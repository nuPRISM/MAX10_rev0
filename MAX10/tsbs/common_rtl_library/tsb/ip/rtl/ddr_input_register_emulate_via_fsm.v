`default_nettype none
module ddr_output_register_emulate_via_fsm
#(
parameter numbits = 4,
parameter synchronizer_depth = 2
)
(
input  in_clk,
input  fsm_clk,
input  outclk,
input  reset,
input  [numbits-1:0] indata_posedge,
input  [numbits-1:0] indata_negedge,
output logic  [numbits-1:0] outdata,
input  transpose_data,
output logic found_rising_edge,
output logic found_falling_edge,
output logic output_data_sel,
output logic output_data_latch_now,
output logic [7:0] state
);

async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth))  
find_rising_edge
(.async_sig(in_clk), 
.outclk(fsm_clk), 
.out_sync_sig(found_rising_edge), 
.auto_reset(1'b1), 
.reset(1'b1)
);


async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth))  
find_falling_edge
(.async_sig(!in_clk), 
.outclk(fsm_clk), 
.out_sync_sig(found_falling_edge), 
.auto_reset(1'b1), 
.reset(1'b1)
);

parameter [7:0] idle                     = 8'b0000_0000;
parameter [7:0] set_up_falling_edge_data = 8'b0001_0001;
parameter [7:0] latch_falling_edge_data  = 8'b0011_0010;
parameter [7:0] wait_for_falling_edge    = 8'b0001_0011;
parameter [7:0] set_up_rising_edge_data  = 8'b0000_0100;
parameter [7:0] latch_rising_edge_data   = 8'b0010_0101;
parameter [7:0] wait_for_rising_edge     = 8'b0000_0110;

assign output_data_sel = state[4];
assign output_data_latch_now = state[5];

always_ff @(posedge fsm_clk)
begin
     if (output_data_latch_now)
	 begin
		 if (output_data_sel)
		 begin
			   outdata <= transpose_data ? indata_posedge : indata_negedge;
		 end else
		 begin
			   outdata <= transpose_data ? indata_negedge : indata_posedge;
		 end	
	 end
end


always_ff @(posedge fsm_clk)
begin
       if (reset)
	   begin
	         state <= idle;			 
	   end
	   begin
	        case (state) /* synthesis full_case parallel_case */
	        idle: if (found_rising_edge)
			      begin
				        state <= set_up_falling_edge_data;						
				  end else if (found_falling_edge)
			      begin
					     state <= set_up_rising_edge_data;
				  end 
				  
		    set_up_falling_edge_data:  state <= latch_falling_edge_data;


			latch_falling_edge_data:  state <= wait_for_falling_edge;
			
			
			
			wait_for_falling_edge:   if (found_falling_edge)
			                          begin
									       state <= set_up_rising_edge_data;
									  end
									


									
			set_up_rising_edge_data:  state <= latch_rising_edge_data;


			latch_rising_edge_data:  state <= wait_for_rising_edge;

			wait_for_rising_edge:  if (found_rising_edge)
			                          begin
									       state <= set_up_falling_edge_data;
									  end
		    endcase
	   end
end


endmodule
`default_nettype wire