`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador RV32I
// Module Name: load_align
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Selecao de byte/halfword e extensao de sinal das leituras da data_memory.
//
// Dependencies: mem_pkg
//
// Revision:
// Revision 0.01 - File Created (recortado da data_memory)
// Additional Comments:
//   Logica puramente combinacional.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file load_align.sv
 * @brief Alinhamento das leituras (LB/LBU/LH/LHU/LW) da data_memory.
 *
 * A selecao de byte/halfword e a extensao de sinal valem tanto para a RAM
 * quanto para o MMIO (ex.: LBU em 0x4000_0011 retorna io_in0_i[15:8]).
 *
 * @param word_data_i Palavra lida (RAM ou MMIO).
 * @param byte_offset_i Byte dentro da palavra (addr[1:0]).
 * @param mem_width_i Largura do acesso (byte, halfword, word).
 * @param mem_signed_i Extensao com sinal ou com zero.
 * @retval load_data_o Dado alinhado e estendido para 32 bits.
 */
module load_align
    import mem_pkg::*;
(
    input  logic [31:0] word_data_i,
    input  logic [1:0]  byte_offset_i,
    input  mem_width_t  mem_width_i,
    input  mem_signed_t mem_signed_i,
    output logic [31:0] load_data_o
);

    logic [7:0]  byte_sel;
    logic [15:0] half_sel;
    logic        sign_b;
    logic        sign_h;

    always_comb begin
        case (byte_offset_i)
            2'b00:  byte_sel = word_data_i[7:0];
            2'b01:  byte_sel = word_data_i[15:8];
            2'b10:  byte_sel = word_data_i[23:16];
            2'b11:  byte_sel = word_data_i[31:24];
        endcase
    end

    assign half_sel = byte_offset_i[1] ? word_data_i[31:16] : word_data_i[15:0];

    assign sign_b = (mem_signed_i == MEM_SIGNED) & byte_sel[7];
    assign sign_h = (mem_signed_i == MEM_SIGNED) & half_sel[15];

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: load_data_o = {{24{sign_b}}, byte_sel};
            MEM_WIDTH_HALF: load_data_o = {{16{sign_h}}, half_sel};
            MEM_WIDTH_WORD: load_data_o = word_data_i;
            default:        load_data_o = word_data_i;
        endcase
    end

endmodule
