`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026 10:00:00
// Design Name: Processador RV32I
// Module Name: mem_addr_unit
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Endereco de load/store (rs1 + imediato) e flags de regiao.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Recortado da execution sem mudar a logica.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file mem_addr_unit.sv
 * @brief Somador dedicado rs1 + imediato e flags de região da memória de dados.
 *
 * As duas flags sao calculadas sem esperar o carry do somador e so sao exatas
 * para imediato de 12 bits estendido (`imm_i[31:11]` iguais), ou seja, em loads
 * e stores, as unicas instrucoes que usam a memoria de dados.
 *
 * @param XLEN Largura dos dados e enderecos. Valor padrao: 32 bits.
 * @param reg_data1_i Valor lido do registrador rs1.
 * @param imm_i Imediato estendido da instrucao.
 * @retval mem_addr_o Endereco de load/store (rs1 + imediato), calculado por um
 *                    somador dedicado em paralelo a ALU.
 * @retval mem_io_o Endereco de load/store no espaco de MMIO
 *                  (`mem_addr_o[31:28] == 4'h4`).
 * @retval mem_page0_o Endereco de load/store nos primeiros 4 KiB
 *                     (`mem_addr_o[31:12] == 0`).
 */
module mem_addr_unit #(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] reg_data1_i,
    input  logic [XLEN-1:0] imm_i,

    output logic [XLEN-1:0] mem_addr_o,
    output logic            mem_io_o,
    output logic            mem_page0_o
);

    // Endereco da memoria de dados: nao passa pelos muxes de operando nem pelo
    // mux de saida da ALU.
    assign mem_addr_o = reg_data1_i + imm_i;

    // Regiao da memoria de dados sem esperar o carry ate o bit 31. Com imediato
    // de 12 bits, mem_addr_o[31:12] so pode ser rs1[31:12] - 1, + 0 ou + 1,
    // conforme imm[11] e o carry do bit 11. As flags dos tres candidatos
    // dependem so de rs1; o carry atravessa apenas 12 bits.
    logic [12:0] addr_low;
    logic [19:0] rs1_hi;
    logic        io_dec, io_mid, io_inc;
    logic        page0_dec, page0_mid, page0_inc;

    assign addr_low = {1'b0, reg_data1_i[11:0]} + {1'b0, imm_i[11:0]};
    assign rs1_hi   = reg_data1_i[31:12];

    assign io_mid    = (rs1_hi[19:16] == 4'h4);
    // rs1_hi + 1: o nibble alto so muda se rs1_hi[15:0] for todo 1.
    assign io_inc    = (rs1_hi[15:0] == 16'hFFFF) ? (rs1_hi[19:16] == 4'h3) : io_mid;
    // rs1_hi - 1: o nibble alto so muda se rs1_hi[15:0] for todo 0.
    assign io_dec    = (rs1_hi[15:0] == 16'h0000) ? (rs1_hi[19:16] == 4'h5) : io_mid;

    assign page0_mid = (rs1_hi == 20'h00000);
    assign page0_inc = (rs1_hi == 20'hFFFFF);   // rs1_hi + 1 == 0
    assign page0_dec = (rs1_hi == 20'h00001);   // rs1_hi - 1 == 0

    always_comb begin
        case ({imm_i[11], addr_low[12]})
            2'b01:   begin mem_io_o = io_inc; mem_page0_o = page0_inc; end // imm >= 0, carry
            2'b10:   begin mem_io_o = io_dec; mem_page0_o = page0_dec; end // imm < 0, sem carry
            default: begin mem_io_o = io_mid; mem_page0_o = page0_mid; end
        endcase
    end

endmodule
