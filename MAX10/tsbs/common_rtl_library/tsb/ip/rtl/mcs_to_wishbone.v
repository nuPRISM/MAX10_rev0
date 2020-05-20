`default_nettype none
module mcs_to_wishbone
(
input wire clk,
input wire reset,
input wire  IO_Addr_Strobe               ,
input wire  IO_Read_Strobe               ,
input wire  IO_Write_Strobe              ,
input wire  [31 : 0] IO_Address          ,
input wire  [3 : 0] IO_Byte_Enable       ,
input wire  [31 : 0] IO_Write_Data       ,
output wire  [31 : 0] IO_Read_Data       ,
input wire [31:0] Peripheral_Address     ,
input wire [31:0] Peripheral_Address_Mask,
output wire  IO_Ready                    ,

output wire wb_clk_i,
output wire wb_rst_i,
output wire [31:0]  wb_adr_i,
output  wire [31:0] wb_dat_i,
input wire [31:0] wb_dat_o,
output wire [3:0]  wb_sel_i,
output wire wb_we_i ,
output wire wb_stb_i,
output wire wb_cyc_i,
input  wire wb_ack_o,
input  wire wb_err_o,
input  wire wb_int_o

);


reg [31:0] internal_IO_Address;
reg [31:0] internal_IO_Byte_Enable;
reg [31:0] internal_IO_Write_Data;
reg        is_write;
reg        is_read;
reg        is_for_peripheral;

always @(posedge clk)
begin
      if (IO_Addr_Strobe)
	  begin
	        internal_IO_Address     <= IO_Address;
	        internal_IO_Byte_Enable <= IO_Byte_Enable;
	        internal_IO_Write_Data  <= IO_Write_Data;
            is_write                <= IO_Write_Strobe;
            is_read                 <= IO_Read_Strobe;
	  end
end

always @(posedge clk)
begin
      if (IO_Addr_Strobe)
	  begin
			is_for_peripheral <= &((IO_Address & Peripheral_Address_Mask) == (Peripheral_Address & Peripheral_Address_Mask));
	  end else
	  begin
	       if (wb_ack_o)
		   begin
		        is_for_peripheral <= 0;		   
		   end	  
	  end
end

assign wb_clk_i            = clk;
assign wb_rst_i            = reset;
assign wb_adr_i[31:0]      = internal_IO_Address[31:0];
assign wb_sel_i[3:0]       = internal_IO_Byte_Enable[3:0];
assign IO_Read_Data[31:0]  = wb_dat_o[31:0];
assign wb_dat_i[31:0]      = internal_IO_Write_Data[31:0];
assign IO_Ready            = wb_ack_o;
assign wb_cyc_i            = is_for_peripheral;
assign wb_stb_i            = is_for_peripheral;
assign wb_we_i             = is_write;



endmodule