`ifndef ADS_42xx_INTEFACE_DEFS_V
`define ADS_42xx_INTEFACE_DEFS_V

interface ads42xx_interface;
        parameter [7:0] num_channels =  2;
		parameter [7:0] num_received_data_pins = 7;
		parameter [7:0] num_recovered_data_bits = num_received_data_pins*2;

		function logic [7:0] get_num_channels();
		    return num_channels;
        endfunction
		
        function logic [7:0] get_num_received_data_pins();
		   return num_received_data_pins;
        endfunction
		
        function logic [7:0] get_num_recovered_data_bits();
		   return num_recovered_data_bits;
        endfunction
		
		logic        received_clk;         
		logic        recovered_clk;  
        logic        recovered_clk_raw;  		
		logic        receive_pll_locked;         
		logic        [num_received_data_pins-1:0] received_data[num_channels];  		
		logic        [num_recovered_data_bits-1:0] recovered_data_raw[num_channels];  		
		logic        [num_recovered_data_bits-1:0] recovered_data[num_channels];  		
endinterface

`endif