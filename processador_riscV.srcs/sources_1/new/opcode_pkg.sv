`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 20.10.2026 09:29:50
// Design Name: Processador RV32I
// Package Name: opcode_pkg
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Define os opcodes RV32I reconhecidos pela unidade de controle.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Cada opcode ocupa sete bits e identifica uma classe/formato de instrucao.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file opcode_pkg.sv
 * @brief Tipo e codigos de opcode usados no processador RV32I.
 *
 * Declara `opcode_t`, um enum de sete bits com os codigos de operacoes
 * registrador-registrador e imediatas, loads, stores, desvios, saltos,
 * operacoes superiores e instrucoes de sistema/barreiras.
 *
 * @package opcode_pkg
 * @typedef opcode_t Opcode de sete bits da instrucao.
 *
 * Codigos: OPCODE_OP, OPCODE_LOAD, OPCODE_MISC_MEM, OPCODE_OP_IMM,
 * OPCODE_JALR, OPCODE_SYSTEM, OPCODE_STORE, OPCODE_BRANCH, OPCODE_AUIPC,
 * OPCODE_LUI e OPCODE_JAL.
 */


package opcode_pkg;

    typedef enum logic [6:0] {
        OPCODE_OP       = 7'b0110011, // Operacoes registrador-registrador (R-type)
        OPCODE_LOAD     = 7'b0000011, // Loads
        OPCODE_MISC_MEM = 7'b0001111, // FENCE e instrucoes MISC-MEM
        OPCODE_OP_IMM   = 7'b0010011, // Operacoes com imediato (I-type)
        OPCODE_JALR     = 7'b1100111, // Salto indireto relativo a rs1
        OPCODE_SYSTEM   = 7'b1110011, // Instrucoes de sistema
        OPCODE_STORE    = 7'b0100011, // Stores
        OPCODE_BRANCH   = 7'b1100011, // Desvios condicionais
        OPCODE_AUIPC    = 7'b0010111, // Soma imediato superior ao PC
        OPCODE_LUI      = 7'b0110111, // Carrega imediato superior
        OPCODE_JAL      = 7'b1101111  // Salto relativo ao PC
    } opcode_t;

endpackage : opcode_pkg
