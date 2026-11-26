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
 * decisão vem de um comparador dedicado entre `reg_data1_i` (rs1) e
 * `reg_data2_i` (rs2), que não passa pelos muxes de operando nem pela ALU.
 * `funct3_i` escolhe a comparação, como no RV32I: `funct3_i[2]` = 0 igualdade
 * (BEQ/BNE), 1 menor (BLT/BGE/BLTU/BGEU); `funct3_i[1]` = 1 sem sinal. O
 * `alu_control_i` não participa da comparação. OP_BCT desvia quando a
 * comparação é verdadeira e OP_BCF quando é falsa. OP_BIP e OP_BIR sao desvios
 * incondicionais relativos ao PC e a rs1, respectivamente.
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
 * @param funct3_i funct3 da instrucao. Nos desvios condicionais escolhe a
 *                 comparacao; nas demais instrucoes e ignorado.
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
    input  logic [2:0]      funct3_i,

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

    logic [XLEN-1:0] branch_address;
    logic            branch_cond;
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
        .alu_o   (alu_result)
    );

    // Comparador dedicado dos desvios: rs1 x rs2 direto, sem os muxes de
    // operando nem a ALU. É uma cadeia de carry só, configurada pelo funct3
    // (fio da instrução, pronto junto com a leitura do banco): funct3[2] = 0
    // compara igualdade e 1 compara "menor"; funct3[1] = 1 é sem sinal. Com
    // sinal = sem sinal com o bit 31 dos dois operandos invertido.
    // A cadeia anda em dígitos de 2 bits: cmp_eq = dígitos iguais (propaga) e
    // cmp_lt = dígito de rs1 menor (gera; só no modo "menor"). O carry de
    // cmp_lt + (cmp_lt ^ cmp_eq) + cin, com cin = 1 no modo igualdade, é o
    // resultado da comparação; escrito assim, a síntese monta um único
    // somador de 16 dígitos (4 CARRY4) em vez de três comparadores e um mux.
    logic              cmp_less;     // 1: "menor"; 0: igualdade
    logic              cmp_signed;
    logic [XLEN-1:0]   cmp_a;
    logic [XLEN-1:0]   cmp_b;
    logic [XLEN/2-1:0] cmp_eq;
    logic [XLEN/2-1:0] cmp_lt;
    logic [XLEN/2:0]   cmp_chain;

    assign cmp_less   = funct3_i[2];
    assign cmp_signed = ~funct3_i[1];
    assign cmp_a      = {reg_data1_i[XLEN-1] ^ cmp_signed, reg_data1_i[XLEN-2:0]};
    assign cmp_b      = {reg_data2_i[XLEN-1] ^ cmp_signed, reg_data2_i[XLEN-2:0]};

    always_comb begin
        for (int j = 0; j < XLEN/2; j++) begin
            cmp_eq[j] = (cmp_a[2*j +: 2] == cmp_b[2*j +: 2]);
            cmp_lt[j] = cmp_less & (cmp_a[2*j +: 2] < cmp_b[2*j +: 2]);
        end
    end

    assign cmp_chain   = {1'b0, cmp_lt} + {1'b0, cmp_lt ^ cmp_eq} + {{(XLEN/2){1'b0}}, ~cmp_less};
    assign branch_cond = cmp_chain[XLEN/2];

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

    assign branch_taken = branch_cond ? take_if_true : take_if_false;

    // Base do endereço de destino: rs1 no JALR, PC nos demais. Não depende do
    // enable: o destino só é usado quando o desvio é tomado.
    assign branch_b = (branch_control_i == OP_BIR) ? reg_data1_i : pc_i;

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
