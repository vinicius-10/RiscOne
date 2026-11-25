`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador RV32I
// Module Name: mmio
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Registradores de saida e mux de leitura do MMIO da data_memory.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created (recortado da data_memory)
// Additional Comments:
//   As escritas nos registradores de saida ocorrem na borda de subida do clock;
//   a leitura das entradas e combinacional.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file mmio.sv
 * @brief Perifericos de E/S mapeados em memoria (MMIO) da data_memory.
 *
 * Quatro registradores de saida de 32 bits (0x4000_0000 + 4k, somente escrita)
 * e o mux de leitura das quatro entradas (0x4000_0010 + 4k). A escrita usa as
 * mesmas faixas de byte (we_byte/wdata) da RAM.
 *
 * @param clk Clock do sistema.
 * @param mem_write_i Habilitacao de escrita na memoria de dados.
 * @param is_io_space_i Endereco no espaco de MMIO (addr[31:28] == 4'h4).
 * @param io_offset_i Registrador selecionado (addr[5:2]).
 * @param we_byte_i Habilitacao de escrita por faixa de byte (store_align).
 * @param wdata_i Dado de escrita replicado nas faixas (store_align).
 * @param io_in0_i..io_in3_i Entradas genericas, lidas nos offsets 4..7.
 * @retval io_out0_o..io_out3_o Registradores de saida (offsets 0..3).
 * @retval io_data_o Palavra lida dos perifericos (0 fora dos offsets 4..7).
 */
module mmio (
    input  logic        clk,
    input  logic        mem_write_i,
    input  logic        is_io_space_i,
    input  logic [3:0]  io_offset_i,
    input  logic [3:0]  we_byte_i,
    input  logic [31:0] wdata_i,

    input  logic [31:0] io_in0_i,
    input  logic [31:0] io_in1_i,
    input  logic [31:0] io_in2_i,
    input  logic [31:0] io_in3_i,

    output logic [31:0] io_out0_o,
    output logic [31:0] io_out1_o,
    output logic [31:0] io_out2_o,
    output logic [31:0] io_out3_o,
    output logic [31:0] io_data_o
);

    // Habilitação de escrita das saídas (offsets 0..3); entradas não são graváveis
    logic io_write_out0;
    logic io_write_out1;
    logic io_write_out2;
    logic io_write_out3;

    assign io_write_out0 = mem_write_i && is_io_space_i && (io_offset_i == 4'h0);
    assign io_write_out1 = mem_write_i && is_io_space_i && (io_offset_i == 4'h1);
    assign io_write_out2 = mem_write_i && is_io_space_i && (io_offset_i == 4'h2);
    assign io_write_out3 = mem_write_i && is_io_space_i && (io_offset_i == 4'h3);

    // Registradores síncronos das saídas
    initial begin
        io_out0_o = '0;
        io_out1_o = '0;
        io_out2_o = '0;
        io_out3_o = '0;
    end

    // Escrita por faixa de bytes (mesmos we_byte/wdata da RAM): SB/SH alteram
    // apenas os bytes enderecados.
    always_ff @(posedge clk) begin
        for (int b = 0; b < 4; b++) begin
            if (io_write_out0 && we_byte_i[b]) io_out0_o[8*b +: 8] <= wdata_i[8*b +: 8];
            if (io_write_out1 && we_byte_i[b]) io_out1_o[8*b +: 8] <= wdata_i[8*b +: 8];
            if (io_write_out2 && we_byte_i[b]) io_out2_o[8*b +: 8] <= wdata_i[8*b +: 8];
            if (io_write_out3 && we_byte_i[b]) io_out3_o[8*b +: 8] <= wdata_i[8*b +: 8];
        end
    end

    // =========================================================================
    // LEITURA DO MMIO: entradas em 0x10..0x1C; saídas (0x00..0x0C) leem 0
    // =========================================================================
    always_comb begin
        case (io_offset_i)
            4'h4:    io_data_o = io_in0_i;
            4'h5:    io_data_o = io_in1_i;
            4'h6:    io_data_o = io_in2_i;
            4'h7:    io_data_o = io_in3_i;
            default: io_data_o = 32'h0;
        endcase
    end

endmodule
