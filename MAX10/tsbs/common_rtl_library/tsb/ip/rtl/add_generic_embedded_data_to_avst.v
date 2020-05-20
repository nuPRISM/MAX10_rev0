
`default_nettype none
`include "interface_defs.v"
`include "global_project_defines.v"
`include "embedded_2_bit_serial_data_interface.v"

module add_generic_embedded_data_to_avst
#(
parameter NUM_STREAMS,
parameter N,
parameter N_PRIME,
parameter NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK,
parameter SUPPORT_PACKETS
)
(
interface avst_in_streams_interface_pins,
embedded_2_bit_serial_data_interface embedded_2_bit_serial_data_interface_pins,
interface avst_out_streams_interface_pins,
input do_serial_embedding,
input embed_input_as_msb
);

assign avst_out_streams_interface_pins.clk = avst_in_streams_interface_pins.clk;
assign avst_out_streams_interface_pins.valid = avst_in_streams_interface_pins.valid;
generate
   if (SUPPORT_PACKETS)
	begin
	     assign avst_in_streams_interface_pins.ready = avst_out_streams_interface_pins.ready;
		  assign avst_out_streams_interface_pins.sop = avst_in_streams_interface_pins.sop;
		  assign avst_out_streams_interface_pins.eop = avst_in_streams_interface_pins.eop;	
		  assign avst_out_streams_interface_pins.error = avst_in_streams_interface_pins.error;	
  		  assign avst_out_streams_interface_pins.empty = avst_in_streams_interface_pins.empty;	
	end
endgenerate
	 
genvar current_dac;
genvar current_sample;
generate
	
                   for (current_dac = 0; current_dac < NUM_STREAMS; current_dac++)
                   begin : go_over_converters
                          for (current_sample = 0; current_sample < NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK; current_sample++)
						  begin : go_over_samples						       
										  assign avst_out_streams_interface_pins.data[current_dac][(current_sample+1)*N_PRIME-1 -: N_PRIME] 
											=  do_serial_embedding ?  
											( embed_input_as_msb ? 
											  { 
												  embedded_2_bit_serial_data_interface_pins.serial_sop[current_dac][current_sample],
												  embedded_2_bit_serial_data_interface_pins.serial_data[current_dac][current_sample],
												  avst_in_streams_interface_pins.data[current_dac][((current_sample*N_PRIME) + N - 1) : (current_sample*N_PRIME)] 
											  }
											  :
											  { 
												avst_in_streams_interface_pins.data[current_dac][((current_sample*N_PRIME) + N - 1) : (current_sample*N_PRIME)],
												embedded_2_bit_serial_data_interface_pins.serial_data[current_dac][current_sample],
												embedded_2_bit_serial_data_interface_pins.serial_sop[current_dac][current_sample]
											   }
											)  
											: ((N_PRIME == N) ? avst_in_streams_interface_pins.data[current_dac][((current_sample*N_PRIME) + N - 1) : (current_sample*N_PRIME)]
											   : {avst_in_streams_interface_pins.data[current_dac][((current_sample*N_PRIME) + N - 1) : (current_sample*N_PRIME)],{(N_PRIME-N){1'b0}}});
						 end
						  
				   end				   
endgenerate
`undef current_dac
endmodule

`default_nettype wire
