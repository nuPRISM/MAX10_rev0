`default_nettype none
module read_ltc2380
#(
parameter num_adcs = 2,
parameter numbits_spi = 24,
parameter numbits_counter = 8,
parameter synchronizer_depth = 2
)
(
input  logic start,
input  logic enable,
input  logic reset,
input  logic clk,
output logic finish,
output logic conv,
input  [num_adcs-1:0] busy,
output reg [numbits_counter-1:0] sck_pulse_counter = 0,
output logic [numbits_spi -1:0] read_data[num_adcs],
output reg [15:0] state = 0,
output logic spi_clk,
output logic spi_csn,
input  logic [num_adcs-1:0] spi_miso,

//debug outputs
output logic [num_adcs-1:0] spi_miso_synced,
output logic [num_adcs-1:0] busy_synced,
output logic clear_read_data,
output logic insert_miso,
output logic increase_counter,
output logic post_conversion,
output logic is_in_idle
);


genvar current_adc;
generate
			for (current_adc = 0; current_adc < num_adcs; current_adc = current_adc + 1)
			begin : register_adc_data
			
			
							doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
							sync_spi_miso
							(
							  .indata (spi_miso[current_adc]),
							   .outdata(spi_miso_synced[current_adc]),
							   .clk    (clk)
							);
							
							doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
							sync_busy
							(
							  .indata (busy[current_adc]),
							   .outdata(busy_synced[current_adc]),
							   .clk    (clk)
							);

							always_ff @(posedge clk)
							begin
								  if (clear_read_data)
								  begin
									  read_data[current_adc] <= 0;
								  end if (insert_miso)
								  begin
										read_data[current_adc] <= {read_data[current_adc],spi_miso_synced[current_adc]};
								  end
							end
			end
endgenerate
			
always_ff @(posedge clk)
begin
	  if (clear_read_data)
	  begin
		  sck_pulse_counter <= 0;
	  end if (increase_counter)
	  begin
			sck_pulse_counter <= sck_pulse_counter + 1;
	  end
end

parameter idle                    = 16'b0000_0000_0000_0000;
parameter set_conv_high           = 16'b0000_1000_0011_0001;
parameter set_conv_low            = 16'b0000_1000_0001_0010;
parameter wait_busy_sync0         = 16'b0000_1000_0001_0011;
parameter wait_busy_sync1         = 16'b0000_1000_0001_0100;
parameter wait_busy_sync2         = 16'b0000_1000_0001_0101;
parameter wait_for_busy           = 16'b0000_1000_0001_0110;
parameter register_miso           = 16'b0000_1101_0001_1110;
parameter check_sck_pulse_counter = 16'b0000_1100_0001_0111;
parameter set_sck_high            = 16'b0000_1110_0101_1000;
parameter wait_miso_sync0         = 16'b0000_1100_0101_1001;
parameter wait_miso_sync1         = 16'b0000_1100_0001_1010;
parameter wait_miso_sync2         = 16'b0000_1100_0001_1011;
parameter set_sck_low             = 16'b0000_1100_0001_1100;
parameter finished                = 16'b0000_1100_1000_1101;



assign spi_csn         = !state[4];
assign clear_read_data = state[5] ;
assign conv            = state[5] ;
assign spi_clk         = state[6] ;
assign finish          = state[7] ;
assign insert_miso     = state[8] ;
assign increase_counter= state[9] ;
assign post_conversion = state[10];
assign is_in_idle      = !state[11];

always_ff @(posedge clk)
begin
      if (reset)
	  begin
	       state <= idle;
	  end else
	  begin
	       case (state)
           idle: if (start & enable)
		         begin
				       state <= set_conv_high;
				 end
				 
		  set_conv_high   : state <= set_conv_low;
		  set_conv_low    : state <= wait_busy_sync0;
		  
		  wait_busy_sync0 : state <= wait_busy_sync1;
		  
		  wait_busy_sync1 : state <= wait_busy_sync2;
		  
		  wait_busy_sync2 : state <= wait_for_busy;

          wait_for_busy : if (!(&busy_synced))	
                          begin
                                state <= register_miso;
                          end						  

			register_miso : state <= check_sck_pulse_counter;
			check_sck_pulse_counter : if (sck_pulse_counter >= (numbits_spi-1))
			                          begin
									        state <= finished;
									  end else
									  begin
									       state <= set_sck_high;
									  end
									  
			set_sck_high : state <= wait_miso_sync0;
			
			wait_miso_sync0 : state <= wait_miso_sync1;
			
			wait_miso_sync1 : state <= wait_miso_sync2;
		  
		    wait_miso_sync2 : state <= set_sck_low;
			
			set_sck_low : state <= register_miso;
			
			finished : state <= idle;
			
			endcase		   
	  	  
	  end
end

endmodule
`default_nettype wire