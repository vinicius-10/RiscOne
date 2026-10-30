`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 21.09.2026 18:02:06
// Design Name: Processador rv32i
// Module Name: tb_alu
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Testbench automatizado para a unidade ALU.
// 
// Dependencies: alu_pkg e alu
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_alu.sv
 * @brief Testbench direcionado e aleatorio da unidade ALU.
 *
 * Aplica casos direcionados e 1000 vetores aleatorios. Os casos aleatorios sao
 * comparados com a funcao de referencia `ref_alu`; os casos manuais verificam
 * resultados e a saida `zero_o`. O resumo final informa quantidade de testes e
 * falhas.
 *
 * @param a_i Primeiro operando aplicado ao DUT.
 * @param b_i Segundo operando aplicado ao DUT.
 * @param alu_op_i Codigo da operacao exercitada.
 * @retval alu_o Resultado observado da operacao.
 * @retval zero_o Bit de condicao observado na saida da ALU.
 */
module tb_alu;
    import alu_pkg::*;
    parameter int XLEN = 32;

    // Sinais de Interface
    logic [XLEN-1:0] a_i;
    logic [XLEN-1:0] b_i;
    alu_op_t         alu_op_i;
    logic [XLEN-1:0] alu_o;
    logic            zero_o;

    // Estat?sticas do Teste
    int total_tests = 0;
    int error_count = 0;

    // Instancia??o do DUT (Design Under Test)
    alu #(
        .XLEN(XLEN)
    ) dut (
        .a_i(a_i),
        .b_i(b_i),
        .alu_op_i(alu_op_i),
        .alu_o(alu_o),
        .zero_o(zero_o)
    );
    


    // ------------------------------------------------------------------------
    // Modelo de Refer?ncia (Usado APENAS no Teste Aleat?rio)
    // ------------------------------------------------------------------------
    function automatic logic [XLEN-1:0] ref_alu(
        input logic [XLEN-1:0] a,
        input logic [XLEN-1:0] b,
        input alu_op_t         op
    );
        case (op)
            OP_ADD:    return a + b;
            OP_SUB:    return a - b;
            OP_AND:    return a & b;
            OP_OR:     return a | b;
            OP_XOR:    return a ^ b;
            OP_SLL:    return a << b[4:0];
            OP_SRL:    return a >> b[4:0];
            OP_SRA:    return $signed(a) >>> b[4:0];
            OP_SLT:    return {{(XLEN-1){1'b0}}, $signed(a) < $signed(b)};
            OP_SLTU:   return {{(XLEN-1){1'b0}}, a < b};
            OP_CMP:    return {{(XLEN-1){1'b0}}, a == b};
            OP_PASS_B: return b;
            default:   return '0;
        endcase
    endfunction

    // ------------------------------------------------------------------------
    // TASK 1: Verifica??o Direcionada (Resultado Esperado Manual)
    // ------------------------------------------------------------------------
    task automatic check_manual(
        input logic [XLEN-1:0] a,
        input logic [XLEN-1:0] b,
        input alu_op_t         op,
        input logic [XLEN-1:0] exp_alu, // Resultado esperado inserido MANUALMENTE
        input string           test_name = ""
    );
        logic exp_zero;

        a_i      = a;
        b_i      = b;
        alu_op_i = op;

        #10; // Aguarda a propaga??o combinacional

        exp_zero = exp_alu[0]; // A flag zero reflete o bit [0] do resultado manual
        total_tests++;

        if (alu_o !== exp_alu || zero_o !== exp_zero) begin
            error_count++;
            $display("[ERRO MANU #%0d] Falha: %s", error_count, test_name);
            $display("   OP: %s | A: 0x%8h | B: 0x%8h", op.name(), a, b);
            $display("   Obtido:   alu_o = 0x%8h | zero_o = %0b", alu_o, zero_o);
            $display("   Esperado: alu_o = 0x%8h | zero_o = %0b\n", exp_alu, exp_zero);
        end
    endtask

    // ------------------------------------------------------------------------
    // TASK 2: Verifica??o Aleat?ria (Resultado Esperado Calculado Autom?tico)
    // ------------------------------------------------------------------------
    task automatic check_random(
        input logic [XLEN-1:0] a,
        input logic [XLEN-1:0] b,
        input alu_op_t         op,
        input string           test_name = ""
    );
        logic [XLEN-1:0] exp_alu;
        
        exp_alu = ref_alu(a, b, op); // Calcula automaticamente
        check_manual(a, b, op, exp_alu, test_name); // Reutiliza a compara??o
    endtask

    // ------------------------------------------------------------------------
    // Execu??o dos Est?mulos
    // ------------------------------------------------------------------------
    initial begin
        $display("==================================================");
        $display("   INICIANDO SIMULA??O DA ULA (%0d bits)", XLEN);
        $display("==================================================");

        // ====================================================================
        // 1. TESTES DIRECIONADOS (Valores Esperados PASSADOS MANUALMENTE)
        // ====================================================================
        $display("\n--- Executando Testes Direcionados (Valores Manuais) ---");

        // Sintaxe: check_manual(A, B, OP, RESULTADO_ESPERADO, "NOME_DO_TESTE");
        
        // Zeros e Compara??es de Igualdade
        check_manual(32'h0000_0000, 32'h0000_0000, OP_ADD, 32'h0000_0000, "Soma de Zeros");
        check_manual(32'h0000_0000, 32'h0000_0000, OP_SUB, 32'h0000_0000, "Subtra??o de Zeros");
        check_manual(32'h1234_5678, 32'h1234_5678, OP_CMP, 32'h0000_0001, "Igualdade (Retorna 1)");
        check_manual(32'h1234_5678, 32'h8765_4321, OP_CMP, 32'h0000_0000, "Desigualdade (Retorna 0)");

        // Aritm?tica, Overflow e Underflow
        check_manual(32'h7FFF_FFFF, 32'h0000_0001, OP_ADD, 32'h8000_0000, "Overflow Int Positivo");
        check_manual(32'h8000_0000, 32'h0000_0001, OP_SUB, 32'h7FFF_FFFF, "Underflow Int Negativo");

        // SLT (Com Sinal) vs SLTU (Sem Sinal)
        // Exemplo: 0xFFFFFFFF ? -1 em Signed, mas 4294967295 em Unsigned
        check_manual(32'hFFFF_FFFF, 32'h0000_0001, OP_SLT,  32'h0000_0001, "SLT:  -1 < 1 (1)");
        check_manual(32'hFFFF_FFFF, 32'h0000_0001, OP_SLTU, 32'h0000_0000, "SLTU: MAX_UINT < 1 (0)");

        // Deslocamentos Limite (Shifts)
        check_manual(32'h8000_0001, 32'd0,  OP_SRA, 32'h8000_0001, "SRA com shamt 0");
        check_manual(32'h8000_0000, 32'd31, OP_SRA, 32'hFFFF_FFFF, "SRA (Extens?o de sinal de 1s)");
        check_manual(32'h8000_0000, 32'd31, OP_SRL, 32'h0000_0001, "SRL (Preenchimento com 0s)");


        // ====================================================================
        // 2. TESTES DE ESTRESSE ALEAT?RIO (Valores Esperados AUTOM?TICOS)
        // ====================================================================
        $display("\n--- Executando 1000 Testes Aleat?rios (C?lculo Autom?tico) ---");
        
        for (int i = 0; i < 1000; i++) begin
            logic [XLEN-1:0] rand_a  = $urandom();
            logic [XLEN-1:0] rand_b  = $urandom();
            alu_op_t         rand_op = alu_op_t'($urandom_range(0, 11));

            check_random(rand_a, rand_b, rand_op, "Estresse Aleat?rio");
        end


        // ====================================================================
        // 3. RELAT?RIO FINAL
        // ====================================================================
        $display("==================================================");
        $display("   FINAL DA SIMULA??O");
        $display("   Total de Testes Executados: %0d", total_tests);
        if (error_count == 0) begin
            $display("   STATUS: SUCCESS! Todos os testes passaram.");
        end else begin
            $display("   STATUS: FAILED! Total de erros: %0d", error_count);
        end
        $display("==================================================");

        $finish;
    end

endmodule
