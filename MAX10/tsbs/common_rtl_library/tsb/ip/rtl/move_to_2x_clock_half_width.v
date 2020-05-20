`default_nettype none
module move_to_2x_clock_half_width
#(
parameter assign_outdata_clk = 1
)
(
interface indata,
interface outdata,
input invert_superframe_start,
input transpose_input_data_halves ,
input transpose_output_data_halves,
input clk_2x
);

generate
		if (assign_outdata_clk)
		begin
			 assign outdata.clk = clk_2x;
		end
endgenerate

logic outclk;
logic inclk;
assign inclk =  indata.clk;
assign outclk = outdata.clk;

logic synced_transpose_input_data_halves;
logic synced_transpose_output_data_halves;
logic synced_invert_superframe_start;

doublesync_no_reset
sync_transpose_input_data_halves
   (.indata (transpose_input_data_halves),
   .outdata(synced_transpose_input_data_halves),
   .clk    (inclk)
);

doublesync_no_reset
sync_transpose_output_data_halves
   (.indata (transpose_output_data_halves),
   .outdata(synced_transpose_output_data_halves),
   .clk    (outclk)
);

doublesync_no_reset
sync_invert_superframe_start
   (.indata (invert_superframe_start),
   .outdata(synced_invert_superframe_start),
   .clk    (outclk)
);

multi_data_stream_interface
#(
.num_data_streams    (indata.get_num_data_streams()    ),
.data_width          (indata.get_data_width()          ),
.num_description_bits(indata.get_num_description_bits())
) 
pipeline_stage_1(),pipeline_stage_2();

reg current_half = 0;

always_ff @(posedge inclk)
begin
      pipeline_stage_1.valid   <= indata.valid;
	  pipeline_stage_2.valid   <= pipeline_stage_1.valid;
end

assign pipeline_stage_1.clk     = inclk;
assign pipeline_stage_2.clk     = inclk;

always_ff @(posedge outclk)
begin
	  current_half  <= ~current_half;
      outdata.valid <= pipeline_stage_2.valid;	
	  outdata.superframe_start_n <= current_half^synced_invert_superframe_start;
end
								
genvar current_stream;
generate		
       for (current_stream = 0; current_stream < indata.get_num_data_streams(); current_stream++)
		 begin : pipeline
		      always_ff @(posedge inclk)
				begin
				        pipeline_stage_1.data[current_stream] <= indata.data[current_stream];

				        pipeline_stage_2.data[current_stream][indata.get_data_width()-1     : (indata.get_data_width()/2)] 
						                <= synced_transpose_input_data_halves ? pipeline_stage_1.data[current_stream][(indata.get_data_width()/2)-1 : 0] : pipeline_stage_1.data[current_stream][indata.get_data_width()-1 : (indata.get_data_width()/2)];
					    pipeline_stage_2.data[current_stream][(indata.get_data_width()/2) -1  : 0] 
						                <= synced_transpose_input_data_halves ? pipeline_stage_1.data[current_stream][indata.get_data_width()-1 : (indata.get_data_width()/2)] : pipeline_stage_1.data[current_stream][(indata.get_data_width()/2)-1 : 0];				       
				end
				
			    always_ff @(posedge outclk)
				begin
					  outdata.data[current_stream]  <= current_half^synced_transpose_output_data_halves ? pipeline_stage_2.data[current_stream][indata.get_data_width()-1 : (indata.get_data_width()/2)] : pipeline_stage_2.data[current_stream][(indata.get_data_width()/2) -1  : 0];
				end				
		 end
endgenerate    
 
endmodule
`default_nettype wire

