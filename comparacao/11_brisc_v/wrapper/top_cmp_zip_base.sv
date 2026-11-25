// top_cmp - wrapper de medicao do BRISC-V single_cycle_base (comparacao do TCC)
// Clock de 100 MHz direto no nucleo; reset ativo baixo da placa invertido (nucleo usa ativo alto).
// ISP (In-System Programmer) desligada: a IMEM vem do $readmemh (patch/bsram.v, INIT_FILE via defparam).
// LEDs: registrador to_peripheral_data do proprio nucleo (write-back de x9/x18..x25), ja registrado.
module top_cmp (
    input  logic        clk,
    input  logic        CPU_RESETN,
    input  logic [15:0] switch,
    output logic [15:0] led
);
    logic [31:0] periph_data;

    RISC_V_Core core (
        .clock                (clk),
        .reset                (~CPU_RESETN),
        .start                (1'b0),
        .prog_address         (10'd0),
        .from_peripheral      (2'b00),
        .from_peripheral_data (32'd0),
        .from_peripheral_valid(1'b0),
        .to_peripheral        (),
        .to_peripheral_data   (periph_data),
        .to_peripheral_valid  (),
        .isp_address          (10'd0),
        .isp_data             (32'd0),
        .isp_write            (1'b0),
        .current_PC           (),
        .report               (1'b0)
    );

    defparam core.IF.i_mem_interface.RAM.INIT_FILE = "zip_base_prog_word.hex";

    assign led = periph_data[15:0];
endmodule
