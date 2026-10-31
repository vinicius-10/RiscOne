//////////////////////////////////////////////////////////////////////////////////


// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 20.10.2026 15:23:05
// Design Name: Multiplexador de Write-Back (write_back)
// Module Name: tb_write_back
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Testbench automatizado para o multiplexador de Write-Back (RV32I).
//              Seleciona entre o resultado da ULA e os dados da memória.
// Dependencies: write_back
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_write_back.sv
 * @brief Testbench do seletor da etapa de write-back.
 *
 * Executa seis casos para verificar a selecao entre o resultado da ALU e o
 * dado da memoria, incluindo valores positivos, negativos e zero. Cada caso
 * compara `wb_data_o` com o valor esperado e atualiza `fail_count`.
 *
 * @param alu_result_i Valor de teste aplicado a entrada da ALU.
 * @param mem_data_i Valor de teste aplicado a entrada da memoria.
 * @param mem_to_reg_i Seletor da fonte esperada para write-back.
 * @retval wb_data_o Dado selecionado pelo DUT.
 */

`timescale 1ns / 1ps

module tb_write_back;

    // =========================================================================
    // 1. PARÂMETROS E SINAIS DE INTERFACE
    // =========================================================================
    localparam int XLEN = 32;

    logic            clk;
    
    // Entradas do DUT
    logic [XLEN-1:0] alu_result_i;
    logic [XLEN-1:0] mem_data_i;
    logic            mem_to_reg_i;

    // Saídas do DUT
    logic [XLEN-1:0] wb_data_o;

    // Contador interno de falhas
    integer fail_count = 0;

    // =========================================================================
    // 2. INSTANCIAÇÃO DO DUT (Device Under Test)
    // =========================================================================
    write_back #(
        .XLEN(XLEN)
    ) DUT (
        .alu_result_i(alu_result_i),
        .mem_data_i  (mem_data_i),
        .mem_to_reg_i(mem_to_reg_i),
        .wb_data_o   (wb_data_o)
    );

    // =========================================================================
    // 3. GERAÇÃO DO CLOCK DE REFERÊNCIA
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. TASK DE COMPARAÇÃO AUTOMÁTICA
    // =========================================================================
    task automatic check_result(
        input int              test_num,
        input string           test_name, 
        input logic [XLEN-1:0] expected_wb_data_o
    );
        begin
            #1; // Delay para estabilização da lógica combinacional
            
            if (wb_data_o === expected_wb_data_o) begin
                $display("[PASS] Teste %02d: %-50s | WB_DATA: 0x%08h", 
                         test_num, test_name, wb_data_o);
            end else begin
                $display("[FAIL] Teste %02d: %-50s", test_num, test_name);
                $display("       WB_DATA -> Obtido: 0x%08h | Esperado: 0x%08h \n", 
                         wb_data_o, expected_wb_data_o);
                fail_count++;
            end
        end
    endtask

    // =========================================================================
    // 5. SEQUÊNCIA DE TESTES
    // =========================================================================
    initial begin
        // Inicialização de sinais
        clk          = 1'b0;
        alu_result_i = 32'h0000_0000;
        mem_data_i   = 32'h0000_0000;
        mem_to_reg_i = 1'b0;

        $display("\n=========================================================================");
        $display("   INICIANDO BATERIA DE TESTES - MULTIPLEXADOR WRITE-BACK (WRITE_BACK)   ");
        $display("=========================================================================\n");

        // ---------------------------------------------------------------------
        // SEÇÃO 1: SELEÇÃO DO RESULTADO DA ULA (mem_to_reg_i = 0)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 01: Seleção da ULA com valor positivo
        alu_result_i = 32'h1234_5678; // Resultado vindo da ULA
        mem_data_i   = 32'h8765_4321; // Dado vindo da memória (deve ser ignorado)
        mem_to_reg_i = 1'b0;          // Seleção MUX: 0 = ULA (alu_result_i)
        check_result(1, "Selecao ULA (mem_to_reg = 0) - Valor Positivo", 32'h1234_5678);

        @(negedge clk); // TESTE 02: Seleção da ULA com valor negativo (complemento de 2)
        alu_result_i = 32'hFFFF_FFCE; // -50 em Hexadecimal
        mem_data_i   = 32'h0000_0064; // +100 em Hexadecimal (deve ser ignorado)
        mem_to_reg_i = 1'b0;          // Seleção MUX: 0 = ULA (alu_result_i)
        check_result(2, "Selecao ULA (mem_to_reg = 0) - Valor Negativo", 32'hFFFF_FFCE);

        @(negedge clk); // TESTE 03: Seleção da ULA com valor nulo
        alu_result_i = 32'h0000_0000; // Zero
        mem_data_i   = 32'hCAFE_BABE; // Dado de memória (deve ser ignorado)
        mem_to_reg_i = 1'b0;          // Seleção MUX: 0 = ULA (alu_result_i)
        check_result(3, "Selecao ULA (mem_to_reg = 0) - Valor Nulo", 32'h0000_0000);

        // ---------------------------------------------------------------------
        // SEÇÃO 2: SELEÇÃO DOS DADOS DA MEMÓRIA (mem_to_reg_i = 1)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 04: Seleção da Memória com palavra completa
        alu_result_i = 32'h0000_0010; // Endereço de memória na ULA (deve ser ignorado)
        mem_data_i   = 32'hDEAD_BEEF; // Dado lido da memória
        mem_to_reg_i = 1'b1;          // Seleção MUX: 1 = Memória (mem_data_i)
        check_result(4, "Selecao Memoria (mem_to_reg = 1) - Word Completa", 32'hDEAD_BEEF);

        @(negedge clk); // TESTE 05: Seleção da Memória com dado estendido com sinal (Halfword/Byte)
        alu_result_i = 32'h1000_0000; // Endereço na ULA (deve ser ignorado)
        mem_data_i   = 32'hFFFF_ABCD; // Dado estendido com sinal lido da memória
        mem_to_reg_i = 1'b1;          // Seleção MUX: 1 = Memória (mem_data_i)
        check_result(5, "Selecao Memoria (mem_to_reg = 1) - Dado com Extensao", 32'hFFFF_ABCD);

        @(negedge clk); // TESTE 06: Seleção da Memória com valor nulo
        alu_result_i = 32'hA5A5_A5A5; // Padrão de bits na ULA (deve ser ignorado)
        mem_data_i   = 32'h0000_0000; // Dado zerado na memória
        mem_to_reg_i = 1'b1;          // Seleção MUX: 1 = Memória (mem_data_i)
        check_result(6, "Selecao Memoria (mem_to_reg = 1) - Valor Nulo", 32'h0000_0000);

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
