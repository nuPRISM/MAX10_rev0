//
//  udp_port_to_channel_mapper
//
//  This component is used to map incoming Ethernet packets onto specific
//  Avalon ST channels to allow them to be easily demultiplexed and routed.
//  This component receives Ethernet packets on an Avalon ST sink interface and
//  transmits the channelized packets out an Avalon ST source interface.  The
//  configuration and monitoring of this peripheral is performed thru an Avalon
//  MM slave interface.
//  
//  This component inspects the incoming Ethernet packet to locate specific
//  UDP packets that have been programmed in this component to map to a
//  specific Avalon ST channel.  There are 5 possible channels that this
//  component will map to, 4 programmable UDP port numbers, or the fifth
//  channel where all unmapped packets are assigned.
//  
//  The standard format of each of the header layers is illustrated below, you
//  can think of each layer being wrapped in the payload section of the layer
//  above it, with the Ethernet packet layout being the outer most wrapper.
//  
//  Standard Ethernet Packet Layout
//  |-------------------------------------------------------|
//  |                Destination MAC Address                |
//  |                           ----------------------------|
//  |                           |                           |
//  |----------------------------                           |
//  |                  Source MAC Address                   |
//  |-------------------------------------------------------|
//  |         EtherType         |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                   Ethernet Payload                    |
//  |                                                       |
//  |-------------------------------------------------------|
//  |                 Frame Check Sequence                  |
//  |-------------------------------------------------------|
//
//  Standard IP Packet Layout
//  |-------------------------------------------------------|
//  | VER  | HLEN |     TOS     |       Total Length        |
//  |-------------------------------------------------------|
//  |       Identification      | FLGS |    FRAG OFFSET     |
//  |-------------------------------------------------------|
//  |     TTL     |    PROTO    |      Header Checksum      |
//  |-------------------------------------------------------|
//  |                   Source IP Address                   |
//  |-------------------------------------------------------|
//  |                Destination IP Address                 |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      IP Payload                       |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  Standard UDP Packet Layout
//  |-------------------------------------------------------|
//  |      Source UDP Port      |   Destination UDP Port    |
//  |-------------------------------------------------------|
//  |    UDP Message Length     |       UDP Checksum        |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                      UDP Payload                      |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  The general packet channel mapping flows like this:
//  
//  This component supports the mapping of up to 4 UDP port numbers.
//
//  The primary condition that this component looks at to qualify a packet to
//  be mapped to a channel is the Destination UDP Port number in the UDP
//  header.  However, as the Ethernet packet is received by this component a
//  number of other sanity checks are made to ensure that we have a UDP packet
//  to deal with.  Here are the qualifications that are applied to the various
//  fields of the header layers:
//  
//      MAC Destination Address     = X
//      MAC Source Address          = X
//      MAC EtherType               = must be IPV4
//      IP Version                  = must be IPV4
//      IP Header Length            = must be FIVE
//      IP Type of Service          = X
//      IP Total Length             = X
//      IP Identification           = X
//      IP Flags                    = must NOT be fragmented
//      IP Fragment Offset          = must be ZERO
//      IP Time to Live             = X
//      IP Protocol                 = must be UDP
//      IP Checksum                 = must verify
//      IP Source Address           = X
//      IP Destination Address      = X
//      UDP Source UDP Port         = X
//      UDP Destination UDP Port    = must match user programmed value
//      UDP UDP Message Length      = X
//      UDP UDP Checksum            = X
//      
//  If any of the observed fields do not match their expected values then the
//  packet will be assigned to the default channel and forwarded.  If all of
//  the fields match their expected values and the user has programmed a
//  particular UDP port number into a channel mapping and enabled it, then the
//  packet will be mapped onto that channel and forwarded.
//  
//  You can see that there are a few restrictions placed on the received
//  packets to make them eligible for mapping.  First, only a single MAC
//  header is allowed, no VLAN headers are allowed.  Second, only a standard 20
//  byte IP header is allowed, no option words are allowed.  Third, the packet
//  must not be fragmented.
//  
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the udp_port_to_channel_mapper is broken up into 5
//  32-bit registers with the following layout:
//  
//  Register 0 - Channel 0 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 1 - Channel 1 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 2 - Channel 2 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 3 - Channel 3 Mapping Register
//      Bits [15:0] - R/W - this is the destination UDP port value to map on this channel
//      Bits [16]   - R/W - this bit enables this channel, 1 is enabled, 0 is disabled
//                  
//  Register 4 - Packet Count Register
//      Bits [31:0] - R/WC - this is the number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//

module udp_port_to_channel_mapper
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,
    
    // slave interface
    input           avs_s0_write,
    input           avs_s0_read,
    input   [2:0]   avs_s0_address,
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
    output  [2:0]   aso_src0_channel,
    
    // sink interface
    input           asi_snk0_valid,
    output          asi_snk0_ready,
    input   [31:0]  asi_snk0_data,
    input   [1:0]   asi_snk0_empty,
    input           asi_snk0_startofpacket,
    input           asi_snk0_endofpacket
);

localparam [4:0] STATE_PW_0     = 5'd0;
localparam [4:0] STATE_PW_1     = 5'd1;
localparam [4:0] STATE_PW_2     = 5'd2;
localparam [4:0] STATE_PW_3     = 5'd3;
localparam [4:0] STATE_PW_4     = 5'd4;
localparam [4:0] STATE_PW_5     = 5'd5;
localparam [4:0] STATE_PW_6     = 5'd6;
localparam [4:0] STATE_PW_7     = 5'd7;
localparam [4:0] STATE_PW_8     = 5'd8;
localparam [4:0] STATE_PW_9     = 5'd9;
localparam [4:0] STATE_PW_10    = 5'd10;
localparam [4:0] STATE_PW_N     = 5'd11;

wire            source_cycle;
wire            sink_cycle;
wire    [35:0]  fifo_sink_word;
wire    [35:0]  fifo_source_word;
wire            data_fifo_empty;
wire            data_fifo_full;
reg     [4:0]   state;
reg             count_packet;
reg             clear_packet_count;
reg     [31:0]  packet_count;
wire            read_next_channel;
reg             write_next_channel;
wire    [2:0]   channel_fifo_in;
wire    [2:0]   channel_fifo_out;
wire            channel_fifo_empty;
wire            channel_fifo_full;
wire            qualified_packet;
reg     [15:0]  udp_chan_0;
reg     [15:0]  udp_chan_1;
reg     [15:0]  udp_chan_2;
reg     [15:0]  udp_chan_3;
reg             udp_chan_0_en;
reg             udp_chan_1_en;
reg             udp_chan_2_en;
reg             udp_chan_3_en;

reg             mac_type_is_ipv4;
reg             ip_hdr_is_ipv4;
reg             ip_hdr_len_is_5;
reg     [19:0]  ip_hdr_csum;
reg             ip_flg_not_frag;
reg             ip_frag_zero;
reg             ip_proto_is_udp;
reg     [15:0]  udp_dest_port;

//
// misc
//
assign fifo_sink_word   = {asi_snk0_data, asi_snk0_empty, asi_snk0_endofpacket, asi_snk0_startofpacket};

//
// packet transmit state machine
//
assign aso_src0_data            = fifo_source_word[35:4];
assign aso_src0_empty           = fifo_source_word[3:2];
assign aso_src0_endofpacket     = fifo_source_word[1];
assign aso_src0_startofpacket   = fifo_source_word[0];
assign aso_src0_channel         = channel_fifo_out;

assign aso_src0_valid   = !data_fifo_empty & !channel_fifo_empty;
                        
assign asi_snk0_ready   = !data_fifo_full;

assign source_cycle = aso_src0_valid & aso_src0_ready;
assign sink_cycle   = asi_snk0_valid & asi_snk0_ready;

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        state               <= STATE_PW_0;
        mac_type_is_ipv4    <= 0;
        ip_hdr_is_ipv4      <= 0;
        ip_hdr_len_is_5     <= 0;
        ip_hdr_csum         <= 0;
        ip_flg_not_frag     <= 0;
        ip_frag_zero        <= 0;
        ip_proto_is_udp     <= 0;
        udp_dest_port       <= 0;
        write_next_channel  <= 0;
        count_packet        <= 0;
    end
    else
    begin
        case(state)
        STATE_PW_0:
        // packet_word_0    = mac_dst[47:16];
        begin
            count_packet    <= 1'b0;
        
            if(sink_cycle)
            begin
                state <= STATE_PW_1;
            end
        end
        STATE_PW_1:
        // packet_word_1    = {mac_dst[15:0], mac_src[47:32]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_2;
            end
        end
        STATE_PW_2:
        // packet_word_2    = mac_src[31:0];
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_3;
            end
        end
        STATE_PW_3:
        // packet_word_3    = {MAC_TYPE, ip_word_0[31:16]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_4;
                
                mac_type_is_ipv4    <= (asi_snk0_data[31:16] == 16'h0800) ? (1'b1) : (1'b0);
                ip_hdr_is_ipv4      <= (asi_snk0_data[15:12] == 4'h4) ? (1'b1) : (1'b0);
                ip_hdr_len_is_5     <= (asi_snk0_data[11:8] == 4'h5) ? (1'b1) : (1'b0);
                ip_hdr_csum         <= asi_snk0_data[15:0];
            end
        end
        STATE_PW_4:
        // packet_word_4    = {ip_word_0[15:0], ip_word_1[31:16]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_5;

                ip_hdr_csum <= ip_hdr_csum + asi_snk0_data[31:16] + asi_snk0_data[15:0];
            end
        end
        STATE_PW_5:
        // packet_word_5    = {ip_word_1[15:0], ip_word_2[31:16]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_6;
                
                ip_flg_not_frag <= (asi_snk0_data[29] == 1'b0) ? (1'b1) : (1'b0);
                ip_frag_zero    <= (asi_snk0_data[28:16] == 13'h0000) ? (1'b1) : (1'b0);
                ip_proto_is_udp <= (asi_snk0_data[7:0] == 8'd17) ? (1'b1) : (1'b0);
                ip_hdr_csum     <= ip_hdr_csum + asi_snk0_data[31:16] + asi_snk0_data[15:0];
            end
        end
        STATE_PW_6:
        // packet_word_6    = {ip_word_2[15:0], ip_word_3[31:16]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_7;

                ip_hdr_csum     <= ip_hdr_csum + asi_snk0_data[31:16] + asi_snk0_data[15:0];
            end
        end
        STATE_PW_7:
        // packet_word_7    = {ip_word_3[15:0], ip_word_4[31:16]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_8;
                
                ip_hdr_csum     <= ip_hdr_csum + asi_snk0_data[31:16] + asi_snk0_data[15:0];
            end
        end
        STATE_PW_8:
        // packet_word_8    = {ip_word_4[15:0], udp_word_0[31:16]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_9;

                ip_hdr_csum     <= ip_hdr_csum + asi_snk0_data[31:16];
            end
        end
        STATE_PW_9:
        // packet_word_9    = {udp_word_0[15:0], udp_word_1[31:16]};
        begin
            if(sink_cycle)
            begin
                state <= STATE_PW_10;
                
                ip_hdr_csum         <= ip_hdr_csum[15:0] + ip_hdr_csum[19:16];
                udp_dest_port       <= asi_snk0_data[31:16];
                write_next_channel  <= 1'b1;
            end
        end
        STATE_PW_10:
        // packet_word_10   = {udp_word_1[15:0], first_two_bytes};
        begin
            write_next_channel  <= 1'b0;

            if(sink_cycle)
            begin
                state <= STATE_PW_N;
            end
        end
        STATE_PW_N:
        // packet_word_n    = sink_data;
        begin
            if(sink_cycle)
            begin
                if(asi_snk0_endofpacket)
                begin
                    state           <= STATE_PW_0;
                    count_packet    <= 1'b1;
                end
                else
                begin
                end
            end
        end
        default:
        begin
            state <= STATE_PW_0;
        end
        endcase
    end
end

//
// packet_count state machine
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        packet_count    <= 0;
    end
    else if(clear_packet_count)
    begin
        packet_count    <= 0;
    end
    else if(count_packet)
    begin
        packet_count    <= packet_count + 1;
    end
end

//
// slave interface machine
//
assign avs_s0_readdata  =   (avs_s0_address == 3'h0) ? ({{15{1'b0}}, udp_chan_0_en, udp_chan_0}) :
                            (avs_s0_address == 3'h1) ? ({{15{1'b0}}, udp_chan_1_en, udp_chan_1}) :
                            (avs_s0_address == 3'h2) ? ({{15{1'b0}}, udp_chan_2_en, udp_chan_2}) :
                            (avs_s0_address == 3'h3) ? ({{15{1'b0}}, udp_chan_3_en, udp_chan_3}) :
                            (packet_count);

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        clear_packet_count  <= 0;
        udp_chan_0          <= 0;
        udp_chan_1          <= 0;
        udp_chan_2          <= 0;
        udp_chan_3          <= 0;
        udp_chan_0_en       <= 0;
        udp_chan_1_en       <= 0;
        udp_chan_2_en       <= 0;
        udp_chan_3_en       <= 0;
    end
    else if(avs_s0_write)
    begin
        case(avs_s0_address)
            3'h0:
            begin
                if(avs_s0_byteenable[0] == 1'b1)
                    udp_chan_0[7:0]     <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    udp_chan_0[15:8]    <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    udp_chan_0_en   <= avs_s0_writedata[16];
            end
            3'h1:
            begin
                if(avs_s0_byteenable[0] == 1'b1)
                    udp_chan_1[7:0]     <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    udp_chan_1[15:8]    <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    udp_chan_1_en   <= avs_s0_writedata[16];
            end
            3'h2:
            begin
                if(avs_s0_byteenable[0] == 1'b1)
                    udp_chan_2[7:0]     <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    udp_chan_2[15:8]    <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    udp_chan_2_en   <= avs_s0_writedata[16];
            end
            3'h3:
            begin
                if(avs_s0_byteenable[0] == 1'b1)
                    udp_chan_3[7:0]     <= avs_s0_writedata[7:0];
                if(avs_s0_byteenable[1] == 1'b1)
                    udp_chan_3[15:8]    <= avs_s0_writedata[15:8];
                if(avs_s0_byteenable[2] == 1'b1)
                    udp_chan_3_en   <= avs_s0_writedata[16];
            end
            3'h3: clear_packet_count <= 1;
            default: ;
        endcase
    end
    else
    begin
        clear_packet_count <= 0;
    end
end

//
// data and status fifo instances
//
up2cm_data_fifo up2cm_data_fifo_inst (
    .aclr   ( csi_clock_reset ),
    .clock  ( csi_clock_clk ),
    .data   ( fifo_sink_word ),
    .rdreq  ( source_cycle ),
    .wrreq  ( sink_cycle ),
    .empty  ( data_fifo_empty ),
    .full   ( data_fifo_full ),
    .q      ( fifo_source_word )
    );

assign read_next_channel = source_cycle & aso_src0_endofpacket;

assign qualified_packet =   mac_type_is_ipv4    &
                            ip_hdr_is_ipv4      &
                            ip_hdr_len_is_5     &
                            (ip_hdr_csum[15:0] == 16'hFFFF) &
                            ip_flg_not_frag     &
                            ip_frag_zero        &
                            ip_proto_is_udp;

assign channel_fifo_in =    (qualified_packet && (udp_dest_port == udp_chan_0) && udp_chan_0_en) ? (3'h0) :
                            (qualified_packet && (udp_dest_port == udp_chan_1) && udp_chan_1_en) ? (3'h1) :
                            (qualified_packet && (udp_dest_port == udp_chan_2) && udp_chan_2_en) ? (3'h2) :
                            (qualified_packet && (udp_dest_port == udp_chan_3) && udp_chan_3_en) ? (3'h3) :
                            (3'h4);

up2cm_channel_fifo  up2cm_channel_fifo_inst (
    .aclr   ( csi_clock_reset ),
    .clock  ( csi_clock_clk ),
    .data   ( channel_fifo_in ),
    .rdreq  ( read_next_channel ),
    .wrreq  ( write_next_channel ),
    .empty  ( channel_fifo_empty ),
    .full   ( channel_fifo_full ),
    .q      ( channel_fifo_out )
    );

endmodule
