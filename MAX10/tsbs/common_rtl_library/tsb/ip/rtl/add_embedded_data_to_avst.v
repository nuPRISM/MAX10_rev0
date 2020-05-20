
`default_nettype none
`include "interface_defs.v"
`include "global_project_defines.v"
`include "embedded_2_bit_serial_data_interface.v"

module add_embedded_data_to_avst
#(
parameter NUM_STREAMS,
parameter JESD_S,
parameter JESD_M,
parameter JESD_N,
parameter JESD_N_PRIME,
parameter JESD_TL_DATA_BUS_WIDTH,
parameter NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK,
parameter JESD_NUM_LINKS
)
(
multi_data_stream_interface avst_in_streams_interface_pins,
embedded_2_bit_serial_data_interface embedded_2_bit_serial_data_interface_pins,
multi_data_stream_interface avst_out_streams_interface_pins,
input do_serial_embedding,
input embed_input_as_msb
);

assign avst_out_streams_interface_pins.clk = avst_in_streams_interface_pins.clk;
assign avst_out_streams_interface_pins.valid = avst_in_streams_interface_pins.valid;
	 
genvar current_link;
genvar current_converter;
genvar current_sample;
`define current_dac (current_link*JESD_M + current_converter)				   
generate
			for (current_link = 0; current_link < JESD_NUM_LINKS; current_link++)
			begin : go_over_links
                   for (current_converter = 0; current_converter < JESD_M; current_converter++)
                   begin : go_over_converters
                          for (current_sample = 0; current_sample < NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK; current_sample++)
						        begin : go_over_samples						       
										  assign avst_out_streams_interface_pins.data[`current_dac][(current_sample+1)*JESD_N_PRIME-1 -: JESD_N_PRIME] 
											=  do_serial_embedding ?  
											( embed_input_as_msb ? 
											  { 
												  embedded_2_bit_serial_data_interface_pins.serial_sop[`current_dac][current_sample],
												  embedded_2_bit_serial_data_interface_pins.serial_data[`current_dac][current_sample],
												  avst_in_streams_interface_pins.data[`current_dac][((current_sample*JESD_N_PRIME) + JESD_N - 1) : (current_sample*JESD_N_PRIME)] 
											  }
											  :
											  { 
												avst_in_streams_interface_pins.data[`current_dac][((current_sample*JESD_N_PRIME) + JESD_N - 1) : (current_sample*JESD_N_PRIME)],
												embedded_2_bit_serial_data_interface_pins.serial_data[`current_dac][current_sample],
												embedded_2_bit_serial_data_interface_pins.serial_sop[`current_dac][current_sample]
											   }
											)  
											: ((JESD_N_PRIME == JESD_N) ? avst_in_streams_interface_pins.data[`current_dac][((current_sample*JESD_N_PRIME) + JESD_N - 1) : (current_sample*JESD_N_PRIME)]
											   : {avst_in_streams_interface_pins.data[`current_dac][((current_sample*JESD_N_PRIME) + JESD_N - 1) : (current_sample*JESD_N_PRIME)],{(JESD_N_PRIME-JESD_N){1'b0}}});
								  end
						  end
				   end				   
endgenerate
`undef current_dac
endmodule

`default_nettype wire
