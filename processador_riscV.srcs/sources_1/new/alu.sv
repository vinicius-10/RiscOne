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
// Description: Ula para realizar todos as intru?oes do conjunto rv32i
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
 * @brief Unidade L?gica e Aritm?tica (ALU) do processador RV32I.
 *
 * Esta unidade executa opera??es aritm?ticas, l?gicas, compara??es e
 * deslocamentos sobre dois operandos de entrada. O resultado ? selecionado
 * conforme o c?digo de opera??o `alu_op_i` e pode ser usado diretamente pelo
 * datapath do processador.
 *
 * Opera??es suportadas:
 * - aritm?tica: soma, subtra??o;
 * - l?gica: AND, OR, XOR;
 * - compara??o: SLT, SLTU, CMP;
 * - deslocamento: SLL, SRL, SRA;
 * - passagem: PASS_B.
 *
 * @param XLEN Largura dos operandos e do resultado da ALU. Valor padr?o: 32 bits.
 * @param a_i Operando A de entrada.
 * @param b_i Operando B de entrada.
 * @param alu_op_i C?digo da opera??o a ser executada.
 * @retval alu_o Resultado da opera??o selecionada.
 * @retval zero_o Sinal de indica??o de resultado nulo ou igualdade, com base no bit menos significativo do resultado.
 */
module alu import alu_pkg::*; #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] a_i,
    input  logic [XLEN-1:0] b_i,
    input  alu_op_t         alu_op_i,
    output logic [XLEN-1:0] alu_o,
    output logic            zero_o
);



    // --------------------------------------------------------
    // 1. Bloco Aritm?tico e Compara??es (Compartilhamento CARRY4)
    // --------------------------------------------------------
    logic            is_sub;
    logic [XLEN-1:0] b_mux;
    logic [XLEN:0]   add_sub_res; 

    // OP_CMP inclu?do aqui para for?ar a subtra??o (a - b)
    assign is_sub = (alu_op_i == OP_SUB)  | 
                    (alu_op_i == OP_SLT)  | 
                    (alu_op_i == OP_SLTU) | 
                    (alu_op_i == OP_CMP);
    
    assign b_mux  = is_sub ? ~b_i : b_i;
    assign add_sub_res = a_i + b_mux + is_sub;

    logic cmp_slt, cmp_sltu, cmp_eq;
    
    assign cmp_sltu = ~add_sub_res[XLEN]; 
    assign cmp_slt  = (a_i[XLEN-1] != b_i[XLEN-1]) ? a_i[XLEN-1] : add_sub_res[XLEN-1];
    
    // Nova L?gica: Se o resultado da subtra??o for 0, os operandos s?o iguais
    assign cmp_eq   = (add_sub_res[XLEN-1:0] == '0);

    logic [XLEN-1:0] res_arith;
    assign res_arith = (alu_op_i == OP_SLT)  ? {{(XLEN-1){1'b0}}, cmp_slt}  :
                       (alu_op_i == OP_SLTU) ? {{(XLEN-1){1'b0}}, cmp_sltu} :
                       (alu_op_i == OP_CMP)  ? {{(XLEN-1){1'b0}}, cmp_eq}   :
                       add_sub_res[XLEN-1:0];

    // --------------------------------------------------------
    // 2. Bloco L?gico
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
            // OP_CMP adicionado ao mux aritm?tico
            OP_ADD, OP_SUB, OP_SLT, OP_SLTU, OP_CMP: alu_o = res_arith;
            OP_AND, OP_OR, OP_XOR, OP_PASS_B:        alu_o = res_logic;
            OP_SLL, OP_SRL, OP_SRA:                  alu_o = res_shift;
            default:                                 alu_o = '0;
        endcase
    end

    // --------------------------------------------------------
    // Nova Flag: reflete o LSB (Bit 0) da sa?da
    // --------------------------------------------------------
    assign zero_o = alu_o[0];

endmodule

