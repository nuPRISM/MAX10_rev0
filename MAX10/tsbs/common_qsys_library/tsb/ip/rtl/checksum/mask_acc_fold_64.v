// This module takes the 64-bit data and perform the following:
// 1. Reverse the data byte order to little endian, and mask them according to Empty signal
// 2. Accumulate the data to calculate checksum value
// 3. Fold the accumulation result to 16-bit

module mask_acc_fold_64(
	clk,
	reset,
	data_in,
	data_valid,
	eop,
	empty,  
	result_valid, 
	downstream_ready,
	result
);

	input clk;
	input reset;
	input [63:0] data_in;
	input data_valid;
	input eop;
	input [2:0] empty;
	input result_valid;
	input downstream_ready;  
	output wire [15:0] result;

	reg [63:0] mask; 
	wire [63:0] reversed_data;
	wire [63:0] masked_data;
	reg [18:0] sum;

	always @ (eop or empty)
	begin
	case ({eop, empty})
      4'b1000 : mask = 64'hFFFFFFFFFFFFFFFF;
      4'b1001 : mask = 64'h00FFFFFFFFFFFFFF;
      4'b1010 : mask = 64'h0000FFFFFFFFFFFF;
      4'b1011 : mask = 64'h000000FFFFFFFFFF;
			4'b1100 : mask = 64'h00000000FFFFFFFF;
			4'b1101 : mask = 64'h0000000000FFFFFF;
			4'b1110 : mask = 64'h000000000000FFFF;
			4'b1111 : mask = 64'h00000000000000FF;
      default:  mask = 64'hFFFFFFFFFFFFFFFF;
    endcase
	end

	assign reversed_data = {data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24], data_in[39:32], data_in[47:40], data_in[55:48], data_in[63:56]};
	assign masked_data = reversed_data & mask;
	
	// perform checksum of the input data
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			sum <= 0;
		end
		else
		begin
			if (result_valid == 1 & downstream_ready == 1) 
			begin
				sum <= 0;
			end
			else if (data_valid == 1)
			begin
				sum <= (sum[18:16] + sum[15:0] + masked_data[15:0] + masked_data[31:16] + masked_data[47:32] + masked_data[63:48]);
			end	
		end
	end
	
	//fold to 16-bit result
	assign result = sum[18:16] + sum[15:0];
	
endmodule
