// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`default_nettype none
module write_a_series_of_32bit_words_to_avalon_mm
#(
	parameter DATAWIDTH = 32,
	parameter BYTEENABLEWIDTH = DATAWIDTH/8,
	parameter ADDRESSWIDTH = 32,
	parameter WAIT_CYCLE_COUNTER_WIDTH = 8,
	parameter WORD_COUNTER_WIDTH = 8,
    parameter [31:0] MAX_NUM_WORDS_TO_WRITE = 10,
    
	parameter idle                                  = 12'b0000_0000_0000,
	parameter init_counter                          = 12'b0000_0010_0010,
	parameter assemble_transaction_data             = 12'b0001_0000_0011,
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
	
	output logic finish,
	
	input logic [31:0] words_to_write[MAX_NUM_WORDS_TO_WRITE-1:0],
	input logic [WORD_COUNTER_WIDTH-1:0] num_words_to_write,
	input logic [31:0] data_start_address,
	 
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
	output reg [15:0] state = idle,
	output logic [15:0] avalon_mm_master_state,
	output logic avalon_mm_master_start,
	output logic avalon_mm_master_finish,	
	output logic reset_current_word_counter,
	output reg [WORD_COUNTER_WIDTH-1:0] current_word_counter = 0,
	output logic inc_current_word_counter,	
	output logic latch_current_word_to_write,	
	output logic actual_reset_current_word_counter_n,
    output logic [31:0] raw_current_word_to_write,	
    output logic [31:0] current_word_to_write,	    
	
	// user logic inputs and outputs
	output logic is_write,
	output logic [DATAWIDTH-1:0] user_write_data,
	output logic [DATAWIDTH-1:0] user_read_data,
	output logic [ADDRESSWIDTH-1:0] user_address,
	output logic [BYTEENABLEWIDTH-1:0] user_byteenable
	
	
);

assign finish                      = state[4];
assign reset_current_word_counter      = state[5];
assign inc_current_word_counter        = state[6];
assign avalon_mm_master_start      = state[7];
assign latch_current_word_to_write = state[8];

assign user_write_data    = current_word_to_write;
assign user_byteenable    = -1; 
assign user_address       = data_start_address + {current_word_counter,2'b00};

assign is_write  = 1;
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

assign raw_current_word_to_write = words_to_write[current_word_counter]; 

always @(posedge clk)
begin
     if (latch_current_word_to_write)
	 begin
          current_word_to_write <= raw_current_word_to_write;
	 end
end  


 always_ff @ (posedge clk or negedge reset_n)
   begin
        if (!reset_n)
		begin
		     state <= idle;
		end else
		begin
  				case (state)
					idle: begin
								 if (start) 
								 begin 
								        state <= init_counter;
								 end
						   end
						   
					init_counter: state <= assemble_transaction_data;
					assemble_transaction_data    :  state <= start_transaction;
					start_transaction    :  state <= wait_for_transaction;
					wait_for_transaction    : if (avalon_mm_master_finish)
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
   
avalon_master_state_machine_w_programmable_wait 
#(
	.DATAWIDTH      (DATAWIDTH),
	.BYTEENABLEWIDTH(BYTEENABLEWIDTH),
	.ADDRESSWIDTH   (ADDRESSWIDTH),
	.WAIT_CYCLE_COUNTER_WIDTH(WAIT_CYCLE_COUNTER_WIDTH)
)
avalon_master_state_machine_inst (
	.clk               (clk                    ),
	.finish            (avalon_mm_master_finish),
	.is_write          (is_write               ),
	.latch_read_now    (                       ),
	.master_address    (master_address         ),
	.master_byteenable (master_byteenable      ),
	.master_read       (master_read            ),
	.master_readdata   (master_readdata        ),
	.master_waitrequest(master_waitrequest     ),
	.master_write      (master_write           ),
	.master_writedata  (master_writedata       ),
	.reset_n           (reset_n                ),
	.start             (avalon_mm_master_start ),
	.state             (avalon_mm_master_state ),
	.user_address      (user_address           ),
	.user_read_data    (user_read_data         ),
	.user_write_data   (user_write_data        ),
	.user_byteenable   (user_byteenable        ),
	.wait_cycles       (wait_cycles            )
);

endmodule
`default_nettype wire
