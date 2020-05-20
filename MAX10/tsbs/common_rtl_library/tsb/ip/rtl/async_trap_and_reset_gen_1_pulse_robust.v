`default_nettype none
module async_trap_and_reset_gen_1_pulse_robust (
async_sig, 
outclk, 
out_sync_sig, 
auto_reset, 
unregistered_out_sync_sig,
reset);

parameter synchronizer_depth = 2;
/* this module traps an asyncronous signal async_sig and syncronizes it via 2 flip-flops to outclk. The resulting
   signal is named out_sync_sig. auto_reset tells the module whether to do an auto-reset of out_sync_sig after 2 clocks.
   reset is an asynchronous reset signal. The reset signal is active LOW. */


input async_sig, outclk, auto_reset, reset;
output out_sync_sig;
output unregistered_out_sync_sig;

(* keep = 1, preserve = 1 *) reg async_trap=0;
(* keep = 1, preserve = 1 *) wire async_sig_keeper;
(* keep = 1, preserve = 1 *) wire sync1;
(* keep = 1, preserve = 1 *) reg  sync2=0;

reg actual_auto_reset_signal;

wire unregistered_out_ce;

wire actual_async_sig_reset;

wire auto_reset_signal =  auto_reset && sync2;

assign actual_async_sig_reset = actual_auto_reset_signal || (!reset);


assign out_sync_sig = sync2;


assign async_sig_keeper = async_sig;

`ifdef USE_CLOCK_KEEPER_IN_ASYNC_TRAP_AND_RESET
always @ (posedge async_sig_keeper or posedge actual_async_sig_reset)
`else
always @ (posedge async_sig or posedge actual_async_sig_reset)
`endif
begin
	 if (actual_async_sig_reset)
	 	async_trap <= 1'b0;
	 else
	 	async_trap <= 1'b1;
end

assign unregistered_out_sync_sig = auto_reset ? sync1 & !(sync2) : sync1;

always @ (posedge outclk or negedge reset)
begin
	 if (~reset)
	 begin
		  sync2 <= 1'b0;
	 end else
	 begin
		  sync2 <= unregistered_out_sync_sig;
	 end
end


`ifdef SOFTWARE_IS_QUARTUS

      my_altera_std_synchronizer_nocut
      the_altera_std_synchronizer    (
                                .clk(outclk), 
                                .reset_n(!actual_async_sig_reset), 
                                .din(async_trap), 
                                .dout(sync1)
                                );
								
		defparam the_altera_std_synchronizer.depth = synchronizer_depth;

`else
						//special coding for SRL16 inference in Xilinx devices
						reg [synchronizer_depth-1:0] sync_srl16_inferred;
						always @(posedge outclk or posedge actual_async_sig_reset)
						begin
								if (actual_async_sig_reset)
								begin
									  sync_srl16_inferred[synchronizer_depth-1:0]<= 0;
								end
								else
								begin
									  sync_srl16_inferred[synchronizer_depth-1:0] <= {sync_srl16_inferred[synchronizer_depth-2:0], async_trap};
								end
						end
						
						assign sync1 = sync_srl16_inferred[synchronizer_depth-1];
										
`endif

always @ (negedge outclk or negedge reset)
begin
	if (~reset)
		 actual_auto_reset_signal <= 1'b0;
	else
		 actual_auto_reset_signal <= auto_reset_signal;
end

endmodule
`default_nettype wire
