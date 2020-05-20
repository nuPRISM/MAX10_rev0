`default_nettype none
module `SPIRAL_FFT_ENCAPSULATING_MODULE_NAME
#(
parameter NUM_COUNTER_BITS = 16    ,
parameter NUM_FFT_SAMPLES          ,
parameter NUMBITS_DATA             ,
parameter ENABLE_KEEPS = 0         ,
parameter NUM_SAMPLES_PER_CLOCK = 4
)
(
//assumption is always valid in
input clk,
input reset,
input in_sop,
input in_valid, //assumes continuous valid from sop to eop, inclusive
output out_sop,
output out_eop,
output out_valid,
input  [NUMBITS_DATA-1:0] real_data_in [NUM_SAMPLES_PER_CLOCK],
input  [NUMBITS_DATA-1:0] imag_data_in [NUM_SAMPLES_PER_CLOCK],
output [NUMBITS_DATA-1:0] real_data_out[NUM_SAMPLES_PER_CLOCK],
output [NUMBITS_DATA-1:0] imag_data_out[NUM_SAMPLES_PER_CLOCK],
output reg [NUM_COUNTER_BITS-1:0] current_sample_count,
output logic debug_next_in,
output logic debug_next_out
);

logic next_in;
logic next_out;
logic out_sop_raw;
logic out_eop_raw;
logic out_valid_raw;


assign debug_next_in  = next_in;
assign debug_next_out = next_out;

logic [NUMBITS_DATA-1:0] delayed_real_data_in [NUM_SAMPLES_PER_CLOCK];
logic [NUMBITS_DATA-1:0] delayed_imag_data_in [NUM_SAMPLES_PER_CLOCK];
logic [NUMBITS_DATA-1:0] raw_real_data_out[NUM_SAMPLES_PER_CLOCK];
logic [NUMBITS_DATA-1:0] raw_imag_data_out[NUM_SAMPLES_PER_CLOCK];
		
always_ff @(posedge clk)
begin
        delayed_real_data_in   <= real_data_in;
        delayed_imag_data_in   <= imag_data_in;
        real_data_out          <= raw_real_data_out;
        imag_data_out          <= raw_imag_data_out;
		next_in <= (in_sop & in_valid);
		out_sop_raw  <= next_out;
		out_eop_raw  <= (current_sample_count == (NUM_FFT_SAMPLES-(2*NUM_SAMPLES_PER_CLOCK)+1));
		out_valid_raw <= (next_out || ((current_sample_count > 0) && ((current_sample_count <= (NUM_FFT_SAMPLES - NUM_SAMPLES_PER_CLOCK)))));
		out_sop   <= out_sop_raw;
        out_eop   <= out_eop_raw;
        out_valid <= out_valid_raw;		
end
	
always_ff @(posedge clk)
begin
      if (reset)
	  begin
	        current_sample_count <= 0;
	  end else
	  begin	       
		  if (next_out)
		  begin
		        current_sample_count <= 1;
		  end else
		  begin
		       if ((current_sample_count < NUM_FFT_SAMPLES) && (current_sample_count > 0))
			   begin
			         current_sample_count <= current_sample_count + NUM_SAMPLES_PER_CLOCK;
			   end else
			   begin
			         current_sample_count <= 0;
			   end
		  end        
      end
end
				  
`SPIRAL_FFT_DFT_INTERNAL_MODULE_NAME
internal_qsys_dft
   (
   .clk_clk             (clk),              //        clk.clk
   .fft_reset_reset     (reset),     //  fft_reset.reset
   .spiral_fft_next     (next_in),                   
   .spiral_fft_next_out (next_out),                  
   .spiral_fft_x0       (delayed_real_data_in[0]),   
   .spiral_fft_y0       (raw_real_data_out[0]),      
   .spiral_fft_x1       (delayed_imag_data_in[0]),   
   .spiral_fft_y1       (raw_imag_data_out[0]),      
   .spiral_fft_x2       (delayed_real_data_in[1]),   
   .spiral_fft_y2       (raw_real_data_out[1]),      
   .spiral_fft_x3       (delayed_imag_data_in[1]),   
   .spiral_fft_y3       (raw_imag_data_out[1]),      
   .spiral_fft_x4       (delayed_real_data_in[2]),   
   .spiral_fft_y4       (raw_real_data_out[2]),      
   .spiral_fft_x5       (delayed_imag_data_in[2]),   
   .spiral_fft_y5       (raw_imag_data_out[2]),      
   .spiral_fft_x6       (delayed_real_data_in[3]),   
   .spiral_fft_y6       (raw_real_data_out[3]),      
   .spiral_fft_x7       (delayed_imag_data_in[3]),   
   .spiral_fft_y7       (raw_imag_data_out[3])      
);
   
endmodule
`default_nettype wire