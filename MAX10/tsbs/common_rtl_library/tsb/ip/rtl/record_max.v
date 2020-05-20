`default_nettype none
module record_max
#(
parameter num_bits = 16,
parameter num_streams = 4
)
(
input clk,
input [num_bits-1:0] indata[num_streams],
output logic [num_bits-1:0] recorded_max[num_streams],
input reset
);

integer i;
always @(posedge clk)
begin
     for (i = 0; i <num_streams; i++)
	 begin : record_the_max
	      if (reset)
		  begin
                recorded_max[i] <= 0;
		  end else
		  begin
		         if (recorded_max[i] < indata[i])
				 begin
				       recorded_max[i] <= indata[i];
				 end
		  end
	end
end




endmodule