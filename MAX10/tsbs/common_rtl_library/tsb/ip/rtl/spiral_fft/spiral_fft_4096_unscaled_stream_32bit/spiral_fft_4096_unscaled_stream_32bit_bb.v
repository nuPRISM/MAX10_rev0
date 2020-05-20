
module spiral_fft_4096_unscaled_stream_32bit (
	clk_clk,
	fft_reset_reset,
	spiral_fft_next,
	spiral_fft_next_out,
	spiral_fft_x0,
	spiral_fft_y0,
	spiral_fft_x1,
	spiral_fft_y1,
	spiral_fft_x2,
	spiral_fft_y2,
	spiral_fft_x3,
	spiral_fft_y3,
	spiral_fft_x4,
	spiral_fft_y4,
	spiral_fft_x5,
	spiral_fft_y5,
	spiral_fft_x6,
	spiral_fft_y6,
	spiral_fft_x7,
	spiral_fft_y7);	

	input		clk_clk;
	input		fft_reset_reset;
	input		spiral_fft_next;
	output		spiral_fft_next_out;
	input	[31:0]	spiral_fft_x0;
	output	[31:0]	spiral_fft_y0;
	input	[31:0]	spiral_fft_x1;
	output	[31:0]	spiral_fft_y1;
	input	[31:0]	spiral_fft_x2;
	output	[31:0]	spiral_fft_y2;
	input	[31:0]	spiral_fft_x3;
	output	[31:0]	spiral_fft_y3;
	input	[31:0]	spiral_fft_x4;
	output	[31:0]	spiral_fft_y4;
	input	[31:0]	spiral_fft_x5;
	output	[31:0]	spiral_fft_y5;
	input	[31:0]	spiral_fft_x6;
	output	[31:0]	spiral_fft_y6;
	input	[31:0]	spiral_fft_x7;
	output	[31:0]	spiral_fft_y7;
endmodule
