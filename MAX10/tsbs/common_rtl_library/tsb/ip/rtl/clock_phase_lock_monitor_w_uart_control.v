`ifndef CLOCK_PHASE_LOCK_MONITOR_W_UART_CONTROL_V
`define CLOCK_PHASE_LOCK_MONITOR_W_UART_CONTROL_V

`default_nettype none
`include "interface_defs.v"
//`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module clock_phase_lock_monitor_w_uart_control
#(
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter counter_bits = 32,
parameter EVENT_MON_CONTROL_DEFAULT = 1,
parameter CLK0_INCREMENT_DEFAULT = 1,
parameter CLK1_INCREMENT_DEFAULT = 1,
parameter DEFAULT_POSITIVE_DISCORD_THRESHOLD = 1000,
parameter DEFAULT_NEGATIVE_DISCORD_THRESHOLD = -DEFAULT_POSITIVE_DISCORD_THRESHOLD,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_CLKMON"},
parameter UART_REGFILE_TYPE = uart_regfile_types::CLOCK_PHASE_LOCK_MONITOR_REGFILE,
parameter MAX_CLOCK_DECIMATION_RATIO,
parameter DEFAULT_CLOCK_DECIMATION_RATIO,
parameter NUMBITS_CLOCK_DECIMATION_RATIO = $clog2(MAX_CLOCK_DECIMATION_RATIO) > 32 ? 32 : $clog2(MAX_CLOCK_DECIMATION_RATIO),
parameter synchronizer_depth = 3
)
(
	input  UART_CLK,
	input  RESET_FOR_UART_CLK,
	output uart_tx,
	input  uart_rx,

	input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,

	input  measurement_clk,
	input [1:0] monitored_clk

    
);


 logic         reset_check_edge_event_concordance;      
 logic         check_edge_event_concordance_clear_event_discord;      
 logic         check_edge_event_concordance_event_discord;      
 logic         check_edge_event_concordance_immediate_event_discord;      
 logic         check_edge_event_concordance_event_enable;      
 logic [31:0]  check_edge_event_concordance_counter_a;      
 logic [31:0]  check_edge_event_concordance_counter_b;      
 logic [31:0] check_edge_event_concordance_counter_a_clock_count;
 logic [31:0] check_edge_event_concordance_counter_b_clock_count;
 logic [31:0] clk0_increment;
 logic [31:0] clk1_increment;
 
 logic  signed_over_thresh;
 logic  over_thresh;
 logic  signed_under_thresh;
 logic  under_thresh;
 
 
 logic [31:0]  check_edge_event_concordance_diff_counter;      
logic [31:0]  negative_discord_thresh;
logic [31:0]  positive_discord_thresh;


parameter ZERO_IN_ASCII = 48;
localparam NUM_MONITORED_CLOCKS = 2;
logic [NUM_MONITORED_CLOCKS-1:0] clock_event;
logic [NUM_MONITORED_CLOCKS-1:0] synced_clock_event;
logic [NUMBITS_CLOCK_DECIMATION_RATIO-1:0] clock_decimation_ratio;

genvar i;
generate
			for (i = 0; i < NUM_MONITORED_CLOCKS; i++)
			begin : decimate_clock_edges
					flexible_mod_m_counter
					#(
					 .MAX_M(MAX_CLOCK_DECIMATION_RATIO)
					)
					clk_decimation_counter
					(
						.clk(monitored_clk[i]), 
						.reset(1'b0),
						.max_tick(clock_event[i]),
						.q(),
						.M(clock_decimation_ratio)
					);
					
					 async_trap_and_reset_gen_1_pulse_robust 
					 #(.synchronizer_depth(synchronizer_depth)) 
					 sync_clock_event_pulses
					 (
					 .async_sig(clock_event[i]), 
					 .outclk(measurement_clk), 
					 .out_sync_sig(synced_clock_event[i]), 
					 .auto_reset(1'b1), 
					 .reset(1'b1)
					 );	
			end
endgenerate	

smart_check_edge_event_concordance
#(
.counter_bits(counter_bits)
)
smart_check_edge_event_concordance_inst
(
 .signed_over_thresh(signed_over_thresh),
 .over_thresh(over_thresh),
 .signed_under_thresh(signed_under_thresh),
 .under_thresh(under_thresh),
 .event_a(synced_clock_event[0]),
 .event_b(synced_clock_event[1]),
 .clk(measurement_clk),
 .async_reset(reset_check_edge_event_concordance),
 .counter_a(check_edge_event_concordance_counter_a),
 .counter_b(check_edge_event_concordance_counter_b),
 .counter_a_clock_count(check_edge_event_concordance_counter_a_clock_count),
 .counter_b_clock_count(check_edge_event_concordance_counter_b_clock_count),
 .diff_counter(check_edge_event_concordance_diff_counter),
 .event_discord(check_edge_event_concordance_event_discord),
 .immediate_event_discord(check_edge_event_concordance_immediate_event_discord),
 .async_clear_event_discord(check_edge_event_concordance_clear_event_discord),
 .enable(check_edge_event_concordance_event_enable),
 .counter_a_increment    (clk0_increment),
 .counter_b_increment    (clk1_increment),
 .negative_discord_thresh(negative_discord_thresh),
 .positive_discord_thresh(positive_discord_thresh)
);
			
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   Diagnostic UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 8;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 8;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			
			uart_regfile_interface 
			#(                                                                                                     
			.DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       ),
			.DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       ),
			.NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 ),
			.NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  ),
			.INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    ),
			.CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            ),
			.USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      ),
			.CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   ),
			.UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                ),
			.ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   ),
			.ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    ),
			.DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  )
			)
			uart_regfile_interface_pins();

	        assign uart_regfile_interface_pins.display_name         = uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = UART_CLK;
			assign uart_regfile_interface_pins.reset     = 1'b0;
			assign uart_regfile_interface_pins.user_type = UART_REGFILE_TYPE;	
			
			uart_controlled_register_file_w_interfaces
			#(
			 .DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                      ),
			 .DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                      ),
			 .NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                ),
			 .NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                 ),
			 .INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT   ),
			 .CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL           ),
			 .USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                     ),
			 .CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                  ),
			 .UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ               ),
			 .ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE  ),
			 .ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE   ),
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS)
			)		
			control_and_status_regfile
			(
			  .uart_regfile_interface_pins(uart_regfile_interface_pins)		
			);
			
			genvar sreg_count;
			genvar creg_count;
			
			generate
					for ( sreg_count=0; sreg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS; sreg_count++)
					begin : clear_status_descs
						  assign uart_regfile_interface_pins.status_omit_desc[sreg_count] = OMIT_STATUS_REG_DESCRIPTIONS;
					end
					
						
					for (creg_count=0; creg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS; creg_count++)
					begin : clear_control_descs
						  assign uart_regfile_interface_pins.control_omit_desc[creg_count] = OMIT_CONTROL_REG_DESCRIPTIONS;
					end
			endgenerate
			

	assign uart_regfile_interface_pins.control_regs_default_vals[0] = EVENT_MON_CONTROL_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[0] = "event_mon_ctrl";
    assign { 
	       check_edge_event_concordance_clear_event_discord,
		   reset_check_edge_event_concordance,
		   check_edge_event_concordance_event_enable,
		   } = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0] = 8;			
		
	assign uart_regfile_interface_pins.control_regs_default_vals[1] = DEFAULT_POSITIVE_DISCORD_THRESHOLD;
    assign uart_regfile_interface_pins.control_desc[1] = "thr_pos";
    assign positive_discord_thresh = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1] = 32;			
		
	assign uart_regfile_interface_pins.control_regs_default_vals[2] = DEFAULT_NEGATIVE_DISCORD_THRESHOLD;
    assign uart_regfile_interface_pins.control_desc[2] = "thr_neg";
    assign negative_discord_thresh = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2] = 32;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[3] = CLK0_INCREMENT_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[3] = "clk0_increment";
    assign clk0_increment = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3] = 32;	
	
	assign uart_regfile_interface_pins.control_regs_default_vals[4] = CLK1_INCREMENT_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[4] = "clk1_increment";
    assign clk1_increment = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4] = 32;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[5] = DEFAULT_CLOCK_DECIMATION_RATIO;
    assign uart_regfile_interface_pins.control_desc[5] = "clk_decim_ratio";
    assign clock_decimation_ratio = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5] = NUMBITS_CLOCK_DECIMATION_RATIO;	
	
	assign uart_regfile_interface_pins.status[0] =check_edge_event_concordance_counter_a;
	assign uart_regfile_interface_pins.status_desc[0]="counter_a";		
	
	assign uart_regfile_interface_pins.status[1] =check_edge_event_concordance_counter_b;
	assign uart_regfile_interface_pins.status_desc[1]="counter_b";		
	
    assign uart_regfile_interface_pins.status[3] = check_edge_event_concordance_counter_a_clock_count;
	assign uart_regfile_interface_pins.status_desc[3] = "cnt_a_clk_count";
	
	assign uart_regfile_interface_pins.status[4] = check_edge_event_concordance_counter_b_clock_count;
	assign uart_regfile_interface_pins.status_desc[4] = "cnt_b_clk_count";	
	
	assign uart_regfile_interface_pins.status[5] =check_edge_event_concordance_diff_counter;
	assign uart_regfile_interface_pins.status_desc[5]="diff_counter";
			
			
			
			
	assign uart_regfile_interface_pins.status[6] ={signed_over_thresh,over_thresh,signed_under_thresh,under_thresh,2'b0,check_edge_event_concordance_event_discord,check_edge_event_concordance_immediate_event_discord};
	assign uart_regfile_interface_pins.status_desc[6]="event_discord";

			
endmodule
`default_nettype wire
`endif
