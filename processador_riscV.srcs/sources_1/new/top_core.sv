`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.10.2026 16:54:24
// Design Name: 
// Module Name: top_core
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_core (
    input  logic        clk,
    input  logic        CPU_RESETN,
    input  logic [15:0] switch,
    input  logic        BTNC,
    input  logic        BTNU,
    input  logic        BTNL,
    input  logic        BTNR,
    input  logic        BTND,
    output logic [15:0] led,
    output logic [7:0]  c_7_segment,
    output logic [7:0]  a_7_segment,
    inout  wire  [10:1] JA
);

    logic [3:0] pmod_col;
    logic [3:0] pmod_row;
    logic [15:0] seg7;
    logic [4:0] button;

    // JA[1:4] dirigem as colunas; JA[7:10] recebem as linhas do teclado.
    assign JA[4:1]  = pmod_col;
    assign JA[10:7] = 4'bzzzz;
    assign pmod_row = JA[10:7];

    assign button = {BTND, BTNR, BTNL, BTNU, BTNC};
    assign c_7_segment = seg7[7:0];
    assign a_7_segment = seg7[15:8];
    
    logic reset;
    // CPU_RESETN e ativo em nivel baixo; core espera reset ativo em nivel alto.
    assign reset = ~CPU_RESETN;
    
    core core_inst (
        .clk         (clk),
        .reset_i     (reset),
        .switch_i    (switch),
        .button_i    (button),
        .pmod_row_i  (pmod_row),
        .led_o       (led),
        .seg7_o      (seg7),
        .pmod_col_o  (pmod_col)
    );
endmodule
