`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador rv32i
// Module Name: alu_logic
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Bloco lógico da ALU
//
// Dependencies: alu_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file alu_logic.sv
 * @brief Bloco lógico da ALU (submódulo da `alu`): AND, OR, XOR e PASS_B.
 *
 * @param XLEN Largura dos operandos e do resultado. Valor padrão: 32 bits.
 * @param a_i Operando A de entrada.
 * @param b_i Operando B de entrada.
 * @param alu_op_i Código da operação a ser executada.
 * @retval res_logic_o Resultado de AND, OR ou XOR; `b_i` nas demais operações (PASS_B).
 */
module alu_logic import alu_pkg::*; #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] a_i,
    input  logic [XLEN-1:0] b_i,
    input  alu_op_t         alu_op_i,
    output logic [XLEN-1:0] res_logic_o
);

    // --------------------------------------------------------
    // Bloco Lógico
    // --------------------------------------------------------
    always_comb begin
        case (alu_op_i)
            OP_AND:  res_logic_o = a_i & b_i;
            OP_OR:   res_logic_o = a_i | b_i;
            OP_XOR:  res_logic_o = a_i ^ b_i;
            default: res_logic_o = b_i;
        endcase
    end

endmodule
