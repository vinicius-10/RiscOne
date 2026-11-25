// Top de medicao (comparacao do TCC): RV32I37F (basic_rv32s, Kang & Choi) direto no clock de 100 MHz.
// LEDs = registrador de 16 bits carregado com o dado de store quando ha escrita na memoria de dados
// (o nucleo nao tem MMIO/GPIO). Reset do nucleo e ativo alto e assincrono: inverte CPU_RESETN.
module top_cmp (
    input  logic        clk,
    input  logic        CPU_RESETN,
    output logic [15:0] led
);
    logic        we;
    logic [31:0] wdata;

    RV32I37F core (
        .clk(clk),
        .reset(~CPU_RESETN),
        .dbg_memory_write(we),
        .dbg_data_memory_write_data(wdata)
    );

    always_ff @(posedge clk)
        if (we) led <= wdata[15:0];
endmodule
