`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 06.10.2026 12:09:31
// Design Name: Processador RV32I
// Package Name: branch_pkg
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Define os codigos de controle de desvio da unidade de execucao.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   OP_BCT e OP_BCF usam a condicao da ALU; OP_BIP e OP_BIR sao incondicionais.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file branch_pkg.sv
 * @brief Tipo e codigos para selecionar o comportamento dos desvios.
 *
 * O enum `branch_op_t` codifica a decisao do bloco de execucao e a base usada
 * para calcular o endereco de destino.
 *
 * @package branch_pkg
 * @typedef branch_op_t Codigo de dois bits para controle de desvio.
 *
 * Valores:
 * - `OP_BCT`: desvio condicional quando a condicao da ALU e verdadeira; destino PC+imediato.
 * - `OP_BCF`: desvio condicional quando a condicao da ALU e falsa; destino PC+imediato.
 * - `OP_BIP`: desvio incondicional relativo ao PC; destino PC+imediato.
 * - `OP_BIR`: desvio incondicional relativo a rs1; destino rs1+imediato.
 */
package branch_pkg;

    typedef enum logic [1:0] {
        OP_BCT = 2'b00, // Desvio condicional quando a condicao e verdadeira: PC + imediato
        OP_BCF = 2'b01, // Desvio condicional quando a condicao e falsa: PC + imediato
        OP_BIP = 2'b10, // Desvio incondicional relativo ao PC: PC + imediato
        OP_BIR = 2'b11  // Desvio incondicional relativo a rs1: rs1 + imediato
    } branch_op_t;

endpackage : branch_pkg
