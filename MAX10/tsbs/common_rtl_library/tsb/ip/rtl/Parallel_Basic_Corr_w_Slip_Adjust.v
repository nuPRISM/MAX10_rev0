
module Parallel_Basic_Corr_w_Slip_Adjust
#(
  parameter input_width = 10,
  parameter number_of_inwidths_in_corr_length = 6,
  parameter corr_reg_length = number_of_inwidths_in_corr_length*input_width, 
  parameter phase_corr_reg_length = input_width*(number_of_inwidths_in_corr_length-1),
  parameter corr_count_bits = 8
)
(
 indata_clk, 
 ref_data_clk, 
 output_reg_clk, 
 input_seq_bit_in, 
 ref_seq_in, 
 current_corr, 
 ref_bits_reg, 
 input_bits_reg, 
 current_corr_in_bit_by_bit_phases,
 reset
);    

input indata_clk;
input ref_data_clk;
input output_reg_clk;
input [input_width-1:0] input_seq_bit_in;
input [input_width-1:0] ref_seq_in;
output reg [corr_count_bits*(input_width+1)-1:0] current_corr = 0 /* synthesis preserve */;
input reset;

output reg [corr_reg_length-1:0] input_bits_reg = 0, ref_bits_reg = 0;

output reg [phase_corr_reg_length-1:0] current_corr_in_bit_by_bit_phases[input_width-1:0];

always @ (posedge indata_clk)
begin
      input_bits_reg <= {input_bits_reg[corr_reg_length-input_width-1:0],input_seq_bit_in[input_width-1:0]};
end

always @ (posedge ref_data_clk)
begin
      ref_bits_reg <= {ref_bits_reg[corr_reg_length-input_width-1:0],ref_seq_in[input_width-1:0]};
end

wire current_corr_clk;

assign current_corr_clk = output_reg_clk; 

generate
        genvar i;
		for (i=0; i< input_width; i++)
		begin : generate_correlation_phases
			  always @*
              begin
                   current_corr_in_bit_by_bit_phases[i] =  
				                  ~(input_bits_reg[phase_corr_reg_length+i-1 : i] 
				                    ^ ref_bits_reg[phase_corr_reg_length-1 : 0]);
              end
		end
endgenerate

integer corr_bit_count;
integer num_of_corr_bits;
integer phase_num;
	    
always @ (posedge current_corr_clk)
begin
      for (phase_num =0; phase_num < input_width; phase_num++)
	  begin : phase_num_current_corr_compute
	       num_of_corr_bits = 0;
           for (corr_bit_count=0; corr_bit_count < phase_corr_reg_length; corr_bit_count=corr_bit_count+1) 
		   begin : compute_num_corr_bits
               num_of_corr_bits = num_of_corr_bits + current_corr_in_bit_by_bit_phases[phase_num][corr_bit_count];	  
		   end
		   current_corr[(phase_num+1)*corr_count_bits-1 -: corr_count_bits] <= num_of_corr_bits;	
	end	   
end

endmodule
