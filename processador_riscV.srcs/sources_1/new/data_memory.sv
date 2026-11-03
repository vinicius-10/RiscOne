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
// Dependencies: mem_pkg
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
    input  logic [XLEN-1:0]  data_i,
    output logic [XLEN-1:0]  data_o,
    
    // Entradas e Saídas físicas dos Periféricos (MMIO)
    input  logic [15:0]      switch_i,
    input  logic [4:0]       button_i,
    input  logic [3:0]       pmod_row_i,
    
    output logic [15:0]      led_o,
    output logic [15:0]      seg7_o,
    output logic [3:0]       pmod_col_o
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

    // =========================================================================
    // DECODIFICAÇÃO DE ENDEREÇOS (Otimizada para Caminho Crítico)
    // Mapeamento:
    //   - 0x0000_0000 até MEM_DEPTH*4-1 (0x0000_0FFF com MEM_DEPTH = 1024) -> RAM Interna
    //   - 0x4000_0000 em diante      -> Espaço de I/O (MMIO)
    // =========================================================================
    logic                  is_io_space;
    logic                  ram_addr_valid;
    logic [3:0]            io_offset;
    logic [ADDR_WIDTH-1:0] word_addr;
    logic [1:0]            byte_offset;

    assign is_io_space = (addr_i[31:28] == 4'h4);
    assign ram_addr_valid = (addr_i < (MEM_DEPTH * 4));
    assign io_offset   = addr_i[5:2]; // Offset do registrador no bloco de I/O
    assign word_addr   = addr_i[ADDR_WIDTH+1:2];
    assign byte_offset = addr_i[1:0];

    // =========================================================================
    // LÓGICA DE LEITURA DA RAM INTERNA (Assíncrona)
    // =========================================================================
    logic [31:0] ram_word_data;
    logic [31:0] io_data_out;   // palavra lida dos periféricos (definida abaixo)
    logic [31:0] word_data;     // palavra selecionada: RAM ou MMIO
    logic [7:0]  byte_sel;
    logic [15:0] half_sel;
    logic        sign_b;
    logic        sign_h;
    logic [31:0] load_data;

    always_comb begin
        if (ram_addr_valid)
            ram_word_data = mem[word_addr];
        else
            ram_word_data = '0;
    end

    // A selecao de byte/halfword e a extensao de sinal valem tanto para a RAM
    // quanto para o MMIO (ex.: LBU no byte 1 das chaves retorna switch[15:8]).
    assign word_data = is_io_space ? io_data_out : ram_word_data;

    always_comb begin
        case (byte_offset)
            2'b00:  byte_sel = word_data[7:0];
            2'b01:  byte_sel = word_data[15:8];
            2'b10:  byte_sel = word_data[23:16];
            2'b11:  byte_sel = word_data[31:24];
        endcase
    end

    assign half_sel = byte_offset[1] ? word_data[31:16] : word_data[15:0];

    assign sign_b = (mem_signed_i == MEM_SIGNED) & byte_sel[7];
    assign sign_h = (mem_signed_i == MEM_SIGNED) & half_sel[15];

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: load_data = {{24{sign_b}}, byte_sel};
            MEM_WIDTH_HALF: load_data = {{16{sign_h}}, half_sel};
            MEM_WIDTH_WORD: load_data = word_data;
            default:        load_data = word_data;
        endcase
    end

    // =========================================================================
    // LÓGICA DE ESCRITA (Síncrona)
    // =========================================================================
    logic [3:0]  we_byte;
    logic [31:0] wdata;
    logic        ram_write_en;

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: we_byte = 4'b0001 << byte_offset;
            MEM_WIDTH_HALF: we_byte = byte_offset[1] ? 4'b1100 : 4'b0011;
            MEM_WIDTH_WORD: we_byte = 4'b1111;
            default:        we_byte = 4'b1111;
        endcase
    end

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: wdata = {4{data_i[7:0]}};
            MEM_WIDTH_HALF: wdata = {2{data_i[15:0]}};
            MEM_WIDTH_WORD: wdata = data_i;
            default:        wdata = data_i;
        endcase
    end

    // Impede escrita na RAM se o endereço pertencer ao espaço de I/O
    assign ram_write_en = mem_write_i & ~is_io_space & ram_addr_valid;

    always_ff @(posedge clk) begin
        if (ram_write_en) begin
            for (int b = 0; b < 4; b++)
                if (we_byte[b]) mem[word_addr][8*b +: 8] <= wdata[8*b +: 8];
        end
    end

    // Habilitação de escrita para os periféricos de saída individuais
    logic io_write_leds;
    logic io_write_seg7;
    logic io_write_pmod;

    assign io_write_leds = mem_write_i && is_io_space && (io_offset == 4'h0);
    assign io_write_seg7 = mem_write_i && is_io_space && (io_offset == 4'h3);
    assign io_write_pmod = mem_write_i && is_io_space && (io_offset == 4'h4);

    // Registradores síncronos dedicados para os periféricos de saída
    initial begin
        led_o      = '0;
        seg7_o     = '0;
        pmod_col_o = '0;
    end

    // Escrita por faixa de bytes (mesmos we_byte/wdata da RAM): SB/SH alteram
    // apenas os bytes enderecados; SW se comporta como antes.
    always_ff @(posedge clk) begin
        if (io_write_leds) begin
            if (we_byte[0]) led_o[7:0]   <= wdata[7:0];
            if (we_byte[1]) led_o[15:8]  <= wdata[15:8];
        end
        if (io_write_seg7) begin
            if (we_byte[0]) seg7_o[7:0]  <= wdata[7:0];
            if (we_byte[1]) seg7_o[15:8] <= wdata[15:8];
        end
        if (io_write_pmod && we_byte[0]) pmod_col_o <= wdata[3:0];
    end

    // =========================================================================
    // LEITURA DOS PERIFÉRICOS (Mapeamento de Entrada / Estado)
    // =========================================================================
    always_comb begin
        case (io_offset)
            4'h0:    io_data_out = {16'h0, led_o};       // Lê estado atual dos LEDs
            4'h1:    io_data_out = {16'h0, switch_i};    // Lê as Chaves (Switches)
            4'h2:    io_data_out = {27'h0, button_i};    // Lê os Botões
            4'h3:    io_data_out = {16'h0, seg7_o};      // Lê Display de 7 Segmentos
            4'h4:    io_data_out = {28'h0, pmod_row_i};  // Lê Teclado Matricial (Linhas)
            default: io_data_out = 32'h0;
        endcase
    end

    // =========================================================================
    // MULTIPLEXADOR DE SAÍDA FINAL (Caminho Crítico Otimizado)
    // =========================================================================
    assign data_o = load_data;

endmodule
