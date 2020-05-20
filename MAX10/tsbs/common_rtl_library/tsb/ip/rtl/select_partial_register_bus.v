module select_partial_register_bus
#(
  parameter width = 8
  )
 (
  input [width-1:0] indata,
  output [width-1:0] outdata,
  input [width-1:0] number_of_bits_to_output,
  output wire [width-1:0] outdata_raw[width-1:0]
  );
               
			   
  genvar i;
  generate           
           for (i = 0; i < width; i++)
		     begin : out_data_generation
			    if (i==0)
				begin
				     assign outdata_raw[i] = indata;
				end else
				begin
                     assign outdata_raw[i] = indata[i-1:0];
			    end
		    end
 endgenerate
 
 assign outdata = outdata_raw[number_of_bits_to_output];
 
 endmodule
 