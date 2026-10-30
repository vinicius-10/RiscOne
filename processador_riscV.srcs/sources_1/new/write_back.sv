`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 07.10.2026 11:17:20
// Design Name: Processador RV32I
// Module Name: write_back
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Seleciona o dado que sera escrito no banco de registradores.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   A selecao e combinacional: mem_to_reg_i = 0 escolhe a ALU e 1 escolhe a
//   memoria de dados. O valor PC+4 pode ser encaminhado pela ALU.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file write_back.sv
 * @brief Multiplexador combinacional da etapa de write-back do RV32I.
 *
 * Seleciona entre o resultado da ALU e o dado lido da memoria de dados. A
 * escolha e controlada por `mem_to_reg_i` e o valor selecionado e encaminhado
 * ao banco de registradores. A operacao da ALU pode incluir PASS_B para
 * encaminhar o imediato ou PC+4, conforme os sinais da unidade de controle.
 *
 * @param XLEN Largura dos dados de entrada e saida. Valor padrao: 32 bits.
 * @param alu_result_i Resultado produzido pela unidade de execucao.
 * @param mem_data_i Dado lido da memoria de dados.
 * @param mem_to_reg_i Seletor: 0 = resultado da ALU; 1 = dado da memoria.
 * @retval wb_data_o Dado selecionado para escrita no banco de registradores.
 */
module write_back #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] alu_result_i,
    input  logic [XLEN-1:0] mem_data_i,
    input  logic            mem_to_reg_i,
    output logic [XLEN-1:0] wb_data_o
);

    always_comb begin
        case (mem_to_reg_i)
            1'b0:    wb_data_o = alu_result_i;
            1'b1:    wb_data_o = mem_data_i;
            default: wb_data_o = alu_result_i;
        endcase
    end

endmodule
