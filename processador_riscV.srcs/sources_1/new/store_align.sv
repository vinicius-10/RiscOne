`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador RV32I
// Module Name: store_align
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Faixas de byte e dado replicado das escritas da data_memory.
//
// Dependencies: mem_pkg
//
// Revision:
// Revision 0.01 - File Created (recortado da data_memory)
// Additional Comments:
//   Logica puramente combinacional; usada pela RAM e pelo MMIO.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file store_align.sv
 * @brief Alinhamento das escritas (SB/SH/SW) da data_memory.
 *
 * Gera a habilitacao por faixa de byte e replica o dado nas faixas, de modo
 * que a escrita so altere os bytes enderecados.
 *
 * @param data_i Dado vindo de rs2.
 * @param byte_offset_i Byte dentro da palavra (addr[1:0]).
 * @param mem_width_i Largura do acesso (byte, halfword, word).
 * @retval we_byte_o Habilitacao de escrita por faixa de byte.
 * @retval wdata_o Dado de escrita replicado nas faixas.
 */
module store_align
    import mem_pkg::*;
(
    input  logic [31:0] data_i,
    input  logic [1:0]  byte_offset_i,
    input  mem_width_t  mem_width_i,
    output logic [3:0]  we_byte_o,
    output logic [31:0] wdata_o
);

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: we_byte_o = 4'b0001 << byte_offset_i;
            MEM_WIDTH_HALF: we_byte_o = byte_offset_i[1] ? 4'b1100 : 4'b0011;
            MEM_WIDTH_WORD: we_byte_o = 4'b1111;
            default:        we_byte_o = 4'b1111;
        endcase
    end

    always_comb begin
        case (mem_width_i)
            MEM_WIDTH_BYTE: wdata_o = {4{data_i[7:0]}};
            MEM_WIDTH_HALF: wdata_o = {2{data_i[15:0]}};
            MEM_WIDTH_WORD: wdata_o = data_i;
            default:        wdata_o = data_i;
        endcase
    end

endmodule
