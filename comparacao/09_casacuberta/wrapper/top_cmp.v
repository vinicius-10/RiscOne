// Top de medicao (comparacao TCC): nucleo Casacuberta (RV32i-Verilog) + progMem + dataMem,
// mesma ligacao do src/top.v do autor (parametros padrao, sem CUSTOM_DEFINE), clock direto.
// LEDs: registrador carregado com o dado de store quando ha escrita na memoria de dados.
`timescale 1ns/1ps
module top_cmp (
    input  wire        clk,
    input  wire        CPU_RESETN,   // ativo baixo, igual ao rst_n do nucleo
    output reg  [15:0] led
);
    localparam ADDR_WIDTH = 10, DATA_WIDTH = 32, TRANSFER_WIDTH = 4;

    wire                      we_mem_data;
    wire [ADDR_WIDTH-1:0]     addr_mem_data;
    wire [DATA_WIDTH-1:0]     val_mem_data_write;
    wire [DATA_WIDTH-1:0]     val_mem_data_read;
    wire [ADDR_WIDTH-1:0]     addr_mem_prog;
    wire [DATA_WIDTH-1:0]     val_mem_prog;
    wire [TRANSFER_WIDTH-1:0] write_transfer;

    core core_inst (
        .clk                       (clk),
        .rst_n                     (CPU_RESETN),
        .we_mem_data_o             (we_mem_data),
        .addr_mem_data_o           (addr_mem_data),
        .val_mem_data_read_i       (val_mem_data_read),
        .val_mem_data_write_o      (val_mem_data_write),
        .addr_mem_prog_o           (addr_mem_prog),
        .val_mem_prog_i            (val_mem_prog),
        .write_transfer_mem_data_o (write_transfer)
    );

    dataMem mem_data_inst (
        .rst_n            (CPU_RESETN),
        .clk              (clk),
        .we               (we_mem_data),
        .addr             (addr_mem_data),
        .data_in          (val_mem_data_write),
        .data_out         (val_mem_data_read),
        .write_transfer_i (write_transfer)
    );

    progMem mem_prog_inst (
        .rst_n    (CPU_RESETN),
        .clk      (clk),
        .addr     (addr_mem_prog),
        .data_out (val_mem_prog)
    );

    always @(posedge clk)
        if (we_mem_data) led <= val_mem_data_write[15:0];
endmodule
