`default_nettype none
module dft_32_avst_test
#(
parameter NUM_COUNTER_BITS = 16    ,
parameter NUM_FFT_SAMPLES  = 32    ,
parameter NUMBITS_DATA  = 16       ,
parameter ENABLE_KEEPS = 0         ,
parameter NUM_SAMPLES_PER_CLOCK = 4
)
(
input clk,
input reset,
input in_sop,
input in_valid,
output out_sop,
output out_eop,
output out_valid,
input  [NUMBITS_DATA-1:0] real_data_in [NUM_SAMPLES_PER_CLOCK],
input  [NUMBITS_DATA-1:0] imag_data_in [NUM_SAMPLES_PER_CLOCK],
output [NUMBITS_DATA-1:0] real_data_out[NUM_SAMPLES_PER_CLOCK],
output [NUMBITS_DATA-1:0] imag_data_out[NUM_SAMPLES_PER_CLOCK],
output logic [NUM_COUNTER_BITS-1:0] current_sample_count,
output logic [NUM_COUNTER_BITS-1:0] current_input_sample_count,
input  [NUM_COUNTER_BITS-1:0] zero_pad_count_threshold,
output logic debug_next_in,
output logic debug_next_out
);

dft_32_avst
#(
.NUM_COUNTER_BITS     (NUM_COUNTER_BITS     ), 
.NUM_FFT_SAMPLES      (NUM_FFT_SAMPLES      ), 
.NUMBITS_DATA         (NUMBITS_DATA         ),     
.ENABLE_KEEPS         (ENABLE_KEEPS         ),     
.NUM_SAMPLES_PER_CLOCK(NUM_SAMPLES_PER_CLOCK)
)
dft_32_avst_inst
(
.*
);

endmodule
`default_nettype wire
