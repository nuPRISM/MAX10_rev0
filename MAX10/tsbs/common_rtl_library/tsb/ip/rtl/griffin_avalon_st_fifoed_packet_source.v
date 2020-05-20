
`default_nettype none
`include "interface_defs.v"

module griffin_avalon_st_fifoed_packet_source
#(
parameter test_packet_source = 0
)
(
avalon_st_32_bit_packet_interface  avalon_st_packet_tx_out,
input override_avalon_st_ready,
input reset,
input enable,
input packet_clk,
input avalon_st_clk,
input [23:0] packet_words_before_new_packet,
output wire [13:0] calculated_packet_length_in_words,
input logic [3:0] clog2_packets_per_image_width,
input [13:0] packet_length_in_words,
output wire [31:0] packet_outdata,
output wire [23:0] packet_count,
output wire [23:0] packet_word_counter,
output wire [23:0] total_word_counter,
output wire fifo_almost_empty,
output wire fifo_almost_full,
input  [15:0] image_width_in_pixels,
input  [15:0] image_height_in_pixels,
input wire [6:0] unique_index
);

parameter synchronizer_depth = 3;
avalon_st_32_bit_packet_interface raw_avalon_st_packet_tx_out();
assign avalon_st_packet_tx_out.clk = avalon_st_clk;

wire actual_reset;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_reset
(
.indata(reset),
.outdata(actual_reset),
.clk(avalon_st_packet_tx_out.clk)
);

generate_avalon_st_compatible_emulated_packet
#(
.test_packet_source(test_packet_source)
)
griffin_packet_emulator_to_udp_inst
(
.image_width_in_pixels,
.image_height_in_pixels,
.clog2_packets_per_image_width(clog2_packets_per_image_width),
.calculated_packet_length_in_words,
.unique_index                   (unique_index),
.packet_clk                     (packet_clk                                               ),
.avalon_st_source_out           (raw_avalon_st_packet_tx_out                              ),
.avalon_st_clk                  (avalon_st_packet_tx_out.clk                              ),

.packet_length_in_words         (packet_length_in_words                                   ), 
.transpose_input                (0                                                        ),
.transpose_output               (0                                                        ),
.packet_count                   (packet_count                                             ),
.packet_word_counter            (packet_word_counter                                      ),
.total_word_counter             (total_word_counter                                       ),
.packet_words_before_new_packet (packet_words_before_new_packet                           ),
.reset                          (reset                                                    ),
.enable                         (enable                                                   )
);
	 	
avalon_st_sc_fifo_only  //NOTE: assumes clock of 100MHz. For faster clocks, modify the underlying qsys 
avalon_st_sc_fifo_only_inst (
     .clk_clk                 (avalon_st_packet_tx_out.clk),                 //           clk.clk
     .reset_reset_n           (!actual_reset),                           //         reset.reset_n
     .almost_empty_data       (fifo_almost_empty),                            //  almost_empty.data
     .almost_full_data        (fifo_almost_full),                             //   almost_full.data
     .out_data_data           (avalon_st_packet_tx_out.data  ),              //      out_data.data
     .out_data_valid          (avalon_st_packet_tx_out.valid ),              //              .valid
     .out_data_ready          (avalon_st_packet_tx_out.ready ),              //              .ready
     .out_data_startofpacket  (avalon_st_packet_tx_out.sop   ),              //              .startofpacket
     .out_data_endofpacket    (avalon_st_packet_tx_out.eop   ),              //              .endofpacket
     .out_data_empty          (avalon_st_packet_tx_out.empty ),              //              .empty
     .in_data_data            (raw_avalon_st_packet_tx_out.data  ),          //       in_data.data
     .in_data_valid           (raw_avalon_st_packet_tx_out.valid ),          //              .valid
     .in_data_ready           (raw_avalon_st_packet_tx_out.ready ),          //              .ready
     .in_data_startofpacket   (raw_avalon_st_packet_tx_out.sop   ),          //              .startofpacket
     .in_data_endofpacket     (raw_avalon_st_packet_tx_out.eop   ),          //              .endofpacket
     .in_data_empty           (raw_avalon_st_packet_tx_out.empty ),          //              .empty
     .avalon_mm_slv_address   (0),                                            // avalon_mm_slv.address
     .avalon_mm_slv_read      (1'b0),                                         //              .read
     .avalon_mm_slv_write     (1'b0),                                         //              .write
     .avalon_mm_slv_readdata  (),                                             //              .readdata
     .avalon_mm_slv_writedata (0)                                             //              .writedata
 );

endmodule
`default_nettype wire