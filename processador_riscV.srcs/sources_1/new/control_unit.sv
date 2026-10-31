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
// Dependencies: opcode_pkg, func3_pkg, func7_pkg, alu_pkg, branch_pkg, mem_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Unidade combinacional. Para opcodes nao suportados, mantem os valores
//   default e nao habilita escrita em registrador ou memoria.
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
 * recebem os valores default definidos no bloco combinacional.
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

    always_comb begin
        // Estado seguro/default: PC avanca, sem efeitos colaterais.
        execution_alu_control_o   = OP_ADD;
        execution_branch_control_o = OP_BCT;
        execution_branch_enable_o = 1'b0;
        execution_control_alu_a_o = 1'b0;       // rs1
        execution_control_alu_b_o = 2'b00;      // rs2
        search_pc_write_o      = 1'b1;
        data_memory_mem_write_o     = 1'b0;
        data_memory_mem_width_o     = MEM_WIDTH_WORD;
        // Default sem extensao de sinal; apenas loads sobrescrevem este controle.
        data_memory_mem_signed_o    = MEM_UNSIGNED;
        register_file_written_enable_o = 1'b0;
        write_back_mem_to_reg_o    = 1'b0;       // resultado da ALU

        case (opcode)
            OPCODE_OP: begin
                // Decodificacao estrita: apenas funct7 = 0000000 (todas as
                // operacoes) ou 0100000 (SUB/SRA) sao validos no RV32I. Outros
                // valores (ex.: extensao M, funct7 = 0000001) viram NOP.
                register_file_written_enable_o = 1'b1;
                if (funct7 == F7_ZERO) begin
                    case (funct3)
                        F3_ADD:  execution_alu_control_o = OP_ADD;
                        F3_SLL:  execution_alu_control_o = OP_SLL;
                        F3_SLT:  execution_alu_control_o = OP_SLT;
                        F3_SLTU: execution_alu_control_o = OP_SLTU;
                        F3_XOR:  execution_alu_control_o = OP_XOR;
                        F3_SRL:  execution_alu_control_o = OP_SRL;
                        F3_OR:   execution_alu_control_o = OP_OR;
                        F3_AND:  execution_alu_control_o = OP_AND;
                        default: register_file_written_enable_o = 1'b0;
                    endcase
                end else if (funct7 == F7_ALT) begin
                    case (funct3)
                        F3_SUB:  execution_alu_control_o = OP_SUB;
                        F3_SRA:  execution_alu_control_o = OP_SRA;
                        default: register_file_written_enable_o = 1'b0;
                    endcase
                end else begin
                    register_file_written_enable_o = 1'b0;
                end
            end

            OPCODE_OP_IMM: begin
                register_file_written_enable_o = 1'b1;
                execution_control_alu_b_o = 2'b01; // imediato
                case (funct3)
                    F3_ADDI: execution_alu_control_o = OP_ADD;
                    F3_SLTI: execution_alu_control_o = OP_SLT;
                    F3_SLTIU: execution_alu_control_o = OP_SLTU;
                    F3_XORI: execution_alu_control_o = OP_XOR;
                    F3_ORI: execution_alu_control_o = OP_OR;
                    F3_ANDI: execution_alu_control_o = OP_AND;
                    // Shifts com imediato: imm[11:5] precisa ser 0000000
                    // (SLLI/SRLI) ou 0100000 (SRAI); outros valores viram NOP.
                    F3_SLLI: begin
                        if (funct7 == F7_SLLI) execution_alu_control_o = OP_SLL;
                        else                   register_file_written_enable_o = 1'b0;
                    end
                    F3_SRLI: begin
                        if      (funct7 == F7_SRLI) execution_alu_control_o = OP_SRL;
                        else if (funct7 == F7_SRAI) execution_alu_control_o = OP_SRA;
                        else                        register_file_written_enable_o = 1'b0;
                    end
                    default: register_file_written_enable_o = 1'b0;
                endcase
            end

            OPCODE_LOAD: begin
                execution_alu_control_o = OP_ADD;
                execution_control_alu_b_o = 2'b01; // rs1 + imediato
                register_file_written_enable_o = 1'b1;
                write_back_mem_to_reg_o = 1'b1;
                case (funct3)
                    F3_LB:  begin data_memory_mem_width_o = MEM_WIDTH_BYTE; data_memory_mem_signed_o = MEM_SIGNED; end
                    F3_LH:  begin data_memory_mem_width_o = MEM_WIDTH_HALF; data_memory_mem_signed_o = MEM_SIGNED; end
                    F3_LW:  begin data_memory_mem_width_o = MEM_WIDTH_WORD; data_memory_mem_signed_o = MEM_SIGNED; end
                    F3_LBU: begin data_memory_mem_width_o = MEM_WIDTH_BYTE; data_memory_mem_signed_o = MEM_UNSIGNED; end
                    F3_LHU: begin data_memory_mem_width_o = MEM_WIDTH_HALF; data_memory_mem_signed_o = MEM_UNSIGNED; end
                    default: begin register_file_written_enable_o = 1'b0; end
                endcase
            end

            OPCODE_STORE: begin
                execution_alu_control_o = OP_ADD;
                execution_control_alu_b_o = 2'b01; // rs1 + imediato
                data_memory_mem_write_o = 1'b1;
                case (funct3)
                    F3_SB: data_memory_mem_width_o = MEM_WIDTH_BYTE;
                    F3_SH: data_memory_mem_width_o = MEM_WIDTH_HALF;
                    F3_SW: data_memory_mem_width_o = MEM_WIDTH_WORD;
                    default: data_memory_mem_write_o = 1'b0;
                endcase
            end

            OPCODE_BRANCH: begin
                execution_branch_enable_o = 1'b1;
                case (funct3)
                    F3_BEQ: begin execution_alu_control_o = OP_CMP;  execution_branch_control_o = OP_BCT; end
                    F3_BNE: begin execution_alu_control_o = OP_CMP;  execution_branch_control_o = OP_BCF; end
                    F3_BLT: begin execution_alu_control_o = OP_SLT;  execution_branch_control_o = OP_BCT; end
                    F3_BGE: begin execution_alu_control_o = OP_SLT;  execution_branch_control_o = OP_BCF; end
                    F3_BLTU: begin execution_alu_control_o = OP_SLTU; execution_branch_control_o = OP_BCT; end
                    F3_BGEU: begin execution_alu_control_o = OP_SLTU; execution_branch_control_o = OP_BCF; end
                    default: execution_branch_enable_o = 1'b0;
                endcase
            end

            OPCODE_LUI: begin
                execution_alu_control_o = OP_PASS_B;
                execution_control_alu_b_o = 2'b01; // imediato U
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_AUIPC: begin
                execution_alu_control_o = OP_ADD;
                execution_control_alu_a_o = 1'b1; // PC
                execution_control_alu_b_o = 2'b01; // imediato U
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_JAL: begin
                execution_alu_control_o = OP_PASS_B;
                execution_control_alu_b_o = 2'b10; // PC + 4 para write-back
                execution_branch_enable_o = 1'b1;
                execution_branch_control_o = OP_BIP;
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_JALR: begin
                // JALR so e valido com funct3 = 000; caso contrario vira NOP.
                if (funct3 == F3_JALR) begin
                    execution_alu_control_o = OP_PASS_B;
                    execution_control_alu_b_o = 2'b10; // PC + 4 para write-back
                    execution_branch_enable_o = 1'b1;
                    execution_branch_control_o = OP_BIR;
                    register_file_written_enable_o = 1'b1;
                end
            end

            default: begin
                // OPCODEs nao suportados mantem os controles default.
            end
        endcase
    end

endmodule
