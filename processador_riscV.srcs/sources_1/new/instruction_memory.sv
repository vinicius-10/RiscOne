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
// Description: Memória de instruções com leitura síncrona, inicializada por arquivo.
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
 * @brief Memória de instruções com leitura síncrona.
 *
 * Inicializa o array de memória com o conteúdo hexadecimal de `MEM_FILE` por
 * meio de `$readmemh`. O endereço de byte recebido é convertido em índice de
 * palavra descartando os dois bits menos significativos; endereços que diferem
 * só nos bits [1:0] selecionam a mesma palavra.
 *
 * A leitura é síncrona: na borda de subida de `clk`, `instr_o` recebe a palavra
 * de `addr_i`. O `search` entrega em `addr_i` o próximo PC, o mesmo valor que o
 * PC recebe nessa borda; por isso, depois de cada borda, `instr_o` é a
 * instrução do PC atual. Na configuração da FPGA, `instr_o` nasce com a
 * palavra 0, o endereço em que o PC nasce, então a placa pode partir sem
 * reset.
 *
 * A ROM fica em LUTs (`rom_style = "distributed"`): com a saída registrada, o
 * Vivado a colocaria em BRAM.
 *
 * @param XLEN Largura, em bits, de cada palavra e da interface. Padrão: 32.
 * @param MEM_DEPTH Quantidade de palavras na memória. Padrão: 1024.
 * @param MEM_FILE Caminho do arquivo hexadecimal de inicialização. Padrão:
 *                 `program_bytes.mem`.
 * @param clk Clock; a instrução é registrada na borda de subida.
 * @param addr_i Endereço de byte da próxima instrução (próximo PC, vindo do
 *               `search`).
 * @retval instr_o Palavra de XLEN bits registrada a partir de `addr_i` na
 *                 última borda; nasce com a palavra 0.
 */
module instruction_memory #(
    parameter int XLEN       = 32,
    parameter int MEM_DEPTH  = 1024,
    parameter string MEM_FILE = "program_bytes.mem"
)(
    input  logic            clk,
    input  logic [XLEN-1:0] addr_i,
    output logic [XLEN-1:0] instr_o
);

    (* rom_style = "distributed" *) logic [XLEN-1:0] mem [0:MEM_DEPTH-1];

    initial begin
        $readmemh(MEM_FILE, mem);
        // O PC nasce 0 (valor inicial dos FFs); a instrução nasce com a palavra 0.
        instr_o = mem[0];
    end

    localparam int ADDR_WIDTH = $clog2(MEM_DEPTH);
    logic [ADDR_WIDTH-1:0] word_addr;

    assign word_addr = addr_i[ADDR_WIDTH+1:2];

    always_ff @(posedge clk) begin
        instr_o <= mem[word_addr];
    end

endmodule
