`timescale 1 ns / 1 ps

	// done is guaranteed to be low when start is high or the counter is actually counting up
	// counter value is incremented each clock cycle until reaching max value
	module up_counter(input wire clk, input wire reset, input wire start, output wire [4:0] counter, output wire done);
		reg [4:0] counter_up;
		reg done_reg;
    reg not_run_since_reset;

		// up counter
		always @(posedge clk or posedge reset)
			begin
        if(reset == 1'b0)
          begin
            counter_up <= 5'd0;
            done_reg <= 1'b0;
            not_run_since_reset <= 1'b1;
          end
        else if (counter_up == 5'b11111)
          begin
            counter_up <= 5'd0;
            done_reg <= 1'b1;
          end
        else if (start == 1'b1)
          begin
            done_reg <= 1'b0;
            not_run_since_reset <= 1'b0;
          end
        else if (done_reg == 1'b0 && not_run_since_reset == 1'b0)
          begin
            counter_up <= counter_up + 5'd1;
          end
		  end 
		assign counter = counter_up;
		// ensure that done is not set when start is high
		assign done = (start == 1'b1) ? 1'b0 : done_reg;
	endmodule