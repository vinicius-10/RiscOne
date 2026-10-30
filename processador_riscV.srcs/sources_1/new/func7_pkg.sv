`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 20.10.2026 17:00:03
// Design Name: Processador RV32I
// Package Name: func7_pkg
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Define os valores funct7 usados na decodificacao RV32I.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   F7_ZERO e F7_ALT descrevem os padroes principais; os demais nomes sao aliases.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file func7_pkg.sv
 * @brief Tipo e constantes para o campo funct7 das instrucoes RV32I.
 *
 * Declara `func7_t`, um tipo logico de sete bits, e os padroes usados para
 * distinguir operacoes que compartilham opcode e funct3. `F7_ZERO` representa
 * 0000000 e `F7_ALT` representa 0100000. As constantes especificas por
 * instrucao sao aliases de um desses dois valores.
 *
 * @package func7_pkg
 * @typedef func7_t Tipo logico de sete bits para valores de funct7.
 *
 * Aliases disponiveis: F7_ADD, F7_SUB, F7_SLL, F7_SLT, F7_SLTU, F7_XOR,
 * F7_SRL, F7_SRA, F7_OR, F7_AND, F7_SLLI, F7_SRLI e F7_SRAI.
 */


package func7_pkg;

    // Tipos Fortes (Typedef)
    typedef logic [6:0] func7_t;

    // Valores Padrão do Campo funct7
    localparam func7_t F7_ZERO = 7'b0000000; // Padrão para ADD, SLL, SRL, XOR, OR, AND, SLLI, SRLI
    localparam func7_t F7_ALT  = 7'b0100000; // Alternativo para SUB, SRA, SRAI

    // Aliases explícitos por instrução R-Type e Shifts com Imediato
    localparam func7_t F7_ADD  = F7_ZERO;
    localparam func7_t F7_SUB  = F7_ALT;
    localparam func7_t F7_SLL  = F7_ZERO;
    localparam func7_t F7_SLT  = F7_ZERO;
    localparam func7_t F7_SLTU = F7_ZERO;
    localparam func7_t F7_XOR  = F7_ZERO;
    localparam func7_t F7_SRL  = F7_ZERO;
    localparam func7_t F7_SRA  = F7_ALT;
    localparam func7_t F7_OR   = F7_ZERO;
    localparam func7_t F7_AND  = F7_ZERO;

    localparam func7_t F7_SLLI = F7_ZERO;
    localparam func7_t F7_SRLI = F7_ZERO;
    localparam func7_t F7_SRAI = F7_ALT;

endpackage : func7_pkg
