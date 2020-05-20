`default_nettype none
`include "interface_defs.v"

module convert_from_priority_atlantic_interface_to_avalon_st_sink
(
avalon_st_32_bit_packet_interface  avalon_st_packet_to_sink,
atlantic_32_bit_packet_interface   atlantic_packet,
input override_avalon_st_ready,
input reset_n,
output wire [7:0] fifo_usedw,
output wire fifo_almost_empty ,
output wire fifo_almost_full  ,
output wire fifo_empty        ,
output wire fifo_full       ,
input wire fifo_flush  
);
parameter synchronizer_depth = 3;
wire controlled_atlantic_enable;
wire controlled_avalon_valid;

assign atlantic_packet.clk = avalon_st_packet_to_sink.clk;

wire actual_reset_n;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_reset
(
.indata(reset_n),
.outdata(actual_reset_n),
.clk(atlantic_packet.clk)
);

wire actual_fifo_flush;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_fifo_flush
(
.indata(fifo_flush | (!reset_n)),
.outdata(actual_fifo_flush),
.clk(atlantic_packet.clk)
);


	(* keep = 1 *) wire fifo_wr;
	(* keep = 1 *) wire fifo_rd;
	(* keep = 1 *) wire fifo_input_ready;
    
    assign atlantic_packet.ena = fifo_input_ready || override_avalon_st_ready;

	/*
	assign controlled_atlantic_enable = (!fifo_almost_full && !fifo_full);
    assign atlantic_packet.ena = controlled_atlantic_enable || override_avalon_st_ready;
	assign fifo_wr = atlantic_packet.val & controlled_atlantic_enable & (!atlantic_packet.err);
	assign fifo_rd = avalon_st_packet_to_sink.ready;
	assign avalon_st_packet_to_sink.valid = !fifo_empty;

	fifo_for_atlantic_to_st_conversion	fifo_for_atlantic_to_st_conversion_inst (
	.clock        ( atlantic_packet.clk                                                                                                         ),
	.data         ( {atlantic_packet.mty,atlantic_packet.eop,atlantic_packet.sop,atlantic_packet.dat}                                           ),
	.rdreq        ( fifo_rd                                                                                                                     ),
	.sclr         ( actual_fifo_flush                                                                                                           ),
	.wrreq        ( fifo_wr                                                                                                                     ),
	.almost_empty ( fifo_almost_empty                                                                                                           ),
	.almost_full  ( fifo_almost_full                                                                                                            ),
	.empty        ( fifo_empty                                                                                                                  ),
	.full         ( fifo_full                                                                                                                   ),
	.q            ( {avalon_st_packet_to_sink.empty, avalon_st_packet_to_sink.eop, avalon_st_packet_to_sink.sop, avalon_st_packet_to_sink.data} ),
	.usedw        ( fifo_usedw                                                                                                                  )
	);
	*/
	
	
	
	avalon_st_sc_fifo_only  //NOTE: assumes clock of 100MHz. For faster clocks, modify the underlying qsys 
	fifo_for_atlantic_to_st_conversion_inst(
        .clk_clk                 (avalon_st_packet_to_sink.clk),                 //           clk.clk
        .reset_reset_n           (!actual_fifo_flush),           //         reset.reset_n
        .almost_empty_data       (fifo_almost_empty),       //  almost_empty.data
        .almost_full_data        (fifo_almost_full),        //   almost_full.data
        .out_data_data           (avalon_st_packet_to_sink.data),           //      out_data.data
        .out_data_valid          (avalon_st_packet_to_sink.valid),          //              .valid
        .out_data_ready          (avalon_st_packet_to_sink.ready),          //              .ready
        .out_data_startofpacket  (avalon_st_packet_to_sink.sop),  //              .startofpacket
        .out_data_endofpacket    (avalon_st_packet_to_sink.eop),    //              .endofpacket
        .out_data_empty          (avalon_st_packet_to_sink.empty),          //              .empty
        .in_data_data            (atlantic_packet.dat),            //       in_data.data
        .in_data_valid           (atlantic_packet.val),                               //              .valid
        .in_data_ready           (fifo_input_ready),           //              .ready
        .in_data_startofpacket   (atlantic_packet.sop),   //              .startofpacket
        .in_data_endofpacket     (atlantic_packet.eop),     //              .endofpacket
        .in_data_empty           (atlantic_packet.mty),           //              .empty
        .avalon_mm_slv_address   (0),   // avalon_mm_slv.address
        .avalon_mm_slv_read      (1'b0),      //              .read
        .avalon_mm_slv_write     (1'b0),     //              .write
        .avalon_mm_slv_readdata  (),  //              .readdata
        .avalon_mm_slv_writedata (0)  //              .writedata
    );

	
	
	
endmodule
