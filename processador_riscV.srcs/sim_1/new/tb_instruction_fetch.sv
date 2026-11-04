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
// Description: Testbench de PC e busca com uma memória auxiliar que devolve uma palavra por endereço.
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
 * Valida reset (no início e no meio da execução), avanços sequenciais de PC,
 * carregamento de destino de desvio e congelamento/retomada do PC pelo sinal
 * `pc_write_i`. A memória auxiliar é combinacional como a real e devolve
 * `~endereço`, uma palavra diferente para cada endereço. O search a lê com o
 * próximo PC e registra a palavra junto com o PC; assim, além do PC e de PC+4,
 * o testbench confere que a instrução registrada é sempre a do PC atual
 * (`instr_o == ~pc_o`).
 *
 * @param clk Clock usado para atualizar o PC e registrar a instrução.
 * @param reset_i Reset do PC, ativo em nivel alto.
 * @param pc_write_i Habilita a atualizacao do PC; em 0, mantem o valor atual.
 * @param pc_branch_i Seleciona o carregamento de `new_pc_i` quando habilitado.
 * @param new_pc_i Endereco de destino aplicado ao caminho de desvio.
 * @retval pc_o Valor atual do contador de programa.
 * @retval pc_next Proximo endereco sequencial, PC+4.
 * @retval instr_o Instrução registrada pelo search; deve valer `~pc_o`.
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
            
            // A instrução entregue tem que ser a do PC atual (palavra ~PC no modelo).
            if ((pc_o === expected_pc_o) && (pc_next === expected_pc_next) &&
                (instr_o === ~expected_pc_o)) begin
                $display("[PASS] Teste %0d: %-32s | PC: 0x%08h | PC_NEXT: 0x%08h | INSTR: 0x%08h",
                         test_count, test_name, pc_o, pc_next, instr_o);
                pass_count++;
            end else begin
                $display("[FAIL] Teste %0d: %-32s | PC Obtido: 0x%08h (Esp: 0x%08h) | PC_NEXT Obtido: 0x%08h (Esp: 0x%08h) | INSTR Obtida: 0x%08h (Esp: 0x%08h)",
                         test_count, test_name, pc_o, expected_pc_o, pc_next, expected_pc_next,
                         instr_o, ~expected_pc_o);
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

        // --- TESTE 7: Reset no meio da execução ---
        // O reset entra no próximo PC: na borda, PC = 0 e a instrução registrada é a palavra 0.
        @(negedge clk);
        reset_i = 1'b1;
        check_result("Reset pedido (antes da borda)", 32'h0000_0114, 32'h0000_0118);

        @(negedge clk);
        reset_i = 1'b0;
        check_result("Reset no meio da execucao", 32'h0000_0000, 32'h0000_0004);

        @(negedge clk);
        check_result("Retomada apos o reset", 32'h0000_0004, 32'h0000_0008);

        

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
 * @brief Modelo auxiliar de memória usado exclusivamente por tb_instruction_fetch.
 *
 * Substitui a memória real durante este teste. Como a real, é combinacional. A
 * palavra de cada endereço é `~addr_i`, diferente para cada endereço, para o
 * testbench conferir que a instrução registrada pelo search é a do PC atual.
 * O parâmetro MEM_DEPTH é mantido para compatibilidade com a instância da
 * etapa de busca.
 *
 * @param MEM_DEPTH Profundidade nominal da memória no módulo search.
 * @param addr_i Endereço da próxima instrução, vindo do search.
 * @retval instr_o Palavra do endereço: `~addr_i`.
 */
module instruction_memory #(
    parameter int MEM_DEPTH = 1024
)(
    input  logic [31:0] addr_i,
    output logic [31:0] instr_o
);
    assign instr_o = ~addr_i;
endmodule
