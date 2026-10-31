`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UTFPR-CP
// Engineer: Vinicius Souza Dias
//
// Create Date: 31.10.2026 12:00:00
// Design Name: Processador RV32I
// Module Name: tb_program
// Project Name: processador_riscV
// Target Devices: Artix-7 Nexys A7-100T
// Tool Versions: Vivado 2025.2
// Description: Executa no core um programa compilado com o riscv-gcc
//              (scripts/build_sw.ps1) e confere o valor de retorno de main().
//
// Dependencies: core e todos os seus submodulos e pacotes
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Usa os arquivos program_bytes.mem e data.mem do diretorio de execucao.
//   O scripts/run_tb.ps1 copia os de build/sw/selftest/ (gerando-os se preciso).
//////////////////////////////////////////////////////////////////////////////////

/**
 * @file tb_program.sv
 * @brief Roda um programa C ate ele parar em `_halt` e verifica a0 == 0.
 *
 * Convencao do sw/common/crt0.S: main() retorna 0 em caso de sucesso; o crt0
 * deixa o retorno em a0 (x10) e entra num laco `j _halt` (0x0000006F). O
 * testbench detecta esse laco, le a0 pela hierarquia e reporta PASS/FAIL.
 * Falha tambem se o PC buscar uma instrucao indefinida (X), o que indica salto
 * para fora do programa, ou se o limite de ciclos estourar.
 *
 * @param MAX_CYCLES Limite de ciclos antes de declarar timeout.
 * @param SWITCH_VAL Valor aplicado nas chaves durante a simulacao.
 */
module tb_program;

    localparam int          MAX_CYCLES = 200_000;
    localparam logic [15:0] SWITCH_VAL = 16'hA5F0;
    localparam logic [31:0] HALT_INSTR = 32'h0000_006F; // jal x0, 0  (j .)

    logic        clk;
    logic        CPU_RESETN;
    logic [15:0] switch_i;
    logic [4:0]  button_i;
    logic [3:0]  pmod_row_i;
    logic [15:0] led_o;
    logic [15:0] seg7_o;
    logic [3:0]  pmod_col_o;

    core dut (
        .clk        (clk),
        .CPU_RESETN (CPU_RESETN),
        .switch_i   (switch_i),
        .button_i   (button_i),
        .pmod_row_i (pmod_row_i),
        .led_o      (led_o),
        .seg7_o     (seg7_o),
        .pmod_col_o (pmod_col_o)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;   // 100 MHz

    int          cycles;
    logic [31:0] a0;

    initial begin
        switch_i   = SWITCH_VAL;
        button_i   = '0;
        pmod_row_i = '0;

        // Reset sincrono: mantem CPU_RESETN baixo por algumas bordas.
        CPU_RESETN = 1'b0;
        repeat (3) @(posedge clk);
        @(negedge clk);
        CPU_RESETN = 1'b1;

        $display("==============================================================");
        $display(" tb_program: executando programa compilado (riscv-gcc)");
        $display("==============================================================");

        cycles = 0;
        forever begin
            @(negedge clk);   // sinais combinacionais estaveis no meio do ciclo
            if ($isunknown(dut.instruction)) begin
                $display("[FAIL] instrucao indefinida em PC = 0x%08h apos %0d ciclos (salto para fora do programa?)",
                         dut.pc, cycles);
                $display("STATUS: FAILED");
                $finish;
            end
            if (dut.instruction == HALT_INSTR) break;
            if (cycles >= MAX_CYCLES) begin
                $display("[FAIL] timeout: %0d ciclos sem chegar em _halt (PC = 0x%08h)", cycles, dut.pc);
                $display("STATUS: FAILED");
                $finish;
            end
            cycles++;
        end

        a0 = dut.decoder_inst.register_file_inst.register_file[10];
        $display(" _halt em PC = 0x%08h apos %0d ciclos", dut.pc, cycles);
        $display(" a0 (retorno de main) = %0d | LEDs = 0x%04h", $signed(a0), led_o);

        if (a0 == 32'd0) begin
            $display("[PASS] main() retornou 0");
            $display("STATUS: SUCCESS");
        end else begin
            $display("[FAIL] main() retornou %0d (numero do grupo de teste que falhou)", $signed(a0));
            $display("STATUS: FAILED");
        end
        $finish;
    end

endmodule
