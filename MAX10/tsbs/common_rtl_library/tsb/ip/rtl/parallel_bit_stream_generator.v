module parallel_bit_stream_generator
(
clk,
sm_clk,
out_bit_stream,
all_finish,
all_bit_streams,
sel_output_bitstream,
user_bit_pattern,
external_sequence,
pattern_to_output_for_atrophied_generation,
finish
);

`include "log2_function.v"

parameter numbitstreams=16;
parameter log2_numbitstreams=log2(numbitstreams);
parameter output_width = 10;
parameter log2_output_width = log2(output_width);

parameter user_seq_bit_pattern_length = 24;
parameter user_seq_bit_pattern_counter_width = 5;

input clk;
input sm_clk;
output reg [output_width-1:0] out_bit_stream;
output logic [numbitstreams-1:0] all_finish;
output logic [output_width-1:0] all_bit_streams[numbitstreams];
input [log2_numbitstreams-1:0] sel_output_bitstream;
input [user_seq_bit_pattern_length-1:0] user_bit_pattern;
input [output_width-1:0] external_sequence;
output logic finish;
input [output_width-1:0] pattern_to_output_for_atrophied_generation;

parameter PN_LFSR_DEFAULT_WIDTH = 7;
parameter PN_LFSR_DEFAULT_TAP = 6;
parameter PN_LFSR_TRANS_MATRIX = 49'b0111111111111110111111001111100011110000111000001;


parameter ALTERNATE_PN_LFSR_DEFAULT_WIDTH = 3;
parameter ALTERNATE_PN_LFSR_DEFAULT_TAP = 2;
parameter ALTERNATE_PN_LFSR_TRANS_MATRIX = 9'b011111101;


parameter ALTERNATE3_PN_LFSR_DEFAULT_WIDTH = 10;
parameter ALTERNATE3_PN_LFSR_DEFAULT_TAP = 9;
parameter ALTERNATE3_PN_LFSR_TRANS_MATRIX = 100'b1011001001110010010001100100100011001001100010010001000100100010001001100000010001000000100010000001;
                                          //100'b0111111111111111111110111111111001111111100011111110000111111000001111100000011110000000111000000001;


parameter ALTERNATE4_PN_LFSR_DEFAULT_WIDTH = 22;
parameter ALTERNATE4_PN_LFSR_DEFAULT_TAP = 21;
parameter ALTERNATE4_PN_LFSR_TRANS_MATRIX = 484'b0111111111111111111111111111111111111111111110111111111111111111111001111111111111111111100011111111111111111110000111111111111111111000001111111111111111100000011111111111111110000000111111111111111000000001111111111111100000000011111111111110000000000111111111111000000000001111111111100000000000011111111110000000000000111111111000000000000001111111100000000000000011111110000000000000000111111000000000000000001111100000000000000000011110000000000000000000111000000000000000000001;


parameter ALTERNATE5_PN_LFSR_DEFAULT_WIDTH = 31;
parameter ALTERNATE5_PN_LFSR_DEFAULT_TAP = 28;
parameter ALTERNATE5_PN_LFSR_TRANS_MATRIX = 961'b0111111111111111111111111111111111111111111111111111111111111110111111111111111111111111111111001111111111111111111111111111100011111111111111111111111111110000111111111111111111111111111000001111111111111111111111111100000011111111111111111111111110000000111111111111111111111111000000001111111111111111111111100000000011111111111111111111110000000000111111111111111111111000000000001111111111111111111100000000000011111111111111111110000000000000111111111111111111000000000000001111111111111111100000000000000011111111111111110000000000000000111111111111111000000000000000001111111111111100000000000000000011111111111110000000000000000000111111111111000000000000000000001111111111100000000000000000000011111111110000000000000000000000111111111000000000000000000000001111111100000000000000000000000011111110000000000000000000000000111111000000000000000000000000001111100000000000000000000000000011110000000000000000000000000000111000000000000000000000000000001;

wire Parallel_LFSR_Start;


async_trap_and_reset 
make_start_sig
(.async_sig(clk), 
.outclk(sm_clk), 
.out_sync_sig(Parallel_LFSR_Start), 
.auto_reset(1'b1), 
.reset(1'b1));

assign all_finish[0] = Parallel_LFSR_Start;

assign all_bit_streams[0] = pattern_to_output_for_atrophied_generation;
			

/*
Parallel_LFSR_synchronous
#(
.LFSR_LENGTH(PN_LFSR_DEFAULT_WIDTH),
.OUTPUT_WIDTH(output_width)
)
Parallel_LFSR_inst
(
  .LFSR_Transition_Matrix(PN_LFSR_TRANS_MATRIX),
  .sm_clk(sm_clk),
  .start(Parallel_LFSR_Start),
  .finish(all_finish[0]),
  .output_parallel_LFSR_bits(all_bit_streams[0]),
  .reset(1'b1)
); 
*/
Parallel_LFSR_synchronous
#(
.LFSR_LENGTH(ALTERNATE_PN_LFSR_DEFAULT_WIDTH),
.OUTPUT_WIDTH(output_width)
)
Parallel_ALTERNATE_LFSR_inst
(
  .LFSR_Transition_Matrix(ALTERNATE_PN_LFSR_TRANS_MATRIX),
  .sm_clk(sm_clk),
  .start(Parallel_LFSR_Start),
  .finish(all_finish[1]),
  .output_parallel_LFSR_bits(all_bit_streams[1]),
  .reset(1'b1)
); 

assign all_bit_streams[2] = external_sequence;
assign all_finish[2] = all_finish[4]; //piggy-back on 101010 finish signal

//Parallel_LFSR_synchronous
//#(
//.LFSR_LENGTH(ALTERNATE3_PN_LFSR_DEFAULT_WIDTH),
//.OUTPUT_WIDTH(output_width)
//)
//Parallel_ALTERNATE3_LFSR_inst
//(
//  .LFSR_Transition_Matrix(ALTERNATE3_PN_LFSR_TRANS_MATRIX),
//  .sm_clk(sm_clk),
//  .start(Parallel_LFSR_Start),
//  .finish(all_finish[3]),
//  .output_parallel_LFSR_bits(all_bit_streams[3]),
//  .reset(1'b1)
//); 

make_parallel_alternating_output
#(
.width(output_width)
)
make_parallel_alternating_output_inst
(
 .start(Parallel_LFSR_Start),
 .sm_clk(sm_clk),
 .outdata(all_bit_streams[4]),
 .finish(all_finish[4])
);
 
// `ifdef COMPILE_22TAP_PN_SEQUENCE

		// Parallel_LFSR_synchronous
		// #(
		// .LFSR_LENGTH(ALTERNATE4_PN_LFSR_DEFAULT_WIDTH),
		// .OUTPUT_WIDTH(output_width)
		// )
		// Parallel_ALTERNATE4_LFSR_inst
		// (
		  // .LFSR_Transition_Matrix(ALTERNATE4_PN_LFSR_TRANS_MATRIX),
		  // .sm_clk(sm_clk),
		  // .start(Parallel_LFSR_Start),
		  // .finish(all_finish[6]),
		  // .output_parallel_LFSR_bits(all_bit_streams[6]),
		  // .reset(1'b1)
		// ); 

// `else
       // assign all_finish[6] = all_finish[4]; //piggy-back on 101010 finish signal
       // assign all_bit_streams[6] = 1'b1;
// `endif


// `ifdef COMPILE_31TAP_PN_SEQUENCE
		// Parallel_LFSR_synchronous
		// #(
		// .LFSR_LENGTH(ALTERNATE5_PN_LFSR_DEFAULT_WIDTH),
		// .OUTPUT_WIDTH(output_width)
		// )
		// Parallel_ALTERNATE5_LFSR_inst
		// (
		  // .LFSR_Transition_Matrix(ALTERNATE5_PN_LFSR_TRANS_MATRIX),
		  // .sm_clk(sm_clk),
		  // .start(Parallel_LFSR_Start),
		  // .finish(all_finish[7]),
		  // .output_parallel_LFSR_bits(all_bit_streams[7]),
		  // .reset(1'b1)
		// ); 
// `else
      // assign all_finish[7] = all_finish[4]; //piggy-back on 101010 finish signal
      // assign all_bit_streams[7] = 1'b0;
// `endif
// /*
// Parallel_LFSR_synchronous
// #(
// .LFSR_LENGTH(3),
// .OUTPUT_WIDTH(output_width)
// )
// Parallel_PN3_Gen_inst
// (
  // .LFSR_Transition_Matrix(9'011111101),
  // .sm_clk(sm_clk),
  // .start(Parallel_LFSR_Start),
  // .finish(all_finish[8]),
  // .output_parallel_LFSR_bits(all_bit_streams[8]),
  // .reset(1'b1)
// ); 
// */



// Parallel_LFSR_synchronous //for checking markov chain generation
// #(
// .LFSR_LENGTH(ALTERNATE_PN_LFSR_DEFAULT_WIDTH),
// .OUTPUT_WIDTH(output_width)
// )
// Parallel_PN3_Gen_inst
// (
  // .LFSR_Transition_Matrix(ALTERNATE_PN_LFSR_TRANS_MATRIX),
  // .sm_clk(sm_clk),
  // .start(Parallel_LFSR_Start),
  // .finish(all_finish[8]),
  // .output_parallel_LFSR_bits(all_bit_streams[8]),
  // .reset(1'b1)
// ); 

// Parallel_LFSR_synchronous
// #(
// .LFSR_LENGTH(7),
// .OUTPUT_WIDTH(output_width)
// )
// Parallel_PN7_Gen_inst
// (
  // .LFSR_Transition_Matrix(49'b0111111111111110111111001111100011110000111000001),
  // .sm_clk(sm_clk),
  // .start(Parallel_LFSR_Start),
  // .finish(all_finish[9]),
  // .output_parallel_LFSR_bits(all_bit_streams[9]),
  // .reset(1'b1)
// ); 


Parallel_LFSR_synchronous
#(
.LFSR_LENGTH(9),
.OUTPUT_WIDTH(output_width)
)
Parallel_PN9_Gen_inst
(
  .LFSR_Transition_Matrix(81'b100110001110001000011000100001100010000110001100001000010000100001000010000100001),
  .sm_clk(sm_clk),
  .start(Parallel_LFSR_Start),
  .finish(all_finish[10]),
  .output_parallel_LFSR_bits(all_bit_streams[10]),
  .reset(1'b1)
); 


// Parallel_LFSR_synchronous
// #(
// .LFSR_LENGTH(ALTERNATE3_PN_LFSR_DEFAULT_WIDTH),
// .OUTPUT_WIDTH(output_width)
// )
// Parallel_PN10_Gen_inst
// (
  // .LFSR_Transition_Matrix(ALTERNATE3_PN_LFSR_TRANS_MATRIX),
  // .sm_clk(sm_clk),
  // .start(Parallel_LFSR_Start),
  // .finish(all_finish[11]),
  // .output_parallel_LFSR_bits(all_bit_streams[11]),
  // .reset(1'b1)
// ); 


// Parallel_LFSR_synchronous
// #(
// .LFSR_LENGTH(11),
// .OUTPUT_WIDTH(output_width)
// )
// Parallel_PN11_Gen_inst
// (
  // .LFSR_Transition_Matrix(121'b1110101010111010101010011010101011001010101001001010101100001010100100001010110000001010010000001011000000001001000000001),
  // .sm_clk(sm_clk),
  // .start(Parallel_LFSR_Start),
  // .finish(all_finish[12]),
  // .output_parallel_LFSR_bits(all_bit_streams[12]),
  // .reset(1'b1)
// ); 



// Parallel_LFSR_synchronous
// #(
// .LFSR_LENGTH(15),
// .OUTPUT_WIDTH(output_width)
// )
// Parallel_PN15_Gen_inst
// (
  // .LFSR_Transition_Matrix(225'b011111111111111111111111111111101111111111111100111111111111100011111111111100001111111111100000111111111100000011111111100000001111111100000000111111100000000011111100000000001111100000000000111100000000000011100000000000001),
  // .sm_clk(sm_clk),
  // .start(Parallel_LFSR_Start),
  // .finish(all_finish[13]),
  // .output_parallel_LFSR_bits(all_bit_streams[13]),
  // .reset(1'b1)
// ); 


// `ifdef COMPILE_22TAP_PN_SEQUENCE

			// Parallel_LFSR_synchronous
			// #(
			// .LFSR_LENGTH(22),
			// .OUTPUT_WIDTH(output_width)
			// )
			// Parallel_PN22_Gen_inst
			// (
			  // .LFSR_Transition_Matrix(484'b0111111111111111111111111111111111111111111110111111111111111111111001111111111111111111100011111111111111111110000111111111111111111000001111111111111111100000011111111111111110000000111111111111111000000001111111111111100000000011111111111110000000000111111111111000000000001111111111100000000000011111111110000000000000111111111000000000000001111111100000000000000011111110000000000000000111111000000000000000001111100000000000000000011110000000000000000000111000000000000000000001),
			  // .sm_clk(sm_clk),
			  // .start(Parallel_LFSR_Start),
			  // .finish(all_finish[14]),
			  // .output_parallel_LFSR_bits(all_bit_streams[14]),
			  // .reset(1'b1)
			// ); 

// `else
       // assign all_finish[14] = all_finish[4]; //piggy-back on 101010 finish signal
       // assign all_bit_streams[14] = 1'b0;
// `endif

		// Parallel_LFSR_synchronous
		// #(
		// .LFSR_LENGTH(23),
		// .OUTPUT_WIDTH(output_width)
		// )
		// Parallel_PN23_Gen_inst
		// (
		  // .LFSR_Transition_Matrix(529'b1010010000100001000010001010010000100001000010001010010000100001000011001000010000100001000001001000010000100001000001001000010000100001000001001000010000100001000001001000010000100001100000001000010000100000100000001000010000100000100000001000010000100000100000001000010000100000100000001000010000110000000000001000010000010000000000001000010000010000000000001000010000010000000000001000010000010000000000001000011000000000000000001000001000000000000000001000001000000000000000001000001000000000000000001000001000000000000000001),
		  // .sm_clk(sm_clk),
		  // .start(Parallel_LFSR_Start),
		  // .finish(all_finish[15]),
		  // .output_parallel_LFSR_bits(all_bit_streams[15]),
		  // .reset(1'b1)
		// ); 


always @ (posedge clk)
begin
      out_bit_stream <= all_bit_streams[sel_output_bitstream];
end

assign finish = all_finish[sel_output_bitstream];
endmodule		