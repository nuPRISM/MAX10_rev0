`default_nettype none
module simple_averager
#(
   parameter shift_num_bits       = 4,
   parameter num_data_bits        = 8,
   parameter clk_count_num_bits   = (2**shift_num_bits)+1,
   parameter num_accumulator_bits = (2**shift_num_bits) + num_data_bits
)

(				
				DECIMATOR_SHIFT,
				DECIMATOR_M,
				inclk,
				indata,
				reset_n,
				outclk,
				average_outdata,
				accumulator_outdata,
);


input  [shift_num_bits-1:0]	 	  DECIMATOR_SHIFT;
input  [clk_count_num_bits-1:0]	  DECIMATOR_M;                       
input				              inclk;
input  [num_data_bits-1:0]        indata;
input				              reset_n;
output				              outclk;
output logic [num_data_bits-1:0]        average_outdata;
output logic [num_accumulator_bits-1:0] accumulator_outdata;



generic_one_stream_averager
#(
   .USE_ONLY_GLOBAL_CLOCKS(1'b1),
   .num_accumulator_bits (num_accumulator_bits) ,
   .clk_count_num_bits   (clk_count_num_bits  ) ,
   .shift_num_bits       (shift_num_bits      ) ,
   .num_data_bits        (num_data_bits       ) 
)
generic_one_stream_averager_inst
(
                .DECIMATOR_SHIFT(DECIMATOR_SHIFT),
				.DECIMATOR_M(DECIMATOR_M),
				.FAST_CLK(1'b0),
				.SM_CLK(1'b0),
				.input_metric_clk(inclk),
				.RESET(reset_n),
				.estimator_clk(outclk),
				.estimator_output(average_outdata),
				.input_metric(indata),
				.estimator_output_full(accumulator_outdata)
);

endmodule
`default_nettype wire