`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 22.09.2026 16:06:55
// Design Name: Processador RV32I
// Module Name: tb_instruction_fetch
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Testbench de PC e busca usando uma memoria auxiliar que retorna NOP.
// 
// Dependencies: search, instruction_memory (modelo auxiliar), opcode_pkg
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_instruction_fetch.sv
 * @brief Testbench da etapa de busca de instruções.
 *
 * Valida reset, avancos sequenciais de PC, carregamento de destino de desvio e
 * congelamento/retomada do PC pelo sinal `pc_write_i`. A memoria auxiliar
 * retorna sempre a instrucao NOP; este testbench verifica o PC e PC+4, nao o
 * conteudo da instrucao.
 *
 * @param clk Clock usado para atualizar o PC.
 * @param reset_i Reset do PC, ativo em nivel alto.
 * @param pc_write_i Habilita a atualizacao do PC; em 0, mantem o valor atual.
 * @param pc_branch_i Seleciona o carregamento de `new_pc_i` quando habilitado.
 * @param new_pc_i Endereco de destino aplicado ao caminho de desvio.
 * @retval pc_o Valor atual do contador de programa.
 * @retval pc_next Proximo endereco sequencial, PC+4.
 * @retval instr_o Instrucao retornada pelo modelo auxiliar, sempre NOP.
 *
 */

`timescale 1ns / 1ps

module tb_instruction_fetch;

    // =========================================================================
    // 1. PARÂMETROS E SINAIS DE INTERFACE
    // =========================================================================
    localparam int XLEN = 32;
    localparam int MEM_DEPTH = 1024;

    logic              clk;
    logic [XLEN-1:0]   new_pc_i;
    logic              pc_write_i;
    logic              pc_branch_i;
    logic              reset_i;
    
    logic [XLEN-1:0]   instr_o;
    logic [XLEN-1:0]   pc_o;
    logic [XLEN-1:0]   pc_next;

    // =========================================================================
    // 2. ESTRUTURAS E VARIÁVEIS DE VERIFICAÇÃO AUTOMÁTICA
    // =========================================================================;     
    
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    // =========================================================================
    // 3. INSTANCIAÇÃO DO DUT (Device Under Test)
    // =========================================================================
    search #(
        .XLEN(XLEN),
        .MEM_DEPTH(MEM_DEPTH)
    ) DUT (
        .clk        (clk),
        .new_pc_i   (new_pc_i),
        .pc_write_i (pc_write_i),
        .pc_branch_i(pc_branch_i),
        .reset_i     (reset_i),
        .instr_o    (instr_o),
        .pc_o       (pc_o),
        .pc_next    (pc_next)
    );

    // =========================================================================
    // 4. GERAÇÃO DO CLOCK (Período = 10ns -> 100 MHz)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 5. TASK DE COMPARAÇÃO
    // =========================================================================
    task automatic check_result(
        input string           test_name, 
        input logic [XLEN-1:0] expected_pc_o,
        input logic [XLEN-1:0] expected_pc_next
    );
        begin
            test_count++;
            #1; // Pequeno delay após o clock para estabilização dos sinais
            
            if ((pc_o === expected_pc_o) && (pc_next === expected_pc_next)) begin
                $display("[PASS] Teste %0d: %-32s | PC: 0x%08h | PC_NEXT: 0x%08h", 
                         test_count, test_name, pc_o, pc_next);
                pass_count++;
            end else begin
                $display("[FAIL] Teste %0d: %-32s | PC Obtido: 0x%08h (Esp: 0x%08h) | PC_NEXT Obtido: 0x%08h (Esp: 0x%08h)", 
                         test_count, test_name, pc_o, expected_pc_o, pc_next, expected_pc_next);
                fail_count++;
            end
        end
    endtask

    // =========================================================================
    // 6. SEQUÊNCIA DE TESTES
    // =========================================================================
    initial begin
        // Inicialização dos sinais
        clk         = 0;
        reset_i      = 1;
        pc_write_i  = 0;
        pc_branch_i = 0;
        new_pc_i    = 32'h0;

        $display("\n=======================================================");
        $display("     INICIANDO BATERIA DE TESTES - MODULO SEARCH       ");
        $display("=======================================================\n");

        // --- TESTE 1: Reset Ativo ---
        @(negedge clk);
        check_result("Reset Ativo", 32'h0000_0000, 32'h0000_0004);

        // Desativa Reset
        @(negedge clk);
        reset_i = 0;

        // --- TESTE 2: Incremento Sequencial (PC + 4) ---
        @(negedge clk);
        pc_write_i  = 1'b1;
        pc_branch_i = 1'b0;
        check_result("Incremento Sequencial 0", 32'h0000_0000, 32'h0000_0004);

        @(negedge clk);
        check_result("Incremento Sequencial 1", 32'h0000_0004, 32'h0000_0008);

        @(negedge clk);
        check_result("Incremento Sequencial 2", 32'h0000_0008, 32'h0000_000C);

        // --- TESTE 3: Predição/Cálculo de Branch (Branch Ativo) ---
        @(negedge clk);
        pc_branch_i = 1'b1;
        new_pc_i    = 32'h0000_0100; // Salto para endereço 0x100
        // Verifica se o pc_next aponta para o new_pc_i imediatamente
        check_result("Calculo de Branch (pc_next)", 32'h0000_000C, 32'h0000_0010);

        @(negedge clk);
        // Na borda de subida, o PC deve ter assumido o valor de branch (0x100)
        pc_branch_i = 1'b0;
        check_result("Execucao do Salto (Branch) e incremento 2.0", 32'h0000_0100, 32'h0000_0104);

        // --- TESTE 4: Voltar para Fluxo Sequencial Pós-Branch ---
        @(negedge clk);
        check_result("Incremento Sequencial 2.1 ", 32'h0000_0104, 32'h0000_0108);

        @(negedge clk);
        check_result("Incremento Sequencial 2.2", 32'h0000_0108, 32'h0000_010c);

        // --- TESTE 5: Stall (pc_write_i = 0) ---
        @(negedge clk);
        pc_write_i = 1'b0; // Congela o PC
        check_result("Stop", 32'h0000_010c, 32'h0000_0110 );

        // --- TESTE 6: Retomada Pós-Stall ---
        @(negedge clk);
        pc_write_i = 1'b1;
        check_result("Stall do PC (Mantem valor)", 32'h0000_010c, 32'h0000_0110);

        @(negedge clk);
        check_result("Retomada Pos-Stall", 32'h0000_0110, 32'h0000_0114);
        
        

        // =========================================================================
        // 7. RELATÓRIO FINAL
        // =========================================================================
        #10;
        $display("\n=======================================================");
        $display("                   RELATÓRIO FINAL                      ");
        $display("=======================================================");
        $display(" Total de Casos Executados : %0d", test_count);
        $display(" Casos com SUCESSO         : %0d", pass_count);
        $display(" Casos com FALHA           : %0d", fail_count);
        $display("-------------------------------------------------------");

        if (fail_count == 0) begin
            $display(" STATUS GERAL: >>> PASSOU (TODOS OS TESTES COM SUCESSO) <<<");
        end else begin
            $display(" STATUS GERAL: >>> FALHOU <<<");
        end
            $display("\n=======================================================\n");
        $finish;
    end

endmodule

/**
 * @brief Modelo auxiliar de memoria usado exclusivamente por tb_instruction_fetch.
 *
 * Substitui a memoria real durante este teste e fornece uma instrucao NOP
 * constante. O parametro MEM_DEPTH e mantido para compatibilidade com a
 * instancia da etapa de busca.
 *
 * @param MEM_DEPTH Profundidade nominal da memoria no modulo search.
 * @param addr_i Endereco recebido do PC; nao afeta o valor retornado.
 * @retval instr_o Instrucao NOP constante (addi x0, x0, 0).
 */
module instruction_memory #(
    parameter int MEM_DEPTH = 1024
)(
    input  logic [31:0] addr_i,
    output logic [31:0] instr_o
);
    // Retorna NOP (addi x0, x0, 0)
    assign instr_o = 32'h0000_0013;
endmodule
