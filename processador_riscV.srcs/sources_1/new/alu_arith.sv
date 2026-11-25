`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador rv32i
// Module Name: alu_arith
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Bloco aritmético e de comparações da ALU
//
// Dependencies: alu_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file alu_arith.sv
 * @brief Bloco aritmético e de comparações da ALU (submódulo da `alu`).
 *
 * Um único somador (compartilhando a cadeia CARRY4) faz soma e subtração;
 * SLT e SLTU usam o mesmo resultado da subtração.
 *
 * @param XLEN Largura dos operandos e do resultado. Valor padrão: 32 bits.
 * @param a_i Operando A de entrada.
 * @param b_i Operando B de entrada.
 * @param alu_op_i Código da operação a ser executada.
 * @retval res_arith_o Resultado de ADD, SUB, SLT ou SLTU (soma/subtração nas demais operações).
 */
module alu_arith import alu_pkg::*; #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] a_i,
    input  logic [XLEN-1:0] b_i,
    input  alu_op_t         alu_op_i,
    output logic [XLEN-1:0] res_arith_o
);

    // --------------------------------------------------------
    // Bloco Aritmético e Comparações (Compartilhamento CARRY4)
    // --------------------------------------------------------
    logic            is_sub;
    logic [XLEN-1:0] b_mux;
    logic [XLEN:0]   add_sub_res;

    assign is_sub = (alu_op_i == OP_SUB)  |
                    (alu_op_i == OP_SLT)  |
                    (alu_op_i == OP_SLTU);

    assign b_mux  = is_sub ? ~b_i : b_i;
    assign add_sub_res = a_i + b_mux + is_sub;

    logic cmp_slt, cmp_sltu;

    assign cmp_sltu = ~add_sub_res[XLEN];
    assign cmp_slt  = (a_i[XLEN-1] != b_i[XLEN-1]) ? a_i[XLEN-1] : add_sub_res[XLEN-1];

    assign res_arith_o = (alu_op_i == OP_SLT)  ? {{(XLEN-1){1'b0}}, cmp_slt}  :
                         (alu_op_i == OP_SLTU) ? {{(XLEN-1){1'b0}}, cmp_sltu} :
                         add_sub_res[XLEN-1:0];

endmodule
