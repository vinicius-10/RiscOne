// Top de medicao do Pequeno-Risco-5: Core direto no clk de 100 MHz.
// LEDs[7:0] = saida leds do proprio nucleo (~x15[7:0], vem direto dos FFs do banco de registradores).
module top_cmp (
    input  wire        clk,
    input  wire        CPU_RESETN,
    output wire [15:0] led
);
    wire [7:0] leds;
    Core #(.MEMORY_FILE("prog_word_256.hex")) Core (
        .clk(clk), .reset(~CPU_RESETN), .leds(leds)
    );
    assign led = {8'h00, leds};
endmodule
