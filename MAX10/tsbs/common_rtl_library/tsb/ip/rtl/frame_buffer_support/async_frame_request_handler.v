`default_nettype none
module async_frame_request_handler   	
(
input logic driver_clk,
input logic frame_request_from_driver,

input logic frame_buffer_clk,
output logic frame_request_to_frame_buffer,
input logic reset_frame_request_from_frame_buffer

);	

parameter synchronizer_depth = 2;

logic reset_frame_request_from_frame_buffer_synced_to_driver_clk;
logic frame_request_to_frame_buffer_synced_to_driver_clk;
	frame_request_handler
    frame_request_handler_inst
    (
	.clk(driver_clk),
  	.frame_request(frame_request_to_frame_buffer_synced_to_driver_clk),
	.reset_frame_request(reset_frame_request_from_frame_buffer_synced_to_driver_clk),
	.request_frame_now(frame_request_from_driver)
	);
				

	 async_trap_and_reset_gen_1_pulse_robust
	 #(.synchronizer_depth(synchronizer_depth))	 
	 async_trap_reset_frame_request_from_frame_buffer
	 (
	 .async_sig(reset_frame_request_from_frame_buffer), 
	 .outclk(driver_clk), 
	 .out_sync_sig(reset_frame_request_from_frame_buffer_synced_to_driver_clk), 
	 .auto_reset(1'b1), 
	 .reset(1'b1)
	 );
			
						
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_frame_request_to_frame_buffer
	(
	 .indata (frame_request_to_frame_buffer_synced_to_driver_clk),
	 .outdata(frame_request_to_frame_buffer),
	 .clk    (frame_buffer_clk)
	 );
endmodule
`default_nettype wire