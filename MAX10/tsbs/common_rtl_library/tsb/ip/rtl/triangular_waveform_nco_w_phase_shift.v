module triangular_waveform_nco_w_phase_shift 
#(parameter num_phase_bits = 6, 
  parameter num_output_bits = 4,
  parameter [num_phase_bits-1:0] initial_phase = 0)
(
	input	    [num_phase_bits-1:0]	phi_inc_i,
	input		 clk,
	input		 reset_n,
	input		 clken,
	input        [num_phase_bits-1:0] phase_shift,
	output logic [num_output_bits-1:0] triangular_waveform_out,
	output logic [num_phase_bits-1:0]  phase_accumulator     = 0,
	output logic [num_phase_bits-1:0]  raw_phase_accumulator = 0,
	output logic [num_phase_bits-1:0]  full_scale_triangular_nco_value,
	output logic [num_phase_bits-1:0]  principal_theta,
    output logic [num_phase_bits-1:0]  intermediate_triangular_nco_values,
    output logic [num_phase_bits-1:0]  to_add_to_triangular_nco_theta,
    output logic [num_phase_bits-2:0]  temp_triangular_nco_value
);
	
	always @ (posedge clk)
	begin
	      if (!reset_n)
		  begin
		       raw_phase_accumulator <= initial_phase;
		       phase_accumulator     <= initial_phase;
		  end
		  else
		  begin
		       if (clken)
			   begin
			        raw_phase_accumulator <= raw_phase_accumulator + phi_inc_i;
			        phase_accumulator <= raw_phase_accumulator + phase_shift;
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
				
assign intermediate_triangular_nco_values = ~({{num_phase_bits{~(phase_accumulator[num_phase_bits-1]^phase_accumulator[num_phase_bits-2])}} ^ principal_theta} + to_add_to_triangular_nco_theta);

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

assign triangular_waveform_out = full_scale_triangular_nco_value[$size(full_scale_triangular_nco_value)-1 -: num_output_bits];


endmodule
