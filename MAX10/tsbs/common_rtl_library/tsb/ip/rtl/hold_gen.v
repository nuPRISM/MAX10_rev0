module hold_gen(indata,data_clk,delaying_clk,outdata);


parameter width = 8;
input [width-1:0] indata;
input data_clk;
input delaying_clk;
output [width-1:0] outdata;

wire [width-1:0] indata;
wire data_clk,delaying_clk;
wire [width-1:0] outdata;

(* buffer_type = "NONE" *) reg delayreg1,delayreg2;
(* buffer_type = "NONE" *) reg [width-1:0] datareg;

always @(posedge delaying_clk)
begin
	delayreg1 <= data_clk;
	delayreg2 <= delayreg1;
end

always @(posedge delayreg2)
begin
	datareg <= indata;
end

assign outdata[width-1:0] = datareg[width-1:0];

endmodule
