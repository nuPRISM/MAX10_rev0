module generic_one_stream_averager
#(
   parameter [0:0] USE_ONLY_GLOBAL_CLOCKS = 1'b1,
   parameter num_accumulator_bits = 24,
   parameter clk_count_num_bits   = 16,
   parameter shift_num_bits       = 8,
   parameter num_data_bits        = 8
)
				(	//outputs
				
				DEBUG1,
				DEBUG2,
				DEBUG3,
					//inputs
				
				DECIMATOR_SHIFT,
				DECIMATOR_M,
				FAST_CLK,
				SM_CLK,
				input_metric_clk,
				RESET,
				estimator_clk,
				estimator_output,
				input_metric,
				estimator_output_full
            	);

///////////////////////////////////////////////////////////////////////////
//
//   Inputs and Outputs
//
///////////////////////////////////////////////////////////////////////////

output [31:0]		DEBUG1;
output [31:0]		DEBUG2;
output [31:0]		DEBUG3;

output [num_data_bits-1:0]         estimator_output;
output				              estimator_clk;
input  [shift_num_bits-1:0]	 	DECIMATOR_SHIFT;
input  [clk_count_num_bits-1:0]	DECIMATOR_M;                       
input				     FAST_CLK;
input 			         SM_CLK;
input				     input_metric_clk;
input				     RESET;
input  [num_data_bits-1:0] input_metric;
output [num_accumulator_bits-1:0] estimator_output_full;

wire			div_m_clk_1 /* synthesis syn_keep=1 */;

wire [num_data_bits-1:0] out_data_1;
wire actual_decm1_inclk = !input_metric_clk;
	
wire  [num_data_bits-1:0] actual_dec_filter_m1_indata;
wire  [num_data_bits-1:0] data_to_hg_predec_to_decm1;		

generate 
		if (USE_ONLY_GLOBAL_CLOCKS)
				begin     
					widereg 
                    #(.width(num_data_bits))
 				    predec_to_decm1(
					.indata(input_metric),
					.outdata(actual_dec_filter_m1_indata),
					.inclk(actual_decm1_inclk)
					);
				end
				else  
				begin
					widereg 
					#(.width(num_data_bits))
					predec_to_decm1(.indata(input_metric),
									   .outdata(data_to_hg_predec_to_decm1),
									   .inclk(actual_decm1_inclk)); 
									   
					hold_gen 
                    #(.width(num_data_bits))					
					hold_to_decm1(.indata(data_to_hg_predec_to_decm1),
										.data_clk(actual_decm1_inclk),
										.delaying_clk(FAST_CLK),
										.outdata(actual_dec_filter_m1_indata));
				end
endgenerate

wire [num_accumulator_bits-1:0] unreduced_carrier_lock_val_wire;

mod_IQ_dec_filter_w_1strm_parameterized2 
#(.num_accumulator_bits(num_accumulator_bits),
.clk_count_num_bits(clk_count_num_bits),
.shift_num_bits(shift_num_bits), 
.num_data_bits(num_data_bits))
CEST_decm_1(
				.out_data_Io(),
				.out_data_Ie(out_data_1),
				.out_data_Qo(),
				.out_data_Qe(),
				.out_clk(div_m_clk_1),
				.out_clk_non_global(),
				.in_data_Ie(actual_dec_filter_m1_indata),
				.in_data_Io(0),
				.in_data_Qe(0),
				.in_data_Qo(0),
				.in_clk(actual_decm1_inclk),             
				.clk_count(DECIMATOR_M),
				.Reset(RESET),
				.shift(DECIMATOR_SHIFT),
				.single_strm_clk(),
				.single_strm_I(),
				.single_strm_Q(),
				.out_data_Ie_full(unreduced_carrier_lock_val_wire),
				.out_data_Io_full(),
				.out_data_Qe_full(),
				.out_data_Qo_full(), 
				.single_strm_I_full(), 
				.single_strm_Q_full());


wire estimator_clk = !div_m_clk_1;

widereg 
#(.width(num_data_bits))
decm_to_output(.indata(out_data_1),
					    .outdata(estimator_output),
					    .inclk(estimator_clk));
					    

widereg #(.width(num_accumulator_bits))   
                         decm_to_output_full(.indata(unreduced_carrier_lock_val_wire),
					    .outdata(estimator_output_full),
					    .inclk(estimator_clk));
endmodule



