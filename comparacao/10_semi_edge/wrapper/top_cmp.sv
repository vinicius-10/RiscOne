// top_cmp: wrapper de medicao (comparacao do TCC). Instancia RISCV_Top (nucleo + IMEM + DMEM do
// autor) direto no clock de 100 MHz. LEDs = dado do ultimo store (registrador), para a sintese
// nao podar o nucleo.
module top_cmp (
    input  logic        clk,
    input  logic        CPU_RESETN,
    output logic [15:0] led
);
    logic        dmem_we;
    logic [31:0] dmem_wdata;

    RISCV_Top core (
        .clk       (clk),
        .rst       (~CPU_RESETN),
        .dmem_we   (dmem_we),
        .dmem_wdata(dmem_wdata)
    );

    always_ff @(posedge clk)
        if (dmem_we) led <= dmem_wdata[15:0];
endmodule
