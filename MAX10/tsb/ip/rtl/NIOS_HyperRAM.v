// Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions
// and other software and tools, and its AMPP partner logic
// functions, and any output files from any of the foregoing
// (including device programming or simulation files), and any
// associated documentation or information are expressly subject
// to the terms and conditions of the Altera Program License
// Subscription Agreement, the Altera Quartus Prime License Agreement,
// the Altera MegaCore Function License Agreement, or other
// applicable license agreement, including, without limitation,
// that your use is for the sole purpose of programming logic
// devices manufactured by Altera and sold by Altera or its
// authorized distributors.  Please refer to the applicable
// agreement for further details.

// PROGRAM		"Quartus Prime"
// VERSION		"Version 16.0.0 Build 211 04/27/2016 SJ Lite Edition"
// CREATED		"Mon Mar 13 12:41:39 2017"

module NIOS_HyperRAM(
inout     FPGA_DONE          ,
inout     ModPwrGood         ,
inout     POR_N_LOAD_N       ,
inout     FPGA_UART_TX       ,
inout     FPGA_UART_RX       ,
inout     SRSTn              ,
inout     FPGA_I2C_INTn      ,
inout     ModPwrEn           ,
inout     B1_1B_J5           ,
inout     JTAGEN             ,
inout     B1A_F4             ,
inout     B1A_F5             ,
inout     B1A_C3             ,
inout     B1A_C4             ,
inout     B1A_G5             ,
inout     B1A_H5             ,
inout     B1A_F2             ,
inout     B1A_E3             ,
inout     B1A_G2             ,
inout     B1A_B2             ,
inout     B1A_C2             ,
inout     B2_N1              ,
inout     B2_L3              ,
inout     B2_K2              ,
inout     B2_L1              ,
inout     B2_L2              ,
inout     B2_M2              ,
inout     B2_L6              ,
inout     B2_K5              ,
inout     B2_M1              ,
inout     FPGA_SPI_SEL1      ,
inout     B3_N5              ,
inout     B3_P4              ,
inout     FPGA_SMA_CLK       ,
inout     FPGA_SMA_TRIG      ,
inout     B3_L7              ,
inout     B3_M6              ,
input     FPGA_UART_SEL4     ,
input     FPGA_UART_SEL2     ,
inout     FPGA_SPI_SCLK      ,
inout     FPGA_UART_SEL0     ,
inout     FPGA_SPI_SEL2      ,
inout     FPGA_SPI_SDOUT     ,
inout     FPGA_SPI_SDATA     ,
inout     B3_L8              ,
inout     B3_M7              ,
inout     B3_P6              ,
inout     FPGA_SPI_SEL4      ,
inout     FPGA_SPI_SEL6      ,
inout     FPGA_SPI_SEL5      ,
inout     B3_P8              ,
inout     B3_P9              ,
inout     MAX10_SPARE1       ,
inout     MAX10_SPARE0       ,
inout     B3_M9              ,
inout     B3_M8              ,
inout     MAX10_SPARE2       ,
inout     MAX10_SPARE3       ,
inout     FPGA_SPI_SEL3      ,
input     FPGA_UART_SEL1     ,
input     FPGA_UART_SEL3     ,
input     FPGA_SPI_SEL0      ,
inout     MAX10_SPARE5       ,
inout     B4_P11             ,
inout     B4_P10             ,
inout     MAX10_SPARE6       ,
inout     MAX10_SPARE4       ,
inout     B4_L9              ,
inout     B4_M10             ,
inout     B4_L10             ,
inout     B4_M11             ,
inout     MAX10_SPARE7       ,
inout     B4_P12             ,
inout     MAX10_SPARE8       ,
inout     MAX10_SPARE12      ,
inout     B5_P14             ,
inout     MAX10_SPARE10      ,
inout     MAX10_SPARE9       ,
inout     MAX10_SPARE11      ,
inout     B5_L11             ,
inout     B5_L12             ,
inout     B5_N14             ,
inout     B5_P15             ,
inout     B5_M15             ,
inout     B5_N16             ,
inout     B5_K11             ,
inout     B5_K12             ,
inout     B5_K14             ,
inout     B5_L15             ,
inout     B5_M16             ,
inout     B5_L16             ,
inout     B5_M14             ,
inout     MAX10_SPARE13      ,
inout     TX_UART19          ,
inout     RX_UART1           ,
inout     RX_UART3           ,
inout     RX_UART2           ,
inout     SFP_MAX_SDA        ,
inout     SFP_MAC_SCL        ,
inout     TX_UART3           ,
inout     TX_UART2           ,
inout     TX_UART9           ,
inout     TX_UART15          ,
inout     RX_UART0           ,
inout     RX_UART7           ,
inout     TX_UART0           ,
inout     TX_UART6           ,
inout     TX_UART7           ,
inout     TX_UART5           ,
inout     RX_UART6           ,
inout     RX_UART5           ,
inout     RX_UART4           ,
inout     TX_UART4           ,
inout     TX_UART11          ,
inout     RX_UART10          ,
inout    RX_UART8            ,
inout    TX_UART10           ,
inout    TX_UART8            ,
inout    TX_UART14           ,
inout    TX_UART1            ,
inout    RX_UART12           ,
inout    RX_UART11           ,
inout    B7_E11              ,
inout    RX_UART9            ,
inout    RX_UART15           ,
inout    B7_E10              ,
inout    RX_UART13           ,
inout    RX_UART19           ,
inout    RX_UART14           ,
inout    TX_UART17           ,
inout    CLNR_nINT           ,
inout    TX_UART16           ,
inout    RX_UART18           ,
inout    RX_UART17           ,
inout    TX_UART12           ,
inout    TX_UART18           ,
inout    TX_UART13           ,
inout    RX_UART16           ,
inout    CLNR_GPIO0          ,
inout    SFP_LOS             ,
inout    CLNR_GPIO2          ,
inout    CLNR_GPIO3          ,
inout    FPGA_I2C_SCL        ,
inout    CLNR_GPIO1          ,
inout    SFP_ModDet          ,
inout    SFP_TX_Fault        ,
inout    SMA_TTL_CLK         ,
inout    FPGA_I2C_SDA        ,
inout    SMA_NIM_SYNC        ,
inout    SMA_RJ45_CLK_SEL    ,
inout    SMA_TTL_SYNC        ,
inout    SMA_NIM_CLK         ,
inout    CLNR_RESETn         ,
input    CLK_50MHz              ,
input    MAX10_CLK_p            ,
output   SMA_CLK_p              ,
output   ADC_SYSREF_p
);

//********************************* Signal Tap Clock ******************************//
logic stp_sample_clk;


clk_gen Stp_clk (
	.areset(1'b0),
	.inclk0(CLK_50MHz),
	.c0(stp_sample_clk),
	.locked(B5_L15)
	);

assign B5_L12 = stp_sample_clk;

//*********************************** Clock Cleaner *******************************//
assign SMA_CLK_p = SMA_TTL_CLK | SMA_NIM_CLK;
assign CLNR_RESETn = SRSTn;
logic signal_tap_clock;
logic clock_1MHz;
assign ADC_SYSREF_p = 1;

logic divided_clk;
logic divided_ref_clk;

Divisor_frecuencia
#(.Bits_counter(4))
Generate_divided_clk
 (
  .CLOCK(MAX10_CLK_p),
  .TIMER_OUT(divided_clk),
  .Comparator(3)
 );


assign B3_P9 = divided_clk;

Divisor_frecuencia
#(.Bits_counter(4))
Generate_divided_ref_clk
 (
  .CLOCK(SMA_CLK_p),
  .TIMER_OUT(divided_ref_clk),
  .Comparator(1)
 );

assign B3_L8 = divided_ref_clk;


Divisor_frecuencia
#(.Bits_counter(16))
Generate_1MHZ_clk
 (
  .CLOCK(CLK_50MHz),
  .TIMER_OUT(clock_1MHz),
  .Comparator(24)
 );

assign B3_L7 = clock_1MHz;


//*************************************** UART ************************************//

assign TX_UART12 = FPGA_UART_TX;
assign FPGA_UART_RX = RX_UART12;

endmodule
