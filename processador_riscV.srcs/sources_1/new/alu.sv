`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 16.09.2026 09:00:49
// Design Name: Processador rv32i
// Module Name: alu
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Ula para realizar todos as instruções do conjunto rv32i
// 
// Dependencies: alu_pkg, alu_arith, alu_logic, alu_shift
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file alu.sv
 * @brief Unidade Lógica e Aritmética (ALU) do processador RV32I.
 *
 * Esta unidade executa operações aritméticas, lógicas, comparações e
 * deslocamentos sobre dois operandos de entrada. O resultado é selecionado
 * conforme o código de operação `alu_op_i` e pode ser usado diretamente pelo
 * datapath do processador.
 *
 * Operações suportadas:
 * - aritmética: soma, subtração;
 * - lógica: AND, OR, XOR;
 * - comparação: SLT, SLTU;
 * - deslocamento: SLL, SRL, SRA;
 * - passagem: PASS_B.
 *
 * Submódulos: `alu_arith` (soma/subtração, SLT, SLTU), `alu_logic` (AND, OR,
 * XOR, PASS_B) e `alu_shift` (SLL, SRL, SRA); a `alu` só escolhe o resultado
 * final pelo `alu_op_i`.
 *
 * A ALU não decide desvios: a condição dos branches vem do comparador dedicado
 * da `execution`. Por isso `OP_CMP` (igualdade, usado só por BEQ/BNE) não é
 * calculado aqui e cai no valor padrão 0.
 *
 * @param XLEN Largura dos operandos e do resultado da ALU. Valor padrão: 32 bits.
 * @param a_i Operando A de entrada.
 * @param b_i Operando B de entrada.
 * @param alu_op_i Código da operação a ser executada.
 * @retval alu_o Resultado da operação selecionada (0 para OP_CMP).
 */
module alu import alu_pkg::*; #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] a_i,
    input  logic [XLEN-1:0] b_i,
    input  alu_op_t         alu_op_i,
    output logic [XLEN-1:0] alu_o
);



    // --------------------------------------------------------
    // 1. Bloco Aritmético e Comparações (Compartilhamento CARRY4)
    // --------------------------------------------------------
    logic [XLEN-1:0] res_arith;

    alu_arith #(.XLEN(XLEN)) alu_arith_inst (
        .a_i         (a_i),
        .b_i         (b_i),
        .alu_op_i    (alu_op_i),
        .res_arith_o (res_arith)
    );

    // --------------------------------------------------------
    // 2. Bloco Lógico
    // --------------------------------------------------------
    logic [XLEN-1:0] res_logic;

    alu_logic #(.XLEN(XLEN)) alu_logic_inst (
        .a_i         (a_i),
        .b_i         (b_i),
        .alu_op_i    (alu_op_i),
        .res_logic_o (res_logic)
    );

    // --------------------------------------------------------
    // 3. Bloco de Deslocamento (Barrel Shifter)
    // --------------------------------------------------------
    logic [XLEN-1:0] res_shift;

    alu_shift #(.XLEN(XLEN)) alu_shift_inst (
        .a_i         (a_i),
        .b_i         (b_i),
        .alu_op_i    (alu_op_i),
        .res_shift_o (res_shift)
    );

    // --------------------------------------------------------
    // 4. Multiplexador Final
    // --------------------------------------------------------
    always_comb begin
        case (alu_op_i)
            OP_ADD, OP_SUB, OP_SLT, OP_SLTU:   alu_o = res_arith;
            OP_AND, OP_OR, OP_XOR, OP_PASS_B:  alu_o = res_logic;
            OP_SLL, OP_SRL, OP_SRA:            alu_o = res_shift;
            default:                           alu_o = '0;   // inclui OP_CMP
        endcase
    end

endmodule

