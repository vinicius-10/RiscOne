`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026
// Design Name: Processador rv32i
// Module Name: next_pc
// Project Name:  processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Cálculo do próximo PC (PC + 4 e mux de seleção), usado pela search
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file next_pc.sv
 * @brief Cálculo combinacional do próximo PC do processador RV32I.
 *
 * Soma 4 ao PC atual (`pc_next_o`) e escolhe o próximo PC (`pc_sel_o`), que a
 * `search` registra no PC e usa para endereçar a memória de instruções.
 *
 * Próximo PC (`pc_sel_o`):
 * - reset_i = 1 => 0 (o PC zera e a instrução registrada passa a ser a palavra 0).
 * - pc_write_i = 0 => o PC atual.
 * - pc_write_i = 1 e pc_branch_i = 0 => PC + 4.
 * - pc_write_i = 1 e pc_branch_i = 1 => new_pc_i.
 *
 * @param XLEN Largura do endereço do PC. Valor padrão: 32.
 * @param reset_i Reset síncrono ativo em nível alto: força o próximo PC para 0.
 * @param pc_write_i Habilita a atualização do contador de programa; em 0, o PC é mantido.
 * @param pc_branch_i Sinal de controle do tipo de atualização do PC. 0 = incrementa; 1 = carrega new_pc_i.
 * @param new_pc_i Destino do desvio ou salto.
 * @param pc_i Valor atual do contador de programa.
 * @retval pc_sel_o Próximo PC (vai para o registrador do PC e para o endereço da ROM).
 * @retval pc_next_o Próximo PC sequencial (PC + 4).
 */

module next_pc #(
    parameter int XLEN = 32
)(
    input  logic              reset_i,     // Reset síncrono ativo em nível alto
    input  logic              pc_write_i,  // Enable para atualização do PC
    input  logic              pc_branch_i, // Seleção de desvio (1 = salto, 0 = PC+4)
    input  logic [XLEN-1:0]   new_pc_i,    // Endereço de destino do salto/branch
    input  logic [XLEN-1:0]   pc_i,        // PC atual
    output logic [XLEN-1:0]   pc_sel_o,    // Próximo PC
    output logic [XLEN-1:0]   pc_next_o    // Próximo PC sequencial (PC + 4)
);

    assign pc_next_o = pc_i + 32'd4;

    // Próximo PC. O reset entra aqui, e não só no registrador, para a instrução
    // registrada também voltar à palavra do endereço 0.
    always_comb begin
        if (reset_i)
            pc_sel_o = '0;
        else if (pc_write_i)
            pc_sel_o = pc_branch_i ? new_pc_i : pc_next_o;
        else
            pc_sel_o = pc_i;
    end

endmodule
