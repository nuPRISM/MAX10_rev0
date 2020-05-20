//
//	udp_payload_extractor
//
//	This component extracts the UDP payload out of an Ethernet packet and
//	forwards it in a RAW proprietary packet format.  This component assumes
//	that the input packet is a valid UDP packet within an Ethernet frame.
//	The input and output for the packet data thru this component are provided
//	by an Avalon ST sink and source interface.  Status information is collected
//	thru an Avalon MM slave interface.
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
//  Proprietary RAW Output Packet Layout
//  |-------------------------------------------------------|
//  |       Packet Length       |                           |
//  |----------------------------                           |
//  |                                                       |
//  |                    Packet Payload                     |
//  |                                                       |
//  |-------------------------------------------------------|
//
//  The general payload extraction flows like this:
//  
//	This component begins by receiving the Ethenet packet on its Avalon ST
//	interface.  It is assumed that the Ethernet packet contains a valid UDP
//	packet that we wish to extract the payload from.  This component assumes
//	that the Ethernet MAC header is the first 14 bytes, followed by a standard
//	IP header of 20 bytes, followed by a standard UDP header of 8 bytes.  If
//	the packet format does not follow these assumptions, then it should not be
//	sent into this component.  This component will discard all of the protocol
//	headers until it gets to the UDP Message Length field, where it will read
//	the length value and use that to create the length field of the RAW output
//	packet that it creates for the UDP payload.  Once the payload length is
//	known, this component will create a RAW output packet that has the length
//	of the RAW packet payload as its first two bytes, followed by the UDP
//	payload from the input packet.
//
//	The RAW output packet will only contain the number of bytes indicated in
//	the UDP header for its payload.  Any Ethernet payload pad bytes as well as
//	the Frame Check Sequence will be discarded.
//
//  ---------------------------------------------------------------------------
//  Register Map
//  ---------------------------------------------------------------------------
//  
//  The slave interface for the udp_payload_extractor contains one 32-bit
//	register with the following layout:
//  
//  Register 0 - Packet Count Register
//      Bits [31:0] - R/WC - this is the number of packets that have been
//                  processed since the last reset or clearing of this register.
//                  
//  R - Readable
//  W - Writeable
//  WC - Clear on Write
//

module udp_payload_extractor
(
	// clock interface
	input 			csi_clock_clk,
	input 			csi_clock_reset,
	
	// slave interface
	input			avs_s0_write,
	input			avs_s0_read,
	input	[3:0]	avs_s0_byteenable,
	input	[31:0]	avs_s0_writedata,
	output	[31:0]	avs_s0_readdata,
	
	// source interface
	output				aso_src0_valid,
	input				aso_src0_ready,
	output	reg	[31:0]	aso_src0_data,
	output	reg	[1:0]	aso_src0_empty,
	output	reg			aso_src0_startofpacket,
	output	reg			aso_src0_endofpacket,
	
	// sink interface
	input			asi_snk0_valid,
	output			asi_snk0_ready,
	input	[31:0]	asi_snk0_data,
	input	[1:0]	asi_snk0_empty,
	input			asi_snk0_startofpacket,
	input			asi_snk0_endofpacket
);

localparam [4:0] STATE_PW_0		= 5'd0;
localparam [4:0] STATE_PW_1		= 5'd1;
localparam [4:0] STATE_PW_2		= 5'd2;
localparam [4:0] STATE_PW_3		= 5'd3;
localparam [4:0] STATE_PW_4		= 5'd4;
localparam [4:0] STATE_PW_5		= 5'd5;
localparam [4:0] STATE_PW_6		= 5'd6;
localparam [4:0] STATE_PW_7		= 5'd7;
localparam [4:0] STATE_PW_8		= 5'd8;
localparam [4:0] STATE_PW_9		= 5'd9;
localparam [4:0] STATE_PW_10	= 5'd10;
localparam [4:0] STATE_PW_11	= 5'd11;
localparam [4:0] STATE_PW_12	= 5'd12;
localparam [4:0] STATE_PW_13	= 5'd13;
localparam [4:0] STATE_PW_14	= 5'd14;
localparam [4:0] STATE_PW_N		= 5'd15;

reg		[15:0]	raw_length;
reg		[15:0]	byte_count;
reg		[4:0]	state;
reg		[15:0]	first_two_bytes;
reg		[31:0]	sink_data;
reg				count_packet;
reg				clear_packet_count;
reg		[31:0]	packet_count;
wire			sink_cycle;
wire	[15:0]	empty_calc;

wire			pipe_src0_ready;
wire			pipe_src0_valid;
wire	[31:0]	pipe_src0_data;
wire			pipe_src0_startofpacket;
wire			pipe_src0_endofpacket;
wire	[1:0]	pipe_src0_empty;
reg		[35:0]	in_payload;
wire	[35:0]	out_payload;

//
// misc computations
//
assign empty_calc = byte_count - raw_length;

//
// packet transmit state machine
//
assign pipe_src0_data =	(state == STATE_PW_11) ? ({raw_length, first_two_bytes}) : (sink_data);

assign pipe_src0_valid =	(state == STATE_PW_11) ? (pipe_src0_ready & asi_snk0_valid) :
						((state > STATE_PW_11) && ((raw_length + 4) > byte_count)) ? (pipe_src0_ready & asi_snk0_valid) :
						(1'b0);
						
assign pipe_src0_empty =	(raw_length > byte_count) ? (2'h0) : (empty_calc[1:0]);

assign pipe_src0_startofpacket = (state == STATE_PW_11);

assign pipe_src0_endofpacket =	((state >= STATE_PW_11) && (raw_length <= byte_count)) ? (1'b1) :
								(1'b0);

assign asi_snk0_ready =	((state >= STATE_PW_0) && (state < STATE_PW_11)) ? (1'b1) :
						((state >= STATE_PW_11) && ((raw_length + 4) > byte_count)) ? (pipe_src0_valid) :
						((state >= STATE_PW_11) && ((raw_length + 4) <= byte_count)) ? (1'b1) :
						(1'b0);

assign sink_cycle = asi_snk0_valid & asi_snk0_ready;

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
	if(csi_clock_reset)
	begin
		state			<= STATE_PW_0;
		sink_data		<= 0;
		count_packet	<= 0;
		raw_length		<= 0;
		byte_count		<= 0;
	end
	else
	begin
		case(state)
		STATE_PW_0:
		begin
			count_packet	<= 1'b0;
		
			if(sink_cycle)
			begin
				state <= STATE_PW_1;
			end
		end
		STATE_PW_1:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_2;
			end
		end
		STATE_PW_2:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_3;
			end
		end
		STATE_PW_3:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_4;
			end
		end
		STATE_PW_4:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_5;
			end
		end
		STATE_PW_5:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_6;
			end
		end
		STATE_PW_6:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_7;
			end
		end
		STATE_PW_7:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_8;
			end
		end
		STATE_PW_8:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_9;
			end
		end
		STATE_PW_9:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_10;

				// udp_length field, subtract off the udp header length
				raw_length	<= (asi_snk0_data[15:0] >= 8) ? (asi_snk0_data[15:0] - 8) : (0);
			end
		end
		STATE_PW_10:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_11;
				
				first_two_bytes	<= asi_snk0_data[15:0];
				byte_count		<= 2;
			end
		end
		STATE_PW_11:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_12;
				
				sink_data	<= asi_snk0_data;
				byte_count	<= byte_count + 4;
			end
		end
		STATE_PW_12:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_13;
				
				sink_data	<= asi_snk0_data;
				byte_count	<= byte_count + 4;
			end
		end
		STATE_PW_13:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_14;
				
				sink_data	<= asi_snk0_data;
				byte_count	<= byte_count + 4;
			end
		end
		STATE_PW_14:
		begin
			if(sink_cycle)
			begin
				state <= STATE_PW_N;
					
				sink_data	<= asi_snk0_data;
				byte_count	<= byte_count + 4;
			end
		end
		STATE_PW_N:
		begin
			if(sink_cycle)
			begin
				if(asi_snk0_endofpacket)
				begin
					state			<= STATE_PW_0;
					count_packet	<= 1'b1;
				end
				else
				begin
					sink_data	<= asi_snk0_data;
					byte_count	<= byte_count + 4;
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
		packet_count	<= 0;
	end
	else if(clear_packet_count)
	begin
		packet_count	<= 0;
	end
	else if(count_packet)
	begin
		packet_count	<= packet_count + 1;
	end
end

//
// slave interface machine
//
assign avs_s0_readdata	= packet_count;

always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
	if(csi_clock_reset)
	begin
		clear_packet_count <= 0;
	end
	else if(avs_s0_write)
	begin
		clear_packet_count <= 1;
	end
	else
	begin
		clear_packet_count <= 0;
	end
end

//
// output Pipeline
//
udp_payload_extractor_1stage_pipeline #( .PAYLOAD_WIDTH( 36 ) ) outpipe (
	.clk			(csi_clock_clk ),
	.reset_n		(~csi_clock_reset),
	.in_ready		(pipe_src0_ready),
	.in_valid		(pipe_src0_valid), 
	.in_payload		(in_payload),
	.out_ready		(aso_src0_ready), 
	.out_valid		(aso_src0_valid), 
	.out_payload	(out_payload)
);

//
// Output Mapping
//
always @* begin
	in_payload <= {pipe_src0_data, pipe_src0_startofpacket, pipe_src0_endofpacket, pipe_src0_empty};
	{aso_src0_data, aso_src0_startofpacket, aso_src0_endofpacket, aso_src0_empty} <= out_payload;
end

endmodule

//  --------------------------------------------------------------------------------
// | single buffered pipeline stage
//  --------------------------------------------------------------------------------
module udp_payload_extractor_1stage_pipeline  
#( parameter PAYLOAD_WIDTH = 8 )
 ( input                          clk,
   input                          reset_n, 
   output reg                     in_ready,
   input                          in_valid,   
   input      [PAYLOAD_WIDTH-1:0] in_payload,
   input                          out_ready,   
   output reg                     out_valid,
   output reg [PAYLOAD_WIDTH-1:0] out_payload      
 );
      
   always @* begin
     in_ready <= out_ready || ~out_valid;
   end
   
   always @ (negedge reset_n, posedge clk) begin
      if (!reset_n) begin
         out_valid <= 0;
         out_payload <= 0;
      end else begin
         if (in_valid) begin
           out_valid <= 1;
         end else if (out_ready) begin
           out_valid <= 0;
         end
         
         if(in_valid && in_ready) begin
            out_payload <= in_payload;
         end
      end
   end

endmodule
