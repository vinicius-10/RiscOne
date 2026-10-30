`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 26.10.2026
// Design Name: Processador RV32I
// Module Name: core
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Integra os modulos do datapath monociclo RV32I.
//
// Dependencies: search, decoder, execution, data_memory, write_back,
//               alu_pkg, branch_pkg, mem_pkg
//
// Revision:
// Revision 0.02 - Integracao dos modulos do processador
// Additional Comments:
//   O sinal reset_i e encaminhado ao modulo search, que zera o PC de forma
//   sincrona. As memorias sao inicializadas pelos arquivos configurados nos
//   parametros INSTR_MEM_FILE e DATA_MEM_FILE.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file core.sv
 * @brief Modulo de integracao do processador monociclo RV32I.
 *
 * Conecta os blocos de busca, decodificacao, execucao, memoria de dados e
 * write-back para formar um processador RV32I monociclo. O PC e mantido pelo
 * modulo `search`; a instrucao buscada e decodificada, seus operandos passam
 * pela unidade de execucao e o resultado da ALU pode acessar a memoria de
 * dados. O bloco `write_back` seleciona o resultado da ALU ou o dado lido da
 * memoria para retornar ao banco de registradores. Desvios tomados encaminham
 * o endereco calculado pela unidade de execucao ao PC.
 *
 * A interface externa contem somente clock e reset. Os sinais de PC,
 * instrucao e resultados permanecem internos ao modulo. O banco de
 * registradores nao possui reset; `reset_i` reinicia somente o PC por meio do
 * modulo `search`.
 *
 * @param XLEN Largura dos dados e enderecos. Padrao: 32 bits.
 * @param MEM_DEPTH Numero de palavras na memoria de instrucoes e na memoria de
 *                  dados. Padrao: 1024.
 * @param INSTR_MEM_FILE Arquivo hexadecimal de inicializacao da memoria de
 *                       instrucoes. Padrao: `program_bytes.hex`.
 * @param DATA_MEM_FILE Arquivo hexadecimal de inicializacao da memoria de
 *                      dados. Padrao: `data.hex`.
 * @param clk Clock do processador; PC, escritas no banco de registradores e
 *            escritas na memoria de dados sao atualizados na borda de subida.
 * @param reset_i Reset sincrono ativo em nivel alto para zerar o PC.
 */
module core #(
    parameter int XLEN = 32,
    parameter int MEM_DEPTH = 1024,
    parameter string INSTR_MEM_FILE = "program_bytes.mem",
    parameter string DATA_MEM_FILE = "data.mem"
)(
    input logic clk,
    input logic CPU_RESETN,
    input logic [15:0] switch_i,
    input logic [4:0] button_i,
    input logic [3:0] pmod_row_i,
    output logic [15:0] led_o,
    output logic [15:0] seg7_o,
    output logic [3:0] pmod_col_o
);


    import alu_pkg::*;
    import branch_pkg::*;
    import mem_pkg::*;
    
    logic reset_i;
    // CPU_RESETN e ativo em nivel baixo; search espera reset ativo em nivel alto.
    assign reset_i = ~CPU_RESETN;

    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] pc_next;
    logic [XLEN-1:0] pc_branch;
    logic [31:0]     instruction;
    logic [XLEN-1:0] rs1_data;
    logic [XLEN-1:0] rs2_data;
    logic [XLEN-1:0] immediate;
    logic [XLEN-1:0] data_memory_data;
    logic [XLEN-1:0] alu_result;
    logic [XLEN-1:0] write_back_data;
    logic            pc_write_enable;
    logic            branch_taken;
    logic            branch_enable;
    logic            alu_a_select;
    logic [1:0]      alu_b_select;
    logic            data_memory_write_enable;
    logic            register_write_enable;
    logic            mem_to_reg;
    alu_op_t         alu_control;
    branch_op_t      branch_control;
    mem_width_t      data_memory_width;
    mem_signed_t     data_memory_signed;

    search #(
        .XLEN(XLEN),
        .MEM_DEPTH(MEM_DEPTH),
        .MEM_FILE(INSTR_MEM_FILE)
    ) search_inst (
        .clk         (clk),
        .rest_i      (reset_i),
        .pc_write_i  (pc_write_enable),
        .pc_branch_i (branch_taken),
        .new_pc_i    (pc_branch),
        .instr_o     (instruction),
        .pc_o        (pc),
        .pc_next     (pc_next)
    );

    decoder #(.XLEN(XLEN)) decoder_inst (
        .clk                              (clk),
        .instruction_i                    (instruction),
        .written_data_i                   (write_back_data),
        .rs1_o                            (rs1_data),
        .rs2_o                            (rs2_data),
        .imm_o                            (immediate),
        .execution_alu_control_o          (alu_control),
        .execution_branch_control_o       (branch_control),
        .execution_branch_enable_o        (branch_enable),
        .execution_control_alu_a_o        (alu_a_select),
        .execution_control_alu_b_o        (alu_b_select),
        .search_pc_write_o                (pc_write_enable),
        .data_memory_mem_write_o          (data_memory_write_enable),
        .data_memory_mem_width_o          (data_memory_width),
        .data_memory_mem_signed_o         (data_memory_signed),
        .register_file_written_enable_o   (register_write_enable),
        .write_back_mem_to_reg_o          (mem_to_reg)
    );

    execution #(.XLEN(XLEN)) execution_inst (
        .pc_next_i       (pc_next),
        .pc_i            (pc),
        .imm_i           (immediate),
        .reg_data1_i     (rs1_data),
        .reg_data2_i     (rs2_data),
        .alu_control_i   (alu_control),
        .branch_control_i(branch_control),
        .branch_enable_i (branch_enable),
        .control_alu_a   (alu_a_select),
        .control_alu_b   (alu_b_select),
        .pc_branch_o     (pc_branch),
        .alu_result_o    (alu_result),
        .branch_taken_o  (branch_taken)
    );

    data_memory #(
        .XLEN(XLEN),
        .MEM_DEPTH(MEM_DEPTH),
        .MEM_FILE(DATA_MEM_FILE)
    ) data_memory_inst (
        .clk         (clk),
        .mem_write_i (data_memory_write_enable),
        .mem_width_i (data_memory_width),
        .mem_signed_i(data_memory_signed),
        .addr_i      (alu_result),
        .data_i      (rs2_data),
        .data_o      (data_memory_data),
        .switch_i    (switch_i),
        .button_i    (button_i),
        .pmod_row_i  (pmod_row_i),
        .led_o       (led_o),
        .seg7_o      (seg7_o),
        .pmod_col_o  (pmod_col_o)
    );

    write_back #(.XLEN(XLEN)) write_back_inst (
        .alu_result_i(alu_result),
        .mem_data_i  (data_memory_data),
        .mem_to_reg_i(mem_to_reg),
        .wb_data_o   (write_back_data)
    );

endmodule
