`default_nettype none
module avsoc_maxv_command_receiver(
    output [29:0] flash_addr_request,
	input [15:0] received_data_from_flash,
	output [7:0] current_returned_data_byte,    
	input [2:0]  current_register_index,
    input        latch_now,
	input   dir,
    input [5:0]  data_from_arria_v,
	output reg [5:0] address_reg [8] //locations 5, 6, 7 are minimized
);


genvar i;
generate
			for (i = 0; i < 5; i++)
			begin : generate_addr_registers
						always_ff @(posedge latch_now)
						begin
							  if (dir)
							  begin
								   if (current_register_index == i)
								   begin
										address_reg[i] <= data_from_arria_v;
								   end
							  end
						end
			end
endgenerate

assign flash_addr_request = {address_reg[4],address_reg[3],address_reg[2],address_reg[1],address_reg[0]};

assign current_returned_data_byte = (current_register_index == 0) ? received_data_from_flash[7:0] : received_data_from_flash[15:8];

endmodule
`default_nettype wire


