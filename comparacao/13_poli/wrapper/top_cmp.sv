// Top de medicao (comparacao do TCC): instancia o top do autor (patch/top.sv, sem divisor de
// clock) direto no clk de 100 MHz. LEDs = porta debug do autor = RF[31][15:0] (saida de FF).
module top_cmp (
    input  logic        clk,
    input  logic        CPU_RESETN,
    output logic [15:0] led
);
    top core (
        .clk_200M(clk),
        .rst     (~CPU_RESETN),
        .debug   (led)
    );
endmodule
