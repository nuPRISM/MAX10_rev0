`default_nettype none
module advanced_dds
#(
parameter num_phase_bits = 16, 
parameter num_output_bits = 14,
parameter num_sample_count_bits = 32,
parameter use_explicit_blockram = 1,
parameter add_extra_pipelining = 1,
parameter initial_phase_value = 5
)
(
 input		 clk,
 input		 reset_n,
 input		 clken,
 input	      [num_phase_bits-1:0]	phi_inc_i,
 output logic [num_output_bits-1:0] sine_waveform_out,
 output logic [num_output_bits-1:0] cosine_waveform_out,
 output logic [num_output_bits-1:0] triangular_waveform_out,
 output reg   [num_phase_bits-1:0]  phase_accumulator = initial_phase_value,
 output reg   [num_sample_count_bits-1:0]  sample_since_reset_count = 0

 );

logic [num_output_bits-1:0] sine_waveform_out_raw;
logic [num_output_bits-1:0] cosine_waveform_out_raw;
	
				generate
				        logic [num_phase_bits-1:0]  full_scale_triangular_nco_value;
								logic [num_phase_bits-1:0]  principal_theta;
								logic [num_phase_bits-1:0]  intermediate_triangular_nco_values;
								logic [num_phase_bits-1:0]  to_add_to_triangular_nco_theta;
								logic [num_phase_bits-2:0]  temp_triangular_nco_value;
															
								always @ (posedge clk)
								begin
									  if (!reset_n)
									  begin
										   phase_accumulator     <= initial_phase_value;
										   sample_since_reset_count <= 0;
									  end
									  else
									  begin
										   if (clken)
										   begin
										        sample_since_reset_count <= sample_since_reset_count + 1;
												phase_accumulator <= phase_accumulator + phi_inc_i;
										   end
									  end
								end
								
								
								//format of principal theta is unsigned s1w1.f(num_phase_bits-1)
								assign principal_theta = {2'b00,phase_accumulator[num_phase_bits-3 :  0]};
								
								always_comb
								begin
									 case (phase_accumulator[num_phase_bits-1 -: 2])
									 2'b00 : to_add_to_triangular_nco_theta = 0;
									 2'b01 : to_add_to_triangular_nco_theta = {2'b10,{(num_phase_bits-3){1'b1}},1'b0}; //-1
									 2'b10 : to_add_to_triangular_nco_theta = 0;
									 2'b11 : to_add_to_triangular_nco_theta = {2'b01,{(num_phase_bits-2){1'b0}}}; //=1
									 endcase
								end
								
								if (add_extra_pipelining)
								begin
										always @ (posedge clk)
										begin
												intermediate_triangular_nco_values <= ~({{num_phase_bits{~(phase_accumulator[num_phase_bits-1]^phase_accumulator[num_phase_bits-2])}} ^ principal_theta} + to_add_to_triangular_nco_theta);
										end
								end else
								begin
							           assign intermediate_triangular_nco_values = ~({{num_phase_bits{~(phase_accumulator[num_phase_bits-1]^phase_accumulator[num_phase_bits-2])}} ^ principal_theta} + to_add_to_triangular_nco_theta);
								end		  

							safely_discard_upper_sign_bits
							#(
							.inwidth(num_phase_bits),
							.number_of_bits_to_discard(1),
							.outwidth(num_phase_bits-1)
							)
							safely_discard_upper_sign_bits_triangular_nco
							(
							  .indata(intermediate_triangular_nco_values),
							  .outdata(temp_triangular_nco_value)
							);

							assign full_scale_triangular_nco_value = {temp_triangular_nco_value,1'b1};

							always @(posedge clk)
							begin
				                 triangular_waveform_out <= full_scale_triangular_nco_value[$size(full_scale_triangular_nco_value)-1 -: num_output_bits];
                            end
                            
							if (use_explicit_blockram)
							begin
							           sincos_w_block_ram_megacore
										#(
										  .NBA(num_phase_bits),
										  .NBD(num_output_bits)
										)
										sincos_inst
										(
										  .c(clk),
										  .a(phase_accumulator),
										  .o_cos(cosine_waveform_out_raw), 
										  .o_sin(sine_waveform_out_raw)
										);
							
							end
							else
							begin
										sincos
										#(
										  .NBA(num_phase_bits),
										  .NBD(num_output_bits)
										)
										sincos_inst
										(
										  .c(clk),
										  .a(phase_accumulator),
										  .o_cos(cosine_waveform_out_raw), 
										  .o_sin(sine_waveform_out_raw)
										);
							end
							
							always @(posedge clk)
							begin
				                     sine_waveform_out <= sine_waveform_out_raw;
				                     cosine_waveform_out <= cosine_waveform_out_raw;
				            end
		      endgenerate

endmodule
`default_nettype wire
