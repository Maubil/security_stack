`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2018 05:05:25 PM
// Design Name: 
// Module Name: edge_detect
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


module edge_detect(
    input clk,
    input reset,
    input in,
    output out
  );
  
  reg in_prev;
  reg out_reg;
  reg again;

  assign out = out_reg;

  always @ (posedge clk or negedge reset)
  begin: reg_update
    if (!reset)
      begin
        in_prev <= 1'b0;
        out_reg <= 1'b0;
        again <= 1'b0;
      end
    else begin // on falling edge set the output HIGH for 2 cycle
      if (in_prev == 1'b1 && in == 1'b0)
        begin
          out_reg <= 1'b1;
          again <= 1'b1;
        end
      else if (again == 1'b1)
        begin
          again <= 1'b0;
        end
      else
        begin
          out_reg <= 1'b0;
        end
    end

    in_prev = in;
  end

    
endmodule
