module inc_or_dec_iodelay2_delay
#(
parameter wait_counter_bits = 9
)
(
clk,
start,
 finish,
 iodelay2_ce,
 iodelay2_incdec,
inc_or_dec,
counter,
 state,
 wait_cycles
);


parameter idle                = 16'b0000_0000_1000_0000;
parameter set_incdec_val      = 16'b0000_0000_0100_0001;
parameter wait_incdec_val     = 16'b0000_0000_0100_1000;
parameter set_ce_high         = 16'b0000_0001_0000_0010;
parameter set_ce_low          = 16'b0000_0000_0000_0011;
parameter reset_wait_counter  = 16'b0000_0000_1010_0100;
parameter check_wait_counter  = 16'b0000_0000_0000_0101;
parameter inc_wait_counter    = 16'b0000_0000_0001_0110;
parameter finished            = 16'b0000_0010_0000_0111;


input wire clk;
input wire start;
output wire finish;
output wire iodelay2_ce;
output reg iodelay2_incdec = 0;
input wire inc_or_dec;
output reg  [15:0] state = idle;
output reg [wait_counter_bits-1:0] counter = 0;

wire counter_enable;
wire reset_counter;
input [wait_counter_bits-1:0] wait_cycles;

assign counter_enable     = state[4];
assign reset_counter      = state[5];
assign inc_dec_var_enable = state[6];
assign inc_dec_clear      = state[7];
assign iodelay2_ce        = state[8];
assign finish             = state[9];


always_ff @(posedge clk)
begin
      case (state)
	  idle : if (start)
	         begin
			      state <= set_incdec_val;
			 end else
			 begin
			 	  state <= idle;
			 end
	   
	 set_incdec_val: state <= wait_incdec_val;
	 wait_incdec_val: state <= set_ce_high;
	 set_ce_high : state <= set_ce_low;
	 set_ce_low : state <= reset_wait_counter;
	 reset_wait_counter : state <= check_wait_counter;
	 check_wait_counter : if (counter >= wait_cycles)
	                      begin
						      state <= finished;
						  end else
						  begin
	                         state <= inc_wait_counter;
						  end
	 inc_wait_counter : state <= check_wait_counter;
	 finished : state <= idle;	
      endcase
end

always_ff @(posedge clk)
begin
     if (reset_counter)
	 begin
	      counter <= 0;
	 end else
	 begin	 
	      if (counter_enable)
		  begin
		        counter <= counter + 1;
		  end
	 end
end

always_ff @(posedge clk)
begin
      if (inc_dec_clear)
	  begin
	        iodelay2_incdec <= 0;
	  end else
	  begin
	        if (inc_dec_var_enable)
			begin
			       iodelay2_incdec <= inc_or_dec;
			end else
			begin
			      iodelay2_incdec <= iodelay2_incdec;
			end	  	  
	  end
end


endmodule