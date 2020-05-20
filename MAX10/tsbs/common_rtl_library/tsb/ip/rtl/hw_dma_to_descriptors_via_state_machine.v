// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`default_nettype none

module hw_dma_to_descriptors_via_state_machine
#(
	parameter DATAWIDTH = 32,
	parameter BYTEENABLEWIDTH = DATAWIDTH/8,
	parameter ADDRESSWIDTH = 32,
	parameter WAIT_CYCLE_COUNTER_WIDTH = 8,
	parameter DESCRIPTOR_COUNTER_WIDTH = 8,
	parameter WORDS_PER_DESCRIPTOR = 4,
	`ifdef CLOG2_SUPPORTED
	parameter LOG2_WORDS_PER_DESCRIPTOR = $clog2(WORDS_PER_DESCRIPTOR),
	`else
	parameter LOG2_WORDS_PER_DESCRIPTOR = 2,
	`endif
	parameter WORD_COUNTER_WIDTH = DESCRIPTOR_COUNTER_WIDTH + LOG2_WORDS_PER_DESCRIPTOR,
    parameter [31:0] MAX_DESCRIPTORS_TO_WRITE = 128,
	parameter synchronizer_depth = 3,
    
	parameter idle                                  = 12'b0000_0000_0000,
	parameter init_counter                          = 12'b0000_0010_0010,
	parameter assemble_transaction_data             = 12'b0000_0000_0011,
	parameter start_transaction                     = 12'b0000_1000_0100,
	parameter wait_for_transaction                  = 12'b0000_0000_0101,
	parameter check_counter                         = 12'b0000_0000_0110,
	parameter inc_counter                           = 12'b0000_0100_0110,
	parameter assert_finish                         = 12'b0000_0001_1001
)

 (
	input clk,
	input reset_n,
	input start,
	input async_start,
	
	output logic finish,
	
	input logic [DESCRIPTOR_COUNTER_WIDTH-1:0] num_descriptors_to_write,
	input logic [ADDRESSWIDTH-1:0] data_start_address,
	input logic [ADDRESSWIDTH-1:0] descriptor_space_start_address,
	 
	// master inputs and outputs
	output logic [ADDRESSWIDTH-1:0] master_address,
	output logic master_write,
	output logic master_read,
	output logic [BYTEENABLEWIDTH-1:0] master_byteenable,
	input  logic [DATAWIDTH-1:0] master_readdata,
	input  logic [WAIT_CYCLE_COUNTER_WIDTH-1:0] wait_cycles,
	output logic [DATAWIDTH-1:0] master_writedata,
	input  master_waitrequest,
	
	//debug outputs
	output reg   [15:0] state = idle,
	output logic [15:0] avalon_mm_master_state,
	output logic [15:0] transfer_word_state,
	output logic avalon_mm_master_start,
	output logic sync_start,
	output logic transfer_word_start,
	output logic avalon_mm_master_finish,	
	output logic transfer_word_finish,	
	output logic reset_current_word_counter,
	output reg   [WORD_COUNTER_WIDTH-1:0] current_word_counter = 0,
	output logic inc_current_word_counter,	
	output logic latch_read_now,	
	output logic actual_reset_current_word_counter_n,
	output logic is_write,
	output logic [DATAWIDTH-1:0] num_words_to_write,
	output logic [DATAWIDTH-1:0] user_write_data,
	output logic [DATAWIDTH-1:0] user_read_data,
	output logic [ADDRESSWIDTH-1:0] user_address,
	output logic [ADDRESSWIDTH-1:0] read_address,
	output logic [ADDRESSWIDTH-1:0] write_address,
	output logic [BYTEENABLEWIDTH-1:0] user_byteenable
	
	
);

assign finish                      = state[4];
assign reset_current_word_counter  = state[5];
assign inc_current_word_counter    = state[6];
assign transfer_word_start         = state[7];

assign read_address       = data_start_address + {current_word_counter,2'b00};
assign write_address      = descriptor_space_start_address + {current_word_counter[LOG2_WORDS_PER_DESCRIPTOR-1:0],2'b00};
assign num_words_to_write = {num_descriptors_to_write,{LOG2_WORDS_PER_DESCRIPTOR{1'b0}}};

assign actual_reset_current_word_counter_n = !((!reset_n) | reset_current_word_counter);

always @(posedge clk or negedge actual_reset_current_word_counter_n) 
begin
     if (!actual_reset_current_word_counter_n)
	 begin
	       current_word_counter <= 0;
	 end else 
	 begin
	       if (inc_current_word_counter)
		   begin
		         current_word_counter <= current_word_counter + 1;
		   end	 
	 end
end

 async_trap_and_reset_gen_1_pulse_robust
 #(.synchronizer_depth(synchronizer_depth))
 make_start_signal
 (
 .async_sig(async_start), 
 .outclk(clk), 
 .out_sync_sig(sync_start), 
 .auto_reset(1'b1), 
 .reset(1'b1)
 );

 always_ff @ (posedge clk or negedge reset_n)
   begin
        if (!reset_n)
		begin
		     state <= idle;
		end else
		begin
  				case (state)
					idle: begin
								 if (start || sync_start) 
								 begin 
								        state <= init_counter;
								 end
						   end
						   
					init_counter: state <= assemble_transaction_data;
					assemble_transaction_data    :  state <= start_transaction;
					start_transaction    :  state <= wait_for_transaction;
					wait_for_transaction    : if (transfer_word_finish)
									   begin
											 state <= check_counter;
									   end			   
					check_counter: if (current_word_counter >= num_words_to_write - 1)
					               begin								       
										state <= assert_finish;										
								   end else
								   begin
								         state <= inc_counter;
								   end
					inc_counter : state <= assemble_transaction_data;					
					assert_finish  : state <= idle;			   
					endcase
		end
   end
   
transfer_word_over_avalon_mm 
#(
	.DATAWIDTH      (DATAWIDTH),
	.BYTEENABLEWIDTH(BYTEENABLEWIDTH),
	.ADDRESSWIDTH   (ADDRESSWIDTH),
	.WAIT_CYCLE_COUNTER_WIDTH(WAIT_CYCLE_COUNTER_WIDTH)
)
transfer_word_over_avalon_mm_inst (
	.avalon_mm_master_finish(avalon_mm_master_finish),
	.avalon_mm_master_start(avalon_mm_master_start),
	.avalon_mm_master_state(avalon_mm_master_state),
	.clk(clk),
	.start(transfer_word_start),
	.finish(transfer_word_finish),
	.is_write(is_write),
	.latch_read_now(latch_read_now),
	.master_address(master_address),
	.master_byteenable(master_byteenable),
	.master_read(master_read),
	.master_readdata(master_readdata),
	.master_waitrequest(master_waitrequest),
	.master_write(master_write),
	.master_writedata(master_writedata),
	.read_address(read_address),	
	.write_address(write_address),
	.reset_n(reset_n),
	.state(transfer_word_state),
	.user_address(user_address),
	.user_byteenable(user_byteenable),
	.user_read_data(user_read_data),
	.user_write_data(user_write_data),
	.wait_cycles(wait_cycles)
);

endmodule
`default_nettype wire
