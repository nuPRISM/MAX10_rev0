
`default_nettype none
`include "interface_defs.v"
`include "global_project_defines.v"
`include "jesd204b_a10_interface.v"

module distribute_jesd_rx_out_to_avst
#(
parameter JESD_S,
parameter JESD_M,
parameter JESD_N,
parameter JESD_N_PRIME,
parameter JESD_TL_DATA_BUS_WIDTH,
parameter NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK,
parameter JESD_NUM_LINKS
)
(
multi_data_stream_interface avst_out_streams_interface_pins,
jesd204b_a10_interface jesd204b_a10_interface_pins
);

assign avst_out_streams_interface_pins.clk = jesd204b_a10_interface_pins.frame_clk;
assign avst_out_streams_interface_pins.valid = 1'b1;
	 
genvar current_link;
genvar current_converter;
genvar current_sample_chunk;
genvar current_sample;
`define current_dac (current_link*JESD_M + current_converter)				   
generate
			for (current_link = 0; current_link < JESD_NUM_LINKS; current_link++)
			begin : go_over_links
			       assign jesd204b_a10_interface_pins.avst_usr_dout_ready[current_link] = 1'b1;
                   for (current_converter = 0; current_converter < JESD_M; current_converter++)
                   begin : go_over_converters	                          
				          for (current_sample_chunk = 0; current_sample_chunk*JESD_S < NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK; current_sample_chunk++)
						  begin : go_over_samples
						        for (current_sample =  0; current_sample < JESD_S ; current_sample++)
								begin : go_over_per_sample
										assign avst_out_streams_interface_pins.data[`current_dac][((current_sample_chunk+1)*JESD_S*JESD_N_PRIME)-1-(current_sample*JESD_N_PRIME) -: JESD_N_PRIME] 
												=  jesd204b_a10_interface_pins.avst_usr_dout[(current_link*JESD_TL_DATA_BUS_WIDTH) + 
												   + ((current_converter+1)*JESD_S*JESD_N)
												   + (current_sample_chunk*JESD_M*JESD_S*JESD_N)
												   -1 - (current_sample*JESD_N) -: JESD_N];
								end   
						  end
				   end				   
			end
endgenerate
`undef current_dac
endmodule

`default_nettype wire
