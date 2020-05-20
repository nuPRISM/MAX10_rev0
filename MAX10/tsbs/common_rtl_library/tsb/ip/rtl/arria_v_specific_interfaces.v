`ifndef ARRIA_V_SPECIFIC_INTERFACES
`define ARRIA_V_SPECIFIC_INTERFACES
		
interface arria_v_seriallite_ii_custom_phy_interface;
	/*output from xcvr perspective*/	logic         tx_ready;                    //        arria_v_seriallite_ii_custom_phy_qsys_wrapper_0_conduit_end.tx_ready
	/*output from xcvr perspective*/	logic         rx_ready;                    //                                                                   .rx_ready
	/*input  from xcvr perspective*/	logic         pll_ref_clk;                 //                                                                   .pll_ref_clk
	/*output from xcvr perspective*/	logic         tx_serial_data;              //                                                                   .tx_serial_data
	/*input  from xcvr perspective*/	logic         tx_forceelecidle;            //                                                                   .tx_forceelecidle
	/*output from xcvr perspective*/	logic         pll_locked;                  //                                                                   .pll_locked
	/*input  from xcvr perspective*/	logic         rx_serial_data;              //                                                                   .rx_serial_data
	/*output from xcvr perspective*/	logic [3:0]   rx_runningdisp;              //                                                                   .rx_runningdisp
	/*output from xcvr perspective*/	logic [3:0]   rx_disperr;                  //                                                                   .rx_disperr
	/*output from xcvr perspective*/	logic [3:0]   rx_errdetect;                //                                                                   .rx_errdetect
	/*output from xcvr perspective*/	logic         rx_is_lockedtoref;           //                                                                   .rx_is_lockedtoref
	/*output from xcvr perspective*/	logic         rx_is_lockedtodata;          //                                                                   .rx_is_lockedtodata
	/*output from xcvr perspective*/	logic         rx_signaldetect;             //                                                                   .rx_signaldetect
	/*output from xcvr perspective*/	logic [3:0]   rx_patterndetect;            //                                                                   .rx_patterndetect
	/*output from xcvr perspective*/	logic [3:0]   rx_syncstatus;               //                                                                   .rx_syncstatus
	/*output from xcvr perspective*/	logic [4:0]   rx_bitslipboundaryselectout; //                                                                   .rx_bitslipboundaryselectout
	/*output from xcvr perspective*/	logic         rx_rlv;                      //                                                                   .rx_rlv
	/*input  from xcvr perspective*/	logic         tx_coreclkin;                //                                                                   .tx_coreclkin
	/*input  from xcvr perspective*/	logic         rx_coreclkin;                //                                                                   .rx_coreclkin
	/*output from xcvr perspective*/	logic         tx_clkout;                   //                                                                   .tx_clkout
	/*output from xcvr perspective*/	logic         rx_clkout;                   //                                                                   .rx_clkout
	/*input  from xcvr perspective*/	logic [31:0]  tx_parallel_data;            //                                                                   .tx_parallel_data
	/*input  from xcvr perspective*/	logic [3:0]   tx_datak;                    //                                                                   .tx_datak
	/*output from xcvr perspective*/	logic [31:0]  rx_parallel_data;            //                                                                   .rx_parallel_data
	/*output from xcvr perspective*/	logic [3:0]   rx_datak;    
endinterface

interface quad_adc_parallel_interface;
       logic [13:0] ADC [3:0][3:0];
	   logic clk;
endinterface
					
interface adc_output_bus_interface;
parameter numbits = 12;
parameter numchannels = 16;
logic [numbits-1:0] data_from_adcs[numchannels-1:0];
logic adc_clk;
endinterface

interface mscb_interface;
parameter num_adc_channels = 16;
parameter fifo_count_bits = 11;
parameter data_width = 16;
logic [data_width-1:0]      adc_fifo_ctrl;
logic [data_width-1:0]      adc_fifo_clk;
logic [3:0] adc_locked;
logic [data_width-1:0]      adc_fifo_data [num_adc_channels-1:0];
logic [fifo_count_bits-1:0] adc_fifo_cnt  [num_adc_channels-1:0];
logic				DAC_XOR;
logic				DAC_SELIQ;
logic				DAC_TORB;
logic				DAC_PD;
logic [3:0]   dac_sel;
logic [3:0]   pio_dac_ctrl;                                                      //                                        mscb_support_0_pio_dac_ctrl.export
logic [3:0]   pio_dac_mux;                                                       //                                         mscb_support_0_pio_dac_mux.export
logic [1:0]   pio_clock_mux;                                                     //                                       mscb_support_0_pio_clock_mux.export
logic [7:0]   pio_edge_detector;                                                 //                                   mscb_support_0_pio_edge_detector.export
logic [15:0]  pio_fifo_ctrl;                                                     //                                       mscb_support_0_pio_fifo_ctrl.export
logic [2:0]   pio_maxv_out;                                                      //                                        mscb_support_0_pio_maxv_out.export
logic         spi_maxv_MISO;                                                            //                                            mscb_support_0_spi_maxv.MISO
logic         spi_maxv_MOSI;                                                            //                                                                   .MOSI
logic         spi_maxv_SCLK;                                                            //                                                                   .SCLK
logic [1:0]   spi_maxv_SS_n;                                                            //                                                                   .SS_n
logic         pio_fpga_temp_out;                                                 //                                   mscb_support_0_pio_fpga_temp_out.export
logic [1:0]   pio_signalp;                                                       //                                         mscb_support_0_pio_signalp.export
logic [8:0]   pio_fpga_temp_in;                                                  //                                    mscb_support_0_pio_fpga_temp_in.export
logic [1:0]   pio_clockcleaner_out;                                              //                                mscb_support_0_pio_clockcleaner_out.export
logic         pio_clockcleaner_in;                                               //                                 mscb_support_0_pio_clockcleaner_in.export
logic [29:0]  pio_adc_in;                                                        //                                          mscb_support_0_pio_adc_in.export
logic [3:0]   pio_adc_out;                                                       //                                         mscb_support_0_pio_adc_out.export
logic         i2c_fmc_scl_pad_io;                                                       //                                             mscb_support_0_i2c_fmc.scl_pad_io
logic         i2c_fmc_sda_pad_io;                                                       //                                                                   .sda_pad_io
logic         spi_adc_external_MISO;                                                    //                                    mscb_support_0_spi_adc_external.MISO
logic         spi_adc_external_MOSI;                                                    //                                                                   .MOSI
logic         spi_adc_external_SCLK;                                                    //                                                                   .SCLK
logic [3:0]   spi_adc_external_SS_n;                                                    //                                                                   .SS_n
logic         spi_clockcleaner_external_MISO;                                           //                           mscb_support_0_spi_clockcleaner_external.MISO
logic         spi_clockcleaner_external_MOSI;                                           //                                                                   .MOSI
logic         spi_clockcleaner_external_SCLK;                                           //                                                                   .SCLK
logic         spi_clockcleaner_external_SS_n;                                           //                                                                   .SS_n
logic [31:0]  pio_chipid_lo;                                            //                              mscb_support_0_pio_chipid_lo_external.export
logic [31:0]  pio_chipid_hi;                                            //                              mscb_support_0_pio_chipid_hi_external.export
logic         i2c_dac2655_scl_pad_io;                                                   //                                         mscb_support_0_i2c_dac2655.scl_pad_io
logic         i2c_dac2655_sda_pad_io;                                                   //                                                                   .sda_pad_io
logic [3:0]   pio_fpled;                                                         //                                           mscb_support_0_pio_fpled.export
logic [3:0]   pio_userled;       
endinterface

interface four_lane_seriallite_interface;
		 logic          tx_ready                       ;
		 logic          rx_ready                       ;
		 logic [0:0]    pll_ref_clk                    ;
		 logic [3:0]    tx_serial_data                 ;
		 logic [3:0]    tx_forceelecidle               ;
		 logic [0:0]    pll_locked                     ;
		 logic [3:0]    rx_serial_data                 ;
		 logic [15:0]   rx_runningdisp                 ;
		 logic [15:0]   rx_disperr                     ;
		 logic [15:0]   rx_errdetect                   ;
		 logic [3:0]    rx_is_lockedtoref              ;
		 logic [3:0]    rx_is_lockedtodata             ;
		 logic [3:0]    rx_signaldetect                ;
		 logic [15:0]   rx_patterndetect               ;
		 logic [15:0]   rx_syncstatus                  ;
		 logic [19:0]   rx_bitslipboundaryselectout    ;
		 logic [3:0]    rx_rlv                         ;
		 logic [3:0]    tx_coreclkin                   ;
		 logic [3:0]    rx_coreclkin                   ;
		 logic [3:0]    tx_clkout                      ;
		 logic [3:0]    rx_clkout                      ;
		 logic [127:0]  tx_parallel_data               ;
		 logic [15:0]   tx_datak                       ;
		 logic [127:0]  rx_parallel_data               ;
		 logic [15:0]   rx_datak                       ;
endinterface 





`endif
