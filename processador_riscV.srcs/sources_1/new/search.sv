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
// Description: Bloco responsável por realizar a busca de instruções na memória de instruções e enviar para o decodificador
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
 * Mantém o contador de programa (PC), calcula o próximo PC (PC + 4 ou o destino
 * de um desvio) e entrega a instrução do PC atual. O próximo PC (`pc_sel`) vai,
 * na mesma borda, para o registrador do PC e para o endereço da memória de
 * instruções, que tem leitura síncrona. Assim, depois de cada borda, `instr_o`
 * é sempre a instrução do endereço `pc_o`. Continua monociclo (uma instrução
 * por ciclo): a leitura da ROM só passa para o fim do ciclo anterior.
 *
 * Próximo PC (`pc_sel`):
 * - reset_i = 1 => 0 (o PC zera e a memória registra a palavra 0).
 * - pc_write_i = 0 => o PC atual (a memória relê a mesma palavra).
 * - pc_write_i = 1 e pc_branch_i = 0 => PC + 4.
 * - pc_write_i = 1 e pc_branch_i = 1 => new_pc_i.
 *
 * @param XLEN Largura do barramento de dados e do endereço do PC. Valor padrão: 32.
 * @param MEM_DEPTH Profundidade da memória de instruções. Valor padrão: 1024.
 * @param MEM_FILE Arquivo de inicialização da memória de instruções.
 * @param clk Sinal de clock do módulo. PC e instrução são atualizados na borda de subida.
 * @param new_pc_i Destino do desvio ou salto.
 * @param pc_write_i Habilita a atualização do contador de programa; em 0, o PC é mantido.
 * @param pc_branch_i Sinal de controle do tipo de atualização do PC. 0 = incrementa; 1 = carrega new_pc_i.
 * @param reset_i Reset síncrono ativo em nível alto: na borda, PC = 0 e instrução = palavra 0.
 * @retval instr_o Instrução do endereço atual do PC, registrada na mesma borda que o PC.
 * @retval pc_o Valor atual do contador de programa. Valor padrão após reset: 0.
 * @retval pc_next Próximo PC sequencial (PC + 4).
 */

module search #(
    parameter int XLEN      = 32,
    parameter int MEM_DEPTH = 1024,
    parameter string MEM_FILE = "program_bytes.mem"
)(
    input  logic              clk,         // Sinal de clock
    input  logic              reset_i,     // Reset síncrono ativo em nível alto
    input  logic              pc_write_i,  // Enable para atualização do PC
    input  logic              pc_branch_i, // Seleção de desvio (1 = salto, 0 = PC+4)
    input  logic [XLEN-1:0]   new_pc_i,    // Endereço de destino do salto/branch
    output logic [XLEN-1:0]   instr_o,     // Instrução do PC atual (registrada)
    output logic [XLEN-1:0]   pc_o,        // PC da instrução atual
    output logic [XLEN-1:0]   pc_next      // Próximo PC sequencial (PC + 4)
);

    logic [XLEN-1:0] pc_reg;
    logic [XLEN-1:0] pc_sel;   // próximo PC: vai para o PC e para a memória de instruções

    // Atribuições combinacionais de saída
    assign pc_o    = pc_reg;
    assign pc_next = pc_reg + 32'd4;

    // Próximo PC. O reset entra aqui, e não só no registrador, para a memória de
    // instruções também registrar a palavra do endereço 0.
    always_comb begin
        if (reset_i)
            pc_sel = '0;
        else if (pc_write_i)
            pc_sel = pc_branch_i ? new_pc_i : pc_next;
        else
            pc_sel = pc_reg;
    end

    // Atualização sequencial do Contador de Programa (PC); na mesma borda, a
    // memória de instruções registra a palavra de pc_sel.
    always_ff @(posedge clk) begin
        pc_reg <= pc_sel;
    end

    instruction_memory #(
        .XLEN(XLEN),
        .MEM_DEPTH(MEM_DEPTH),
        .MEM_FILE(MEM_FILE)
    ) instr_mem (
        .clk     (clk),
        .addr_i  (pc_sel),
        .instr_o (instr_o)
    );

endmodule
