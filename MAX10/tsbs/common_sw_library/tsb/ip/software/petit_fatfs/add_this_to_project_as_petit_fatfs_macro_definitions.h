#ifndef PETIT_FATFS_MACRO_DEFINITIONS_H
#define PETIT_FATFS_MACRO_DEFINITIONS_H

#define	INIT_PORT()	do {} while(0)	    /* Initialize MMC control port (CS/CLK/DI:output, DO:input) */
#define DLY_US(n)	usleep(n)	        /* Delay n microseconds */
#define	FORWARD(d)	do {} while(0)	    /* Data in-time processing function (depends on the project) */

#define	CS_H()		sd_card_cs_set(1)	/* Set MMC CS "high" */
#define CS_L()		sd_card_cs_set(0)	/* Set MMC CS "low" */
#define CK_H()		sd_card_clk_set(1)	/* Set MMC SCLK "high" */
#define	CK_L()		sd_card_clk_set(0)	/* Set MMC SCLK "low" */
#define DI_H()		sd_card_mosi_set(1)	/* Set MMC DI "high" */
#define DI_L()		sd_card_mosi_set(0)	/* Set MMC DI "low" */
#define DO			sd_card_get_miso()	/* Test MMC DO (high:true, low:false) */

#endif