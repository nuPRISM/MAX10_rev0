`ifdef SOFTWARE_IS_QUARTUS
   `include "interface_defs.v"
`endif
module variable_compact_registers_keeper_ver3
(	
  READ_LD,
  DATA,
  ADDRESS,
  CLK,
  READ_EN,
  WRITE_EN,
  ACTIVE_HIGH_ASYNC_RESET,
  IS_STATUS_OP,
  IS_INFO_OP,
  IS_CTRL_NAME_OP,
  IS_STATUS_NAME_OP,
  CONTROL,
  CONTROL_BITWIDTH,
  CONTROL_DESC,
  CONTROL_OMIT_DESC,
  CONTROL_SHORT_TO_DEFAULT,
  STATUS,
  STATUS_BITWIDTH,
  STATUS_DESC,
  STATUS_OMIT,
  STATUS_OMIT_DESC,
  CONTROL_INIT_VAL,
  TRANSACTION_ERROR,
  DISPLAY_NAME,
  USER_TYPE,
  WR_ERROR,
  RD_ERROR,
  NUM_SECONDARY_UARTS,
  ADDRESS_OF_THIS_UART,
  IS_SECONDARY_UART,
  CLOCK_FREQ_HZ,
  WATCHDOG_TIMEOUT_LIMIT,
  CURRENT_WATCHDOG_COUNT,
  WATCHDOG_EVENT_COUNT
  `ifdef SOFTWARE_IS_QUARTUS
		  ,
		  status_wishbone_interface,
		  control_wishbone_interface  
  `endif
);


	function automatic int log2 (input int n);
						if (n <=1) return 1; // abort function
						log2 = 0;
						while (n > 1) begin
						n = n/2;
						log2++;
						end
						endfunction


  parameter [15:0] DATA_WIDTH                            =  8;
  parameter	[15:0] DESC_WIDTH                            =  8;
  parameter	[15:0] ACTUAL_DATA_WIDTH                     = (DESC_WIDTH > DATA_WIDTH) ? DESC_WIDTH : DATA_WIDTH;
  parameter [15:0] NUM_OF_CONTROL_REGS                   =  16;
  parameter [15:0] NUM_OF_STATUS_REGS                    =   8;
  parameter [15:0] ADDRESS_WIDTH                         =  16;
  parameter [15:0] STATUS_ADDRESS_START                  =  NUM_OF_CONTROL_REGS;
  parameter [0:0] INIT_ALL_CONTROL_REGS_TO_DEFAULT      =  1'b1;
  parameter [DATA_WIDTH-1:0] CONTROL_REGS_DEFAULT_VAL    =  {DATA_WIDTH{1'b0}};
  parameter [0:0]    USE_AUTO_RESET                        =  1'b1;
  parameter [0:0]    ENABLE_CONTROL_WISHBONE_INTERFACE           = 1'b0;
  parameter [0:0]    ENABLE_STATUS_WISHBONE_INTERFACE            = 1'b0;
  parameter [0:0]    WISHBONE_INTERFACE_IS_PART_OF_BRIDGE        = 1'b0;
  parameter [0:0]    DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 1'b0;
  parameter [0:0]    ENABLE_ERROR_MONITORING                     = 1'b0;
  parameter [0:0]    IGNORE_TIMING_TO_READ_LD                    = 1'b0;
  parameter [0:0]    USE_GENERIC_ATTRIBUTE_FOR_READ_LD           = 1'b0;
  parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = ENABLE_STATUS_WISHBONE_INTERFACE ? $clog2(NUM_OF_STATUS_REGS) : 0; 
  parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = ENABLE_CONTROL_WISHBONE_INTERFACE ? $clog2(NUM_OF_CONTROL_REGS) : 0;   
  parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS     = 0;
  parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS      = 0;
  parameter [15:0] NUM_OF_CLOCKS_TO_WAIT_BEFORE_AUTORESET = 1;
  parameter [15:0] LENGTH_OF_AUTORESET_PULSE = 10;
  parameter [0:0] COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0;
  parameter ENABLE_KEEPS = 0;
  /*
  parameter [0:0]    SET_MAX_DELAY_TIMING_TO_READ_LD = 1'b0;
  parameter [31:0]    MAX_DELAY_TIMING_TO_READ_LD = 1'b0;
  */
  parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR";
  
 output [ACTUAL_DATA_WIDTH   -1:0] READ_LD;
 generate
		 if ((!IGNORE_TIMING_TO_READ_LD) && (!USE_GENERIC_ATTRIBUTE_FOR_READ_LD))
		 begin
				(* keep = 1, preserve = 1  *) reg  [ACTUAL_DATA_WIDTH   -1:0] READ_LD = 0;
		 end else if (IGNORE_TIMING_TO_READ_LD)
		 begin		 
		       (* keep = 1, preserve = 1, altera_attribute = "-name CUT ON -from *"  *) reg  [ACTUAL_DATA_WIDTH   -1:0] READ_LD = 0;
		 end else if (USE_GENERIC_ATTRIBUTE_FOR_READ_LD)
		 begin
		      (* keep = 1, preserve = 1, altera_attribute = GENERIC_ATTRIBUTE_FOR_READ_LD  *) reg  [ACTUAL_DATA_WIDTH   -1:0] READ_LD = 0;
		 end
 endgenerate
 
 input  wire [ACTUAL_DATA_WIDTH   -1:0]			 DATA;
 input  wire [ADDRESS_WIDTH-1:0]			 ADDRESS;
 input  wire 					             CLK;
 input  wire 					             READ_EN;
 input  wire 					             WRITE_EN;
 input  wire                                 ACTIVE_HIGH_ASYNC_RESET;
 input  wire                                 IS_STATUS_OP;
 input  wire                                 IS_INFO_OP;
 input  wire                                 IS_CTRL_NAME_OP;
 input  wire                                 IS_STATUS_NAME_OP;
 input wire  [7:0]                           USER_TYPE;

input [DATA_WIDTH-1:0] CONTROL_BITWIDTH[NUM_OF_CONTROL_REGS-1:0];
input [DATA_WIDTH-1:0] STATUS_BITWIDTH [NUM_OF_STATUS_REGS-1:0];
					

 output wire [DATA_WIDTH-1:0]                CONTROL[NUM_OF_CONTROL_REGS-1:0];
 input  wire [DESC_WIDTH-1:0]                CONTROL_DESC[NUM_OF_CONTROL_REGS-1:0];
 input  wire                                 CONTROL_SHORT_TO_DEFAULT[NUM_OF_CONTROL_REGS-1:0];
 input  wire                                 CONTROL_OMIT_DESC[NUM_OF_CONTROL_REGS-1:0];
 
 input  wire [DATA_WIDTH-1:0]                STATUS [NUM_OF_STATUS_REGS-1:0];
 input  wire [DESC_WIDTH-1:0]                STATUS_DESC[NUM_OF_STATUS_REGS-1:0];
 input  wire                                 STATUS_OMIT[NUM_OF_STATUS_REGS-1:0];
 input  wire                                 STATUS_OMIT_DESC[NUM_OF_STATUS_REGS-1:0];

 input wire [7:0] NUM_SECONDARY_UARTS;
 input wire [7:0] ADDRESS_OF_THIS_UART;
 input wire       IS_SECONDARY_UART;
 

 input  wire [DATA_WIDTH-1:0]                CONTROL_INIT_VAL[NUM_OF_CONTROL_REGS-1:0];
 
 input wire [31:0] CLOCK_FREQ_HZ         ;
 input wire [31:0] WATCHDOG_TIMEOUT_LIMIT;
 input wire [31:0] CURRENT_WATCHDOG_COUNT;
 input wire [15:0] WATCHDOG_EVENT_COUNT;

 input [127:0] DISPLAY_NAME;

 output wire                                 TRANSACTION_ERROR;
 output reg                                  WR_ERROR = 0;
 output reg                                  RD_ERROR = 0;
  
  

 reg [15:0] total_read_errors  = 0;
 reg [15:0] total_write_errors = 0;
 parameter [7:0] VERSION = 3;
 wire auto_reset;
 wire [DATA_WIDTH-1:0] POSSIBLY_CROPPED_CONTROL_OUTPUT_DATA[NUM_OF_CONTROL_REGS-1:0];
 wire [DATA_WIDTH-1:0] actual_CONTROL_BITWIDTH[NUM_OF_CONTROL_REGS-1:0];



 genvar actual_ctrl_index;
 generate
		  for (actual_ctrl_index = 0; actual_ctrl_index < NUM_OF_CONTROL_REGS; actual_ctrl_index++)
		  begin : get_actual_control_bitwidths				
				   assign actual_CONTROL_BITWIDTH[actual_ctrl_index]  = ((CONTROL_INIT_VAL[actual_ctrl_index] == 0) && (CONTROL_BITWIDTH[actual_ctrl_index] == 0) && (CONTROL_DESC[actual_ctrl_index] == 0)  && (!DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS)) ? 1 : CONTROL_BITWIDTH[actual_ctrl_index];	//default to width of 1 for unamed registers with no description and no assigned bitwidth and no default value
 		  end
 endgenerate
 
/*
generate_one_shot_pulse 
#(.num_clks_to_wait(NUM_OF_CLOCKS_TO_WAIT_BEFORE_AUTORESET))  
generate_auto_reset
(
.clk(CLK), 
.oneshot_pulse(auto_reset)
);
*/
generate_controlled_length_auto_reset_pulse
#(
.default_count(LENGTH_OF_AUTORESET_PULSE),
.wait_clks_before_start(NUM_OF_CLOCKS_TO_WAIT_BEFORE_AUTORESET),
.num_bits_counter(16)
)
generate_auto_reset
(
.async_level_reset(1'b0),
.pulse_out(auto_reset),
.clk(CLK)
);

wire actual_reset = USE_AUTO_RESET ? (auto_reset ||  ACTIVE_HIGH_ASYNC_RESET) : ACTIVE_HIGH_ASYNC_RESET;

`ifdef SOFTWARE_IS_QUARTUS
     wishbone_interface status_wishbone_interface;
     wishbone_interface control_wishbone_interface;  
	 (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  [DATA_WIDTH-1:0] STATUS_WISHBONE_KEEP_DATA_REG;
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  [DATA_WIDTH-1:0] CONTROL_WISHBONE_KEEP_DATA_REG;
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  STATUS_WISHBONE_KEEP_ACK_REG;
     (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  CONTROL_WISHBONE_KEEP_ACK_REG;
 
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// CONTROL Wishbone
		//
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////

		// generate wishbone signals
		wire control_wb_wacc;
		assign control_wb_wacc	= ENABLE_CONTROL_WISHBONE_INTERFACE ? (control_wishbone_interface.wbs_cyc_i & control_wishbone_interface.wbs_stb_i & control_wishbone_interface.wbs_we_i) : 0;

		// generate acknowledge output signal
		always @(posedge CLK)
		begin					 
			CONTROL_WISHBONE_KEEP_ACK_REG <= #1 control_wishbone_interface.wbs_cyc_i & control_wishbone_interface.wbs_stb_i & ~control_wishbone_interface.wbs_ack_o; // because timing is always honored
		end
		
		assign control_wishbone_interface.wbs_ack_o = CONTROL_WISHBONE_KEEP_ACK_REG;

		// assign DAT_O
		always @(posedge CLK)
		begin
			  CONTROL_WISHBONE_KEEP_DATA_REG  <=  POSSIBLY_CROPPED_CONTROL_OUTPUT_DATA[control_wishbone_interface.wbs_adr_i];
		end	

		assign control_wishbone_interface.wbs_dat_o = CONTROL_WISHBONE_KEEP_DATA_REG;
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// STATUS Wishbone
		//
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////


		// generate acknowledge output signal
		always @(posedge CLK)
		begin
			  STATUS_WISHBONE_KEEP_ACK_REG <= #1 status_wishbone_interface.wbs_cyc_i & status_wishbone_interface.wbs_stb_i & ~status_wishbone_interface.wbs_ack_o; // because timing is always honored
		end	
		
		assign status_wishbone_interface.wbs_ack_o = STATUS_WISHBONE_KEEP_ACK_REG;
		
		
		// assign DAT_O
		always @(posedge CLK)
		begin
			  STATUS_WISHBONE_KEEP_DATA_REG <= STATUS[status_wishbone_interface.wbs_adr_i]; //will only work up to 32 bits!
		end

		assign status_wishbone_interface.wbs_dat_o = STATUS_WISHBONE_KEEP_DATA_REG;
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
`endif  
	
assign TRANSACTION_ERROR = WR_ERROR || RD_ERROR;
genvar i;
generate

			if (INIT_ALL_CONTROL_REGS_TO_DEFAULT[0])
			begin
				  for (i = 0; i < NUM_OF_CONTROL_REGS; i=i+1)
				  begin : write_ctrl_register_block
				            wire [DATA_WIDTH-1:0] POSSIBLY_CROPPED_DATA;

				            select_partial_register_bus
							#(
							  .width(DATA_WIDTH+1)
							  )
							 select_partial_CONTROL_REG_bus
							 (
							  .indata(CONTROL_SHORT_TO_DEFAULT[i] ?  CONTROL_INIT_VAL[i] : DATA),
							  .outdata(POSSIBLY_CROPPED_DATA),
							  .number_of_bits_to_output(actual_CONTROL_BITWIDTH[i])
							);
							
							`ifdef SOFTWARE_IS_QUARTUS
        							wire [DATA_WIDTH-1:0] POSSIBLY_CROPPED_DATA_WISHBONE;

									select_partial_register_bus
									#(
									  .width(DATA_WIDTH+1)
									   )
									 select_partial_CONTROL_REG_bus_for_wishbone
									 (
									  .indata(CONTROL_SHORT_TO_DEFAULT[i] ?  CONTROL_INIT_VAL[i] : control_wishbone_interface.wbs_dat_i),
									  .outdata(POSSIBLY_CROPPED_DATA_WISHBONE),
									  .number_of_bits_to_output(actual_CONTROL_BITWIDTH[i])
									);
							`endif
									
							wire control_enable = ((WRITE_EN) && (i == ADDRESS));
							reg [DATA_WIDTH-1:0] CONTROL_REG = CONTROL_REGS_DEFAULT_VAL;
							assign CONTROL[i] = CONTROL_REG;
							
							`ifdef UART_REGISTER_FILES_USE_SYNCRONOUS_RESET
							always @(posedge CLK)
							`else
							always @(posedge CLK or posedge actual_reset)
							`endif
							begin   
								 if (actual_reset)
								 begin
									   CONTROL_REG <= CONTROL_REGS_DEFAULT_VAL;							
								 end else
								 begin
									  if (control_enable)
									  begin
										   CONTROL_REG <= POSSIBLY_CROPPED_DATA;
									  end
 							          `ifdef SOFTWARE_IS_QUARTUS
											  else 
											  begin
													 if (control_wb_wacc && (control_wishbone_interface.wbs_adr_i == i))
													 begin
														   CONTROL_REG <= POSSIBLY_CROPPED_DATA_WISHBONE;
													 end
											  end
									  `endif
								end
							end
					 end
			end else 
			begin
					  for (i = 0; i < NUM_OF_CONTROL_REGS; i=i+1)
					  begin : write_ctrl_register_block
					        wire [DATA_WIDTH-1:0] POSSIBLY_CROPPED_DATA;
				            select_partial_register_bus
							#(
							  .width(DATA_WIDTH+1)
							   )
							 select_partial_CONTROL_REG_bus
							 (
							  .indata(CONTROL_SHORT_TO_DEFAULT[i] ?  CONTROL_INIT_VAL[i] : DATA),
							  .outdata(POSSIBLY_CROPPED_DATA),
							  .number_of_bits_to_output(actual_CONTROL_BITWIDTH[i])
							);
							
					        `ifdef SOFTWARE_IS_QUARTUS
							        wire [DATA_WIDTH-1:0] POSSIBLY_CROPPED_DATA_WISHBONE;

									select_partial_register_bus
									#(
									  .width(DATA_WIDTH+1)
									   )
									 select_partial_CONTROL_REG_bus_for_wishbone
									 (
									  .indata(CONTROL_SHORT_TO_DEFAULT[i] ?  CONTROL_INIT_VAL[i] : control_wishbone_interface.wbs_dat_i),
									  .outdata(POSSIBLY_CROPPED_DATA_WISHBONE),
									  .number_of_bits_to_output(actual_CONTROL_BITWIDTH[i])
									);
							`endif
							
							wire control_enable = ((WRITE_EN) && (i == ADDRESS));
							reg [DATA_WIDTH-1:0] CONTROL_REG;
							assign CONTROL[i] = CONTROL_REG;
							
							`ifdef UART_REGISTER_FILES_USE_SYNCRONOUS_RESET
							always @(posedge CLK)
							`else
							always @(posedge CLK or posedge actual_reset)
							`endif
							begin   
								 if (actual_reset)
								 begin
										CONTROL_REG <= CONTROL_INIT_VAL[i];			    							
								 end else
								 begin
									  if (control_enable)
									  begin
										   CONTROL_REG <= POSSIBLY_CROPPED_DATA;
									  end
 							          `ifdef SOFTWARE_IS_QUARTUS
									  else 
									  begin
									         if (control_wb_wacc && (control_wishbone_interface.wbs_adr_i == i))
											 begin
											       CONTROL_REG <= POSSIBLY_CROPPED_DATA_WISHBONE;
											 end
									  end
									  `endif
								end
							end
					 end
			end
endgenerate


genvar output_ctrl_index;
generate
		  for (output_ctrl_index = 0; output_ctrl_index < NUM_OF_CONTROL_REGS; output_ctrl_index++)
		  begin : crop_CONTROL_output
				
				   select_partial_register_bus
				   #(
					 .width(DATA_WIDTH+1)
					)
					select_partial_OUTPUT_CONTROL_REG_bus
					(
					//.indata(write_ctrl_register_block[output_ctrl_index].CONTROL_REG), //works with quartus, not with modelsim
					 .indata(CONTROL[output_ctrl_index]),
					 .outdata(POSSIBLY_CROPPED_CONTROL_OUTPUT_DATA[output_ctrl_index]),
					 .number_of_bits_to_output(actual_CONTROL_BITWIDTH[output_ctrl_index])
					);
		   end
 endgenerate




wire [ADDRESS_WIDTH-1:0]			 ACTUAL_ADDRESS;
assign ACTUAL_ADDRESS = (IS_STATUS_OP || IS_STATUS_NAME_OP) ? ADDRESS+STATUS_ADDRESS_START : ADDRESS;

wire [1:0] ERROR_MONITOR_STRING;
generate
		if (!ENABLE_ERROR_MONITORING)
		begin
				assign ERROR_MONITOR_STRING = 0;
		end
		else
		begin
				assign ERROR_MONITOR_STRING = {WR_ERROR,RD_ERROR};

		end
endgenerate


`ifdef UART_REGISTER_FILES_USE_SYNCRONOUS_RESET
always @(posedge CLK)
`else
always @(posedge CLK or posedge actual_reset)
`endif
begin
      if (actual_reset)
	  begin
	        READ_LD <= {ACTUAL_DATA_WIDTH{1'b0}};
			RD_ERROR <= 0;
	  end else
	  begin
	  	  if (READ_EN) 
		  begin
		        if (IS_INFO_OP)
				begin
				     case (ACTUAL_ADDRESS)
					 'h00 :  begin READ_LD <= DATA_WIDTH[7:0];                                                                 RD_ERROR <= 1'b0; end 
					 'h01 :  begin READ_LD <= DATA_WIDTH[15:8];                                                                RD_ERROR <= 1'b0; end
					 'h02 :  begin READ_LD <= ADDRESS_WIDTH[7:0];                                                              RD_ERROR <= 1'b0; end
					 'h03 :  begin READ_LD <= ADDRESS_WIDTH[15:8];                                                             RD_ERROR <= 1'b0; end
					 'h04 :  begin READ_LD <= STATUS_ADDRESS_START[7:0];                                                       RD_ERROR <= 1'b0; end
					 'h05 :  begin READ_LD <= STATUS_ADDRESS_START[15:8];                                                      RD_ERROR <= 1'b0; end
					 'h06 :  begin READ_LD <= NUM_OF_CONTROL_REGS[7:0];                                                        RD_ERROR <= 1'b0; end
					 'h07 :  begin READ_LD <= NUM_OF_CONTROL_REGS[15:8];                                                       RD_ERROR <= 1'b0; end
					 'h08 :  begin READ_LD <= NUM_OF_STATUS_REGS[7:0];                                                         RD_ERROR <= 1'b0; end
					 'h09 :  begin READ_LD <= NUM_OF_STATUS_REGS[15:8];                                                        RD_ERROR <= 1'b0; end
					 'h0A :  begin READ_LD <= {ERROR_MONITOR_STRING,INIT_ALL_CONTROL_REGS_TO_DEFAULT[0],USE_AUTO_RESET[0]};       RD_ERROR <= 1'b0; end
					 'h0B :  begin READ_LD <= total_read_errors  [7:0];                                                        RD_ERROR <= 1'b0; end
					 'h0C :  begin READ_LD <= total_read_errors [15:8];                                                        RD_ERROR <= 1'b0; end
					 'h0D :  begin READ_LD <= total_write_errors [7:0];                                                        RD_ERROR <= 1'b0; end
					 'h0E :  begin READ_LD <= total_write_errors[15:8];                                                        RD_ERROR <= 1'b0; end
					 'h0F :  begin READ_LD <= VERSION;                                                                         RD_ERROR <= 1'b0; end
					 'h10 :  begin READ_LD <= DISPLAY_NAME    [7:0];                                                           RD_ERROR <= 1'b0; end 
					 'h11 :  begin READ_LD <= DISPLAY_NAME   [15:8];                                                           RD_ERROR <= 1'b0; end
					 'h12 :  begin READ_LD <= DISPLAY_NAME  [23:16];                                                           RD_ERROR <= 1'b0; end
					 'h13 :  begin READ_LD <= DISPLAY_NAME  [31:24];                                                           RD_ERROR <= 1'b0; end
					 'h14 :  begin READ_LD <= DISPLAY_NAME  [39:32];                                                           RD_ERROR <= 1'b0; end
					 'h15 :  begin READ_LD <= DISPLAY_NAME  [47:40];                                                           RD_ERROR <= 1'b0; end
					 'h16 :  begin READ_LD <= DISPLAY_NAME  [55:48];                                                           RD_ERROR <= 1'b0; end
					 'h17 :  begin READ_LD <= DISPLAY_NAME  [63:56];                                                           RD_ERROR <= 1'b0; end
					 'h18 :  begin READ_LD <= DISPLAY_NAME  [71:64];                                                           RD_ERROR <= 1'b0; end
					 'h19 :  begin READ_LD <= DISPLAY_NAME  [79:72];                                                           RD_ERROR <= 1'b0; end
					 'h1A :  begin READ_LD <= DISPLAY_NAME  [87:80];                                                           RD_ERROR <= 1'b0; end
					 'h1B :  begin READ_LD <= DISPLAY_NAME  [95:88];                                                           RD_ERROR <= 1'b0; end
					 'h1C :  begin READ_LD <= DISPLAY_NAME [103:96];                                                           RD_ERROR <= 1'b0; end
					 'h1D :  begin READ_LD <= DISPLAY_NAME[111:104];                                                           RD_ERROR <= 1'b0; end
					 'h1E :  begin READ_LD <= DISPLAY_NAME[119:112];                                                           RD_ERROR <= 1'b0; end
					 'h1F :  begin READ_LD <= DISPLAY_NAME[127:120];                                                           RD_ERROR <= 1'b0; end
					 'h20 :  begin READ_LD <= USER_TYPE;                                                                       RD_ERROR <= 1'b0; end
					 'h21 :  begin READ_LD <= ADDRESS_OF_THIS_UART;                                                            RD_ERROR <= 1'b0; end
					 'h22 :  begin READ_LD <= IS_SECONDARY_UART;                                                               RD_ERROR <= 1'b0; end 
					 'h23 :  begin READ_LD <= NUM_SECONDARY_UARTS;                                                             RD_ERROR <= 1'b0; end						 
					 'h24 :  begin READ_LD <= CLOCK_FREQ_HZ[7:0];                                                              RD_ERROR <= 1'b0; end						 
					 'h25 :  begin READ_LD <= CLOCK_FREQ_HZ[15:8];                                                             RD_ERROR <= 1'b0; end						 
					 'h26 :  begin READ_LD <= CLOCK_FREQ_HZ[23:16];                                                            RD_ERROR <= 1'b0; end						 
					 'h27 :  begin READ_LD <= CLOCK_FREQ_HZ[31:24];                                                            RD_ERROR <= 1'b0; end						 
					 'h28 :  begin READ_LD <= WATCHDOG_TIMEOUT_LIMIT[7:0];                                                     RD_ERROR <= 1'b0; end						 
					 'h29 :  begin READ_LD <= WATCHDOG_TIMEOUT_LIMIT[15:8];                                                    RD_ERROR <= 1'b0; end						 
					 'h2A :  begin READ_LD <= WATCHDOG_TIMEOUT_LIMIT[23:16];                                                   RD_ERROR <= 1'b0; end						 
					 'h2B :  begin READ_LD <= WATCHDOG_TIMEOUT_LIMIT[31:24];                                                   RD_ERROR <= 1'b0; end						 
					 'h2C :  begin READ_LD <= CURRENT_WATCHDOG_COUNT[7:0];                                                     RD_ERROR <= 1'b0; end						 
					 'h2D :  begin READ_LD <= CURRENT_WATCHDOG_COUNT[15:8];                                                    RD_ERROR <= 1'b0; end						 
					 'h2E :  begin READ_LD <= CURRENT_WATCHDOG_COUNT[23:16];                                                   RD_ERROR <= 1'b0; end						 
					 'h2F :  begin READ_LD <= CURRENT_WATCHDOG_COUNT[31:24];  	                                               RD_ERROR <= 1'b0; end
					 'h30 :  begin READ_LD <= WATCHDOG_EVENT_COUNT[7:0];                                                       RD_ERROR <= 1'b0; end						 
					 'h31 :  begin READ_LD <= WATCHDOG_EVENT_COUNT[15:8];                                                      RD_ERROR <= 1'b0; end						 
					 'h32 :  begin 
					               READ_LD <= {
										     IGNORE_TIMING_TO_READ_LD,
					                    USE_GENERIC_ATTRIBUTE_FOR_READ_LD,
											  ENABLE_ERROR_MONITORING,
											  DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS};   
								   RD_ERROR <= 1'b0; 
							 end						 
					 'h33 :  begin 
					               READ_LD <=  {
												COMPILE_CRC_ERROR_CHECKING_IN_PARSER,
 						                  WISHBONE_INTERFACE_IS_PART_OF_BRIDGE,
					                     ENABLE_STATUS_WISHBONE_INTERFACE,
												ENABLE_CONTROL_WISHBONE_INTERFACE
											   };                                                                                  
								   RD_ERROR <= 1'b0; 
						     end						 
								   
					 'h34 :  begin READ_LD <=  STATUS_WISHBONE_NUM_ADDRESS_BITS   ;                                              RD_ERROR <= 1'b0; end						 
					 'h35 :  begin READ_LD <=  CONTROL_WISHBONE_NUM_ADDRESS_BITS  ;                                              RD_ERROR <= 1'b0; end						 
					 

					 
					 'h36 :  begin READ_LD <=  WISHBONE_STATUS_BASE_ADDRESS    [7:0];                                                RD_ERROR <= 1'b0; end						 
					 'h37 :  begin READ_LD <=  WISHBONE_STATUS_BASE_ADDRESS   [15:8];                                                RD_ERROR <= 1'b0; end						 
					 'h38 :  begin READ_LD <=  WISHBONE_STATUS_BASE_ADDRESS  [23:16];                                                RD_ERROR <= 1'b0; end						 
					 'h39 :  begin READ_LD <=  WISHBONE_STATUS_BASE_ADDRESS  [31:24];                                                RD_ERROR <= 1'b0; end						 
					 
					 'h3A :  begin READ_LD <=  WISHBONE_CONTROL_BASE_ADDRESS    [7:0];                                                RD_ERROR <= 1'b0; end						 
					 'h3B :  begin READ_LD <=  WISHBONE_CONTROL_BASE_ADDRESS   [15:8];                                                RD_ERROR <= 1'b0; end						 
					 'h3C :  begin READ_LD <=  WISHBONE_CONTROL_BASE_ADDRESS  [23:16];                                                RD_ERROR <= 1'b0; end						 
					 'h3D :  begin READ_LD <=  WISHBONE_CONTROL_BASE_ADDRESS  [31:24];                                                RD_ERROR <= 1'b0; end						 
					 default: 
					 begin
					        READ_LD  <= 32'h0; 
					        RD_ERROR <= ENABLE_ERROR_MONITORING;
					 end 
					 endcase
				end else
				begin
						if (ACTUAL_ADDRESS < NUM_OF_CONTROL_REGS) 
						begin
							  READ_LD  <= IS_CTRL_NAME_OP ? (CONTROL_OMIT_DESC[ACTUAL_ADDRESS] ? 0 :CONTROL_DESC[ACTUAL_ADDRESS]) : 
							                                (CONTROL_SHORT_TO_DEFAULT[ACTUAL_ADDRESS] ?  CONTROL_INIT_VAL[ACTUAL_ADDRESS] : POSSIBLY_CROPPED_CONTROL_OUTPUT_DATA[ACTUAL_ADDRESS]);
							  RD_ERROR <= 0;
						end else
						begin
							 if ((STATUS_ADDRESS_START <= ACTUAL_ADDRESS)  && (ACTUAL_ADDRESS < (STATUS_ADDRESS_START+NUM_OF_STATUS_REGS)))
							 begin
								  READ_LD  <= IS_STATUS_NAME_OP ? (STATUS_OMIT_DESC[ACTUAL_ADDRESS - STATUS_ADDRESS_START] ? 0 : STATUS_DESC[ACTUAL_ADDRESS - STATUS_ADDRESS_START]) : 
								                                  (STATUS_OMIT[ACTUAL_ADDRESS - STATUS_ADDRESS_START] ? 0 : STATUS[ACTUAL_ADDRESS - STATUS_ADDRESS_START]);
								  RD_ERROR <= 0;
							 end else
							 begin
								  READ_LD  <= 32'hEAA;
								  RD_ERROR <= ENABLE_ERROR_MONITORING;
							 end
						end	
                end				
		   end else
		   begin
		         READ_LD  <= READ_LD;
				 RD_ERROR <= RD_ERROR;
		   end
    end
end

wire rd_error_edge, wr_error_edge;

generate
if (ENABLE_ERROR_MONITORING)
begin

		edge_detector rd_error_edge_detector
		(
		 .insignal (RD_ERROR), 
		 .outsignal(rd_error_edge), 
		 .clk      (CLK)
		);


		edge_detector wr_error_edge_detector
		(
		 .insignal (WR_ERROR), 
		 .outsignal(wr_error_edge), 
		 .clk      (CLK)
		);


		`ifdef UART_REGISTER_FILES_USE_SYNCRONOUS_RESET
		always @(posedge CLK)
		`else
		always @(posedge CLK or posedge actual_reset)
		`endif
		begin   
				 if (actual_reset)
				 begin
					  
							  WR_ERROR <= 0;
				 end else
				 begin
						  if (WRITE_EN)
						  begin
							   if (ADDRESS < NUM_OF_CONTROL_REGS)
							   begin
									WR_ERROR <= 0;
							   end else
							   begin
									WR_ERROR <= 1;
							   end
						  end
				end
		end

		`ifdef UART_REGISTER_FILES_USE_SYNCRONOUS_RESET
		always @(posedge CLK)
		`else
		always @(posedge CLK or posedge actual_reset)
		`endif
		begin
			  if (actual_reset)
			  begin
					 total_read_errors <= 0;
			  end else
			  begin
					 if (rd_error_edge)
					 begin
						  total_read_errors <= total_read_errors + 1;
					 end
			  end
		end

		`ifdef UART_REGISTER_FILES_USE_SYNCRONOUS_RESET
		always @(posedge CLK)
		`else
		always @(posedge CLK or posedge actual_reset)
		`endif
		begin
			  if (actual_reset)
			  begin
				   total_write_errors <= 0;
			  end else
			  begin
				   if (wr_error_edge)
				   begin
						total_write_errors <= total_write_errors + 1;
				   end
			  end
		end
end

endgenerate
endmodule
