`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 06.10.2026 17:35:54
// Design Name: Processador RV32I
// Module Name: data_memory
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Memoria de dados byte-addressable com suporte a MMIO integrado (Otimizada para Caminho Crítico).
//
// Dependencies: mem_pkg, mmio, load_align, store_align
//
// Revision:
// Revision 0.02 - Suporte a MMIO integrado com registradores de E/S e caminho crítico otimizado.
// Additional Comments:
//   As escritas na RAM e registradores de I/O ocorrem na borda de subida do clock.
//   As leituras (tanto RAM quanto MMIO) sao combinacionais de baixo atraso.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file data_memory.sv
 * @brief Memoria de dados com MMIO embutido para o datapath RV32I.
 *
 * O MMIO (addr[31:28] == 4'h4, registrador por addr[5:2]) tem quatro saidas e
 * quatro entradas genericas de 32 bits; o significado de cada uma na placa e
 * definido no top_core.
 *
 * Submodulos: mmio (registradores de saida e leitura das entradas),
 * load_align (selecao de byte/halfword e extensao de sinal das leituras) e
 * store_align (faixas de byte e dado replicado das escritas). O array da RAM,
 * sua leitura/escrita e o mux RAM x MMIO ficam aqui.
 *
 * @param addr_io_i Endereco no espaco de MMIO (addr_i[31:28] == 4'h4),
 *                  calculado pela execution sem esperar o somador.
 * @param addr_page0_i Endereco nos primeiros 4 KiB (addr_i[31:12] == 0),
 *                     idem. Por isso MEM_DEPTH*4 nao pode passar de 4096.
 * @param io_in0_i..io_in3_i Entradas genericas, lidas em 0x4000_0010 + 4k
 *                           (escrita ignorada).
 * @retval io_out0_o..io_out3_o Registradores de saida, escritos (por faixa de
 *                              byte) em 0x4000_0000 + 4k. Somente escrita: a
 *                              leitura desses enderecos devolve 0, o que deixa a
 *                              sintese remover os bits sem pino no top_core.
 */
module data_memory
    import mem_pkg::*;
#(
    parameter int XLEN      = 32,
    parameter int MEM_DEPTH = 1024,
    parameter string MEM_FILE = "data.mem"
)(
    input  logic             clk,
    input  logic             mem_write_i,
    input  mem_width_t       mem_width_i,
    input  mem_signed_t      mem_signed_i,
    input  logic [XLEN-1:0]  addr_i,
    input  logic             addr_io_i,
    input  logic             addr_page0_i,
    input  logic [XLEN-1:0]  data_i,
    output logic [XLEN-1:0]  data_o,
    
    // Entradas e saídas genéricas de E/S (MMIO)
    input  logic [31:0]      io_in0_i,
    input  logic [31:0]      io_in1_i,
    input  logic [31:0]      io_in2_i,
    input  logic [31:0]      io_in3_i,

    output logic [31:0]      io_out0_o,
    output logic [31:0]      io_out1_o,
    output logic [31:0]      io_out2_o,
    output logic [31:0]      io_out3_o
);

    // RAM interna: array 1-D de words com escrita por faixa de byte (forma que
    // o Vivado infere como RAM distribuida; o array 2-D de bytes virava FFs).
    logic [31:0] mem [0:MEM_DEPTH-1];

    // data.mem tem um byte por token em ordem de endereco; monta as words
    // little-endian a partir de um array temporario.
    logic [7:0] mem_init_bytes [0:MEM_DEPTH*4-1];

    initial begin
        $readmemh(MEM_FILE, mem_init_bytes);
        for (int w = 0; w < MEM_DEPTH; w++)
            mem[w] = {mem_init_bytes[4*w+3], mem_init_bytes[4*w+2],
                      mem_init_bytes[4*w+1], mem_init_bytes[4*w]};
    end

    localparam int ADDR_WIDTH = $clog2(MEM_DEPTH);

    // addr_page0_i so cobre os primeiros 4 KiB.
    if (MEM_DEPTH * 4 > 4096) begin : g_mem_depth_check
        $error("data_memory: MEM_DEPTH*4 (%0d) passa de 4096, limite de addr_page0_i", MEM_DEPTH * 4);
    end

    // =========================================================================
    // DECODIFICAÇÃO DE ENDEREÇOS
    // Mapeamento:
    //   - 0x0000_0000 até MEM_DEPTH*4-1 (0x0000_03FF com MEM_DEPTH = 256, o valor do core) -> RAM Interna
    //   - 0x4xxx_xxxx                -> Espaço de I/O (MMIO)
    // As comparações dos bits altos vêm prontas da execution (addr_io_i,
    // addr_page0_i), sem esperar o carry do somador de endereço.
    // =========================================================================
    logic                  is_io_space;
    logic                  ram_addr_valid;
    logic [3:0]            io_offset;
    logic [ADDR_WIDTH-1:0] word_addr;
    logic [1:0]            byte_offset;

    assign is_io_space    = addr_io_i;
    assign ram_addr_valid = addr_page0_i && (addr_i[11:0] < (MEM_DEPTH * 4));
    assign io_offset   = addr_i[5:2]; // Offset do registrador no bloco de I/O
    assign word_addr   = addr_i[ADDR_WIDTH+1:2];
    assign byte_offset = addr_i[1:0];

    // =========================================================================
    // LÓGICA DE LEITURA DA RAM INTERNA (Assíncrona)
    // =========================================================================
    logic [31:0] ram_word_data;
    logic [31:0] io_data_out;   // palavra lida dos periféricos (mmio)
    logic [31:0] word_data;     // palavra selecionada: RAM ou MMIO
    logic [31:0] load_data;

    always_comb begin
        if (ram_addr_valid)
            ram_word_data = mem[word_addr];
        else
            ram_word_data = '0;
    end

    // A selecao de byte/halfword e a extensao de sinal valem tanto para a RAM
    // quanto para o MMIO (ex.: LBU em 0x4000_0011 retorna io_in0_i[15:8]).
    assign word_data = is_io_space ? io_data_out : ram_word_data;

    load_align load_align_inst (
        .word_data_i   (word_data),
        .byte_offset_i (byte_offset),
        .mem_width_i   (mem_width_i),
        .mem_signed_i  (mem_signed_i),
        .load_data_o   (load_data)
    );

    // =========================================================================
    // LÓGICA DE ESCRITA (Síncrona)
    // =========================================================================
    logic [3:0]  we_byte;
    logic [31:0] wdata;
    logic        ram_write_en;

    store_align store_align_inst (
        .data_i        (data_i),
        .byte_offset_i (byte_offset),
        .mem_width_i   (mem_width_i),
        .we_byte_o     (we_byte),
        .wdata_o       (wdata)
    );

    // Impede escrita na RAM se o endereço pertencer ao espaço de I/O
    assign ram_write_en = mem_write_i & ~is_io_space & ram_addr_valid;

    always_ff @(posedge clk) begin
        if (ram_write_en) begin
            for (int b = 0; b < 4; b++)
                if (we_byte[b]) mem[word_addr][8*b +: 8] <= wdata[8*b +: 8];
        end
    end

    // =========================================================================
    // MMIO: registradores de saída e leitura das entradas
    // =========================================================================
    mmio mmio_inst (
        .clk           (clk),
        .mem_write_i   (mem_write_i),
        .is_io_space_i (is_io_space),
        .io_offset_i   (io_offset),
        .we_byte_i     (we_byte),
        .wdata_i       (wdata),
        .io_in0_i      (io_in0_i),
        .io_in1_i      (io_in1_i),
        .io_in2_i      (io_in2_i),
        .io_in3_i      (io_in3_i),
        .io_out0_o     (io_out0_o),
        .io_out1_o     (io_out1_o),
        .io_out2_o     (io_out2_o),
        .io_out3_o     (io_out3_o),
        .io_data_o     (io_data_out)
    );

    // =========================================================================
    // MULTIPLEXADOR DE SAÍDA FINAL (Caminho Crítico Otimizado)
    // =========================================================================
    assign data_o = load_data;

endmodule
