`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 29.09.2026 13:30:30
// Design Name: Processador RV32I
// Module Name: execution
// Project Name: processador_riscV
// Target Device: Artix-7 Nexys A7-100T
// Tool Version: Vivado 2025.2
// Description: Executa operacoes da ALU e calcula enderecos e condicoes de desvio.
//
// Dependencies: alu, alu_pkg, branch_pkg
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Os seletores das entradas da ALU devem receber somente os codigos descritos
//   na interface. O destino calculado para desvio tem o bit menos significativo
//   zerado para manter o alinhamento de instrucao.
//////////////////////////////////////////////////////////////////////////////////


/**
 * @file execution.sv
 * @brief Unidade de execucao do processador RV32I.
 *
 * Seleciona os operandos da ALU, executa a operacao indicada e calcula em
 * paralelo o endereco de destino de desvio. Para desvios condicionais, a
 * decisao usa `alu_lsb`, que nesta implementacao reflete o bit menos significativo
 * do resultado da ALU: OP_BCT aceita quando `alu_lsb` vale 1 e OP_BCF aceita
 * quando `alu_lsb` vale 0. OP_BIP e OP_BIR sao desvios incondicionais relativos ao
 * PC e a rs1, respectivamente.
 *
 * @param XLEN Largura dos dados e enderecos. Valor padrao: 32 bits.
 * @param pc_next_i Endereco sequencial da instrucao, normalmente PC + 4.
 * @param pc_i Endereco da instrucao atual.
 * @param imm_i Imediato estendido da instrucao.
 * @param reg_data1_i Valor lido do registrador rs1.
 * @param reg_data2_i Valor lido do registrador rs2.
 * @param alu_control_i Operacao da ALU, conforme `alu_op_t` de `alu_pkg`.
 * @param branch_control_i Tipo de desvio, conforme `branch_op_t` de `branch_pkg`.
 * @param branch_enable_i Habilita a decisao de desvio.
 * @param control_alu_a Seletor da entrada A: 0 = rs1, 1 = PC.
 * @param control_alu_b Seletor da entrada B: 00 = rs2, 01 = imediato,
 *                       10 = PC+4.
 * @retval pc_branch_o Endereco de destino calculado, com o bit 0 zerado.
 * @retval alu_result_o Resultado da operacao selecionada para a ALU.
 * @retval branch_taken_o Indica se o desvio deve ser tomado.
 * @retval mem_addr_o Endereco de load/store (rs1 + imediato), calculado por um
 *                    somador dedicado em paralelo a ALU para encurtar o
 *                    caminho ate a memoria de dados.
 * @retval mem_io_o Endereco de load/store no espaco de MMIO
 *                  (`mem_addr_o[31:28] == 4'h4`).
 * @retval mem_page0_o Endereco de load/store nos primeiros 4 KiB
 *                     (`mem_addr_o[31:12] == 0`).
 *
 * As duas flags sao calculadas sem esperar o carry do somador e so sao exatas
 * para imediato de 12 bits estendido (`imm_i[31:11]` iguais), ou seja, em loads
 * e stores, as unicas instrucoes que usam a memoria de dados.
 */
module execution
    import alu_pkg::*;
    import branch_pkg::*;
#(
    parameter int XLEN = 32
)(
    input  logic [XLEN-1:0] pc_next_i,
    input  logic [XLEN-1:0] pc_i,
    input  logic [XLEN-1:0] imm_i,
    input  logic [XLEN-1:0] reg_data1_i,
    input  logic [XLEN-1:0] reg_data2_i,

    input  alu_op_t         alu_control_i,
    input  branch_op_t      branch_control_i,
    input  logic            branch_enable_i,
    input  logic            control_alu_a,
    input  logic [1:0]      control_alu_b,

    output logic [XLEN-1:0] pc_branch_o,
    output logic [XLEN-1:0] alu_result_o,
    output logic            branch_taken_o,
    output logic [XLEN-1:0] mem_addr_o,
    output logic            mem_io_o,
    output logic            mem_page0_o
);

    logic [XLEN-1:0] alu_a;
    logic [XLEN-1:0] alu_b;
    logic [XLEN-1:0] alu_result;
    logic            alu_lsb;

    logic [XLEN-1:0] branch_address;
    logic            branch_taken;
    logic [XLEN-1:0] branch_a;
    logic [XLEN-1:0] branch_b;

    assign alu_result_o  = alu_result;
    assign pc_branch_o   = branch_address;
    assign branch_taken_o = branch_taken;

    // Selecao dos operandos enviados a ALU.
    always_comb begin
        case (control_alu_a)
            1'b0: alu_a = reg_data1_i;
            1'b1: alu_a = pc_i;
        endcase

        case (control_alu_b)
            2'b00: alu_b = reg_data2_i;
            2'b01: alu_b = imm_i;
            2'b10: alu_b = pc_next_i;
            default: alu_b = reg_data2_i;
        endcase
    end

    alu #(
        .XLEN(XLEN)
    ) alu_inst (
        .a_i     (alu_a),
        .b_i     (alu_b),
        .alu_op_i(alu_control_i),
        .alu_o   (alu_result),
        .alu_lsb_o(alu_lsb)
    );

    // Escolhe a condicao do desvio e a base do endereco de destino.
    always_comb begin
        if (branch_enable_i) begin
            case (branch_control_i)
                OP_BCT: begin
                    branch_taken = alu_lsb;
                    branch_b     = pc_i;
                end
                OP_BCF: begin
                    branch_taken = ~alu_lsb;
                    branch_b     = pc_i;
                end
                OP_BIP: begin
                    branch_taken = 1'b1;
                    branch_b     = pc_i;
                end
                OP_BIR: begin
                    branch_taken = 1'b1;
                    branch_b     = reg_data1_i;
                end
            endcase
        end else begin
            branch_taken = 1'b0;
            branch_b     = pc_i;
        end
    end

    assign branch_a       = imm_i;
    // Zera o bit 0: exigido pelo JALR; inofensivo para branches/JAL, cujo
    // imediato ja tem bit 0 = 0.
    assign branch_address = (branch_a + branch_b) & ~XLEN'(1);

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
