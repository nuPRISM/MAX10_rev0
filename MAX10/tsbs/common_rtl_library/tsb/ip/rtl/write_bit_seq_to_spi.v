`default_nettype none
module write_bit_seq_to_spi
#(
parameter num_adcs = 2,
parameter numbits_spi = 16,
parameter numbits_counter = 8,
parameter shift_out_msb_first = 1,
parameter return_read_data = 0
)
(
input  logic start,
input  logic enable,
input  logic reset,
input  logic clk,
output logic finish,
output reg [numbits_counter-1:0] sck_pulse_counter = 0,
input  logic [numbits_spi -1:0] write_data[num_adcs],
output  logic [numbits_spi -1:0] read_data[num_adcs],
output reg [15:0] state = 0,
output logic spi_clk,
output logic spi_csn,
input  logic [num_adcs-1:0] spi_miso,
output  logic [num_adcs-1:0] spi_mosi,
output  logic [num_adcs-1:0] spi_miso_synced,

//debug outputs
output logic clear_read_data,
output logic insert_miso,
output logic update_spi_mosi,
output logic increase_counter
);


genvar current_adc;
generate
			for (current_adc = 0; current_adc < num_adcs; current_adc = current_adc + 1)
			begin : register_adc_data
			                if (return_read_data)
			                begin
									doublesync_no_reset
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
							
							always_ff @(posedge clk)
							begin
							      if (update_spi_mosi)
								  begin
								       spi_mosi[current_adc] <= shift_out_msb_first ? write_data[current_adc][numbits_spi-1-sck_pulse_counter] : write_data[current_adc][sck_pulse_counter];
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
parameter init_counters           = 16'b0000_0000_0011_0001;
parameter set_sck_high            = 16'b0000_0010_0101_0010;
parameter wait_miso_sync0         = 16'b0000_0000_0101_0011;
parameter wait_miso_sync1         = 16'b0000_0000_0001_0100;
parameter wait_miso_sync2         = 16'b0000_0000_0001_0101;
parameter set_sck_low             = 16'b0000_0000_0001_0110;
parameter set_sck_low_inc_cnt     = 16'b0000_0100_0001_0111;
parameter register_miso           = 16'b0000_0001_0001_1000;
parameter update_mosi_out         = 16'b0000_0100_0001_1001;
parameter check_sck_pulse_counter = 16'b0000_0000_0001_1010;
parameter finished                = 16'b0000_0000_1000_1011;



assign spi_csn         = !state[4];
assign clear_read_data = state[5] ;
assign spi_clk         = state[6] ;
assign finish          = state[7] ;
assign insert_miso     = state[8] ;
assign increase_counter= state[9] ;
assign update_spi_mosi = state[10] ;


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
				       state <= init_counters;
				 end
				 
		    init_counters   : state <= set_sck_high;
	
			  

			
									  
			set_sck_high : if (return_read_data) 
			                   state <= wait_miso_sync0;
			               else
			                   state <= set_sck_low_inc_cnt;
						
			set_sck_low_inc_cnt: state <= check_sck_pulse_counter;

			wait_miso_sync0 : state <= wait_miso_sync1;
			
			wait_miso_sync1 : state <= wait_miso_sync2;
		  
		    wait_miso_sync2 : state <= set_sck_low;						
			
			set_sck_low    :  state <= register_miso;			                 
			
			register_miso    : state <= update_mosi_out;
			
			update_mosi_out : state <= check_sck_pulse_counter;
            check_sck_pulse_counter : if (sck_pulse_counter >= (numbits_spi))
			                          begin
									        state <= finished;
									  end else
									  begin
									       state <= set_sck_high;
									  end
			finished : state <= idle;
			
			endcase		   
	  	  
	  end
end

endmodule
`default_nettype wire