//////////////////////////////////////////////////////////////////////////////////


// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 20.10.2026 20:22:44
// Design Name: Unidade de Controle (control_unit)
// Module Name: tb_control_unit
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Testbench automatizado para a Unidade de Controle do RV32I.
//              Valida a decodificação de opcodes e a geração dos sinais de controle.
// Dependencies: control_unit, opcode_pkg, func3_pkg, func7_pkg, alu_pkg,
//               branch_pkg, mem_pkg
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_control_unit.sv
 * @brief Testbench da unidade de controle RV32I.
 *
 * Aplica instrucoes codificadas e compara os sinais da ALU, desvios, memoria,
 * write-back e banco de registradores com os valores esperados. A bateria cobre
 * classes R, I, load, store, branch, jump e imediatos superiores; falhas sao
 * contabilizadas em `fail_count`.
 *
 * @param clk Clock de referencia do testbench.
 * @param instruction_i Instrucao RV32I aplicada a unidade de controle.
 * @retval execution_alu_control_o Operacao de ALU gerada.
 * @retval execution_branch_control_o Selecao de condicao/base de desvio.
 * @retval execution_branch_enable_o Habilitacao de desvio gerada.
 * @retval execution_control_alu_a_o Selecao da entrada A da ALU.
 * @retval execution_control_alu_b_o Selecao da entrada B da ALU.
 * @retval search_pc_write_o Habilitacao de atualizacao do PC.
 * @retval data_memory_mem_write_o Habilitacao de escrita na memoria.
 * @retval data_memory_mem_width_o Largura de acesso selecionada.
 * @retval data_memory_mem_signed_o Modo de extensao selecionado.
 * @retval register_file_written_enable_o Habilitacao de escrita no banco.
 * @retval write_back_mem_to_reg_o Selecao da fonte de write-back.
 */

`timescale 1ns / 1ps

import opcode_pkg::*;
import func3_pkg::*;
import func7_pkg::*;
import alu_pkg::*;
import branch_pkg::*;
import mem_pkg::*;

module tb_control_unit;

    // =========================================================================
    // 1. SINAIS DE INTERFACE
    // =========================================================================
    logic           clk;
    logic [31:0]    instruction_i;

    // Saídas do DUT
    alu_op_t        execution_alu_control_o;
    branch_op_t     execution_branch_control_o;
    logic           execution_branch_enable_o;
    logic           execution_control_alu_a_o;
    logic [1:0]     execution_control_alu_b_o;
    logic           search_pc_write_o;
    logic           data_memory_mem_write_o;
    mem_width_t     data_memory_mem_width_o;
    mem_signed_t    data_memory_mem_signed_o;
    logic           register_file_written_enable_o;
    logic           write_back_mem_to_reg_o;

    // Contador interno de falhas
    integer fail_count = 0;

    // =========================================================================
    // 2. INSTANCIAÇÃO DO DUT
    // =========================================================================
    control_unit DUT (
        .instruction_i                  (instruction_i),
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
        logic [31:0] base_instruction;
        integer variant;
        begin
            base_instruction = instruction_i;

            // Cada caso roda com tres combinacoes de registradores/imediato.
            // Opcode, funct3 e funct7 permanecem intactos, preservando a operacao.
            for (variant = 0; variant < 3; variant = variant + 1) begin
                instruction_i = base_instruction;
                case (variant)
                    1: begin
                        instruction_i[19:15] = 5'd1;
                        instruction_i[24:20] = 5'd2;
                        instruction_i[11:7]  = 5'd3;
                    end
                    2: begin
                        instruction_i[19:15] = 5'd30;
                        instruction_i[24:20] = 5'd21;
                        instruction_i[11:7]  = 5'd31;
                    end
                    default: begin end
                endcase

                #1; // Delay combinacional
            
            if ((execution_alu_control_o        === exp_alu_ctrl)     &&
                (execution_branch_control_o     === exp_branch_ctrl)  &&
                (execution_branch_enable_o      === exp_branch_en)    &&
                (execution_control_alu_b_o      === exp_alu_b)        &&
                (search_pc_write_o              === exp_pc_write)     &&
                (data_memory_mem_write_o        === exp_mem_write)    &&
                (data_memory_mem_width_o        === exp_mem_width)    &&
                (data_memory_mem_signed_o       === exp_mem_signed)   &&
                (register_file_written_enable_o === exp_reg_write)   &&
                (write_back_mem_to_reg_o        === exp_mem_to_reg)) begin
                
                $display("[PASS] Teste %02d.%0d: %-55s", test_num, variant + 1, test_name);
            end else begin
                $display("[FAIL] Teste %02d.%0d: %-55s", test_num, variant + 1, test_name);
                $display("       Obtido   -> ALU_Op:%b Br_Op:%b Br_En:%b ALU_A:%b ALU_B:%b PC_W:%b Mem_W:%b Width:%b Signed:%b Reg_W:%b M2R:%b",
                         execution_alu_control_o, execution_branch_control_o, execution_branch_enable_o,
                         execution_control_alu_a_o, execution_control_alu_b_o, search_pc_write_o,
                         data_memory_mem_write_o, data_memory_mem_width_o, data_memory_mem_signed_o,
                         register_file_written_enable_o, write_back_mem_to_reg_o);
                $display("       Esperado -> ALU_Op:%b Br_Op:%b Br_En:%b ALU_A:%b ALU_B:%b PC_W:%b Mem_W:%b Width:%b Signed:%b Reg_W:%b M2R:%b\n",
                         exp_alu_ctrl, exp_branch_ctrl, exp_branch_en,
                         exp_alu_a, exp_alu_b, exp_pc_write,
                         exp_mem_write, exp_mem_width, exp_mem_signed,
                         exp_reg_write, exp_mem_to_reg);
                fail_count++;
            end
            end
            instruction_i = base_instruction;
        end
    endtask

    // =========================================================================
    // 5. SEQUÊNCIA DE TESTES
    // =========================================================================
    initial begin
        clk           = 1'b0;
        instruction_i = 32'h0000_0000;

        $display("\n=========================================================================");
        $display("   INICIANDO BATERIA EXTENSA DE TESTES - UNIDADE DE CONTROLE             ");
        $display("=========================================================================\n");

        // ---------------------------------------------------------------------
        // SEÇÃO 1: INSTRUÇÕES TIPO-R (ALU REG-REG)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 01: ADD
        instruction_i = {F7_ADD, 5'b00011, 5'b00010, F3_ADD, 5'b00001, OPCODE_OP};
        check_result(1, "R-Type: ADD", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 02: SUB
        instruction_i = {F7_SUB, 5'b00011, 5'b00010, F3_SUB, 5'b00001, OPCODE_OP};
        check_result(2, "R-Type: SUB", OP_SUB, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 03: SLL
        instruction_i = {F7_SLL, 5'b00011, 5'b00010, F3_SLL, 5'b00001, OPCODE_OP};
        check_result(3, "R-Type: SLL", OP_SLL, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 04: SLT
        instruction_i = {F7_SLT, 5'b00011, 5'b00010, F3_SLT, 5'b00001, OPCODE_OP};
        check_result(4, "R-Type: SLT", OP_SLT, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 36: SLTU
        instruction_i = {F7_SLTU, 5'b00011, 5'b00010, F3_SLTU, 5'b00001, OPCODE_OP};
        check_result(36, "R-Type: SLTU", OP_SLTU, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 05: XOR
        instruction_i = {F7_XOR, 5'b00011, 5'b00010, F3_XOR, 5'b00001, OPCODE_OP};
        check_result(5, "R-Type: XOR", OP_XOR, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 06: SRL
        instruction_i = {F7_SRL, 5'b00011, 5'b00010, F3_SRL, 5'b00001, OPCODE_OP};
        check_result(6, "R-Type: SRL", OP_SRL, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 07: SRA
        instruction_i = {F7_SRA, 5'b00011, 5'b00010, F3_SRA, 5'b00001, OPCODE_OP};
        check_result(7, "R-Type: SRA", OP_SRA, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 08: OR
        instruction_i = {F7_OR, 5'b00011, 5'b00010, F3_OR, 5'b00001, OPCODE_OP};
        check_result(8, "R-Type: OR", OP_OR, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 09: AND
        instruction_i = {F7_AND, 5'b00011, 5'b00010, F3_AND, 5'b00001, OPCODE_OP};
        check_result(9, "R-Type: AND", OP_AND, OP_BCT, 1'b0, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 2: INSTRUÇÕES TIPO-I (ALU COM IMEDIATO)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 10: ADDI
        instruction_i = {12'b0000_0000_0001, 5'b00010, F3_ADDI, 5'b00001, OPCODE_OP_IMM};
        check_result(10, "I-Type: ADDI", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 11: SLTI
        instruction_i = {12'b0000_0000_0001, 5'b00010, F3_SLTI, 5'b00001, OPCODE_OP_IMM};
        check_result(11, "I-Type: SLTI", OP_SLT, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 37: SLTIU
        instruction_i = {12'b1111_1111_1111, 5'b00010, F3_SLTIU, 5'b00001, OPCODE_OP_IMM};
        check_result(37, "I-Type: SLTIU", OP_SLTU, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 12: XORI
        instruction_i = {12'b0000_0000_0001, 5'b00010, F3_XORI, 5'b00001, OPCODE_OP_IMM};
        check_result(12, "I-Type: XORI", OP_XOR, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 13: ORI
        instruction_i = {12'b0000_0000_0001, 5'b00010, F3_ORI, 5'b00001, OPCODE_OP_IMM};
        check_result(13, "I-Type: ORI", OP_OR, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 14: ANDI
        instruction_i = {12'b0000_0000_0001, 5'b00010, F3_ANDI, 5'b00001, OPCODE_OP_IMM};
        check_result(14, "I-Type: ANDI", OP_AND, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 15: SLLI
        instruction_i = {F7_SLLI, 5'b00011, 5'b00010, F3_SLLI, 5'b00001, OPCODE_OP_IMM};
        check_result(15, "I-Type: SLLI", OP_SLL, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 16: SRLI
        instruction_i = {F7_SRLI, 5'b00011, 5'b00010, F3_SRLI, 5'b00001, OPCODE_OP_IMM};
        check_result(16, "I-Type: SRLI", OP_SRL, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 17: SRAI
        instruction_i = {F7_SRAI, 5'b00011, 5'b00010, F3_SRAI, 5'b00001, OPCODE_OP_IMM};
        check_result(17, "I-Type: SRAI", OP_SRA, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 3: INSTRUÇÕES DE LEITURA DE MEMÓRIA (LOADS)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 18: LB (Load Byte)
        instruction_i = {12'b0000_0000_0100, 5'b00010, F3_LB, 5'b00001, OPCODE_LOAD};
        check_result(18, "Load: LB (Signed Byte)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_BYTE, MEM_SIGNED, 1'b1, 1'b1);

        @(negedge clk); // TESTE 19: LH (Load Halfword)
        instruction_i = {12'b0000_0000_0100, 5'b00010, F3_LH, 5'b00001, OPCODE_LOAD};
        check_result(19, "Load: LH (Signed Half)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_HALF, MEM_SIGNED, 1'b1, 1'b1);

        @(negedge clk); // TESTE 20: LW (Load Word)
        instruction_i = {12'b0000_0000_0100, 5'b00010, F3_LW, 5'b00001, OPCODE_LOAD};
        check_result(20, "Load: LW (Signed Word)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_SIGNED, 1'b1, 1'b1);

        @(negedge clk); // TESTE 21: LBU (Load Byte Unsigned)
        instruction_i = {12'b0000_0000_0100, 5'b00010, F3_LBU, 5'b00001, OPCODE_LOAD};
        check_result(21, "Load: LBU (Unsigned Byte)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_BYTE, MEM_UNSIGNED, 1'b1, 1'b1);

        @(negedge clk); // TESTE 22: LHU (Load Halfword Unsigned)
        instruction_i = {12'b0000_0000_0100, 5'b00010, F3_LHU, 5'b00001, OPCODE_LOAD};
        check_result(22, "Load: LHU (Unsigned Half)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_HALF, MEM_UNSIGNED, 1'b1, 1'b1);

        // ---------------------------------------------------------------------
        // SEÇÃO 4: INSTRUÇÕES DE ESCRITA NA MEMÓRIA (STORES)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 23: SB (Store Byte)
        instruction_i = {7'b0000000, 5'b00011, 5'b00010, F3_SB, 5'b00000, OPCODE_STORE};
        check_result(23, "Store: SB (Byte)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b1, MEM_WIDTH_BYTE, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 24: SH (Store Halfword)
        instruction_i = {7'b0000000, 5'b00011, 5'b00010, F3_SH, 5'b00000, OPCODE_STORE};
        check_result(24, "Store: SH (Halfword)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b1, MEM_WIDTH_HALF, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 25: SW (Store Word)
        instruction_i = {7'b0000000, 5'b00011, 5'b00010, F3_SW, 5'b00000, OPCODE_STORE};
        check_result(25, "Store: SW (Word)", OP_ADD, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b1, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 5: DESVIOS CONDICIONAIS (BRANCHES)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 26: BEQ
        instruction_i = {1'b0, 6'b000000, 5'b00010, 5'b00001, F3_BEQ, 4'b0000, 1'b0, OPCODE_BRANCH};
        check_result(26, "Branch: BEQ (True Cond)", OP_CMP, OP_BCT, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 27: BNE
        instruction_i = {1'b0, 6'b000000, 5'b00010, 5'b00001, F3_BNE, 4'b0000, 1'b0, OPCODE_BRANCH};
        check_result(27, "Branch: BNE (False Cond)", OP_CMP, OP_BCF, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 28: BLT
        instruction_i = {1'b0, 6'b000000, 5'b00010, 5'b00001, F3_BLT, 4'b0000, 1'b0, OPCODE_BRANCH};
        check_result(28, "Branch: BLT (True Cond)", OP_SLT, OP_BCT, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 29: BGE
        instruction_i = {1'b0, 6'b000000, 5'b00010, 5'b00001, F3_BGE, 4'b0000, 1'b0, OPCODE_BRANCH};
        check_result(29, "Branch: BGE (False Cond)", OP_SLT, OP_BCF, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 30: BLTU
        instruction_i = {1'b0, 6'b000000, 5'b00010, 5'b00001, F3_BLTU, 4'b0000, 1'b0, OPCODE_BRANCH};
        check_result(30, "Branch: BLTU (True Cond)", OP_SLTU, OP_BCT, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        @(negedge clk); // TESTE 31: BGEU
        instruction_i = {1'b0, 6'b000000, 5'b00010, 5'b00001, F3_BGEU, 4'b0000, 1'b0, OPCODE_BRANCH};
        check_result(31, "Branch: BGEU (False Cond)", OP_SLTU, OP_BCF, 1'b1, 1'b0, 2'b00, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b0, 1'b0);

        // ---------------------------------------------------------------------
        // SEÇÃO 6: SALTOS INCONDICIONAIS E TIPO-U
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 32: JAL
        instruction_i = {1'b0, 10'b0000000000, 1'b0, 8'b00000000, 5'b00001, OPCODE_JAL};
        check_result(32, "Jump: JAL", OP_PASS_B, OP_BIP, 1'b1, 1'b1, 2'b10, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 33: JALR
        instruction_i = {12'b0000_0000_0100, 5'b00010, F3_JALR, 5'b00001, OPCODE_JALR};
        check_result(33, "Jump: JALR", OP_PASS_B, OP_BIR, 1'b1, 1'b1, 2'b10, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 34: LUI
        instruction_i = {20'h12345, 5'b00001, OPCODE_LUI};
        check_result(34, "Upper Imm: LUI", OP_PASS_B, OP_BCT, 1'b0, 1'b0, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

        @(negedge clk); // TESTE 35: AUIPC
        instruction_i = {20'h12345, 5'b00001, OPCODE_AUIPC};
        check_result(35, "Upper Imm: AUIPC", OP_ADD, OP_BCT, 1'b0, 1'b1, 2'b01, 1'b1, 1'b0, MEM_WIDTH_WORD, MEM_UNSIGNED, 1'b1, 1'b0);

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
