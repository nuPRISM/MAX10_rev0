`default_nettype none
module read_max11100
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
output reg [numbits_counter-1:0] sck_pulse_counter = 0,
output reg [numbits_counter-1:0] wait_counter = 0,
input      [numbits_counter-1:0] pulse_width_in_clocks,
output logic [numbits_spi -1:0]  read_data[num_adcs],
output reg [15:0] state = 0,
output logic spi_clk,
output logic spi_csn,
input  logic [num_adcs-1:0] spi_miso,
input  logic [7:0] num_sck_clocks,
//debug outputs
output logic [num_adcs-1:0] spi_miso_synced,
output logic clear_read_data,
output logic insert_miso,
output logic increase_counter,
output logic inc_wait_counter,
output logic reset_wait_counter
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


			
always_ff @(posedge clk)
begin
	  if (reset_wait_counter)
	  begin
		  wait_counter <= 0;
	  end if (inc_wait_counter)
	  begin
		  wait_counter <= wait_counter + 1;
	  end
end

parameter idle                    = 16'b0000_0000_0000_0000;
parameter set_sck_low_initially   = 16'b0000_0100_0001_0001;
parameter wait_sck_low_initially  = 16'b0000_1000_0001_0010;
parameter clear_sck_counter       = 16'b0000_0000_0011_0011;
parameter set_sck_high            = 16'b0000_0110_0101_0100;
parameter wait_sck_high           = 16'b0000_1000_0101_0101;
parameter register_miso           = 16'b0000_0001_0101_0110;
parameter set_sck_low             = 16'b0000_0100_0001_0111;
parameter wait_sck_low            = 16'b0000_1000_0001_1000;
parameter check_sck_pulse_counter = 16'b0000_0000_0001_1001;
parameter set_csn_high            = 16'b0000_0100_0000_1010;
parameter wait_csn_high           = 16'b0000_1000_0000_1011;
parameter finished                = 16'b0000_0000_1000_1100;



assign spi_csn         = !state[4];
assign clear_read_data = state[5] ;
assign spi_clk         = state[6] ;
assign finish          = state[7] ;
assign insert_miso     = state[8] ;
assign increase_counter= state[9] ;
assign reset_wait_counter = state[10];
assign inc_wait_counter = state[11];


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
				       state <= set_sck_low_initially;
				 end
				 
		   set_sck_low_initially : state <= wait_sck_low_initially;
			
		   wait_sck_low_initially :  if (wait_counter >= pulse_width_in_clocks) 
			                begin
							      state <= clear_sck_counter;
							end
							
		    clear_sck_counter   : state <= set_sck_high;
		  
									  
			set_sck_high : state <= wait_sck_high;
			
			wait_sck_high : if (wait_counter >= pulse_width_in_clocks) 
			                begin
							      state <= register_miso;
							end
			register_miso : state <= set_sck_low;

			set_sck_low : state <= wait_sck_low;
			
			wait_sck_low :  if (wait_counter >= pulse_width_in_clocks) 
			                begin
							      state <= check_sck_pulse_counter;
							end
							

			check_sck_pulse_counter : if (sck_pulse_counter >= (num_sck_clocks))
			                          begin
									             state <= set_csn_high;
											  end else
											  begin
													 state <= set_sck_high;
											  end
									  
			set_csn_high            :  state <= wait_csn_high;
			wait_csn_high           :  if (wait_counter >= pulse_width_in_clocks) 
											   begin
														state <= finished;
												end
			finished : state <= idle;
			
			endcase		   
	  	  
	  end
end

endmodule
`default_nettype wire