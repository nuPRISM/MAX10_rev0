// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005

`default_nettype none
module transfer_word_over_separate_avalon_mm_interfaces
#(
	parameter DATAWIDTH = 32,
	parameter BYTEENABLEWIDTH = DATAWIDTH/8,
	parameter ADDRESSWIDTH = 32,
	parameter WAIT_CYCLE_COUNTER_WIDTH = 8,
	
	parameter idle                                  = 12'b0000_0000_0000,
	parameter assemble_read_transaction             = 12'b0000_0000_0001,
	parameter start_read_transaction                = 12'b0000_1000_0010,
	parameter wait_for_read_transaction             = 12'b0000_0000_0011,
    parameter assemble_write_transaction            = 12'b0000_0010_0100,
	parameter start_write_transaction               = 12'b0001_0010_0101,
	parameter wait_for_write_transaction            = 12'b0000_0010_0110,
	parameter assert_finish                         = 12'b0000_0001_0111
)

 (
	input clk,
	input reset_n,
	input start,
	
	output logic finish,
	
	input logic [ADDRESSWIDTH-1:0] read_address,
	input logic [ADDRESSWIDTH-1:0] write_address,
	 
	// master inputs and outputs
	output logic [ADDRESSWIDTH-1:0] master_address,
	output logic master_write,
	output logic master_read,
	output logic [BYTEENABLEWIDTH-1:0] master_byteenable,
	input  logic [DATAWIDTH-1:0] master_readdata,
	input  logic [WAIT_CYCLE_COUNTER_WIDTH-1:0] wait_cycles,
	output logic [DATAWIDTH-1:0] master_writedata,
	input  master_waitrequest_read,
	input  master_waitrequest_write,
	
	//debug outputs
	output reg [15:0] state = idle,
	output logic [ADDRESSWIDTH-1:0] write_master_address,
	output logic [ADDRESSWIDTH-1:0] read_master_address,
    output logic [BYTEENABLEWIDTH-1:0] read_master_byteenable,
	output logic [BYTEENABLEWIDTH-1:0] write_master_byteenable,

	output logic [15:0] avalon_mm_master_state,
	output logic avalon_mm_master_start,
	output logic avalon_mm_master_finish,	
	
	output logic [15:0] read_avalon_mm_master_state,
	output logic read_avalon_mm_master_start,
	output logic read_avalon_mm_master_finish,	
	output logic [15:0] write_avalon_mm_master_state,
	output logic write_avalon_mm_master_start,
	output logic write_avalon_mm_master_finish,	
	output logic is_write,
	output logic latch_read_now,
	output logic [DATAWIDTH-1:0] user_write_data,
	output logic [DATAWIDTH-1:0] user_read_data,
	output logic [ADDRESSWIDTH-1:0] user_address,
	output logic [BYTEENABLEWIDTH-1:0] user_byteenable
	
	
);

assign finish                            = state[4];
assign is_write                          = state[5];
assign read_avalon_mm_master_start       = state[7];
assign write_avalon_mm_master_start      = state[8];

assign user_write_data    = user_read_data;
assign user_byteenable    = -1; 
assign user_address       = is_write ? write_address : read_address;
assign master_address     = is_write ? write_master_address : read_master_address;
assign master_byteenable  = is_write ? write_master_byteenable : read_master_byteenable;

assign avalon_mm_master_state   = is_write ? write_avalon_mm_master_state : read_avalon_mm_master_state;
assign avalon_mm_master_start   = write_avalon_mm_master_start | read_avalon_mm_master_start;
assign avalon_mm_master_finish	= write_avalon_mm_master_finish | read_avalon_mm_master_finish;
	

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
								        state <= assemble_read_transaction;
								 end
						   end
						   
					assemble_read_transaction: state <= start_read_transaction;
					start_read_transaction  :  state <= wait_for_read_transaction;
					wait_for_read_transaction    : if (read_avalon_mm_master_finish)
									   begin
											 state <= assemble_write_transaction;
									   end			   
					assemble_write_transaction: state <= start_write_transaction;
					start_write_transaction  :  state <= wait_for_write_transaction;
					wait_for_write_transaction    : if (write_avalon_mm_master_finish)
									   begin
											 state <= assert_finish;
									   end						
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
read_avalon_master_state_machine_inst (
	.clk               (clk                    ),
	.finish            (read_avalon_mm_master_finish),
	.is_write          (is_write               ),
	.latch_read_now    (latch_read_now         ),
	.master_address    (read_master_address         ),
	.master_byteenable (read_master_byteenable      ),
	.master_read       (master_read            ),
	.master_readdata   (master_readdata        ),
	.master_waitrequest(master_waitrequest_read),
	.master_write      (                       ),
	.master_writedata  (                       ),
	.reset_n           (reset_n                ),
	.start             (read_avalon_mm_master_start ),
	.state             (read_avalon_mm_master_state ),
	.user_address      (user_address           ),
	.user_read_data    (user_read_data         ),
	.user_write_data   (                       ),
	.user_byteenable   (user_byteenable        ),
	.wait_cycles       (wait_cycles            )
);

avalon_master_state_machine_w_programmable_wait 
#(
	.DATAWIDTH      (DATAWIDTH),
	.BYTEENABLEWIDTH(BYTEENABLEWIDTH),
	.ADDRESSWIDTH   (ADDRESSWIDTH),
	.WAIT_CYCLE_COUNTER_WIDTH(WAIT_CYCLE_COUNTER_WIDTH)
)
write_avalon_master_state_machine_inst (
	.clk               (clk                          ),
	.finish            (write_avalon_mm_master_finish),
	.is_write          (is_write                     ),
	.latch_read_now    (                             ),
	.master_address    (write_master_address               ),
	.master_byteenable (write_master_byteenable            ),
	.master_read       (                             ),
	.master_readdata   (                             ),
	.master_waitrequest(master_waitrequest_write     ),
	.master_write      (master_write                 ),
	.master_writedata  (master_writedata             ),
	.reset_n           (reset_n                      ),
	.start             (write_avalon_mm_master_start ),
	.state             (write_avalon_mm_master_state ),
	.user_address      (user_address                 ),
	.user_read_data    (                             ),
	.user_write_data   (user_write_data              ),
	.user_byteenable   (user_byteenable              ),
	.wait_cycles       (wait_cycles                  )
);

endmodule
`default_nettype wire
