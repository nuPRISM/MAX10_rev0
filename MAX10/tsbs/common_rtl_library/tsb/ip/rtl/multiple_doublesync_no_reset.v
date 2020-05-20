`default_nettype none
module multiple_doublesync_no_reset (indata,
				  outdata,
				  clk);

parameter N = 	1;			  
parameter synchronizer_depth = 2;
parameter CUT_TIMING_TO_INPUT = 0;
input indata[N];
input clk;
output outdata[N];

genvar n;
generate 
     for (n = 0; n < N; n++)
	 begin : instantiate_doublesync
    `ifdef SOFTWARE_IS_QUARTUS
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
											  .din (indata[n]),
											  .dout (outdata[n]),
											  .reset_n (1'b1)
											);
											defparam the_altera_std_synchronizer.depth = synchronizer_depth;

									 end else
									 begin
											 
											 my_altera_std_synchronizer_nocut 
											 the_altera_std_synchronizer
											 (
											  .clk (clk),
											  .din (indata[n]),
											  .dout (outdata[n]),
											  .reset_n (1'b1)
											);
											defparam the_altera_std_synchronizer.depth = synchronizer_depth;
									end
							
			`else
								//special coding for SRL16 inference in Xilinx devices
								reg [synchronizer_depth-1:0] sync_srl16_inferred;
								   always @(posedge clk)
										 sync_srl16_inferred[synchronizer_depth-1:0] <= {sync_srl16_inferred[synchronizer_depth-2:0], indata[n]};
											
								assign outdata[n] = sync_srl16_inferred[synchronizer_depth-1];
												
			`endif
		end
endgenerate

endmodule
`default_nettype wire