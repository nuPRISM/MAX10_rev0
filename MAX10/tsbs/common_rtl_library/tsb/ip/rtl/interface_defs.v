`ifndef INTEFACE_DEFS_V
`define INTEFACE_DEFS_V

interface generic_tristate_interface;
wire the_tri_signal;
wire in;
wire out;
endinterface

typedef struct 
{
logic tx;
logic rx;
} uart_struct;
    

interface avalon_st_32_bit_packet_interface;
		logic        eop;	
		logic        sop; 
		logic        valid;         
		logic [31:0] data;  
		logic [1:0]  empty; 
		logic        clk;
		logic        error;
		logic        ready;
endinterface

interface avalon_st_streaming_interface;
   parameter [15:0] num_data_bits = 32;
   parameter [15:0] num_bits_per_symbol = 8;
   parameter [15:0] num_error_bits = 1;

   function logic [15:0] get_num_data_bits();
		return num_data_bits;
   endfunction
   
   function logic [15:0] get_num_bits_per_symbol();
		return num_bits_per_symbol;
   endfunction
   function logic [15:0] get_num_error_bits();
		     return num_error_bits;
        endfunction
		logic        valid;         
		logic [num_data_bits-1:0] data;  
		logic        clk;
		logic        ready;
	    logic [$clog2(num_data_bits/num_bits_per_symbol):0]  empty; 
		logic        eop;	
		logic        sop; 
		logic  [num_error_bits-1:0]       error;
endinterface

interface multiple_avalon_st_streaming_interfaces;
        parameter [15:0] num_channels = 32;
		parameter [15:0] num_data_bits = 32;
	    parameter [15:0] num_bits_per_symbol = 8;
		parameter [15:0] num_error_bits = 1;
	    function logic [15:0] get_num_error_bits();
		     return num_error_bits;
        endfunction
		function logic [15:0] get_num_channels();
		    return num_channels;
        endfunction
		
        function logic [15:0] get_num_data_bits();
		   return num_data_bits;
        endfunction
		
		function logic [15:0] get_num_bits_per_symbol();
		     return num_bits_per_symbol;
        endfunction
   
		logic        [num_channels-1:0] valid;         
		logic        [num_data_bits-1:0] data[num_channels];  
		logic        clk;
		logic        [num_channels-1:0] ready;
	    logic [$clog2(num_data_bits/num_bits_per_symbol):0]  empty[num_channels]; 
		logic        [num_channels-1:0] eop;	
		logic        [num_channels-1:0] sop; 
		logic        [num_error_bits-1:0] error;
endinterface

interface multiple_avalon_st_streaming_interfaces_w_independent_clocks;
        parameter [15:0] num_channels = 32;
		parameter [15:0] num_data_bits = 32;
		  parameter [15:0] num_bits_per_symbol = 8;
		  parameter [15:0] num_error_bits = 1;
		function logic [15:0] get_num_channels();
		    return num_channels;
        endfunction
        function logic [15:0] get_num_data_bits();
		   return num_data_bits;
        endfunction
			function logic [15:0] get_num_bits_per_symbol();
		     return num_bits_per_symbol;
        endfunction			
		function logic [15:0] get_num_error_bits();
		     return num_error_bits;
        endfunction
		logic        [num_channels-1:0] valid;         
		logic        [num_data_bits-1:0] data[num_channels];  
		logic        [num_channels-1:0] clk;
		logic        [num_channels-1:0] ready;
		logic        [$clog2(num_data_bits/num_bits_per_symbol):0]  empty[num_channels]; 
		logic        [num_channels-1:0] eop;	
		logic        [num_channels-1:0] sop; 
		logic        [num_error_bits-1:0] error;
endinterface

interface multiple_synced_st_streaming_interfaces;
        parameter [15:0] num_channels = 32;
		parameter [15:0] num_data_bits = 32;
	    parameter [15:0] num_bits_per_symbol = 8;
		parameter [15:0] num_error_bits = 1;
	    function logic [15:0] get_num_error_bits();
		     return num_error_bits;
        endfunction
		function logic [15:0] get_num_channels();
		    return num_channels;
        endfunction
		
        function logic [15:0] get_num_data_bits();
		   return num_data_bits;
        endfunction
		
		function logic [15:0] get_num_bits_per_symbol();
		     return num_bits_per_symbol;
        endfunction
   
		logic        valid;         
		logic        [num_data_bits-1:0] data[num_channels];  
		logic        clk;
		logic        ready;
	    logic [$clog2(num_data_bits/num_bits_per_symbol):0]  empty[num_channels]; 
		logic         eop;	
		logic         sop;
        logic         superframe_start_n;
		logic        [num_error_bits-1:0] error[num_channels];
endinterface


interface multiple_synced_st_streaming_interfaces_w_independent_controls;
        parameter [15:0] num_channels = 32;
		parameter [15:0] num_data_bits = 32;
	    parameter [15:0] num_bits_per_symbol = 8;
		parameter [15:0] num_error_bits = 1;
	    function logic [15:0] get_num_error_bits();
		     return num_error_bits;
        endfunction
		function logic [15:0] get_num_channels();
		    return num_channels;
        endfunction
		
        function logic [15:0] get_num_data_bits();
		   return num_data_bits;
        endfunction
		
		function logic [15:0] get_num_bits_per_symbol();
		     return num_bits_per_symbol;
        endfunction
   
		logic        valid[num_channels];         
		logic        [num_data_bits-1:0] data[num_channels];  
		logic        clk;
		logic        ready[num_channels];
	    logic [$clog2(num_data_bits/num_bits_per_symbol):0]  empty[num_channels]; 
		logic         eop[num_channels];	
		logic         sop[num_channels];
        logic         superframe_start_n[num_channels];
		logic        [num_error_bits-1:0] error[num_channels];
endinterface


interface multiple_2d_synced_st_streaming_interfaces;
        parameter [15:0] num_aggregates = 32;
        parameter [15:0] num_channels = 32;
		parameter [15:0] num_data_bits = 32;
	    parameter [15:0] num_bits_per_symbol = 8;
		parameter [15:0] num_error_bits = 1;
		
		function logic [15:0] get_num_aggregates();
		     return num_aggregates;
        endfunction
		
	    function logic [15:0] get_num_error_bits();
		     return num_error_bits;
        endfunction
		
		function logic [15:0] get_num_channels();
		    return num_channels;
        endfunction
		
        function logic [15:0] get_num_data_bits();
		   return num_data_bits;
        endfunction
		
		function logic [15:0] get_num_bits_per_symbol();
		     return num_bits_per_symbol;
        endfunction
   
		logic        valid[num_aggregates];         
		logic        [num_data_bits-1:0] data[num_aggregates][num_channels];  
		logic        clk;
		logic        ready[num_aggregates];
	    logic [$clog2(num_data_bits/num_bits_per_symbol):0]  empty[num_aggregates][num_channels]; 
		logic         eop[num_aggregates];	
		logic         sop[num_aggregates];
        logic         superframe_start_n[num_aggregates];
		logic        [num_error_bits-1:0] error[num_aggregates][num_channels];
endinterface

interface atlantic_32_bit_packet_interface;
		logic        eop;	
		logic        sop; 
		logic        ena;         
		logic        dav;         
		logic [31:0] dat;  
		logic [1:0]  mty; 
		logic        clk;
		logic        err;
		logic [7:0]  adr;
		logic        val;
endinterface

interface simple_atlantic_streaming_interface;
        parameter [15:0] numdatabits = 32;
		function logic [15:0] get_num_data_bits();
		    return numdatabits;
        endfunction
		logic        ena;         
		logic        dav;         
		logic [numdatabits-1:0] dat;  
		logic        clk;		
endinterface

interface generic_spi_interface;
    logic  base_high_speed_clk;
    logic  spi_clk;
 	logic  [7:0] spi_csn;
	logic  spi_sdi;
	logic  spi_sdo;
	logic  spi_sdio_oe_n;
	logic  spi_sdio_oe;
	logic  spi_reset;
	logic  this_spi_interface_is_currently_active;
	logic [7:0] tx_bit_pos;	
	logic [7:0] rx_bit_pos;	
	logic [7:0] cnt       ;	
	logic [7:0] debug_tag;
	logic [7:0] debug_tag_in;
	logic [31:0] aux_in;
	logic [31:0] aux_out;
endinterface

interface wishbone_interface;
			parameter [15:0] num_address_bits = 32;
			parameter [15:0] num_data_bits = 32;
			parameter [15:0] num_sel_bits = (num_data_bits/8);		

            function logic [15:0] get_num_data_bits();
		       return num_data_bits;
            endfunction
			
            function logic [15:0] get_num_address_bits();
		       return num_address_bits;
            endfunction
		
		    function logic [15:0] get_num_sel_bits();
		       return num_sel_bits;
            endfunction
			
			logic [num_address_bits-1:0] wbs_adr_i;
			logic                        wbs_bte_i;
			logic                        wbs_cti_i;
			logic                        wbs_cyc_i;
			logic [num_data_bits-1:0]    wbs_dat_i;
			logic [num_sel_bits-1:0]     wbs_sel_i;
			logic                        wbs_stb_i;
			logic                        wbs_we_i ;
			logic                        wbs_ack_o;
			logic                        wbs_err_o;
			logic                        wbs_rty_o;
			logic [num_data_bits-1:0]    wbs_dat_o;
			logic clk;
endinterface

interface avalon_mm_pipeline_bridge_interface;
		parameter [15:0] num_address_bits = 32;
		parameter [15:0] num_data_bits = 32;

		function logic [15:0] get_num_data_bits();
		   return num_data_bits;
		endfunction
		
		function logic [15:0] get_num_address_bits();
		   return num_address_bits;
		endfunction
		
	    logic        waitrequest  ;
		logic [num_data_bits-1:0] readdata     ;
		logic        readdatavalid;
		logic [0:0]  burstcount   ;
		logic [num_data_bits-1:0] writedata    ;
		logic [num_address_bits-1:0]  address;
		logic        write        ;
		logic        read         ;
		logic [(num_data_bits/8)-1:0]  byteenable   ;
		logic        debugaccess  ;
		logic        clk          ;
endinterface

interface avalon_mm_simple_bridge_interface;
		parameter [15:0] num_address_bits = 32;
		parameter [15:0] num_data_bits = 32;


		function logic [15:0] get_num_data_bits();
		   return num_data_bits;
		endfunction
		
		function logic [15:0] get_num_address_bits();
		   return num_address_bits;
		endfunction
		
		
	    logic        waitrequest  ;
		logic [num_data_bits-1:0] readdata     ;
		logic [num_data_bits-1:0] writedata    ;
		logic [num_address_bits-1:0]  address;
		logic        write        ;
		logic        read         ;
		logic        readdatavalid         ;
		logic [(num_data_bits/8)-1:0]  byteenable   ;
		logic        clk          ;
endinterface

interface altera_up_external_bus_interface;
		parameter [15:0] num_address_bits = 32;
		parameter [15:0] num_data_bits = 32;
		
		
		function logic [15:0] get_num_data_bits();
		   return num_data_bits;
		endfunction
		
		function logic [15:0] get_num_address_bits();
		   return num_address_bits;
		endfunction
		
		logic                            acknowledge          ;
		logic                            irq                  ;
		logic [num_address_bits-1:0]     address              ;
		logic                            bus_enable           ;
		logic [(num_data_bits/8)-1:0]    byte_enable          ;
		logic                            rw                   ;
		logic [num_data_bits-1:0]        write_data           ;
		logic [num_data_bits-1:0]        read_data            ;
endinterface

interface data_acq_fifo_interface;
        parameter [15:0] in_data_bits = 16;
        parameter [15:0] out_data_bits = 16;
		parameter [15:0] input_to_output_ratio = in_data_bits/out_data_bits;
		parameter [15:0] num_locations_in_fifo = 16384;
        parameter [15:0] num_words_bits = $clog2(num_locations_in_fifo);
		parameter [15:0] num_input_locations = (num_locations_in_fifo/input_to_output_ratio);
        parameter [15:0] num_wrusedw_bits = $clog2(num_input_locations);
        parameter [15:0] num_rdusedw_bits = num_words_bits;
		
		function logic [15:0] get_in_data_bits();
		   return in_data_bits;
		endfunction
		
		function logic [15:0] get_out_data_bits();
		   return out_data_bits;
		endfunction
		
		function logic [15:0] get_num_locations_in_fifo();
		   return num_locations_in_fifo;
		endfunction
		
		function logic [15:0] get_num_words_bits();
		   return num_words_bits;
		endfunction
		
		function logic [15:0] get_num_wrusedw_bits();
		   return num_wrusedw_bits;
		endfunction
		
		function logic [15:0] get_num_rdusedw_bits();
		   return num_rdusedw_bits;
		endfunction
		function logic [15:0] get_input_to_output_ratio();
		   return input_to_output_ratio;
		endfunction				
		
		function logic [15:0] get_num_input_locations();
		   return num_input_locations;
		endfunction		
		
        logic [in_data_bits-1:0] data;
        logic rdclk   ;
        logic rdreq   ;
        logic wrclk   ;
        logic wrreq   ;
        logic [out_data_bits-1:0] q;
        logic rdempty ;
        logic rdfull  ;
        logic wrempty ;
        logic wrfull  ;
        logic [num_wrusedw_bits-1:0] wrusedw;
        logic [num_rdusedw_bits-1:0] rdusedw;
endinterface



interface multi_data_acq_fifo_interface;
        parameter [15:0] num_fifos = 2;
        parameter [15:0] in_data_bits = 16;
        parameter [15:0] out_data_bits = 16;
		parameter [15:0] input_to_output_ratio = in_data_bits/out_data_bits;
		parameter [15:0] num_locations_in_fifo = 16384;
        parameter [15:0] num_words_bits = $clog2(num_locations_in_fifo);
		parameter [15:0] num_input_locations = (num_locations_in_fifo/input_to_output_ratio);
        parameter [15:0] num_wrusedw_bits = $clog2(num_input_locations);
        parameter [15:0] num_rdusedw_bits = num_words_bits;
		
		function logic [15:0] get_in_data_bits();
		   return in_data_bits;
		endfunction
		
		function logic [15:0] get_out_data_bits();
		   return out_data_bits;
		endfunction
		
		function logic [15:0] get_num_locations_in_fifo();
		   return num_locations_in_fifo;
		endfunction
		
		function logic [15:0] get_num_words_bits();
		   return num_words_bits;
		endfunction
		
		function logic [15:0] get_num_wrusedw_bits();
		   return num_wrusedw_bits;
		endfunction
		
		function logic [15:0] get_num_rdusedw_bits();
		   return num_rdusedw_bits;
		endfunction
		function logic [15:0] get_input_to_output_ratio();
		   return input_to_output_ratio;
		endfunction				
		
		function logic [15:0] get_num_input_locations();
		   return num_input_locations;
		endfunction		
		
        logic [in_data_bits-1:0] data[num_fifos];
        logic rdclk[num_fifos]   ;
        logic rdreq[num_fifos]   ;
        logic wrclk[num_fifos]   ;
        logic wrreq[num_fifos]   ;
        logic [out_data_bits-1:0] q[num_fifos];
        logic rdempty[num_fifos] ;
        logic rdfull[num_fifos]  ;
        logic wrempty[num_fifos] ;
        logic wrfull[num_fifos]  ;
        logic [num_wrusedw_bits-1:0] wrusedw[num_fifos];
        logic [num_rdusedw_bits-1:0] rdusedw[num_fifos];
endinterface


interface fifo_bank_interface;
			parameter [15:0] DATA_BITWIDTH = 12;
			parameter [15:0] NUM_CHANNELS = 24;
			parameter [15:0] FIFO_WIDTH = 16;
			parameter [15:0] FIFO_NUMBITS_ADDR_COUNT = 11;
			logic [DATA_BITWIDTH-1:0] data_to_fifos[NUM_CHANNELS-1:0];
			logic clk;
			logic [31:0] FIFO_Flags   [NUM_CHANNELS-1:0];
			logic [7:0]  FIFO_Control [NUM_CHANNELS-1:0];
			logic [31:0] FIFO_data_out[NUM_CHANNELS-1:0];
			logic [NUM_CHANNELS-1:0] trigger_mechanism_rdreq;
			logic [NUM_CHANNELS-1:0] trigger_mechanism_rdclk;
			logic [NUM_CHANNELS-1:0] trigger_mechanism_disable_wrclk;        
			logic [NUM_CHANNELS-1:0] trigger_mechanism_enable_feedthrough; 
			wire  [FIFO_NUMBITS_ADDR_COUNT-1:0] FIFO_threshold_for_auto_read_start;
			logic [NUM_CHANNELS-1:0] clear_fifos;
			wire  [NUM_CHANNELS-1:0] select_processor_control_of_FIFO;
			wire  [NUM_CHANNELS-1:0] select_other_binary_format_of_FIFO_data;
endinterface

interface external_hw_dma_interface;		 
    parameter [15:0] NUM_USER_PREAMBLE_WORDS = 6;
	
	function logic [15:0] get_num_user_preamble_words();
	  return NUM_USER_PREAMBLE_WORDS;
	endfunction		
		
 	logic [31:0] external_user_preamble_words[NUM_USER_PREAMBLE_WORDS-1:0];
	logic        external_trigger;
    logic [15:0] external_dma_first_descriptor_number;
	logic [15:0] external_dma_num_descriptors;
	logic [31:0] external_smartbuf_retransmit_address;
	logic [31:0] external_smartbuf_retransmit_length;
	logic        external_retransmit_now;
	logic hw_retransmission_in_progress;
	logic dma_clk;
	logic external_clk;
	
endinterface

interface dual_dac_interface;
		parameter [15:0] data_width = 16;
		parameter [15:0] num_selection_bits = 4;
		parameter [15:0] actual_num_selections = 2**num_selection_bits;	
			
		
        function logic [15:0] get_data_width();
		       return data_width;
		endfunction
		
		function logic [15:0] get_num_selection_bits();
		       return num_selection_bits;
		endfunction
		
		function logic [15:0] get_actual_num_selections();
		       return actual_num_selections;
		endfunction

		logic [127:0] dac0_descriptions[actual_num_selections];
		logic [127:0] dac1_descriptions[actual_num_selections];
		logic [num_selection_bits-1:0] select_channel_to_DAC0;
		logic [num_selection_bits-1:0] select_channel_to_DAC1;
		logic [data_width-1:0]                     selected_channel_to_DAC0;
		logic [data_width-1:0]                     selected_channel_to_DAC1;
		logic                                      valid_to_DAC0;
		logic                                      valid_to_DAC1;
		logic                                      selected_clk_to_DAC0    ;
		logic                                      selected_clk_to_DAC1    ;
endinterface

interface multi_dac_interface;
        parameter [15:0] num_dacs = 2;
		parameter [15:0] data_width = 16;
		parameter [15:0] num_selection_bits = 4;
		parameter [15:0] actual_num_selections = 2**num_selection_bits;
		
		 function logic [15:0] get_num_dacs();
		       return num_dacs;
		endfunction
		
     
        function logic [15:0] get_data_width();
		       return data_width;
		endfunction
		
		function logic [15:0] get_num_selection_bits();
		       return num_selection_bits;
		endfunction
		
		function logic [15:0] get_actual_num_selections();
		       return actual_num_selections;
		endfunction

		logic [127:0] dac_descriptions[num_dacs][actual_num_selections];
		logic [num_selection_bits-1:0] select_channel_to_dac[num_dacs];
		logic [data_width-1:0]                     selected_channel_to_dac[num_dacs];
		logic                                      valid_to_dac[num_dacs];
		logic                                      selected_clk_to_dac[num_dacs];
endinterface


interface multi_data_stream_interface;
        parameter [15:0] num_data_streams = 2;
		parameter [15:0] data_width = 16;
		parameter [15:0] num_description_bits = 128;
		
		 function logic [15:0] get_num_data_streams();
		       return num_data_streams;
		endfunction
		
     
        function logic [15:0] get_data_width();
		       return data_width;
		endfunction
		
        function logic [15:0] get_num_description_bits();
		       return num_description_bits;
		endfunction
		
		logic [num_description_bits-1:0] desc[num_data_streams];
		logic [data_width-1:0]           data[num_data_streams];
		logic                            valid;
		logic                            superframe_start_n;
		logic                            clk;
endinterface

interface multi_input_stream_interface;
        parameter [15:0] num_streams = 2;
		parameter [15:0] data_width = 16;
		parameter [15:0] num_description_bits = 128;
		
		 function logic [15:0] get_num_streams();
		       return num_streams;
		endfunction
		     
        function logic [15:0] get_data_width();
		       return data_width;
		endfunction
		     
        function logic [15:0] get_num_description_bits();
		       return num_description_bits;
		endfunction
		
		logic [num_description_bits-1:0]     dac_descriptions[num_streams];
		logic [data_width-1:0]               data[num_streams];
		logic                                valid;
		logic                                clk;
endinterface

interface generic_multi_lane_seriallite_phy_interface;
parameter [15:0] numlanes = 4;
parameter [15:0] numcolumns = 4;

        function logic [15:0] get_numlanes();
		       return numlanes;
		endfunction
		
		function logic [15:0] get_numcolumns();
		       return numcolumns;
		endfunction


		 logic          tx_ready                       ;
		 logic          rx_ready                       ;
		 logic [0:0]    pll_ref_clk                    ;
		 logic [numlanes-1:0]    tx_serial_data                 ;
		 logic [numlanes-1:0]    tx_forceelecidle               ;
		 logic [0:0]    pll_locked                     ;
		 logic [numlanes-1:0]    rx_serial_data                 ;
		 logic [numlanes*numcolumns-1:0]   rx_runningdisp                 ;
		 logic [numlanes*numcolumns-1:0]   rx_disperr                     ;
		 logic [numlanes*numcolumns-1:0]   rx_errdetect                   ;
		 logic [numlanes-1:0]    rx_is_lockedtoref              ;
		 logic [numlanes-1:0]    rx_is_lockedtodata             ;
		 logic [numlanes-1:0]    rx_signaldetect                ;
		 logic [numlanes*numcolumns-1:0]   rx_patterndetect               ;
		 logic [numlanes*numcolumns-1:0]   rx_syncstatus                  ;
		 logic [numlanes*5-1:0]   rx_bitslipboundaryselectout    ;
		 logic [numlanes-1:0]    rx_rlv                         ;
		 logic [numlanes-1:0]    tx_coreclkin                   ;
		 logic [numlanes-1:0]    rx_coreclkin                   ;
		 logic [numlanes-1:0]    tx_clkout                      ;
		 logic [numlanes-1:0]    rx_clkout                      ;
		 logic [numlanes*numcolumns*8-1:0]  tx_parallel_data               ;
		 logic [numlanes*numcolumns-1:0]   tx_datak                       ;
		 logic [numlanes*numcolumns*8-1:0]  rx_parallel_data               ;
		 logic [numlanes*numcolumns-1:0]   rx_datak                       ;
endinterface 	


interface multi_spi_interface;
  parameter [15:0] numlanes = 4;
  function logic [15:0] get_numlanes();
	       return numlanes;
  endfunction
  logic  	[numlanes-1:0]   cs          ;    // spi cs
  logic 	[numlanes-1:0]   sclk        ;  // spi clock input
  logic     [numlanes-1:0]   mosi        ;    // spi slave input
  logic 	[numlanes-1:0]   cpol        ;
  logic 	[numlanes-1:0]   cpha        ;
    
//CPOL = 0 sclk has to be pull down before CS is down
//CPHA = 1 means that the data has to be taken on the first edge of the sclk
		 // in the case of CPOL =0 it has to be taken at the rising edge
		 // in case CPOL = 1 it has to be taken on the falling edge
//CPHA =0  means that the data has to be taken on the second edge of sclk
		 // in case of CPOL =0, it is taken at the falling edge
		 // in case CPOL = 1, it has to be taken on the rising edge.
		 
endinterface


`endif