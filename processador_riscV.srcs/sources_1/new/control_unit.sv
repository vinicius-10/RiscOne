`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 20.10.2026 17:05:05
// Design Name: Processador RV32I
// Module Name: control_unit
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: Vivado 2025.2
// Description: Decodifica a instrucao RV32I e gera os sinais de controle do
//              datapath para execucao, acesso a memoria, write-back e PC.
//
// Dependencies: opcode_pkg, func3_pkg, func7_pkg, alu_pkg, branch_pkg, mem_pkg,
//               alu_decoder, main_decoder
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Unidade combinacional. Para opcodes nao suportados, mantem os valores
//   default e nao habilita escrita em registrador ou memoria.
//   Dividida em dois submodulos: alu_decoder (execution_alu_control_o) e
//   main_decoder (demais sinais de controle); aqui ficam apenas a extracao
//   de opcode/funct3/funct7 e as duas instancias.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file control_unit.sv
 * @brief Unidade de controle combinacional do processador RV32I.
 *
 * Decodifica opcode, funct3 e funct7 de uma instrucao completa de 32 bits e
 * produz os sinais que controlam a ALU, os desvios, os acessos a memoria,
 * a selecao do valor de write-back e a atualizacao do PC.
 *
 * Instrucoes implementadas: operacoes registrador-registrador e imediatas,
 * loads (LB, LH, LW, LBU e LHU), stores (SB, SH e SW), branches (BEQ, BNE,
 * BLT, BGE, BLTU e BGEU), LUI, AUIPC, JAL e JALR. Opcodes nao suportados
 * recebem os valores default definidos nos submodulos.
 *
 * Submodulos: `alu_decoder` gera `execution_alu_control_o`; `main_decoder`
 * gera todos os demais sinais (inclusive as checagens de funct3/funct7
 * invalidos que zeram os enables).
 *
 * A selecao de `execution_branch_control_o` considera o comportamento da etapa de
 * execucao: OP_BCT aceita quando o bit de condicao da ALU e 1; OP_BCF aceita
 * quando esse bit e 0. A ALU fornece igualdade para BEQ/BNE e comparacao
 * assinada ou nao assinada para os demais branches relacionais.
 *
 * @param instruction_i Instrucao RV32I completa de 32 bits a ser decodificada.
 * @retval execution_alu_control_o Operacao da ALU, conforme `alu_op_t` de `alu_pkg`.
 * @retval execution_branch_control_o Condicao/origem do desvio, conforme `branch_op_t`.
 * @retval execution_branch_enable_o Habilita a avaliacao do desvio na etapa de execucao.
 * @retval execution_control_alu_a_o Seleciona rs1 (0) ou PC (1) na entrada A da ALU.
 * @retval execution_control_alu_b_o Seleciona rs2 (00), imediato (01) ou PC+4 (10).
 * @retval search_pc_write_o Habilita a atualizacao do PC; permanece ativo nesta unidade.
 * @retval data_memory_mem_write_o Habilita a escrita na memoria de dados.
 * @retval data_memory_mem_width_o Largura do acesso a memoria: byte, halfword ou word.
 * @retval data_memory_mem_signed_o Define extensao com sinal ou sem sinal para loads.
 * @retval register_file_written_enable_o Habilita a escrita do resultado no registrador destino.
 * @retval write_back_mem_to_reg_o Seleciona dado da memoria (1) ou resultado da ALU (0).
 */
module control_unit
    import opcode_pkg::*;
    import func3_pkg::*;
    import func7_pkg::*;
    import alu_pkg::*;
    import branch_pkg::*;
    import mem_pkg::*;
(
    input  logic [31:0] instruction_i,

    output alu_op_t     execution_alu_control_o,
    output branch_op_t  execution_branch_control_o,
    output logic        execution_branch_enable_o,
    output logic        execution_control_alu_a_o,
    output logic [1:0]  execution_control_alu_b_o,
    output logic        search_pc_write_o,
    output logic        data_memory_mem_write_o,
    output mem_width_t  data_memory_mem_width_o,
    output mem_signed_t data_memory_mem_signed_o,
    output logic        register_file_written_enable_o,
    output logic        write_back_mem_to_reg_o
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instruction_i[6:0];
    assign funct3 = instruction_i[14:12];
    assign funct7 = instruction_i[31:25];

    // Divisao classica: decodificador da operacao da ALU e decodificador
    // principal (todos os demais sinais de controle).
    alu_decoder alu_decoder_inst (
        .opcode_i               (opcode),
        .funct3_i               (funct3),
        .funct7_i               (funct7),
        .execution_alu_control_o(execution_alu_control_o)
    );

    main_decoder main_decoder_inst (
        .opcode_i                      (opcode),
        .funct3_i                      (funct3),
        .funct7_i                      (funct7),
        .execution_branch_control_o    (execution_branch_control_o),
        .execution_branch_enable_o     (execution_branch_enable_o),
        .execution_control_alu_a_o     (execution_control_alu_a_o),
        .execution_control_alu_b_o     (execution_control_alu_b_o),
        .search_pc_write_o             (search_pc_write_o),
        .data_memory_mem_write_o       (data_memory_mem_write_o),
        .data_memory_mem_width_o       (data_memory_mem_width_o),
        .data_memory_mem_signed_o      (data_memory_mem_signed_o),
        .register_file_written_enable_o(register_file_written_enable_o),
        .write_back_mem_to_reg_o       (write_back_mem_to_reg_o)
    );

endmodule
