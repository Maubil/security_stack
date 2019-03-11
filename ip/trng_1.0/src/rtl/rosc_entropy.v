//======================================================================
//
// rosc_entropy.v
// --------------
// Top level wrapper for the ring oscillator entropy core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2014, Secworks Sweden AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module rosc_entropy(
                    input wire           clk,
                    input wire           reset_n,

                    input wire           cs,
                    input wire           we,
                    input wire  [7 : 0]  address,
                    input wire  [31 : 0] write_data,
                    output wire [31 : 0] read_data,
                    output wire          error,

                    input wire           discard,
                    input wire           test_mode,
                    output wire          security_error,

                    output wire          entropy_enabled,
                    output wire [31 : 0] entropy_data,
                    output wire          entropy_valid,
                    input wire           entropy_ack,

                    output wire [7 : 0]  debug,
                    input wire           debug_update
                   );


  //----------------------------------------------------------------
  // Parameters.
  //----------------------------------------------------------------
  parameter ADDR_NAME0               = 8'h00;
  parameter ADDR_NAME1               = 8'h01;
  parameter ADDR_VERSION             = 8'h02;

  parameter ADDR_CTRL                = 8'h10;

  parameter ADDR_STATUS              = 8'h11;
  parameter STATUS_ENTROPY_VALID_BIT = 0;

  parameter ADDR_ROSC_CYCLES         = 8'h14;

  parameter ADDR_OP_A                = 8'h18;
  parameter ADDR_OP_B                = 8'h19;

  parameter ADDR_ENTROPY             = 8'h20;
  parameter ADDR_RAW                 = 8'h21;
  parameter ADDR_ROSC_OUTPUTS        = 8'h22;

  parameter DEFAULT_ROSC_EN          = 32'hffffffff;
  parameter DEFAULT_ROSC_CYCLES      = 8'hff;
  parameter DEFAULT_OP_A             = 32'haaaaaaaa;
  parameter DEFAULT_OP_B             = ~DEFAULT_OP_A;

  parameter CORE_NAME0               = 32'h726f7363; // "rosc"
  parameter CORE_NAME1               = 32'h20656e74; // " ent"
  parameter CORE_VERSION             = 32'h302e3130; // "0.10"


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [31 : 0] enable_reg;
  reg          enable_we;

  reg [7 : 0]  rosc_cycles_reg;
  reg [7 : 0]  rosc_cycles_we;

  reg [31 : 0] op_a_reg;
  reg          op_a_we;

  reg [31 : 0] op_b_reg;
  reg          op_b_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  wire [31 : 0] raw_entropy;
  wire [31 : 0] rosc_outputs;

  wire [31 : 0] internal_entropy_data;
  wire          internal_entropy_valid;
  wire          internal_entropy_ack;
  reg           api_entropy_ack;

  reg [31 : 0]  tmp_read_data;
  reg           tmp_error;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign read_data            = tmp_read_data;
  assign error                = tmp_error;
  assign security_error       = 0;

  assign entropy_enabled      = |enable_reg;
  assign entropy_data         = internal_entropy_data;
  assign entropy_valid        = internal_entropy_valid;
  assign internal_entropy_ack = api_entropy_ack | entropy_ack;


  //----------------------------------------------------------------
  // module instantiations.
  //----------------------------------------------------------------
  rosc_entropy_core core(
                         .clk(clk),
                         .reset_n(reset_n),

                         .opa(op_a_reg),
                         .opb(op_b_reg),

                         .rosc_en(enable_reg),
                         .rosc_cycles(rosc_cycles_reg),

                         .raw_entropy(raw_entropy),
                         .rosc_outputs(rosc_outputs),

                         .entropy_data(internal_entropy_data),
                         .entropy_valid(internal_entropy_valid),
                         .entropy_ack(internal_entropy_ack),

                         .debug(debug),
                         .debug_update(debug_update)
                        );


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin
      if (!reset_n)
        begin
          enable_reg      <= 32'hffffffff;
          rosc_cycles_reg <= 8'hff;
          op_a_reg        <= DEFAULT_OP_A;
          op_b_reg        <= DEFAULT_OP_B;
        end
      else
        begin
          if (enable_we)
            begin
              enable_reg <= write_data;
            end

          if (rosc_cycles_we)
            begin
              rosc_cycles_reg <= write_data[7 : 0];
            end

          if (op_a_we)
            begin
              op_a_reg <=  write_data;
            end

          if (op_b_we)
            begin
              op_b_reg <=  write_data;
            end
         end
    end // reg_update


  //----------------------------------------------------------------
  // api_logic
  //
  // Implementation of the api logic. If cs is enabled will either
  // try to write to or read from the internal registers.
  //----------------------------------------------------------------
  always @*
    begin : api_logic
      enable_we       = 0;
      rosc_cycles_we  = 0;
      op_a_we         = 0;
      op_b_we         = 0;
      api_entropy_ack = 0;
      tmp_read_data   = 32'h00000000;
      tmp_error       = 0;

      if (cs)
        begin
          if (we)
            begin
              case (address)
                // Write operations.
                ADDR_CTRL:
                  begin
                    enable_we  = 1;
                  end

                ADDR_ROSC_CYCLES:
                  begin
                    rosc_cycles_we = 1;
                  end

                ADDR_OP_A:
                  begin
                    op_a_we  = 1;
                  end

                ADDR_OP_B:
                  begin
                    op_b_we  = 1;
                  end

                default:
                  begin
                    tmp_error = 1;
                  end
              endcase // case (address)
            end
          else
            begin
              case (address)
                ADDR_NAME0:
                  begin
                    tmp_read_data = CORE_NAME0;
                  end

                ADDR_NAME1:
                  begin
                    tmp_read_data = CORE_NAME1;
                  end

                ADDR_VERSION:
                  begin
                    tmp_read_data = CORE_VERSION;
                  end

                ADDR_CTRL:
                  begin
                    tmp_read_data = enable_reg;
                  end

                ADDR_STATUS:
                  begin
                    tmp_read_data[STATUS_ENTROPY_VALID_BIT] = internal_entropy_valid;
                  end

                ADDR_ROSC_CYCLES:
                  begin
                    tmp_read_data = rosc_cycles_reg;
                  end

                ADDR_OP_A:
                  begin
                    tmp_read_data = op_a_reg;
                  end

                ADDR_OP_B:
                  begin
                    tmp_read_data = op_b_reg;
                  end

                ADDR_ENTROPY:
                  begin
                    tmp_read_data = entropy_data;
                    api_entropy_ack = 1;
                  end

                ADDR_RAW:
                  begin
                    tmp_read_data = raw_entropy;
                  end

                ADDR_ROSC_OUTPUTS:
                  begin
                    tmp_read_data = rosc_outputs;
                  end

                default:
                  begin
                    tmp_error = 1;
                  end
              endcase // case (address)
            end
        end
    end

endmodule // rosc_entropy_core

//======================================================================
// EOF rosc_entropy_core.v
//======================================================================
