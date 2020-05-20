`default_nettype none
`include "interface_defs.v"

module convert_from_atlantic_interface_to_avalon_st_sink
(
avalon_st_32_bit_packet_interface  avalon_st_packet_to_sink,
atlantic_32_bit_packet_interface   atlantic_packet,
input override_avalon_st_ready,
input reset_n
);

(* keep = 1 *) reg [12:0] state = 0;

parameter prev_rx_adr_DEFAULT =  8'h12; //random value; try to not lose first packet with index 00; better way would be to  explicitly ignore test for first time
parameter synchronizer_depth = 3;

wire controlled_atlantic_enable;
wire controlled_avalon_valid;

parameter idle               = 12'b0000_0000_0000;
parameter wait_for_rx_dav    = 12'b0000_0000_0001;
parameter init_fake_enable   = 12'b0000_0001_0010;
parameter wait_for_rx_valid  = 12'b0000_0000_0011;
parameter set_avalon_valid   = 12'b0000_0010_0100;

assign controlled_atlantic_enable = state[4];
assign controlled_avalon_valid    = state[5];

assign atlantic_packet.clk = avalon_st_packet_to_sink.clk;
assign atlantic_packet.ena = controlled_atlantic_enable || override_avalon_st_ready;
assign avalon_st_packet_to_sink.valid = controlled_avalon_valid; 

(* keep = 1 *) reg [7:0] prev_rx_adr = prev_rx_adr_DEFAULT; 
(* keep = 1 *) reg is_first_time = 1;

wire actual_reset_n;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_reset
(
.indata(reset_n),
.outdata(actual_reset_n),
.clk(atlantic_packet.clk)
);
	

always @(posedge atlantic_packet.clk or negedge actual_reset_n)
begin
      if (!actual_reset_n)
	  begin
	       state <= idle;	  
	  end else
	  begin
	        case (state)
			idle            : state <= wait_for_rx_dav;
			wait_for_rx_dav : if (atlantic_packet.dav)
			                  begin
			                       state <= init_fake_enable;
							  end
			init_fake_enable : state <= wait_for_rx_valid;
			wait_for_rx_valid : if (atlantic_packet.val)
			                    begin
								      if ((prev_rx_adr != atlantic_packet.adr) || is_first_time)
									  begin
								           state <= set_avalon_valid; //set valid for avalon st to consume packet
									  end else
									  begin
									          if (atlantic_packet.dav)
											  begin
												   state <= init_fake_enable;
											  end else
											  begin												
									        state <= wait_for_rx_dav; //we've already seen this packet; skip it
									  end
								end
								end
			set_avalon_valid : if (avalon_st_packet_to_sink.ready)
			                   begin
							           if (atlantic_packet.dav)
									   begin
									      state <= init_fake_enable;
									   end else
									   begin												
									      state <= wait_for_rx_dav; //we've already seen this packet; skip it
							   end		
							   end		
			endcase	  	  
	  end
end

always @(posedge atlantic_packet.clk or negedge actual_reset_n)
begin
     if (!actual_reset_n)
	 begin
	       prev_rx_adr <= prev_rx_adr_DEFAULT; 
		   is_first_time <= 1;
	 end
	 else
     begin	 
		 if (avalon_st_packet_to_sink.ready && controlled_avalon_valid)
		 begin
			   prev_rx_adr <= atlantic_packet.adr; //if a confirmed packet consumption by the st interface has occurred, record this packet address
			   is_first_time <= 0; //we are not in kansas anymore
		 end
	 end
end

always @(posedge atlantic_packet.clk)
begin
      if (atlantic_packet.val)
	  begin
	        avalon_st_packet_to_sink.data   <= atlantic_packet.dat;	  
			avalon_st_packet_to_sink.sop    <= atlantic_packet.sop;
			avalon_st_packet_to_sink.eop    <= atlantic_packet.eop;
			avalon_st_packet_to_sink.empty  <= atlantic_packet.mty;
			avalon_st_packet_to_sink.error  <= atlantic_packet.err;
	  end	  
end
	
endmodule
