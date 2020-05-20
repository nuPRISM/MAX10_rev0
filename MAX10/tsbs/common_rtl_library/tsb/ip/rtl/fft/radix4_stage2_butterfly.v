`default_nettype none
`include "fft_support_pkg.v"
import fft_support_pkg::*;

module radix4_stage2_butterfly 
(
input complex_float butterfly_out_Yr_plus_WN_2r_Gr,
input complex_float butterfly_out_Yr_minus_WN_2r_Gr,
input complex_float butterfly_out_WN_r_Zr_plus_WN_3r_Hr,
input complex_float butterfly_out_WN_r_Zr_minus_WN_3r_Hr,
output complex_float Xr,
output complex_float Xr_plus_N_div_4 ,
output complex_float Xr_plus_2N_div_4,
output complex_float Xr_plus_3N_div_4,
input reset,
input clk
);



/////////////////////////////////////
//
//
//        Xr
//
//
//


	fp_adder make_Xr_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_plus_WN_2r_Gr.float_real),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_real),      //      b.b
		.q      (Xr.float_real)       //      q.q
	);


	fp_adder make_Xr_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_plus_WN_2r_Gr.float_imag),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_imag),      //      b.b
		.q      (Xr.float_imag)       //      q.q
	);


/////////////////////////////////////
//
//
//        Xr_plus_N_div_4
//
//
//


	fp_adder make_Xr_plus_N_div_4_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_minus_WN_2r_Gr.float_real),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_imag),      //      b.b
		.q      (Xr_plus_N_div_4.float_real)       //      q.q
	);


	fp_subtract make_Xr_plus_N_div_4_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_minus_WN_2r_Gr.float_imag),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_real),      //      b.b
		.q      (Xr_plus_N_div_4.float_imag)       //      q.q
	);
	
	

/////////////////////////////////////
//
//
//         Xr_plus_2N_div_4
//
//
//


	fp_subtract make_Xr_plus_2N_div_4_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_plus_WN_2r_Gr.float_real),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_real),      //      b.b
		.q      (Xr_plus_2N_div_4.float_real)       //      q.q
	);


	fp_subtract make_Xr_plus_2N_div_4_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_plus_WN_2r_Gr.float_imag),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_imag),      //      b.b
		.q      (Xr_plus_2N_div_4.float_imag)       //      q.q
	);


/////////////////////////////////////
//
//
//         Xr_plus_3N_div_4
//
//
//


	fp_subtract make_Xr_plus_3N_div_4_real (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_minus_WN_2r_Gr.float_real),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_imag),      //      b.b
		.q      (Xr_plus_3N_div_4.float_real)       //      q.q
	);


	fp_adder make_Xr_plus_3N_div_4_imag (
		.clk,    //    clk.clk
		.areset (reset), // areset.reset
		.a      (butterfly_out_Yr_minus_WN_2r_Gr.float_imag),      //      a.a
		.b      (butterfly_out_WN_r_Zr_plus_WN_3r_Hr.float_real),      //      b.b
		.q      (Xr_plus_3N_div_4.float_imag)       //      q.q
	);

endmodule
`default_nettype wire