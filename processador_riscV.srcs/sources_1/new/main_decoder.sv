`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador RV32I
// Module Name: main_decoder
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: Vivado 2025.2
// Description: Decodificador principal da control_unit: gera todos os sinais
//              de controle exceto a operacao da ALU.
//
// Dependencies: opcode_pkg, func3_pkg, func7_pkg, branch_pkg, mem_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Unidade combinacional. Para opcodes nao suportados, mantem os valores
//   default e nao habilita escrita em registrador ou memoria.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file main_decoder.sv
 * @brief Decodificador principal (submodulo da control_unit).
 *
 * Mesma estrutura de case da control_unit original, sem as atribuicoes de
 * `execution_alu_control_o` (que ficam no alu_decoder). Inclui as checagens de
 * funct3/funct7 invalidos que zeram os enables de escrita e de desvio. Ramos
 * que so controlavam a operacao da ALU ficam vazios.
 *
 * @param opcode_i Campo opcode da instrucao (instruction[6:0]).
 * @param funct3_i Campo funct3 da instrucao (instruction[14:12]).
 * @param funct7_i Campo funct7 da instrucao (instruction[31:25]).
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
module main_decoder
    import opcode_pkg::*;
    import func3_pkg::*;
    import func7_pkg::*;
    import branch_pkg::*;
    import mem_pkg::*;
(
    input  logic [6:0]  opcode_i,
    input  logic [2:0]  funct3_i,
    input  logic [6:0]  funct7_i,

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

    assign opcode = opcode_i;
    assign funct3 = funct3_i;
    assign funct7 = funct7_i;

    always_comb begin
        // Estado seguro/default: PC avanca, sem efeitos colaterais.
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
                        F3_ADD:  begin end
                        F3_SLL:  begin end
                        F3_SLT:  begin end
                        F3_SLTU: begin end
                        F3_XOR:  begin end
                        F3_SRL:  begin end
                        F3_OR:   begin end
                        F3_AND:  begin end
                        default: register_file_written_enable_o = 1'b0;
                    endcase
                end else if (funct7 == F7_ALT) begin
                    case (funct3)
                        F3_SUB:  begin end
                        F3_SRA:  begin end
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
                    F3_ADDI: begin end
                    F3_SLTI: begin end
                    F3_SLTIU: begin end
                    F3_XORI: begin end
                    F3_ORI: begin end
                    F3_ANDI: begin end
                    // Shifts com imediato: imm[11:5] precisa ser 0000000
                    // (SLLI/SRLI) ou 0100000 (SRAI); outros valores viram NOP.
                    F3_SLLI: begin
                        if (funct7 == F7_SLLI) begin end
                        else                   register_file_written_enable_o = 1'b0;
                    end
                    F3_SRLI: begin
                        if      (funct7 == F7_SRLI) begin end
                        else if (funct7 == F7_SRAI) begin end
                        else                        register_file_written_enable_o = 1'b0;
                    end
                    default: register_file_written_enable_o = 1'b0;
                endcase
            end

            OPCODE_LOAD: begin
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
                    F3_BEQ: begin execution_branch_control_o = OP_BCT; end
                    F3_BNE: begin execution_branch_control_o = OP_BCF; end
                    F3_BLT: begin execution_branch_control_o = OP_BCT; end
                    F3_BGE: begin execution_branch_control_o = OP_BCF; end
                    F3_BLTU: begin execution_branch_control_o = OP_BCT; end
                    F3_BGEU: begin execution_branch_control_o = OP_BCF; end
                    default: execution_branch_enable_o = 1'b0;
                endcase
            end

            OPCODE_LUI: begin
                execution_control_alu_b_o = 2'b01; // imediato U
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_AUIPC: begin
                execution_control_alu_a_o = 1'b1; // PC
                execution_control_alu_b_o = 2'b01; // imediato U
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_JAL: begin
                execution_control_alu_b_o = 2'b10; // PC + 4 para write-back
                execution_branch_enable_o = 1'b1;
                execution_branch_control_o = OP_BIP;
                register_file_written_enable_o = 1'b1;
            end

            OPCODE_JALR: begin
                // JALR so e valido com funct3 = 000; caso contrario vira NOP.
                // OP_BIR (base rs1 do alvo) nao olha o funct3: com funct3
                // invalido o enable fica 0 e o desvio nao acontece. Medido em
                // 21/11/2026: assim o core fecha 100 MHz nos dois fluxos.
                execution_branch_control_o = OP_BIR;
                if (funct3 == F3_JALR) begin
                    execution_control_alu_b_o = 2'b10; // PC + 4 para write-back
                    execution_branch_enable_o = 1'b1;
                    register_file_written_enable_o = 1'b1;
                end
            end

            default: begin
                // OPCODEs nao suportados mantem os controles default.
            end
        endcase
    end

endmodule
