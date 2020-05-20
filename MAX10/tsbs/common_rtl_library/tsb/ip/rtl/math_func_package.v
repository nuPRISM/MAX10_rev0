`ifndef MATH_FUNC_PACKAGE_V
`define MATH_FUNC_PACKAGE_V

package math_func_package;
    localparam  ZERO_IN_ASCII = 48;
	function automatic int my_clog2 (input int n);
						int original_n;
						original_n = n;
						if (n <=1) return 1; // abort function
						my_clog2 = 0;
						while (n > 1) begin
						    n = n/2;
						    my_clog2++;
						end
						
						if (2**my_clog2 != original_n)
						begin
						     my_clog2 = my_clog2 + 1;
						end
						
						endfunction
						
						
						function automatic bit [7:0] get_second_digit_as_ascii(input int x);
								    get_second_digit_as_ascii = ((x/10)+ZERO_IN_ASCII);
						endfunction
						
						function  automatic bit [7:0] get_first_digit_as_ascii(input int x);
						            get_first_digit_as_ascii = ((x % 10)+ZERO_IN_ASCII);
	endfunction
	
	
	typedef enum bit [3:0]  {
		UNSIGNED_FORMAT_ENUM_VAL = 4'd0,
		TWOS_COMPLEMENT_FORMAT_ENUM_VAL = 4'd1,
		SIGN_MAGNITUDE_FORMAT_ENUM_VAL = 4'd2,
		FLOATING_POINT_32BIT_FORMAT_ENUM_VAL = 4'd3,
		FLOATING_POINT_64BIT_FORMAT_ENUM_VAL = 4'd4,
		FLOATING_POINT_COMPLEX_REAL_AND_IMAG_EACH_32_BIT_FORMAT_ENUM_VAL = 4'd5,
		FIXED_COMPLEX_REAL_AND_IMAG_EACH_32_BIT_FORMAT_ENUM_VAL = 4'd6		
	} math_format_type;
	
	typedef enum bit [15:0]  {
	    SPIRAL_FFT_UNSCALED_32BIT_4096_ITERATIVE_FFT = 16'd0,
		SPIRAL_FFT_UNSCALED_32BIT_4096_STREAMING_FFT = 16'd1,
		SPIRAL_FFT_SCALED_16BIT_4096_ITERATIVE_FFT = 16'd2,
		SPIRAL_FFT_SCALED_16BIT_4096_STREAMING_FFT = 16'd3,
		SPIRAL_FFT_UNSCALED_32BIT_8192_STREAMING_FFT = 16'd4,
		SPIRAL_FFT_SCALED_16BIT_8192_STREAMING_D_FFT = 16'd5,
		SPIRAL_FFT_SCALED_16BIT_8192_STREAMING_J_FFT = 16'd6
	} FFT_IMPLEMENTATION_METHOD_ENUM_TYPE;
	
	function automatic int get_num_of_fft_samples(FFT_IMPLEMENTATION_METHOD_ENUM_TYPE fft_type);
	   if ((fft_type == SPIRAL_FFT_UNSCALED_32BIT_8192_STREAMING_FFT) 
	   || (fft_type == SPIRAL_FFT_SCALED_16BIT_8192_STREAMING_D_FFT) 
	   || (fft_type == SPIRAL_FFT_SCALED_16BIT_8192_STREAMING_J_FFT) )
	       return 8192;
	   else
	       return 4096;
	
	endfunction
	
	
endpackage
`endif