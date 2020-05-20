`default_nettype none
`include "interface_defs.v"
//`include "keep_defines.v"
import uart_regfile_types::*;
	  
module multi_channel_generic_reframer_w_uart_support
#(
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"Reframer"},
parameter UART_REGFILE_TYPE = uart_regfile_types::GENERIC_REFRAMER_REGFILE,
parameter lock_wait_counter_bits = 9,
parameter [7:0] numbits_datain    = 14,
parameter [7:0] num_data_channels = 8,
parameter DEFAULT_FRAME_LOCK_MASK = {{(numbits_datain/2){1'b1}},{(numbits_datain/2){1'b0}}},
parameter DEFAULT_TRANSPOSE_CTRL = 2,
parameter DEFAULT_LOCK_WAIT = 50,
parameter DEFAULT_ENABLE_LOCK_SCAN = 1,
parameter DEFAULT_FRAME_TO_DATA_OFFSET = 0,
parameter [7:0] CHANNEL_TO_LOOK_AT_FOR_DEBUGGING = 0,
parameter ACTIVITY_MONITOR_NUMBITS = 32,
parameter [0:0] ALLOW_LOOK_AT_ALL_CHANNELS = 0,
parameter synchronizer_depth = 3
)
(
	input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
	
   input frame_clk,
   input frame_clk_valid,
   input        [numbits_datain-1:0] data_in[num_data_channels],
   input        [numbits_datain-1:0] frame_sampled_clock_in,
   output logic [numbits_datain-1:0] frame_sampled_clock_out,

   output logic [numbits_datain-1:0] data_out[num_data_channels],
   output logic reframer_is_locked,
	
	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output     [7:0] NUM_UARTS_HERE
	
);

assign NUM_UARTS_HERE = 1;



logic reset;
logic      [$clog2(numbits_datain)-1:0] frame_select;
logic      [$clog2(numbits_datain)-1:0] frame_to_data_offset;
logic      [numbits_datain-1:0] frame_lock_mask;  
logic [$clog2(numbits_datain)-1:0] actual_data_selection_value;
logic [7:0]  actualChannelToLookAt;
logic [$clog2(num_data_channels)-1:0]  internalChannelToLookAt;
logic [2*numbits_datain-1:0] raw_2x_bit_data[num_data_channels];
logic [2*numbits_datain-1:0] raw_2x_bit_frame;
logic [2*numbits_datain-1:0] raw_raw_2x_bit_data[num_data_channels];
logic [2*numbits_datain-1:0] raw_raw_2x_bit_frame;
logic transpose_2xbit_data_bits;
logic transpose_channel_data_halves;
logic [lock_wait_counter_bits-1:0] lock_wait;

logic [3:0]                 debug_lock_wait_machine_state_num;
logic [numbits_datain-1:0]  debug_frame_sampled_clock_in;
logic [numbits_datain-1:0]  debug_frame_sampled_clock_out;
logic [numbits_datain-1:0]  debug_data_in;
logic [numbits_datain-1:0]  debug_data_out;

logic [2*numbits_datain-1:0] debug_raw_2x_bit_frame;
logic [2*numbits_datain-1:0] debug_raw_raw_2x_bit_frame;
logic [2*numbits_datain-1:0] debug_raw_2x_bit_data;
logic [2*numbits_datain-1:0] debug_raw_raw_2x_bit_data;

logic [lock_wait_counter_bits-1:0] lock_wait_counter;
logic [3:0] lock_wait_machine_state_num;
logic enable_lock_scan  ;
logic clear_scan_counter;
logic inc_scan_counter  ;

logic [numbits_datain-1:0] raw_frame_lock_mask;
logic raw_transpose_2xbit_data_bits;
logic raw_transpose_channel_data_halves;
logic [lock_wait_counter_bits-1:0] raw_lock_wait;
logic raw_enable_lock_scan;

logic [numbits_datain-1:0] chosen_data_in               ;
logic [numbits_datain-1:0] chosen_data_out              ;
logic [2*numbits_datain-1:0] chosen_raw_2x_bit_data       ;
logic [2*numbits_datain-1:0] chosen_raw_raw_2x_bit_data   ;

logic [31:0] module_params;
reg [ACTIVITY_MONITOR_NUMBITS-1:0] activity_monitor = 0;

always @(posedge frame_clk)
begin
     activity_monitor <= activity_monitor + 1;
end

assign module_params = { ALLOW_LOOK_AT_ALL_CHANNELS, numbits_datain, num_data_channels, actualChannelToLookAt};

  		
multi_channel_generic_reframer
#(
.lock_wait_counter_bits(lock_wait_counter_bits),
.numbits_datain        (numbits_datain        ),
.num_data_channels     (num_data_channels     )
)
multi_channel_generic_reframer_inst
(
   .*   
);


generate
        if (ALLOW_LOOK_AT_ALL_CHANNELS)
		begin
		       assign actualChannelToLookAt = internalChannelToLookAt;
			   always_ff @(posedge frame_clk) //add additional pipeline register
			   begin
                            chosen_data_in              <= data_in            [actualChannelToLookAt];
                            chosen_data_out             <= data_out           [actualChannelToLookAt];
                            chosen_raw_2x_bit_data      <= raw_2x_bit_data    [actualChannelToLookAt];
                            chosen_raw_raw_2x_bit_data  <= raw_raw_2x_bit_data[actualChannelToLookAt];
			   end
			   
			   
		end else
		begin
		       assign actualChannelToLookAt = CHANNEL_TO_LOOK_AT_FOR_DEBUGGING;
		      assign chosen_data_in             = data_in            [CHANNEL_TO_LOOK_AT_FOR_DEBUGGING];
			  assign chosen_data_out            = data_out           [CHANNEL_TO_LOOK_AT_FOR_DEBUGGING];
			  assign chosen_raw_2x_bit_data     = raw_2x_bit_data    [CHANNEL_TO_LOOK_AT_FOR_DEBUGGING];
			  assign chosen_raw_raw_2x_bit_data = raw_raw_2x_bit_data[CHANNEL_TO_LOOK_AT_FOR_DEBUGGING];						
		end
endgenerate

logic mcp_from_frame_clk_aready, mcp_from_frame_clk_bvalid, mcp_to_frame_clk_aready, mcp_to_frame_clk_bvalid;
logic mcp2_reset, mcp1_reset;

my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(4 + 4*numbits_datain +  4*(2*numbits_datain)),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth) 
)
mcp_from_frame_clk
(
   .in_clk(frame_clk),
   .in_valid(1'b1),
   .in_data({
			   lock_wait_machine_state_num,
			   frame_sampled_clock_in,
			   frame_sampled_clock_out,
			   raw_2x_bit_frame,
			   raw_raw_2x_bit_frame,
			   chosen_data_in          ,   
			   chosen_data_out         ,   
			   chosen_raw_2x_bit_data  ,   
			   chosen_raw_raw_2x_bit_data 
			}),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_from_frame_clk_bvalid),
   .out_data({
				debug_lock_wait_machine_state_num,
				debug_frame_sampled_clock_in,
				debug_frame_sampled_clock_out,
				debug_raw_2x_bit_frame,
				debug_raw_raw_2x_bit_frame,
				debug_data_in,
				debug_data_out,
				debug_raw_2x_bit_data,
				debug_raw_raw_2x_bit_data
			   })
 );



//mcp_blk 
//#(
//.width(4 + 4*numbits_datain +  4*(2*numbits_datain)),
//.generate_edge_reset(1)
//) 
//mcp_from_frame_clk
//(
///* output  logic */                 .aready  (mcp_from_frame_clk_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({
//lock_wait_machine_state_num,
//frame_sampled_clock_in,
//frame_sampled_clock_out,
//raw_2x_bit_frame,
//raw_raw_2x_bit_frame,
//chosen_data_in          ,   
//chosen_data_out         ,   
//chosen_raw_2x_bit_data  ,   
//chosen_raw_raw_2x_bit_data 
//}),
///* input  logic */                  .asend   (1'b1),
///* input  logic */                  .aclk    (frame_clk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({
//debug_lock_wait_machine_state_num,
//debug_frame_sampled_clock_in,
//debug_frame_sampled_clock_out,
//debug_raw_2x_bit_frame,
//debug_raw_raw_2x_bit_frame,
//debug_data_in,
//debug_data_out,
//debug_raw_2x_bit_data,
//debug_raw_raw_2x_bit_data
//}),
///* output  logic */                 .bvalid  (mcp_from_frame_clk_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1),
//									.a_reset_edge(frame_clk_valid || mcp2_reset),
//									.b_reset_edge(frame_clk_valid || mcp2_reset)
//);

my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(numbits_datain+1+1+lock_wait_counter_bits+1),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth) 
)
mcp_to_frame_clk
(
   .in_clk(UART_REGFILE_CLK),
   .in_valid(1'b1),
   .in_data({raw_frame_lock_mask,raw_transpose_2xbit_data_bits,raw_transpose_channel_data_halves,raw_lock_wait,raw_enable_lock_scan}),
   .out_clk(frame_clk),
   .out_valid(mcp_to_frame_clk_bvalid),
   .out_data({frame_lock_mask,transpose_2xbit_data_bits,transpose_channel_data_halves,lock_wait,enable_lock_scan})
 );





//mcp_blk 
//#(
//.width(numbits_datain+1+1+lock_wait_counter_bits+1),
//.generate_edge_reset(1)
//) 
//mcp_to_frame_clk
//(
///* output  logic */                 .aready  (mcp_to_frame_clk_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({raw_frame_lock_mask,raw_transpose_2xbit_data_bits,raw_transpose_channel_data_halves,raw_lock_wait,raw_enable_lock_scan}),
///* input  logic */                  .asend   (1'b1),
///* input  logic */                  .aclk    (UART_REGFILE_CLK),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({frame_lock_mask,transpose_2xbit_data_bits,transpose_channel_data_halves,lock_wait,enable_lock_scan}),
///* output  logic */                 .bvalid  (mcp_to_frame_clk_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (frame_clk),
///* input  logic */                  .brst_n  (1'b1),
//									.a_reset_edge(frame_clk_valid || mcp1_reset ),
//									.b_reset_edge(frame_clk_valid || mcp1_reset )
//);
			
										  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 7;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 15;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0 ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 1;
			
			/* dummy wishbone interface definitions */		
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			status_wishbone_interface_pins();
						
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			control_wishbone_interface_pins();
			
			
			
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
			assign uart_regfile_interface_pins.clk       = UART_REGFILE_CLK;
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
			  .uart_regfile_interface_pins(uart_regfile_interface_pins),
			  .status_wishbone_interface_pins (status_wishbone_interface_pins ), 
			  .control_wishbone_interface_pins(control_wishbone_interface_pins)			  
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
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  DEFAULT_FRAME_LOCK_MASK;
    assign uart_regfile_interface_pins.control_desc[0]               = "frm_lock_mask";
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = numbits_datain;		
	 assign raw_frame_lock_mask = uart_regfile_interface_pins.control[0];
		
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  DEFAULT_TRANSPOSE_CTRL;
    assign uart_regfile_interface_pins.control_desc[1]               = "transpose_ctrl";
    assign {  raw_transpose_2xbit_data_bits, raw_transpose_channel_data_halves} = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 2;		
	  

	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_LOCK_WAIT;
    assign uart_regfile_interface_pins.control_desc[2]               = "lock_wait";
    assign raw_lock_wait     = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = lock_wait_counter_bits;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  DEFAULT_ENABLE_LOCK_SCAN;
    assign uart_regfile_interface_pins.control_desc[3]               = "ENABLE_LOCK_SCAN";
    assign raw_enable_lock_scan     = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = 1;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  DEFAULT_FRAME_TO_DATA_OFFSET;
    assign uart_regfile_interface_pins.control_desc[4]               = "Frame2DataOffset";
    assign frame_to_data_offset     = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = $clog2(numbits_datain);		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[5]  =  CHANNEL_TO_LOOK_AT_FOR_DEBUGGING;
    assign uart_regfile_interface_pins.control_desc[5]               = "CTRLChanLook";
    assign internalChannelToLookAt     = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = $clog2(num_data_channels);		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[6]  =  0;
    assign uart_regfile_interface_pins.control_desc[6]               = "mcp_blk_reset";
    assign {mcp2_reset, mcp1_reset}     = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6]      = 2;		
	
	
	assign uart_regfile_interface_pins.status[0] = debug_lock_wait_machine_state_num;
	assign uart_regfile_interface_pins.status_desc[0]    ="lock_SM_State";	

	assign uart_regfile_interface_pins.status[1] = debug_frame_sampled_clock_in;
	assign uart_regfile_interface_pins.status_desc[1]    ="frmSampClkIn";
	
	assign uart_regfile_interface_pins.status[2] = debug_frame_sampled_clock_out;
	assign uart_regfile_interface_pins.status_desc[2]    ="frmSampClkOut";
	
	assign uart_regfile_interface_pins.status[3] = debug_raw_2x_bit_frame;
	assign uart_regfile_interface_pins.status_desc[3]    ="rawFrm2xbit";
		
    assign uart_regfile_interface_pins.status[4] = debug_raw_raw_2x_bit_frame;
	assign uart_regfile_interface_pins.status_desc[4]    ="rawrawFrm2xbit";
	
	assign uart_regfile_interface_pins.status[5] = debug_data_in;
	assign uart_regfile_interface_pins.status_desc[5]    ="debugDataIn";
		
	assign uart_regfile_interface_pins.status[6] = debug_data_out;
	assign uart_regfile_interface_pins.status_desc[6]    ="debugDataOut";
	
    assign uart_regfile_interface_pins.status[7] = debug_raw_2x_bit_data;
	assign uart_regfile_interface_pins.status_desc[7]    ="debugRaw2xData";
	
    assign uart_regfile_interface_pins.status[8] = debug_raw_raw_2x_bit_data;
	assign uart_regfile_interface_pins.status_desc[8]    ="debugRawRaw2xDat";

    assign uart_regfile_interface_pins.status[9] = frame_select;
	assign uart_regfile_interface_pins.status_desc[9]    ="frame_select";

    assign uart_regfile_interface_pins.status[10] = actual_data_selection_value;
	assign uart_regfile_interface_pins.status_desc[10]    ="actual_frm_sel";    
	
	assign uart_regfile_interface_pins.status[11] = reframer_is_locked;
	assign uart_regfile_interface_pins.status_desc[11]    ="reframerLocked";

	assign uart_regfile_interface_pins.status[12] = module_params;
	assign uart_regfile_interface_pins.status_desc[12]    ="moduleParams";

	assign uart_regfile_interface_pins.status[13] = activity_monitor;
	assign uart_regfile_interface_pins.status_desc[13]    ="activityMonitor";

	assign uart_regfile_interface_pins.status[14] = {mcp_from_frame_clk_aready, mcp_from_frame_clk_bvalid, mcp_to_frame_clk_aready, mcp_to_frame_clk_bvalid};
	assign uart_regfile_interface_pins.status_desc[14]    ="mcp_status";

 endmodule
 
`default_nettype wire
