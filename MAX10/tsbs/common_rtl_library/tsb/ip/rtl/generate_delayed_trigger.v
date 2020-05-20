
module generate_delayed_trigger 
#(
parameter numbits_counter = 32,
parameter synchronizer_depth = 3
)
(
input trigger_pulse_async_in,
output trigger_pulse_sync_out,
input clk,
input [numbits_counter-1:0] delay
);

async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth))
async_trap_reset_external_trigger
(
.async_sig(trigger_pulse_async_in), 
.outclk(clk), 
.out_sync_sig(external_trigger_pulse), 
.auto_reset(1'b1), 
.reset(1'b1)
);
		

generate_delayed_pulse_variable_count
#(
.initial_count           (0),
.num_bits_counter        (numbits_counter ),
.pulse_out_initial_value (0  )
)
generate_delayed_external_trigger
(
.default_count                 (2),
.initial_pulse_delay           (delay),
.async_reset                   (external_trigger_pulse         ),
.pulse_out                     (trigger_pulse_sync_out),
.clk(clk)
);
	
endmodule