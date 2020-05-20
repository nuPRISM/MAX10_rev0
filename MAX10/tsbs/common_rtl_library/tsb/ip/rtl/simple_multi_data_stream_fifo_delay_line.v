module simple_multi_data_stream_fifo_delay_line 
#(
parameter device_family = "Cyclone V",
parameter NUM_OF_CLOCK_CYCLES_TO_DELAY_INPUT,
parameter [0:0] CONNECT_CLOCK_OF_OUTPUT_INTERFACE_TO_INPUT_CLOCK = 1'b1
)
(
multi_data_stream_interface input_streams_interface_pins,
multi_data_stream_interface output_streams_interface_pins,
input async_clear_fifo
);

generate
if (CONNECT_CLOCK_OF_OUTPUT_INTERFACE_TO_INPUT_CLOCK)
begin
       assign output_streams_interface_pins.clk = input_streams_interface_pins.clk;
end
endgenerate

logic [input_streams_interface_pins.get_num_data_streams()*input_streams_interface_pins.get_data_width()-1 : 0] parallelized_input_data;
logic [input_streams_interface_pins.get_num_data_streams()*input_streams_interface_pins.get_data_width()-1 : 0] parallelized_output_data;

adv_2d_unpacked_to_packed
#(
.numelements_in          (input_streams_interface_pins.get_num_data_streams()),
.num_bits_per_elements_in(input_streams_interface_pins.get_data_width()      )
)
parallelize_input_data
(
.in_unpacked(input_streams_interface_pins.data),
.out_packed (parallelized_input_data)
);

simple_fifo_delay_line
#(
 .device_family(device_family),
 .num_locations(NUM_OF_CLOCK_CYCLES_TO_DELAY_INPUT),
 .num_data_bits(input_streams_interface_pins.get_num_data_streams()*input_streams_interface_pins.get_data_width()+1)
)
simple_fifo_delay_line_inst
(
	.async_clear_fifo(async_clear_fifo),
	.clock(input_streams_interface_pins.clk),
	.data_in({input_streams_interface_pins.superframe_start_n,parallelized_input_data}),
	.data_in_valid(input_streams_interface_pins.valid),	
	.data_out({output_streams_interface_pins.superframe_start_n,parallelized_output_data}),
	.usedw(),
	.delay_achieved(output_streams_interface_pins.valid)	
); 


adv_2d_packed_to_unpacked
#(
.numelements_out          (output_streams_interface_pins.get_num_data_streams()),
.num_bits_per_elements_out(output_streams_interface_pins.get_data_width()      )
)
deparallelize_output_data
(
.in_packed(parallelized_output_data),
.out_unpacked(output_streams_interface_pins.data)
);

assign output_streams_interface_pins.desc = input_streams_interface_pins.desc;

endmodule


