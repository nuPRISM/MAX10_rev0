`default_nettype none
module test_generate_controlled_length_pulse_variable_count_ver2
#(
parameter initial_count = 0,
parameter num_bits_counter = 16,
parameter pulse_out_initial_value = 0,
parameter synchronizer_depth = 3,
parameter USE_ASYNC_TRAP_AND_RESET_FOR_ASYNC_RESET = 1
)
(
input async_reset,
output pulse_out,
input logic [num_bits_counter-1:0] default_count,
input clk
);

generate_controlled_length_pulse_variable_count_ver2
#(
.initial_count                           (initial_count                           ),
.num_bits_counter                        (num_bits_counter                        ),
.pulse_out_initial_value                 (pulse_out_initial_value                 ),
.synchronizer_depth                      (synchronizer_depth                      ),
.USE_ASYNC_TRAP_AND_RESET_FOR_ASYNC_RESET(USE_ASYNC_TRAP_AND_RESET_FOR_ASYNC_RESET)
)
generate_controlled_length_pulse_variable_count_ver2_inst
(
.*
);

endmodule
`default_nettype wire