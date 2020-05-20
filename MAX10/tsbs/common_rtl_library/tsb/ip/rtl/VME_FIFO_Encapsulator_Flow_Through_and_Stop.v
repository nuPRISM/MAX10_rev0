module VME_FIFO_Encapsulator_Flow_Through_and_Stop
#(
parameter [15:0] VME_FIFO_CAPTURE_FIFO_WIDTH = 16,
parameter [15:0] VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT = 12,
parameter [VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT-1:0] AUTO_THRESH_CORRIDOR_WIDTH = 5,
parameter synchronizer_depth = 3
)
(
input  [VME_FIFO_CAPTURE_FIFO_WIDTH-1:0] wrdata_to_the_VME_FIFO,
input  wrclk_to_the_VME_FIFO,
output [31:0] VME_FIFO_Flags,
input  [7:0] VME_FIFO_Control,
output [31:0] VME_FIFO_data_out,
input  [VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT-1:0] threshold_for_auto_read_start,
input  select_external_control_of_VME_FIFOs,
input  trigger_mechanism_rdreq_to_the_VME_FIFO,
input  trigger_mechanism_rdclk_to_the_VME_FIFO,
input  trigger_mechanism_disable_wrclk,
input  trigger_mechanism_enable_feedthrough,
input  clear_fifo
);
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     FIFO Encapsulator
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	

    (* keep = 1, preserve = 1 *) wire  [VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT-1:0] wrusedw_from_the_VME_FIFO;
    (* keep = 1, preserve = 1 *) wire  [VME_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT-1:0] rdusedw_from_the_VME_FIFO;
   	(* keep = 1, preserve = 1 *) wire  rdempty_from_the_VME_FIFO;
   	(* keep = 1, preserve = 1 *) wire  rdfull_from_the_VME_FIFO;
   	(* keep = 1, preserve = 1 *) wire  wrempty_from_the_VME_FIFO;
   	(* keep = 1, preserve = 1 *) wire  wrfull_from_the_VME_FIFO;
   	(* keep = 1, preserve = 1 *) wire  wrreq_to_the_VME_FIFO;
	(* keep = 1, preserve = 1 *) wire  enable_feedthrough_synced_to_wr_clk;
	(* keep = 1, preserve = 1 *) wire  enable_feedthrough_synced_to_actual_read_clk;
	(* keep = 1, preserve = 1 *) wire  [VME_FIFO_CAPTURE_FIFO_WIDTH-1:0] actual_wrdata_to_the_VME_FIFO;
	(* keep = 1, preserve = 1 *) wire  [VME_FIFO_CAPTURE_FIFO_WIDTH-1:0] presync_wrdata_to_the_VME_FIFO;
	(* keep = 1, preserve = 1 *) wire actual_disable_wrclk;
	
	(* keep = 1, preserve = 1 *)wire enable_feedthrough;
	 (* keep = 1, preserve = 1 *)reg actual_rdreq_to_the_VME_FIFO = 0;
	 (* keep = 1, preserve = 1 *)reg currently_reading = 0;
	 (* keep = 1, preserve = 1 *)wire actual_wrreq_to_the_VME_FIFO;
	

	(* keep = 1, preserve = 1 *) wire actual_read_clk;
	(* keep = 1, preserve = 1 *) wire controlled_wrclk;
	(* keep = 1, preserve = 1 *) wire disable_wrclk;	
    (* keep = 1, preserve = 1 *) wire rdclk_to_the_VME_FIFO;	
	(* keep = 1, preserve = 1 *) wire rdreq_to_the_VME_FIFO;
	(* keep = 1, preserve = 1 *) wire wrreq_to_the_VME_FIFO_raw;
	
	
	
	always_ff @(negedge actual_read_clk or posedge clear_fifo)
	begin	
	      if (clear_fifo)
		  begin
		        currently_reading <= 0;
		  end else
		  begin
				  if (enable_feedthrough_synced_to_actual_read_clk)
				  begin
						  if (!currently_reading && (rdusedw_from_the_VME_FIFO >= threshold_for_auto_read_start)) 
						  begin
								currently_reading <= 1;
						  end else if (currently_reading && (rdusedw_from_the_VME_FIFO < threshold_for_auto_read_start - AUTO_THRESH_CORRIDOR_WIDTH)) 
						  begin
								 currently_reading <= 0;
						  end else 
						  begin
								 currently_reading <= currently_reading;
						  end
				  end else
				  begin
					   currently_reading <= 0;
				  end	
          end		  
	end	
			
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_wrreq_to_the_VME_FIFO_raw
	(
	.indata(wrreq_to_the_VME_FIFO_raw),
	.outdata(wrreq_to_the_VME_FIFO),
	.clk(wrclk_to_the_VME_FIFO)
	);
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_disable_wrclk
	(
	.indata(disable_wrclk),
	.outdata(actual_disable_wrclk),
	.clk(wrclk_to_the_VME_FIFO)
	);
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_enable_feedthrough
	(
	.indata(enable_feedthrough),
	.outdata(enable_feedthrough_synced_to_wr_clk),
	.clk(wrclk_to_the_VME_FIFO)
	);
	
	doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
	sync_enable_feedthrough_to_actual_read_clk
	(
	.indata(enable_feedthrough),
	.outdata(enable_feedthrough_synced_to_actual_read_clk),
	.clk(actual_read_clk)
	);
	
	always_ff @(posedge wrclk_to_the_VME_FIFO)
	begin 
	      presync_wrdata_to_the_VME_FIFO <= wrdata_to_the_VME_FIFO;
	end
	
	always_ff @(posedge controlled_wrclk)
	begin 
	      actual_wrdata_to_the_VME_FIFO <= presync_wrdata_to_the_VME_FIFO;
	end
	
	assign controlled_wrclk = (!wrclk_to_the_VME_FIFO) & (!actual_disable_wrclk);
		
	assign wrreq_to_the_VME_FIFO_raw  =                                    VME_FIFO_Control[0];
	assign rdreq_to_the_VME_FIFO = select_external_control_of_VME_FIFOs  ? VME_FIFO_Control[1] : trigger_mechanism_rdreq_to_the_VME_FIFO;
	assign rdclk_to_the_VME_FIFO = select_external_control_of_VME_FIFOs  ? VME_FIFO_Control[4] : trigger_mechanism_rdclk_to_the_VME_FIFO;
   assign disable_wrclk         = select_external_control_of_VME_FIFOs  ? VME_FIFO_Control[6] : trigger_mechanism_disable_wrclk;
	assign enable_feedthrough    = select_external_control_of_VME_FIFOs  ? VME_FIFO_Control[7] : trigger_mechanism_enable_feedthrough;
	
	assign actual_rdreq_to_the_VME_FIFO = enable_feedthrough_synced_to_actual_read_clk ? currently_reading : rdreq_to_the_VME_FIFO;
	
	assign actual_wrreq_to_the_VME_FIFO = enable_feedthrough_synced_to_wr_clk ? 1'b1 : wrreq_to_the_VME_FIFO;
		
	assign actual_read_clk = enable_feedthrough ? controlled_wrclk : rdclk_to_the_VME_FIFO ;	
	
	DEAP_ADC_TO_VME_FIFO	
	VME_FIFO_inst (
	.aclr ( clear_fifo ),
	.data ( actual_wrdata_to_the_VME_FIFO ),
	.rdclk ( actual_read_clk   ),
	.rdreq ( actual_rdreq_to_the_VME_FIFO ),
	.wrclk ( controlled_wrclk ),
	.wrreq ( actual_wrreq_to_the_VME_FIFO ),
	.q ( VME_FIFO_data_out ),
	.rdempty ( rdempty_from_the_VME_FIFO ),
	.rdfull ( rdfull_from_the_VME_FIFO ),
	.wrempty ( wrempty_from_the_VME_FIFO ),
	.wrfull ( wrfull_from_the_VME_FIFO ),
	.wrusedw ( wrusedw_from_the_VME_FIFO ),
	.rdusedw ( rdusedw_from_the_VME_FIFO )
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
	