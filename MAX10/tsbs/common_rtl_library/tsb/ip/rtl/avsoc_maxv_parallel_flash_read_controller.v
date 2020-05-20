`default_nettype none
module avsoc_maxv_parallel_flash_read_controller
#(
  parameter synchronizer_depth = 3,
  parameter wait_counter_bits                   = 5,
  
  parameter idle                                = 16'b0000_0000_0000_0000,
  parameter select_word0                        = 16'b0000_1000_0000_0001,
  parameter latch_word0                         = 16'b0100_1000_0000_0010,
  parameter select_word1                        = 16'b0000_1001_0000_0011,
  parameter latch_word1                         = 16'b0100_1001_0000_0100,
  parameter select_word2                        = 16'b0000_1010_0000_0101,
  parameter latch_word2                         = 16'b0100_1010_0000_0110,
  parameter select_word3                        = 16'b0000_1011_0000_0111,
  parameter latch_word3                         = 16'b0100_1011_0000_1000,
  parameter select_word4                        = 16'b0000_1100_0000_1001,
  parameter latch_word4                         = 16'b0100_1100_0000_1010,
  parameter start_wait_for_flash                = 16'b0000_0000_1000_1101,
  parameter wait_for_wait_for_flash             = 16'b0000_0000_0000_1110,  
  parameter latch_result0                       = 16'b0010_0000_0000_1111,
  parameter select_result1                      = 16'b0000_0001_0000_1111,
  parameter latch_result1                       = 16'b0010_0001_0001_0000,
  parameter finished                            = 16'b0001_0000_0001_0001
)
(
input  wire clk,
input  reset,
output wire start_delay_counter,
output reg  [15:0] state = idle,
input  [wait_counter_bits-1:0] wait_for_flash,
output wait_counter_finished,
output   delay_reset_n,

output dir,

input [29:0] flash_addr_request,
input async_start,
output sync_start,

output [2:0] addr_out,
output latch_now,

output [5:0] data_out,
input  [7:0] data_in,

output reg [15:0] flash_read_result = 0,
output latch_result_now,
output finish,
output reg result_ready = 0
 );
  

assign start_delay_counter    = state[7];
assign addr_out               = state[10:8];
assign dir                    = state[11];
assign finish                 = state[12];
assign latch_result_now       = state[13];
assign latch_now              = state[14];

always_comb
begin
      case (addr_out)
	  3'b000: data_out = flash_addr_request[5:0];
	  3'b001: data_out = flash_addr_request[11:6];
	  3'b010: data_out = flash_addr_request[17:12];
	  3'b011: data_out = flash_addr_request[23:18];
	  3'b100: data_out = flash_addr_request[29:24];
	  default: data_out = flash_addr_request[5:0];
	  endcase
end

always_ff @(posedge clk)
begin
      if (latch_result_now)
	  begin
	         if (addr_out == 0)
			 begin
			      flash_read_result[7:0] <= data_in[7:0];
				  flash_read_result[15:8] <= flash_read_result[15:8]; 		 
			 end else 
			 begin
			      flash_read_result[7:0] <=  flash_read_result[7:0];
				  flash_read_result[15:8] <= data_in[7:0];; 		 			 			 
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

always @(posedge clk or posedge async_start)
begin
      if (async_start)
	  begin 
	         result_ready <= 0;	  
	  end else
	  begin
	         if (finish)
			 begin
			         result_ready <= 1;
			 end	  
	  end
end


assign delay_reset_n = ~reset;

always_ff @(posedge clk or posedge reset)
begin
      if (reset)
	  begin
	        state <= idle;
	  end
	  else 
	  begin
				  case (state)
				  idle : if (sync_start)
				          begin
				            state <= select_word0;			 
						  end						  
				 select_word0               : state <= latch_word0              ;
				 latch_word0                : state <= select_word1             ;
				 select_word1               : state <= latch_word1              ;
				 latch_word1                : state <= select_word2             ;
				 select_word2               : state <= latch_word2              ;
				 latch_word2                : state <= select_word3             ;
				 select_word3               : state <= latch_word3              ;
				 latch_word3                : state <= select_word4             ;
				 select_word4               : state <= latch_word4              ;
				 latch_word4                : state <= start_wait_for_flash     ;
				 start_wait_for_flash       : state <= wait_for_wait_for_flash  ; 
				 wait_for_wait_for_flash    : if (wait_counter_finished) state <= latch_result0;
				 latch_result0              : state <= select_result1           ;
				 select_result1             : state <= latch_result1            ;
				 latch_result1              : state <= finished                 ;
				 finished                   : state <= idle;				 				  
 			    endcase
	end
end
programmable_wait
#(
.width(wait_counter_bits)
)
programmable_wait_inst
   ( //Inputs
	.SM_CLK   (clk),
	.RESET_N  (delay_reset_n),
	.START    (start_delay_counter),
	.AMOUNT   (wait_for_flash),
	//Outputs
	 .FINISH  (wait_counter_finished)
);

endmodule
`default_nettype wire
