`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador RV32I
// Module Name: alu_decoder
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: Vivado 2025.2
// Description: Decodificador da operacao da ALU, parte da control_unit.
//
// Dependencies: opcode_pkg, func3_pkg, func7_pkg, alu_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Unidade combinacional. Contem apenas as atribuicoes de
//   execution_alu_control_o do case original da control_unit; os demais
//   sinais de controle ficam no main_decoder.
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file alu_decoder.sv
 * @brief Decodificador da operacao da ALU (submodulo da control_unit).
 *
 * Mesma estrutura de case da control_unit original, mantendo somente as
 * atribuicoes de `execution_alu_control_o`. Ramos que so controlavam outros
 * sinais ficam vazios, de modo que a saida e identica a original para toda
 * instrucao de 32 bits (inclusive encodings invalidos, que mantem OP_ADD ou o
 * valor atribuido antes da checagem).
 *
 * @param opcode_i Campo opcode da instrucao (instruction[6:0]).
 * @param funct3_i Campo funct3 da instrucao (instruction[14:12]).
 * @param funct7_i Campo funct7 da instrucao (instruction[31:25]).
 * @retval execution_alu_control_o Operacao da ALU, conforme `alu_op_t` de `alu_pkg`.
 */
module alu_decoder
    import opcode_pkg::*;
    import func3_pkg::*;
    import func7_pkg::*;
    import alu_pkg::*;
(
    input  logic [6:0] opcode_i,
    input  logic [2:0] funct3_i,
    input  logic [6:0] funct7_i,

    output alu_op_t    execution_alu_control_o
);

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = opcode_i;
    assign funct3 = funct3_i;
    assign funct7 = funct7_i;

    always_comb begin
        // Estado seguro/default.
        execution_alu_control_o   = OP_ADD;

        case (opcode)
            OPCODE_OP: begin
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
                        default: begin end
                    endcase
                end else if (funct7 == F7_ALT) begin
                    case (funct3)
                        F3_SUB:  execution_alu_control_o = OP_SUB;
                        F3_SRA:  execution_alu_control_o = OP_SRA;
                        default: begin end
                    endcase
                end else begin
                end
            end

            OPCODE_OP_IMM: begin
                case (funct3)
                    F3_ADDI: execution_alu_control_o = OP_ADD;
                    F3_SLTI: execution_alu_control_o = OP_SLT;
                    F3_SLTIU: execution_alu_control_o = OP_SLTU;
                    F3_XORI: execution_alu_control_o = OP_XOR;
                    F3_ORI: execution_alu_control_o = OP_OR;
                    F3_ANDI: execution_alu_control_o = OP_AND;
                    F3_SLLI: begin
                        if (funct7 == F7_SLLI) execution_alu_control_o = OP_SLL;
                        else                   begin end
                    end
                    F3_SRLI: begin
                        if      (funct7 == F7_SRLI) execution_alu_control_o = OP_SRL;
                        else if (funct7 == F7_SRAI) execution_alu_control_o = OP_SRA;
                        else                        begin end
                    end
                    default: begin end
                endcase
            end

            OPCODE_LOAD: begin
                execution_alu_control_o = OP_ADD;
            end

            OPCODE_STORE: begin
                execution_alu_control_o = OP_ADD;
            end

            OPCODE_BRANCH: begin
                case (funct3)
                    F3_BEQ: begin execution_alu_control_o = OP_CMP;  end
                    F3_BNE: begin execution_alu_control_o = OP_CMP;  end
                    F3_BLT: begin execution_alu_control_o = OP_SLT;  end
                    F3_BGE: begin execution_alu_control_o = OP_SLT;  end
                    F3_BLTU: begin execution_alu_control_o = OP_SLTU; end
                    F3_BGEU: begin execution_alu_control_o = OP_SLTU; end
                    default: begin end
                endcase
            end

            OPCODE_LUI: begin
                execution_alu_control_o = OP_PASS_B;
            end

            OPCODE_AUIPC: begin
                execution_alu_control_o = OP_ADD;
            end

            OPCODE_JAL: begin
                execution_alu_control_o = OP_PASS_B;
            end

            OPCODE_JALR: begin
                // JALR so e valido com funct3 = 000.
                if (funct3 == F3_JALR) begin
                    execution_alu_control_o = OP_PASS_B;
                end
            end

            default: begin
                // OPCODEs nao suportados mantem os controles default.
            end
        endcase
    end

endmodule
