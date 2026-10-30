`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 16.09.2026 08:30:03
// Design Name: Processador RV32I
// Package Name: alu_pkg
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Define os codigos de operacao usados pela unidade ALU.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Os codigos sao usados pela control_unit, pela ALU e pela unidade de execucao.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file alu_pkg.sv
 * @brief Tipos e codigos de operacao da ALU.
 *
 * Declara `alu_op_t`, um enum de quatro bits utilizado para selecionar as
 * operacoes aritmeticas, logicas, de deslocamento, comparacao e passagem de
 * operando implementadas pela ALU.
 *
 * @package alu_pkg
 * @typedef alu_op_t Codigo de operacao da ALU.
 * Valores: OP_ADD (soma), OP_SUB (subtracao), OP_AND, OP_OR, OP_XOR,
 * OP_SLL, OP_SRL, OP_SRA, OP_SLT (menor que com sinal), OP_SLTU (menor que
 * sem sinal), OP_PASS_B (encaminha B) e OP_CMP (igualdade).
 */
package alu_pkg;

    typedef enum logic [3:0] {
        OP_ADD    = 4'b0000, // Soma: S = A + B
        OP_SUB    = 4'b0001, // Subtração: S = A - B
        OP_AND    = 4'b0010, // E Lógico: S = A AND B
        OP_OR     = 4'b0011, // OU Lógico: S = A OR B
        OP_XOR    = 4'b0100, // OU Exclusivo Lógico: S = A XOR B
        OP_SLL    = 4'b0101, // Deslocamento Esquerdo Lógico: S = A << B[4:0]
        OP_SRL    = 4'b0110, // Deslocamento Direito Lógico: S = A >> B[4:0]
        OP_SRA    = 4'b0111, // Deslocamento Direito Aritmético: S = $signed(A) >>> B[4:0]
        OP_SLT    = 4'b1000, // Comparação Menor Que Com Sinal
        OP_SLTU   = 4'b1001, // Comparação Menor Que Sem Sinal
        OP_PASS_B = 4'b1010, // Passagem Direta do Operando B
        OP_CMP    = 4'b1011  // Comparação de igualdade entre A e B
    } alu_op_t;

endpackage : alu_pkg
