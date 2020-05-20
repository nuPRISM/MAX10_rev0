`ifndef JESD204B_A10_INTEFACE_DEFS_V
`define JESD204B_A10_INTEFACE_DEFS_V


interface jesd_parameter_struct;
   parameter NUMBITS_PARAMETERS = 8;

	parameter  [NUMBITS_PARAMETERS - 1 : 0] LINK              = 1;  // Number of links, a link composed of multiple lanes
	parameter  [NUMBITS_PARAMETERS - 1 : 0] L                 = 2;  // Number of lanes per converter device
	parameter  [NUMBITS_PARAMETERS - 1 : 0] M                 = 2;  // Number of converters per converter device
	parameter  [NUMBITS_PARAMETERS - 1 : 0] F                 = 2;  // Number of octets per frame
	parameter  [NUMBITS_PARAMETERS - 1 : 0] S                 = 1;  // Number of transmitter samples per converter per frame
	parameter  [NUMBITS_PARAMETERS - 1 : 0] N                 = 16; // Number of converter bits per converter
	parameter  [NUMBITS_PARAMETERS - 1 : 0] N_PRIME           = 16; // Number of transmitted bits per sample
	parameter   [NUMBITS_PARAMETERS - 1 : 0]CS                = 0;  // Number of control bits per conversion sample				 
	parameter   [NUMBITS_PARAMETERS - 1 : 0]F1_FRAMECLK_DIV   = 2;  // Frame clk divider for transport layer when F=1. Valid value = 1 or 4. Default parameter used in all F value scenarios.
	parameter   [NUMBITS_PARAMETERS - 1 : 0]F2_FRAMECLK_DIV   = 2;  // Frame clk divider for transport layer when F=2. Valid value = 1 or 2. For F=4 & 8, this parameter is not used.

	function logic [NUMBITS_PARAMETERS - 1 : 0] get_LINK                      ();  return         LINK    ; endfunction  // Number of links, a link composed of multiple lanes
	function logic [NUMBITS_PARAMETERS - 1 : 0] get_L                         ();  return         L       ; endfunction  // Number of lanes per converter device
	function logic [NUMBITS_PARAMETERS - 1 : 0] get_M                         ();  return         M       ; endfunction  // Number of converters per converter device
	function logic [NUMBITS_PARAMETERS - 1 : 0] get_F                         ();  return         F       ; endfunction  // Number of octets per frame
	function logic [NUMBITS_PARAMETERS - 1 : 0] get_S                         ();  return         S       ; endfunction  // Number of transmitter samples per converter per frame
	function logic [NUMBITS_PARAMETERS - 1 : 0] get_N                         ();  return         N       ; endfunction // Number of converter bits per converter
	function logic [NUMBITS_PARAMETERS - 1 : 0] get_N_PRIME                   ();  return         N_PRIME ; endfunction // Number of transmitted bits per sample 
	function logic [NUMBITS_PARAMETERS - 1 : 0] get_CS                        ();  return         CS      ; endfunction  // Number of control bits per conversion sample				 
    function logic [NUMBITS_PARAMETERS - 1 : 0] get_F1_FRAMECLK_DIV           ();  return         F1_FRAMECLK_DIV; endfunction  // Number of control bits per conversion sample				 
    function logic [NUMBITS_PARAMETERS - 1 : 0] get_F2_FRAMECLK_DIV           ();  return         F2_FRAMECLK_DIV; endfunction  // Number of control bits per conversion sample				 

endinterface			

interface jesd204b_a10_interface;

   // --------------------------------------------------
   // Calculates the divceil of the input value (m/n)
   // --------------------------------------------------
   function integer divceil;
      input integer m;
      input integer n;
      integer i;

      begin
         i = m % n;
         divceil = (m/n);

         if (i > 0) begin
            divceil = divceil + 1;
         end

      end
   endfunction


       parameter  NUMBITS_PARAMETERS = 8;
	   parameter [NUMBITS_PARAMETERS - 1 : 0] LINK              = 1 ;  // Number of links, a link composed of multiple lanes
	   parameter [NUMBITS_PARAMETERS - 1 : 0] L                 = 2 ;  // Number of lanes per converter device
	   parameter [NUMBITS_PARAMETERS - 1 : 0] M                 = 2 ;  // Number of converters per converter device
	   parameter [NUMBITS_PARAMETERS - 1 : 0] F                 = 2 ;  // Number of octets per frame
	   parameter [NUMBITS_PARAMETERS - 1 : 0] S                 = 1 ;  // Number of transmitter samples per converter per frame
	   parameter [NUMBITS_PARAMETERS - 1 : 0] N                 = 16; // Number of converter bits per converter
	   parameter [NUMBITS_PARAMETERS - 1 : 0] N_PRIME           = 16; // Number of transmitted bits per sample 
	   parameter [NUMBITS_PARAMETERS - 1 : 0] CS                = 0 ;  // Number of control bits per conversion sample				 
       parameter F1_FRAMECLK_DIV                                = 2 ;  // Frame clk divider for transport layer when F=1. Valid value = 1 or 4. Default parameter used in all F value scenarios.
       parameter F2_FRAMECLK_DIV                                = 2 ;  // Frame clk divider for transport layer when F=2. Valid value = 1 or 2. For F=4 & 8, this parameter is not used.
       parameter [NUMBITS_PARAMETERS - 1 : 0] XCVR_PLL_PER_LINK             = divceil(L, 5);       
       parameter FRAMECLK_DIV = (F == 1) ? F1_FRAMECLK_DIV : ((F == 2) ? F2_FRAMECLK_DIV : 1);

       parameter TL_DATA_BUS_WIDTH    = (F==8)? (8*F*L*N/N_PRIME) : (F==4)? (8*F*L*N/N_PRIME) : (F==2) ? (F2_FRAMECLK_DIV*8*F*L*N/N_PRIME) : (F==1) ? (F1_FRAMECLK_DIV*8*F*L*N/N_PRIME) : 1;
       parameter TL_CONTROL_BUS_WIDTH = ( (CS==0) ? 1 : (TL_DATA_BUS_WIDTH/N*CS) ); 

       parameter ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH          = TL_DATA_BUS_WIDTH*N_PRIME/(M*N);
       parameter ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH    = N_PRIME;
       parameter ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH    = N;
       parameter NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK               = ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH / N_PRIME;
	   
	   
	   
	   
	   
	   
	   
	   
	   

	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_LINK                      ();  return         LINK    ; endfunction          
	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_L                         ();  return         L       ; endfunction          
	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_M                         ();  return         M       ; endfunction          
	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_F                         ();  return         F       ; endfunction          
	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_S                         ();  return         S       ; endfunction          
	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_N                         ();  return         N       ; endfunction          
	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_N_PRIME                   ();  return         N_PRIME ; endfunction          
	   function logic [NUMBITS_PARAMETERS - 1 : 0] get_CS                        ();  return         CS      ; endfunction          	 
       function logic [NUMBITS_PARAMETERS - 1 : 0] get_XCVR_PLL_PER_LINK         ();  return         XCVR_PLL_PER_LINK; endfunction  
       function logic [31 : 0] get_F1_FRAMECLK_DIV           ();  return         F1_FRAMECLK_DIV; endfunction                       	 
       function logic [31 : 0] get_F2_FRAMECLK_DIV           ();  return         F2_FRAMECLK_DIV; endfunction                        
       function logic [31 : 0] get_FRAMECLK_DIV           ();  return              FRAMECLK_DIV; endfunction                          	 
       function logic [31 : 0] get_TL_DATA_BUS_WIDTH              ();  return          TL_DATA_BUS_WIDTH   ; endfunction            		 
       function logic [31 : 0] get_TL_CONTROL_BUS_WIDTH           ();  return          TL_CONTROL_BUS_WIDTH; endfunction            	 
       function logic [31 : 0]  get_ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH           (); return ONE_CONVERTER_IN_PARALLEL_PADDED_BIT_WIDTH         ; endfunction
       function logic [31 : 0]  get_ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH   	 (); return ONE_CONVERTER_SINGLE_DATA_VALUE_PADDED_BIT_WIDTH   ; endfunction
       function logic [31 : 0]  get_ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH   	 (); return ONE_CONVERTER_SINGLE_DATA_VALUE_ACTUAL_BIT_WIDTH   ; endfunction
       function logic [31 : 0]  get_NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK              	 (); return NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK              ; endfunction
	  

		   logic [LINK-1:0][L-1:0]                     tx_serial_data_reordered;
		   logic [LINK-1:0][L-1:0]                     rx_serial_data_reordered;
		   logic [31:0]                                io_control;
		   logic [31:0]                                io_status;
		   logic                                       core_pll_locked;
		   logic [LINK-1:0][XCVR_PLL_PER_LINK-1:0]     xcvr_pll_locked;
		   logic [LINK-1:0][L-1:0]                     xcvr_pll_locked_bus;
		   logic [LINK-1:0][L-1:0]                     xcvr_rst_ctrl_tx_ready;
		   logic [LINK-1:0][L-1:0]                     xcvr_rst_ctrl_rx_ready;
		   logic [LINK-1:0][L-1:0]                     rx_seriallpbken;
		   logic [LINK-1:0][L-1:0]                     rxphy_clk;
		   logic [LINK-1:0][L-1:0]                     txphy_clk;
		   logic [LINK-1:0][L-1:0]                     rx_csr_lane_powerdown;
		   logic [LINK-1:0][4:0]                       rx_csr_np;
		   logic [LINK-1:0]                            rx_csr_hd;
		   logic [LINK-1:0][1:0]                       rx_csr_cs;
		   logic [LINK-1:0][4:0]                       rx_csr_cf;
		   logic [LINK-1:0][4:0]                       rx_csr_s;
		   logic [LINK-1:0][4:0]                       rx_csr_n;
		   logic [LINK-1:0][7:0]                       rx_csr_m;
		   logic [LINK-1:0][4:0]                       rx_csr_l;
		   logic [LINK-1:0][4:0]                       rx_csr_k;
		   logic [LINK-1:0][7:0]                       rx_csr_f;
		   logic [LINK-1:0][L-1:0]                     tx_csr_lane_powerdown;
		   logic [LINK-1:0][4:0]                       tx_csr_cf;
		   logic [LINK-1:0]                            tx_csr_hd;
		   logic [LINK-1:0][4:0]                       tx_csr_s;
		   logic [LINK-1:0][4:0]                       tx_csr_np;
		   logic [LINK-1:0][4:0]                       tx_csr_n;
		   logic [LINK-1:0][1:0]                       tx_csr_cs;
		   logic [LINK-1:0][7:0]                       tx_csr_m;
		   logic [LINK-1:0][4:0]                       tx_csr_k;
		   logic [LINK-1:0][7:0]                       tx_csr_f;
		   logic [LINK-1:0][4:0]                       tx_csr_l;
		   logic [LINK-1:0][3:0]                       csr_tx_testmode;
		   logic [LINK-1:0][3:0]                       csr_rx_testmode;
		   logic [LINK-1:0]                            rx_dev_sync_n;
		   logic [LINK-1:0]                            sync_n;
		   logic [LINK-1:0]                            dev_lane_aligned;
		   logic                                       alldev_lane_aligned;
		   logic [LINK-1:0]                            mdev_sync_n;
		   logic [LINK-1:0]                            tx_dev_sync_n;
		   logic [LINK-1:0]                            tx_sysref;
		   logic [LINK-1:0]                            rx_sysref;
		   logic                                       sysref;

		  logic [LINK*L-1:0]                          rx_analogreset;
	      logic [LINK*L-1:0]                          rx_digitalreset;
	      logic [LINK*L-1:0]                          rx_cal_busy;
	      logic [LINK*L-1:0]                          rx_is_lockedtodata;
		  
		  logic [LINK*L-1:0]                          tx_analogreset;
	      logic [LINK*L-1:0]                          tx_digitalreset;
	      logic [LINK*L-1:0]                          tx_cal_busy;
		   
		   
		  logic [LINK-1:0][(L*32)-1:0]                jesd204_tx_link_data;
		  logic [LINK-1:0]                            jesd204_tx_link_valid;
		  logic [LINK-1:0][(L*32)-1:0]                jesd204_rx_link_data;
		  logic [LINK-1:0]                            jesd204_rx_link_valid;
		  logic [LINK-1:0]                            jesd204_rx_link_ready;
		  logic [LINK-1:0]                            jesd204_tx_frame_error;
		  logic [LINK-1:0]                            jesd204_tx_frame_ready;
		  logic [LINK-1:0]                            jesd204_rx_frame_error;
		  logic [LINK-1:0][15:0]                      jesd204_rx_dlb_disperr;
		  logic [LINK-1:0][15:0]                      jesd204_rx_dlb_errdetect;
		  logic [LINK-1:0][15:0]                      jesd204_rx_dlb_kchar_data;
		  logic [LINK-1:0][3:0]                       jesd204_rx_dlb_data_valid;
		  logic [LINK-1:0][127:0]                     jesd204_rx_dlb_data;
          
		  logic [LINK-1:0][TL_DATA_BUS_WIDTH-1:0]     avst_usr_din_reordered;

		  logic                                       device_clk;
		  logic                                       link_clk;
		  logic                                       frame_clk;
		  logic                                       frame_clk_x2;
          logic                                       jesd_2x_conversion_transpose_input_data_halves ;
		  logic									      jesd_2x_conversion_transpose_output_data_halves;
		  logic									      invert_superframe_start;
												   

		  logic [LINK-1:0]                            tx_link_rst_n;
		  logic [LINK-1:0]                            rx_link_rst_n;
		  logic [LINK-1:0]                            tx_frame_rst_n;
		  logic [LINK-1:0]                            rx_frame_rst_n;
          
		  logic [LINK-1:0]                            all_tx_ready;
		  logic [LINK-1:0]                            all_rx_ready;
		  logic [LINK-1:0]                            tx_xcvr_ready_in;
		  logic [LINK-1:0]                            rx_xcvr_ready_in;
		  
		  
		     // Av-ST user Data
		  logic [LINK*TL_DATA_BUS_WIDTH-1:0]     avst_usr_din;
		  logic [LINK-1:0]                       avst_usr_din_valid;
		  logic [LINK-1:0]                       avst_usr_din_ready;
		  logic [LINK*TL_DATA_BUS_WIDTH-1:0]     avst_usr_dout;
		  logic [LINK-1:0]                       avst_usr_dout_valid;
		  logic [LINK-1:0]                       avst_usr_dout_ready;
		  logic [LINK-1:0]                       avst_patchk_data_error;

		  
		  logic                                       sel_manual_sysref;
		  logic                                       manual_sysref;
		  logic                                       tie_sync_n_together;
		  logic                                       sync_sync_n_to_sysref;
		  logic [LINK-1:0]                            set_manual_sync;
		  logic [LINK-1:0]                            manual_sync;
		  logic [LINK-1:0]                            set_periodic_manual_sync;
		  logic [LINK-1:0]                            periodic_manual_sync;
		  
endinterface



`endif