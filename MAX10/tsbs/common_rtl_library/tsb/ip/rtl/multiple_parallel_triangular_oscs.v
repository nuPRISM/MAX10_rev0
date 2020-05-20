module multiple_parallel_triangular_oscs
#(
parameter num_phase_bits = 8, 
parameter num_output_bits = 6,
parameter num_parallel_oscillators = 8
)
(
 input		 clk,
 input		 reset_n,
 input		 clken,
 input	      [num_phase_bits-1:0]	phi_inc_i,
 output logic [num_output_bits-1:0] triangular_waveform_out[num_parallel_oscillators],
 output logic [num_phase_bits-1:0]  phase_accumulator[num_parallel_oscillators]
);

		genvar current_osc;
				generate 
						 for (current_osc = 0; current_osc < num_parallel_oscillators; current_osc++)
						 begin : generate_parallel_oscillators
						 
						triangular_waveform_nco_w_phase_shift 
						#(
						  .num_phase_bits(num_phase_bits), 
						  .num_output_bits(num_output_bits),
						  .initial_phase(0)
						  )
						triangular_waveform_nco_w_phase_shift_inst
						(
							.phi_inc_i(num_parallel_oscillators*phi_inc_i),
							.phase_shift(phi_inc_i*(current_osc-1)),
							.clk(clk),
							.reset_n(reset_n),
							.clken(clken),
							.triangular_waveform_out(triangular_waveform_out[current_osc]),
							.phase_accumulator(phase_accumulator[current_osc])
						);
				end 
		endgenerate
endmodule
