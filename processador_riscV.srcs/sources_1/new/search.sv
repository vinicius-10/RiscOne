`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 22.09.2026 13:11:55
// Design Name: Processador rv32i
// Module Name: search
// Project Name:  processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Bloco responsanvel por realizar a busca de instruçoes na memoria de instruçoes, e enviar para o decodificador
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file search.sv
 * @brief Módulo de busca de instruções do processador RV32I.
 *
 * Este módulo mantém o contador de programa (PC), realiza o incremento
 * sequencial em 4 instruções, pode carregar um novo endereço em caso de branch
 * e acessa a memória de instruções para devolver a instrução atual.
 *
 * Comportamento padrão:
 * - rest_i = 1 => pc_reg é zerado.
 * - pc_write_i = 0 => o PC mantém o valor atual.
 * - pc_write_i = 1 e pc_branch_i = 0 => o PC avança em 4.
 * - pc_write_i = 1 e pc_branch_i = 1 => o PC recebe new_pc_i.
 *
 * @param XLEN Largura do barramento de dados e do endereço do PC. Valor padrão: 32.
 * @param MEM_DEPTH Profundidade da memória de instruções. Valor padrão: 1024.
 * @param clk Sinal de clock do módulo. A atualização do PC ocorre na borda de subida.
 * @param new_pc_i Novo endereço do PC em caso de desvio condicional. Valor padrão lógico: 0 quando não há branch.
 * @param pc_write_i Habilita a atualização do contador de programa. Valor padrão: 0 (não escreve).
 * @param pc_branch_i Sinal de controle do tipo de atualização do PC. 0 = incrementa; 1 = carrega new_pc_i.
 * @param rest_i Sinal de reset do módulo. 1 força o valor do PC para zero.
 * @retval instr_o Instrução lida da memória de instruções correspondente ao endereço atual do PC. Valor padrão após reset: 0.
 * @retval pc_o Valor atual do contador de programa. Valor padrão após reset: 0.
 */

module search #(
    parameter int XLEN      = 32,
    parameter int MEM_DEPTH = 1024,
    parameter string MEM_FILE = "program_bytes.hex"
)(
    input  logic              clk,         // Sinal de clock
    input  logic              rest_i,      // Reset assíncrono/síncrono
    input  logic              pc_write_i,  // Enable para atualização do PC
    input  logic              pc_branch_i, // Seleção de desvio (1 = salto, 0 = PC+4)
    input  logic [XLEN-1:0]   new_pc_i,    // Endereço de destino do salto/branch
    output logic [XLEN-1:0]   instr_o,     // Instrução buscada
    output logic [XLEN-1:0]   pc_o,        // PC da instrução atual (buscada agora)
    output logic [XLEN-1:0]   pc_next      // Próximo PC sequencial (PC + 4)
);

    logic [XLEN-1:0] pc_reg;

    // Atribuições combinacionais de saída
    assign pc_o    = pc_reg;
    assign pc_next = pc_reg + 32'd4;

    // Atualização sequencial do Contador de Programa (PC)
    always_ff @(posedge clk) begin
        if (rest_i) begin
            pc_reg <= '0;
        end else if (pc_write_i) begin
            pc_reg <= pc_branch_i ? new_pc_i : pc_next;
        end
    end

    instruction_memory #(
        .XLEN(XLEN),
        .MEM_DEPTH(MEM_DEPTH),
        .MEM_FILE(MEM_FILE)
    ) instr_mem (
        .addr_i  (pc_reg),
        .instr_o (instr_o)
    );

endmodule