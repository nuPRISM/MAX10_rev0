`default_nettype none
module multi_channel_2x_generic_parallelizer
#(
parameter NUMBITS_DATAIN_FULL_WIDTH = 14,
parameter NUM_DATA_CHANNELS = 2,
parameter GENERATE_FRAME_CLOCK_ON_NEGEDGE = 1 
)
(
   input [NUM_DATA_CHANNELS-1:0] choose_output_frame_simulation_data,
   input [NUM_DATA_CHANNELS-1:0] choose_input_frame_simulation_data,
   input [NUMBITS_DATAIN_FULL_WIDTH/2-1:0] half_frame_data_in[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]   outdata[NUM_DATA_CHANNELS],
   input [NUMBITS_DATAIN_FULL_WIDTH/2-1:0] simulated_input_half_frame_data_in[NUM_DATA_CHANNELS],
   input [NUMBITS_DATAIN_FULL_WIDTH-1:0] simulated_output_full_frame_data[NUM_DATA_CHANNELS],
   input half_frame_clk,
   output logic frame_clk,
   input transpose_frame_rx_out_bits,
   input transpose_frame_halves,
   input xpose_frame_filling_direction,
   input BitReverseOutput,
   output logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0]     raw_frame_data[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH/2-1:0]     possibly_transposed_raw_frame_data[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       frame_data_2X_bit[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       actual_frame_data_2X_bit[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       reconstituted_frame_samples[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       transposed_reconstituted_frame_samples[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       possibly_transposed_frame_data_2X_bit[NUM_DATA_CHANNELS],
   output logic [NUMBITS_DATAIN_FULL_WIDTH-1:0]       outdata_raw[NUM_DATA_CHANNELS]
);	

generate
 if (GENERATE_FRAME_CLOCK_ON_NEGEDGE)
 begin
		always @(negedge half_frame_clk)
		begin
			 frame_clk <= ~frame_clk;
		end
  end else
  begin
        always @(posedge half_frame_clk)
		begin
			 frame_clk <= ~frame_clk;
		end
  end
endgenerate

			genvar adc_channel_index;
			generate				
					for (adc_channel_index = 0; adc_channel_index < NUM_DATA_CHANNELS; adc_channel_index = adc_channel_index +1)
					begin : rx_out_to_status_reg
						   
							 
							  always @(posedge half_frame_clk)
							  begin
								 raw_frame_data[adc_channel_index] <= choose_input_frame_simulation_data[adc_channel_index] ?  simulated_input_half_frame_data_in[adc_channel_index] : half_frame_data_in[adc_channel_index];
							  end
							 
							 
							 always @(posedge half_frame_clk)
							 begin
								 for (int i = 0; i < NUMBITS_DATAIN_FULL_WIDTH/2; i++)
								 begin
									   if (transpose_frame_rx_out_bits)
									   begin
											 possibly_transposed_raw_frame_data[adc_channel_index][i] <= raw_frame_data[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH/2-1-i];
									   end else
									   begin 
											 possibly_transposed_raw_frame_data[adc_channel_index][i] <= raw_frame_data[adc_channel_index][i];
									   end			   
								 end
							end

							always @(posedge half_frame_clk)
							begin
								 if (xpose_frame_filling_direction)
								 begin
									  frame_data_2X_bit[adc_channel_index] <= {possibly_transposed_raw_frame_data[adc_channel_index],frame_data_2X_bit[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH-1 -: NUMBITS_DATAIN_FULL_WIDTH/2]};				 
								 end else
								 begin
									  frame_data_2X_bit[adc_channel_index] <= {frame_data_2X_bit[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH/2-1:0],possibly_transposed_raw_frame_data[adc_channel_index]};
								 end
							end

							
							always @(posedge frame_clk)
							begin
								   actual_frame_data_2X_bit[adc_channel_index] <= frame_data_2X_bit[adc_channel_index];
							end
							
							assign reconstituted_frame_samples[adc_channel_index] = {actual_frame_data_2X_bit[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH-1:NUMBITS_DATAIN_FULL_WIDTH/2],actual_frame_data_2X_bit[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH/2-1:0]};
  						    assign transposed_reconstituted_frame_samples[adc_channel_index] = {actual_frame_data_2X_bit[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH/2-1:0],actual_frame_data_2X_bit[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH-1:NUMBITS_DATAIN_FULL_WIDTH/2]};

							always @(posedge frame_clk)
							begin
								 if (transpose_frame_halves)
								 begin
									  possibly_transposed_frame_data_2X_bit[adc_channel_index] <= transposed_reconstituted_frame_samples[adc_channel_index];
								 end else
								 begin
									  possibly_transposed_frame_data_2X_bit[adc_channel_index] <= reconstituted_frame_samples[adc_channel_index];
								 end
							end 

							assign outdata_raw[adc_channel_index] = choose_output_frame_simulation_data[adc_channel_index] ? simulated_output_full_frame_data[adc_channel_index] : possibly_transposed_frame_data_2X_bit[adc_channel_index];

							always @(posedge frame_clk)
							begin
								  if (BitReverseOutput)
								  begin
									   for (int i = 0; i < NUMBITS_DATAIN_FULL_WIDTH; i++)
									   begin
											outdata[adc_channel_index][i] <= outdata_raw[adc_channel_index][NUMBITS_DATAIN_FULL_WIDTH-1-i];
									   end						   
								  end else
								  begin
									 outdata[adc_channel_index] <= outdata_raw[adc_channel_index];
								  end
							end										
					   end

					   
			endgenerate	
endmodule
`default_nettype wire