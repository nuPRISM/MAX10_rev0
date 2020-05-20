`default_nettype none
module multidevice_mcs_to_wishbone
#(
  parameter numdevices = 1
)
(
input wire clk,
input wire reset,
input wire  IO_Addr_Strobe                               ,
input wire  IO_Read_Strobe                               ,
input wire  IO_Write_Strobe                              ,
input wire  [31 : 0] IO_Address                          ,
input wire  [3 : 0]  IO_Byte_Enable                       ,
input wire  [31 : 0] IO_Write_Data                       ,
output logic [31 : 0] IO_Read_Data                       ,
input wire  [31:0]   Peripheral_Address[numdevices-1:0]     ,
input wire  [31:0]   Peripheral_Address_Mask[numdevices-1:0],
output logic  IO_Ready                                    ,

output wire wb_clk_i        [numdevices-1:0],
output wire wb_rst_i        [numdevices-1:0],
output wire [31:0]  wb_adr_i[numdevices-1:0],
output wire [31:0]  wb_dat_i[numdevices-1:0],
input  wire [31:0]  wb_dat_o[numdevices-1:0],
output wire [3:0]   wb_sel_i[numdevices-1:0],
output wire wb_we_i         [numdevices-1:0],
output wire wb_stb_i        [numdevices-1:0],
output wire wb_cyc_i        [numdevices-1:0],
input  wire wb_ack_o        [numdevices-1:0],
input  wire wb_err_o        [numdevices-1:0],
input  wire wb_int_o        [numdevices-1:0]
);


reg [31:0] internal_IO_Address;
reg [31:0] internal_IO_Byte_Enable;
reg [31:0] internal_IO_Write_Data;
reg        is_write;
reg        is_read;
reg        is_for_peripheral[numdevices-1:0];
reg        last_device_was_this_peripheral[numdevices-1:0];
logic        is_for_peripheral_raw[numdevices-1:0];

wire [numdevices-1:0] device_is_ready_array;
wire [numdevices-1:0] controlled_data_from_device[31:0] ;
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


genvar current_device;
genvar i;
generate
          for (current_device =0; current_device < numdevices; current_device++)
		  begin : assign_current_device_vals		            
					//assign device_is_ready_array[current_device] =  (wb_ack_o[current_device] &  is_for_peripheral[current_device]);
					assign device_is_ready_array[current_device] =  wb_ack_o[current_device];					
					
					for (i = 0; i < 32; i++)
					begin : set_controlled_data_from_device
						   assign controlled_data_from_device[i][current_device] = wb_dat_o[current_device][i] & last_device_was_this_peripheral[current_device];
					end
										
		            assign is_for_peripheral_raw[current_device] = &((IO_Address & Peripheral_Address_Mask[current_device]) == (Peripheral_Address[current_device] & Peripheral_Address_Mask[current_device]));
					
					always @(posedge clk)
					begin
						  if (IO_Addr_Strobe)
						  begin
								is_for_peripheral[current_device] <= is_for_peripheral_raw[current_device];
								last_device_was_this_peripheral[current_device] <= is_for_peripheral_raw[current_device];
						  end else
						  begin
							   if (wb_ack_o[current_device])
							   begin
									is_for_peripheral[current_device] <= 0;		   
							   end	  
						  end
						  					
					end


                    
                    assign wb_clk_i[current_device]            = clk;
                    assign wb_rst_i[current_device]            = reset;
                    assign wb_adr_i[current_device][31:0]      = internal_IO_Address[31:0];
                    assign wb_sel_i[current_device][3:0]       = internal_IO_Byte_Enable[3:0];
                    assign wb_dat_i[current_device][31:0]      = internal_IO_Write_Data[31:0];
                    assign wb_cyc_i[current_device]            = is_for_peripheral[current_device];
                    assign wb_stb_i[current_device]            = is_for_peripheral[current_device];
                    assign wb_we_i [current_device]            = is_write;
					
					
		end
endgenerate


genvar j;
generate
       for (j = 0;  j< 32; j++)
	   begin : make_IO_Read_Data
              assign IO_Read_Data[j] = |controlled_data_from_device[j];
       end	   
endgenerate

assign IO_Ready            = |device_is_ready_array;

endmodule
