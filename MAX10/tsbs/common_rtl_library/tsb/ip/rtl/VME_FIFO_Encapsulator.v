
module VME_FIFO_Encapsulator
#(
parameter [15:0] VME_FIFO_CAPTURE_FIFO_WIDTH = 16,
parameter [15:0] VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT = 12
)
(
input  [VME_FIFO_CAPTURE_FIFO_WIDTH-1:0] wrdata_to_the_VME_FIFO,
input  wrclk_to_the_VME_FIFO,
output [31:0] VME_FIFO_Flags,
input  [7:0] VME_FIFO_Control,
output [31:0] VME_FIFO_data_out
);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     FIFO Encapsulator
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	
   wire  [VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT-1:0] wrusedw_from_the_VME_FIFO;
   	wire  rdempty_from_the_VME_FIFO;
   	wire  rdfull_from_the_VME_FIFO;
   	wire  wrempty_from_the_VME_FIFO;
   	wire  wrfull_from_the_VME_FIFO;
   	wire  wrreq_to_the_VME_FIFO;
	
    wire rdclk_to_the_VME_FIFO;
	
	wire rdreq_to_the_VME_FIFO;
	
	wire wrreq_to_the_VME_FIFO_raw = VME_FIFO_Control[0];
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_wrreq_to_the_VME_FIFO_raw
	(
	.indata(wrreq_to_the_VME_FIFO_raw),
	.outdata(wrreq_to_the_VME_FIFO),
	.clk(wrclk_to_the_VME_FIFO)
	);
	
	assign rdreq_to_the_VME_FIFO = VME_FIFO_Control[1];
	assign rdclk_to_the_VME_FIFO = VME_FIFO_Control[4];

	
	DEAP_ADC_TO_VME_FIFO	
	VME_FIFO_inst (
	.data ( wrdata_to_the_VME_FIFO ),
	.rdclk ( rdclk_to_the_VME_FIFO ),
	.rdreq ( rdreq_to_the_VME_FIFO ),
	.wrclk ( wrclk_to_the_VME_FIFO ),
	.wrreq ( wrreq_to_the_VME_FIFO ),
	.q ( VME_FIFO_data_out ),
	.rdempty ( rdempty_from_the_VME_FIFO ),
	.rdfull ( rdfull_from_the_VME_FIFO ),
	.wrempty ( wrempty_from_the_VME_FIFO ),
	.wrfull ( wrfull_from_the_VME_FIFO ),
	.wrusedw ( wrusedw_from_the_VME_FIFO )
	);
	
	
   
		
	assign VME_FIFO_Flags = {
	                              3'b0,rdempty_from_the_VME_FIFO, 
	                              3'b0,rdfull_from_the_VME_FIFO, 
								  3'b0,wrempty_from_the_VME_FIFO, 
								  3'b0,wrfull_from_the_VME_FIFO, 
								  {{(16-VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT){1'b0}},
								  wrusedw_from_the_VME_FIFO}
							};
	

	
endmodule
	