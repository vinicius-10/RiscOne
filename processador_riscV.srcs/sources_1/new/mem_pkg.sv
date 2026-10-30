`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 06.10.2026 16:51:21
// Design Name: Processador RV32I
// Package Name: mem_pkg
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Define tipos de largura de acesso e extensao para a memoria.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Os tipos sao compartilhados pela unidade de controle e pela memoria de dados.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file mem_pkg.sv
 * @brief Tipos de controle para os acessos a memoria de dados.
 *
 * Fornece `mem_width_t` para selecionar byte, halfword ou word e
 * `mem_signed_t` para selecionar extensao com sinal ou sem sinal em loads.
 *
 * @package mem_pkg
 * @enum mem_width_t Largura de acesso: MEM_WIDTH_BYTE, MEM_WIDTH_HALF ou
 *                   MEM_WIDTH_WORD.
 * @enum mem_signed_t Modo de extensao: MEM_UNSIGNED ou MEM_SIGNED.
 */


package mem_pkg;

    //==========================================================
    // Memory Access Width
    //==========================================================
    typedef enum logic [1:0] {
        MEM_WIDTH_BYTE = 2'b00, // Acesso de 8 bits
        MEM_WIDTH_HALF = 2'b01, // Acesso de 16 bits
        MEM_WIDTH_WORD = 2'b10  // Acesso de 32 bits
    } mem_width_t;


    //==========================================================
    // Load Extension Mode
    //==========================================================
    typedef enum logic {
        MEM_UNSIGNED = 1'b0, // Preenche bits altos com zero
        MEM_SIGNED   = 1'b1  // Repete o bit de sinal nos bits altos
    } mem_signed_t;


endpackage  
