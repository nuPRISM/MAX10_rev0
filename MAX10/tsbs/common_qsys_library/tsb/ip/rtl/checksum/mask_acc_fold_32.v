// This module takes the 32-bit data and perform the following:
// 1. Reverse the data byte order to little endian, and mask them according to Empty signal
// 2. Accumulate the data to calculate checksum value
// 3. Fold the accumulation result to 16-bit

module mask_acc_fold_32(
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
	input [31:0] data_in;
	input data_valid;
	input eop;
	input [1:0] empty;  
	input result_valid;
	input downstream_ready;
	output wire [15:0] result;

	reg [31:0] mask; 
	wire [31:0] reversed_data;
	wire [31:0] masked_data;
	reg [17:0] sum;
	
  always @ (eop or empty)
  begin
   case ({eop, empty})
      3'b100 : mask = 32'hFFFFFFFF;
      3'b101 : mask = 32'h00FFFFFF;
      3'b110 : mask = 32'h0000FFFF;
      3'b111 : mask = 32'h000000FF;
      default:  mask = 32'hFFFFFFFF;
    endcase
  end

	assign reversed_data = {data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24]};
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
				sum <= (sum[17:16] + sum[15:0] + masked_data[15:0] + masked_data[31:16]);
			end	
		end
	end
	
	//fold to 16-bit result
	assign result = sum[17:16] + sum[15:0];
	
	
endmodule
