`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 21.10.2026 08:49:07
// Design Name: Processador RV32I
// Module Name: tb_decoder
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: Vivado 2025.2
// Description: Testbench automatizado da etapa de decodificacao RV32I.
// 
// Dependencies: decoder, alu_pkg, branch_pkg, func3_pkg, func7_pkg, mem_pkg,
//               opcode_pkg
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



/**
 * @file tb_decoder.sv
 * @brief Testbench integrado do modulo decoder.
 *
 * Aplica instrucoes RV32I representativas, fornece os valores simulados que
 * chegam do write-back e verifica as leituras do banco, o imediato e todos os
 * sinais de controle exportados. Inicializa x1 a x31 antes dos casos para que
 * leituras de campos nao usados pela instrucao tenham valores definidos.
 *
 * A verificacao compara cada resultado com valores esperados e contabiliza
 * as falhas em `fail_count`.
 */
import opcode_pkg::*;
import func3_pkg::*;
import func7_pkg::*;
import alu_pkg::*;
import branch_pkg::*;
import mem_pkg::*;

module tb_decoder;

    // =========================================================================
    // 1. PARÂMETROS E SINAIS DE INTERFACE
    // =========================================================================
    localparam int XLEN     = 32;
    localparam int REG_XLEN = 5;

    logic                 clk;
    logic [31:0]          instruction_i;
    logic [XLEN-1:0]      written_data_i;

    logic [XLEN-1:0]      rs1_o;
    logic [XLEN-1:0]      rs2_o;
    logic [XLEN-1:0]      imm_o;

    alu_op_t              execution_alu_control_o;
    branch_op_t           execution_branch_control_o;
    logic                 execution_branch_enable_o;
    logic                 execution_control_alu_a_o;
    logic [1:0]           execution_control_alu_b_o;
    logic                 search_pc_write_o;
    logic                 data_memory_mem_write_o;
    mem_width_t           data_memory_mem_width_o;
    mem_signed_t          data_memory_mem_signed_o;
    logic                 register_file_written_enable_o;
    logic                 write_back_mem_to_reg_o;

    integer fail_count = 0;
    integer init_reg;

    // =========================================================================
    // 2. INSTANCIAÇÃO DO DUT
    // =========================================================================
    decoder #(
        .XLEN    (XLEN),
        .REG_XLEN(REG_XLEN)
    ) DUT (
        .clk                            (clk),
        .instruction_i                  (instruction_i),
        .written_data_i                 (written_data_i),
        .rs1_o                          (rs1_o),
        .rs2_o                          (rs2_o),
        .imm_o                          (imm_o),
        .execution_alu_control_o        (execution_alu_control_o),
        .execution_branch_control_o     (execution_branch_control_o),
        .execution_branch_enable_o      (execution_branch_enable_o),
        .execution_control_alu_a_o      (execution_control_alu_a_o),
        .execution_control_alu_b_o      (execution_control_alu_b_o),
        .search_pc_write_o              (search_pc_write_o),
        .data_memory_mem_write_o        (data_memory_mem_write_o),
        .data_memory_mem_width_o        (data_memory_mem_width_o),
        .data_memory_mem_signed_o       (data_memory_mem_signed_o),
        .register_file_written_enable_o (register_file_written_enable_o),
        .write_back_mem_to_reg_o        (write_back_mem_to_reg_o)
    );

    // =========================================================================
    // 3. GERAÇÃO DO CLOCK DE REFERÊNCIA
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. TASK DE COMPARAÇÃO AUTOMÁTICA
    // =========================================================================
    task automatic check_result(
        input int           test_num,
        input string        test_name,
        input logic [31:0]  exp_rs1,
        input logic [31:0]  exp_rs2,
        input logic [31:0]  exp_imm,
        input alu_op_t      exp_alu_ctrl,
        input branch_op_t   exp_branch_ctrl,
        input logic         exp_branch_en,
        input logic         exp_alu_a,
        input logic [1:0]   exp_alu_b,
        input logic         exp_pc_write,
        input logic         exp_mem_write,
        input mem_width_t   exp_mem_width,
        input mem_signed_t  exp_mem_signed,
        input logic         exp_reg_write,
        input logic         exp_mem_to_reg
    );
        begin
            #1; // Tolera atraso de propagação após o posedge clk
            
            if ((rs1_o                          === exp_rs1)          &&
                (rs2_o                          === exp_rs2)          &&
                (imm_o                          === exp_imm)          &&
                (execution_alu_control_o        === exp_alu_ctrl)     &&
                (execution_branch_control_o     === exp_branch_ctrl)  &&
                (execution_branch_enable_o      === exp_branch_en)    &&
                (execution_control_alu_a_o      === exp_alu_a)        &&
                (execution_control_alu_b_o      === exp_alu_b)        &&
                (search_pc_write_o              === exp_pc_write)     &&
                (data_memory_mem_write_o        === exp_mem_write)    &&
                (data_memory_mem_width_o        === exp_mem_width)    &&
                (data_memory_mem_signed_o       === exp_mem_signed)   &&
                (register_file_written_enable_o === exp_reg_write)   &&
                (write_back_mem_to_reg_o        === exp_mem_to_reg)) begin
                
                $display("[PASS] Teste %02d: %-55s", test_num, test_name);
            end else begin
                $display("[FAIL] Teste %02d: %-55s", test_num, test_name);
                $display("       Obtido   -> RS1:0x%08h RS2:0x%08h IMM:0x%08h ALU_Op:%b Br_En:%b ALU_A:%b ALU_B:%b Reg_W:%b M2R:%b",
                         rs1_o, rs2_o, imm_o, execution_alu_control_o, execution_branch_enable_o,
                         execution_control_alu_a_o, execution_control_alu_b_o, register_file_written_enable_o, write_back_mem_to_reg_o);
                $display("       Esperado -> RS1:0x%08h RS2:0x%08h IMM:0x%08h ALU_Op:%b Br_En:%b ALU_A:%b ALU_B:%b Reg_W:%b M2R:%b\n",
                         exp_rs1, exp_rs2, exp_imm, exp_alu_ctrl, exp_branch_en,
                         exp_alu_a, exp_alu_b, exp_reg_write, exp_mem_to_reg);
                fail_count++;
            end
        end
    endtask

    // =========================================================================
    // 5. SEQUÊNCIA DE TESTES
    // =========================================================================
    initial begin
        clk            = 1'b0;
        instruction_i  = 32'h0000_0000;
        written_data_i = 32'h0000_0000;

        // Inicializa x1..x31 para que leituras de campos nao usados pela
        // instrucao tambem tenham valores definidos durante as verificacoes.
        for (init_reg = 1; init_reg < 32; init_reg = init_reg + 1) begin
            @(negedge clk);
            instruction_i  = {12'b0, 5'b0, F3_ADDI, init_reg[4:0], OPCODE_OP_IMM};
            written_data_i = '0;
            @(posedge clk);
            #1;
        end

        $display("\n=========================================================================");
        $display("   INICIANDO BATERIA EXTENSA DE TESTES - MÓDULO DE DECODIFICAÇÃO         ");
        $display("=========================================================================\n");

        // ---------------------------------------------------------------------
        // SEÇÃO 1: PREENCHIMENTO E INICIALIZAÇÃO DE REGISTRADORES
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 01: Escrita em x1 (ADDI x1, x0, 100)
        instruction_i  = {12'b0000_0110_0100, 5'b00000, F3_ADDI, 5'b00001, OPCODE_OP_IMM};
        written_data_i = 32'd100;
        @(posedge clk);
        check_result(1, "Escrita em x1 via ADDI (+100)",
                     32'h0, 32'h0, 32'd100, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 02: Escrita em x2 (ADDI x2, x0, 200)
        instruction_i  = {12'b0000_1100_1000, 5'b00000, F3_ADDI, 5'b00010, OPCODE_OP_IMM};
        written_data_i = 32'd200;
        @(posedge clk);
        check_result(2, "Escrita em x2 via ADDI (+200)",
                     32'h0, 32'h0, 32'd200, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 03: Escrita em x4 com valor negativo (ADDI x4, x0, -50)
        instruction_i  = {12'b1111_1100_1110, 5'b00000, F3_ADDI, 5'b00100, OPCODE_OP_IMM};
        written_data_i = -32'd50;
        @(posedge clk);
        check_result(3, "Escrita em x4 via ADDI (-50)",
                     32'h0, 32'h0, 32'hFFFF_FFCE, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 2: OPERAÇÕES R-TYPE COM LEITURA DO BANCO DE REGISTRADORES
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 04: ADD x3, x1, x2
        instruction_i  = {F7_ADD, 5'b00010, 5'b00001, F3_ADD, 5'b00011, OPCODE_OP};
        written_data_i = 32'd300; // Escreve o resultado no posedge em x3
        @(posedge clk);
        check_result(4, "R-Type: ADD x3, x1, x2 (x1=100, x2=200)",
                     32'd100, 32'd200, 32'h0000_0002, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 05: SUB x5, x2, x1
        instruction_i  = {F7_SUB, 5'b00001, 5'b00010, F3_SUB, 5'b00101, OPCODE_OP};
        written_data_i = 32'd100; // Escreve 100 em x5
        @(posedge clk);
        check_result(5, "R-Type: SUB x5, x2, x1 (x2=200, x1=100)",
                     32'd200, 32'd100, 32'h0000_0401, OP_SUB, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 06: AND x6, x1, x4
        instruction_i  = {F7_AND, 5'b00100, 5'b00001, F3_AND, 5'b00110, OPCODE_OP};
        written_data_i = 32'h0000_0040;
        @(posedge clk);
        check_result(6, "R-Type: AND x6, x1, x4 (x1=100, x4=-50)",
                     32'd100, -32'd50, 32'h0000_0004, OP_AND, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 3: OPERAÇÕES I-TYPE COM SHIFTS E DECODIFICAÇÃO DE IMEDIATO
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 07: SRAI x7, x4, 2
        instruction_i  = {F7_SRAI, 5'b00010, 5'b00100, F3_SRAI, 5'b00111, OPCODE_OP_IMM};
        written_data_i = -32'd13;
        @(posedge clk);
        check_result(7, "I-Type: SRAI x7, x4, 2 (shamt=2)",
                     -32'd50, 32'd200, 32'h0000_0402, OP_SRA, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 08: XORI x8, x1, 0x0FF
        instruction_i  = {12'b0000_1111_1111, 5'b00001, F3_XORI, 5'b01000, OPCODE_OP_IMM};
        written_data_i = 32'h0000_009B;
        @(posedge clk);
        check_result(8, "I-Type: XORI x8, x1, 255",
                     32'd100, 32'd0, 32'h0000_00FF, OP_XOR, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 4: LEITURAS DE MEMÓRIA (LOADS - LB, LH, LW, LBU, LHU)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 09: LW x9, -4(x2)
        instruction_i  = {12'b1111_1111_1100, 5'b00010, F3_LW, 5'b01001, OPCODE_LOAD};
        written_data_i = 32'hDEAD_BEEF; // Simulação do retorno da memória
        @(posedge clk);
        check_result(9, "Load: LW x9, -4(x2)",
                     32'd200, 32'd0, 32'hFFFF_FFFC, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_SIGNED, 1'b1, 1'b1);

        @(negedge clk); // TESTE 10: LBU x10, 8(x1)
        instruction_i  = {12'b0000_0000_1000, 5'b00001, F3_LBU, 5'b01010, OPCODE_LOAD};
        written_data_i = 32'h0000_0080;
        @(posedge clk);
        check_result(10, "Load: LBU x10, 8(x1)",
                     32'd100, 32'h0000_009B, 32'h0000_0008, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_BYTE, MEM_UNSIGNED, 1'b1, 1'b1);

        // ---------------------------------------------------------------------
        // SEÇÃO 5: ESCRITAS NA MEMÓRIA (STORES - SB, SH, SW)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 11: SW x2, 16(x1)
        instruction_i  = {7'b0000000, 5'b00010, 5'b00001, F3_SW, 5'b10000, OPCODE_STORE};
        written_data_i = 32'h0000_0000; // reg_write desativado na SW
        @(posedge clk);
        check_result(11, "Store: SW x2, 16(x1)",
                     32'd100, 32'd200, 32'd16, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b1, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 12: SH x4, -2(x2)
        instruction_i  = {7'b1111111, 5'b00100, 5'b00010, F3_SH, 5'b11110, OPCODE_STORE};
        written_data_i = 32'h0000_0000;
        @(posedge clk);
        check_result(12, "Store: SH x4, -2(x2)",
                     32'd200, -32'd50, 32'hFFFF_FFFE, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b1, MEM_WIDTH_HALF, MEM_UNSIGNED, 1'b0, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 6: DESVIOS CONDICIONAIS (BRANCHES)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 13: BEQ x1, x5, +12 (100 == 100)
        instruction_i  = {1'b0, 6'b000000, 5'b00101, 5'b00001, F3_BEQ, 4'b0110, 1'b0, OPCODE_BRANCH};
        written_data_i = 32'h0000_0000;
        @(posedge clk);
        check_result(13, "Branch: BEQ x1, x5, +12",
                     32'd100, 32'd100, 32'd12, OP_CMP, OP_BCT, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 14: BNE x1, x2, -8 (100 != 200)
        instruction_i  = {1'b1, 6'b111111, 5'b00010, 5'b00001, F3_BNE, 4'b1100, 1'b1, OPCODE_BRANCH};
        written_data_i = 32'h0000_0000;
        @(posedge clk);
        check_result(14, "Branch: BNE x1, x2, -8",
                     32'd100, 32'd200, 32'hFFFF_FFF8, OP_CMP, OP_BCF, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 15: BLT x4, x1, +16 (-50 < 100)
        instruction_i  = {1'b0, 6'b000000, 5'b00001, 5'b00100, F3_BLT, 4'b1000, 1'b0, OPCODE_BRANCH};
        written_data_i = 32'h0000_0000;
        @(posedge clk);
        check_result(15, "Branch: BLT x4, x1, +16",
                     -32'd50, 32'd100, 32'd16, OP_SLT, OP_BCT, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 7: SALTOS INCONDICIONAIS E CARREGAMENTO SUPERIOR (JAL, JALR, LUI, AUIPC)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 16: JAL x1, +2048
        instruction_i  = {1'b0, 10'b0000000000, 1'b1, 8'b00000000, 5'b00001, OPCODE_JAL};
        written_data_i = 32'h0000_0104; // Endereço de retorno (PC + 4)
        @(posedge clk);
        check_result(16, "Jump: JAL x1, +2048",
                     32'd0, 32'd260, 32'd2048, OP_PASS_B, OP_BIP, 1'b1, 1'b0, 2'b10, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 17: JALR x1, 4(x2)
        instruction_i  = {12'b0000_0000_0100, 5'b00010, F3_JALR, 5'b00001, OPCODE_JALR};
        written_data_i = 32'h0000_0108;
        @(posedge clk);
        check_result(17, "Jump: JALR x1, 4(x2)",
                     32'd200, -32'd50, 32'd4, OP_PASS_B, OP_BIR, 1'b1, 1'b0, 2'b10, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 18: LUI x11, 0x12345
        instruction_i  = {20'h12345, 5'b01011, OPCODE_LUI};
        written_data_i = 32'h1234_5000;
        @(posedge clk);
        check_result(18, "Upper Imm: LUI x11, 0x12345",
                     32'h0000_009B, 32'd300, 32'h1234_5000, OP_PASS_B, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 19: AUIPC x12, 0x80000
        instruction_i  = {20'h80000, 5'b01100, OPCODE_AUIPC};
        written_data_i = 32'h8000_0000;
        @(posedge clk);
        check_result(19, "Upper Imm: AUIPC x12, 0x80000",
                     32'd0, 32'd0, 32'h8000_0000, OP_ADD, OP_BCT, 1'b0, 1'b1, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 8: VALIDAÇÃO DE PROTEÇÃO DO REGISTRADOR ZERO (x0)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 20: Escrita bloqueda em x0 (ADDI x0, x0, 500)
        instruction_i  = {12'b0001_1111_0100, 5'b00000, F3_ADDI, 5'b00000, OPCODE_OP_IMM};
        written_data_i = 32'd500;
        @(posedge clk);
        check_result(20, "Tentativa de escrita em x0 (deve manter 0)",
                     32'h0, 32'h0, 32'd500, OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        // =========================================================================
        // 6. RELATÓRIO FINAL
        // =========================================================================
        #10;
        $display("\n=========================================================================");
        $display("                           RELATÓRIO FINAL                               ");
        $display("=========================================================================");

        if (fail_count == 0) begin
            $display(" STATUS GERAL: >>> PASSOU (TODOS OS TESTES COM SUCESSO) <<<");
        end else begin
            $display(" STATUS GERAL: >>> FALHOU (%0d ERROS ENCONTRADOS) <<<", fail_count);
        end

        $display("=========================================================================\n");
        $finish;
    end

endmodule
