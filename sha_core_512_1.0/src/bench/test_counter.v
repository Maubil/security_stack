

`timescale 1ns/10ps

module test_counter;

  reg clk,rst;

  reg [31:0] data_block_i [31:0];
  reg trigger_i;

  wire [4:0] counter_val_o;
  wire done_o;
  wire [31:0] cyclic_out;

  initial
  begin

    data_block_i[00] = {32'hDEAD0000};
    data_block_i[01] = {32'hDEAD0001};
    data_block_i[02] = {32'hDEAD0002};
    data_block_i[03] = {32'hDEAD0003};
    data_block_i[04] = {32'hDEAD0004};
    data_block_i[05] = {32'hDEAD0005};
    data_block_i[06] = {32'hDEAD0006};
    data_block_i[07] = {32'hDEAD0007};
    data_block_i[08] = {32'hDEAD0008};
    data_block_i[09] = {32'hDEAD0009};
    data_block_i[10] = {32'hDEAD000a};
    data_block_i[11] = {32'hDEAD000b};
    data_block_i[12] = {32'hDEAD000c};
    data_block_i[13] = {32'hDEAD000d};
    data_block_i[14] = {32'hDEAD000e};
    data_block_i[15] = {32'hDEAD000f};
    data_block_i[16] = {32'hDEAD0010};
    data_block_i[17] = {32'hDEAD0011};
    data_block_i[18] = {32'hDEAD0012};
    data_block_i[19] = {32'hDEAD0013};
    data_block_i[20] = {32'hDEAD0014};
    data_block_i[21] = {32'hDEAD0015};
    data_block_i[22] = {32'hDEAD0016};
    data_block_i[23] = {32'hDEAD0017};
    data_block_i[24] = {32'hDEAD0018};
    data_block_i[25] = {32'hDEAD0019};
    data_block_i[26] = {32'hDEAD001a};
    data_block_i[27] = {32'hDEAD001b};
    data_block_i[28] = {32'hDEAD001c};
    data_block_i[29] = {32'hDEAD001d};
    data_block_i[30] = {32'hDEAD001e};
    data_block_i[31] = {32'hDEAD001f};

    clk = 1'b0;
    rst = 1'b0;
    trigger_i = 1'b0;
    
    @(posedge clk);
    rst = 1'b1;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    trigger_i = 1'b1;
    @(posedge clk);
    trigger_i = 1'b0;
  
    while (~done_o) begin
      @(posedge clk);
    end

    @(posedge clk);
    @(posedge clk);
    @(posedge clk);


    $finish;
  end


  always #5 clk = ~clk;


  // this is how this should be used
	up_counter core(.clk(clk), .reset(rst), .start(trigger_i), .counter(counter_val_o), .done(done_o));
	assign cyclic_out = (trigger_i | ~done_o) ? data_block_i[counter_val_o] : 0;

endmodule