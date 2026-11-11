`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 05.10.2026 20:26:53
// Design Name: Processador RV32I
// Module Name: tb_execution
// Project Name:  processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Testbench automatizado da unidade de execucao RV32I.
// Dependencies: execution, alu_pkg, branch_pkg
// 
// Revision:
// Revision 0.02 - Reatribuicao explicita de entradas e comentarios nos controles
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_execution.sv
 * @brief Testbench da unidade de execucao.
 *
 * Exercita os seletores de operandos, operacoes da ALU e os quatro modos de
 * calculo/decisao de desvio. A task de verificacao compara o resultado da ALU,
 * o endereco de destino e o indicador de desvio tomado, acumulando falhas em
 * `fail_count`. A decisão dos desvios condicionais vem do comparador dedicado
 * (`rs1` × `rs2`), independente dos muxes e da operação da ALU; `OP_CMP` só
 * escolhe a igualdade no comparador (a ALU devolve 0 para ele).
 *
 * @param clk Clock de referencia usado para organizar os estimulos.
 * @param pc_next_i Endereco sequencial aplicado ao DUT.
 * @param pc_i Endereco atual aplicado ao DUT.
 * @param imm_i Imediato de teste.
 * @param reg_data1_i Operando de teste rs1.
 * @param reg_data2_i Operando de teste rs2.
 * @param alu_control_i Operacao de ALU selecionada no caso.
 * @param branch_control_i Modo de desvio selecionado no caso.
 * @param branch_enable_i Habilitacao de desvio aplicada ao DUT.
 * @param control_alu_a Seletor da entrada A da ALU.
 * @param control_alu_b Seletor da entrada B da ALU.
 * @retval pc_branch_o Endereco de desvio observado.
 * @retval alu_result_o Resultado da ALU observado.
 * @retval branch_taken_o Indicador de desvio tomado observado.
 * @retval mem_addr_o Endereco de load/store observado (rs1 + imm).
 * @retval mem_io_o Flag de MMIO observada (endereco em 0x4xxx_xxxx).
 * @retval mem_page0_o Flag dos primeiros 4 KiB observada (addr[31:12] == 0).
 */
import alu_pkg::*;
import branch_pkg::*;

// Importa os tipos da ULA
module tb_execution;


    // =========================================================================
    // 1. PARÂMETROS E SINAIS DE INTERFACE
    // =========================================================================
    localparam int XLEN = 32;

    logic            clk;
    
    // Entradas do DUT
    logic [XLEN-1:0]   pc_next_i;
    logic [XLEN-1:0]   pc_i;
    logic [XLEN-1:0]   imm_i;
    logic [XLEN-1:0]   reg_data1_i;
    logic [XLEN-1:0]   reg_data2_i;
    
    alu_op_t           alu_control_i;
    branch_op_t        branch_control_i;
    logic              branch_enable_i;
    logic              control_alu_a;
    logic [1:0]        control_alu_b;

    // Saídas do DUT
    logic [XLEN-1:0]   pc_branch_o;
    logic [XLEN-1:0]   alu_result_o;
    logic              branch_taken_o;
    logic [XLEN-1:0]   mem_addr_o;
    logic              mem_io_o;
    logic              mem_page0_o;

    // Controladora de falhas interna
    integer fail_count = 0;

    // =========================================================================
    // 2. INSTANCIAÇÃO DO DUT (Device Under Test)
    // =========================================================================
    execution #(
        .XLEN(XLEN)
    ) DUT (
        .pc_next_i       (pc_next_i),
        .pc_i            (pc_i),
        .imm_i           (imm_i),
        .reg_data1_i     (reg_data1_i),
        .reg_data2_i     (reg_data2_i),
        .alu_control_i   (alu_control_i),
        .branch_control_i(branch_control_i),
        .branch_enable_i (branch_enable_i),
        .control_alu_a   (control_alu_a),
        .control_alu_b   (control_alu_b),
        .pc_branch_o     (pc_branch_o),
        .alu_result_o    (alu_result_o),
        .branch_taken_o  (branch_taken_o),
        .mem_addr_o      (mem_addr_o),
        .mem_io_o        (mem_io_o),
        .mem_page0_o     (mem_page0_o)
    );
    import alu_pkg::*;
    import branch_pkg::*;


    // =========================================================================
    // 3. GERAÇÃO DO CLOCK (Período = 10ns)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. TASK DE COMPARAÇÃO
    // =========================================================================
    task automatic check_result(
        input int              test_num,
        input string           test_name, 
        input logic [XLEN-1:0] expected_alu_result,
        input logic [XLEN-1:0] expected_pc_branch,
        input logic            expected_branch_taken
    );
        begin
            #1; // Delay para estabilização da lógica combinacional
            
            if ((alu_result_o === expected_alu_result) && 
                (pc_branch_o   === expected_pc_branch) && 
                (branch_taken_o === expected_branch_taken)) begin
                $display("[PASS] Teste %02d: %-50s | ALU: 0x%08h | PC_BR: 0x%08h | TAKEN: %0b", 
                         test_num, test_name, alu_result_o, pc_branch_o, branch_taken_o);
            end else begin
                $display("[FAIL] Teste %02d: %-42s", test_num, test_name);
                $display("       ALU  -> Obtido: 0x%08h | Esperado: 0x%08h", alu_result_o, expected_alu_result);
                $display("       PC_BR-> Obtido: 0x%08h | Esperado: 0x%08h", pc_branch_o, expected_pc_branch);
                $display("       TAKEN-> Obtido: %0b          | Esperado: %0b \n", branch_taken_o, expected_branch_taken);
                fail_count++;
            end
        end
    endtask

    // Verifica o endereco de load/store (rs1 + imm), independente da ALU.
    task automatic check_mem_addr(
        input int              test_num,
        input string           test_name,
        input logic [XLEN-1:0] expected_mem_addr
    );
        begin
            #1;
            if (mem_addr_o === expected_mem_addr) begin
                $display("[PASS] Teste %02d: %-50s | MEM_ADDR: 0x%08h",
                         test_num, test_name, mem_addr_o);
            end else begin
                $display("[FAIL] Teste %02d: %-42s", test_num, test_name);
                $display("       MEM_ADDR -> Obtido: 0x%08h | Esperado: 0x%08h \n",
                         mem_addr_o, expected_mem_addr);
                fail_count++;
            end
        end
    endtask

    // Aplica rs1 e um imediato de 12 bits (estendido como em load/store) e
    // confere o endereco e as flags de regiao contra os valores esperados.
    task automatic check_mem_region(
        input int              test_num,
        input string           test_name,
        input logic [XLEN-1:0] rs1,
        input logic [11:0]     imm12,
        input logic [XLEN-1:0] expected_mem_addr,
        input logic            expected_io,
        input logic            expected_page0
    );
        begin
            @(negedge clk);
            reg_data1_i = rs1;
            imm_i       = {{20{imm12[11]}}, imm12};
            #1;
            if (mem_addr_o === expected_mem_addr && mem_io_o === expected_io &&
                mem_page0_o === expected_page0) begin
                $display("[PASS] Teste %02d: %-50s | MEM_ADDR: 0x%08h | IO: %0b | PAGE0: %0b",
                         test_num, test_name, mem_addr_o, mem_io_o, mem_page0_o);
            end else begin
                $display("[FAIL] Teste %02d: %-42s", test_num, test_name);
                $display("       MEM_ADDR -> Obtido: 0x%08h | Esperado: 0x%08h",
                         mem_addr_o, expected_mem_addr);
                $display("       IO/PAGE0 -> Obtido: %0b/%0b | Esperado: %0b/%0b \n",
                         mem_io_o, mem_page0_o, expected_io, expected_page0);
                fail_count++;
            end
        end
    endtask

    // =========================================================================
    // 5. SEQUÊNCIA DE TESTES
    // =========================================================================
    initial begin
        clk = 0;

        $display("\n=========================================================================");
        $display("       INICIANDO BATERIA DE TESTES - MÓDULO DE EXECUÇÃO (EXECUTION)      ");
        $display("=========================================================================\n");

        // ---------------------------------------------------------------------
        // SEÇÃO 1: TESTE DOS MULTIPLEXADORES DE ENTRADA DA ULA
        // ---------------------------------------------------------------------
        
        @(negedge clk); // TESTE 01
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Conteúdo do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conteúdo do registrador rs2 (5 em dec)
        alu_control_i    = OP_ADD;        // ULA: Operação de soma (A + B)
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1 (reg_data1_i)
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2 (reg_data2_i)
        check_result(1, "MUX ULA: reg1 + reg2", 32'd15, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 02
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Conteúdo do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conteúdo do registrador rs2 (5 em dec)
        alu_control_i    = OP_ADD;        // ULA: Operação de soma (A + B)
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1 (reg_data1_i)
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(2, "MUX ULA: reg1 + imm", 32'd42, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 03
        pc_i             = 32'h0000_1000; // Endereço atual do PC (0x1000)
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (0x20)
        reg_data1_i      = 32'h0000_000A; // Conteúdo do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conteúdo do registrador rs2 (5 em dec)
        alu_control_i    = OP_ADD;        // ULA: Operação de soma (A + B)
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b1;          // MUX A: Seleciona PC (pc_i)
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(3, "MUX ULA: pc + imm (AUIPC)", 32'h0000_1020, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 04
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço PC+4 (0x1004)
        imm_i            = 32'h0000_0020; // Valor imediato (0x20)
        reg_data1_i      = 32'h0000_000A; // Conteúdo do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conteúdo do registrador rs2 (5 em dec)
        alu_control_i    = OP_PASS_B;     // ULA: Passa entrada B diretamente para a saída
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1 (não utilizado em PASS_B)
        control_alu_b    = 2'b10;         // MUX B: Seleciona PC+4 (pc_next_i)
        check_result(4, "MUX ULA: PASS_B (pc_next)", 32'h0000_1004, 32'h0000_1020, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 2: TESTE DE TODAS AS OPERAÇÕES DA ULA (alu_op_t)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 05
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Operando A = 10
        reg_data2_i      = 32'h0000_0005; // Operando B = 5
        alu_control_i    = OP_ADD;        // ULA: Adição (10 + 5)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(5, "ULA OP_ADD: 10 + 5", 32'd15, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 06
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Operando A = 10
        reg_data2_i      = 32'h0000_0005; // Operando B = 5
        alu_control_i    = OP_SUB;        // ULA: Subtração (10 - 5)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(6, "ULA OP_SUB: 10 - 5", 32'd5, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 07
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'hF0F0_FFFF; // Operando A para lógica E
        reg_data2_i      = 32'h0F0F_FFFF; // Operando B para lógica E
        alu_control_i    = OP_AND;        // ULA: Operação E bit a bit (A & B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(7, "ULA OP_AND", 32'h0000_FFFF, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 08
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'hF0F0_FFFF; // Operando A para lógica OU
        reg_data2_i      = 32'h0F0F_FFFF; // Operando B para lógica OU
        alu_control_i    = OP_OR;         // ULA: Operação OU bit a bit (A | B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(8, "ULA OP_OR", 32'hFFFF_FFFF, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 09
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'hF0F0_FFFF; // Operando A para lógica XOR
        reg_data2_i      = 32'h0F0F_FFFF; // Operando B para lógica XOR
        alu_control_i    = OP_XOR;        // ULA: Operação OU Exclusivo bit a bit (A ^ B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(9, "ULA OP_XOR", 32'hFFFF_0000, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 10
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'h0000_0003; // Dado a ser deslocado (3 em dec)
        reg_data2_i      = 32'd4;         // Quantidade de posições a deslocar (4)
        alu_control_i    = OP_SLL;        // ULA: Deslocamento Lógico para a Esquerda (A << B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(10, "ULA OP_SLL: 3 << 4", 32'h0000_0030, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 11
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // Dado a ser deslocado (MSB = 1)
        reg_data2_i      = 32'd4;         // Quantidade de posições a deslocar (4)
        alu_control_i    = OP_SRL;        // ULA: Deslocamento Lógico para a Direita (A >> B sem extensão)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(11, "ULA OP_SRL: 0x80000000 >> 4", 32'h0800_0000, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 12
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // Dado a ser deslocado (negativo em compl. de 2)
        reg_data2_i      = 32'd4;         // Quantidade de posições a deslocar (4)
        alu_control_i    = OP_SRA;        // ULA: Deslocamento Aritmético para Direita (A >>> B com extensão de sinal)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;    // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(12, "ULA OP_SRA: 0x80000000 >>> 4", 32'hF800_0000, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 13
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = -32'd10;       // rs1 = -10 (com sinal)
        reg_data2_i      = 32'd5;         // rs2 = 5 (com sinal)
        alu_control_i    = OP_SLT;        // ULA: Menor que com sinal (A < B ? 1 : 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(13, "ULA OP_SLT: Signed (-10 < 5)", 32'd1, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 14
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'd5;         // rs1 = 5 (com sinal)
        reg_data2_i      = -32'd10;       // rs2 = -10 (com sinal)
        alu_control_i    = OP_SLT;        // ULA: Menor que com sinal (A < B ? 1 : 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(14, "ULA OP_SLT: Signed (5 < -10)", 32'd0, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 15
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'd5;         // rs1 = 5 (sem sinal)
        reg_data2_i      = 32'd10;        // rs2 = 10 (sem sinal)
        alu_control_i    = OP_SLTU;       // ULA: Menor que sem sinal (A < B ? 1 : 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(15, "ULA OP_SLTU: Unsigned (5 < 10)", 32'd1, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 16
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // rs1 = 2147483648 (sem sinal)
        reg_data2_i      = 32'd10;        // rs2 = 10 (sem sinal)
        alu_control_i    = OP_SLTU;       // ULA: Menor que sem sinal (A < B ? 1 : 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(16, "ULA OP_SLTU: Unsigned (0x80000000 < 10)", 32'd0, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 17
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h1234_5678; // Valor imediato a repassar
        reg_data1_i      = 32'h8000_0000; // Conteúdo de rs1 (ignorado)
        reg_data2_i      = 32'd10;        // Conteúdo de rs2 (ignorado)
        alu_control_i    = OP_PASS_B;     // ULA: Passa entrada B diretamente
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(17, "ULA OP_PASS_B: Passa Imm", 32'h1234_5678, 32'h1234_6678, 1'b0);

        @(negedge clk); // TESTE 18
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h1234_5678; // Valor imediato
        reg_data1_i      = 32'd100;       // rs1 = 100
        reg_data2_i      = 32'd100;       // rs2 = 100
        alu_control_i    = OP_CMP;        // Comparador: igualdade (a ALU devolve 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(18, "BEQ iguais (100 == 100) sem enable, ALU = 0", 32'd0, 32'h1234_6678, 1'b0);

        @(negedge clk); // TESTE 19
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h1234_5678; // Valor imediato
        reg_data1_i      = 32'd100;       // rs1 = 100
        reg_data2_i      = 32'd50;        // rs2 = 50
        alu_control_i    = OP_CMP;        // Comparador: igualdade (a ALU devolve 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(19, "BEQ diferentes (100 != 50) sem enable", 32'd0, 32'h1234_6678, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 3: TESTES DE DESVIOS E SALTOS (BRANCH E JUMP)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 20
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Próximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd100;       // Conteúdo de rs1
        reg_data2_i      = 32'd50;        // Conteúdo de rs2
        alu_control_i    = OP_CMP;        // ULA: Comparação
        branch_control_i = OP_BIP;        // Branch: Salto incondicional relativo ao PC (JAL)
        branch_enable_i  = 1'b0;          // Branch: DESABILITADO (Impede o salto)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(20, "Branch Desabilitado (branch_enable=0)", 32'd0, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 21
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Próximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd50;        // rs2 = 50
        alu_control_i    = OP_CMP;        // Comparador: igualdade (50 == 50)
        branch_control_i = OP_BCT;        // Branch: BEQ (toma se rs1 == rs2)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(21, "Branch 00: Condicional Verdadeiro (Tomado)", 32'd0, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 22
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Próximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd30;        // rs2 = 30
        alu_control_i    = OP_CMP;        // Comparador: igualdade (50 != 30)
        branch_control_i = OP_BCT;        // Branch: BEQ (toma se rs1 == rs2)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(22, "Branch 00: Condicional Falso (Nao Tomado)", 32'd0, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 23
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Próximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd30;        // rs2 = 30
        alu_control_i    = OP_CMP;        // Comparador: igualdade (50 != 30)
        branch_control_i = OP_BCF;        // Branch: BNE (toma se rs1 != rs2)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(23, "Branch 01: BNE em valores diferentes (Tomado)", 32'd0, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 24
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Próximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd50;        // rs2 = 50
        alu_control_i    = OP_CMP;        // Comparador: igualdade (50 == 50)
        branch_control_i = OP_BCF;        // Branch: BNE (toma se rs1 != rs2)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(24, "Branch 01: BNE em valores iguais (Nao Tomado)", 32'd0, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 25
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Próximo PC
        imm_i            = 32'h0000_0040; // Imediato (0x40 -> Alvo PC+Imm = 0x240)
        reg_data1_i      = 32'd50;        // Conteúdo de rs1
        reg_data2_i      = 32'd50;        // Conteúdo de rs2
        alu_control_i    = OP_CMP;        // ULA: Operação
        branch_control_i = OP_BIP;        // Branch: JAL (Salto incondicional PC + Imediato)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(25, "Jump 10: Incondicional PC + Imm (JAL)", 32'd0, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 26
        pc_i             = 32'h0000_0200; // PC base
        pc_next_i        = 32'h0000_1004; // Próximo PC
        imm_i            = 32'h0000_0004; // Imediato (0x4)
        reg_data1_i      = 32'h0000_0501; // rs1 = 0x501 (ímpar para testar máscara &~1 -> Alvo 0x504)
        reg_data2_i      = 32'd50;        // Conteúdo de rs2
        alu_control_i    = OP_CMP;        // ULA: Operação
        branch_control_i = OP_BIR;        // Branch: JALR (Salto incondicional rs1 + Imediato com alinhamento)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(26, "Jump 11: Incondicional rs1 + Imm (JALR + Mascara &~1)", 32'd0, 32'h0000_0504, 1'b1);

         // ---------------------------------------------------------------------
        // SEÇÃO 4: TESTES ADICIONAIS DE CASOS LIMITE (EDGE CASES)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 27: Shift com shamt > 31
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0000; // Valor imediato
        reg_data1_i      = 32'h0000_0001; // Dado a ser deslocado (1)
        reg_data2_i      = 32'd36;        // Quantidade de shift = 36 (Apenas bits [4:0] valem -> 36 % 32 = 4)
        alu_control_i    = OP_SLL;        // ULA: Deslocamento Lógico Esquerda (A << B[4:0])
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(27, "ULA OP_SLL: shamt > 31 (36 -> shift 4)", 32'h0000_0010, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 28: Branch com deslocamento negativo (Loop)
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = -32'd16;       // Offset de -16 bytes (32'hFFFF_FFF0)
        reg_data1_i      = 32'd10;        // rs1 = 10
        reg_data2_i      = 32'd10;        // rs2 = 10
        alu_control_i    = OP_CMP;        // Comparador: igualdade (10 == 10)
        branch_control_i = OP_BCT;        // Branch: BEQ (toma se rs1 == rs2)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(28, "Branch BEQ: Salto negativo no PC (Loop)", 32'd0, 32'h0000_0FF0, 1'b1);

        @(negedge clk); // TESTE 29: JALR com imediato negativo
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = -32'd5;        // Imediato negativo (-5 -> 32'hFFFF_FFFB)
        reg_data1_i      = 32'h0000_1003; // rs1 = 0x1003 (0x1003 - 5 = 0x0FFE)
        reg_data2_i      = 32'h0000_0000; // Conteúdo de rs2 (ignorado)
        alu_control_i    = OP_CMP;        // ULA: Operação
        branch_control_i = OP_BIR;        // Branch: JALR (rs1 + Imm com máscara &~1)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(29, "JALR: rs1 + Imm Negativo com Mascara", 32'd0, 32'h0000_0FFE, 1'b1);

        @(negedge clk); // TESTE 30: Overflow Positivo -> Negativo
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0001; // Valor imediato
        reg_data1_i      = 32'h7FFF_FFFF; // Maior inteiro positivo de 32 bits
        reg_data2_i      = 32'h0000_0001; // Valor 1
        alu_control_i    = OP_ADD;        // ULA: Soma com overflow (0x7FFFFFFF + 1 = 0x80000000)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(30, "ULA OP_ADD: Overflow 0x7FFFFFFF + 1", 32'h8000_0000, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 31: Underflow Negativo -> Positivo
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0001; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // Menor inteiro negativo de 32 bits
        reg_data2_i      = 32'h0000_0001; // Valor 1
        alu_control_i    = OP_SUB;        // ULA: Subtração com underflow (0x80000000 - 1 = 0x7FFFFFFF)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(31, "ULA OP_SUB: Underflow 0x80000000 - 1", 32'h7FFF_FFFF, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 32: SLT Signed extremo
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0000; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // rs1 = -2147483648
        reg_data2_i      = 32'h7FFF_FFFF; // rs2 = +2147483647
        alu_control_i    = OP_SLT;        // ULA: Menor que com sinal (-2147483648 < +2147483647 -> 1)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(32, "ULA OP_SLT: 0x80000000 < 0x7FFFFFFF (Signed)", 32'd1, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 33: SLTU Unsigned extremo
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0000; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // rs1 = 2147483648 (sem sinal)
        reg_data2_i      = 32'h7FFF_FFFF; // rs2 = 2147483647 (sem sinal)
        alu_control_i    = OP_SLTU;       // ULA: Menor que sem sinal (2147483648 < 2147483647 -> 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(33, "ULA OP_SLTU: 0x80000000 < 0x7FFFFFFF (Unsigned)", 32'd0, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 34: Instrução NOP (ADDI x0, x0, 0)
        pc_i             = 32'h0000_1000; // Endereço atual do PC
        pc_next_i        = 32'h0000_1004; // Próximo endereço (PC + 4)
        imm_i            = 32'h0000_0000; // Imediato = 0
        reg_data1_i      = 32'h0000_0000; // rs1 = 0 (x0)
        reg_data2_i      = 32'h0000_0000; // rs2 = 0
        alu_control_i    = OP_ADD;        // ULA: Soma (0 + 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(34, "NOP (ADDI x0, x0, 0)", 32'h0000_0000, 32'h0000_1000, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 5: ENDEREÇO DE LOAD/STORE (mem_addr_o = rs1 + imm)
        // Independe da operação da ALU e do MUX B (somador dedicado).
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 35: offset positivo, MUX B em rs2
        imm_i            = 32'h0000_0008;
        reg_data1_i      = 32'h0000_0100;
        reg_data2_i      = 32'h0000_0055;
        alu_control_i    = OP_AND;
        branch_enable_i  = 1'b0;
        control_alu_a    = 1'b1;          // MUX A: PC (não afeta o endereço)
        control_alu_b    = 2'b00;         // MUX B: rs2 (não afeta o endereço)
        check_mem_addr(35, "MEM_ADDR: 0x100 + 8 (ALU em AND)", 32'h0000_0108);

        @(negedge clk); // TESTE 36: offset negativo
        imm_i            = -32'd4;
        reg_data1_i      = 32'h0000_0100;
        alu_control_i    = OP_ADD;
        control_alu_a    = 1'b0;
        control_alu_b    = 2'b01;
        check_mem_addr(36, "MEM_ADDR: 0x100 + (-4)", 32'h0000_00FC);

        @(negedge clk); // TESTE 37: endereço MMIO (display de 7 segmentos)
        imm_i            = 32'h0000_000C;
        reg_data1_i      = 32'h4000_0000;
        alu_control_i    = OP_SLL;
        control_alu_b    = 2'b10;         // MUX B: PC+4 (não afeta o endereço)
        check_mem_addr(37, "MEM_ADDR: 0x40000000 + 0xC (MMIO)", 32'h4000_000C);

        @(negedge clk); // TESTE 38: estouro em 32 bits
        imm_i            = 32'h0000_0010;
        reg_data1_i      = 32'hFFFF_FFF8;
        alu_control_i    = OP_PASS_B;
        control_alu_b    = 2'b00;
        check_mem_addr(38, "MEM_ADDR: 0xFFFFFFF8 + 0x10 (wrap)", 32'h0000_0008);

        // ---------------------------------------------------------------------
        // SEÇÃO 6: FLAGS DE REGIÃO (mem_io_o, mem_page0_o)
        // Calculadas sem esperar o carry do somador; o imediato cruza as
        // fronteiras RAM/fora/MMIO nos dois sentidos.
        // ---------------------------------------------------------------------
        check_mem_region(39, "REGIAO: 0xFFC + 4 -> 0x1000 (fora)",
                         32'h0000_0FFC, 12'h004, 32'h0000_1000, 1'b0, 1'b0);
        check_mem_region(40, "REGIAO: 0x1000 - 4 -> 0xFFC (RAM)",
                         32'h0000_1000, 12'hFFC, 32'h0000_0FFC, 1'b0, 1'b1);
        check_mem_region(41, "REGIAO: 0xFFFFFFFC + 4 -> 0 (RAM, estouro)",
                         32'hFFFF_FFFC, 12'h004, 32'h0000_0000, 1'b0, 1'b1);
        check_mem_region(42, "REGIAO: 0 - 4 -> 0xFFFFFFFC (fora)",
                         32'h0000_0000, 12'hFFC, 32'hFFFF_FFFC, 1'b0, 1'b0);
        check_mem_region(43, "REGIAO: 0x3FFFFFF0 + 0x10 -> MMIO",
                         32'h3FFF_FFF0, 12'h010, 32'h4000_0000, 1'b1, 1'b0);
        check_mem_region(44, "REGIAO: 0x40000000 - 4 -> 0x3FFFFFFC (fora)",
                         32'h4000_0000, 12'hFFC, 32'h3FFF_FFFC, 1'b0, 1'b0);
        check_mem_region(45, "REGIAO: 0x4FFFFFFC + 4 -> 0x50000000 (fora)",
                         32'h4FFF_FFFC, 12'h004, 32'h5000_0000, 1'b0, 1'b0);
        check_mem_region(46, "REGIAO: 0x50000004 - 8 -> 0x4FFFFFFC (MMIO)",
                         32'h5000_0004, 12'hFF8, 32'h4FFF_FFFC, 1'b1, 1'b0);
        check_mem_region(47, "REGIAO: 0x40000010 + 0x7FF (MMIO)",
                         32'h4000_0010, 12'h7FF, 32'h4000_080F, 1'b1, 1'b0);
        check_mem_region(48, "REGIAO: 0x800 - 0x800 -> 0 (RAM)",
                         32'h0000_0800, 12'h800, 32'h0000_0000, 1'b0, 1'b1);

        // TESTE 49: vetores aleatórios contra a referência rs1 + sext(imm),
        // com rs1[31:12] concentrado nas fronteiras de região.
        begin
            logic [19:0]     hi_borda [7];
            logic [XLEN-1:0] rs1, addr;
            logic [11:0]     imm12;
            logic            ref_io, ref_page0;
            int              erros;

            hi_borda = '{20'h00000, 20'h00001, 20'hFFFFF, 20'h3FFFF,
                         20'h40000, 20'h4FFFF, 20'h50000};
            erros    = 0;
            for (int n = 0; n < 5000; n++) begin
                rs1   = $urandom;
                if (n % 2 == 0) rs1[31:12] = hi_borda[$urandom_range(6)];
                imm12 = $urandom;
                addr  = rs1 + {{20{imm12[11]}}, imm12};
                ref_io    = (addr[31:28] == 4'h4);
                ref_page0 = (addr[31:12] == 20'h0);

                @(negedge clk);
                reg_data1_i = rs1;
                imm_i       = {{20{imm12[11]}}, imm12};
                #1;
                if (mem_addr_o !== addr || mem_io_o !== ref_io || mem_page0_o !== ref_page0) begin
                    if (erros < 5)
                        $display("       rs1=0x%08h imm=0x%03h -> addr 0x%08h io/page0 %0b/%0b (esperado 0x%08h %0b/%0b)",
                                 rs1, imm12, mem_addr_o, mem_io_o, mem_page0_o, addr, ref_io, ref_page0);
                    erros++;
                end
            end

            if (erros == 0) begin
                $display("[PASS] Teste 49: %-50s | 5000 vetores", "REGIAO: aleatorio contra rs1 + sext(imm)");
            end else begin
                $display("[FAIL] Teste 49: REGIAO: aleatorio contra rs1 + sext(imm) | %0d erros", erros);
                fail_count++;
            end
        end

        // ---------------------------------------------------------------------
        // SEÇÃO 7: COMPARADOR DE DESVIO (rs1 × rs2, sem a ALU)
        // A condição dos desvios compara rs1 com rs2 direto; os muxes A/B e a
        // ALU não influem. alu_control escolhe a comparação: OP_SLT (com
        // sinal), OP_SLTU (sem sinal) ou igualdade (OP_CMP).
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 50: MUX B no imediato não afeta o BEQ
        pc_i             = 32'h0000_0200; // Alvo: 0x200 + 0x40 = 0x240
        pc_next_i        = 32'h0000_0204;
        imm_i            = 32'h0000_0040; // B = imediato, diferente de rs2
        reg_data1_i      = 32'd7;
        reg_data2_i      = 32'd7;
        alu_control_i    = OP_CMP;
        branch_control_i = OP_BCT;        // BEQ
        branch_enable_i  = 1'b1;
        control_alu_a    = 1'b0;          // MUX A: rs1
        control_alu_b    = 2'b01;         // MUX B: imediato
        check_result(50, "Comparador: BEQ rs1 == rs2 com MUX B no imediato", 32'd0, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 51: MUX A no PC não afeta o BEQ
        reg_data1_i      = 32'd5;
        reg_data2_i      = 32'h0000_0200; // igual ao PC, diferente de rs1
        control_alu_a    = 1'b1;          // MUX A: PC
        control_alu_b    = 2'b00;         // MUX B: rs2
        check_result(51, "Comparador: BEQ rs1 != rs2 com MUX A no PC", 32'd0, 32'h0000_0240, 1'b0);

        // Fronteira de sinal: 0x80000000 é o menor com sinal e maior sem sinal.
        @(negedge clk); // TESTE 52
        reg_data1_i      = 32'h8000_0000;
        reg_data2_i      = 32'h7FFF_FFFF;
        control_alu_a    = 1'b0;
        control_alu_b    = 2'b00;
        alu_control_i    = OP_SLT;
        branch_control_i = OP_BCT;        // BLT
        check_result(52, "Comparador: BLT 0x80000000 < 0x7FFFFFFF (tomado)", 32'd1, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 53
        branch_control_i = OP_BCF;        // BGE
        check_result(53, "Comparador: BGE 0x80000000 >= 0x7FFFFFFF (nao)", 32'd1, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 54
        alu_control_i    = OP_SLTU;
        branch_control_i = OP_BCT;        // BLTU
        check_result(54, "Comparador: BLTU 0x80000000 < 0x7FFFFFFF (nao)", 32'd0, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 55
        branch_control_i = OP_BCF;        // BGEU
        check_result(55, "Comparador: BGEU 0x80000000 >= 0x7FFFFFFF (tomado)", 32'd0, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 56: -1 × 0
        reg_data1_i      = 32'hFFFF_FFFF;
        reg_data2_i      = 32'h0000_0000;
        alu_control_i    = OP_SLT;
        branch_control_i = OP_BCT;        // BLT
        check_result(56, "Comparador: BLT -1 < 0 (tomado)", 32'd1, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 57
        alu_control_i    = OP_SLTU;       // BLTU: 0xFFFFFFFF < 0 é falso
        check_result(57, "Comparador: BLTU 0xFFFFFFFF < 0 (nao)", 32'd0, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 58: iguais no BGE (não é menor -> tomado)
        reg_data1_i      = 32'h8000_0000;
        reg_data2_i      = 32'h8000_0000;
        alu_control_i    = OP_SLT;
        branch_control_i = OP_BCF;        // BGE
        check_result(58, "Comparador: BGE iguais (tomado)", 32'd0, 32'h0000_0240, 1'b1);

        // TESTE 59: vetores aleatórios contra um modelo do comparador. rs2 = rs1
        // em 1/4 dos vetores e só o bit de sinal diferente em outro 1/4; muxes,
        // imediato e PC aleatórios (não podem influir na decisão).
        begin
            alu_op_t         ops [3];
            logic [XLEN-1:0] rs1, rs2;
            logic            cond, ref_taken;
            int              erros;

            ops   = '{OP_CMP, OP_SLT, OP_SLTU};
            erros = 0;
            for (int n = 0; n < 2000; n++) begin
                rs1 = $urandom;
                case (n % 4)
                    0:       rs2 = rs1;
                    1:       rs2 = rs1 ^ 32'h8000_0000;
                    default: rs2 = $urandom;
                endcase

                @(negedge clk);
                reg_data1_i      = rs1;
                reg_data2_i      = rs2;
                alu_control_i    = ops[$urandom_range(2)];
                branch_control_i = ($urandom_range(1) == 1) ? OP_BCF : OP_BCT;
                branch_enable_i  = 1'b1;
                control_alu_a    = $urandom_range(1);
                control_alu_b    = $urandom_range(2);
                imm_i            = $urandom;
                pc_i             = $urandom;
                pc_next_i        = $urandom;

                case (alu_control_i)
                    OP_SLT:  cond = ($signed(rs1) < $signed(rs2));
                    OP_SLTU: cond = (rs1 < rs2);
                    default: cond = (rs1 == rs2);
                endcase
                ref_taken = (branch_control_i == OP_BCT) ? cond : ~cond;

                #1;
                if (branch_taken_o !== ref_taken) begin
                    if (erros < 5)
                        $display("       rs1=0x%08h rs2=0x%08h %s %s A=%0b B=%0d -> taken %0b (esperado %0b)",
                                 rs1, rs2, alu_control_i.name(), branch_control_i.name(),
                                 control_alu_a, control_alu_b, branch_taken_o, ref_taken);
                    erros++;
                end
            end

            if (erros == 0) begin
                $display("[PASS] Teste 59: %-50s | 2000 vetores", "Comparador: aleatorio contra o modelo");
            end else begin
                $display("[FAIL] Teste 59: Comparador: aleatorio contra o modelo | %0d erros", erros);
                fail_count++;
            end
        end


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
            $display(" STATUS GERAL: >>> FALHOU <<<");
        end

        $display("=========================================================================\n");
        $finish;
    end

endmodule
