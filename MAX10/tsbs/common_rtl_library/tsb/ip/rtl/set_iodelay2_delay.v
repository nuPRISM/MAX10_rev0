module set_iodelay2_delay 
#(
  parameter wait_counter_bits = 9
)
(
	clk,
	start,
	iodelay2_ce,
	iodelay2_incdec,
	tap_val,
	state,
	counter,
	finish,
	current_inc_or_dec,
	start_inc_dec_machine,
	inc_dec_machine_finish,
	get_to_zero_count,
	wait_for_reset_count,
	iodelay2_rst,
    wait_cycles
);

input clk;
input start;
output iodelay2_ce;
output iodelay2_incdec;
output iodelay2_rst;
output finish;
input [7:0] tap_val;
input [wait_counter_bits-2:0] get_to_zero_count;
input [wait_counter_bits-2:0] wait_for_reset_count;
input [wait_counter_bits-1:0] wait_cycles;

localparam idle                    = 16'b0000_0000_0000_0000;
localparam reset_reset_counter     = 16'b0000_0100_0010_1100;
localparam check_reset_counter     = 16'b0000_0000_0000_1101;
localparam inc_reset_counter       = 16'b0000_0000_0100_1110;
localparam reset_zeroing_counter   = 16'b0000_0000_0010_0001;
localparam check_zeroing_counter   = 16'b0000_0000_0000_0010;
localparam start_zeroing_decrement = 16'b0000_0000_1000_0011;
localparam wait_for_inc_dec_finish = 16'b0000_0000_0000_0100;
localparam inc_zeroing_counter     = 16'b0000_0000_0100_0101;
localparam reset_setting_counter   = 16'b0000_0000_0010_0110;
localparam check_setting_counter   = 16'b0000_0000_0000_0111;
localparam start_setting_increment = 16'b0000_0001_1000_1000;
localparam wait_setting_increment  = 16'b0000_0001_0000_1001;
localparam inc_setting_counter     = 16'b0000_0000_0100_1010;
localparam finished                = 16'b0000_0010_0000_1011;

output reg [15:0] state = idle;                                 

output reg [wait_counter_bits-1:0] counter = 0;


wire reset_counter;
wire counter_enable;
output wire start_inc_dec_machine;
output wire inc_dec_machine_finish;
output current_inc_or_dec;

assign reset_counter = state[5];
assign counter_enable = state[6];
assign start_inc_dec_machine = state[7];
assign current_inc_or_dec = state[8];
assign finish = state[9];
assign iodelay2_rst = state[10];

inc_or_dec_iodelay2_delay
#(
.wait_counter_bits(wait_counter_bits)
)
inc_or_dec_iodelay2_delay_inst
(
.clk(clk),
.start(start_inc_dec_machine),
.finish(inc_dec_machine_finish),
.iodelay2_ce(iodelay2_ce),
.iodelay2_incdec(iodelay2_incdec),
.inc_or_dec(current_inc_or_dec),
.wait_cycles(wait_cycles),
.counter(),
.state()
);


always_ff @(posedge clk)
begin
     case (state)
	 idle : if (start) state <= reset_reset_counter; else state <= idle;
 	 reset_reset_counter : state <= check_reset_counter;
	 check_reset_counter :  if (counter >= wait_for_reset_count) 
	                         begin
							      state <= reset_zeroing_counter;
							 end else
							 begin
							      state <= inc_reset_counter;
							 end
	 inc_reset_counter : state <= check_reset_counter;
	 reset_zeroing_counter : state <= check_zeroing_counter;
	 check_zeroing_counter : if (counter >= get_to_zero_count) 
	                         begin
							      state <= reset_setting_counter;
							 end else
							 begin
							      state <= start_zeroing_decrement;
							 end
	  start_zeroing_decrement : state <= wait_for_inc_dec_finish;
	  wait_for_inc_dec_finish : if (inc_dec_machine_finish) state <= inc_zeroing_counter; else state <= wait_for_inc_dec_finish;
	  inc_zeroing_counter : state <= check_zeroing_counter;
	  reset_setting_counter : state <= check_setting_counter;
	  check_setting_counter : if (counter >= tap_val) 
	                         begin
							      state <= finished;
							 end else
							 begin
							      state <= start_setting_increment;
							 end
	                                 
	 start_setting_increment : state <= wait_setting_increment;
	 wait_setting_increment : if (inc_dec_machine_finish) state <= inc_setting_counter; else state <= wait_setting_increment;
	 inc_setting_counter : state <= check_setting_counter;
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


endmodule
