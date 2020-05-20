`default_nettype none
module async_event_request_handler   	
(
input  logic driver_clk,
input  logic event_request_from_driver,
output logic event_request_to_event_buffer_synced_to_driver_clk,
output logic reset_event_request_from_event_buffer_synced_to_driver_clk,

input logic event_buffer_clk,
output logic event_request_to_event_buffer,
input logic reset_event_request_from_event_buffer

);	

parameter synchronizer_depth = 2;

	event_request_handler
    event_request_handler_inst
    (
	.clk(driver_clk),
  	.event_request(event_request_to_event_buffer_synced_to_driver_clk),
	.reset_event_request(reset_event_request_from_event_buffer_synced_to_driver_clk),
	.request_event_now(event_request_from_driver)
	);
				

	 async_trap_and_reset_gen_1_pulse_robust 
	  #(.synchronizer_depth(synchronizer_depth))
	 async_trap_reset_event_request_from_event_buffer
	 (
	 .async_sig(reset_event_request_from_event_buffer), 
	 .outclk(driver_clk), 
	 .out_sync_sig(reset_event_request_from_event_buffer_synced_to_driver_clk), 
	 .auto_reset(1'b1), 
	 .reset(1'b1)
	 );
			
						
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_event_request_to_event_buffer
	(
	 .indata (event_request_to_event_buffer_synced_to_driver_clk),
	 .outdata(event_request_to_event_buffer),
	 .clk    (event_buffer_clk)
	 );
endmodule
`default_nettype wire