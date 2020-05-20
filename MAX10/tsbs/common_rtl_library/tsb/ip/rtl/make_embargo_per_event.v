`default_nettype none

module make_embargo_per_event
#(
parameter num_clocks_per_event = 10,
parameter numbits_counter = 16
)
(
input embargo_causing_event,
output logic embargo_active,
input clk,
output reg [numbits_counter-1:0] count = 0 
);

always_ff @(posedge clk)
begin
      embargo_active <= (count != 0);
end

always_ff @(posedge clk)
begin
     if (embargo_causing_event)
	 begin
          count <= num_clocks_per_event;
	 end else
	 begin
	      count <= (count > 0) ? (count-1) : 0;
	 end 
end

endmodule
`default_nettype wire