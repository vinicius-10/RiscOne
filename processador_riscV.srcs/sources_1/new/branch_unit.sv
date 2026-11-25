`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 25.11.2026 10:00:00
// Design Name: Processador RV32I
// Module Name: branch_unit
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Decide se o desvio e tomado e calcula o endereco de destino.
//
// Dependencies: branch_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Recortado da execution sem mudar a logica. O destino tem o bit menos
//   significativo zerado para manter o alinhamento de instrucao.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file branch_unit.sv
 * @brief Decisão de desvio e somador do endereço de destino.
 *
 * OP_BCT desvia quando a comparação é verdadeira e OP_BCF quando é falsa.
 * OP_BIP e OP_BIR são desvios incondicionais relativos ao PC e a rs1,
 * respectivamente.
 *
 * @param XLEN Largura dos dados e enderecos. Valor padrao: 32 bits.
 * @param branch_cond_i Resultado da comparacao do `branch_comparator`.
 * @param branch_enable_i Habilita a decisao de desvio.
 * @param branch_control_i Tipo de desvio, conforme `branch_op_t` de `branch_pkg`.
 * @param imm_i Imediato estendido da instrucao.
 * @param pc_i Endereco da instrucao atual.
 * @param reg_data1_i Valor lido do registrador rs1 (base do JALR).
 * @retval branch_taken_o Indica se o desvio deve ser tomado.
 * @retval pc_branch_o Endereco de destino calculado, com o bit 0 zerado.
 */
module branch_unit
    import branch_pkg::*;
#(
    parameter int XLEN = 32
)(
    input  logic            branch_cond_i,
    input  logic            branch_enable_i,
    input  branch_op_t      branch_control_i,
    input  logic [XLEN-1:0] imm_i,
    input  logic [XLEN-1:0] pc_i,
    input  logic [XLEN-1:0] reg_data1_i,

    output logic            branch_taken_o,
    output logic [XLEN-1:0] pc_branch_o
);

    logic [XLEN-1:0] branch_a;
    logic [XLEN-1:0] branch_b;

    // Decisão: o controle diz antes o que fazer com a comparação verdadeira e
    // com a falsa; a comparação, que chega por último, só escolhe entre as duas.
    logic take_if_true;
    logic take_if_false;

    always_comb begin
        take_if_true  = 1'b0;
        take_if_false = 1'b0;
        if (branch_enable_i) begin
            case (branch_control_i)
                OP_BCT:  take_if_true  = 1'b1;
                OP_BCF:  take_if_false = 1'b1;
                default: begin                 // OP_BIP, OP_BIR: sempre
                    take_if_true  = 1'b1;
                    take_if_false = 1'b1;
                end
            endcase
        end
    end

    assign branch_taken_o = branch_cond_i ? take_if_true : take_if_false;

    // Base do endereço de destino: rs1 no JALR, PC nos demais. Não depende do
    // enable: o destino só é usado quando o desvio é tomado.
    assign branch_b = (branch_control_i == OP_BIR) ? reg_data1_i : pc_i;

    assign branch_a    = imm_i;
    // Zera o bit 0: exigido pelo JALR; inofensivo para branches/JAL, cujo
    // imediato ja tem bit 0 = 0.
    assign pc_branch_o = (branch_a + branch_b) & ~XLEN'(1);

endmodule
