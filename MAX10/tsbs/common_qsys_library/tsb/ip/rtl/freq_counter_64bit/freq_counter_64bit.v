`default_nettype none
module freq_counter_64bit
(
 input	clk,
 input	reference_and_avalon_mm_clk,
 input	reference_and_avalon_mm_reset,
 input reset,
 input read_now,
 input write_now,
 input [1:0] address,
 output reg [31:0] read_data,
 input [31:0] write_data,
 output reg [63:0] the_counter=0,
 output reg [63:0] ref_counter=0
);

parameter synchronizer_depth = 3;
reg [63:0] snapshot_reg=0;
reg [63:0] synced_snapshot_reg=0;
reg [63:0] reference_reg=0;
reg prev_write_now = 0;
wire synced_write;
reg edge_detect_write_now = 0;

always_ff @(posedge clk or posedge reset)
begin
     if (reset)
	 begin
	      the_counter <= 0;
	 end
	 else
	 begin
           the_counter <= the_counter+64'b1;
	  end
end

always_ff @(posedge reference_and_avalon_mm_clk)
begin
      prev_write_now <= write_now;
	  edge_detect_write_now <= (!prev_write_now) & write_now;
end	  


always_ff @(posedge reference_and_avalon_mm_clk)
begin
     if (reference_and_avalon_mm_reset)
	 begin
	       ref_counter <= 0;
	 end
	 else
	 begin
           ref_counter <= ref_counter+64'b1;
	 end
end

async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth))
make_synced_write_for_snapshot (
.async_sig(edge_detect_write_now), 
.outclk(clk), 
.out_sync_sig(synced_write), 
.auto_reset(1'b1), 
.unregistered_out_sync_sig(),
.reset(1'b1)
);


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(64),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth) 
)
sync_snapshot_reg
(
   .in_clk(clk),
   .in_valid(1'b1),
   .in_data(snapshot_reg),
   .out_clk(reference_and_avalon_mm_clk),
   .out_valid(),
   .out_data(synced_snapshot_reg)
 );


always @(posedge clk or posedge reset)
begin
     if (reset)
	 begin
	       snapshot_reg <= 0;
	 end else
	 begin
			 if (synced_write)
			 begin
				  snapshot_reg <= the_counter;
			 end
	 end
end

always @(posedge reference_and_avalon_mm_clk)
begin
     if (reference_and_avalon_mm_reset)
	 begin
	       reference_reg <= 0;
	 end else
	 begin
			 if (write_now)
			 begin
				  reference_reg <= ref_counter;
			 end
	 end
end

always @(posedge reference_and_avalon_mm_clk)
begin
     if (reference_and_avalon_mm_reset)
	 begin
	          read_data <= 0;
	 end else
	 begin
			 if (read_now)
			 begin
				  case (address)
				  2'b00 :  read_data <= synced_snapshot_reg[31:0];
				  2'b01 :  read_data <= synced_snapshot_reg[63:32];
				  2'b10 :  read_data <= reference_reg[31:0];
				  2'b11 :  read_data <= reference_reg[63:32];
				  endcase
			 end
	 end
end

endmodule


`default_nettype wire