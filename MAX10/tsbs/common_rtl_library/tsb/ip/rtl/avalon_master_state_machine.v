`default_nettype none
module avalon_master_state_machine
#(
	parameter DATAWIDTH = 32,
	parameter BYTEENABLEWIDTH = DATAWIDTH/8,
	parameter ADDRESSWIDTH = 32,
	parameter LATCHED_READ_DATA_DEFAULT = 32'hEAAEAA, //default is error 
	parameter idle                = 12'b0000_0000_0000,
	parameter assert_write        = 12'b0000_0100_0010,
	parameter wait_for_write      = 12'b0000_0100_0011,
	parameter assert_read         = 12'b0000_1000_0100,
	parameter wait_for_read       = 12'b0000_1000_0101,
	parameter latch_readdata      = 12'b0000_1010_0110,
	parameter assert_finish       = 12'b0000_0001_0111
)

 (
	input clk,
	input reset_n,
	input start,
	
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
	output reg [15:0] state = idle,
	output logic latch_read_now
);

reg [DATAWIDTH-1:0] latched_read_data = LATCHED_READ_DATA_DEFAULT;

assign finish         = state[4];
assign latch_read_now = state[5];
assign master_write   = state[6];
assign master_read    = state[7];
assign master_byteenable = user_byteenable;

always_ff @(posedge clk or negedge reset_n)
begin
       if (~reset_n)
	   begin
	        latched_read_data <= LATCHED_READ_DATA_DEFAULT;			
	   end else
	   begin 
	         if (latch_read_now)
			 begin
			        latched_read_data <= master_readdata;			 
			 end	   	   
	   end
end

assign master_address = user_address;
assign master_writedata = user_write_data;
assign user_read_data = latched_read_data;

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
								       if (is_write) 
									   begin
									         state <= assert_write;					 
									   end else
									   begin
									         state <= assert_read;
									   end
								 end
						   end
						   
					assert_write: state <= wait_for_write;
					wait_for_write    : if (!master_waitrequest)
									   begin
											 state <= assert_finish;
									   end
									   
					assert_read: state <= wait_for_read;
					wait_for_read    : if (!master_waitrequest)
									   begin
											 state <= latch_readdata;
									   end
					latch_readdata : state <= assert_finish;
					assert_finish  : state <= idle;			   
					endcase
		end
   end
   
   endmodule
   `default_nettype wire