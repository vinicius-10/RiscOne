`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 20.10.2026 10:20:30
// Design Name: Processador RV32I
// Module Name: imm_gen
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Gera e estende os imediatos dos formatos I, S, B, U e J do RV32I.
//
// Dependencies: opcode_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   A porta instuction_i mantém a grafia usada na interface atual do módulo.
//////////////////////////////////////////////////////////////////////////////////



/**
 * @file imm_gen.sv
 * @brief Gerador de imediatos para instruções RV32I.
 *
 * Decodifica o opcode e monta o imediato nos formatos I, S, B, U ou J,
 * incluindo extensão de sinal e os bits de alinhamento definidos pela ISA.
 *
 * @param instuction_i Instrução de 32 bits.
 * @retval imm_o Imediato de 32 bits decodificado e estendido.
 */
module imm_gen(
    input  logic [31:0] instruction_i,
    output logic [31:0] imm_o
);
    import opcode_pkg::*;

always_comb begin
        case (instruction_i[6:0])
            OPCODE_LOAD,
            OPCODE_OP_IMM,
            OPCODE_JALR:
                imm_o = {{20{instruction_i[31]}}, instruction_i[31:20]};

            OPCODE_STORE:
                imm_o = {{20{instruction_i[31]}},
                         instruction_i[31:25],
                         instruction_i[11:7]};

            OPCODE_BRANCH:
                imm_o = {{19{instruction_i[31]}},
                         instruction_i[31],
                         instruction_i[7],
                         instruction_i[30:25],
                         instruction_i[11:8],
                         1'b0};

            OPCODE_LUI,
            OPCODE_AUIPC:
                imm_o = {instruction_i[31:12], 12'b0};

            OPCODE_JAL:
                imm_o = {{11{instruction_i[31]}},
                         instruction_i[31],
                         instruction_i[19:12],
                         instruction_i[20],
                         instruction_i[30:21],
                         1'b0};

            default:
                imm_o = {{20{instruction_i[31]}}, instruction_i[31:20]};
        endcase
    end

endmodule

