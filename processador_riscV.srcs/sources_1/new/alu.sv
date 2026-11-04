`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 16.09.2026 09:00:49
// Design Name: Processador rv32i
// Module Name: alu
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Ula para realizar todos as instruções do conjunto rv32i
// 
// Dependencies: alu_pkg
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file alu.sv
 * @brief Unidade Lógica e Aritmética (ALU) do processador RV32I.
 *
 * Esta unidade executa operações aritméticas, lógicas, comparações e
 * deslocamentos sobre dois operandos de entrada. O resultado é selecionado
 * conforme o código de operação `alu_op_i` e pode ser usado diretamente pelo
 * datapath do processador.
 *
 * Operações suportadas:
 * - aritmética: soma, subtração;
 * - lógica: AND, OR, XOR;
 * - comparação: SLT, SLTU, CMP;
 * - deslocamento: SLL, SRL, SRA;
 * - passagem: PASS_B.
 *
 * @param XLEN Largura dos operandos e do resultado da ALU. Valor padrão: 32 bits.
 * @param a_i Operando A de entrada.
 * @param b_i Operando B de entrada.
 * @param alu_op_i Código da operação a ser executada.
 * @retval alu_o Resultado da operação selecionada.
 * @retval alu_lsb_o Bit 0 (LSB) do resultado `alu_o`. Em CMP/SLT/SLTU o resultado e 0 ou 1, entao este bit e a condicao usada pelos branches.
 */
module alu import alu_pkg::*; #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] a_i,
    input  logic [XLEN-1:0] b_i,
    input  alu_op_t         alu_op_i,
    output logic [XLEN-1:0] alu_o,
    output logic            alu_lsb_o
);



    // --------------------------------------------------------
    // 1. Bloco Aritmético e Comparações (Compartilhamento CARRY4)
    // --------------------------------------------------------
    logic            is_sub;
    logic [XLEN-1:0] b_mux;
    logic [XLEN:0]   add_sub_res; 

    assign is_sub = (alu_op_i == OP_SUB)  |
                    (alu_op_i == OP_SLT)  |
                    (alu_op_i == OP_SLTU);
    
    assign b_mux  = is_sub ? ~b_i : b_i;
    assign add_sub_res = a_i + b_mux + is_sub;

    logic cmp_slt, cmp_sltu, cmp_eq;
    
    assign cmp_sltu = ~add_sub_res[XLEN]; 
    assign cmp_slt  = (a_i[XLEN-1] != b_i[XLEN-1]) ? a_i[XLEN-1] : add_sub_res[XLEN-1];
    
    // Igualdade direta (XOR + redução): não espera a cadeia de carry do somador.
    assign cmp_eq   = (a_i == b_i);

    logic [XLEN-1:0] res_arith;
    assign res_arith = (alu_op_i == OP_SLT)  ? {{(XLEN-1){1'b0}}, cmp_slt}  :
                       (alu_op_i == OP_SLTU) ? {{(XLEN-1){1'b0}}, cmp_sltu} :
                       (alu_op_i == OP_CMP)  ? {{(XLEN-1){1'b0}}, cmp_eq}   :
                       add_sub_res[XLEN-1:0];

    // --------------------------------------------------------
    // 2. Bloco Lógico
    // --------------------------------------------------------
    logic [XLEN-1:0] res_logic;
    always_comb begin
        case (alu_op_i)
            OP_AND:  res_logic = a_i & b_i;
            OP_OR:   res_logic = a_i | b_i;
            OP_XOR:  res_logic = a_i ^ b_i;
            default: res_logic = b_i;
        endcase
    end

    // --------------------------------------------------------
    // 3. Bloco de Deslocamento (Barrel Shifter)
    // --------------------------------------------------------
    logic [XLEN-1:0] res_shift;
    always_comb begin
        case (alu_op_i)
            OP_SLL:  res_shift = a_i << b_i[4:0];
            OP_SRL:  res_shift = a_i >> b_i[4:0];
            OP_SRA:  res_shift = $signed(a_i) >>> b_i[4:0];
            default: res_shift = '0;
        endcase
    end

    // --------------------------------------------------------
    // 4. Multiplexador Final
    // --------------------------------------------------------
    always_comb begin
        case (alu_op_i)
            // OP_CMP adicionado ao mux aritmético
            OP_ADD, OP_SUB, OP_SLT, OP_SLTU, OP_CMP: alu_o = res_arith;
            OP_AND, OP_OR, OP_XOR, OP_PASS_B:        alu_o = res_logic;
            OP_SLL, OP_SRL, OP_SRA:                  alu_o = res_shift;
            default:                                 alu_o = '0;
        endcase
    end

    // --------------------------------------------------------
    // Flag alu_lsb_o: reflete o LSB (Bit 0) da saída
    // --------------------------------------------------------
    assign alu_lsb_o = alu_o[0];

endmodule

