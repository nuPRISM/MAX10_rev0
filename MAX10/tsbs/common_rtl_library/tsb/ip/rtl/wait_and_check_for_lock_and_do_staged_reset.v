`default_nettype none
module wait_and_check_for_lock_and_do_staged_reset
(
 clk,
 reset,
 state,
 lock_indication,
 enable,
 start_delay_counter,
 reset_event_occurred_pulse,
 reset_outer,
 reset_inner,
 select_wait_period,
 wait_counter_finished,
 wait_between_lock_checks,
 wait_between_resets,
 programmable_wait_amount,
 use_slow_mode
);
  parameter wait_counter_bits = 32;
  
  parameter idle                                = 16'b0000_0000_0000_0000;
  parameter start_wait_between_lock_checks      = 16'b0000_0000_1000_0001;
  parameter wait_for_wait_between_lock_checks   = 16'b0000_0000_0000_0010;
  parameter check_lock                          = 16'b0000_0000_0000_0101;
  parameter assert_outer_reset                  = 16'b0000_0001_1101_0110;
  parameter wait_assert_outer_reset             = 16'b0000_0001_0001_0111;
  parameter assert_inner_reset                  = 16'b0000_0011_1001_1000;
  parameter wait_assert_inner_reset             = 16'b0000_0011_0001_1001;
  parameter deassert_inner_reset                = 16'b0000_0001_1001_1010;
  parameter wait_deassert_inner_reset           = 16'b0000_0001_0001_1011;
  parameter deassert_outer_reset                = 16'b0000_0000_1001_1100;
  parameter wait_deassert_outer_reset           = 16'b0000_0000_0001_1101;
  
  

input wire clk;
input reset;
input enable;
output wire start_delay_counter;
output wire select_wait_period;
output reset_event_occurred_pulse;
output reg  [15:0] state = idle;
input [wait_counter_bits-1:0] wait_between_lock_checks;
input [wait_counter_bits-1:0] wait_between_resets;
output [wait_counter_bits-1:0] programmable_wait_amount;
input lock_indication;
output wait_counter_finished;
wire delay_reset_n;
output reset_outer;
output reset_inner;
input use_slow_mode;
assign select_wait_period           = state[4];
assign reset_event_occurred_pulse   = state[6];
assign start_delay_counter          = state[7];
assign reset_outer                  = state[8];
assign reset_inner                  = state[9];

assign programmable_wait_amount     =  select_wait_period ? wait_between_resets : wait_between_lock_checks;

assign delay_reset_n = ~reset;

always_ff @(posedge clk or posedge reset)
begin
      if (reset)
	  begin
	        state <= idle;
	  end
	  else 
	  begin
				  case (state)
				  idle : state <= start_wait_between_lock_checks;			 
				  start_wait_between_lock_checks    : state <= wait_for_wait_between_lock_checks;
				  wait_for_wait_between_lock_checks : if (wait_counter_finished) state <= check_lock;
				 
				  check_lock: if (!enable)
				              begin
							       state <= check_lock;
							  end else
							  begin				  				  
									if (lock_indication) 
									begin
									     if (use_slow_mode)
										 begin
									         state <= start_wait_between_lock_checks;
										 end
										 else begin 
										      state <= check_lock;
										 end
									end else
									begin
									    state <= assert_outer_reset;
									end
							  end
				  assert_outer_reset         : state <=  wait_assert_outer_reset   ;
				  wait_assert_outer_reset    : if (wait_counter_finished) state <=  assert_inner_reset ;
				  assert_inner_reset         : state <=  wait_assert_inner_reset   ;
				  wait_assert_inner_reset    : if (wait_counter_finished) state <=  deassert_inner_reset  ;    
				  deassert_inner_reset       : state <=  wait_deassert_inner_reset   ;
				  wait_deassert_inner_reset  : if (wait_counter_finished) state <=   state <=  deassert_outer_reset        ;
				  deassert_outer_reset       : state <=  wait_deassert_outer_reset   ;
				  wait_deassert_outer_reset  : if (wait_counter_finished) state <=   state <=  start_wait_between_lock_checks;            
				  
				  
				  endcase
	end
end
programmable_wait
#(
.width(wait_counter_bits)
)
programmable_wait_inst
   ( //Inputs
	.SM_CLK   (clk),
	.RESET_N  (delay_reset_n),
	.START    (start_delay_counter),
	.AMOUNT   (programmable_wait_amount),
	//Outputs
	 .FINISH  (wait_counter_finished)
);

endmodule
`default_nettype wire
