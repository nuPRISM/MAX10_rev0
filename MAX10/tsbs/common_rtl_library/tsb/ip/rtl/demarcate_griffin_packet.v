
module demarcate_griffin_packet
#(
parameter SOP_Marker = 32'h08000000,
parameter SOP_Mask   = 32'hFF000000,
parameter EOP_Marker = 32'h0E000000,
parameter EOP_Mask   = 32'hFF000000,
parameter numbits = 32

)
(
input  [numbits-1:0] indata,
output logic [numbits-1:0] outdata,
output valid,
output startofpacket,
output endofpacket,
input clk,
input transpose_input,
input transpose_output,
input enable,
input reset,
output reg found_sop = 0,
output reg found_eop = 0,
output reg [11:0] state = 0,
output [numbits-1:0] possibly_transposed_indata
)

parameter idle                            = 12'b0000_0000_0000;
parameter waiting_for_start_of_packet     = 12'b0000_0000_0001;
parameter currently_inside_packet         = 12'b0000_0001_0011;
parameter found_end_of_packet             = 12'b0000_0001_0100;

assign startofpacket = found_sop;
assign endofpacket   = found_eop;

assign valid = state[4];

registered_controlled_transpose
#(
numbits(numbits)
)
input_controlled_transpose
(
.indata(indata),
.outdata(possibly_transposed_indata),
.clk(clk),
.transpose(transpose_input)
);

//the output transposition is necessary for delay matching and also in case Avalon ST wants the bits in reverse position
registered_controlled_transpose
#(
numbits(numbits)
)
output_controlled_transpose
(
.indata(possibly_transposed_indata),
.outdata(outdata),
.clk(clk),
.transpose(transpose_input)
);


always @(posedge clk or posedge reset)
begin
      if (reset)
	  begin
	        found_eop <= 0;
	  end else
	  begin
	       if ((possibly_transposed_indata & EOP_Mask) ==  EOP_Marker)
		   begin
                found_eop <= 1;
		   end else 
		   begin
		        found_eop <= 0;
		   end
	  end
end


always @(posedge clk or posedge reset)
begin
      if (reset)
	  begin
	        found_sop <= 0;
	  end else
	  begin
	       if ((possibly_transposed_indata & SOP_Mask) ==  SOP_Marker)
		   begin
                found_sop <= 1;
		   end else 
		   begin
		        found_sop <= 0;
		   end
	  end
end



always @(posedge clk or posedge reset)
begin
      if (reset)
	  begin
	        state <= idle;
	  end else
	  begin
	       case (state)
		   idle                        : if (enable) 
		                                 begin
										      state <= waiting_for_start_of_packed;		   		   
										 end 
										 
		   waiting_for_start_of_packet : if (found_sop)
		                                 begin
										      state <= currently_inside_packet;
										 end else
										 begin
										     state <= waiting_for_start_of_packed;
										 end
		   currently_inside_packet     : if (found_eop)
                                         begin
      										 state <= currently_inside_packet; 
										 end
										 
           found_end_of_packet         : state <= waiting_for_start_of_packet;
           endcase
      end
end

endmodule


