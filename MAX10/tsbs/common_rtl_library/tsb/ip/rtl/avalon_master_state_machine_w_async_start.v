`default_nettype none
module avalon_master_state_machine_w_async_start
#(
	parameter DATAWIDTH                  = 32,
	parameter BYTEENABLEWIDTH                   = DATAWIDTH/8,
	parameter ADDRESSWIDTH                      = 32,
	parameter LATCHED_READ_DATA_DEFAULT = 32'hEAAEAA, //default is error 
	parameter synchronizer_depth = 3
)

 (
	input clk,
	input reset_n,
	input async_start,
	output sync_start,
	
	output logic finish,

	// user logic inputs and outputs
	input is_write,
	input logic [DATAWIDTH-1:0] user_write_data,
	output logic [DATAWIDTH-1:0] user_read_data,
	input logic [ADDRESSWIDTH-1:0] user_address,
	input logic [BYTEENABLEWIDTH-1:0] user_byteenable,
	
	
	// master inputs and outputs
	output logic [ADDRESSWIDTH-1:0] master_address,
	output logic master_write,
	output logic master_read,
	output logic [BYTEENABLEWIDTH-1:0] master_byteenable,
	input  logic [DATAWIDTH-1:0] master_readdata,
	output logic [DATAWIDTH-1:0] master_writedata,
	input  master_waitrequest,
	
	//debug outputs
	output reg [15:0] state,
	output logic latch_read_now
);


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
	
avalon_master_state_machine
#(
.DATAWIDTH                    (DATAWIDTH                ),
.BYTEENABLEWIDTH              (BYTEENABLEWIDTH          ),
.ADDRESSWIDTH                 (ADDRESSWIDTH             ),
.LATCHED_READ_DATA_DEFAULT    (LATCHED_READ_DATA_DEFAULT)
)
avalon_master_state_machine_inst
(
.start(sync_start),
.*
);

endmodule
`default_nettype wire