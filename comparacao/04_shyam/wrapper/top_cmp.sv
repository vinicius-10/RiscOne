// Top de medicao (comparacao do TCC): nucleo do Shyam Sundhar (processor) direto no clock de
// 100 MHz, sem divisor de clock, BCD nem display. O nucleo nao tem MMIO nem expoe a escrita na
// memoria de dados; os LEDs registram o dado de write-back (result), que depende do banco de
// registradores, por um registrador (opcao c das instrucoes).
module top_cmp (
    input  logic        clk,
    input  logic        CPU_RESETN,
    input  logic [15:0] switch,
    output logic [15:0] led
);
    logic [31:0] result, fib_value;

    processor risc (
        .clk      (clk),
        .reset    (~CPU_RESETN),
        .result   (result),
        .fib_value(fib_value)
    );

    always_ff @(posedge clk) led <= result[15:0];
endmodule
