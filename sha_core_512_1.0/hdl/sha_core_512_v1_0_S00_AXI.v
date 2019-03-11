
`timescale 1 ns / 1 ps

	module sha_core_512_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of ID for for write address, write data, read address and read data
		parameter integer C_S_AXI_ID_WIDTH	= 1,
		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 6,
		// Width of optional user defined signal in write address channel
		parameter integer C_S_AXI_AWUSER_WIDTH	= 0,
		// Width of optional user defined signal in read address channel
		parameter integer C_S_AXI_ARUSER_WIDTH	= 0,
		// Width of optional user defined signal in write data channel
		parameter integer C_S_AXI_WUSER_WIDTH	= 0,
		// Width of optional user defined signal in read data channel
		parameter integer C_S_AXI_RUSER_WIDTH	= 0,
		// Width of optional user defined signal in write response channel
		parameter integer C_S_AXI_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here
		input wire sha512_aclk,
		output wire done,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write Address ID
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
		// Write address
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each
    // write transaction.
		input wire [3 : 0] S_AXI_AWQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_AWREGION,
		// Optional User-defined signal in the write address channel.
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and
    // control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_AWREADY,
		// Write Data
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write last. This signal indicates the last transfer
    // in a write burst.
		input wire  S_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		output wire  S_AXI_WREADY,
		// Response ID tag. This signal is the ID tag of the
    // write response.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
		// Write response. This signal indicates the status
    // of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Optional User-defined signal in the write response channel.
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address ID. This signal is the identification
    // tag for the read address group of signals.
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each
    // read transaction.
		input wire [3 : 0] S_AXI_ARQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_ARREGION,
		// Optional User-defined signal in the read address channel.
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and
    // control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
		// Read Data
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of
    // the read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read last. This signal indicates the last transfer
    // in a read burst.
		output wire  S_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		input wire  S_AXI_RREADY
	);

	// AXI4FULL signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg [C_S_AXI_BUSER_WIDTH-1 : 0] 	axi_buser;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rlast;
	reg [C_S_AXI_RUSER_WIDTH-1 : 0] 	axi_ruser;
	reg  	axi_rvalid;
	// aw_wrap_en determines wrap boundary and enables wrapping
	wire aw_wrap_en;
	// ar_wrap_en determines wrap boundary and enables wrapping
	wire ar_wrap_en;
	// aw_wrap_size is the size of the write transfer, the
	// write address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  aw_wrap_size ; 
	// ar_wrap_size is the size of the read transfer, the
	// read address wraps to a lower address if upper address
	// limit is reached
	wire [31:0]  ar_wrap_size ; 
	// The axi_awv_awr_flag flag marks the presence of write address valid
	reg axi_awv_awr_flag;
	//The axi_arv_arr_flag flag marks the presence of read address valid
	reg axi_arv_arr_flag; 
	// The axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
	reg [7:0] axi_awlen_cntr;
	//The axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
	reg [7:0] axi_arlen_cntr;
	reg [1:0] axi_arburst;
	reg [1:0] axi_awburst;
	reg [7:0] axi_arlen;
	reg [7:0] axi_awlen;
	//local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	//ADDR_LSB is used for addressing 32/64 bit registers/memories
	//ADDR_LSB = 2 for 32 bits (n downto 2) 
	//ADDR_LSB = 3 for 42 bits (n downto 3)

	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32)+ 1;
	localparam integer OPT_MEM_ADDR_BITS = 3;
	localparam integer USER_NUM_MEM = 1;

  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam ADDR_NAME0           = 6'h00; 
  localparam ADDR_NAME1           = 6'h01;
  localparam ADDR_VERSION         = 6'h02;
	localparam ADDR_UUID						= 6'h03;

  localparam ADDR_CTRL            = 6'h08;

	localparam ADDR_BLOCK0          = 6'h10;
  localparam ADDR_BLOCK31         = 6'h2f;

  localparam ADDR_DIGEST0         = 6'h30;
  localparam ADDR_DIGEST15        = 6'h3f;

  localparam CORE_NAME0           = 32'h73686132; // "sha2"
  localparam CORE_NAME1           = 32'h2d353132; // "-512"
  localparam CORE_VERSION         = 32'h302e3031; // "0.01"
	localparam CORE_UUID						= 32'h4d414249; // "MABI"

	//----------------------------------------------
	//-- Signals for user logic memory space example
	//----------------------------------------------
	(* MARK_DEBUG = "TRUE" *) reg [31:0]    control_reg;
	(* MARK_DEBUG = "TRUE" *) reg [31:0]    reg_data_out;
	(* MARK_DEBUG = "TRUE" *) reg [31:0]		block_reg [31:0];
	(* MARK_DEBUG = "TRUE" *) reg [31:0]		digest_reg [15:0];

	(* MARK_DEBUG = "TRUE" *) wire [C_S_AXI_ADDR_WIDTH-1:0] address;
	(* MARK_DEBUG = "TRUE" *) wire [4:0] 		block_addr;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BUSER	= axi_buser;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RLAST	= axi_rlast;
	assign S_AXI_RUSER	= axi_ruser;
	assign S_AXI_RVALID	= axi_rvalid;
	assign S_AXI_BID = S_AXI_AWID;
	assign S_AXI_RID = S_AXI_ARID;
	assign  aw_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_awlen)); 
	assign  ar_wrap_size = (C_S_AXI_DATA_WIDTH/8 * (axi_arlen)); 
	assign  aw_wrap_en = ((axi_awaddr & aw_wrap_size) == aw_wrap_size)? 1'b1: 1'b0;
	assign  ar_wrap_en = ((axi_araddr & ar_wrap_size) == ar_wrap_size)? 1'b1: 1'b0;

	// Implement axi_awready generation

	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	      axi_awv_awr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          // slave is ready to accept an address and
	          // associated control signals
	          axi_awready <= 1'b1;
	          axi_awv_awr_flag  <= 1'b1; 
	          // used for generation of bresp() and bvalid
	        end
	      else if (S_AXI_WLAST && axi_wready)          
	      // preparing to accept next address after current write burst tx completion
	        begin
	          axi_awv_awr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_awaddr latching

	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	      axi_awlen_cntr <= 0;
	      axi_awburst <= 0;
	      axi_awlen <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && ~axi_awv_awr_flag)
	        begin
	          // address latching 
	          axi_awaddr <= S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH - 1:0];  
	           axi_awburst <= S_AXI_AWBURST; 
	           axi_awlen <= S_AXI_AWLEN;     
	          // start address of transfer
	          axi_awlen_cntr <= 0;
	        end   
	      else if((axi_awlen_cntr <= axi_awlen) && axi_wready && S_AXI_WVALID)        
	        begin

	          axi_awlen_cntr <= axi_awlen_cntr + 1;

	          case (axi_awburst)
	            2'b00: // fixed burst
	            // The write address for all the beats in the transaction are fixed
	              begin
	                axi_awaddr <= axi_awaddr;          
	                //for awsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The write address for all the beats in the transaction are increments by awsize
	              begin
	                axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //awaddr aligned to 4 byte boundary
	                axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The write address wraps when the address reaches wrap boundary 
	              if (aw_wrap_en)
	                begin
	                  axi_awaddr <= (axi_awaddr - aw_wrap_size); 
	                end
	              else 
	                begin
	                  axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                  axi_awaddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}}; 
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_awaddr <= axi_awaddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1;
	                //for awsize = 4 bytes (010)
	              end
	          endcase              
	        end
	    end 
	end       
	// Implement axi_wready generation

	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if ( ~axi_wready && S_AXI_WVALID && axi_awv_awr_flag)
	        begin
	          // slave can accept the write data
	          axi_wready <= 1'b1;
	        end
	      //else if (~axi_awv_awr_flag)
	      else if (S_AXI_WLAST && axi_wready)
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       
	// Implement write response logic generation

	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid <= 0;
	      axi_bresp <= 2'b0;
	      axi_buser <= 0;
	    end 
	  else
	    begin    
	      if (axi_awv_awr_flag && axi_wready && S_AXI_WVALID && ~axi_bvalid && S_AXI_WLAST )
	        begin
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; 
	          // 'OKAY' response 
	        end                   
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	          //check if bready is asserted while bvalid is high) 
	          //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	 end   
	// Implement axi_arready generation

	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_arv_arr_flag <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_awv_awr_flag && ~axi_arv_arr_flag)
	        begin
	          axi_arready <= 1'b1;
	          axi_arv_arr_flag <= 1'b1;
	        end
	      else if (axi_rvalid && S_AXI_RREADY && axi_arlen_cntr == axi_arlen)
	      // preparing to accept next address after current read completion
	        begin
	          axi_arv_arr_flag  <= 1'b0;
	        end
	      else        
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       
	// Implement axi_araddr latching

	//This process is used to latch the address when both 
	//S_AXI_ARVALID and S_AXI_RVALID are valid. 
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_araddr <= 0;
	      axi_arlen_cntr <= 0;
	      axi_arburst <= 0;
	      axi_arlen <= 0;
	      axi_rlast <= 1'b0;
	      axi_ruser <= 0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID && ~axi_arv_arr_flag)
	        begin
	          // address latching 
	          axi_araddr <= S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH - 1:0]; 
	          axi_arburst <= S_AXI_ARBURST; 
	          axi_arlen <= S_AXI_ARLEN;     
	          // start address of transfer
	          axi_arlen_cntr <= 0;
	          axi_rlast <= 1'b0;
	        end   
	      else if((axi_arlen_cntr <= axi_arlen) && axi_rvalid && S_AXI_RREADY)        
	        begin
	         
	          axi_arlen_cntr <= axi_arlen_cntr + 1;
	          axi_rlast <= 1'b0;
	        
	          case (axi_arburst)
	            2'b00: // fixed burst
	             // The read address for all the beats in the transaction are fixed
	              begin
	                axi_araddr       <= axi_araddr;        
	                //for arsize = 4 bytes (010)
	              end   
	            2'b01: //incremental burst
	            // The read address for all the beats in the transaction are increments by awsize
	              begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                //for awsize = 4 bytes (010)
	              end   
	            2'b10: //Wrapping burst
	            // The read address wraps when the address reaches wrap boundary 
	              if (ar_wrap_en) 
	                begin
	                  axi_araddr <= (axi_araddr - ar_wrap_size); 
	                end
	              else 
	                begin
	                axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB] + 1; 
	                //araddr aligned to 4 byte boundary
	                axi_araddr[ADDR_LSB-1:0]  <= {ADDR_LSB{1'b0}};   
	                end                      
	            default: //reserved (incremental burst for example)
	              begin
	                axi_araddr <= axi_araddr[C_S_AXI_ADDR_WIDTH - 1:ADDR_LSB]+1;
	                //for arsize = 4 bytes (010)
	              end
	          endcase              
	        end
	      else if((axi_arlen_cntr == axi_arlen) && ~axi_rlast && axi_arv_arr_flag )   
	        begin
	          axi_rlast <= 1'b1;
	        end          
	      else if (S_AXI_RREADY)   
	        begin
	          axi_rlast <= 1'b0;
	        end          
	    end 
	end       
	// Implement axi_arvalid generation

	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arv_arr_flag && ~axi_rvalid)
	        begin
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; 
	          // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          axi_rvalid <= 1'b0;
	        end            
	    end
	end    
	
	//----------------------------------------------------
	//-- Add user logic here
	//----------------------------------------------------

	assign done = cmd_o[4];
	assign address = (axi_arv_arr_flag == 1'b1) ? axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] : (axi_awv_awr_flag == 1'b1) ? axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] : 0;
	assign block_addr = address[4:0] - ADDR_BLOCK0[4 : 0]; // for the AXI4 internal block

	wire [31:0]		text_i; // only used for the SHA data
	wire [31:0]		text_o; // only used for the digest result
	reg [3:0]		cmd_i;	// here we have the control bus of the core -> is written on clock rising edge and cmd_w_i HIGH !! (posedge clk and cmd_w_i == 1'b1)
																																		// else it's just ignored!
																																		// cmd[0] is read output values 	-> needs to be set before reading the output
																																		// cmd[1] is start input 					-> needs to be set to write the mode and start computation (see sha512 simulation for more info)
																																		// cmd[3:2] is the mode => 	2'b00 -> sha-384 first message
																																		//													2'b01 -> sha-384 internal message
																																		//													2'b10 -> sha-512 first message
																																		//													2'b11 -> sha-512 internal message
	reg 					cmd_w_i;
	wire [4:0]		cmd_o;	// read the same values as cmd_i with one difference
																																		// cmd[4] is the busy bit -> set HIGH when computing, LOW when done


	wire read;
	wire write;
	wire counter_val_o;
	wire counter_done;

	sha512 core(.clk_i(sha512_aclk), 
							.rst_i(~S_AXI_ARESETN),
							.text_i(text_i),
							.text_o(text_o),
							.cmd_i(cmd_i),
							.cmd_w_i(cmd_w_i),
							.cmd_o(cmd_o)
						 );

	up_counter core(.clk(sha512_aclk), .reset(S_AXI_ARESETN), .start(start), .counter(counter_val_o), .done(counter_done));
	assign text_i = (write | ~counter_done) ? block_reg[counter_val_o] : 0;

	wire start;

	// falling edge on counter_done writes the result back into the digest_reg
	edge_detect(0)(sha512_aclk, S_AXI_ARESETN, control_reg[0], start);

parameter IDLE = 3'b000, WRITE = 3'b001, FIRST_ROUND = 3'b010, DONE0 = 3'b011, INTERNAL_ROUND = 3'b100, DONE1 = 3'b101;

	reg   [2:0]          state;
	wire  [2:0]          next_state;

	assign next_state = fsm_function(state, start, counter_done, done);

	function [2:0] fsm_function;
		input  [2:0] state;
		input    start ;
		input    loaded ;
		input 	 sha_done;
		case(state)
			IDLE : 
				if (start == 1'b1)
					begin
						fsm_function = WRITE;
					end
				else
					begin
						fsm_function = IDLE;
					end
			WRITE : 
				if (loaded == 1'b1)
					begin
						fsm_function = FIRST_ROUND;
					end
				else
					begin
						fsm_function = WRITE;
					end
			FIRST_ROUND : 
				if (sha_done == 1'b1) 
					begin
						fsm_function = DONE0;
					end
				else 
					begin
						fsm_function = FIRST_ROUND;
					end
			DONE0 : 
				if (sha_done == 1'b0) 
					begin
						fsm_function = INTERNAL_ROUND;
					end
				else 
					begin
						fsm_function = DONE0;
					end
			INTERNAL_ROUND:
				if (sha_done == 1'b1) 
					begin
						fsm_function = INTERNAL_ROUND;
					end
				else 
					begin
						fsm_function = DONE0;
					end
			DONE1 : 
				if (sha_done == 1'b0) 
					begin
						fsm_function = IDLE;
					end
				else 
					begin
						fsm_function = DONE1;
					end

			default : fsm_function = IDLE;
		endcase
	endfunction

	reg mode; // 1 = SHA512 // 0 = SHA384
	reg round; // 0 first round // 1 = internal round

	assign cmd_i = {mode, round, write, read};

	// api logic
	always @(posedge sha512_aclk)
	begin : api_op
		if ( S_AXI_ARESETN == 1'b0 )
	    begin
				cmd_w_i <= 1'b0;
				mode <= 1'b0;
			end
		else
			begin
				case(state)
					IDLE: begin
						mode <= control_reg[2];
						round <= 1'b0;
						write <= 1'b1;
					end
					WRITE: begin
						cmd_i[3:2] <= {mode, 1'b0};
						cmd_w_i <= 1'b1;
					default: begin

					end
				endcase
			end
	end

	always @(posedge sha512_aclk)
	begin
		if ( S_AXI_ARESETN == 1'b0 )
	    begin
				state <= IDLE;
			end
		else
			begin
				state <= next_state;
			end
	end

	/*
	@(posedge clk);
	cmd_i = 4'b1010;
	cmd_w_i = 1'b1;
	
	for (i=0;i<32;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[32*32-1:31*32];
		tmp_i = tmp_i << 32;
	end

	@(posedge clk); * 5

	while (cmd_o[4])
		@(posedge clk);
	
	@(posedge clk); * 5
	
	#100;
	
	tmp_i = all_message[1023:0];
	@(posedge clk);
	cmd_i = 4'b1110;
	cmd_w_i = 1'b1;
	
	for (i=0;i<32;i=i+1)
	begin
		@(posedge clk);
		cmd_w_i = 1'b0;
		text_i = tmp_i[32*32-1:31*32];
		tmp_i = tmp_i << 32;
	end

	@(posedge clk); * 5

	while (cmd_o[4])
		@(posedge clk);
	
	@(posedge clk); * 5

	cmd_i = 4'b1001;
	cmd_w_i = 1'b1;
	
	@(posedge clk);
	cmd_w_i = 1'b0;
	for (i=0;i<16;i=i+1)
	begin
		@(posedge clk);
		#1;
		tmp = tmp_o[16*32-1:15*32];
		if (text_o !== tmp | (|text_o)===1'bx)
		begin
			$display("ERROR(SHA-512-%02d) Expected %x, Got %x", i,tmp, text_o);
		end
		else
		begin
			$display("OK(SHA-512-%02d),Expected %x, Got %x", i,tmp, text_o);
		end
		tmp_o = tmp_o << 32;
	end	

	*/

	// update output values
	always @(posedge sha512_aclk)
	begin
		if ( S_AXI_ARESETN == 1'b0 )
	    begin
	  		digest_reg <= 0;
	  		ready_reg <= 0;
	  		digest_valid_reg <= 0;
			end
		else
			begin
				if (core_digest_valid == 1'b1)
					begin
						digest_reg <= core_digest;
					end
					else
						begin
							digest_reg <= 0;
						end

					ready_reg <= core_ready;
					digest_valid_reg <= core_digest_valid;
				end
	end

	// write operation
	always @( posedge S_AXI_ACLK )
	begin : write_op
		integer i;
		integer byte_index;

	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
				for (i = 0 ; i < 32 ; i = i + 1)
            block_reg[i] <= 32'h0;

				control_reg <= 0;
	    end 
	  else begin
	    if (axi_wready && S_AXI_WVALID)
	      begin
					if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK31))
						begin
							for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
								if ( S_AXI_WSTRB[byte_index] == 1 ) begin
									block_reg[block_addr][(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
								end  
						end
					else
						begin
							case ( address )
								ADDR_CTRL:
									for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
										if ( S_AXI_WSTRB[byte_index] == 1 ) begin
											control_reg[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
										end
								default :
									begin
									   for (i = 0 ; i < 32 ; i = i + 1)
										  block_reg[i] <= block_reg[i];
										control_reg <= control_reg;
									end
							endcase
						end
	      end
	  end
	end

	// read logic
	always @(*)
	begin : read_op
		if ((address >= ADDR_DIGEST0) && (address <= ADDR_DIGEST15))
			reg_data_out = digest_reg[(15 - (address - ADDR_DIGEST0)) * 32 +: 32];

		else if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK31))
			reg_data_out = block_reg[address[4 : 0] - ADDR_BLOCK0[4 : 0]];

		else
			begin
				case (address)
					// Read operations.
					ADDR_NAME0:
						reg_data_out = CORE_NAME0;

					ADDR_NAME1:
						reg_data_out = CORE_NAME1;

					ADDR_VERSION:
						reg_data_out = CORE_VERSION;

					ADDR_UUID:
						reg_data_out = CORE_UUID;

					ADDR_CTRL:
						reg_data_out = {29'h0, cmd_o[3:2], done};

					default: reg_data_out <= 0;
				endcase // case (address)
			end
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (axi_arv_arr_flag)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    

	//----------------------------------------------------
	//-- User logic ends
	//----------------------------------------------------

	endmodule