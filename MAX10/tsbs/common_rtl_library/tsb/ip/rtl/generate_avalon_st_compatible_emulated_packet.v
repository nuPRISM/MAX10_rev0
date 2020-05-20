`default_nettype none
`include "interface_defs.v"

module generate_avalon_st_compatible_emulated_packet
#(
parameter test_packet_source = 0
)
(
avalon_st_32_bit_packet_interface  avalon_st_source_out,
input  packet_clk,
input  avalon_st_clk,
input  logic [23:0] packet_words_before_new_packet,
input  logic [13:0] packet_length_in_words,
output  logic [13:0] calculated_packet_length_in_words,
input  logic transpose_input,
input  logic transpose_output,
input  logic enable,
input  logic reset,
input  logic [15:0] image_width_in_pixels,
input  logic [15:0] image_height_in_pixels,

//debugging outputs
output logic [31:0] packet_outdata,
output logic [23:0] packet_count,
output logic [23:0] packet_word_counter,
output logic [23:0] total_word_counter,
input logic [3:0] clog2_packets_per_image_width, 
output logic processed_in_sop,
output logic processed_in_eop,
output logic processed_in_valid,
output logic found_sop,
output logic found_eop,
output found_sop_raw,
output found_eop_raw,
output logic [11:0] state,
output       [31:0] actual_possibly_transposed_indata,
output logic [15:0] packet_byte_count,
output new_packet_word_clk_has_arrived,
output found_valid,
output found_valid_raw,
input wire [6:0] unique_index
);


assign avalon_st_source_out.clk = avalon_st_clk;
assign avalon_st_source_out.error = 0;

generate
				if (test_packet_source == 0)
				begin
							griffin_packet_emulator_ver2
							griffin_packet_emulator_ver2_inst
							(
							.unique_index(unique_index),
							.clk(packet_clk),
							.outdata                              (packet_outdata),
							.packet_count                         (packet_count),
							.packet_word_counter                  (packet_word_counter),
							.total_word_counter                   (total_word_counter),
							.packet_words_before_new_packet       (packet_words_before_new_packet),
							.packet_length_in_words               (packet_length_in_words),
							.sop                                  (processed_in_sop),
							.eop                                  (processed_in_eop),
							.valid                                (processed_in_valid)
							);
							assign calculated_packet_length_in_words = packet_length_in_words;
				end else 
				begin
							test_image_udp_packet_generator
							test_packet_source_inst
							(
							.reset_n(!reset),
							.enable(enable),
							//.unique_index(unique_index),
							.image_width_in_pixels(image_width_in_pixels),
                            .image_height_in_pixels(image_height_in_pixels),
							.packet_length_in_words(calculated_packet_length_in_words),
							.CLOG2_NUM_OF_PACKETS_PER_IMAGE_WIDTH(clog2_packets_per_image_width),
							.clk(packet_clk),
							.outdata                              (packet_outdata),
							.packet_count                         (packet_count),
							.packet_word_counter                  (packet_word_counter),
							.total_word_counter                   (total_word_counter),
							.packet_words_before_new_packet       (packet_words_before_new_packet),
							//.packet_length_in_words               (packet_length_in_words),
							.sop                                  (processed_in_sop),
							.eop                                  (processed_in_eop),
							.valid                                (processed_in_valid)
							);
				end
endgenerate

demarcate_and_ready_packet_for_udp_streaming_fast_sm_clk
#(
.numbits(32)
)
demarcate_and_ready_packet_for_udp_streaming_fast_sm_clk_inst
(
 .indata                              (packet_outdata                   ),
 .outdata                             (avalon_st_source_out.data        ),
 .valid                               (avalon_st_source_out.valid       ),
 .startofpacket                       (avalon_st_source_out.sop         ),
 .endofpacket                         (avalon_st_source_out.eop         ),
 .empty                               (avalon_st_source_out.empty       ),
 .in_sop                              (processed_in_sop                 ),
 .in_eop                              (processed_in_eop                 ),
 .in_valid                            (processed_in_valid               ),
 .packet_word_clk                     (packet_clk                       ),
 .fast_sm_clk                         (avalon_st_clk                    ),
 .transpose_input                     (transpose_input                  ),
 .transpose_output                    (transpose_output                 ),
 .enable                              (enable                           ),
 .reset                               (reset                            ),
 .ready                               (avalon_st_source_out.ready       ),                          

 .found_sop                           (found_sop                        ),
 .found_eop                           (found_eop                        ),
 .found_sop_raw                       (found_sop_raw                    ),
 .found_eop_raw                       (found_eop_raw                    ),
 .state                               (state                            ),
 .actual_possibly_transposed_indata   (actual_possibly_transposed_indata),
 .packet_byte_count                   (packet_byte_count                ),
 .new_packet_word_clk_has_arrived     (new_packet_word_clk_has_arrived  ),
 .found_valid                         (found_valid                      ),
 .found_valid_raw                     (found_valid_raw                  )
);


endmodule
`default_nettype wire