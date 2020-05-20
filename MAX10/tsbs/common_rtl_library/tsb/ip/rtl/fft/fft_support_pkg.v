`ifndef FFT_SUPPORT_PKG_V
`define FFT_SUPPORT_PKG_V

		
interface fft_source_avalon_st;
        parameter NUMBITS_PARAMETERS = 16;
        parameter [NUMBITS_PARAMETERS-1:0] numchannels = 1;
		parameter [NUMBITS_PARAMETERS-1:0] bits_per_component;

		function logic [NUMBITS_PARAMETERS-1:0] get_bits_per_component() ;
					return bits_per_component;
		endfunction
        
		function logic [NUMBITS_PARAMETERS-1:0] get_numchannels() ;
					return numchannels;
		endfunction
        
		typedef struct packed {
		logic [bits_per_component-1:0] real_component;
		logic [bits_per_component-1:0] imag_component;
		} complex_data_struct;

		
		typedef struct packed {
		        complex_data_struct complex_data;
				logic sop;
				logic [1:0] error;
				logic eop;
				logic valid;
				logic ready;
		} fft_avst_struct;
	
		fft_avst_struct packet[numchannels];
		
		fft_avst_struct dummy_var;
		
		function logic [NUMBITS_PARAMETERS-1:0] get_bits_per_packet();
					return $bits(dummy_var);
		endfunction
        
endinterface

		
interface fft_source_float_avalon_st;
        parameter NUMBITS_PARAMETERS = 16;
        parameter [NUMBITS_PARAMETERS-1:0] numchannels = 1;
        
		function logic [NUMBITS_PARAMETERS-1:0] get_numchannels() ;
					return numchannels;
		endfunction
        
		typedef struct packed {
		logic [31:0] real_component;
		logic [31:0] imag_component;
		} complex_float_data_struct;

		
		typedef struct packed {
		        complex_float_data_struct complex_data;
				logic sop;
				logic [1:0] error;
				logic eop;
				logic valid;
				logic ready;
		} fft_float_avst_struct;
	
		fft_float_avst_struct packet[numchannels];
		
		fft_float_avst_struct dummy_var;
		
		function logic [NUMBITS_PARAMETERS-1:0] get_bits_per_packet();
					return $bits(dummy_var);
		endfunction
        
endinterface

package fft_support_pkg;

typedef struct {
       logic [31:0] float_real;
	   logic [31:0] float_imag;
} complex_float;

typedef struct {
 complex_float Xr;
 complex_float Xr_plus_N_div_4;
 complex_float Xr_plus_2N_div_4;
 complex_float Xr_plus_3N_div_4;
} fft_x4_complex_float_struct; 

endpackage
`endif