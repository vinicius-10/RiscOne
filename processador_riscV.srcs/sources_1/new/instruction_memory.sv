`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 22.09.2026 09:23:34
// Design Name: Processador RV32I
// Module Name: instruction_memory
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Memoria combinacional de instrucoes inicializada por arquivo.
//
// Dependencies: $readmemh
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   addr_i e um endereco de byte. Os bits [1:0] sao ignorados, selecionando
//   palavras alinhadas de XLEN bits. MEM_DEPTH indica quantidade de palavras.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file instruction_memory.sv
 * @brief Memoria de instrucoes com leitura combinacional.
 *
 * Inicializa o array de memoria com o conteudo hexadecimal de `MEM_FILE` por
 * meio de `$readmemh`. O endereco de byte recebido e convertido em indice de
 * palavra descartando os dois bits menos significativos. Portanto, enderecos
 * com diferenca apenas nos bits [1:0] selecionam a mesma palavra. A leitura nao
 * depende de clock.
 *
 * O `search` endereça esta memória com o próximo PC e guarda a palavra lida no
 * registrador da instrução, na mesma borda em que atualiza o PC.
 *
 * @param XLEN Largura, em bits, de cada palavra e da interface. Padrao: 32.
 * @param MEM_DEPTH Quantidade de palavras na memoria. Padrao: 1024.
 * @param MEM_FILE Caminho do arquivo hexadecimal de inicializacao. Padrao:
 *                 `program_bytes.mem`.
 * @param addr_i Endereço de byte da próxima instrução (próximo PC, vindo do
 *               `search`).
 * @retval instr_o Palavra de XLEN bits lida do indice selecionado por addr_i.
 */
module instruction_memory #(
    parameter int XLEN       = 32,
    parameter int MEM_DEPTH  = 1024,
    parameter string MEM_FILE = "program_bytes.mem"
)(
    input  logic [XLEN-1:0] addr_i,
    output logic [XLEN-1:0] instr_o
);

    logic [XLEN-1:0] mem [0:MEM_DEPTH-1];

    initial begin
        $readmemh(MEM_FILE, mem);
    end

    localparam int ADDR_WIDTH = $clog2(MEM_DEPTH);
    logic [ADDR_WIDTH-1:0] word_addr;

    assign word_addr = addr_i[ADDR_WIDTH+1:2];

    assign instr_o = mem[word_addr];

endmodule
