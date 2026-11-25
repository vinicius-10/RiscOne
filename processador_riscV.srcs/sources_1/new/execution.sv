`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 29.09.2026 13:30:30
// Design Name: Processador RV32I
// Module Name: execution
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Executa operacoes da ALU e calcula enderecos e condicoes de desvio.
//
// Dependencies: alu, branch_comparator, branch_unit, mem_addr_unit, alu_pkg,
//               branch_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Os seletores das entradas da ALU devem receber somente os codigos descritos
//   na interface. O destino calculado para desvio tem o bit menos significativo
//   zerado para manter o alinhamento de instrucao.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file execution.sv
 * @brief Unidade de execucao do processador RV32I.
 *
 * Seleciona os operandos da ALU, executa a operacao indicada e calcula em
 * paralelo o endereco de destino de desvio. Para desvios condicionais, a
 * decisão vem de um comparador dedicado entre `reg_data1_i` (rs1) e
 * `reg_data2_i` (rs2), que não passa pelos muxes de operando nem pela ALU.
 * `funct3_i` escolhe a comparação, como no RV32I: `funct3_i[2]` = 0 igualdade
 * (BEQ/BNE), 1 menor (BLT/BGE/BLTU/BGEU); `funct3_i[1]` = 1 sem sinal. O
 * `alu_control_i` não participa da comparação. OP_BCT desvia quando a
 * comparação é verdadeira e OP_BCF quando é falsa. OP_BIP e OP_BIR sao desvios
 * incondicionais relativos ao PC e a rs1, respectivamente.
 *
 * Submódulos: `alu` (operação), `branch_comparator` (comparação rs1 x rs2),
 * `branch_unit` (decisão e endereço de destino) e `mem_addr_unit` (endereço
 * de load/store e flags de região). Os muxes de operando ficam aqui.
 *
 * @param XLEN Largura dos dados e enderecos. Valor padrao: 32 bits.
 * @param pc_next_i Endereco sequencial da instrucao, normalmente PC + 4.
 * @param pc_i Endereco da instrucao atual.
 * @param imm_i Imediato estendido da instrucao.
 * @param reg_data1_i Valor lido do registrador rs1.
 * @param reg_data2_i Valor lido do registrador rs2.
 * @param alu_control_i Operacao da ALU, conforme `alu_op_t` de `alu_pkg`.
 * @param branch_control_i Tipo de desvio, conforme `branch_op_t` de `branch_pkg`.
 * @param branch_enable_i Habilita a decisao de desvio.
 * @param control_alu_a Seletor da entrada A: 0 = rs1, 1 = PC.
 * @param control_alu_b Seletor da entrada B: 00 = rs2, 01 = imediato,
 *                       10 = PC+4.
 * @param funct3_i funct3 da instrucao. Nos desvios condicionais escolhe a
 *                 comparacao; nas demais instrucoes e ignorado.
 * @retval pc_branch_o Endereco de destino calculado, com o bit 0 zerado.
 * @retval alu_result_o Resultado da operacao selecionada para a ALU.
 * @retval branch_taken_o Indica se o desvio deve ser tomado.
 * @retval mem_addr_o Endereco de load/store (rs1 + imediato), calculado por um
 *                    somador dedicado em paralelo a ALU para encurtar o
 *                    caminho ate a memoria de dados.
 * @retval mem_io_o Endereco de load/store no espaco de MMIO
 *                  (`mem_addr_o[31:28] == 4'h4`).
 * @retval mem_page0_o Endereco de load/store nos primeiros 4 KiB
 *                     (`mem_addr_o[31:12] == 0`).
 *
 * As duas flags sao calculadas sem esperar o carry do somador e so sao exatas
 * para imediato de 12 bits estendido (`imm_i[31:11]` iguais), ou seja, em loads
 * e stores, as unicas instrucoes que usam a memoria de dados.
 */
module execution
    import alu_pkg::*;
    import branch_pkg::*;
#(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] pc_next_i,
    input  logic [XLEN-1:0] pc_i,
    input  logic [XLEN-1:0] imm_i,
    input  logic [XLEN-1:0] reg_data1_i,
    input  logic [XLEN-1:0] reg_data2_i,

    input  alu_op_t         alu_control_i,
    input  branch_op_t      branch_control_i,
    input  logic            branch_enable_i,
    input  logic            control_alu_a,
    input  logic [1:0]      control_alu_b,
    input  logic [2:0]      funct3_i,

    output logic [XLEN-1:0] pc_branch_o,
    output logic [XLEN-1:0] alu_result_o,
    output logic            branch_taken_o,
    output logic [XLEN-1:0] mem_addr_o,
    output logic            mem_io_o,
    output logic            mem_page0_o
);

    logic [XLEN-1:0] alu_a;
    logic [XLEN-1:0] alu_b;
    logic [XLEN-1:0] alu_result;

    logic [XLEN-1:0] branch_address;
    logic            branch_cond;
    logic            branch_taken;

    assign alu_result_o  = alu_result;
    assign pc_branch_o   = branch_address;
    assign branch_taken_o = branch_taken;

    // Selecao dos operandos enviados a ALU.
    always_comb begin
        case (control_alu_a)
            1'b0: alu_a = reg_data1_i;
            1'b1: alu_a = pc_i;
        endcase

        case (control_alu_b)
            2'b00: alu_b = reg_data2_i;
            2'b01: alu_b = imm_i;
            2'b10: alu_b = pc_next_i;
            default: alu_b = reg_data2_i;
        endcase
    end

    alu #(
        .XLEN(XLEN)
    ) alu_inst (
        .a_i     (alu_a),
        .b_i     (alu_b),
        .alu_op_i(alu_control_i),
        .alu_o   (alu_result)
    );

    // Comparador dedicado dos desvios: rs1 x rs2 direto, sem os muxes de
    // operando nem a ALU (cadeia unica configurada pelo funct3).
    branch_comparator #(
        .XLEN(XLEN)
    ) branch_comparator_inst (
        .reg_data1_i  (reg_data1_i),
        .reg_data2_i  (reg_data2_i),
        .funct3_i     (funct3_i),
        .branch_cond_o(branch_cond)
    );

    // Decisao do desvio e somador do endereco de destino.
    branch_unit #(
        .XLEN(XLEN)
    ) branch_unit_inst (
        .branch_cond_i   (branch_cond),
        .branch_enable_i (branch_enable_i),
        .branch_control_i(branch_control_i),
        .imm_i           (imm_i),
        .pc_i            (pc_i),
        .reg_data1_i     (reg_data1_i),
        .branch_taken_o  (branch_taken),
        .pc_branch_o     (branch_address)
    );

    // Endereco da memoria de dados (rs1 + imediato) e flags de regiao.
    mem_addr_unit #(
        .XLEN(XLEN)
    ) mem_addr_unit_inst (
        .reg_data1_i(reg_data1_i),
        .imm_i      (imm_i),
        .mem_addr_o (mem_addr_o),
        .mem_io_o   (mem_io_o),
        .mem_page0_o(mem_page0_o)
    );

endmodule
