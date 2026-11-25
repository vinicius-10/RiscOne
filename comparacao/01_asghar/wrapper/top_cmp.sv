// Wrapper de medicao (comparacao do TCC) para o nucleo de Asghar (top.sv).
// Clock de 100 MHz direto no nucleo; CPU_RESETN (ativo baixo) invertido para reset (ativo alto).
// O top do autor nao tem MMIO nem expoe o dado de store, entao os LEDs registram (opcao c)
// os 16 bits baixos do resultado da ALU quando ha escrita no banco de registradores.
module top_cmp (
    input  logic        clk,
    input  logic        CPU_RESETN,
    output logic [15:0] led
);
    logic [31:0] alu_result, dmem_out;
    logic        mem_rw, reg_we;

    top core (
        .clk(clk),
        .reset(~CPU_RESETN),
        .alu_result_out(alu_result),
        .MemRW(mem_rw),
        .reg_write_en(reg_we),
        .data_mem_out(dmem_out)
    );

    always_ff @(posedge clk)
        if (reg_we) led <= alu_result[15:0];
endmodule
