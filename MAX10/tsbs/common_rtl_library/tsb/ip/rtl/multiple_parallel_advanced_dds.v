module multiple_parallel_advanced_dds
#(
parameter num_phase_bits = 16, 
parameter num_output_bits = 14,
parameter num_parallel_oscillators = 8,
parameter use_explicit_blockram = 1,
parameter add_extra_pipelining = 0
)
(
 input		 clk,
 input		 reset_n,
 input		 clken,
 input	      [num_phase_bits-1:0]	phi_inc_i,
 output logic [num_output_bits-1:0] triangular_waveform_out[num_parallel_oscillators],
 output logic [num_output_bits-1:0] sine_waveform_out[num_parallel_oscillators],
 output logic [num_output_bits-1:0] cosine_waveform_out[num_parallel_oscillators],
 output logic [num_phase_bits-1:0]  phase_accumulator[num_parallel_oscillators],
 output logic [num_output_bits-1:0]  ramp_plus1_accumulator[num_parallel_oscillators],
 output logic [num_output_bits-1:0]  oscillator_id[num_parallel_oscillators]
);

logic [num_phase_bits-1:0]  raw_phase_accumulator = 0;
logic [num_output_bits-1:0] sine_waveform_out_raw[num_parallel_oscillators];
logic [num_output_bits-1:0] cosine_waveform_out_raw[num_parallel_oscillators];
logic [num_output_bits-1:0] raw_ramp_plus1_accumulator;

	always @ (posedge clk)
	begin
	      if (!reset_n)
		  begin
		       raw_phase_accumulator <= 0;
		  end
		  else
		  begin
		       if (clken)
			   begin
			        raw_phase_accumulator <= raw_phase_accumulator + num_parallel_oscillators*phi_inc_i;
			   end
		  end
	end
	
    always_ff @ (posedge clk)
	begin
	      if (!reset_n)
		  begin
		       raw_ramp_plus1_accumulator <= 0;
		  end
		  else
		  begin
		       if (clken)
			   begin
			        raw_ramp_plus1_accumulator <= raw_ramp_plus1_accumulator + num_parallel_oscillators;
			   end
		  end
	end
	

		genvar current_osc;
		generate 
				
				
				
				
						 for (current_osc = 0; current_osc < num_parallel_oscillators; current_osc++)
						 begin : generate_parallel_oscillators
						        logic [num_phase_bits-1:0]  full_scale_triangular_nco_value;
								logic [num_phase_bits-1:0]  principal_theta;
								logic [num_phase_bits-1:0]  intermediate_triangular_nco_values;
								logic [num_phase_bits-1:0]  to_add_to_triangular_nco_theta;
								logic [num_phase_bits-2:0]  temp_triangular_nco_value;
								
								assign oscillator_id[current_osc] = current_osc;
								
								always @ (posedge clk)
								begin
									  if (!reset_n)
									  begin
										   phase_accumulator[current_osc]     <= 0;
									  end
									  else
									  begin
										   if (clken)
										   begin
												phase_accumulator[current_osc] <= raw_phase_accumulator + phi_inc_i*current_osc;
										   end
									  end
								end
								
								always @ (posedge clk)
								begin
									  if (!reset_n)
									  begin
										   ramp_plus1_accumulator[current_osc]     <= 0;
									  end
									  else
									  begin
										   if (clken)
										   begin
												ramp_plus1_accumulator[current_osc] <= raw_ramp_plus1_accumulator + current_osc;
										   end
									  end
								end
								
								//format of principal theta is unsigned s1w1.f(num_phase_bits-1)
								assign principal_theta = {2'b00,phase_accumulator[current_osc][num_phase_bits-3 :  0]};
								
								always_comb
								begin
									 case (phase_accumulator[current_osc][num_phase_bits-1 -: 2])
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
												intermediate_triangular_nco_values <= ~({{num_phase_bits{~(phase_accumulator[current_osc][num_phase_bits-1]^phase_accumulator[current_osc][num_phase_bits-2])}} ^ principal_theta} + to_add_to_triangular_nco_theta);
										end
								end else
								begin
							           assign intermediate_triangular_nco_values = ~({{num_phase_bits{~(phase_accumulator[current_osc][num_phase_bits-1]^phase_accumulator[current_osc][num_phase_bits-2])}} ^ principal_theta} + to_add_to_triangular_nco_theta);
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
				                 triangular_waveform_out[current_osc] <= full_scale_triangular_nco_value[$size(full_scale_triangular_nco_value)-1 -: num_output_bits];
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
										  .a(phase_accumulator[current_osc]),
										  .o_cos(cosine_waveform_out_raw[current_osc]), 
										  .o_sin(sine_waveform_out_raw[current_osc])
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
										  .a(phase_accumulator[current_osc]),
										  .o_cos(cosine_waveform_out_raw[current_osc]), 
										  .o_sin(sine_waveform_out_raw[current_osc])
										);
							end
							
							always @(posedge clk)
							begin
				                     sine_waveform_out[current_osc] <= sine_waveform_out_raw[current_osc];
				                     cosine_waveform_out[current_osc] <= cosine_waveform_out_raw[current_osc];
				            end

				   end 
		endgenerate
endmodule
