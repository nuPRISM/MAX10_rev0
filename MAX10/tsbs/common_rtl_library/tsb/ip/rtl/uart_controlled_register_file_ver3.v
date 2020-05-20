`default_nettype none

`ifdef SOFTWARE_IS_QUARTUS
   `include "interface_defs.v"
`endif

module uart_controlled_register_file_ver3
(	
 CLK,
 data_clock,
 REG_ACTIVE_HIGH_ASYNC_RESET,
 CONTROL,
 CONTROL_BITWIDTH,
 CONTROL_DESC,
 STATUS,
 STATUS_BITWIDTH,
 STATUS_DESC,
 CONTROL_INIT_VAL,
 STATUS_OMIT_DESC,
 CONTROL_OMIT_DESC,
 CONTROL_SHORT_TO_DEFAULT,
 STATUS_OMIT,
 TRANSACTION_ERROR,
 WR_ERROR,
 RD_ERROR,
 PARSER_ERROR_COUNT,
 DISPLAY_NAME,
 USER_TYPE,
 NUM_SECONDARY_UARTS,
 ADDRESS_OF_THIS_UART,
 IS_SECONDARY_UART,
 enable_watchdog,
 reset_watchdog,
 watchdog_reset_pulse,
 watchdog_limit,
 watchdog_reset_pulse_width,
 current_watchdog_count,
 watchdog_event_count,
 ignore_crc_value_for_debugging,
 
 //UART
 uart_active_high_async_reset,
 rxd,
 txd,
 
 //UART DEBUG
 main_sm,
 tx_sm,
 command_count
 `ifdef SOFTWARE_IS_QUARTUS
 ,
 status_wishbone_interface_pins,
 control_wishbone_interface_pins
 `endif
  
);
  parameter [15:0] DATA_WIDTH_IN_BYTES = 4;
  parameter [15:0] DESC_WIDTH_IN_BYTES = 8;
  parameter	[15:0] DATA_WIDTH = 8*DATA_WIDTH_IN_BYTES;
  parameter	[15:0] DESC_WIDTH = 8*DESC_WIDTH_IN_BYTES;
  parameter [15:0] NUM_OF_CONTROL_REGS                   =  2;
  parameter [15:0] NUM_OF_STATUS_REGS                    =  2;
  parameter [15:0] STATUS_ADDRESS_START                  =  NUM_OF_CONTROL_REGS;
  parameter [15:0] INIT_ALL_CONTROL_REGS_TO_DEFAULT      =  1'b0;
  parameter [DATA_WIDTH-1:0]  CONTROL_REGS_DEFAULT_VAL   =  0;
  parameter [7:0]  USE_AUTO_RESET                         = 1'b1;
  parameter	ACTUAL_DATA_WIDTH_IN_BYTES = (DESC_WIDTH_IN_BYTES > DATA_WIDTH_IN_BYTES) ?  DESC_WIDTH_IN_BYTES : DATA_WIDTH_IN_BYTES; // data bus width parameter 
  parameter	DW = 8*ACTUAL_DATA_WIDTH_IN_BYTES;		// data bus width parameter 
  parameter CLOCK_SPEED_IN_HZ = 50000000;
  parameter UART_BAUD_RATE_IN_HZ = 115200;
  parameter  [0:0]                 ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0;
  parameter  [0:0]                 ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b0;
  parameter   [0:0]                DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS = 1'b0;
  parameter [0:0]    DISABLE_ERROR_MONITORING = 1'b1;
  parameter [0:0]    IGNORE_TIMING_TO_READ_LD = 1'b0;
  parameter [0:0]    WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0;
  parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = ENABLE_STATUS_WISHBONE_INTERFACE ? $clog2(NUM_OF_STATUS_REGS) : 0; 
  parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = ENABLE_CONTROL_WISHBONE_INTERFACE ? $clog2(NUM_OF_CONTROL_REGS) : 0; 
  parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS     = 0;
  parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS      = 0;
  parameter [15:0] NUM_OF_CLOCKS_TO_WAIT_BEFORE_AUTORESET = 1;
  parameter [15:0] LENGTH_OF_AUTORESET_PULSE              = 10;
  parameter        ENABLE_KEEPS = 0;

  /*
  parameter [0:0]    SET_MAX_DELAY_TIMING_TO_READ_LD = 1'b0;
  parameter [31:0]    MAX_DELAY_TIMING_TO_READ_LD = 1'b0;
  */
  parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0;
  parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR";
  parameter [0:0] UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK = 0;
  parameter [0:0]  ADD_EXTRA_UART_RXD_SYNC_REGS = 1'b1;
  parameter        NUM_EXTRA_UART_RXD_SYNC_REGS = 3;
  parameter synchronizer_depth = 3;
  
  parameter       [0:0] USE_LEGACY_UART_PARSER= 0;
  
  parameter       [0:0] COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0;
  logic actual_ignore_crc_value_for_debugging;
  
`ifdef UART_REGFILE_GLOBAL_ENABLE_CRC
      parameter [0:0] ACTUAL_COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 1;
		assign actual_ignore_crc_value_for_debugging = 1'b0;
`else
     `ifdef  UART_REGFILE_GLOBAL_DISABLE_CRC
      parameter [0:0] ACTUAL_COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0;
		assign actual_ignore_crc_value_for_debugging = 1'b1;
	   `else
		        parameter [0:0] ACTUAL_COMPILE_CRC_ERROR_CHECKING_IN_PARSER  = COMPILE_CRC_ERROR_CHECKING_IN_PARSER;
				  assign actual_ignore_crc_value_for_debugging = ignore_crc_value_for_debugging;
		`endif
 `endif

  input   [127:0] DISPLAY_NAME;
  input wire  [7:0]                           USER_TYPE;
  input  wire 					             CLK;
 input  wire                                 REG_ACTIVE_HIGH_ASYNC_RESET;
 output reg  [DATA_WIDTH-1:0]                CONTROL[NUM_OF_CONTROL_REGS-1:0];
 input wire  [DESC_WIDTH-1:0]                CONTROL_DESC[NUM_OF_CONTROL_REGS-1:0];
 input  wire                                 CONTROL_SHORT_TO_DEFAULT[NUM_OF_CONTROL_REGS-1:0];
 input  wire                                 CONTROL_OMIT_DESC[NUM_OF_CONTROL_REGS-1:0];
 input  logic data_clock;
 
 input  wire [DATA_WIDTH-1:0]                STATUS [NUM_OF_STATUS_REGS-1:0];
 input  wire [DESC_WIDTH-1:0]                STATUS_DESC[NUM_OF_STATUS_REGS-1:0];
 input  wire                                 STATUS_OMIT[NUM_OF_STATUS_REGS-1:0];
 input  wire                                 STATUS_OMIT_DESC[NUM_OF_STATUS_REGS-1:0];
 
 input  wire [DATA_WIDTH-1:0]                CONTROL_INIT_VAL[NUM_OF_CONTROL_REGS-1:0];
 output wire                                 TRANSACTION_ERROR;
 output reg                                  WR_ERROR = 0;
 output reg                                  RD_ERROR = 0;
 
 input wire [7:0] NUM_SECONDARY_UARTS;
 input wire [7:0] ADDRESS_OF_THIS_UART;
 input wire IS_SECONDARY_UART;
 
 input [31:0] watchdog_limit;
 input [7:0]  watchdog_reset_pulse_width;
 input ignore_crc_value_for_debugging;
 
 output wire enable_watchdog;
 output wire reset_watchdog;
	  
	  
 output wire watchdog_reset_pulse; 
 output wire [31:0] current_watchdog_count;
 output wire [31:0] PARSER_ERROR_COUNT;
 output reg  [15:0] watchdog_event_count = 0;
 //UART
 input wire uart_active_high_async_reset;
 input rxd;
 output txd;
 
 //UART DEBUG
 output wire [31:0] main_sm;
 output wire [31:0] tx_sm;
 output wire [31:0] command_count;
 
 (* keep = 1, preserve = 1 *)logic actual_rxd;
 logic chosen_data_clock;
 wire actual_uart_active_high_async_reset;

 `ifdef SOFTWARE_IS_QUARTUS
		 wishbone_interface control_wishbone_interface_pins;
		 wishbone_interface status_wishbone_interface_pins;

		 generate 
			   if (!ENABLE_CONTROL_WISHBONE_INTERFACE)
			   begin
				   wishbone_interface control_wishbone_interface_pins(); //generate dummy interface to allow top module to leave this interface disconnected
			   end
		 
			  if (!ENABLE_STATUS_WISHBONE_INTERFACE)
			   begin
				   wishbone_interface status_wishbone_interface_pins(); //generate dummy interface to allow top module to leave this interface disconnected
			   end
		  endgenerate
		
  `endif

 generate 
    `ifdef SOFTWARE_IS_QUARTUS
					if (ADD_EXTRA_UART_RXD_SYNC_REGS)
					begin
							 my_altera_std_synchronizer_nocut 
							 the_altera_std_synchronizer_for_uart_rxd
							 (
							  .clk (CLK),
							  .din (rxd),
							  .dout (actual_rxd),
							  .reset_n (!actual_uart_active_high_async_reset)
							);
							defparam the_altera_std_synchronizer_for_uart_rxd.depth = NUM_EXTRA_UART_RXD_SYNC_REGS;
						    defparam the_altera_std_synchronizer_for_uart_rxd.rst_value = 1'b1;
					end else
					begin
							 assign actual_rxd = rxd;
					end
	`else
	
					//invert input and then invert output in order to get initial value of 1 at output
					logic actual_rxd_n_raw;
					doublesync_no_reset #(.synchronizer_depth(NUM_EXTRA_UART_RXD_SYNC_REGS))
							extra_sync_for_uart_rxd
								(
								 .indata(!rxd),
								 .outdata(actual_rxd_n_raw),
								 .clk(CLK)
								);		
								
			           assign actual_rxd = !actual_rxd_n_raw;
	`endif
 endgenerate				
 
	function automatic int log2 (input int n);
						if (n <=1) return 1; // abort function
						log2 = 0;
						while (n > 1) begin
						n = n/2;
						log2++;
						end
						endfunction

	function automatic int gcd (input int a, input int b);
							if (a == 0)
							begin
							   return b;
							end
							
							while (!(b == 0))
							begin
								if (a > b)
								begin
								   a = a - b;
								end else
								begin
								   b = b - a;
								end
							end
							return a;
						endfunction

input [DATA_WIDTH-1:0] CONTROL_BITWIDTH[NUM_OF_CONTROL_REGS-1:0];
input [DATA_WIDTH-1:0] STATUS_BITWIDTH [NUM_OF_STATUS_REGS-1:0];
					
function int calculate_baud_freq_param (input int clk_osc_freq_hz, input int baud_freq_hz);
 return (16*baud_freq_hz/(gcd(clk_osc_freq_hz, 16*baud_freq_hz)));
endfunction

function int calculate_baud_limit_param (input int clk_osc_freq_hz, input int baud_freq_hz, input int baud_freq_param);
  return ((clk_osc_freq_hz / gcd(clk_osc_freq_hz, 16*baud_freq_hz)) - baud_freq_param);
endfunction


// baud rate configuration, see baud_gen.v for more details.
// baud rate generator parameters for 115200 baud on 50MHz clock 
//parameter D_BAUD_FREQ			= 12'h240,
// parameter D_BAUD_LIMIT		= 16'h3AC9 
						
	
parameter D_BAUD_FREQ			= calculate_baud_freq_param(CLOCK_SPEED_IN_HZ,UART_BAUD_RATE_IN_HZ);
parameter D_BAUD_LIMIT		    = calculate_baud_limit_param(CLOCK_SPEED_IN_HZ,UART_BAUD_RATE_IN_HZ,D_BAUD_FREQ);

 wire [DW-1:0] uart_write_data;
 wire [DW-1:0] uart_read_data;
 wire [15:0] uart_address;
 wire uart_write_strb;
 wire uart_read_strb;
 wire uart_int_req;
 wire is_status_op;
 wire is_info_op;
 wire is_status_name_op;
 wire is_ctrl_name_op;
 
 
generate
        if (UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK)
        begin
		      assign chosen_data_clock = data_clock;
		end
		else
		begin
		     assign chosen_data_clock = CLK;			
		end
endgenerate
 
`ifndef GLOBAL_DISABLE_ALL_UART_REGFILE_HW_WATCHDOGS 
				 
				hw_watchdog_timer
				#(
				.numbits(32)
				)
				hw_watchdog_timer_inst
				(
				.clk                 ( chosen_data_clock           ),
				.async_reset         ( uart_active_high_async_reset),
				.enable              ( enable_watchdog             ),
				.reset_watchdog      ( reset_watchdog              ),
				.watchdog_reset_pulse( watchdog_reset_pulse        ),
				.watchdog_limit      ( watchdog_limit              ),
				.num_reset_cycles    ( watchdog_reset_pulse_width  ),

				//debug outputs
				.current_count       (current_watchdog_count       )

				);


				 
				doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
				sync_and_delay_watchdog_reset
				(
				 .indata(uart_active_high_async_reset || watchdog_reset_pulse),
				 .outdata(actual_uart_active_high_async_reset),
				 .clk(chosen_data_clock)
				);
				 
				wire watchdog_reset_pulse_edge;
				 
				edge_detector watchdog_reset_pulse_edge_detector
				(
				 .insignal (watchdog_reset_pulse), 
				 .outsignal(watchdog_reset_pulse_edge), 
				 .clk      (chosen_data_clock)
				);

				always @(posedge chosen_data_clock or posedge uart_active_high_async_reset)
				begin
					  if (uart_active_high_async_reset)
					 begin
							watchdog_event_count <= 0;
					 end else
					 begin 
							 if (watchdog_reset_pulse_edge)
							begin
									watchdog_event_count <= watchdog_event_count+1; 
							end
					 end	
				end 
`else
			doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
			sync_uart_active_high_async_reset
				(
				 .indata(uart_active_high_async_reset),
				 .outdata(actual_uart_active_high_async_reset),
				 .clk(chosen_data_clock)
				);		
`endif
 
uart2bus_top_ver3
 #(
 .DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES),
 .DESC_WIDTH_IN_BYTES(DESC_WIDTH_IN_BYTES),
 .D_BAUD_FREQ (D_BAUD_FREQ),	
 .D_BAUD_LIMIT(D_BAUD_LIMIT),
 .UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK(UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK),
 .USE_LEGACY_UART_PARSER(USE_LEGACY_UART_PARSER),
 .COMPILE_CRC_ERROR_CHECKING_IN_PARSER(ACTUAL_COMPILE_CRC_ERROR_CHECKING_IN_PARSER)
 )            
 uart2bus_top_inst
(
	// global signals 
	.clock(CLK), 
	.data_clock(chosen_data_clock),
	.reset(actual_uart_active_high_async_reset),
	// uart serial signals 
	.ser_in(actual_rxd), 
	.ser_out(txd),
	// internal bus to register file 
	.int_address  (uart_address), 
	.int_wr_data  (uart_write_data), 
	.int_write    (uart_write_strb),
	.int_rd_data  (uart_read_data), 
	.int_read     (uart_read_strb), 
	.int_req      (uart_int_req), 
	.int_gnt      (1'b1),
	.is_status_op (is_status_op),
	.is_info_op   (is_info_op),
    .main_sm      (main_sm),
	.tx_sm        (tx_sm),
    .command_count(command_count),
	.error_count(PARSER_ERROR_COUNT),
    .is_status_name_op  (is_status_name_op),
    .is_ctrl_name_op    (is_ctrl_name_op),
    .NUM_SECONDARY_UARTS   (NUM_SECONDARY_UARTS  ),
    .ADDRESS_OF_THIS_UART  (ADDRESS_OF_THIS_UART ),
    .IS_SECONDARY_UART     (IS_SECONDARY_UART    ),
 	.enable_watchdog(enable_watchdog),
	.reset_watchdog(reset_watchdog),
	.ignore_crc_value_for_debugging(actual_ignore_crc_value_for_debugging)
);

variable_compact_registers_keeper_ver3
#( 
  .DATA_WIDTH                            (DATA_WIDTH                      ),
  .DESC_WIDTH                            (DESC_WIDTH                      ),
  .NUM_OF_CONTROL_REGS                   (NUM_OF_CONTROL_REGS             ),
  .NUM_OF_STATUS_REGS                    (NUM_OF_STATUS_REGS              ),
  .ADDRESS_WIDTH                         (16                              ),
  .STATUS_ADDRESS_START                  (STATUS_ADDRESS_START            ),
  .INIT_ALL_CONTROL_REGS_TO_DEFAULT      (INIT_ALL_CONTROL_REGS_TO_DEFAULT),
  .CONTROL_REGS_DEFAULT_VAL              (CONTROL_REGS_DEFAULT_VAL        ),
  .USE_AUTO_RESET                        (USE_AUTO_RESET                  ),
  .ENABLE_CONTROL_WISHBONE_INTERFACE (ENABLE_CONTROL_WISHBONE_INTERFACE), 
  .ENABLE_STATUS_WISHBONE_INTERFACE  (ENABLE_STATUS_WISHBONE_INTERFACE) ,
  .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS(DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS)  ,
  .ENABLE_ERROR_MONITORING(!DISABLE_ERROR_MONITORING),
  .IGNORE_TIMING_TO_READ_LD(IGNORE_TIMING_TO_READ_LD),
  .USE_GENERIC_ATTRIBUTE_FOR_READ_LD(USE_GENERIC_ATTRIBUTE_FOR_READ_LD),
  .GENERIC_ATTRIBUTE_FOR_READ_LD(GENERIC_ATTRIBUTE_FOR_READ_LD),
  .STATUS_WISHBONE_NUM_ADDRESS_BITS(STATUS_WISHBONE_NUM_ADDRESS_BITS),
  .CONTROL_WISHBONE_NUM_ADDRESS_BITS(CONTROL_WISHBONE_NUM_ADDRESS_BITS),
  .WISHBONE_INTERFACE_IS_PART_OF_BRIDGE(WISHBONE_INTERFACE_IS_PART_OF_BRIDGE),
  .WISHBONE_CONTROL_BASE_ADDRESS  (WISHBONE_CONTROL_BASE_ADDRESS),  
  .WISHBONE_STATUS_BASE_ADDRESS   (WISHBONE_STATUS_BASE_ADDRESS ),
  .NUM_OF_CLOCKS_TO_WAIT_BEFORE_AUTORESET(NUM_OF_CLOCKS_TO_WAIT_BEFORE_AUTORESET),
  .LENGTH_OF_AUTORESET_PULSE             (LENGTH_OF_AUTORESET_PULSE             ),
  .COMPILE_CRC_ERROR_CHECKING_IN_PARSER(ACTUAL_COMPILE_CRC_ERROR_CHECKING_IN_PARSER),
  .ENABLE_KEEPS(ENABLE_KEEPS)  
)
variable_compact_registers_keeper_inst
(	
 .READ_LD(uart_read_data),
 .DATA(uart_write_data),
 .ADDRESS(uart_address),
 .CLK(chosen_data_clock),
 .READ_EN(uart_read_strb),
 .WRITE_EN(uart_write_strb),
 .ACTIVE_HIGH_ASYNC_RESET(REG_ACTIVE_HIGH_ASYNC_RESET),
 .CONTROL(CONTROL),
 .CONTROL_BITWIDTH(CONTROL_BITWIDTH),
 .CONTROL_DESC(CONTROL_DESC),
 .STATUS(STATUS),
 .STATUS_BITWIDTH(STATUS_BITWIDTH),
 .STATUS_DESC(STATUS_DESC),
 .CONTROL_INIT_VAL(CONTROL_INIT_VAL),
 .STATUS_OMIT_DESC(STATUS_OMIT_DESC),
 .CONTROL_OMIT_DESC(CONTROL_OMIT_DESC),
 .CONTROL_SHORT_TO_DEFAULT(CONTROL_SHORT_TO_DEFAULT),
 .STATUS_OMIT(STATUS_OMIT), 
 .TRANSACTION_ERROR(TRANSACTION_ERROR),
 .IS_STATUS_OP(is_status_op),
 .IS_INFO_OP  (is_info_op),
 .IS_STATUS_NAME_OP  (is_status_name_op),
 .IS_CTRL_NAME_OP    (is_ctrl_name_op),
 .DISPLAY_NAME       (DISPLAY_NAME   ),
 .USER_TYPE (USER_TYPE),
 .WR_ERROR(WR_ERROR),
 .RD_ERROR(RD_ERROR),
 .NUM_SECONDARY_UARTS   (NUM_SECONDARY_UARTS   ),
 .ADDRESS_OF_THIS_UART  (ADDRESS_OF_THIS_UART  ),
 .IS_SECONDARY_UART     (IS_SECONDARY_UART     ),
 .CLOCK_FREQ_HZ         (CLOCK_SPEED_IN_HZ     ),
 .WATCHDOG_TIMEOUT_LIMIT(watchdog_limit        ),
 .CURRENT_WATCHDOG_COUNT(current_watchdog_count),
 .WATCHDOG_EVENT_COUNT  (watchdog_event_count)
  `ifdef SOFTWARE_IS_QUARTUS
 ,
 .status_wishbone_interface(status_wishbone_interface_pins),
 .control_wishbone_interface(control_wishbone_interface_pins)
 `endif
 
);

endmodule
`default_nettype wire