///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.17)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  10-Gigabit Transceiver for AURORA I/O Standard 1 Byte Data
// /___/   /\     Filename : GT10_AURORA_1.v
// \   \  /  \    Timestamp : Thu Mar 25 16:42:19 PST 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    02/22/06 - CR#226003 - Added integer, real parameter type

`timescale 1 ps / 1 ps 

module GT10_AURORA_1 (
	CHBONDDONE,
	CHBONDO,
	PMARXLOCK,
	RXBUFSTATUS,
	RXCHARISCOMMA,
	RXCHARISK,
	RXCLKCORCNT,
	RXCOMMADET,
	RXDATA,
	RXDISPERR,
	RXLOSSOFSYNC,
	RXNOTINTABLE,
	RXREALIGN,
	RXRECCLK,
	RXRUNDISP,
	TXBUFERR,
	TXKERR,
	TXN,
	TXOUTCLK,
	TXP,
	TXRUNDISP,

	BREFCLKNIN,
	BREFCLKPIN,
	CHBONDI,
	ENCHANSYNC,
	ENMCOMMAALIGN,
	ENPCOMMAALIGN,
	LOOPBACK,
	PMAINIT,
	PMAREGADDR,
	PMAREGDATAIN,
	PMAREGRW,
	PMAREGSTROBE,
	PMARXLOCKSEL,
	POWERDOWN,
	REFCLK,
	REFCLK2,
	REFCLKBSEL,
	REFCLKSEL,
	RXBLOCKSYNC64B66BUSE,
	RXCOMMADETUSE,
	RXDATAWIDTH,
	RXDEC64B66BUSE,
	RXDEC8B10BUSE,
	RXDESCRAM64B66BUSE,
	RXIGNOREBTF,
	RXINTDATAWIDTH,
	RXN,
	RXP,
	RXPOLARITY,
	RXRESET,
	RXSLIDE,
	RXUSRCLK,
	RXUSRCLK2,
	TXBYPASS8B10B,
	TXCHARDISPMODE,
	TXCHARDISPVAL,
	TXCHARISK,
	TXDATA,
	TXDATAWIDTH,
	TXENC64B66BUSE,
	TXENC8B10BUSE,
	TXGEARBOX64B66BUSE,
	TXINHIBIT,
	TXINTDATAWIDTH,
	TXPOLARITY,
	TXRESET,
	TXSCRAM64B66BUSE,
	TXUSRCLK,
	TXUSRCLK2
);

parameter integer ALIGN_COMMA_WORD = 1;
parameter integer CHAN_BOND_LIMIT = 16;
parameter CHAN_BOND_MODE = "OFF";
parameter CHAN_BOND_ONE_SHOT = "FALSE";
parameter CHAN_BOND_SEQ_1_MASK = 4'b0000;
parameter CHAN_BOND_SEQ_2_MASK = 4'b0000;
parameter CLK_COR_8B10B_DE = "FALSE";
parameter integer CLK_COR_MAX_LAT = 36;
parameter integer CLK_COR_MIN_LAT = 28;
parameter CLK_COR_SEQ_1_MASK = 4'b0000;
parameter CLK_COR_SEQ_2_MASK = 4'b0000;
parameter CLK_COR_SEQ_DROP = "FALSE";
parameter CLK_CORRECT_USE = "TRUE";
parameter PMA_PWR_CNTRL = 8'b11111111;
parameter PMA_SPEED_HEX = 120'h00fc0db00b0f32263068090104a628;
parameter PMA_SPEED_USE = "PMA_SPEED";
parameter RX_BUFFER_USE = "TRUE";
parameter integer RX_LOS_INVALID_INCR = 1;
parameter integer RX_LOS_THRESHOLD = 4;
parameter RX_LOSS_OF_SYNC_FSM = "TRUE";
parameter TX_BUFFER_USE = "TRUE";

output CHBONDDONE;
output [4:0] CHBONDO;
output PMARXLOCK;
output [1:0] RXBUFSTATUS;
output [0:0] RXCHARISCOMMA;
output [0:0] RXCHARISK;
output [2:0] RXCLKCORCNT;
output RXCOMMADET;
output [7:0] RXDATA;
output [0:0] RXDISPERR;
output [1:0] RXLOSSOFSYNC;
output [0:0] RXNOTINTABLE;
output RXREALIGN;
output RXRECCLK;
output [0:0] RXRUNDISP;
output TXBUFERR;
output [0:0] TXKERR;
output TXN;
output TXOUTCLK;
output TXP;
output [0:0] TXRUNDISP;

input BREFCLKNIN;
input BREFCLKPIN;
input [4:0] CHBONDI;
input ENCHANSYNC;
input ENMCOMMAALIGN;
input ENPCOMMAALIGN;
input [1:0] LOOPBACK;
input PMAINIT;
input [5:0] PMAREGADDR;
input [7:0] PMAREGDATAIN;
input PMAREGRW;
input PMAREGSTROBE;
input [1:0] PMARXLOCKSEL;
input POWERDOWN;
input REFCLK;
input REFCLK2;
input REFCLKBSEL;
input REFCLKSEL;
input RXBLOCKSYNC64B66BUSE;
input RXCOMMADETUSE;
input [1:0] RXDATAWIDTH;
input RXDEC64B66BUSE;
input RXDEC8B10BUSE;
input RXDESCRAM64B66BUSE;
input RXIGNOREBTF;
input [1:0] RXINTDATAWIDTH;
input RXN;
input RXP;
input RXPOLARITY;
input RXRESET;
input RXSLIDE;
input RXUSRCLK;
input RXUSRCLK2;
input [0:0] TXBYPASS8B10B;
input [0:0] TXCHARDISPMODE;
input [0:0] TXCHARDISPVAL;
input [0:0] TXCHARISK;
input [7:0] TXDATA;
input [1:0] TXDATAWIDTH;
input TXENC64B66BUSE;
input TXENC8B10BUSE;
input TXGEARBOX64B66BUSE;
input TXINHIBIT;
input [1:0] TXINTDATAWIDTH;
input TXPOLARITY;
input TXRESET;
input TXSCRAM64B66BUSE;
input TXUSRCLK;
input TXUSRCLK2;

wire [6:0] OPEN_RXCHARISCOMMA;
wire [6:0] OPEN_RXCHARISK;
wire [55:0] OPEN_RXDATA;
wire [6:0] OPEN_RXDISPERR;
wire [6:0] OPEN_RXNOTINTABLE;
wire [6:0] OPEN_RXRUNDISP;
wire [6:0] OPEN_TXKERR;
wire [6:0] OPEN_TXRUNDISP;

GT10 gt10_1 (
	.CHBONDDONE (CHBONDDONE),
	.CHBONDO (CHBONDO),
	.PMARXLOCK (PMARXLOCK),
	.RXBUFSTATUS (RXBUFSTATUS),
	.RXCHARISCOMMA ({OPEN_RXCHARISCOMMA, RXCHARISCOMMA}),
	.RXCHARISK ({OPEN_RXCHARISK, RXCHARISK}),
	.RXCLKCORCNT (RXCLKCORCNT),
	.RXCOMMADET (RXCOMMADET),
	.RXDATA ({OPEN_RXDATA, RXDATA}),
	.RXDISPERR ({OPEN_RXDISPERR, RXDISPERR}),
	.RXLOSSOFSYNC (RXLOSSOFSYNC),
	.RXNOTINTABLE ({OPEN_RXNOTINTABLE, RXNOTINTABLE}),
	.RXREALIGN (RXREALIGN),
	.RXRECCLK (RXRECCLK),
	.RXRUNDISP ({OPEN_RXRUNDISP, RXRUNDISP}),
	.TXBUFERR (TXBUFERR),
	.TXKERR ({OPEN_TXKERR, TXKERR}),
	.TXN (TXN),
	.TXOUTCLK (TXOUTCLK),
	.TXP (TXP),
	.TXRUNDISP ({OPEN_TXRUNDISP, TXRUNDISP}),
	.BREFCLKNIN (BREFCLKNIN),
	.BREFCLKPIN (BREFCLKPIN),
	.CHBONDI (CHBONDI),
	.ENCHANSYNC (ENCHANSYNC),
	.ENMCOMMAALIGN (ENMCOMMAALIGN),
	.ENPCOMMAALIGN (ENPCOMMAALIGN),
	.LOOPBACK (LOOPBACK),
	.PMAINIT (PMAINIT),
	.PMAREGADDR (PMAREGADDR),
	.PMAREGDATAIN (PMAREGDATAIN),
	.PMAREGRW (PMAREGRW),
	.PMAREGSTROBE (PMAREGSTROBE),
	.PMARXLOCKSEL (PMARXLOCKSEL),
	.POWERDOWN (POWERDOWN),
	.REFCLK (REFCLK),
	.REFCLK2 (REFCLK2),
	.REFCLKBSEL (REFCLKBSEL),
	.REFCLKSEL (REFCLKSEL),
	.RXBLOCKSYNC64B66BUSE (RXBLOCKSYNC64B66BUSE),
	.RXCOMMADETUSE (RXCOMMADETUSE),
	.RXDATAWIDTH (RXDATAWIDTH),
	.RXDEC64B66BUSE (RXDEC64B66BUSE),
	.RXDEC8B10BUSE (RXDEC8B10BUSE),
	.RXDESCRAM64B66BUSE (RXDESCRAM64B66BUSE),
	.RXIGNOREBTF (RXIGNOREBTF),
	.RXINTDATAWIDTH (RXINTDATAWIDTH),
	.RXN (RXN),
	.RXP (RXP),
	.RXPOLARITY (RXPOLARITY),
	.RXRESET (RXRESET),
	.RXSLIDE (RXSLIDE),
	.RXUSRCLK (RXUSRCLK),
	.RXUSRCLK2 (RXUSRCLK2),
	.TXBYPASS8B10B ({7'b0, TXBYPASS8B10B}),
	.TXCHARDISPMODE ({7'b0, TXCHARDISPMODE}),
	.TXCHARDISPVAL ({7'b0, TXCHARDISPVAL}),
	.TXCHARISK ({7'b0, TXCHARISK}),
	.TXDATA ({56'b0, TXDATA}),
	.TXDATAWIDTH (TXDATAWIDTH),
	.TXENC64B66BUSE (TXENC64B66BUSE),
	.TXENC8B10BUSE (TXENC8B10BUSE),
	.TXGEARBOX64B66BUSE (TXGEARBOX64B66BUSE),
	.TXINHIBIT (TXINHIBIT),
	.TXINTDATAWIDTH (TXINTDATAWIDTH),
	.TXPOLARITY (TXPOLARITY),
	.TXRESET (TXRESET),
	.TXSCRAM64B66BUSE (TXSCRAM64B66BUSE),
	.TXUSRCLK (TXUSRCLK),
	.TXUSRCLK2 (TXUSRCLK2)
);

defparam gt10_1.ALIGN_COMMA_WORD = ALIGN_COMMA_WORD;
defparam gt10_1.CHAN_BOND_LIMIT = CHAN_BOND_LIMIT;
defparam gt10_1.CHAN_BOND_MODE = CHAN_BOND_MODE;
defparam gt10_1.CHAN_BOND_ONE_SHOT = CHAN_BOND_ONE_SHOT;
defparam gt10_1.CHAN_BOND_SEQ_1_1 = 11'b00110111100;
defparam gt10_1.CHAN_BOND_SEQ_1_2 = 11'b00000000000;
defparam gt10_1.CHAN_BOND_SEQ_1_3 = 11'b00001001010;
defparam gt10_1.CHAN_BOND_SEQ_1_4 = 11'b00001001010;
defparam gt10_1.CHAN_BOND_SEQ_1_MASK = CHAN_BOND_SEQ_1_MASK;
defparam gt10_1.CHAN_BOND_SEQ_2_1 = 11'b00110111100;
defparam gt10_1.CHAN_BOND_SEQ_2_2 = 11'b00000000000;
defparam gt10_1.CHAN_BOND_SEQ_2_3 = 11'b00001000101;
defparam gt10_1.CHAN_BOND_SEQ_2_4 = 11'b00001000101;
defparam gt10_1.CHAN_BOND_SEQ_2_MASK = CHAN_BOND_SEQ_2_MASK;
defparam gt10_1.CHAN_BOND_SEQ_2_USE = "FALSE";
defparam gt10_1.CHAN_BOND_SEQ_LEN = 2;
defparam gt10_1.CLK_COR_8B10B_DE = CLK_COR_8B10B_DE;
defparam gt10_1.CLK_COR_MAX_LAT = CLK_COR_MAX_LAT;
defparam gt10_1.CLK_COR_MIN_LAT = CLK_COR_MIN_LAT;
defparam gt10_1.CLK_COR_SEQ_1_1 = 11'b00100011100;
defparam gt10_1.CLK_COR_SEQ_1_2 = 11'b00100011100;
defparam gt10_1.CLK_COR_SEQ_1_3 = 11'b00000000000;
defparam gt10_1.CLK_COR_SEQ_1_4 = 11'b00000000000;
defparam gt10_1.CLK_COR_SEQ_1_MASK = CLK_COR_SEQ_1_MASK;
defparam gt10_1.CLK_COR_SEQ_2_1 = 11'b00000000000;
defparam gt10_1.CLK_COR_SEQ_2_2 = 11'b00000000000;
defparam gt10_1.CLK_COR_SEQ_2_3 = 11'b00000000000;
defparam gt10_1.CLK_COR_SEQ_2_4 = 11'b00000000000;
defparam gt10_1.CLK_COR_SEQ_2_MASK = CLK_COR_SEQ_2_MASK;
defparam gt10_1.CLK_COR_SEQ_2_USE = "FALSE";
defparam gt10_1.CLK_COR_SEQ_DROP = CLK_COR_SEQ_DROP;
defparam gt10_1.CLK_COR_SEQ_LEN = 2;
defparam gt10_1.CLK_CORRECT_USE = CLK_CORRECT_USE;
defparam gt10_1.COMMA_10B_MASK = 10'b0001111111;
defparam gt10_1.DEC_MCOMMA_DETECT = "TRUE";
defparam gt10_1.DEC_PCOMMA_DETECT = "TRUE";
defparam gt10_1.DEC_VALID_COMMA_ONLY = "TRUE";
defparam gt10_1.MCOMMA_10B_VALUE = 10'b1010000011;
defparam gt10_1.MCOMMA_DETECT = "TRUE";
defparam gt10_1.PCOMMA_10B_VALUE = 10'b0101111100;
defparam gt10_1.PCOMMA_DETECT = "TRUE";
defparam gt10_1.PMA_PWR_CNTRL = PMA_PWR_CNTRL;
defparam gt10_1.PMA_SPEED = "25_10";
defparam gt10_1.PMA_SPEED_HEX = PMA_SPEED_HEX;
defparam gt10_1.PMA_SPEED_USE = PMA_SPEED_USE;
defparam gt10_1.RX_BUFFER_USE = RX_BUFFER_USE;
defparam gt10_1.RX_LOS_INVALID_INCR = RX_LOS_INVALID_INCR;
defparam gt10_1.RX_LOS_THRESHOLD = RX_LOS_THRESHOLD;
defparam gt10_1.RX_LOSS_OF_SYNC_FSM = RX_LOSS_OF_SYNC_FSM;
defparam gt10_1.TX_BUFFER_USE = TX_BUFFER_USE;

endmodule
