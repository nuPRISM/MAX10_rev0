`include "interface_defs.v"
`default_nettype none
module uart_bridge_to_wishbone_master
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
  CONTROL_DESC,
  CONTROL_OMIT_DESC,
  WISHBONE_SLAVE_DATA,
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
  parameter [15:0] NUM_OF_STATUS_REGS                    =   0;
  parameter [15:0] ADDRESS_WIDTH                         =  16;
  parameter [15:0] STATUS_ADDRESS_START                  =  NUM_OF_CONTROL_REGS;
  parameter [0:0]  USE_AUTO_RESET                        =  1'b1;

  parameter  [7:0]                 ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0;
  parameter  [7:0]                 ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b0;
  parameter   [7:0]                DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS = 1'b0;
  parameter [0:0]    DISABLE_ERROR_MONITORING = 1'b1;
  parameter [0:0] COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0;
  
 output [ACTUAL_DATA_WIDTH   -1:0] READ_LD;
 (* keep = 1, preserve = 1  *) reg  [ACTUAL_DATA_WIDTH   -1:0] READ_LD = 0;
 
 
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
				

 input  wire [DESC_WIDTH-1:0]                CONTROL_DESC[NUM_OF_CONTROL_REGS-1:0];
 input  wire                                 CONTROL_OMIT_DESC[NUM_OF_CONTROL_REGS-1:0];
 

 input wire [7:0] NUM_SECONDARY_UARTS;
 input wire [7:0] ADDRESS_OF_THIS_UART;
 input wire       IS_SECONDARY_UART;
 
 input wire [31:0] CLOCK_FREQ_HZ         ;
 input wire [31:0] WATCHDOG_TIMEOUT_LIMIT;
 input wire [31:0] CURRENT_WATCHDOG_COUNT;
 input wire [15:0] WATCHDOG_EVENT_COUNT;
 input wire [DATA_WIDTH-1:0] WISHBONE_SLAVE_DATA;
 
 input [127:0] DISPLAY_NAME;

 output wire                                 TRANSACTION_ERROR;
 output reg                                  WR_ERROR = 0;
 output reg                                  RD_ERROR = 0;
  
 reg [15:0] total_read_errors  = 0;
 reg [15:0] total_write_errors = 0;
 parameter [7:0] VERSION = 3;
 wire auto_reset;


generate_one_shot_pulse 
#(.num_clks_to_wait(1))  
generate_auto_reset
(
.clk(CLK), 
.oneshot_pulse(auto_reset)
);

wire actual_reset = USE_AUTO_RESET ? (auto_reset ||  ACTIVE_HIGH_ASYNC_RESET) : ACTIVE_HIGH_ASYNC_RESET;

wire [1:0] ERROR_MONITOR_STRING;
generate
		if (DISABLE_ERROR_MONITORING)
		begin
				assign ERROR_MONITOR_STRING = 0;
		end
		else
		begin
				assign ERROR_MONITOR_STRING = {WR_ERROR,RD_ERROR};

		end
endgenerate


always @(posedge CLK or posedge actual_reset)
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
				     case (ADDRESS)
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
					 'h0A :  begin READ_LD <= {ERROR_MONITOR_STRING,1'b0,USE_AUTO_RESET[0]};       RD_ERROR <= 1'b0; end
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
					 'h32 :  begin READ_LD <= {ENABLE_STATUS_WISHBONE_INTERFACE};                                              RD_ERROR <= 1'b0; end						 
					 'h33 :  begin READ_LD <= {ENABLE_CONTROL_WISHBONE_INTERFACE};                                             RD_ERROR <= 1'b0; end						 
					 'h34 :  begin READ_LD <= {DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS};                                    RD_ERROR <= 1'b0; end						 
					 'h35 :  begin READ_LD <= DISABLE_ERROR_MONITORING;                                                       RD_ERROR <= 1'b0; end						 
					 default: 
					 begin
					        READ_LD  <= 32'h0; 
					        RD_ERROR <= !DISABLE_ERROR_MONITORING;
					 end
					 endcase
				end else
				begin
				      if (!IS_STATUS_OP)
						begin
							  READ_LD  <= IS_CTRL_NAME_OP ? (CONTROL_OMIT_DESC[ADDRESS] ? 0 :CONTROL_DESC[ADDRESS]) : 
							                                 WISHBONE_SLAVE_DATA;
							  RD_ERROR <= 0;
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
if (!DISABLE_ERROR_MONITORING)
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


		always @(posedge CLK or posedge actual_reset)
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

		always @(posedge CLK or posedge actual_reset)
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

		always @(posedge CLK or posedge actual_reset)
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
`default_nettype wire