`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 19.10.2026 11:38:28
// Design Name: Processador RV32I
// Module Name: register_file
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Banco com 31 registradores inteiros e duas portas de leitura.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   x0 e implementado como zero constante e nao ocupa o array. Nao ha reset;
//   os registradores x1 a x31 permanecem indefinidos ate serem escritos.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file register_file.sv
 * @brief Banco de registradores inteiros do processador RV32I.
 *
 * Armazena os registradores x1 a x31, oferece duas leituras combinacionais e
 * uma escrita sincronizada na borda de subida do clock. A escrita em x0 e
 * ignorada e as leituras de x0 sempre retornam zero. Este modulo nao possui
 * sinal de reset.
 *
 * @param XLEN Largura dos dados armazenados. Valor padrao: 32 bits.
 * @param REG_XLEN Largura dos enderecos de registrador. Valor padrao: 5 bits.
 * @param clk Clock usado para efetivar as escritas.
 * @param written_enable_i Habilita a escrita no registrador de destino.
 * @param written_data_i Dado gravado na borda de subida quando a escrita esta habilitada.
 * @param written_add_i Endereco do registrador de destino.
 * @param rs1_add_i Endereco do registrador selecionado pela porta de leitura 1.
 * @param rs2_add_i Endereco do registrador selecionado pela porta de leitura 2.
 * @retval rs1_o Dado lido da porta rs1; zero quando rs1_add_i e x0.
 * @retval rs2_o Dado lido da porta rs2; zero quando rs2_add_i e x0.
 */
module register_file #(
    parameter XLEN = 32,
    parameter REG_XLEN = 5
)(
    input  logic                 clk,
    input  logic                 written_enable_i,
    input  logic [XLEN-1:0]      written_data_i,
    input  logic [REG_XLEN-1:0]  written_add_i,
    input  logic [REG_XLEN-1:0]  rs1_add_i,
    input  logic [REG_XLEN-1:0]  rs2_add_i,
    output logic [XLEN-1:0]      rs1_o,
    output logic [XLEN-1:0]      rs2_o
);

    logic [XLEN-1:0] register_file [1:31];

    // Valor inicial zero: evita leituras 'X' na simulacao e vira valor de
    // inicializacao da LUTRAM/FFs na FPGA. Não é um reset (o reset só reinicia o
    // PC e a instrução registrada).
    initial begin
        for (int i = 1; i < 32; i++) register_file[i] = '0;
    end

    always_ff @(posedge clk) begin
        if (written_enable_i && (written_add_i != 5'd0)) begin
            register_file[written_add_i] <= written_data_i;
        end
    end

    always_comb begin
        if (rs1_add_i == 5'd0)
            rs1_o = 32'd0;
        else
            rs1_o = register_file[rs1_add_i];

        if (rs2_add_i == 5'd0)
            rs2_o = 32'd0;
        else
            rs2_o = register_file[rs2_add_i];
    end
endmodule
