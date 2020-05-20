`default_nettype none
module difference_over_time
#(
parameter counter_bits = 32,
parameter data_bits = 32
)
(
output logic [counter_bits-1:0] counter,
input  logic [counter_bits-1:0] measurement_interval,
output logic [counter_bits-1:0] num_of_measurements,
input  logic [data_bits-1:0]    measured_signal,
output logic [data_bits-1:0]    prev_measurement,
output logic [data_bits-1:0]    current_measurement,
output logic [data_bits-1:0]    measured_difference,
output logic                    new_measurement_available,
output logic                    measurement_is_valid,

input  logic enable,
input  logic clk,
input  logic reset
);

always @(posedge clk)
begin
      if (reset)
	  begin
	        counter <= 0;	 
            prev_measurement <= 0;
			current_measurement <= 0;
			measured_difference <= 0;
			new_measurement_available <= 0;
			num_of_measurements <= 0;
	  end else
	  begin
	        if (enable)
			begin
		          if (counter >= measurement_interval)
				  begin
				        counter <= 0;	
                        prev_measurement <= current_measurement;
						current_measurement <= measured_signal;
						measured_difference <= current_measurement - prev_measurement;
						new_measurement_available <= 1;
						num_of_measurements <= num_of_measurements + 1;
						measurement_is_valid <= (num_of_measurements > 1);
				  end
				  else
				  begin
				        counter <= counter + 1;
						new_measurement_available <= 0;
				  end			
			end
	  end	 
end

endmodule
`default_nettype wire