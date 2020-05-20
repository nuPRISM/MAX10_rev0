//
//  error_packet_discard
//
//  This component monitors an incoming packet on its Avalon ST interface for
//  any error signal.  If an error signal is detected, this component discards
//  the packet.  If no error signal is detected, then this component forwards
//  the packet out its Avalon ST source interface.  This component uses a store
//  and forward algorithm, whereby it will store each packet it receives in a
//  local FIFO, and upon successfully receiving the entire packet, it will then
//  forward the packet on, or in the event of an error, it will discard the
//  packet.  The local FIFO in this component is able to hold 2KB of packet
//  data, it is intended to filter out errant Ethernet packets which are
//  assumed to be no greater than 1518 bytes long, so there should be plenty
//  of FIFO buffer to manage a full sized Ethernet packet.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the error_packet_discard is broken up into two
//  32-bit registers with the following layout:
//  
//  Register 0 - Packet Count Register
//      Bits [31:0] - R/WC - this is the total number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  This includes valid packets as well as error'ed packet.
//                  
//  Register 1 - Error Packet Count Register
//      Bits [31:0] - R/WC - this is the number of error'ed packets that have
//                  been processed since the last reset or clearing of this 
//                  register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//

module error_packet_discard
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
    input           asi_snk0_endofpacket,
    input   [5:0]   asi_snk0_error
);

wire    [35:0]  fifo_sink_word;
wire    [35:0]  fifo_source_word;
wire            source_word_ack;
wire            read_next_status;
wire            write_next_status;
wire            status_fifo_in;
wire            source_cycle;
wire            sink_cycle;
reg             packet_error;
reg             count_packet;
reg             count_error_packet;
reg             clear_packet_count;
reg             clear_error_packet_count;
reg     [31:0]  packet_count;
reg     [31:0]  error_packet_count;
wire            data_fifo_empty;
wire            data_fifo_full;
wire            status_fifo_empty;
wire            status_fifo_full;
wire            status_fifo_out;

//
// misc assignments
//
assign fifo_sink_word   = {asi_snk0_data, asi_snk0_empty, asi_snk0_endofpacket, asi_snk0_startofpacket};
assign { aso_src0_data, aso_src0_empty, aso_src0_endofpacket, aso_src0_startofpacket }  = fifo_source_word;

//
// packet transmit state machine
//
assign aso_src0_valid   = !data_fifo_empty & !status_fifo_empty & !status_fifo_out;
                        
assign asi_snk0_ready   = !data_fifo_full & !status_fifo_full;

assign source_word_ack  =   (source_cycle) | 
                            (!data_fifo_empty & !status_fifo_empty & status_fifo_out);
                            
assign read_next_status     =   source_word_ack & aso_src0_endofpacket;

assign write_next_status    =   sink_cycle & asi_snk0_endofpacket;

assign status_fifo_in       =   (packet_error) |
                                (|asi_snk0_error);

assign source_cycle = aso_src0_valid & aso_src0_ready;
assign sink_cycle   = asi_snk0_valid & asi_snk0_ready;

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        packet_error <= 0;
    end
    else
    begin
        if(asi_snk0_endofpacket & sink_cycle)
        begin
            packet_error <= 0;
        end
        else if(!packet_error & sink_cycle)
        begin
            packet_error <= |asi_snk0_error;
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
        count_packet        <= 0;
        count_error_packet  <= 0;
    end
    else if(asi_snk0_endofpacket & sink_cycle)
    begin
        count_packet        <= 1'b1;
        count_error_packet  <= status_fifo_in;
    end
    else
    begin
        count_packet        <= 0;
        count_error_packet  <= 0;
    end

    // packet counter
    if(csi_clock_reset)
    begin
        packet_count        <= 0;
    end
    else if(clear_packet_count)
    begin
        packet_count    <= 0;
    end
    else if(count_packet)
    begin
        packet_count    <= packet_count + 1;
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
assign avs_s0_readdata  =   (avs_s0_address == 1'b0) ? (packet_count) :
                            (error_packet_count);

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        clear_packet_count          <= 0;
        clear_error_packet_count    <= 0;
    end
    else if(avs_s0_write)
    begin
        case(avs_s0_address)
            1'b0:
            begin
                clear_packet_count          <= 1'b1;
            end
            1'b1:
            begin
                clear_error_packet_count    <= 1'b1;
            end
            default: ;
        endcase
    end
    else
    begin
        clear_packet_count          <= 0;
        clear_error_packet_count    <= 0;
    end
end

//
//  data fifo instance
//
epd_data_fifo   epd_data_fifo_inst (
    .aclr   ( csi_clock_reset ),
    .clock  ( csi_clock_clk ),
    .data   ( fifo_sink_word ),
    .rdreq  ( source_word_ack ),
    .wrreq  ( sink_cycle ),
    .empty  ( data_fifo_empty ),
    .full   ( data_fifo_full ),
    .q      ( fifo_source_word )
    );

//
//  status fifo instance
//
epd_status_fifo epd_status_fifo_inst (
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
