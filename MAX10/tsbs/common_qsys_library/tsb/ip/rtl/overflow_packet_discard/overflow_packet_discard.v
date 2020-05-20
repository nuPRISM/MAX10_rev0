//
//  overflow_packet_discard
//
//  This component contains a 4KB FIFO which it uses as an elastic overflow
//  buffer for the packet stream arriving on it's Avalon ST sink interface.
//  Packets are received on the Avalon ST sink interface and buffered in the
//  local FIFO memory until the Avalon ST source is allowed to transmit them
//  to the next peripheral.  If the Avalon ST source interface is back
//  pressured such that it cannot transmit packets forward, then the FIFO will
//  fill to a point where it cannot hold any additional packet data, at which
//  point it will mark the last packet it was receiving as discarded, and it
//  will continue to discard any further packets until the source is allowed to
//  empty data from the FIFO to make room for new packets.
//  
//  This component uses a store and forward algorithm to buffer the packets in
//  the FIFO.  Once it begins receiving a packet, it waits until it has
//  received the entire packet before it begins transmitting the packet forward
//  on its Avalon ST source interface.  This is done to ensure that the
//  component can ensure that once it begins transmitting a packet forward that
//  it actually has the entire packet available.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the overflow_packet_discard contains one 32-bit
//  registers with the following layout:
//  
//  Register 0 - Discarded Packet Count Register
//      Bits [31:0] - R/WC - this is the number of discarded packets that have
//                  been processed since the last reset or clearing of this 
//                  register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//

module overflow_packet_discard
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,
    
    // slave interface
    input           avs_s0_write,
    input           avs_s0_read,
    input           avs_s0_address,
    input   [3:0]   avs_s0_byteenable,
    input   [31:0]  avs_s0_writedata,
    output  [31:0]  avs_s0_readdata,
    
    // source interface
    output          aso_src0_valid,
    input           aso_src0_ready,
    output  [31:0]  aso_src0_data,
    output  [1:0]   aso_src0_empty,
    output          aso_src0_startofpacket,
    output          aso_src0_endofpacket,
    
    // sink interface
    input           asi_snk0_valid,
    output          asi_snk0_ready,
    input   [31:0]  asi_snk0_data,
    input   [1:0]   asi_snk0_empty,
    input           asi_snk0_startofpacket,
    input           asi_snk0_endofpacket
);

wire    [35:0]  fifo_sink_word;
wire    [35:0]  fifo_source_word;
wire            source_word_ack;
wire            read_next_status;
wire            write_next_status;
wire            status_fifo_in;
wire            source_cycle;
wire            sink_cycle;
reg             overflow_error;
reg             count_error_packet;
reg             clear_error_packet_count;
reg     [31:0]  error_packet_count;
wire            data_fifo_empty;
wire            data_fifo_full;
wire            status_fifo_empty;
wire            status_fifo_full;
wire            status_fifo_out;
wire            data_fifo_almost_full;
wire            sink_endofpacket;
wire            data_fifo_write;

//
// misc assignments
//
assign fifo_sink_word   = {asi_snk0_data, asi_snk0_empty, sink_endofpacket, asi_snk0_startofpacket};
assign { aso_src0_data, aso_src0_empty, aso_src0_endofpacket, aso_src0_startofpacket }  = fifo_source_word;

//
// packet transmit state machine
//
assign aso_src0_valid   = !data_fifo_empty & !status_fifo_empty & !status_fifo_out;
                        
assign asi_snk0_ready   =   (!data_fifo_full & !status_fifo_full) |
                            (overflow_error) |
                            (data_fifo_full & !overflow_error);

assign source_word_ack  =   (source_cycle) | 
                            (!data_fifo_empty & !status_fifo_empty & status_fifo_out);
                            
assign read_next_status     =   source_word_ack & aso_src0_endofpacket;

assign write_next_status    =   data_fifo_write & sink_endofpacket;

assign sink_endofpacket =   (asi_snk0_endofpacket) |
                            (status_fifo_in);

assign status_fifo_in       =   (!data_fifo_full & data_fifo_almost_full & !asi_snk0_endofpacket);

assign data_fifo_write  = sink_cycle & !overflow_error & !data_fifo_full;

assign source_cycle = aso_src0_valid & aso_src0_ready;
assign sink_cycle   = asi_snk0_valid & asi_snk0_ready;

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        overflow_error <= 0;
    end
    else
    begin
        if(asi_snk0_endofpacket & sink_cycle)
        begin
            overflow_error <= 0;
        end
        else if(!overflow_error & sink_cycle)
        begin
            overflow_error <=   (status_fifo_in) |
                                (data_fifo_full);
        end
    end
end

//
// packet_count state machine
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    // counter enables
    if(csi_clock_reset)
    begin
        count_error_packet  <= 0;
    end
    else if(!overflow_error & sink_cycle)
    begin
        count_error_packet  <=  (status_fifo_in) |
                                (data_fifo_full);
    end
    else
    begin
        count_error_packet  <= 0;
    end

    // error packet counter
    if(csi_clock_reset)
    begin
        error_packet_count      <= 0;
    end
    else if(clear_error_packet_count)
    begin
        error_packet_count  <= 0;
    end
    else if(count_error_packet)
    begin
        error_packet_count  <= error_packet_count + 1;
    end
end

//
// slave interface machine
//
assign avs_s0_readdata  =   (error_packet_count);

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        clear_error_packet_count    <= 0;
    end
    else if(avs_s0_write)
    begin
        clear_error_packet_count    <= 1'b1;
    end
    else
    begin
        clear_error_packet_count    <= 0;
    end
end

//
//  data fifo instance
//
opd_data_fifo   opd_data_fifo_inst (
    .aclr           ( csi_clock_reset ),
    .clock          ( csi_clock_clk ),
    .data           ( fifo_sink_word ),
    .rdreq          ( source_word_ack ),
    .wrreq          ( data_fifo_write ),
    .almost_full    ( data_fifo_almost_full ),
    .empty          ( data_fifo_empty ),
    .full           ( data_fifo_full ),
    .q              ( fifo_source_word )
    );

//
//  status fifo instance
//
opd_status_fifo opd_status_fifo_inst (
    .aclr   ( csi_clock_reset ),
    .clock  ( csi_clock_clk ),
    .data   ( status_fifo_in ),
    .rdreq  ( read_next_status ),
    .wrreq  ( write_next_status ),
    .empty  ( status_fifo_empty ),
    .full   ( status_fifo_full ),
    .q      ( status_fifo_out )
    );

endmodule
