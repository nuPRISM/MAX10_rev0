//
// prbs_packet_generator
//
// This component is designed to create sequenced packets of programmable
// length, filled with pseudo random data.  The packets are transmitted from an
// Avalon ST source interface.  These packets are intended to be verified by
// the prbs_packet_checker on the receiving end of the data path.
//
// The packets are created with this format:
//
//  |-------------------------------------------------------|
//  |    PRBS Packet Length     |   Seq LSB   |   Seq MSB   |
//  |-------------------------------------------------------|
//  |             PRBS Data Word 0 (MSB first)              |
//  |-------------------------------------------------------|
//  |                                                       |
//  |                         . . .                         |
//  |                                                       |
//  |-------------------------------------------------------|
//  |             PRBS Data Word N (MSB first)              |
//  |-------------------------------------------------------|
//
//  PRBS Packet Length - is the length of the packet data not including this
//      length field.  This value is programmed via control register.
//
//  Sequence Number - is the packet sequence number which begins at ZERO when
//      the peripheral is enabled and then incremented for each subsequent
//      packet.
//                  
//  Sequence LSB - is the least significant byte of the sequence number
//
//  Sequence MSB - is the most significant byte of the sequence number
//
//  PRBS Data Word - is the pseudo random data pattern that fills the packet.
//      When the peripheral is enabled, the first PRBS data word is the initial
//      value which is programmed via control register.  Each subsequent PRBS
//      word is computed using the PRBS algorithm encoded in this peripheral,
//      which follows no standard PRBS generation scheme.  The PRBS data words
//      are transmitted most significant byte first, and it is perfectly legal
//      to transmit partial PRBS data words, depending on the packet length.
//      Packet lengths less than three will contain no PRBS data at all, and
//      only packets of length 7 or greater will contain enough PRBS data for
//      verification by the corresponding checker peripheral.
// 
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the prbs_packet_generator is broken up into four
//  32-bit registers with the following layout:
//  
//  Register 0 - Status Register
//      Bit 0 - R/W - GO control and status bit.  Set this bit to 1 to enable
//                  the packet generator, and clear it to disable it.  Note
//                  that once cleared, the packet generator will not truely
//                  stop until it completes the current packe that it's
//                  generating.
//      Bit 1 - RO  - Running status bit.  This bit indicates whether the
//                  peripheral is currently running or not.  After clearing the
//                  GO bit, you can monitor this status bit to tell when the
//                  generator is truely stopped.
//      
//  Register 1 - Packet Length Register
//      Bits [15:0] - R/W - byte count of packet payload length, does not
//                  include the length field of the packet.  The length value
//                  may be anything from 0x0000 thru 0xFFFF.
//                  
//  Register 2 - Initial Value Register
//      Bits [31:0] - R/W - the initial seed value for the PRBS pattern
//                  generator.  A good value for this is 0x33557799.
//                  
//  Register 3 - Packet Count Register
//      Bits [31:0] - R/WC - the packet count that this peripheral has
//                  generated since it's last reset, or clear.  Writing to any
//                  byte in this register will clear the packet count.
//                  
//  R - Readable
//  W - Writeable
//  RO - Read Only
//  WC - Clear on Write
//

module prbs_packet_generator
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,
    
    // slave interface
    input           avs_s0_write,
    input           avs_s0_read,
    input   [1:0]   avs_s0_address,
    input   [3:0]   avs_s0_byteenable,
    input   [31:0]  avs_s0_writedata,
    output  [31:0]  avs_s0_readdata,
    
    // source interface
    output          aso_src0_valid,
    input           aso_src0_ready,
    output  [31:0]  aso_src0_data,
    output  [1:0]   aso_src0_empty,
    output          aso_src0_startofpacket,
    output          aso_src0_endofpacket
);

localparam [1:0] IDLE_STATE = 2'h0;
localparam [1:0] SOP_STATE  = 2'h1;
localparam [1:0] DATA_STATE = 2'h2;
localparam [1:0] EOP_STATE  = 2'h3;

reg             go_bit;
reg             running_bit;
reg     [15:0]  payload_prbs_byte_count;
reg     [15:0]  byte_count;
reg     [31:0]  initial_value;
reg     [31:0]  next_value;
reg     [31:0]  packet_count;
reg             clear_packet_count;
reg     [1:0]   state;
reg     [15:0]  packet_sequence_number;

wire    [15:0]  empty_symbols;

//
// slave read mux
//
assign avs_s0_readdata =    (avs_s0_address == 2'h0) ?  ({{30{1'b0}}, running_bit, go_bit}) :
                            (avs_s0_address == 2'h1) ?  ({{16{1'b0}}, payload_prbs_byte_count}) :
                            (avs_s0_address == 2'h2) ?  (initial_value) :
                                                        (packet_count);

//
// slave write demux
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        go_bit                  <= 0;
        payload_prbs_byte_count <= 0;
        initial_value           <= 0;
        clear_packet_count      <= 0;
    end
    else
    begin
        if(avs_s0_write)
        begin
            case(avs_s0_address)
                2'h0:
                begin
                    if (avs_s0_byteenable[0] == 1'b1)
                        go_bit  <= avs_s0_writedata[0];
                end
                2'h1:
                begin
                    if (avs_s0_byteenable[0] == 1'b1)
                        payload_prbs_byte_count[7:0]    <= avs_s0_writedata[7:0];
                    if (avs_s0_byteenable[1] == 1'b1)
                        payload_prbs_byte_count[15:8]   <= avs_s0_writedata[15:8];
                end
                2'h2:
                begin
                    if (avs_s0_byteenable[0] == 1'b1)
                        initial_value[7:0]      <= avs_s0_writedata[7:0];
                    if (avs_s0_byteenable[1] == 1'b1)
                        initial_value[15:8]     <= avs_s0_writedata[15:8];
                    if (avs_s0_byteenable[2] == 1'b1)
                        initial_value[23:16]    <= avs_s0_writedata[23:16];
                    if (avs_s0_byteenable[3] == 1'b1)
                        initial_value[31:24]    <= avs_s0_writedata[31:24];
                end
                2'h3:
                begin
                    clear_packet_count  <= 1;
                end
            endcase
        end
        else
        begin
            clear_packet_count  <= 0;
        end
    end
end

//
// packet_count state machine
//
// count the packet when we send startofpacket, the first word of the packet
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        packet_count <= 0;
    end
    else
    begin
        if(clear_packet_count)
        begin
            packet_count <= 0;
        end
        else if(aso_src0_valid & aso_src0_ready & aso_src0_startofpacket)
        begin
            packet_count <= packet_count + 1;
        end
    end
end

//
// running_bit state machine
//
// we start immediately when go_bit is asserted
// we don't stop until we reach the end of the current packet that we're generating
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        running_bit <= 0;
    end
    else
    begin
        if(go_bit)
        begin
            running_bit <= 1;
        end
        else if(running_bit & !go_bit & aso_src0_valid & aso_src0_ready & aso_src0_endofpacket)
        begin
            running_bit <= 0;
        end
    end
end

//
// next_value state machine
//
// this PRBS algorithm is quite simple but efficient, it takes the current
// value and rotates it 5-bits to the left and then adds the initial value to 
// the rotated value.
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        next_value  <= 0;
    end
    else
    begin
        if(go_bit & !running_bit)
        begin
            next_value <= initial_value;
        end
        else if(((state == DATA_STATE) || (state == EOP_STATE)) && aso_src0_valid && aso_src0_ready)
        begin
            next_value <= ((((next_value << 5) & 32'hFFFFFFE0) | ((next_value >> 27) & 32'h0000001F)) + 32'h33557799);
        end
    end
end

//
// byte_count state machine
//
// this state machine counts the number of bytes that have been transmitted in
// current packet.
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        byte_count  <= 0;
    end
    else
    begin
        case(state)
            IDLE_STATE:
            begin
                byte_count  <= 0;
            end
            SOP_STATE:
            begin
                byte_count  <= 2;
            end
            DATA_STATE:
            begin
                if(aso_src0_valid && aso_src0_ready)
                begin
                    byte_count  <= byte_count + 4;
                end
            end
            EOP_STATE:
            begin
                byte_count  <= 0;
            end
        endcase
    end
end

//
// packet_sequence_number state machine
//
// the sequence always starts at ZERO and increments once we've transmitted the
// first word of each packet.
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        packet_sequence_number  <= 0;
    end
    else
    begin
        if(!running_bit)
        begin
            packet_sequence_number  <= 0;
        end
        else if((state == SOP_STATE) && aso_src0_valid && aso_src0_ready)
        begin
            packet_sequence_number  <= packet_sequence_number + 1;
        end
    end
end

//
// source interface control
//
// these are combinatorial control equations for our source interface
//
assign empty_symbols            =   byte_count - payload_prbs_byte_count;

assign aso_src0_valid           =   running_bit;

assign aso_src0_data            =   (state == SOP_STATE) ? ({payload_prbs_byte_count, packet_sequence_number[7:0], packet_sequence_number[15:8]}) :
                                    (next_value);

assign aso_src0_empty           =   (state == EOP_STATE) ? (empty_symbols[1:0]) : 
                                    ((state == SOP_STATE) && (payload_prbs_byte_count < 1)) ? (2'h2) : 
                                    ((state == SOP_STATE) && (payload_prbs_byte_count < 2)) ? (2'h1) : (2'h0);

assign aso_src0_startofpacket   =   (state == SOP_STATE) ? (1'b1) : (1'b0);

assign aso_src0_endofpacket     =   (state == EOP_STATE) ? (1'b1) : 
                                    ((state == SOP_STATE) && (payload_prbs_byte_count < 3)) ? (1'b1) : (1'b0);

//
// source state machine
//
// this state machine provides synchronous sequencing for the control of the
// source interface
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset)
    begin
        state <= IDLE_STATE;
    end
    else
    begin
        case(state)
            IDLE_STATE:
            begin
                if(go_bit)
                begin
                    state <= SOP_STATE;
                end
            end
            SOP_STATE:
            begin
                if((payload_prbs_byte_count < 3) && go_bit && aso_src0_valid && aso_src0_ready)
                begin
                    state <= SOP_STATE;
                end
                else if((payload_prbs_byte_count > 6) && aso_src0_valid && aso_src0_ready)
                begin
                    state <= DATA_STATE;
                end
                else if((payload_prbs_byte_count < 7) && (payload_prbs_byte_count > 2) && aso_src0_valid && aso_src0_ready)
                begin
                    state <= EOP_STATE;
                end
                else if((payload_prbs_byte_count < 3) && !go_bit && aso_src0_valid && aso_src0_ready)
                begin
                    state <= IDLE_STATE;
                end
            end
            DATA_STATE:
            begin
                if(((byte_count + 8) >= payload_prbs_byte_count) && aso_src0_valid && aso_src0_ready)
                begin
                    state <= EOP_STATE;
                end
            end
            EOP_STATE:
            begin
                if(go_bit && aso_src0_valid && aso_src0_ready)
                begin
                    state <= SOP_STATE;
                end
                else if(!go_bit && aso_src0_valid && aso_src0_ready)
                begin
                    state <= IDLE_STATE;
                end
            end
        endcase
    end
end

endmodule
