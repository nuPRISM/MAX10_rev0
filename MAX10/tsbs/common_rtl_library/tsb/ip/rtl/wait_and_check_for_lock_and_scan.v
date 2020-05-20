module wait_and_check_for_lock_and_scan
#(
  parameter wait_counter_bits = 9,
  parameter scan_counter_bits = 4
)
(
 clk,
 reset,
 counter,
 scan_counter,
 state,
 wait_cycles,
 lock_indication,
 max_scan_offset,
 enable_scan,
 clear_scan_counter,
 inc_scan_counter
);


localparam idle                = 16'b0000_0000_0000_0000;
localparam clear_counters      = 16'b0000_0000_1010_0001;
localparam reset_wait_counter  = 16'b0000_0000_0010_0010;
localparam check_wait_counter  = 16'b0000_0000_0000_0011;
localparam do_inc_wait_counter = 16'b0000_0000_0001_0100;
localparam check_lock          = 16'b0000_0000_0000_0101;
localparam do_inc_scan_counter = 16'b0000_0000_0100_0110;


input wire clk;
input reset;
input enable_scan;
output wire clear_scan_counter;
output inc_scan_counter;
output reg  [15:0] state = idle;
output reg [wait_counter_bits-1:0] counter = 0;
output reg [scan_counter_bits-1:0] scan_counter = 0;
input [scan_counter_bits-1:0] max_scan_offset;
input [wait_counter_bits-1:0] wait_cycles;
input lock_indication;

wire inc_wait_counter;
wire reset_counter;


assign inc_wait_counter   = state[4];
assign reset_counter      = state[5];
assign inc_scan_counter   = state[6];
assign clear_scan_counter = state[7];


always_ff @(posedge clk or posedge reset)
begin
      if (reset)
	  begin
	        state <= idle;
	  end
	  else 
	  begin
				  case (state)
				  idle : state <= clear_counters;			 
				  clear_counters : state <= reset_wait_counter;
				  reset_wait_counter : state <= check_wait_counter;
				  check_wait_counter : if (counter >= wait_cycles)
									  begin
										  state <= check_lock;
									  end else
									  begin
										 state <= do_inc_wait_counter;
									  end
				  do_inc_wait_counter : state <= check_wait_counter;
				  check_lock: if (!enable_scan)
				              begin
							       state <= check_lock;
							  end else
							  begin				  				  
									if (lock_indication) 
									begin
									     state <= reset_wait_counter;
									end else
									begin
									    state <= do_inc_scan_counter;
									end
							  end
				  do_inc_scan_counter : state <= reset_wait_counter;	 
				  endcase
	end
end

always_ff @(posedge clk)
begin
     if (reset_counter)
	 begin
	      counter <= 0;
	 end else
	 begin	 
	      if (inc_wait_counter)
		  begin
		        counter <= counter + 1;
		  end
	 end
end

always_ff @(posedge clk)
begin
      if (clear_scan_counter)
	  begin
	        scan_counter <= 0;
	  end else
	  begin
	        if (inc_scan_counter)
			begin
			     if (scan_counter < max_scan_offset)
				 begin
			         scan_counter <= scan_counter+1;
				 end
				 else 
				 begin
				     scan_counter <= 0;
				 end
			end else
			begin
			      scan_counter <= scan_counter;
			end	  	  
	  end
end


endmodule
