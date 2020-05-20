module checksum(
  clk,
	reset,
	
	//sink port
	snk_data,
	snk_valid,
	snk_ready,
	snk_sop,
	snk_eop,
	snk_empty,
	
	
	//source port
	src_data,
	src_valid,
	src_ready	
);

  parameter DATA_WIDTH = 32; //visible to user
	parameter SYMBOL_WIDTH = 8;
	parameter NUMBER_OF_SYMBOLS = 4;
	parameter NUMBER_OF_SYMBOLS_LOG2 = 2;
	
	input clk;
  input reset;
	
	input[DATA_WIDTH-1:0] snk_data;
	input snk_valid;
	output reg snk_ready;
	input snk_sop;
	input snk_eop;
	input[NUMBER_OF_SYMBOLS_LOG2-1:0] snk_empty;
	
	output wire [15:0] src_data; //16-bit result
	output reg src_valid;
	input src_ready;
		
	wire [15:0] result;
	wire last_beat;
	wire result_read;
		
	//perform checksum on the incoming data
	generate
		if (DATA_WIDTH == 32)
		begin
			mask_acc_fold_32 mask_acc_fold_32_inst (clk, reset, snk_data, snk_valid, snk_eop, snk_empty, src_valid, src_ready, result);
		end
		else if (DATA_WIDTH == 64)
		begin
			mask_acc_fold_64 mask_acc_fold_64_inst (clk, reset, snk_data, snk_valid, snk_eop, snk_empty, src_valid, src_ready, result);
		end
	endgenerate
		
	
	
	
	//SR flip-flop for flow control
	always @ (posedge clk or posedge reset)
	begin
	  if (reset)
		  snk_ready <= 1;
    else
		begin
		  if (last_beat == 1)
			  snk_ready <= 0;
			else if (result_read == 1)
			  snk_ready <= 1;
		end
	end
	
  always @ (posedge clk or posedge reset)
	begin
	  if (reset)
		  src_valid <= 0;
	  else
	  begin
		  if (last_beat == 1)      // use delayed copy of last_beat if the input or result is pipelined
			  src_valid <= 1;
		  else if ((src_valid == 1) & (src_ready == 1))
			  src_valid <= 0;
	  end
	end

		
	assign last_beat = (snk_valid == 1) & (snk_eop == 1) & (snk_ready == 1);
	assign result_read = (src_valid == 1) & (src_ready == 1);
	assign src_data = result;	
	
endmodule
