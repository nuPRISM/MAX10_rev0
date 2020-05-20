`default_nettype none
module jesd_transport_and_distribute
#(
parameter COMPILE_TX_PORTION = 0               ,
parameter NUM_LINKS                            ,
parameter L                                    ,
parameter M                                    ,
parameter F                                    ,
parameter S                                    ,
parameter N                                    ,
parameter N_PRIME                              ,
parameter CS                                   ,
parameter F1_FRAMECLK_DIV                      ,
parameter F2_FRAMECLK_DIV                      ,
parameter TL_DATA_BUS_WIDTH                    ,
parameter NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK,
parameter POLYNOMIAL_LENGTH = 9,
parameter FEEDBACK_TAP      = 5
)
(
//RX/TX serial data input/output
input  wire [NUM_LINKS*L-1:0]  rx_serial_data,
output wire [NUM_LINKS*L-1:0]  tx_serial_data,
jesd204b_a10_interface                   jesd204b_a10_interface_pins,
multi_data_stream_interface              avst_out_streams_interface_pins
);


jesd204b_a10_wrapper_mcgb  #(
  .LINK              (NUM_LINKS         ),  // Number of links, a link composed of multiple lanes
  .L                 (L                 ),  // Number of lanes per converter device
  .M                 (M                 ),  // Number of converters per converter device
  .F                 (F                 ),  // Number of octets per frame
  .S                 (S                 ),  // Number of transmitter samples per converter per frame
  .N                 (N                 ), // Number of converter bits per converter
  .N_PRIME           (N_PRIME           ), // Number of transmitted bits per sample 
  .CS                (CS                ),  // Number of control bits per conversion sample				 
  .F1_FRAMECLK_DIV   (F1_FRAMECLK_DIV   ),  // Frame clk divider for transport layer when F=1. Valid value = 1 or 4. Default parameter used in all F value scenarios.
  .F2_FRAMECLK_DIV   (F2_FRAMECLK_DIV   ),  // Frame clk divider for transport layer when F=2. Valid value = 1 or 2. For F=4 & 8, this parameter is not used.
  .POLYNOMIAL_LENGTH (POLYNOMIAL_LENGTH ),
  .FEEDBACK_TAP      (FEEDBACK_TAP      ),
  .COMPILE_TX_PORTION(COMPILE_TX_PORTION)
)
jesd204b_a10_wrapper_inst
(

  /* //RX/TX serial data input/output            */ 
  /* input  wire [LINK*L-1:0]                    */ .rx_serial_data,    
  /* output wire [LINK*L-1:0]                    */ .tx_serial_data,
  /*                                             */ 

  /* jesd204b_a10_interface                      */ .jesd204b_a10_interface_pins
);


distribute_jesd_rx_out_to_avst
#(
.JESD_S                               (S                                    ),
.JESD_M                               (M                                    ),
.JESD_N                               (N                                    ),
.JESD_N_PRIME                         (N_PRIME                              ),
.JESD_TL_DATA_BUS_WIDTH               (TL_DATA_BUS_WIDTH                    ),
.NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK(NUM_CONVERTER_SAMPLES_PER_FRAME_CLOCK),
.JESD_NUM_LINKS                       (NUM_LINKS                            )
)
distribute_jesd_rx_out_to_avst_inst
(
.jesd204b_a10_interface_pins,
.avst_out_streams_interface_pins
);

endmodule
`default_nettype wire