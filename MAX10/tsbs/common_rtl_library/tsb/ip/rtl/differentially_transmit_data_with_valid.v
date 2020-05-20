
`default_nettype none
module differentially_transmit_data_with_valid
#(
parameter width = 8,
parameter counter_width = 32
)
(
input clk,
input reset,
input logic [width-1:0] data_in,
input valid_in,
output logic [width-1:0] data_out,
output reg valid_out = 0,
output reg [width-1:0] prev_data_in = 0,
output reg [counter_width-1:0] data_in_count = 0,
output reg [counter_width-1:0] data_out_count = 0,
output reg first_data_sent = 0,
output logic current_data_is_different_than_previous
);

assign current_data_is_different_than_previous = (valid_in && (data_in != prev_data_in));

always_ff @(posedge clk)
begin
        if (reset)
        begin 
                  valid_out <= 0;
				  first_data_sent <= 0;
				  data_out <=  0;
				  prev_data_in <= 0;
				  data_in_count  <= 0;
				  data_out_count <= 0;				  
        end else
        begin
			if (valid_in)
			begin
				  data_in_count <= data_in_count + 1;				  
				  valid_out <= first_data_sent ? current_data_is_different_than_previous : 1'b1;
				  data_out_count <= first_data_sent ? (current_data_is_different_than_previous ? (data_out_count + 1): data_out_count)  
				                    : 1;
				  first_data_sent <= 1'b1;
				  data_out <=  first_data_sent ? (current_data_is_different_than_previous ? data_in : data_out): data_in;
				  prev_data_in <= data_in;
			end
		end
end




endmodule


`default_nettype wire