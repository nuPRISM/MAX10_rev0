module parameterized_systemverilog_mux
#(
parameter num_inputs = 16,
parameter width = 10,
parameter sel_width = $clog2(num_inputs)
)
(
input [width-1:0] data_in[num_inputs-1:0],
input clk_in,
input [sel_width-1:0] sel,
output logic [width-1:0] data_out,
output clk_out
);

reg [width-1:0] data_in_pipeline_reg[num_inputs-1:0];

always_ff @(posedge clk_in)
begin
     data_in_pipeline_reg <= data_in;
end

always_ff @(posedge clk_in)
begin
     data_out <= data_in_pipeline_reg[sel];
end

assign clk_out = clk_in;

endmodule







