// Top de medicao (comparacao do TCC) para o rv32i-core de W. Zongo.
// Nucleo + IMEM (256 palavras, LUT) + DMEM (256 palavras, LUTRAM) direto no clk de 100 MHz.
// O nucleo nao tem MMIO nem expoe a escrita na DMEM; os LEDs registram debug_result
// (resultado da ALU, depende do banco de registradores) - opcao (c) das instrucoes.
module top_cmp (
    input  wire        clk,
    input  wire        CPU_RESETN,
    output reg  [15:0] led
);
    wire [31:0] debug_pc, debug_result;

    core u_core (
        .clk          (clk),
        .rst          (~CPU_RESETN),
        .debug_pc     (debug_pc),
        .debug_result (debug_result)
    );

    always @(posedge clk) led <= debug_result[15:0];
endmodule
