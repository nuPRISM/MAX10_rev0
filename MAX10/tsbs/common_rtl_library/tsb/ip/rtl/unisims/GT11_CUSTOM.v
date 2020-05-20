///////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995/2004 Xilinx, Inc.
// All Right Reserved.
///////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor : Xilinx
// \   \   \/     Version : 8.1i (I.17)
//  \   \         Description : Xilinx Functional Simulation Library Component
//  /   /                  11-Gigabit Transceiver for High-Speed I/O CUSTOM Simulation Model
// /___/   /\     Filename : GT11_CUSTOM.v
// \   \  /  \    Timestamp : Fri Jun 18 10:57:01 PDT 2004
//  \___\/\___\
//
// Revision:
//    03/23/04 - Initial version.
//    05/16/05 - Changed default values for some parameters and removed two parameters. Fixed CR#207101.
//    08/08/05 - Changed default parameter values for some parameters. Added POWER_ENABLE parameter. (CR 214282).
//    02/22/06 - CR#226003 - Added integer, real parameter type
//    02/28/06 - CR#226322 - Addition of new parameters and change of default values for some parameters.
// End Revision

`timescale 1 ps / 1 ps 

module GT11_CUSTOM (
	CHBONDO,
	DO,
	DRDY,
	RXBUFERR,
	RXCALFAIL,
	RXCHARISCOMMA,
	RXCHARISK,
	RXCOMMADET,
	RXCRCOUT,
	RXCYCLELIMIT,
	RXDATA,
	RXDISPERR,
	RXLOCK,
	RXLOSSOFSYNC,
	RXMCLK,
	RXNOTINTABLE,
	RXPCSHCLKOUT,
	RXREALIGN,
	RXRECCLK1,
	RXRECCLK2,
	RXRUNDISP,
	RXSIGDET,
	RXSTATUS,
	TX1N,
	TX1P,
	TXBUFERR,
	TXCALFAIL,
	TXCRCOUT,
	TXCYCLELIMIT,
	TXKERR,
	TXLOCK,
	TXOUTCLK1,
	TXOUTCLK2,
	TXPCSHCLKOUT,
	TXRUNDISP,
	CHBONDI,
	DADDR,
	DCLK,
	DEN,
	DI,
	DWE,
	ENCHANSYNC,
	ENMCOMMAALIGN,
	ENPCOMMAALIGN,
	GREFCLK,
	LOOPBACK,
	POWERDOWN,
	REFCLK1,
	REFCLK2,
	RX1N,
	RX1P,
	RXBLOCKSYNC64B66BUSE,
	RXCLKSTABLE,
	RXCOMMADETUSE,
	RXCRCCLK,
	RXCRCDATAVALID,
	RXCRCDATAWIDTH,
	RXCRCIN,
	RXCRCINIT,
	RXCRCINTCLK,
	RXCRCPD,
	RXCRCRESET,
	RXDATAWIDTH,
	RXDEC64B66BUSE,
	RXDEC8B10BUSE,
	RXDESCRAM64B66BUSE,
	RXIGNOREBTF,
	RXINTDATAWIDTH,
	RXPMARESET,
	RXPOLARITY,
	RXRESET,
	RXSLIDE,
	RXSYNC,
	RXUSRCLK,
	RXUSRCLK2,
	TXBYPASS8B10B,
	TXCHARDISPMODE,
	TXCHARDISPVAL,
	TXCHARISK,
	TXCLKSTABLE,
	TXCRCCLK,
	TXCRCDATAVALID,
	TXCRCDATAWIDTH,
	TXCRCIN,
	TXCRCINIT,
	TXCRCINTCLK,
	TXCRCPD,
	TXCRCRESET,
	TXDATA,
	TXDATAWIDTH,
	TXENC64B66BUSE,
	TXENC8B10BUSE,
	TXENOOB,
	TXGEARBOX64B66BUSE,
	TXINHIBIT,
	TXINTDATAWIDTH,
	TXPMARESET,
	TXPOLARITY,
	TXRESET,
	TXSCRAM64B66BUSE,
	TXSYNC,
	TXUSRCLK,
	TXUSRCLK2
);

parameter BANDGAPSEL = "FALSE";
parameter BIASRESSEL = "FALSE";
parameter CCCB_ARBITRATOR_DISABLE = "FALSE";
parameter CHAN_BOND_MODE = "NONE";
parameter CHAN_BOND_ONE_SHOT = "FALSE";
parameter CHAN_BOND_SEQ_1_1 = 11'b00000000000;
parameter CHAN_BOND_SEQ_1_2 = 11'b00000000000;
parameter CHAN_BOND_SEQ_1_3 = 11'b00000000000;
parameter CHAN_BOND_SEQ_1_4 = 11'b00000000000;
parameter CHAN_BOND_SEQ_1_MASK = 4'b1110;
parameter CHAN_BOND_SEQ_2_1 = 11'b00000000000;
parameter CHAN_BOND_SEQ_2_2 = 11'b00000000000;
parameter CHAN_BOND_SEQ_2_3 = 11'b00000000000;
parameter CHAN_BOND_SEQ_2_4 = 11'b00000000000;
parameter CHAN_BOND_SEQ_2_MASK = 4'b1110;
parameter CHAN_BOND_SEQ_2_USE = "FALSE";
parameter CLK_CORRECT_USE = "FALSE";
parameter CLK_COR_8B10B_DE = "FALSE";
parameter CLK_COR_SEQ_1_1 = 11'b00000000000;
parameter CLK_COR_SEQ_1_2 = 11'b00000000000;
parameter CLK_COR_SEQ_1_3 = 11'b00000000000;
parameter CLK_COR_SEQ_1_4 = 11'b00000000000;
parameter CLK_COR_SEQ_1_MASK = 4'b1110;
parameter CLK_COR_SEQ_2_1 = 11'b00000000000;
parameter CLK_COR_SEQ_2_2 = 11'b00000000000;
parameter CLK_COR_SEQ_2_3 = 11'b00000000000;
parameter CLK_COR_SEQ_2_4 = 11'b00000000000;
parameter CLK_COR_SEQ_2_MASK = 4'b1110;
parameter CLK_COR_SEQ_2_USE = "FALSE";
parameter CLK_COR_SEQ_DROP = "FALSE";
parameter COMMA32 = "FALSE";
parameter COMMA_10B_MASK = 10'h3FF;
parameter CYCLE_LIMIT_SEL = 2'b00;
parameter DCDR_FILTER = 3'b010;
parameter DEC_MCOMMA_DETECT = "TRUE";
parameter DEC_PCOMMA_DETECT = "TRUE";
parameter DEC_VALID_COMMA_ONLY = "TRUE";
parameter DIGRX_FWDCLK = 2'b00;
parameter DIGRX_SYNC_MODE = "FALSE";
parameter ENABLE_DCDR = "FALSE";
parameter FDET_HYS_CAL = 3'b010;
parameter FDET_HYS_SEL = 3'b100;
parameter FDET_LCK_CAL = 3'b100;
parameter FDET_LCK_SEL = 3'b001;
parameter IREFBIASMODE = 2'b11;
parameter LOOPCAL_WAIT = 2'b00;
parameter MCOMMA_32B_VALUE = 32'h00000000;
parameter MCOMMA_DETECT = "TRUE";
parameter OPPOSITE_SELECT = "FALSE";
parameter PCOMMA_32B_VALUE = 32'h00000000;
parameter PCOMMA_DETECT = "TRUE";
parameter PCS_BIT_SLIP = "FALSE";
parameter PMACLKENABLE = "TRUE";
parameter PMACOREPWRENABLE = "TRUE";
parameter PMAIREFTRIM = 4'b0111;
parameter PMAVBGCTRL = 5'b00000;
parameter PMAVREFTRIM = 4'b0111;
parameter PMA_BIT_SLIP = "FALSE";
parameter POWER_ENABLE = "TRUE";
parameter REPEATER = "FALSE";
parameter RXACTST = "FALSE";
parameter RXAFEEQ = 9'b000000000;
parameter RXAFEPD = "FALSE";
parameter RXAFETST = "FALSE";
parameter RXAPD = "FALSE";
parameter RXAREGCTRL = 5'b00000;
parameter RXASYNCDIVIDE = 2'b11;
parameter RXBY_32 = "FALSE";
parameter RXCDRLOS = 6'b000000;
parameter RXCLK0_FORCE_PMACLK = "FALSE";
parameter RXCLKMODE = 6'b110001;
parameter RXCLMODE = 2'b00;
parameter RXCMADJ = 2'b01;
parameter RXCPSEL = "TRUE";
parameter RXCPTST = "FALSE";
parameter RXCRCCLOCKDOUBLE = "FALSE";
parameter RXCRCENABLE = "FALSE";
parameter RXCRCINITVAL = 32'h00000000;
parameter RXCRCINVERTGEN = "FALSE";
parameter RXCRCSAMECLOCK = "FALSE";
parameter RXCTRL1 = 10'h200;
parameter RXCYCLE_LIMIT_SEL = 2'b00;
parameter RXDATA_SEL = 2'b00;
parameter RXDCCOUPLE = "FALSE";
parameter RXDIGRESET = "FALSE";
parameter RXDIGRX = "FALSE";
parameter RXEQ = 64'h4000000000000000;
parameter RXFDCAL_CLOCK_DIVIDE = "NONE";
parameter RXFDET_HYS_CAL = 3'b010;
parameter RXFDET_HYS_SEL = 3'b100;
parameter RXFDET_LCK_CAL = 3'b100;
parameter RXFDET_LCK_SEL = 3'b001;
parameter RXFECONTROL1 = 2'b00;
parameter RXFECONTROL2 = 3'b000;
parameter RXFETUNE = 2'b01;
parameter RXLB = "FALSE";
parameter RXLKADJ = 5'b00000;
parameter RXLKAPD = "FALSE";
parameter RXLOOPCAL_WAIT = 2'b00;
parameter RXLOOPFILT = 4'b0111;
parameter RXMODE = 6'b000000;
parameter RXPD = "FALSE";
parameter RXPDDTST = "TRUE";
parameter RXPMACLKSEL = "REFCLK1";
parameter RXRCPADJ = 3'b011;
parameter RXRCPPD = "FALSE";
parameter RXRECCLK1_USE_SYNC = "FALSE";
parameter RXRIBADJ = 2'b11;
parameter RXRPDPD = "FALSE";
parameter RXRSDPD = "FALSE";
parameter RXSLOWDOWN_CAL = 2'b00;
parameter RXTUNE = 13'h0000;
parameter RXVCODAC_INIT = 10'b1010000000;
parameter RXVCO_CTRL_ENABLE = "FALSE";
parameter RX_BUFFER_USE = "TRUE";
parameter RX_CLOCK_DIVIDER = 2'b00;
parameter SAMPLE_8X = "FALSE";
parameter SLOWDOWN_CAL = 2'b00;
parameter TXABPMACLKSEL = "REFCLK1";
parameter TXAPD = "FALSE";
parameter TXAREFBIASSEL = "TRUE";
parameter TXASYNCDIVIDE = 2'b11;
parameter TXCLK0_FORCE_PMACLK = "FALSE";
parameter TXCLKMODE = 4'b1001;
parameter TXCLMODE = 2'b00;
parameter TXCPSEL = "TRUE";
parameter TXCRCCLOCKDOUBLE = "FALSE";
parameter TXCRCENABLE = "FALSE";
parameter TXCRCINITVAL = 32'h00000000;
parameter TXCRCINVERTGEN = "FALSE";
parameter TXCRCSAMECLOCK = "FALSE";
parameter TXCTRL1 = 10'h200;
parameter TXDATA_SEL = 2'b00;
parameter TXDAT_PRDRV_DAC = 3'b111;
parameter TXDAT_TAP_DAC = 5'b10110;
parameter TXDIGPD = "FALSE";
parameter TXFDCAL_CLOCK_DIVIDE = "NONE";
parameter TXHIGHSIGNALEN = "TRUE";
parameter TXLOOPFILT = 4'b0111;
parameter TXLVLSHFTPD = "FALSE";
parameter TXOUTCLK1_USE_SYNC = "FALSE";
parameter TXPD = "FALSE";
parameter TXPHASESEL = "FALSE";
parameter TXPOST_PRDRV_DAC = 3'b111;
parameter TXPOST_TAP_DAC = 5'b01110;
parameter TXPOST_TAP_PD = "TRUE";
parameter TXPRE_PRDRV_DAC = 3'b111;
parameter TXPRE_TAP_DAC = 5'b00000;
parameter TXPRE_TAP_PD = "TRUE";
parameter TXSLEWRATE = "FALSE";
parameter TXTERMTRIM = 4'b1100;
parameter TXTUNE = 13'h0000;
parameter TX_BUFFER_USE = "TRUE";
parameter TX_CLOCK_DIVIDER = 2'b00;
parameter VCODAC_INIT = 10'b1010000000;
parameter VCO_CTRL_ENABLE = "FALSE";
parameter VREFBIASMODE = 2'b11;
parameter integer ALIGN_COMMA_WORD = 4;
parameter integer CHAN_BOND_LIMIT = 16;
parameter integer CHAN_BOND_SEQ_LEN = 1;
parameter integer CLK_COR_MAX_LAT = 48;
parameter integer CLK_COR_MIN_LAT = 36;
parameter integer CLK_COR_SEQ_LEN = 1;
parameter integer RXOUTDIV2SEL = 1;
parameter integer RXPLLNDIVSEL = 8;
parameter integer RXUSRDIVISOR = 1;
parameter integer SH_CNT_MAX = 64;
parameter integer SH_INVALID_CNT_MAX = 16;
parameter integer TXOUTDIV2SEL = 1;
parameter integer TXPLLNDIVSEL = 8;


output DRDY;
output RXBUFERR;
output RXCALFAIL;
output RXCOMMADET;
output RXCYCLELIMIT;
output RXLOCK;
output RXMCLK;
output RXPCSHCLKOUT;
output RXREALIGN;
output RXRECCLK1;
output RXRECCLK2;
output RXSIGDET;
output TX1N;
output TX1P;
output TXBUFERR;
output TXCALFAIL;
output TXCYCLELIMIT;
output TXLOCK;
output TXOUTCLK1;
output TXOUTCLK2;
output TXPCSHCLKOUT;
output [15:0] DO;
output [1:0] RXLOSSOFSYNC;
output [31:0] RXCRCOUT;
output [31:0] TXCRCOUT;
output [4:0] CHBONDO;
output [5:0] RXSTATUS;
output [63:0] RXDATA;
output [7:0] RXCHARISCOMMA;
output [7:0] RXCHARISK;
output [7:0] RXDISPERR;
output [7:0] RXNOTINTABLE;
output [7:0] RXRUNDISP;
output [7:0] TXKERR;
output [7:0] TXRUNDISP;

input DCLK;
input DEN;
input DWE;
input ENCHANSYNC;
input ENMCOMMAALIGN;
input ENPCOMMAALIGN;
input GREFCLK;
input POWERDOWN;
input REFCLK1;
input REFCLK2;
input RX1N;
input RX1P;
input RXBLOCKSYNC64B66BUSE;
input RXCLKSTABLE;
input RXCOMMADETUSE;
input RXCRCCLK;
input RXCRCDATAVALID;
input RXCRCINIT;
input RXCRCINTCLK;
input RXCRCPD;
input RXCRCRESET;
input RXDEC64B66BUSE;
input RXDEC8B10BUSE;
input RXDESCRAM64B66BUSE;
input RXIGNOREBTF;
input RXPMARESET;
input RXPOLARITY;
input RXRESET;
input RXSLIDE;
input RXSYNC;
input RXUSRCLK2;
input RXUSRCLK;
input TXCLKSTABLE;
input TXCRCCLK;
input TXCRCDATAVALID;
input TXCRCINIT;
input TXCRCINTCLK;
input TXCRCPD;
input TXCRCRESET;
input TXENC64B66BUSE;
input TXENC8B10BUSE;
input TXENOOB;
input TXGEARBOX64B66BUSE;
input TXINHIBIT;
input TXPMARESET;
input TXPOLARITY;
input TXRESET;
input TXSCRAM64B66BUSE;
input TXSYNC;
input TXUSRCLK2;
input TXUSRCLK;
input [15:0] DI;
input [1:0] LOOPBACK;
input [1:0] RXDATAWIDTH;
input [1:0] RXINTDATAWIDTH;
input [1:0] TXDATAWIDTH;
input [1:0] TXINTDATAWIDTH;
input [2:0] RXCRCDATAWIDTH;
input [2:0] TXCRCDATAWIDTH;
input [4:0] CHBONDI;
input [63:0] RXCRCIN;
input [63:0] TXCRCIN;
input [63:0] TXDATA;
input [7:0] DADDR;
input [7:0] TXBYPASS8B10B;
input [7:0] TXCHARDISPMODE;
input [7:0] TXCHARDISPVAL;
input [7:0] TXCHARISK;

wire [15:0] OPEN_COMBUSOUT;

GT11 gt11_1 (
	.CHBONDI (CHBONDI),
	.CHBONDO (CHBONDO),
	.COMBUSIN (16'b0),
	.COMBUSOUT (OPEN_COMBUSOUT),
	.DADDR (DADDR),
	.DCLK (DCLK),
	.DEN (DEN),
	.DI (DI),
	.DO (DO),
	.DRDY (DRDY),
	.DWE (DWE),
	.ENCHANSYNC (ENCHANSYNC),
	.ENMCOMMAALIGN (ENMCOMMAALIGN),
	.ENPCOMMAALIGN (ENPCOMMAALIGN),
	.GREFCLK (GREFCLK),
	.LOOPBACK (LOOPBACK),
	.POWERDOWN (POWERDOWN),
	.REFCLK1 (REFCLK1),
	.REFCLK2 (REFCLK2),
	.RX1N (RX1N),
	.RX1P (RX1P),
	.RXBLOCKSYNC64B66BUSE (RXBLOCKSYNC64B66BUSE),
	.RXBUFERR (RXBUFERR),
	.RXCALFAIL (RXCALFAIL),
	.RXCHARISCOMMA (RXCHARISCOMMA),
	.RXCHARISK (RXCHARISK),
	.RXCLKSTABLE (RXCLKSTABLE),
	.RXCOMMADET (RXCOMMADET),
	.RXCOMMADETUSE (RXCOMMADETUSE),
	.RXCRCCLK (RXCRCCLK),
	.RXCRCDATAVALID (RXCRCDATAVALID),
	.RXCRCDATAWIDTH (RXCRCDATAWIDTH),
	.RXCRCIN (RXCRCIN),
	.RXCRCINIT (RXCRCINIT),
	.RXCRCINTCLK (RXCRCINTCLK),
	.RXCRCOUT (RXCRCOUT),
	.RXCRCPD (RXCRCPD),
	.RXCRCRESET (RXCRCRESET),
	.RXCYCLELIMIT (RXCYCLELIMIT),
	.RXDATA (RXDATA),
	.RXDATAWIDTH (RXDATAWIDTH),
	.RXDEC64B66BUSE (RXDEC64B66BUSE),
	.RXDEC8B10BUSE (RXDEC8B10BUSE),
	.RXDESCRAM64B66BUSE (RXDESCRAM64B66BUSE),
	.RXDISPERR (RXDISPERR),
	.RXIGNOREBTF (RXIGNOREBTF),
	.RXINTDATAWIDTH (RXINTDATAWIDTH),
	.RXLOCK (RXLOCK),
	.RXLOSSOFSYNC (RXLOSSOFSYNC),
	.RXMCLK (RXMCLK),
	.RXNOTINTABLE (RXNOTINTABLE),
	.RXPCSHCLKOUT (RXPCSHCLKOUT),
	.RXPMARESET (RXPMARESET),
	.RXPOLARITY (RXPOLARITY),
	.RXREALIGN (RXREALIGN),
	.RXRECCLK1 (RXRECCLK1),
	.RXRECCLK2 (RXRECCLK2),
	.RXRESET (RXRESET),
	.RXRUNDISP (RXRUNDISP),
	.RXSIGDET (RXSIGDET),
	.RXSLIDE (RXSLIDE),
	.RXSTATUS (RXSTATUS),
	.RXSYNC (RXSYNC),
	.RXUSRCLK (RXUSRCLK),
	.RXUSRCLK2 (RXUSRCLK2),
	.TX1N (TX1N),
	.TX1P (TX1P),
	.TXBUFERR (TXBUFERR),
	.TXBYPASS8B10B (TXBYPASS8B10B),
	.TXCALFAIL (TXCALFAIL),
	.TXCHARDISPMODE (TXCHARDISPMODE),
	.TXCHARDISPVAL (TXCHARDISPVAL),
	.TXCHARISK (TXCHARISK),
	.TXCLKSTABLE (TXCLKSTABLE),
	.TXCRCCLK (TXCRCCLK),
	.TXCRCDATAVALID (TXCRCDATAVALID),
	.TXCRCDATAWIDTH (TXCRCDATAWIDTH),
	.TXCRCIN (TXCRCIN),
	.TXCRCINIT (TXCRCINIT),
	.TXCRCINTCLK (TXCRCINTCLK),
	.TXCRCOUT (TXCRCOUT),
	.TXCRCPD (TXCRCPD),
	.TXCRCRESET (TXCRCRESET),
	.TXCYCLELIMIT (TXCYCLELIMIT),
	.TXDATA (TXDATA),
	.TXDATAWIDTH (TXDATAWIDTH),
	.TXENC64B66BUSE (TXENC64B66BUSE),
	.TXENC8B10BUSE (TXENC8B10BUSE),
	.TXENOOB (TXENOOB),
	.TXGEARBOX64B66BUSE (TXGEARBOX64B66BUSE),
	.TXINHIBIT (TXINHIBIT),
	.TXINTDATAWIDTH (TXINTDATAWIDTH),
	.TXKERR (TXKERR),
	.TXLOCK (TXLOCK),
	.TXOUTCLK1 (TXOUTCLK1),
	.TXOUTCLK2 (TXOUTCLK2),
	.TXPCSHCLKOUT (TXPCSHCLKOUT),
	.TXPMARESET (TXPMARESET),
	.TXPOLARITY (TXPOLARITY),
	.TXRESET (TXRESET),
	.TXRUNDISP (TXRUNDISP),
	.TXSCRAM64B66BUSE (TXSCRAM64B66BUSE),
	.TXSYNC (TXSYNC),
	.TXUSRCLK (TXUSRCLK),
	.TXUSRCLK2 (TXUSRCLK2)
);

defparam gt11_1.ALIGN_COMMA_WORD = ALIGN_COMMA_WORD;
defparam gt11_1.BANDGAPSEL = BANDGAPSEL;
defparam gt11_1.BIASRESSEL = BIASRESSEL;
defparam gt11_1.CCCB_ARBITRATOR_DISABLE = CCCB_ARBITRATOR_DISABLE;
defparam gt11_1.CHAN_BOND_LIMIT = CHAN_BOND_LIMIT;
defparam gt11_1.CHAN_BOND_MODE = CHAN_BOND_MODE;
defparam gt11_1.CHAN_BOND_ONE_SHOT = CHAN_BOND_ONE_SHOT;
defparam gt11_1.CHAN_BOND_SEQ_1_1 = CHAN_BOND_SEQ_1_1;
defparam gt11_1.CHAN_BOND_SEQ_1_2 = CHAN_BOND_SEQ_1_2;
defparam gt11_1.CHAN_BOND_SEQ_1_3 = CHAN_BOND_SEQ_1_3;
defparam gt11_1.CHAN_BOND_SEQ_1_4 = CHAN_BOND_SEQ_1_4;
defparam gt11_1.CHAN_BOND_SEQ_1_MASK = CHAN_BOND_SEQ_1_MASK;
defparam gt11_1.CHAN_BOND_SEQ_2_1 = CHAN_BOND_SEQ_2_1;
defparam gt11_1.CHAN_BOND_SEQ_2_2 = CHAN_BOND_SEQ_2_2;
defparam gt11_1.CHAN_BOND_SEQ_2_3 = CHAN_BOND_SEQ_2_3;
defparam gt11_1.CHAN_BOND_SEQ_2_4 = CHAN_BOND_SEQ_2_4;
defparam gt11_1.CHAN_BOND_SEQ_2_MASK = CHAN_BOND_SEQ_2_MASK;
defparam gt11_1.CHAN_BOND_SEQ_2_USE = CHAN_BOND_SEQ_2_USE;
defparam gt11_1.CHAN_BOND_SEQ_LEN = CHAN_BOND_SEQ_LEN;
defparam gt11_1.CLK_CORRECT_USE = CLK_CORRECT_USE;
defparam gt11_1.CLK_COR_8B10B_DE = CLK_COR_8B10B_DE;
defparam gt11_1.CLK_COR_MAX_LAT = CLK_COR_MAX_LAT;
defparam gt11_1.CLK_COR_MIN_LAT = CLK_COR_MIN_LAT;
defparam gt11_1.CLK_COR_SEQ_1_1 = CLK_COR_SEQ_1_1;
defparam gt11_1.CLK_COR_SEQ_1_2 = CLK_COR_SEQ_1_2;
defparam gt11_1.CLK_COR_SEQ_1_3 = CLK_COR_SEQ_1_3;
defparam gt11_1.CLK_COR_SEQ_1_4 = CLK_COR_SEQ_1_4;
defparam gt11_1.CLK_COR_SEQ_1_MASK = CLK_COR_SEQ_1_MASK;
defparam gt11_1.CLK_COR_SEQ_2_1 = CLK_COR_SEQ_2_1;
defparam gt11_1.CLK_COR_SEQ_2_2 = CLK_COR_SEQ_2_2;
defparam gt11_1.CLK_COR_SEQ_2_3 = CLK_COR_SEQ_2_3;
defparam gt11_1.CLK_COR_SEQ_2_4 = CLK_COR_SEQ_2_4;
defparam gt11_1.CLK_COR_SEQ_2_MASK = CLK_COR_SEQ_2_MASK;
defparam gt11_1.CLK_COR_SEQ_2_USE = CLK_COR_SEQ_2_USE;
defparam gt11_1.CLK_COR_SEQ_DROP = CLK_COR_SEQ_DROP;
defparam gt11_1.CLK_COR_SEQ_LEN = CLK_COR_SEQ_LEN;
defparam gt11_1.COMMA32 = COMMA32;
defparam gt11_1.COMMA_10B_MASK = COMMA_10B_MASK;
defparam gt11_1.CYCLE_LIMIT_SEL = CYCLE_LIMIT_SEL;
defparam gt11_1.DCDR_FILTER = DCDR_FILTER;
defparam gt11_1.DEC_MCOMMA_DETECT = DEC_MCOMMA_DETECT;
defparam gt11_1.DEC_PCOMMA_DETECT = DEC_PCOMMA_DETECT;
defparam gt11_1.DEC_VALID_COMMA_ONLY = DEC_VALID_COMMA_ONLY;
defparam gt11_1.DIGRX_FWDCLK = DIGRX_FWDCLK;
defparam gt11_1.DIGRX_SYNC_MODE = DIGRX_SYNC_MODE;
defparam gt11_1.ENABLE_DCDR = ENABLE_DCDR;
defparam gt11_1.FDET_HYS_CAL = FDET_HYS_CAL;
defparam gt11_1.FDET_HYS_SEL = FDET_HYS_SEL;
defparam gt11_1.FDET_LCK_CAL = FDET_LCK_CAL;
defparam gt11_1.FDET_LCK_SEL = FDET_LCK_SEL;
defparam gt11_1.GT11_MODE = "SINGLE";
defparam gt11_1.IREFBIASMODE = IREFBIASMODE;
defparam gt11_1.LOOPCAL_WAIT = LOOPCAL_WAIT;
defparam gt11_1.MCOMMA_32B_VALUE = MCOMMA_32B_VALUE;
defparam gt11_1.MCOMMA_DETECT = MCOMMA_DETECT;
defparam gt11_1.OPPOSITE_SELECT = OPPOSITE_SELECT;
defparam gt11_1.PCOMMA_32B_VALUE = PCOMMA_32B_VALUE;
defparam gt11_1.PCOMMA_DETECT = PCOMMA_DETECT;
defparam gt11_1.PCS_BIT_SLIP = PCS_BIT_SLIP;
defparam gt11_1.PMACLKENABLE = PMACLKENABLE;
defparam gt11_1.PMACOREPWRENABLE = PMACOREPWRENABLE;
defparam gt11_1.PMAIREFTRIM = PMAIREFTRIM;
defparam gt11_1.PMAVBGCTRL = PMAVBGCTRL;
defparam gt11_1.PMAVREFTRIM = PMAVREFTRIM;
defparam gt11_1.PMA_BIT_SLIP = PMA_BIT_SLIP;
defparam gt11_1.POWER_ENABLE = POWER_ENABLE;
defparam gt11_1.REPEATER = REPEATER;
defparam gt11_1.RXACTST = RXACTST;
defparam gt11_1.RXAFEEQ = RXAFEEQ;
defparam gt11_1.RXAFEPD = RXAFEPD;
defparam gt11_1.RXAFETST = RXAFETST;
defparam gt11_1.RXAPD = RXAPD;
defparam gt11_1.RXAREGCTRL = RXAREGCTRL;
defparam gt11_1.RXASYNCDIVIDE = RXASYNCDIVIDE;
defparam gt11_1.RXBY_32 = RXBY_32;
defparam gt11_1.RXCDRLOS = RXCDRLOS;
defparam gt11_1.RXCLK0_FORCE_PMACLK = RXCLK0_FORCE_PMACLK;
defparam gt11_1.RXCLKMODE = RXCLKMODE;
defparam gt11_1.RXCLMODE = RXCLMODE;
defparam gt11_1.RXCMADJ = RXCMADJ;
defparam gt11_1.RXCPSEL = RXCPSEL;
defparam gt11_1.RXCPTST = RXCPTST;
defparam gt11_1.RXCRCCLOCKDOUBLE = RXCRCCLOCKDOUBLE;
defparam gt11_1.RXCRCENABLE = RXCRCENABLE;
defparam gt11_1.RXCRCINITVAL = RXCRCINITVAL;
defparam gt11_1.RXCRCINVERTGEN = RXCRCINVERTGEN;
defparam gt11_1.RXCRCSAMECLOCK = RXCRCSAMECLOCK;
defparam gt11_1.RXCTRL1 = RXCTRL1;
defparam gt11_1.RXCYCLE_LIMIT_SEL = RXCYCLE_LIMIT_SEL;
defparam gt11_1.RXDATA_SEL = RXDATA_SEL;
defparam gt11_1.RXDCCOUPLE = RXDCCOUPLE;
defparam gt11_1.RXDIGRESET = RXDIGRESET;
defparam gt11_1.RXDIGRX = RXDIGRX;
defparam gt11_1.RXEQ = RXEQ;
defparam gt11_1.RXFDCAL_CLOCK_DIVIDE = RXFDCAL_CLOCK_DIVIDE;
defparam gt11_1.RXFDET_HYS_CAL = RXFDET_HYS_CAL;
defparam gt11_1.RXFDET_HYS_SEL = RXFDET_HYS_SEL;
defparam gt11_1.RXFDET_LCK_CAL = RXFDET_LCK_CAL;
defparam gt11_1.RXFDET_LCK_SEL = RXFDET_LCK_SEL;
defparam gt11_1.RXFECONTROL1 = RXFECONTROL1;
defparam gt11_1.RXFECONTROL2 = RXFECONTROL2;
defparam gt11_1.RXFETUNE = RXFETUNE;
defparam gt11_1.RXLB = RXLB;
defparam gt11_1.RXLKADJ = RXLKADJ;
defparam gt11_1.RXLKAPD = RXLKAPD;
defparam gt11_1.RXLOOPCAL_WAIT = RXLOOPCAL_WAIT;
defparam gt11_1.RXLOOPFILT = RXLOOPFILT;
defparam gt11_1.RXMODE = RXMODE;
defparam gt11_1.RXOUTDIV2SEL = RXOUTDIV2SEL;
defparam gt11_1.RXPD = RXPD;
defparam gt11_1.RXPDDTST = RXPDDTST;
defparam gt11_1.RXPLLNDIVSEL = RXPLLNDIVSEL;
defparam gt11_1.RXPMACLKSEL = RXPMACLKSEL;
defparam gt11_1.RXRCPADJ = RXRCPADJ;
defparam gt11_1.RXRCPPD = RXRCPPD;
defparam gt11_1.RXRECCLK1_USE_SYNC = RXRECCLK1_USE_SYNC;
defparam gt11_1.RXRIBADJ = RXRIBADJ;
defparam gt11_1.RXRPDPD = RXRPDPD;
defparam gt11_1.RXRSDPD = RXRSDPD;
defparam gt11_1.RXSLOWDOWN_CAL = RXSLOWDOWN_CAL;
defparam gt11_1.RXTUNE = RXTUNE;
defparam gt11_1.RXUSRDIVISOR = RXUSRDIVISOR;
defparam gt11_1.RXVCODAC_INIT = RXVCODAC_INIT;
defparam gt11_1.RXVCO_CTRL_ENABLE = RXVCO_CTRL_ENABLE;
defparam gt11_1.RX_BUFFER_USE = RX_BUFFER_USE;
defparam gt11_1.RX_CLOCK_DIVIDER = RX_CLOCK_DIVIDER;
defparam gt11_1.SAMPLE_8X = SAMPLE_8X;
defparam gt11_1.SH_CNT_MAX = SH_CNT_MAX;
defparam gt11_1.SH_INVALID_CNT_MAX = SH_INVALID_CNT_MAX;
defparam gt11_1.SLOWDOWN_CAL = SLOWDOWN_CAL;
defparam gt11_1.TXABPMACLKSEL = TXABPMACLKSEL;
defparam gt11_1.TXAPD = TXAPD;
defparam gt11_1.TXAREFBIASSEL = TXAREFBIASSEL;
defparam gt11_1.TXASYNCDIVIDE = TXASYNCDIVIDE;
defparam gt11_1.TXCLK0_FORCE_PMACLK = TXCLK0_FORCE_PMACLK;
defparam gt11_1.TXCLKMODE = TXCLKMODE;
defparam gt11_1.TXCLMODE = TXCLMODE;
defparam gt11_1.TXCPSEL = TXCPSEL;
defparam gt11_1.TXCRCCLOCKDOUBLE = TXCRCCLOCKDOUBLE;
defparam gt11_1.TXCRCENABLE = TXCRCENABLE;
defparam gt11_1.TXCRCINITVAL = TXCRCINITVAL;
defparam gt11_1.TXCRCINVERTGEN = TXCRCINVERTGEN;
defparam gt11_1.TXCRCSAMECLOCK = TXCRCSAMECLOCK;
defparam gt11_1.TXCTRL1 = TXCTRL1;
defparam gt11_1.TXDATA_SEL = TXDATA_SEL;
defparam gt11_1.TXDAT_PRDRV_DAC = TXDAT_PRDRV_DAC;
defparam gt11_1.TXDAT_TAP_DAC = TXDAT_TAP_DAC;
defparam gt11_1.TXDIGPD = TXDIGPD;
defparam gt11_1.TXFDCAL_CLOCK_DIVIDE = TXFDCAL_CLOCK_DIVIDE;
defparam gt11_1.TXHIGHSIGNALEN = TXHIGHSIGNALEN;
defparam gt11_1.TXLOOPFILT = TXLOOPFILT;
defparam gt11_1.TXLVLSHFTPD = TXLVLSHFTPD;
defparam gt11_1.TXOUTCLK1_USE_SYNC = TXOUTCLK1_USE_SYNC;
defparam gt11_1.TXOUTDIV2SEL = TXOUTDIV2SEL;
defparam gt11_1.TXPD = TXPD;
defparam gt11_1.TXPHASESEL = TXPHASESEL;
defparam gt11_1.TXPLLNDIVSEL = TXPLLNDIVSEL;
defparam gt11_1.TXPOST_PRDRV_DAC = TXPOST_PRDRV_DAC;
defparam gt11_1.TXPOST_TAP_DAC = TXPOST_TAP_DAC;
defparam gt11_1.TXPOST_TAP_PD = TXPOST_TAP_PD;
defparam gt11_1.TXPRE_PRDRV_DAC = TXPRE_PRDRV_DAC;
defparam gt11_1.TXPRE_TAP_DAC = TXPRE_TAP_DAC;
defparam gt11_1.TXPRE_TAP_PD = TXPRE_TAP_PD;
defparam gt11_1.TXSLEWRATE = TXSLEWRATE;
defparam gt11_1.TXTERMTRIM = TXTERMTRIM;
defparam gt11_1.TXTUNE = TXTUNE;
defparam gt11_1.TX_BUFFER_USE = TX_BUFFER_USE;
defparam gt11_1.TX_CLOCK_DIVIDER = TX_CLOCK_DIVIDER;
defparam gt11_1.VCODAC_INIT = VCODAC_INIT;
defparam gt11_1.VCO_CTRL_ENABLE = VCO_CTRL_ENABLE;
defparam gt11_1.VREFBIASMODE = VREFBIASMODE;

endmodule
