`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 21.10.2026 08:19:50
// Design Name: Processador RV32I
// Module Name: decoder
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Integra o banco de registradores, o gerador de imediato e a
//              unidade de controle da etapa de decodificacao RV32I.
//
// Dependencies: register_file, imm_gen, control_unit, alu_pkg, branch_pkg,
//               mem_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   O registrador de destino (rd) e usado internamente como endereco de escrita
//   do banco. written_data_i vem externamente da etapa de write-back.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file decoder.sv
 * @brief Integra os blocos da etapa de decodificacao do processador RV32I.
 *
 * Extrai rd, rs1 e rs2 da instrucao, le os operandos no banco de registradores,
 * gera o imediato e encaminha os sinais de controle para as demais etapas do
 * datapath. O sinal de habilitacao de escrita da unidade de controle e ligado
 * diretamente ao banco; o dado escrito e recebido da etapa de write-back.
 *
 * @param XLEN Largura dos dados do banco e dos barramentos de dados. Padrao: 32.
 * @param REG_XLEN Largura dos enderecos de registrador. Padrao: 5.
 * @param clk Clock do banco de registradores.
 * @param instruction_i Instrucao RV32I de 32 bits a decodificar.
 * @param written_data_i Dado de XLEN bits recebido da etapa de write-back.
 * @param rs1_o Dado lido do registrador indicado pelo campo rs1.
 * @param rs2_o Dado lido do registrador indicado pelo campo rs2.
 * @param imm_o Imediato decodificado e estendido para XLEN bits.
 * @param execution_alu_control_o Operacao selecionada para a ALU.
 * @param execution_branch_control_o Tipo de condicao ou salto para execucao.
 * @param execution_branch_enable_o Habilita a avaliacao de desvio na execucao.
 * @param execution_control_alu_a_o Seletor da entrada A da ALU.
 * @param execution_control_alu_b_o Seletor da entrada B da ALU.
 * @param search_pc_write_o Habilita a atualizacao do PC.
 * @param data_memory_mem_write_o Habilita a escrita na memoria de dados.
 * @param data_memory_mem_width_o Largura do acesso a memoria de dados.
 * @param data_memory_mem_signed_o Modo de extensao dos dados lidos da memoria.
 * @param register_file_written_enable_o Habilita a escrita no banco de registradores.
 * @param write_back_mem_to_reg_o Seleciona memoria ou ALU no write-back.
 */
module decoder
    import alu_pkg::*;
    import branch_pkg::*;
    import mem_pkg::*;
#(
    parameter int XLEN     = 32,
    parameter int REG_XLEN = 5
)(
    input  logic                 clk,
    input  logic [31:0]          instruction_i,
    input  logic [XLEN-1:0]      written_data_i,

    output logic [XLEN-1:0]      rs1_o,
    output logic [XLEN-1:0]      rs2_o,
    output logic [XLEN-1:0]      imm_o,

    output alu_op_t              execution_alu_control_o,
    output branch_op_t           execution_branch_control_o,
    output logic                 execution_branch_enable_o,
    output logic                 execution_control_alu_a_o,
    output logic [1:0]           execution_control_alu_b_o,
    output logic                 search_pc_write_o,
    output logic                 data_memory_mem_write_o,
    output mem_width_t           data_memory_mem_width_o,
    output mem_signed_t          data_memory_mem_signed_o,
    output logic                 register_file_written_enable_o,
    output logic                 write_back_mem_to_reg_o
);

    logic [REG_XLEN-1:0] rd;
    logic [REG_XLEN-1:0] rs1_add;
    logic [REG_XLEN-1:0] rs2_add;
    logic [31:0]         imm_rv32;

    // Campos de registrador da instrucao usados pelo banco de registradores.
    assign rd      = instruction_i[11:7];
    assign rs1_add = instruction_i[19:15];
    assign rs2_add = instruction_i[24:20];
    assign imm_o   = imm_rv32;

    register_file #(
        .XLEN(XLEN),
        .REG_XLEN(REG_XLEN)
    ) register_file_inst (
        .clk              (clk),
        .written_enable_i (register_file_written_enable_o),
        .written_data_i   (written_data_i),
        .written_add_i    (rd),
        .rs1_add_i        (rs1_add),
        .rs2_add_i        (rs2_add),
        .rs1_o            (rs1_o),
        .rs2_o            (rs2_o)
    );

    imm_gen imm_gen_inst (
        .instruction_i(instruction_i),
        .imm_o        (imm_rv32)
    );

    control_unit control_unit_inst (
        .instruction_i                  (instruction_i),
        .execution_alu_control_o        (execution_alu_control_o),
        .execution_branch_control_o     (execution_branch_control_o),
        .execution_branch_enable_o      (execution_branch_enable_o),
        .execution_control_alu_a_o      (execution_control_alu_a_o),
        .execution_control_alu_b_o      (execution_control_alu_b_o),
        .search_pc_write_o              (search_pc_write_o),
        .data_memory_mem_write_o        (data_memory_mem_write_o),
        .data_memory_mem_width_o        (data_memory_mem_width_o),
        .data_memory_mem_signed_o       (data_memory_mem_signed_o),
        .register_file_written_enable_o (register_file_written_enable_o),
        .write_back_mem_to_reg_o        (write_back_mem_to_reg_o)
    );

endmodule
