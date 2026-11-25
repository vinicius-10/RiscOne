// Top de medicao (comparacao do TCC): nucleo cdlavila direto no clock de 100 MHz.
// O nucleo nao tem reset (PC inicia em 0 pela declaracao), entao CPU_RESETN fica sem uso.
// LEDs: registrador carregado com o dado de store quando ha escrita na memoria de dados.
module top_cmp (
  input  logic        clk,
  input  logic        CPU_RESETN,
  output logic [15:0] led
);
  logic        dm_we;
  logic [31:0] dm_wdata;

  UnicycleProcessorRISCV core (.clk(clk), .DMWr_o(dm_we), .DataWr_o(dm_wdata));

  always_ff @(posedge clk)
    if (dm_we) led <= dm_wdata[15:0];
endmodule
