`default_nettype none
`include "interface_defs.v"

module convert_from_avalon_st_source_to_atlantic
(
avalon_st_32_bit_packet_interface  avalon_st_packet_from_source,
atlantic_32_bit_packet_interface   atlantic_packet,
input override_avalon_st_ready,
input [7:0] atlantic_adr
);

assign avalon_st_packet_from_source.ready = atlantic_packet.dav || override_avalon_st_ready;
assign atlantic_packet.ena = avalon_st_packet_from_source.valid;
assign atlantic_packet.dat = avalon_st_packet_from_source.data;
assign atlantic_packet.sop = avalon_st_packet_from_source.sop;
assign atlantic_packet.eop = avalon_st_packet_from_source.eop;
assign atlantic_packet.mty = avalon_st_packet_from_source.empty;
assign atlantic_packet.err = avalon_st_packet_from_source.error;
assign atlantic_packet.clk = avalon_st_packet_from_source.clk;
assign atlantic_packet.adr = atlantic_adr;

/*
assign txrdp_clk = avalon_st_packet_tx_out.clk;
assign avalon_st_packet_tx_out.ready = txrdp_dav || actual_override_tx_ready;
assign txrdp_ena = avalon_st_packet_tx_out.valid;
assign txrdp_sop = avalon_st_packet_tx_out.sop;
assign txrdp_eop = avalon_st_packet_tx_out.eop;
assign txrdp_err = avalon_st_packet_tx_out.error;
assign txrdp_mty = avalon_st_packet_tx_out.empty;
assign txrdp_dat = avalon_st_packet_tx_out.data;
assign txrdp_adr = current_tx_packet_id_counter;
*/






endmodule