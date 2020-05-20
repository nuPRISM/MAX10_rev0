`default_nettype none
module doublesync_no_reset (indata,
				  outdata,
				  clk);

parameter synchronizer_depth = 2;
parameter CUT_TIMING_TO_INPUT = 0;
input indata,clk;
output outdata;


    `ifdef SOFTWARE_IS_QUARTUS
	   generate
	                         `ifdef CUT_ALL_TIMING_PATHS_TO_DOUBLESYNCS
                             if (1)
                             `else							 
	                         if (CUT_TIMING_TO_INPUT)
							 `endif
							 begin							 
									 altera_std_synchronizer 
									 the_altera_std_synchronizer
									 (
									  .clk (clk),
									  .din (indata),
									  .dout (outdata),
									  .reset_n (1'b1)
									);
									defparam the_altera_std_synchronizer.depth = synchronizer_depth;

							 end else
							 begin
									 
									 my_altera_std_synchronizer_nocut 
									 the_altera_std_synchronizer
									 (
									  .clk (clk),
									  .din (indata),
									  .dout (outdata),
									  .reset_n (1'b1)
									);
									defparam the_altera_std_synchronizer.depth = synchronizer_depth;
						    end
		endgenerate
					
	`else
						//special coding for SRL16 inference in Xilinx devices
						reg [synchronizer_depth-1:0] sync_srl16_inferred;
						   always @(posedge clk)
								 sync_srl16_inferred[synchronizer_depth-1:0] <= {sync_srl16_inferred[synchronizer_depth-2:0], indata};
									
						assign outdata = sync_srl16_inferred[synchronizer_depth-1];
										
	`endif


endmodule
`default_nettype wire