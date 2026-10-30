//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 20.10.2026 17:00:03
// Design Name: Processador RV32I
// Package Name: func3_pkg
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Define os valores do campo funct3 usados na decodificacao RV32I.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Codigos iguais sao distinguidos pelo opcode e pelo formato da instrucao.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file func3_pkg.sv
 * @brief Tipo e constantes para o campo funct3 das instrucoes RV32I.
 *
 * Declara o tipo de tres bits `func3_t` e os codigos utilizados para desvios,
 * loads, stores, operacoes imediatas, operacoes registrador-registrador e
 * instrucoes de sistema. Constantes com o mesmo valor sao interpretadas em
 * conjunto com opcode e funct7, pois esses campos definem a instrucao completa.
 *
 * @package func3_pkg
 * @typedef func3_t Tipo logico de tres bits para valores de funct3.
 *
 * As constantes F3_JALR, F3_BEQ, F3_BNE, F3_BLT, F3_BGE, F3_BLTU, F3_BGEU,
 * F3_LB, F3_LH, F3_LW, F3_LBU, F3_LHU, F3_SB, F3_SH, F3_SW, F3_ADDI, F3_SLTI,
 * F3_SLTIU, F3_XORI, F3_ORI, F3_ANDI, F3_SLLI, F3_SRLI, F3_SRAI, F3_ADD,
 * F3_SUB, F3_SLL, F3_SLT, F3_SLTU, F3_XOR, F3_SRL, F3_SRA, F3_OR, F3_AND,
 * F3_FENCE, F3_FENCE_TSO, F3_PAUSE, F3_ECALL e F3_EBREAK nomeiam os valores
 * correspondentes do campo funct3.
 */

package func3_pkg;

    // Tipos Fortes (Typedef)
    typedef logic [2:0] func3_t;

    // Desvios Condicionais (Branches) e Saltos
    localparam func3_t F3_JALR  = 3'b000;
    localparam func3_t F3_BEQ   = 3'b000;
    localparam func3_t F3_BNE   = 3'b001;
    localparam func3_t F3_BLT   = 3'b100;
    localparam func3_t F3_BGE   = 3'b101;
    localparam func3_t F3_BLTU  = 3'b110;
    localparam func3_t F3_BGEU  = 3'b111;

    // Instruções de Memória - Loads
    localparam func3_t F3_LB    = 3'b000;
    localparam func3_t F3_LH    = 3'b001;
    localparam func3_t F3_LW    = 3'b010;
    localparam func3_t F3_LBU   = 3'b100;
    localparam func3_t F3_LHU   = 3'b101;

    // Instruções de Memória - Stores
    localparam func3_t F3_SB    = 3'b000;
    localparam func3_t F3_SH    = 3'b001;
    localparam func3_t F3_SW    = 3'b010;

    // Operações Aritméticas e Lógicas com Imediato (I-Type)
    localparam func3_t F3_ADDI  = 3'b000;
    localparam func3_t F3_SLTI  = 3'b010;
    localparam func3_t F3_SLTIU = 3'b011;
    localparam func3_t F3_XORI  = 3'b100;
    localparam func3_t F3_ORI   = 3'b110;
    localparam func3_t F3_ANDI  = 3'b111;
    localparam func3_t F3_SLLI  = 3'b001;
    localparam func3_t F3_SRLI  = 3'b101;
    localparam func3_t F3_SRAI  = 3'b101;

    // Operações Registrador-Registrador (R-Type)
    localparam func3_t F3_ADD   = 3'b000;
    localparam func3_t F3_SUB   = 3'b000;
    localparam func3_t F3_SLL   = 3'b001;
    localparam func3_t F3_SLT   = 3'b010;
    localparam func3_t F3_SLTU  = 3'b011;
    localparam func3_t F3_XOR   = 3'b100;
    localparam func3_t F3_SRL   = 3'b101;
    localparam func3_t F3_SRA   = 3'b101;
    localparam func3_t F3_OR    = 3'b110;
    localparam func3_t F3_AND   = 3'b111;

    // Sistema e Barreiras de Sincronização
    localparam func3_t F3_FENCE     = 3'b000;
    localparam func3_t F3_FENCE_TSO = 3'b000;
    localparam func3_t F3_PAUSE     = 3'b000;
    localparam func3_t F3_ECALL     = 3'b000;
    localparam func3_t F3_EBREAK    = 3'b000;

endpackage : func3_pkg
