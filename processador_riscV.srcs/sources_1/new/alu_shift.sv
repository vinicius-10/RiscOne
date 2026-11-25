`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador rv32i
// Module Name: alu_shift
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Bloco de deslocamento (barrel shifter) da ALU
//
// Dependencies: alu_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file alu_shift.sv
 * @brief Bloco de deslocamento da ALU (submódulo da `alu`): SLL, SRL e SRA.
 *
 * A quantidade de deslocamento é `b_i[4:0]`.
 *
 * @param XLEN Largura dos operandos e do resultado. Valor padrão: 32 bits.
 * @param a_i Operando A de entrada (valor deslocado).
 * @param b_i Operando B de entrada (bits [4:0] = quantidade de deslocamento).
 * @param alu_op_i Código da operação a ser executada.
 * @retval res_shift_o Resultado de SLL, SRL ou SRA; 0 nas demais operações.
 */
module alu_shift import alu_pkg::*; #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] a_i,
    input  logic [XLEN-1:0] b_i,
    input  alu_op_t         alu_op_i,
    output logic [XLEN-1:0] res_shift_o
);

    // --------------------------------------------------------
    // Bloco de Deslocamento (Barrel Shifter)
    // --------------------------------------------------------
    always_comb begin
        case (alu_op_i)
            OP_SLL:  res_shift_o = a_i << b_i[4:0];
            OP_SRL:  res_shift_o = a_i >> b_i[4:0];
            OP_SRA:  res_shift_o = $signed(a_i) >>> b_i[4:0];
            default: res_shift_o = '0;
        endcase
    end

endmodule
