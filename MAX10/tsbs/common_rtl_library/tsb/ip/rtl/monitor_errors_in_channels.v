module monitor_errors_in_channels
#(
parameter num_counter_bits = 4,
parameter num_channels = 4,
parameter [num_counter_bits-1:0] saturation_limit={1'b0,{(num_counter_bits-1){1'b1}}}
)
(
input clk,
input [num_channels-1:0] channel_error_signals,
output [num_counter_bits-1:0] saturated_sum,
input [num_channels-1:0] enabled_channels,
input count_enable,
input clear_counter,
output actual_monitored_signal
);

assign actual_monitored_signal = |(channel_error_signals & enabled_channels);

saturating_counter 
#(
.num_counter_bits(num_counter_bits),
.saturation_limit(saturation_limit)
)
saturating_counter_inst 
(
.clk(clk),
.monitored_signal(actual_monitored_signal),
.saturated_sum(saturated_sum),
.count_enable(count_enable),
.clear_counter(clear_counter)
);

endmodule
