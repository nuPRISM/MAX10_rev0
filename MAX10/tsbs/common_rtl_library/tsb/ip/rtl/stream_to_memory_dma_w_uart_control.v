`ifndef STANDALONE_STREAM_TO_MEMORY_W_UART_CONTROL_V
`define STANDALONE_STREAM_TO_MEMORY_W_UART_CONTROL_V


`default_nettype none
`include "interface_defs.v"
//`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

`ifndef STANDALONE_STREAM_TO_MEMORY_W_UART_CONTROL_KEEP
`define STANDALONE_STREAM_TO_MEMORY_W_UART_CONTROL_KEEP
`endif

module stream_to_memory_dma_w_uart_control
#(
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_ST2DMA"},
parameter DATAWIDTH = 32,
parameter ADDRESSWIDTH = 32,
parameter WAIT_CYCLE_COUNTER_WIDTH = 8,
parameter WORD_COUNTER_WIDTH = 32,
parameter UART_REGFILE_TYPE = uart_regfile_types::STREAM_TO_DMA_REGFILE,
parameter [0:0] COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0,
parameter ENABLE_KEEPS = 0
)
(
	input  UART_CLK,
	input  RESET_FOR_UART_CLK,
	input  dma_clk,
	output uart_tx,
	input  uart_rx, 
	input  reset_n,
	input logic       UART_IS_SECONDARY_UART,
    input logic [7:0] UART_NUM_SECONDARY_UARTS,
    input logic [7:0] UART_ADDRESS_OF_THIS_UART,
	output logic [7:0] NUM_UARTS_HERE,
	
	input logic [DATAWIDTH-1:0] data_in,
	input logic data_clk,
	input logic data_valid,
	
    avalon_mm_simple_bridge_interface dma_controller_avalon_mm_interface_pins,
	 input ignore_crc_value_for_debugging
);
assign NUM_UARTS_HERE = 1;
     
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         dma_async_start;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         raw_dma_finished;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         dma_finished;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         async_dma_start;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic         dma_start;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  user_logic_read_master_control_write_base       ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]  user_logic_read_master_control_write_length     ;

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [15:0]  dma_state       ;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [15:0]  avalon_mm_master_state;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [7:0]   hw_dma_wait_cycles;	
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] current_word_counter;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] num_words_received;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] dma_sequence_number;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic forced_stop;

edge_detect 
make_dma_start_signal
(
.in_signal(async_dma_start), 
.clk(dma_clk), 
.edge_detect(dma_start)
);

always_ff @(posedge dma_clk)
begin
      if (dma_start)
	  begin
	        dma_sequence_number <= dma_sequence_number + 1;
	  end
end

edge_detect_and_hold 
make_dma_finished_signal
(
.in_signal(raw_dma_finished), 
.clk(dma_clk), 
.edge_received(dma_finished), 
.reset(dma_start)
);

write_stream_of_low_speed_words_to_avmm
#(
	.DATAWIDTH(DATAWIDTH),
	.ADDRESSWIDTH(ADDRESSWIDTH),
	.WAIT_CYCLE_COUNTER_WIDTH(WAIT_CYCLE_COUNTER_WIDTH),
	.WORD_COUNTER_WIDTH(WORD_COUNTER_WIDTH)
)
write_stream_of_low_speed_words_to_avmm_inst
 (
	.clk(dma_clk),
	.reset_n(reset_n),
	.start(dma_start),
	.forced_stop,
	.finish(raw_dma_finished),
	
	.data_in,
	.data_clk,
	.data_valid,
	.num_words_to_write(user_logic_read_master_control_write_length),
	.data_start_address(user_logic_read_master_control_write_base),
	 
	// master inputs and outputs
	.master_address(dma_controller_avalon_mm_interface_pins.address),
	.master_write(dma_controller_avalon_mm_interface_pins.write),
	.master_read(),
	.master_byteenable(dma_controller_avalon_mm_interface_pins.byteenable),
	.master_readdata(),
	.wait_cycles(hw_dma_wait_cycles),
	.master_writedata(dma_controller_avalon_mm_interface_pins.writedata ),
	.master_waitrequest(dma_controller_avalon_mm_interface_pins.waitrequest),
	
	//debug outputs
	.state(dma_state),
	.avalon_mm_master_state(avalon_mm_master_state),
	.avalon_mm_master_start(),
	.avalon_mm_master_finish(),	
	.reset_current_word_counter(),
	.current_word_counter(current_word_counter),
	.num_words_received(num_words_received),
	.inc_current_word_counter(),	
	.latch_current_word_to_write(),	
	.actual_reset_current_word_counter_n(),
    .raw_current_word_to_write(),	
    .current_word_to_write(),	    
	.new_data_received(),
	.synced_data_valid(),
	.enable_input_word_counting(),

	// user logic inputs and outputs
	.is_write(),
	.user_write_data(),
	.user_read_data(),
	.user_address(),
	.user_byteenable()
);
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 4;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 6;			
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
			assign uart_regfile_interface_pins.ignore_crc_value_for_debugging = ignore_crc_value_for_debugging;
			
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
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS),
			 .COMPILE_CRC_ERROR_CHECKING_IN_PARSER         (COMPILE_CRC_ERROR_CHECKING_IN_PARSER)
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
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  0;
    assign uart_regfile_interface_pins.control_desc[0]               = "dma_write_base";
    assign user_logic_read_master_control_write_base                           = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  0;
    assign uart_regfile_interface_pins.control_desc[1]               = "dma_write_length";
    assign user_logic_read_master_control_write_length                     = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 32;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  0;
    assign uart_regfile_interface_pins.control_desc[2]               = "dma_start";
    assign {forced_stop,async_dma_start} = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 4;		
		 
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  0;
    assign uart_regfile_interface_pins.control_desc[3]               = "wait_cycles";
    assign hw_dma_wait_cycles = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = WAIT_CYCLE_COUNTER_WIDTH;	
	
	assign uart_regfile_interface_pins.status[0] ={dma_finished};
	assign uart_regfile_interface_pins.status_desc[0]= "dma_finished";									
				
	assign uart_regfile_interface_pins.status[1] = dma_state;
	assign uart_regfile_interface_pins.status_desc[1]= "dma_state";				
	
	assign uart_regfile_interface_pins.status[2] = avalon_mm_master_state;
	assign uart_regfile_interface_pins.status_desc[2]= "avmm_state";		
	
	assign uart_regfile_interface_pins.status[3] = current_word_counter;
	assign uart_regfile_interface_pins.status_desc[3]= "cur_word_counter";				
	
	assign uart_regfile_interface_pins.status[4] = num_words_received;
	assign uart_regfile_interface_pins.status_desc[4]= "num_words_received";									
			
	assign uart_regfile_interface_pins.status[5] = dma_sequence_number;
	assign uart_regfile_interface_pins.status_desc[5]= "dma_seq_num";									
			
endmodule
`default_nettype wire
`endif
