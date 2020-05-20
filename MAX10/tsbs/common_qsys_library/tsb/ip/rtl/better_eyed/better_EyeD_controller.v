// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
module better_EyeD_controller
#(
  parameter num_counter_bits = 12
 )
(
 input sample_clk,
 input Baud_Clk,
 input BusCLK,
 input read_now,
 input  [1:0] address,
 output reg [31:0] read_data,
 output reg [num_counter_bits-1:0] measurement_block_count,
 input [num_counter_bits-1:0] measurement_block_count_limit, 
 output reg [num_counter_bits-1:0] measurement_sample_count,
 input [num_counter_bits-1:0] measurement_sample_count_limit, 
 output reg clear_counters = 0,
 output reg enable = 0,
 output reg all_samples_measured=0,
 output reg measuring_a_block_now,
 output reg acquisition_fifo_write_enable,
 input [31:0] write_data,
 input write_now,
 input reset,
 output dummy_reset
 );
 
 assign dummy_reset = reset;
 wire clear_counters_synced, enable_synced;
 
 doublesync
 doublesync_clear_counters
 (
 .indata(clear_counters),
 .outdata(clear_counters_synced),
 .clk(sample_clk),
 .reset(1'b1)
 );
 
 
 doublesync
 doublesync_enable
 (
 .indata(enable),
 .outdata(enable_synced),
 .clk(sample_clk),
 .reset(1'b1)
 );

 wire new_symbol_has_arrived; 
 
async_trap_and_reset_gen_1_pulse 
sync_symbol_start
(
.async_sig(Baud_Clk), 
.outclk(sample_clk), 
.out_sync_sig(new_symbol_has_arrived), 
.auto_reset(1'b1), 
.reset(1'b1)
);

reg clear_and_wait_for_new_block;

always @(posedge sample_clk)
begin
     if (clear_counters_synced || clear_and_wait_for_new_block || all_samples_measured)
	 begin
	      measuring_a_block_now <= 0;
     end else
	 begin
	      if (new_symbol_has_arrived && enable_synced && (!all_samples_measured))
		  begin
		       measuring_a_block_now <= 1;
		  end 
	 end
end

always @(negedge sample_clk)
begin
     acquisition_fifo_write_enable <= measuring_a_block_now;
end
 
always_ff @(posedge sample_clk)
begin
     if (clear_counters_synced)
	  begin
          measurement_block_count <= 0;
	  end else
	  begin
	        if (enable_synced && new_symbol_has_arrived && (!all_samples_measured) && (!measuring_a_block_now))
			  begin
			       if (measurement_block_count < measurement_block_count_limit)
					     measurement_block_count <= measurement_block_count + 1;
					 else 
					     measurement_block_count <= measurement_block_count;
			  end
	  end
end


always_ff @(posedge sample_clk)
begin
     if (clear_counters_synced)
	  begin
          measurement_sample_count <= 0;
	  end else
	  begin
	        if (enable_synced && measuring_a_block_now)
			  begin
			         if (measurement_sample_count < measurement_sample_count_limit-1)
					     measurement_sample_count <= measurement_sample_count + 1;
					 else if (!all_samples_measured)
					 begin
					     measurement_sample_count <= 0;
				     end
			  end
	  end
end

always_ff @(posedge sample_clk)
begin
     clear_and_wait_for_new_block <= (measurement_sample_count >= measurement_sample_count_limit-2);
end

always_ff @(posedge sample_clk)
begin
	  if ((measurement_block_count >= measurement_block_count_limit) && (measurement_sample_count >= (measurement_sample_count_limit-2)))
			all_samples_measured <= 1;
		else
			all_samples_measured <= 0;
end

always @(posedge BusCLK)
begin
     if (read_now)
	  begin
	       case(address[1:0])
			 2'b00: read_data <= 32'h12345678;
			 2'b01: read_data <= measurement_sample_count;
			 2'b10: read_data <= {8'hAB,3'b0,clear_and_wait_for_new_block,measuring_a_block_now,clear_counters,all_samples_measured,enable};
			 2'b11: read_data <= measurement_block_count;
			 default: read_data <=  32'hEEEEEEEE;
			 endcase
	  end
end

always @(posedge BusCLK)
begin
     if (write_now)
	 begin
	      if (address == 0)
	      begin
              enable <=  write_data[0];
	      end
	      if (address == 1)
	      begin
	          clear_counters <= write_data[0];
	      end
	 end
end


endmodule
