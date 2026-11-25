`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026 10:00:00
// Design Name: Processador RV32I
// Module Name: branch_comparator
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Comparador dedicado dos desvios condicionais (rs1 x rs2).
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Recortado da execution sem mudar a logica.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file branch_comparator.sv
 * @brief Comparador de desvio em cadeia única, configurado pelo funct3.
 *
 * Compara `reg_data1_i` (rs1) com `reg_data2_i` (rs2) direto, sem os muxes de
 * operando nem a ALU. `funct3_i[2]` = 0 compara igualdade (BEQ/BNE) e 1
 * compara "menor" (BLT/BGE/BLTU/BGEU); `funct3_i[1]` = 1 é sem sinal.
 *
 * @param XLEN Largura dos operandos. Valor padrao: 32 bits.
 * @param reg_data1_i Valor lido do registrador rs1.
 * @param reg_data2_i Valor lido do registrador rs2.
 * @param funct3_i funct3 da instrucao; escolhe a comparacao.
 * @retval branch_cond_o Resultado da comparacao (1 = igual ou menor, conforme
 *                       o modo).
 */
module branch_comparator #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] reg_data1_i,
    input  logic [XLEN-1:0] reg_data2_i,
    input  logic [2:0]      funct3_i,

    output logic            branch_cond_o
);

    // Comparador dedicado dos desvios: rs1 x rs2 direto, sem os muxes de
    // operando nem a ALU. É uma cadeia de carry só, configurada pelo funct3
    // (fio da instrução, pronto junto com a leitura do banco): funct3[2] = 0
    // compara igualdade e 1 compara "menor"; funct3[1] = 1 é sem sinal. Com
    // sinal = sem sinal com o bit 31 dos dois operandos invertido.
    // A cadeia anda em dígitos de 2 bits: cmp_eq = dígitos iguais (propaga) e
    // cmp_lt = dígito de rs1 menor (gera; só no modo "menor"). O carry de
    // cmp_lt + (cmp_lt ^ cmp_eq) + cin, com cin = 1 no modo igualdade, é o
    // resultado da comparação; escrito assim, a síntese monta um único
    // somador de 16 dígitos (4 CARRY4) em vez de três comparadores e um mux.
    logic              cmp_less;     // 1: "menor"; 0: igualdade
    logic              cmp_signed;
    logic [XLEN-1:0]   cmp_a;
    logic [XLEN-1:0]   cmp_b;
    logic [XLEN/2-1:0] cmp_eq;
    logic [XLEN/2-1:0] cmp_lt;
    logic [XLEN/2:0]   cmp_chain;

    assign cmp_less   = funct3_i[2];
    assign cmp_signed = ~funct3_i[1];
    assign cmp_a      = {reg_data1_i[XLEN-1] ^ cmp_signed, reg_data1_i[XLEN-2:0]};
    assign cmp_b      = {reg_data2_i[XLEN-1] ^ cmp_signed, reg_data2_i[XLEN-2:0]};

    always_comb begin
        for (int j = 0; j < XLEN/2; j++) begin
            cmp_eq[j] = (cmp_a[2*j +: 2] == cmp_b[2*j +: 2]);
            cmp_lt[j] = cmp_less & (cmp_a[2*j +: 2] < cmp_b[2*j +: 2]);
        end
    end

    assign cmp_chain     = {1'b0, cmp_lt} + {1'b0, cmp_lt ^ cmp_eq} + {{(XLEN/2){1'b0}}, ~cmp_less};
    assign branch_cond_o = cmp_chain[XLEN/2];

endmodule
