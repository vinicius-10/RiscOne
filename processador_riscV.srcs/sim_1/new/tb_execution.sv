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
 * `fail_count`.
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
 */
import alu_pkg::*;
import branch_pkg::*;

// Importa os tipos da ULA
module tb_execution;


    // =========================================================================
    // 1. PAR?METROS E SINAIS DE INTERFACE
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

    // Sa?das do DUT
    logic [XLEN-1:0]   pc_branch_o;
    logic [XLEN-1:0]   alu_result_o;
    logic              branch_taken_o;

    // Controladora de falhas interna
    integer fail_count = 0;

    // =========================================================================
    // 2. INSTANCIA??O DO DUT (Device Under Test)
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
        .branch_taken_o  (branch_taken_o)
    );
    import alu_pkg::*;
    import branch_pkg::*;


    // =========================================================================
    // 3. GERA??O DO CLOCK (Per?odo = 10ns)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. TASK DE COMPARA??O
    // =========================================================================
    task automatic check_result(
        input int              test_num,
        input string           test_name, 
        input logic [XLEN-1:0] expected_alu_result,
        input logic [XLEN-1:0] expected_pc_branch,
        input logic            expected_branch_taken
    );
        begin
            #1; // Delay para estabiliza??o da l?gica combinacional
            
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

    // =========================================================================
    // 5. SEQU?NCIA DE TESTES
    // =========================================================================
    initial begin
        clk = 0;

        $display("\n=========================================================================");
        $display("       INICIANDO BATERIA DE TESTES - M?DULO DE EXECU??O (EXECUTION)      ");
        $display("=========================================================================\n");

        // ---------------------------------------------------------------------
        // SE??O 1: TESTE DOS MULTIPLEXADORES DE ENTRADA DA ULA
        // ---------------------------------------------------------------------
        
        @(negedge clk); // TESTE 01
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Conte?do do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conte?do do registrador rs2 (5 em dec)
        alu_control_i    = OP_ADD;        // ULA: Opera??o de soma (A + B)
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1 (reg_data1_i)
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2 (reg_data2_i)
        check_result(1, "MUX ULA: reg1 + reg2", 32'd15, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 02
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Conte?do do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conte?do do registrador rs2 (5 em dec)
        alu_control_i    = OP_ADD;        // ULA: Opera??o de soma (A + B)
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1 (reg_data1_i)
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(2, "MUX ULA: reg1 + imm", 32'd42, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 03
        pc_i             = 32'h0000_1000; // Endere?o atual do PC (0x1000)
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (0x20)
        reg_data1_i      = 32'h0000_000A; // Conte?do do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conte?do do registrador rs2 (5 em dec)
        alu_control_i    = OP_ADD;        // ULA: Opera??o de soma (A + B)
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b1;          // MUX A: Seleciona PC (pc_i)
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(3, "MUX ULA: pc + imm (AUIPC)", 32'h0000_1020, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 04
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o PC+4 (0x1004)
        imm_i            = 32'h0000_0020; // Valor imediato (0x20)
        reg_data1_i      = 32'h0000_000A; // Conte?do do registrador rs1 (10 em dec)
        reg_data2_i      = 32'h0000_0005; // Conte?do do registrador rs2 (5 em dec)
        alu_control_i    = OP_PASS_B;     // ULA: Passa entrada B diretamente para a sa?da
        branch_control_i = OP_BCT;        // Branch: Condicional igualdade (BEQ)
        branch_enable_i  = 1'b0;          // Branch: Desativado (enable = 0)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1 (n?o utilizado em PASS_B)
        control_alu_b    = 2'b10;         // MUX B: Seleciona PC+4 (pc_next_i)
        check_result(4, "MUX ULA: PASS_B (pc_next)", 32'h0000_1004, 32'h0000_1020, 1'b0);

        // ---------------------------------------------------------------------
        // SE??O 2: TESTE DE TODAS AS OPERA??ES DA ULA (alu_op_t)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 05
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Operando A = 10
        reg_data2_i      = 32'h0000_0005; // Operando B = 5
        alu_control_i    = OP_ADD;        // ULA: Adi??o (10 + 5)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(5, "ULA OP_ADD: 10 + 5", 32'd15, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 06
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato (32 em dec)
        reg_data1_i      = 32'h0000_000A; // Operando A = 10
        reg_data2_i      = 32'h0000_0005; // Operando B = 5
        alu_control_i    = OP_SUB;        // ULA: Subtra??o (10 - 5)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(6, "ULA OP_SUB: 10 - 5", 32'd5, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 07
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'hF0F0_FFFF; // Operando A para l?gica E
        reg_data2_i      = 32'h0F0F_FFFF; // Operando B para l?gica E
        alu_control_i    = OP_AND;        // ULA: Opera??o E bit a bit (A & B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(7, "ULA OP_AND", 32'h0000_FFFF, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 08
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'hF0F0_FFFF; // Operando A para l?gica OU
        reg_data2_i      = 32'h0F0F_FFFF; // Operando B para l?gica OU
        alu_control_i    = OP_OR;         // ULA: Opera??o OU bit a bit (A | B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(8, "ULA OP_OR", 32'hFFFF_FFFF, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 09
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'hF0F0_FFFF; // Operando A para l?gica XOR
        reg_data2_i      = 32'h0F0F_FFFF; // Operando B para l?gica XOR
        alu_control_i    = OP_XOR;        // ULA: Opera??o OU Exclusivo bit a bit (A ^ B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(9, "ULA OP_XOR", 32'hFFFF_0000, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 10
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'h0000_0003; // Dado a ser deslocado (3 em dec)
        reg_data2_i      = 32'd4;         // Quantidade de posi??es a deslocar (4)
        alu_control_i    = OP_SLL;        // ULA: Deslocamento L?gico para a Esquerda (A << B)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(10, "ULA OP_SLL: 3 << 4", 32'h0000_0030, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 11
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // Dado a ser deslocado (MSB = 1)
        reg_data2_i      = 32'd4;         // Quantidade de posi??es a deslocar (4)
        alu_control_i    = OP_SRL;        // ULA: Deslocamento L?gico para a Direita (A >> B sem extens?o)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(11, "ULA OP_SRL: 0x80000000 >> 4", 32'h0800_0000, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 12
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0020; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // Dado a ser deslocado (negativo em compl. de 2)
        reg_data2_i      = 32'd4;         // Quantidade de posi??es a deslocar (4)
        alu_control_i    = OP_SRA;        // ULA: Deslocamento Aritm?tico para Direita (A >>> B com extens?o de sinal)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;    // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(12, "ULA OP_SRA: 0x80000000 >>> 4", 32'hF800_0000, 32'h0000_1020, 1'b0);

        @(negedge clk); // TESTE 13
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
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
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
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
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
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
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
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
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h1234_5678; // Valor imediato a repassar
        reg_data1_i      = 32'h8000_0000; // Conte?do de rs1 (ignorado)
        reg_data2_i      = 32'd10;        // Conte?do de rs2 (ignorado)
        alu_control_i    = OP_PASS_B;     // ULA: Passa entrada B diretamente
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(17, "ULA OP_PASS_B: Passa Imm", 32'h1234_5678, 32'h1234_6678, 1'b0);

        @(negedge clk); // TESTE 18
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h1234_5678; // Valor imediato
        reg_data1_i      = 32'd100;       // rs1 = 100
        reg_data2_i      = 32'd100;       // rs2 = 100
        alu_control_i    = OP_CMP;        // ULA: Compara??o de igualdade (A == B ? 1 : 0)
        branch_control_i = OP_BCT;  // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(18, "ULA OP_CMP: Iguais (100 == 100)", 32'd1, 32'h1234_6678, 1'b0);

        @(negedge clk); // TESTE 19
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h1234_5678; // Valor imediato
        reg_data1_i      = 32'd100;       // rs1 = 100
        reg_data2_i      = 32'd50;        // rs2 = 50
        alu_control_i    = OP_CMP;        // ULA: Compara??o de igualdade (A == B ? 1 : 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(19, "ULA OP_CMP: Diferentes (100 == 50)", 32'd0, 32'h1234_6678, 1'b0);

        // ---------------------------------------------------------------------
        // SE??O 3: TESTES DE DESVIOS E SALTOS (BRANCH E JUMP)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 20
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Pr?ximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd100;       // Conte?do de rs1
        reg_data2_i      = 32'd50;        // Conte?do de rs2
        alu_control_i    = OP_CMP;        // ULA: Compara??o
        branch_control_i = OP_BIP;        // Branch: Salto incondicional relativo ao PC (JAL)
        branch_enable_i  = 1'b0;          // Branch: DESABILITADO (Impede o salto)
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(20, "Branch Desabilitado (branch_enable=0)", 32'd0, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 21
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Pr?ximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd50;        // rs2 = 50
        alu_control_i    = OP_CMP;        // ULA: Compara??o de igualdade (50 == 50 -> 1)
        branch_control_i = OP_BCT;        // Branch: BEQ (Toma desvio se resultado da ULA == 1)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(21, "Branch 00: Condicional Verdadeiro (Tomado)", 32'd1, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 22
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Pr?ximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd30;        // rs2 = 30
        alu_control_i    = OP_CMP;        // ULA: Compara??o de igualdade (50 == 30 -> 0)
        branch_control_i = OP_BCT;        // Branch: BEQ (Toma desvio apenas se ULA == 1)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(22, "Branch 00: Condicional Falso (Nao Tomado)", 32'd0, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 23
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Pr?ximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd30;        // rs2 = 30
        alu_control_i    = OP_CMP;        // ULA: Compara??o de igualdade (Diferentes -> 0)
        branch_control_i = OP_BCF;         // Branch: BNE (Toma desvio se resultado da ULA == 0)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(23, "Branch 01: BNE em valores diferentes (Tomado)", 32'd0, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 24
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Pr?ximo PC
        imm_i            = 32'h0000_0040; // Imediato de desvio (0x40 -> Alvo 0x240)
        reg_data1_i      = 32'd50;        // rs1 = 50
        reg_data2_i      = 32'd50;        // rs2 = 50
        alu_control_i    = OP_CMP;        // ULA: Compara??o de igualdade (Iguais -> 1)
        branch_control_i = OP_BCF;        // Branch: BNE (Toma desvio apenas se ULA == 0)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(24, "Branch 01: BNE em valores iguais (Nao Tomado)", 32'd1, 32'h0000_0240, 1'b0);

        @(negedge clk); // TESTE 25
        pc_i             = 32'h0000_0200; // PC base para desvio (0x200)
        pc_next_i        = 32'h0000_1004; // Pr?ximo PC
        imm_i            = 32'h0000_0040; // Imediato (0x40 -> Alvo PC+Imm = 0x240)
        reg_data1_i      = 32'd50;        // Conte?do de rs1
        reg_data2_i      = 32'd50;        // Conte?do de rs2
        alu_control_i    = OP_CMP;        // ULA: Opera??o
        branch_control_i = OP_BIP;        // Branch: JAL (Salto incondicional PC + Imediato)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(25, "Jump 10: Incondicional PC + Imm (JAL)", 32'd1, 32'h0000_0240, 1'b1);

        @(negedge clk); // TESTE 26
        pc_i             = 32'h0000_0200; // PC base
        pc_next_i        = 32'h0000_1004; // Pr?ximo PC
        imm_i            = 32'h0000_0004; // Imediato (0x4)
        reg_data1_i      = 32'h0000_0501; // rs1 = 0x501 (?mpar para testar m?scara &~1 -> Alvo 0x504)
        reg_data2_i      = 32'd50;        // Conte?do de rs2
        alu_control_i    = OP_CMP;        // ULA: Opera??o
        branch_control_i = OP_BIR;        // Branch: JALR (Salto incondicional rs1 + Imediato com alinhamento)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(26, "Jump 11: Incondicional rs1 + Imm (JALR + Mascara &~1)", 32'd0, 32'h0000_0504, 1'b1);

         // ---------------------------------------------------------------------
        // SE??O 4: TESTES ADICIONAIS DE CASOS LIMITE (EDGE CASES)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 27: Shift com shamt > 31
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0000; // Valor imediato
        reg_data1_i      = 32'h0000_0001; // Dado a ser deslocado (1)
        reg_data2_i      = 32'd36;        // Quantidade de shift = 36 (Apenas bits [4:0] valem -> 36 % 32 = 4)
        alu_control_i    = OP_SLL;        // ULA: Deslocamento L?gico Esquerda (A << B[4:0])
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(27, "ULA OP_SLL: shamt > 31 (36 -> shift 4)", 32'h0000_0010, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 28: Branch com deslocamento negativo (Loop)
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = -32'd16;       // Offset de -16 bytes (32'hFFFF_FFF0)
        reg_data1_i      = 32'd10;        // rs1 = 10
        reg_data2_i      = 32'd10;        // rs2 = 10
        alu_control_i    = OP_CMP;        // ULA: Compara??o de igualdade (10 == 10 -> 1)
        branch_control_i = OP_BCT;        // Branch: BEQ (Toma desvio se ULA == 1)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(28, "Branch BEQ: Salto negativo no PC (Loop)", 32'd1, 32'h0000_0FF0, 1'b1);

        @(negedge clk); // TESTE 29: JALR com imediato negativo
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = -32'd5;        // Imediato negativo (-5 -> 32'hFFFF_FFFB)
        reg_data1_i      = 32'h0000_1003; // rs1 = 0x1003 (0x1003 - 5 = 0x0FFE)
        reg_data2_i      = 32'h0000_0000; // Conte?do de rs2 (ignorado)
        alu_control_i    = OP_CMP;        // ULA: Opera??o
        branch_control_i = OP_BIR;        // Branch: JALR (rs1 + Imm com m?scara &~1)
        branch_enable_i  = 1'b1;          // Branch: HABILITADO
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(29, "JALR: rs1 + Imm Negativo com Mascara", 32'd0, 32'h0000_0FFE, 1'b1);

        @(negedge clk); // TESTE 30: Overflow Positivo -> Negativo
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
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
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0001; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // Menor inteiro negativo de 32 bits
        reg_data2_i      = 32'h0000_0001; // Valor 1
        alu_control_i    = OP_SUB;        // ULA: Subtra??o com underflow (0x80000000 - 1 = 0x7FFFFFFF)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(31, "ULA OP_SUB: Underflow 0x80000000 - 1", 32'h7FFF_FFFF, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 32: SLT Signed extremo
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
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
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0000; // Valor imediato
        reg_data1_i      = 32'h8000_0000; // rs1 = 2147483648 (sem sinal)
        reg_data2_i      = 32'h7FFF_FFFF; // rs2 = 2147483647 (sem sinal)
        alu_control_i    = OP_SLTU;       // ULA: Menor que sem sinal (2147483648 < 2147483647 -> 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b00;         // MUX B: Seleciona rs2
        check_result(33, "ULA OP_SLTU: 0x80000000 < 0x7FFFFFFF (Unsigned)", 32'd0, 32'h0000_1000, 1'b0);

        @(negedge clk); // TESTE 34: Instru??o NOP (ADDI x0, x0, 0)
        pc_i             = 32'h0000_1000; // Endere?o atual do PC
        pc_next_i        = 32'h0000_1004; // Pr?ximo endere?o (PC + 4)
        imm_i            = 32'h0000_0000; // Imediato = 0
        reg_data1_i      = 32'h0000_0000; // rs1 = 0 (x0)
        reg_data2_i      = 32'h0000_0000; // rs2 = 0
        alu_control_i    = OP_ADD;        // ULA: Soma (0 + 0)
        branch_control_i = OP_BCT;        // Branch: BEQ
        branch_enable_i  = 1'b0;          // Branch: Desativado
        control_alu_a    = 1'b0;          // MUX A: Seleciona rs1
        control_alu_b    = 2'b01;         // MUX B: Seleciona Imediato (imm_i)
        check_result(34, "NOP (ADDI x0, x0, 0)", 32'h0000_0000, 32'h0000_1000, 1'b0);
        
        
        // =========================================================================
        // 6. RELAT?RIO FINAL
        // =========================================================================
        #10;
        $display("\n=========================================================================");
        $display("                           RELAT?RIO FINAL                               ");
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
