// top de medição (comparação do TCC): ProcessorCore monociclo de HarieshAnbalagan/RV32I
// + InstructionMemory (64 palavras, combinacional) + DataMemory (64 palavras, leitura
// combinacional) do próprio autor, clock direto de 100 MHz.
// LEDs: registrador de 16 bits carregado com o dado de store quando há escrita na DMEM.
import risc_v_32_i_pkg::*;

module top_cmp
(
    input  logic        clk,
    input  logic        CPU_RESETN,
    output logic [15:0] led
);
    logic [31:0] instruction_address, instruction_data;
    logic [31:0] read_data, write_data, data_address;
    logic [3:0]  write_data_strobe;
    logic        write_enable;

    InstructionMemory imem
    (
        .instruction_data_o     (instruction_data),
        .instruction_address_i  (instruction_address)
    );

    ProcessorCore PrCore
    (
        .clk_i                  (clk),
        .reset_i                (~CPU_RESETN),
        .instruction_address_o  (instruction_address),
        .instruction_data_i     (instruction_data),
        .read_data_i            (read_data),
        .write_enable_o         (write_enable),
        .write_data_o           (write_data),
        .write_data_strobe_o    (write_data_strobe),
        .address_o              (data_address)
    );

    DataMemory dmem
    (
        .read_data_o    (read_data),
        .clk_i          (clk),
        .write_enable_i (write_enable),
        .write_data_i   (write_data),
        .address_i      (data_address)
    );

    always_ff @(posedge clk)
        if (write_enable) led <= write_data[15:0];
endmodule
