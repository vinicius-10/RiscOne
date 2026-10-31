//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
// 
// Create Date: 07.10.2026 08:38:00
// Design Name: Memoria de Dados (data_memory)
// Module Name: tb_data_memory
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: vivado 2025.2
// Description: Testbench automatizado com verificacao de leituras e escritas
//              de byte, halfword e word, incluindo inspecao das lanes.
// Dependencies: data_memory, mem_pkg
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_data_memory.sv
 * @brief Testbench automatizado da memoria de dados.
 *
 * Verifica leituras e escritas de byte, halfword e word, extensao com e sem
 * sinal, selecao de lanes e preservacao dos bytes nao escritos. A task de
 * verificacao compara `data_o` e inspeciona os quatro bytes da palavra
 * enderecada; as escritas sao estimuladas antes da borda de subida.
 *
 * @param clk Clock usado para sincronizar as escritas.
 * @param mem_write_i Habilitacao de escrita aplicada ao DUT.
 * @param mem_width_i Largura do acesso exercitado.
 * @param mem_signed_i Modo de extensao aplicado nas leituras.
 * @param addr_i Endereco de byte aplicado ao DUT.
 * @param data_i Dado usado nos casos de escrita.
 * @retval data_o Valor lido pela memoria.
 */


`timescale 1ns / 1ps

// Importa os enums e tipos da memória de dados
module tb_data_memory;

    import mem_pkg::*;

    // =========================================================================
    // 1. PARÂMETROS E SINAIS DE INTERFACE
    // =========================================================================
    localparam int XLEN = 32;
    localparam int MEM_DEPTH = 1024;

    logic            clk;
    
    // Entradas do DUT
    logic            mem_write_i;
    mem_width_t      mem_width_i;
    mem_signed_t     mem_signed_i;
    logic [XLEN-1:0] addr_i;
    logic [XLEN-1:0] data_i;

    logic [XLEN-1:0] data_o;

    // Contador de falhas
    integer fail_count = 0;

    // =========================================================================
    // 2. INSTANCIAÇÃO DO DUT (Device Under Test)
    // =========================================================================
    data_memory #(
        .XLEN(XLEN),
        .MEM_DEPTH(MEM_DEPTH)
    ) DUT (
        .clk          (clk),
        .mem_write_i  (mem_write_i),
        .mem_width_i  (mem_width_i),
        .mem_signed_i (mem_signed_i),
        .addr_i       (addr_i),
        .data_i       (data_i),
        .data_o       (data_o)
    );
    import mem_pkg::*;


    // =========================================================================
    // 3. GERAÇÃO DO CLOCK (Período = 10ns)
    // =========================================================================
    always #5 clk = ~clk;

    // =========================================================================
    // 4. TASK DE COMPARAÇÃO E INSPEÇÃO DA MEMÓRIA INTERNA
    // =========================================================================
    task automatic check_result(
        input int              test_num,
        input string           test_name, 
        input logic [XLEN-1:0] expected_data_o
    );
        logic [7:0] b0, b1, b2, b3;
        int word_idx;
        begin
            #1; // Estabilização após a borda do clock
            
            // Calcula o índice de palavra da memória interna (addr_i / 4)
            word_idx = addr_i >> 2;
            
            // Leitura direta da matriz interna mem[0:MEM_DEPTH-1][0:3]
            b0 = DUT.mem[word_idx][0];
            b1 = DUT.mem[word_idx][1];
            b2 = DUT.mem[word_idx][2];
            b3 = DUT.mem[word_idx][3];

            if (data_o === expected_data_o) begin
                $display("[PASS] Teste %02d: %-48s | DATA_O: 0x%08h | MEM[%0d]: [3]=0x%02h [2]=0x%02h [1]=0x%02h [0]=0x%02h", 
                         test_num, test_name, data_o, word_idx, b3, b2, b1, b0);
            end else begin
                $display("[FAIL] Teste %02d: %-48s", test_num, test_name);
                $display("       DATA_O -> Obtido: 0x%08h | Esperado: 0x%08h", data_o, expected_data_o);
                $display("       MEM[%0d]-> [3]=0x%02h [2]=0x%02h [1]=0x%02h [0]=0x%02h \n", word_idx, b3, b2, b1, b0);
                fail_count++;
            end
        end
    endtask

    // =========================================================================
    // 5. SEQUÊNCIA DE TESTES
    // =========================================================================
    initial begin
        // Inicialização de sinais
        clk          = 0;
        addr_i       = 32'h0000_0000;
        data_i       = 32'h0000_0000;
        mem_write_i  = 1'b0;
        mem_width_i  = MEM_WIDTH_WORD;
        mem_signed_i = MEM_SIGNED;

        $display("\n=========================================================================");
        $display("     INICIANDO BATERIA DE TESTES - MÓDULO DE MEMÓRIA (DATA_MEMORY)      ");
        $display("=========================================================================\n");

        // ---------------------------------------------------------------------
        // SEÇÃO 1: ESCRITA E LEITURA DE PALAVRA COMPLETA (WORD - 32 BITS)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 01: Escrita de Word (SW)
        addr_i       = 32'h0000_0004; // Endereço de memória (Palavra 1)
        data_i       = 32'h1234_5678; // Dado de 32 bits a ser escrito
        mem_write_i  = 1'b1;          // Habilitação de escrita: ATIVADA (1 = Escreve na memória)
        mem_width_i  = MEM_WIDTH_WORD;// Largura do acesso: Word completa (32 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal (Ignorado na escrita)
        @(posedge clk);
        check_result(1, "Escrita Word (SW): 0x12345678 no addr 0x04", 32'h1234_5678);

        @(negedge clk); // TESTE 02: Leitura de Word (LW)
        addr_i       = 32'h0000_0004; // Endereço de memória (Palavra 1)
        data_i       = 32'h0000_0000; // Dado de entrada zerado (ignorado na leitura)
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA (0 = Leitura)
        mem_width_i  = MEM_WIDTH_WORD;// Largura do acesso: Word completa (32 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal (32 bits diretos)
        @(posedge clk);
        check_result(2, "Leitura Word (LW): Lendo addr 0x04", 32'h1234_5678);

        // ---------------------------------------------------------------------
        // SEÇÃO 2: ESCRITA E LEITURA DE MEIA PALAVRA (HALFWORD - 16 BITS)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 03: Escrita Halfword (SH) no offset 0 (bytes 0 e 1)
        addr_i       = 32'h0000_0008; // Endereço de memória (Palavra 2)
        data_i       = 32'h0000_ABCD; // Dado de 16 bits nos LSBs (0xABCD é negativo com sinal)
        mem_write_i  = 1'b1;          // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_HALF;// Largura do acesso: Halfword (16 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal (Ignorado na escrita)
        @(posedge clk);
        check_result(3, "Escrita Halfword (SH): 0xABCD no addr 0x08 (Offset 0)", 32'hffff_ABCD);

        @(negedge clk); // TESTE 04: Leitura Halfword Signed (LH) - Estende sinal negativo
        addr_i       = 32'h0000_0008; // Endereço de memória (Palavra 2, offset 0)
        data_i       = 32'h0000_0000; // Dado de entrada zerado
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_HALF;// Largura do acesso: Halfword (16 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: COM SINAL (0xABCD -> 0xFFFFABCD)
        @(posedge clk);
        check_result(4, "Leitura Halfword Signed (LH): 0xABCD -> 0xFFFFABCD", 32'hFFFF_ABCD);

        @(negedge clk); // TESTE 05: Leitura Halfword Unsigned (LHU) - Estende zero
        addr_i       = 32'h0000_0008; // Endereço de memória (Palavra 2, offset 0)
        data_i       = 32'h0000_0000; // Dado de entrada zerado
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_HALF;// Largura do acesso: Halfword (16 bits)
        mem_signed_i = MEM_UNSIGNED;  // Sinalização: SEM SINAL (0xABCD -> 0x0000ABCD)
        @(posedge clk);
        check_result(5, "Leitura Halfword Unsigned (LHU): 0xABCD -> 0x0000ABCD", 32'h0000_ABCD);

        @(negedge clk); // TESTE 06: Escrita Halfword (SH) no offset 2 (bytes 2 e 3)
        addr_i       = 32'h0000_000A; // Endereço de memória (Palavra 2, offset 2)
        data_i       = 32'h0000_1234; // Dado de 16 bits nos LSBs
        mem_write_i  = 1'b1;          // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_HALF;// Largura do acesso: Halfword (16 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal (Ignorado na escrita)
        @(posedge clk);
        check_result(6, "Escrita Halfword (SH): 0x1234 no addr 0x0A (Offset 2)", 32'h0000_1234);

        @(negedge clk); // TESTE 07: Leitura Word Inteira da Palavra 2 (Verifica 0x1234ABCD)
        addr_i       = 32'h0000_0008; // Endereço base da Palavra 2 (0x08)
        data_i       = 32'h0000_0000; // Dado de entrada zerado
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_WORD;// Largura do acesso: Word completa (32 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal
        @(posedge clk);
        check_result(7, "Leitura Word Completa: Verifica mescla SH (0x1234ABCD)", 32'h1234_ABCD);

        // ---------------------------------------------------------------------
        // SEÇÃO 3: ESCRITA E LEITURA DE BYTE (BYTE - 8 BITS)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 08: Escrita de Byte (SB) no Byte 0
        addr_i       = 32'h0000_0010; // Endereço de memória (Palavra 4, Byte 0)
        data_i       = 32'h0000_0080; // Byte = 0x80 (negativo em complemento de 2)
        mem_write_i  = 1'b1;          // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;// Largura do acesso: Byte (8 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal (Ignorado na escrita)
        @(posedge clk);
        check_result(8, "Escrita Byte (SB): 0x80 no addr 0x10 (Byte 0)", 32'hFFFF_FF80);

        @(negedge clk); // TESTE 09: Leitura Byte Signed (LB) - Estende sinal negativo
        addr_i       = 32'h0000_0010; // Endereço de memória (Palavra 4, Byte 0)
        data_i       = 32'h0000_0000; // Dado de entrada zerado
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;// Largura do acesso: Byte (8 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: COM SINAL (0x80 -> 0xFFFFFF80)
        @(posedge clk);
        check_result(9, "Leitura Byte Signed (LB): 0x80 -> 0xFFFFFF80", 32'hFFFF_FF80);

        @(negedge clk); // TESTE 10: Leitura Byte Unsigned (LBU) - Estende zero
        addr_i       = 32'h0000_0010; // Endereço de memória (Palavra 4, Byte 0)
        data_i       = 32'h0000_0000; // Dado de entrada zerado
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;// Largura do acesso: Byte (8 bits)
        mem_signed_i = MEM_UNSIGNED;  // Sinalização: SEM SINAL (0x80 -> 0x00000080)
        @(posedge clk);
        check_result(10, "Leitura Byte Unsigned (LBU): 0x80 -> 0x00000080", 32'h0000_0080);

        @(negedge clk); // TESTE 11: Escrita de Byte (SB) no Byte 1
        addr_i       = 32'h0000_0011; // Endereço de memória (Palavra 4, Byte 1)
        data_i       = 32'h0000_007F; // Byte = 0x7F (positivo com sinal)
        mem_write_i  = 1'b1;          // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;// Largura do acesso: Byte (8 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal
        @(posedge clk);
        check_result(11, "Escrita Byte (SB): 0x7F no addr 0x11 (Byte 1)", 32'h0000_007F);

        @(negedge clk); // TESTE 12: Escrita de Byte (SB) no Byte 2
        addr_i       = 32'h0000_0012; // Endereço de memória (Palavra 4, Byte 2)
        data_i       = 32'h0000_00FE; // Byte = 0xFE
        mem_write_i  = 1'b1;          // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;// Largura do acesso: Byte (8 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal
        @(posedge clk);
        check_result(12, "Escrita Byte (SB): 0xFE no addr 0x12 (Byte 2)", 32'hFFFF_FFFE);

        @(negedge clk); // TESTE 13: Escrita de Byte (SB) no Byte 3
        addr_i       = 32'h0000_0013; // Endereço de memória (Palavra 4, Byte 3)
        data_i       = 32'h0000_0012; // Byte = 0x12
        mem_write_i  = 1'b1;          // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;// Largura do acesso: Byte (8 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal
        @(posedge clk);
        check_result(13, "Escrita Byte (SB): 0x12 no addr 0x13 (Byte 3)", 32'h0000_0012);

        @(negedge clk); // TESTE 14: Leitura Byte 1 Signed (LB positivo)
        addr_i       = 32'h0000_0011; // Endereço de memória (Palavra 4, Byte 1)
        data_i       = 32'h0000_0000; // Dado de entrada zerado
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;// Largura do acesso: Byte (8 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: COM SINAL (0x7F -> 0x0000007F)
        @(posedge clk);
        check_result(14, "Leitura Byte Signed (LB): 0x7F -> 0x0000007F", 32'h0000_007F);

        @(negedge clk); // TESTE 15: Leitura Word Inteira montada por 4 SBs (0x12FE7F80)
        addr_i       = 32'h0000_0010; // Endereço base da Palavra 4 (0x10)
        data_i       = 32'h0000_0000; // Dado de entrada zerado
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_WORD;// Largura do acesso: Word completa (32 bits)
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal
        @(posedge clk);
        check_result(15, "Leitura Word Completa: Verifica montagem de 4 SBs", 32'h12FE_7F80);

        // ---------------------------------------------------------------------
        // SEÇÃO 4: CASOS LIMITE E PROTEÇÃO DE ESCRITA (EDGE CASES)
        // ---------------------------------------------------------------------

        @(negedge clk); // TESTE 16: Tentativa de escrita com mem_write_i = 0 (Não altera)
        addr_i       = 32'h0000_0004; // Endereço da Palavra 1 (que contém 0x12345678)
        data_i       = 32'hFFFF_FFFF; // Tentativa de sobrescrever com 0xFFFFFFFF
        mem_write_i  = 1'b0;          // Habilitação de escrita: DESABILITADA (0 = Impede escrita)
        mem_width_i  = MEM_WIDTH_WORD;// Largura do acesso: Word completa
        mem_signed_i = MEM_SIGNED;    // Sinalização: Com sinal
        @(posedge clk);
        check_result(16, "Protecao de Escrita (mem_write=0): Mantem 0x12345678", 32'h1234_5678);

        @(negedge clk); // TESTE 17: Escrita no último endereço de palavra da memória
        addr_i       = (MEM_DEPTH - 1) * 4; // último endereço válido de 32 bits
        data_i       = 32'hCAFE_BABE;       // Dado a ser escrito
        mem_write_i  = 1'b1;                // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_WORD;      // Largura do acesso: Word completa
        mem_signed_i = MEM_SIGNED;          // Sinalização: Com sinal
        @(posedge clk);
        check_result(17, "Escrita Word no ultimo endereco da memoria", 32'hCAFE_BABE);

        @(negedge clk); // TESTE 18: Leitura no último endereço da memória
        addr_i       = (MEM_DEPTH - 1) * 4; // último endereço
        data_i       = 32'h0000_0000;       // Dado de entrada zerado
        mem_write_i  = 1'b0;                // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_WORD;      // Largura do acesso: Word completa
        mem_signed_i = MEM_SIGNED;          // Sinalização: Com sinal
        @(posedge clk);
        check_result(18, "Leitura Word no ultimo endereco da memoria", 32'hCAFE_BABE);

        @(negedge clk); // TESTE 19: Sobrescrita parcial - altera apenas Byte 1 da Word anterior
        addr_i       = ((MEM_DEPTH - 1) * 4) + 1; // Endereço do Byte 1 do último elemento
        data_i       = 32'h0000_0000;             // Sobrescreve com 0x00 no Byte 1
        mem_write_i  = 1'b1;                      // Habilitação de escrita: ATIVADA
        mem_width_i  = MEM_WIDTH_BYTE;            // Largura do acesso: Byte
        mem_signed_i = MEM_SIGNED;                // Sinalização: Com sinal
        @(posedge clk);
        check_result(19, "Sobrescrita de Byte 1 no ultimo elemento", 32'h0000_0000);

        @(negedge clk); // TESTE 20: Leitura Word no último elemento para confirmar efeito (0xCAFE00BE)
        addr_i       = (MEM_DEPTH - 1) * 4; // Endereço base da palavra
        data_i       = 32'h0000_0000;       // Dado de entrada zerado
        mem_write_i  = 1'b0;                // Habilitação de escrita: DESATIVADA
        mem_width_i  = MEM_WIDTH_WORD;      // Largura do acesso: Word completa
        mem_signed_i = MEM_SIGNED;          // Sinalização: Com sinal
        @(posedge clk);
        check_result(20, "Leitura Word: Verifica modificacao de byte (0xCAFE00BE)", 32'hCAFE_00BE);

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
