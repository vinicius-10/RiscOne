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
//   O sinal reset_i é encaminhado ao módulo search, que zera o PC de forma
//   síncrona e faz a memória de instruções registrar a palavra 0. As memorias
//   sao inicializadas pelos arquivos configurados nos
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
 * A interface externa contem clock, reset e as quatro entradas e quatro
 * saidas genericas de E/S (MMIO) de 32 bits; o significado de cada uma na
 * placa e definido no top_core. Os sinais de PC, instrucao e resultados
 * permanecem internos ao modulo. O banco de
 * registradores não possui reset; `reset_i` reinicia somente o PC (e a
 * instrução registrada, que volta à palavra 0) por meio do módulo `search`.
 *
 * @param XLEN Largura dos dados e enderecos. Padrao: 32 bits.
 * @param INSTR_MEM_DEPTH Número de palavras da memória de instruções. Padrão:
 *                        1024 (4 KiB).
 * @param DATA_MEM_DEPTH Número de palavras da RAM de dados. Padrão: 256 (1 KiB,
 *                       endereços 0x000..0x3FF). Menor que a memória de
 *                       instruções para encurtar o caminho do load.
 * @param INSTR_MEM_FILE Arquivo hexadecimal de inicializacao da memoria de
 *                       instrucoes. Padrao: `program_bytes.mem`.
 * @param DATA_MEM_FILE Arquivo hexadecimal de inicializacao da memoria de
 *                      dados. Padrao: `data.mem`.
 * @param clk Clock do processador; PC, instrução registrada, escritas no banco
 *            de registradores e escritas na memória de dados são atualizados
 *            na borda de subida.
 * @param reset_i Reset sincrono ativo em nivel alto para zerar o PC.
 * @param io_in0_i..io_in3_i Entradas genericas, lidas em 0x4000_0010 + 4k.
 * @retval io_out0_o..io_out3_o Saidas genericas, somente escrita, em
 *                              0x4000_0000 + 4k (a leitura devolve 0).
 */
module core #(
    parameter int XLEN = 32,
    parameter int INSTR_MEM_DEPTH = 1024,
    parameter int DATA_MEM_DEPTH = 256,
    parameter string INSTR_MEM_FILE = "program_bytes.mem",
    parameter string DATA_MEM_FILE = "data.mem"
)(
    input logic clk,
    input logic reset_i,
    input logic [31:0] io_in0_i,
    input logic [31:0] io_in1_i,
    input logic [31:0] io_in2_i,
    input logic [31:0] io_in3_i,
    output logic [31:0] io_out0_o,
    output logic [31:0] io_out1_o,
    output logic [31:0] io_out2_o,
    output logic [31:0] io_out3_o
);


    import alu_pkg::*;
    import branch_pkg::*;
    import mem_pkg::*;

    logic [XLEN-1:0] pc;
    logic [XLEN-1:0] pc_next;
    logic [XLEN-1:0] pc_branch;
    logic [31:0]     instruction;
    logic [XLEN-1:0] rs1_data;
    logic [XLEN-1:0] rs2_data;
    logic [XLEN-1:0] immediate;
    logic [XLEN-1:0] data_memory_data;
    logic [XLEN-1:0] alu_result;
    logic [XLEN-1:0] data_memory_addr;
    logic            data_memory_addr_io;     // endereco no MMIO (sem esperar o somador)
    logic            data_memory_addr_page0;  // endereco nos primeiros 4 KiB (idem)
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
        .MEM_DEPTH(INSTR_MEM_DEPTH),
        .MEM_FILE(INSTR_MEM_FILE)
    ) search_inst (
        .clk         (clk),
        .reset_i     (reset_i),
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
        .branch_taken_o  (branch_taken),
        .mem_addr_o      (data_memory_addr),
        .mem_io_o        (data_memory_addr_io),
        .mem_page0_o     (data_memory_addr_page0)
    );

    data_memory #(
        .XLEN(XLEN),
        .MEM_DEPTH(DATA_MEM_DEPTH),
        .MEM_FILE(DATA_MEM_FILE)
    ) data_memory_inst (
        .clk         (clk),
        .mem_write_i (data_memory_write_enable),
        .mem_width_i (data_memory_width),
        .mem_signed_i(data_memory_signed),
        .addr_i      (data_memory_addr),
        .addr_io_i   (data_memory_addr_io),
        .addr_page0_i(data_memory_addr_page0),
        .data_i      (rs2_data),
        .data_o      (data_memory_data),
        .io_in0_i    (io_in0_i),
        .io_in1_i    (io_in1_i),
        .io_in2_i    (io_in2_i),
        .io_in3_i    (io_in3_i),
        .io_out0_o   (io_out0_o),
        .io_out1_o   (io_out1_o),
        .io_out2_o   (io_out2_o),
        .io_out3_o   (io_out3_o)
    );

    write_back #(.XLEN(XLEN)) write_back_inst (
        .alu_result_i(alu_result),
        .mem_data_i  (data_memory_data),
        .mem_to_reg_i(mem_to_reg),
        .wb_data_o   (write_back_data)
    );

endmodule
