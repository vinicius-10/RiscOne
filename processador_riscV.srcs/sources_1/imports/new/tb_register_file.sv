//////////////////////////////////////////////////////////////////////////////////


// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 19.10.2026 14:41:31
// Design Name: Banco de Registradores (register_file)
// Module Name: tb_register_file
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Testbench automatizado para o Banco de Registradores do RV32I,
//              com atribuição explícita de entradas e verificação no posedge.
// Dependencies: register_file
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_register_file.sv
 * @brief Testbench automatizado do banco de registradores.
 *
 * Verifica leituras simultaneas, escrita na borda de subida, comportamento do
 * x0, bloqueio de escrita quando desabilitada e armazenamento de valores
 * positivos e negativos. Os estimulos sao aplicados na borda de descida e os
 * resultados sao comparados depois da borda de subida.
 *
 * @param clk Clock de teste com periodo de 10 ns.
 * @param written_enable_i Habilitacao de escrita aplicada ao DUT.
 * @param written_data_i Dado aplicado a entrada de escrita.
 * @param written_add_i Endereco de destino aplicado ao DUT.
 * @param rs1_add_i Endereco solicitado pela porta de leitura 1.
 * @param rs2_add_i Endereco solicitado pela porta de leitura 2.
 * @retval rs1_o Dado observado na porta de leitura 1.
 * @retval rs2_o Dado observado na porta de leitura 2.
 */

`timescale 1ns / 1ps

module tb_register_file;

    // =========================================================================
    // 1. PARÂMETROS E SINAIS DE INTERFACE
    // =========================================================================
    localparam int XLEN = 32;
    localparam int REG_XLEN = 5;

    logic                  clk;
    
    // Entradas do DUT
    logic                  written_enable_i;
    logic [XLEN-1:0]       written_data_i;
    logic [REG_XLEN-1:0]   written_add_i;
    logic [REG_XLEN-1:0]   rs1_add_i;
    logic [REG_XLEN-1:0]   rs2_add_i;

    // Saídas do DUT
    logic [XLEN-1:0]       rs1_o;
    logic [XLEN-1:0]       rs2_o;

    // Contador interno de falhas
    integer fail_count = 0;

    // =========================================================================
    // 2. INSTANCIAÇÃO DO DUT (Device Under Test)
    // =========================================================================
    register_file #(
        .XLEN    (XLEN),
        .REG_XLEN(REG_XLEN)
    ) DUT (
        .clk             (clk),
        .written_enable_i(written_enable_i),
        .written_data_i  (written_data_i),
        .written_add_i   (written_add_i),
        .rs1_add_i       (rs1_add_i),
        .rs2_add_i       (rs2_add_i),
        .rs1_o           (rs1_o),
        .rs2_o           (rs2_o)
    );

    // =========================================================================
    // 3. GERAÇÃO DO CLOCK (Período = 10ns -> 100 MHz)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. TASK DE COMPARAÇÃO AUTOMÁTICA
    // =========================================================================
    task automatic check_result(
        input int              test_num,
        input string           test_name, 
        input logic [XLEN-1:0] expected_rs1_o,
        input logic [XLEN-1:0] expected_rs2_o
    );
        begin
            #1; // Delay após o posedge para estabilização da leitura
            
            if ((rs1_o === expected_rs1_o) && (rs2_o === expected_rs2_o)) begin
                $display("[PASS] Teste %02d: %-46s | RS1: 0x%08h | RS2: 0x%08h", 
                         test_num, test_name, rs1_o, rs2_o);
            end else begin
                $display("[FAIL] Teste %02d: %-46s", test_num, test_name);
                $display("       RS1 -> Obtido: 0x%08h | Esperado: 0x%08h", rs1_o, expected_rs1_o);
                $display("       RS2 -> Obtido: 0x%08h | Esperado: 0x%08h \n", rs2_o, expected_rs2_o);
                fail_count++;
            end
        end
    endtask

    // =========================================================================
    // 5. SEQUÊNCIA DE TESTES
    // =========================================================================
    initial begin
        // Inicialização de sinais
        clk              = 0;
        written_enable_i = 1'b0;
        written_data_i   = 32'h0000_0000;
        written_add_i    = 5'd0;
        rs1_add_i        = 5'd0;
        rs2_add_i        = 5'd0;

        $display("\n=========================================================================");
        $display("   INICIANDO BATERIA DE TESTES - BANCO DE REGISTRADORES (REGISTER_FILE)  ");
        $display("=========================================================================\n");

        // ---------------------------------------------------------------------
        // SEÇÃO 1: VERIFICAÇÃO DO REGISTRADOR ZERO (x0)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 01: Leitura Inicial de x0
        written_enable_i = 1'b0;          // Habilitação de escrita: DESATIVADA (0 = Não escreve)
        written_data_i   = 32'hFFFF_FFFF; // Dado para tentativa de escrita
        written_add_i    = 5'd0;          // Endereço de destino da escrita (x0)
        rs1_add_i        = 5'd0;          // Leitura na Porta RS1: Registrador x0
        rs2_add_i        = 5'd0;          // Leitura na Porta RS2: Registrador x0
        @(posedge clk);
        check_result(1, "Leitura Inicial de x0 (deve ser 0)", 32'h0000_0000, 32'h0000_0000);

        @(negedge clk); // TESTE 02: Tentativa de Escrita no Registrador Zero (x0)
        written_enable_i = 1'b1;          // Habilitação de escrita: ATIVADA (1 = Escreve)
        written_data_i   = 32'h1234_5678; // Dado gravado (deve ser ignorado em x0)
        written_add_i    = 5'd0;          // Endereço de destino da escrita: Registrador x0
        rs1_add_i        = 5'd0;          // Leitura na Porta RS1: Registrador x0
        rs2_add_i        = 5'd0;          // Leitura na Porta RS2: Registrador x0
        @(posedge clk);
        check_result(2, "Tentativa de escrita em x0 (deve permanecer 0)", 32'h0000_0000, 32'h0000_0000);

        // ---------------------------------------------------------------------
        // SEÇÃO 2: ESCRITA E LEITURA DE REGISTRADORES CONVENCIONAIS
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 03: Escrita em x1 (ra)
        written_enable_i = 1'b1;          // Habilitação de escrita: ATIVADA
        written_data_i   = 32'hDEAD_BEEF; // Dado a ser escrito em x1
        written_add_i    = 5'd1;          // Endereço de destino da escrita: Registrador x1
        rs1_add_i        = 5'd1;          // Leitura RS1: Lendo o próprio x1 sendo escrito
        rs2_add_i        = 5'd0;          // Leitura RS2: Lendo x0
        @(posedge clk);
        check_result(3, "Escrita em x1 (0xDEADBEEF) e leitura em RS1", 32'hDEAD_BEEF, 32'h0000_0000);

        @(negedge clk); // TESTE 04: Escrita em x2 (sp)
        written_enable_i = 1'b1;          // Habilitação de escrita: ATIVADA
        written_data_i   = 32'h7FFF_FF00; // Dado de ponteiro de pilha
        written_add_i    = 5'd2;          // Endereço de destino da escrita: Registrador x2
        rs1_add_i        = 5'd1;          // Leitura RS1: Lendo x1 (já armazenado)
        rs2_add_i        = 5'd2;          // Leitura RS2: Lendo x2 sendo escrito
        @(posedge clk);
        check_result(4, "Escrita em x2 e leitura simultanea (x1 em RS1, x2 em RS2)", 32'hDEAD_BEEF, 32'h7FFF_FF00);

        @(negedge clk); // TESTE 05: Escrita em x5 (t0) com valor negativo
        written_enable_i = 1'b1;          // Habilitação de escrita: ATIVADA
        written_data_i   = -32'd50;       // Dado em complemento de 2 (32'hFFFFFFCE)
        written_add_i    = 5'd5;          // Endereço de destino da escrita: Registrador x5
        rs1_add_i        = 5'd5;          // Leitura RS1: Lendo x5
        rs2_add_i        = 5'd2;          // Leitura RS2: Lendo x2
        @(posedge clk);
        check_result(5, "Escrita em x5 com valor negativo (-50)", -32'd50, 32'h7FFF_FF00);

        // ---------------------------------------------------------------------
        // SEÇÃO 3: PROTEÇÃO DE ESCRITA E LEITURAS SIMULTÂNEAS
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 06: Tentativa de Escrita com written_enable_i = 0
        written_enable_i = 1'b0;          // Habilitação de escrita: DESABILITADA (0 = Bloqueia escrita)
        written_data_i   = 32'hCAFE_BABE; // Tentativa de sobrescrever x1
        written_add_i    = 5'd1;          // Endereço de destino: Registrador x1
        rs1_add_i        = 5'd1;          // Leitura RS1: Registrador x1 (deve manter 0xDEADBEEF)
        rs2_add_i        = 5'd5;          // Leitura RS2: Registrador x5 (deve manter -50)
        @(posedge clk);
        check_result(6, "Protecao de Escrita (written_enable=0 em x1)", 32'hDEAD_BEEF, -32'd50);

        @(negedge clk); // TESTE 07: Leitura Simultânea do Mesmo Registrador em RS1 e RS2
        written_enable_i = 1'b0;          // Habilitação de escrita: DESATIVADA
        written_data_i   = 32'h0000_0000; // Dado zerado (ignorado)
        written_add_i    = 5'd0;          // Endereço zerado
        rs1_add_i        = 5'd2;          // Leitura RS1: Lendo x2
        rs2_add_i        = 5'd2;          // Leitura RS2: Lendo x2 simultaneamente
        @(posedge clk);
        check_result(7, "Leitura simultanea de x2 em ambas as portas", 32'h7FFF_FF00, 32'h7FFF_FF00);

        // ---------------------------------------------------------------------
        // SEÇÃO 4: TESTE NO LÍMITE SUPERIOR DO BANCO (x31)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 08: Escrita no Último Registrador (x31 - t6)
        written_enable_i = 1'b1;          // Habilitação de escrita: ATIVADA
        written_data_i   = 32'hA5A5_5A5A; // Padrão de bits alternados
        written_add_i    = 5'd31;         // Endereço de destino: Registrador x31
        rs1_add_i        = 5'd31;         // Leitura RS1: Lendo x31
        rs2_add_i        = 5'd1;          // Leitura RS2: Lendo x1
        @(posedge clk);
        check_result(8, "Escrita no ultimo registrador (x31)", 32'hA5A5_5A5A, 32'hDEAD_BEEF);

        @(negedge clk); // TESTE 09: Leitura Combinada de x31 e x5
        written_enable_i = 1'b0;          // Habilitação de escrita: DESATIVADA
        written_data_i   = 32'h0000_0000; // Dado zerado (ignorado)
        written_add_i    = 5'd0;          // Endereço zerado
        rs1_add_i        = 5'd5;          // Leitura RS1: Registrador x5 (-50)
        rs2_add_i        = 5'd31;         // Leitura RS2: Registrador x31 (0xA5A55A5A)
        @(posedge clk);
        check_result(9, "Leitura combinada de x5 em RS1 e x31 em RS2", -32'd50, 32'hA5A5_5A5A);

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
