`default_nettype none
module integrate_and_hold_ivc102_rev2
#(
parameter num_adcs = 2,
parameter N = 32,
parameter numbits_spi = 24
)
(
input  logic clk,
input  logic start,
input  logic enable,
output logic finish,
input  logic reset,
input logic do_reset_before_integration,
input logic keep_reset_active_after_integration,
input  [num_adcs-1:0] busy,
output logic in_the_middle_of_acquiring,
output logic s1,
output logic s2,
input  logic [N-1:0]  integration_time,
input  logic [N-1:0]  pre_integration_reset_wait_time,
input  logic [N-1:0]  reset_time,
input  logic [N-1:0]  hold_time,
output logic [N-1:0]  aux_counter,
output logic signed [numbits_spi-1:0] read_data[num_adcs],
output logic signed [numbits_spi-1:0] read_data_raw[num_adcs],
output logic signed [numbits_spi-1:0] pre_integration_read_data[num_adcs],
output reg [15:0] state = 0,
output logic [15:0] read_ltc2380_state,
output logic spi_clk,
output logic spi_csn,
input  logic [num_adcs-1:0] spi_miso,
output logic conv,
output logic start_adc_conv,
output logic finish_adc_conv,
input logic tie_s1_to_0,
//debug
output logic clear_aux_counter,
output logic increase_counter,
output logic latch_read_data,
output logic latch_pre_integration_data_now,
output logic post_conversion,
output logic read_ltc2380_is_in_idle

);

always_ff @(posedge clk)
begin
      if (clear_aux_counter)
	  begin
	      aux_counter <= 0;
	  end if (increase_counter)
	  begin
	        aux_counter <= aux_counter + 1;
	  end
end

read_ltc2380
#(
.num_adcs(num_adcs),
.numbits_spi(numbits_spi),
.numbits_counter(8)
)
read_ltc2380_inst
(
.start(start_adc_conv),
.enable,
.reset(reset),
.clk,
.finish(finish_adc_conv),
.conv,
.busy,
.state(read_ltc2380_state),
.read_data(read_data_raw),
.post_conversion,
.spi_clk,
.spi_csn,
.spi_miso,
.is_in_idle(read_ltc2380_is_in_idle)
);

logic s2_n, set_s2_active, set_s2_inactive;


parameter idle                             = 16'b0000_0000_0000_0000;
parameter start_reset_adc                  = 16'b0000_0011_0010_0001;
parameter wait_reset_adc                   = 16'b0000_0011_0100_0010;
parameter set_reset_inactive_now_start     = 16'b0001_0010_0000_0011;
parameter start_pre_integration_reset_wait = 16'b0000_0010_0010_0100;
parameter inc_pre_integration_reset_wait   = 16'b0000_0010_0100_0101;
parameter start_pre_int_adc_conversion     = 16'b0000_0110_0000_0110;
parameter wait_for_pre_int_adc_conversion  = 16'b0000_0010_0000_0111;
parameter start_integration                = 16'b0000_0010_1010_1000;
parameter inc_integration_counter          = 16'b0000_0010_1100_1001;
parameter stop_integration                 = 16'b0010_0010_0000_1010;
parameter start_hold_wait                  = 16'b0000_0010_0010_1011;
parameter inc_hold_wait                    = 16'b0000_0010_0100_1100;
parameter start_adc_conversion             = 16'b0000_0110_0000_1101;
parameter wait_for_adc_conversion          = 16'b0000_0010_0000_1110;
parameter get_post_adc_data                = 16'b0000_1010_0000_1111;
parameter set_reset_inactive_now_end       = 16'b0001_0010_0001_0000;
parameter set_reset_active_now_end         = 16'b0000_0011_0001_0001;
parameter finished                         = 16'b0100_0010_0001_0010;



assign finish = state[14];
assign clear_aux_counter = state[5];
assign increase_counter = state[6];
assign s1 = tie_s1_to_0 ? 1'b0 : !state[7];
assign set_s2_active = state[8];
assign in_the_middle_of_acquiring = state[9];
assign start_adc_conv = state[10];
assign latch_read_data = state[11];
assign set_s2_inactive = state[12];
assign latch_pre_integration_data_now = state[13];


sr_latch_via_sync_edge_detect
integrator_reset_n_latch
(
.set(set_s2_active),
.reset(set_s2_inactive),
.q(s2_n),
.clk(clk)
);

assign s2 = !s2_n;

always_ff @(posedge clk)
begin
     if (reset)
	 begin
	       state <= idle;
	 end else
	 begin
	      case (state)
		  idle : if (start)
		         begin
					   if (do_reset_before_integration)
						begin
						     state <= start_reset_adc;
						end else
						begin
				           state <= set_reset_inactive_now_start;
						end
				 end
				 
		   start_reset_adc         : state <= wait_reset_adc;
           wait_reset_adc          : if (aux_counter >= reset_time)
		                             begin
									       state <= set_reset_inactive_now_start;
									 end
		   set_reset_inactive_now_start : state <= start_pre_integration_reset_wait;
		   start_pre_integration_reset_wait : state <=   inc_pre_integration_reset_wait;		   
           inc_pre_integration_reset_wait   : if (aux_counter >= pre_integration_reset_wait_time)
															  begin
															     if (!post_conversion)
																  begin
																        state <= start_pre_int_adc_conversion;
																  end
															  end

           start_pre_int_adc_conversion   	: state <= wait_for_pre_int_adc_conversion;	   
           wait_for_pre_int_adc_conversion	: if (post_conversion)
		                                         begin
											                   state <= start_integration;
											              end	   		   
		   		   
           start_integration : state <=   inc_integration_counter;		   
           inc_integration_counter : if (aux_counter >= integration_time)
		                             begin
									      state <= stop_integration;
									 end
           stop_integration        : if (read_ltc2380_is_in_idle)
                                     begin
                                           state <= start_hold_wait;
		                             end
		   start_hold_wait          : state <= inc_hold_wait;
		   inc_hold_wait            :  if (aux_counter >= hold_time)
		                               begin  
												      if (!post_conversion) 
												      begin
									                 state <= start_adc_conversion;
												      end
									          end		  
		   
           start_adc_conversion    : state <= wait_for_adc_conversion;
           wait_for_adc_conversion : if (finish_adc_conv)
                                     begin
                                           state <= get_post_adc_data;
                                     end									 
           get_post_adc_data :if (keep_reset_active_after_integration)
								 state <= set_reset_active_now_end;
							  else 
							  	 state <= set_reset_inactive_now_end;
							  
									  
          
			set_reset_inactive_now_end : state <= finished;
			set_reset_active_now_end : state <= finished;
		    finished                : state <= idle;
	        endcase
	 end
end

always @(posedge clk)
begin
     if (latch_read_data)
	 begin
	       read_data <= read_data_raw;	       
	 end
	 
	 if (latch_pre_integration_data_now & read_ltc2380_is_in_idle)
	 begin
	      pre_integration_read_data <= read_data_raw;
	 end
end

endmodule
`default_nettype wire

