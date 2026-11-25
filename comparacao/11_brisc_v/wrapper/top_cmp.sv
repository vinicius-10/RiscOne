// top_cmp - wrapper de medicao do BRISC-V monociclo gerado pelo usuario no BRISC-V Explorer
// (usuario_256/BRISC_V256memoria.v). Reproduz a mesma ligacao do topo BRISC_V256memoria
// (single_cycle_core + memory_interface + dual_port_BRAM_memory_subsystem, mesmos parametros),
// so para acessar o barramento de store: o topo do autor so exporta o PC.
// Clock de 100 MHz direto; reset ativo baixo da placa invertido (nucleo usa ativo alto).
// LEDs: registrador de 16 bits carregado com o dado de store (opcao b das instrucoes).
module top_cmp (
    input  logic        clk,
    input  logic        CPU_RESETN,
    input  logic [15:0] switch,
    output logic [15:0] led
);
    localparam DATA_WIDTH = 32, ADDRESS_BITS = 32, MEM_ADDRESS_BITS = 6, NUM_BYTES = 4;

    wire reset = ~CPU_RESETN;

    wire fetch_read, fetch_valid, fetch_ready;
    wire [ADDRESS_BITS-1:0] fetch_address_out, fetch_address_in;
    wire [DATA_WIDTH-1:0]   fetch_data_in;
    wire memory_read, memory_write, memory_valid, memory_ready;
    wire [NUM_BYTES-1:0]    memory_byte_en;
    wire [ADDRESS_BITS-1:0] memory_address_out, memory_address_in;
    wire [DATA_WIDTH-1:0]   memory_data_out, memory_data_in;
    wire [DATA_WIDTH-1:0]   i_mem_data_out, d_mem_data_out, d_mem_data_in;
    wire [ADDRESS_BITS-1:0] i_mem_address_out, i_mem_address_in, d_mem_address_out, d_mem_address_in;
    wire i_mem_valid, i_mem_ready, i_mem_read, d_mem_valid, d_mem_ready, d_mem_read, d_mem_write;
    wire [NUM_BYTES-1:0]    d_mem_byte_en;

    single_cycle_core #(
        .CORE(0), .RESET_PC(32'd0), .DATA_WIDTH(DATA_WIDTH), .ADDRESS_BITS(ADDRESS_BITS),
        .SCAN_CYCLES_MIN(0), .SCAN_CYCLES_MAX(1000)
    ) core (
        .clock(clk), .reset(reset), .start(1'b0), .program_address(32'd0),
        .fetch_valid(fetch_valid), .fetch_ready(fetch_ready), .fetch_data_in(fetch_data_in),
        .fetch_address_in(fetch_address_in), .memory_valid(memory_valid), .memory_ready(memory_ready),
        .memory_data_in(memory_data_in), .memory_address_in(memory_address_in),
        .fetch_read(fetch_read), .fetch_address_out(fetch_address_out),
        .memory_read(memory_read), .memory_write(memory_write), .memory_byte_en(memory_byte_en),
        .memory_address_out(memory_address_out), .memory_data_out(memory_data_out),
        .scan(1'b0)
    );

    memory_interface #(.DATA_WIDTH(DATA_WIDTH), .ADDRESS_BITS(ADDRESS_BITS)) mem_interface (
        .fetch_read(fetch_read), .fetch_address_out(fetch_address_out), .fetch_data_in(fetch_data_in),
        .fetch_address_in(fetch_address_in), .fetch_valid(fetch_valid), .fetch_ready(fetch_ready),
        .memory_read(memory_read), .memory_write(memory_write), .memory_byte_en(memory_byte_en),
        .memory_address_out(memory_address_out), .memory_data_out(memory_data_out),
        .memory_data_in(memory_data_in), .memory_address_in(memory_address_in),
        .memory_valid(memory_valid), .memory_ready(memory_ready),
        .i_mem_data_out(i_mem_data_out), .i_mem_address_out(i_mem_address_out),
        .i_mem_valid(i_mem_valid), .i_mem_ready(i_mem_ready), .i_mem_read(i_mem_read),
        .i_mem_address_in(i_mem_address_in),
        .d_mem_data_out(d_mem_data_out), .d_mem_address_out(d_mem_address_out),
        .d_mem_valid(d_mem_valid), .d_mem_ready(d_mem_ready), .d_mem_read(d_mem_read),
        .d_mem_write(d_mem_write), .d_mem_byte_en(d_mem_byte_en),
        .d_mem_address_in(d_mem_address_in), .d_mem_data_in(d_mem_data_in),
        .scan(1'b0)
    );

    dual_port_BRAM_memory_subsystem #(
        .DATA_WIDTH(DATA_WIDTH), .ADDRESS_BITS(ADDRESS_BITS), .MEM_ADDRESS_BITS(MEM_ADDRESS_BITS),
        .SCAN_CYCLES_MIN(0), .SCAN_CYCLES_MAX(1000)
    ) memory (
        .clock(clk), .reset(reset),
        .i_mem_read(i_mem_read), .i_mem_address_in(i_mem_address_in), .i_mem_data_out(i_mem_data_out),
        .i_mem_address_out(i_mem_address_out), .i_mem_valid(i_mem_valid), .i_mem_ready(i_mem_ready),
        .d_mem_read(d_mem_read), .d_mem_write(d_mem_write), .d_mem_byte_en(d_mem_byte_en),
        .d_mem_address_in(d_mem_address_in), .d_mem_data_in(d_mem_data_in),
        .d_mem_data_out(d_mem_data_out), .d_mem_address_out(d_mem_address_out),
        .d_mem_valid(d_mem_valid), .d_mem_ready(d_mem_ready),
        .scan(1'b0)
    );

    always_ff @(posedge clk)
        if (memory_write) led <= memory_data_out[15:0];
endmodule
