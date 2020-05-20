module async_trap_and_reset_gen_1_pulse (
async_sig, 
outclk, 
out_sync_sig, 
auto_reset, 
reset);
/* this module traps an asyncronous signal async_sig and syncronizes it via 2 flip-flops to outclk. The resulting
   signal is named out_sync_sig. auto_reset tells the module whether to do an auto-reset of out_sync_sig after 2 clocks.
   reset is an asynchronous reset signal. The reset signal is active LOW. */


input async_sig, outclk, auto_reset, reset;
output out_sync_sig;

(* keep = 1, preserve = 1 *) reg async_trap=0;
(* keep = 1, preserve = 1 *) reg sync1, sync2;

reg actual_auto_reset_signal;


wire actual_async_sig_reset;

wire auto_reset_signal =  auto_reset && sync2;

assign actual_async_sig_reset = actual_auto_reset_signal || (!reset);


assign out_sync_sig = sync2;

always @ (posedge async_sig or posedge actual_async_sig_reset)
begin
	 if (actual_async_sig_reset)
	 	async_trap <= 1'b0;
	 else
	 	async_trap <= 1'b1;
end

always @ (posedge outclk or negedge reset)
begin
	 if (~reset)
	 begin
		  sync2 <= 1'b0;
	 end else
	 begin
		  sync2 <= auto_reset ? sync1 & !(sync2) : sync1;
	 end
end


always @ (posedge outclk or posedge actual_auto_reset_signal)
begin
	 if (actual_auto_reset_signal)
	 begin
	 	  sync1 <= 1'b0;
	 end else
	 begin
	 	  sync1 <= async_trap;
	 end
end


always @ (negedge outclk or negedge reset)
begin
	if (~reset)
		 actual_auto_reset_signal <= 1'b0;
	else
		 actual_auto_reset_signal <= auto_reset_signal;
end

endmodule

