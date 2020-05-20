// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#include "hdmi_terasic_includes.h"
#include "mcu.h"
#include "system.h"
#include "HDMI_TX.h"
#include "HDMI_RX.h"
#include <math.h>

#include <ctype.h>

/* <stdlib.h>: Contains C "rand()" function. */
#include <stdlib.h>

/* MicroC/OS-II definitions */
#include "includes.h"

/* Nichestack definitions */
#include "ipport.h"
#include "tcpport.h"
#include "osport.h"
#include "basedef.h"


#include "my_mem_defs.h"
#include "mem.h"
#include "hdmi_main.h"

int hdmi_tx_ready = 0;
//=========================================================================
// Function configuration
//=========================================================================
#define RX_DISABLED
// -define RX_DISABLED to disable RX(HDMI Reciver) function
// -defulat: RX_DISABLED is not defined

#define xTX_DISABLED        
// -define TX_DISABLED to disable TX(HDMI Transmitter) function
// -defulat: TX_DISABLED is not defined

#define xTX_VPG_COLOR_CTRL_DISABLED
// -define TX_VPG_COLOR_CTRL_DISABLED to enable users to select 
//  RGB444, YUV422, or YUV444 as TX input color under TX-only mode.   
//   control by press button[1] on main board

// -defulat: TX_VPG_COLOR_CTRL_DISABLED is not defined


#define xTX_CSC_DISABLED   
// -define TX_CSC_DISABLED to disable color space transform in TX
// - TX always output RGB444 if TX_CSC_DISABLED is not defined 
// - TX always bypass input color to output color if TX_CSC_DISABLED is defined 
// -defulat: TX_CSC_DISABLED is not defined

typedef enum{
    DEMO_READY = 0,
    DEMO_TX_ONLY,
    DEMO_LOOPBACK
}DEMO_MODE;
DEMO_MODE gDemoMode = DEMO_READY;


// audio waveform to i2s audio
extern const unsigned int szWave[];
extern const unsigned int nWaveSize;
extern int gEnableColorDepth;
bool SetupColorSpace(void);

//=========================================================================
// VPG data definition
// VPG: Video Pattern Generation, implement in vpg.v
//=========================================================================

char gszVicText[][64] = {
    "720x480p60 VIC=3",
    "1024x768p60",
    "1280x720p50 VIC=19",
    "1280x720p60 VIC=4",
    "1280x1024",
    "1920x1080i60 VIC=5",
    "1920x1080i50 VIC=20",
    "1920x1080p60 VIC=16",
    "1920x1080p50 VIC=31",
    "1600x1200",
    "1920x1080i120 VIC=46",
};

typedef enum{
    MODE_720x480        =0,   // 480p,    27      MHZ    VIC=3
    MODE_1024x768       =1,   // XGA,     65      MHZ  
    MODE_1280x720p50    =2,   // 720p50   74.25   MHZ    VIC=19
    MODE_1280x720       =3,   // 720p,    74.25   MHZ    VIC=4 
    MODE_1280x1024      =4,   // SXGA,    108     MHZ
    MODE_1920x1080i     =5,   // 1080i,   74.25   MHZ    VIC=5 
    MODE_1920x1080i50   =6,   // 1080i,   74.25   MHZ    VIC=20 
    MODE_1920x1080      =7,   // 1080p,   148.5   MHZ    VIC=16  
    MODE_1920x1080p50   =8,   // 1080p50, 148.5   MHZ    VIC=31  
    MODE_1600x1200      =9,   // UXGA,    162     MHZ 
    MODE_1920x1080i120  =10  // 1080i120,148.5   MHZ    VIC=46
}VPG_MODE;

typedef enum{
    VPG_RGB444  =0,
    VPG_YUV422  =1,
    VPG_YUV444  =2
}VPG_COLOR;


VPG_MODE gVpgMode = MODE_1024x768; //MODE_720x480; //MODE_1920x1080;
COLOR_TYPE gVpgColor = COLOR_RGB444;   // video pattern generator - output color (defined ind vpg.v)


//=========================================================================
// HDMI I2S autio Control
//=========================================================================

bool gbPlayTone = TRUE;

#define I2S_REG_CSR             0
#define I2S_REG_FIFO            1
#define I2S_REG_IRQ_CLEAR       2
#define I2S_REG_FIFO_USEDW      3

#define I2S_CSR_GO              0x1
#define I2S_CSR_FIFO_FULL       0x2
#define I2S_CSR_FIFO_EMPTY      0x4


void THDMI_TX_I2S_Start(void){
     IOWR(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_CSR, 0x01);
}

void THDMI_TX_I2S_Stop(void){
     IOWR(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_CSR, 0x00);
}

void THDMI_TX_I2S_Play(alt_u32 szData[], int nNum){
    int i;
    alt_u32 Status, Value;
    for(i=0;i<nNum;i++){
        Status = I2S_CSR_FIFO_FULL;
        while(Status & I2S_CSR_FIFO_FULL){
            Status = IORD(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_CSR);
        } 
        Value = szData[i];
        IOWR(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_FIFO, Value);
    }        
}

void i2s_isr(void* context, alt_u32 id){
    static int nIndex = 0;

    if (gbPlayTone){
        int nPushNum,i;
        nPushNum = 256 - IORD(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_FIFO_USEDW);
        for(i=0;i<nPushNum;i++){
            IOWR(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_FIFO, szWave[nIndex]);
            nIndex++;
            if (nIndex >= nWaveSize){ //sizeof(szWave)/sizeof(szWave[0]))
                nIndex = 0;        
                gbPlayTone = FALSE;
            }            
        }
    }        
 
    //THDMI_TX_I2S_Play(szWave, sizeof(szWave)/sizeof(szWave[0]));
    // clear irq flag
    IOWR(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_IRQ_CLEAR, 0x00);
}

//=========================================================================
// TX video formation control
//=========================================================================

void FindVIC(VPG_MODE Mode, alt_u8 *vic, bool *pb16x9){

    switch(Mode){
        case MODE_720x480: *vic = 3; break;
        case MODE_1280x720p50: *vic = 19; break;
        case MODE_1280x720: *vic = 4; break;
        case MODE_1920x1080i: *vic = 5; break;
        case MODE_1920x1080i50: *vic = 20; break;
        case MODE_1920x1080: *vic = 16; break;
        case MODE_1920x1080p50: *vic = 31; break;
        case MODE_1920x1080i120: *vic = 46; break;
        default:
            *vic = 0;
    }
    
    if (*vic != 0)
        *pb16x9 = TRUE;
    else         
        *pb16x9 = FALSE;
    

}

void SetupTxVIC(VPG_MODE Mode){
    alt_u8 tx_vic;
    bool b16x9;
    FindVIC(Mode, &tx_vic, &b16x9);
    HDMITX_ChangeVideoTiming(tx_vic);    
}


void VPG_Config(VPG_MODE Mode, COLOR_TYPE Color){
#ifndef TX_DISABLED
    
    //===== check whether vpg function is active
    if (!HDMITX_HPD())
        return;
    #ifndef RX_DISABLED        
    if (HDMIRX_IsVideoOn())
        return;    
    #endif //RX_DISABLED    


    OS_PRINTF("===> Pattern Generator Mode: %d (%s)\n", gVpgMode, gszVicText[gVpgMode]);
    
    //===== updagte vpg mode & color   
    IOWR(HDMI_SUBSYSTEM_HDMI_TX_MODE_CHANGE_BASE, 0, 0);
        // change color mode of VPG
        if (gVpgColor == COLOR_RGB444)
            IOWR(HDMI_SUBSYSTEM_HDMI_TX_VPG_COLOR_BASE, 0, VPG_RGB444);  // RGB444
        else if (gVpgColor == COLOR_YUV422)
            IOWR(HDMI_SUBSYSTEM_HDMI_TX_VPG_COLOR_BASE, 0, VPG_YUV422);  // YUV422
        else if (gVpgColor == COLOR_YUV444)
            IOWR(HDMI_SUBSYSTEM_HDMI_TX_VPG_COLOR_BASE, 0, VPG_YUV444);  // YUV444
    
    IOWR(HDMI_SUBSYSTEM_HDMI_TX_DISP_MODE_BASE, 0, gVpgMode);
    IOWR(HDMI_SUBSYSTEM_HDMI_TX_MODE_CHANGE_BASE, 0, 1);
    IOWR(HDMI_SUBSYSTEM_HDMI_TX_MODE_CHANGE_BASE, 0, 0);
    //
    //HDMITX_EnableVideoOutput();

#endif //#ifndef TX_DISABLED      
}




bool SetupColorSpace(void){
    char szColor[][32] = {"RGB444", "YUV422", "YUV444"};
    bool bSuccess = TRUE;
    bool bRxVideoOn = FALSE;
    COLOR_TYPE TxInputColor;
    COLOR_TYPE TxOutputColor;    
#ifndef RX_DISABLED
    bRxVideoOn = HDMIRX_IsVideoOn();
#endif // RX_DISABLED
    
    
#ifndef TX_DISABLED
    if (gDemoMode == DEMO_LOOPBACK){
        // rx-tx loopback
        int RxSourceColor, RxSinkColor;
        bSuccess = HDMIRX_GetSourceColor(&RxSourceColor);
        if (bSuccess){
            // RX-TX loopback (bypass)
            if (RxSourceColor == COLOR_RGB444 ||
                (RxSourceColor == COLOR_YUV422 && HDMITX_IsSinkSupportYUV422()) ||
                (RxSourceColor == COLOR_YUV444 && HDMITX_IsSinkSupportYUV444())){ 
                    
                // Source color --> RX --> TX ---> Display
                // bypass color space    
                TxInputColor = RxSourceColor;
                TxOutputColor = RxSourceColor;
                RxSinkColor = RxSourceColor;
            }else{
                // Source color --> RX --(RGB color)--> TX --(RBG Color)--> Display
                TxInputColor = COLOR_RGB444;
                TxOutputColor = COLOR_RGB444;
                RxSinkColor = COLOR_RGB444;
            }                
            HDMIRX_SetOutputColor(RxSinkColor);
            OS_PRINTF("Set Rx Color Convert:%s->%s\n", szColor[RxSourceColor], szColor[RxSinkColor]);
        }
    }else if (gDemoMode == DEMO_TX_ONLY){
        // tx-only
        #ifdef TX_CSC_DISABLED
            // Transmittor: output color == input color
            TxInputColor = gVpgColor;  
            TxOutputColor = gVpgColor;
        #else
            // Trasmitter: output color is fixed as RGB 
            TxInputColor = gVpgColor;
            TxOutputColor = COLOR_RGB444;
        #endif

        
    }else{
        return TRUE;
    }
    
    HDMITX_SetColorSpace(TxInputColor, TxOutputColor);
          
    
    // set TX color depth
    int ColorDepth = 24; // defualt
    if (gEnableColorDepth){
        if (HDMITX_IsSinkSupportColorDepth36())
            ColorDepth = 36;
        else if (HDMITX_IsSinkSupportColorDepth30())
            ColorDepth = 30;
    }                        
    HDMITX_SetOutputColorDepth(ColorDepth); 
    
    OS_PRINTF("Set Tx Color Depth: %d bits %s\n", ColorDepth, gEnableColorDepth?"":"(default)");
    OS_PRINTF("Set Tx Color Convert:%s->%s\n", szColor[TxInputColor], szColor[TxOutputColor]);
    
    #if 0   // dump debug message
        int i;
        HDMITX_DumpReg(0xC0);
        HDMITX_DumpReg(0x72);
        for(i=0x73;i<=0x8d;i++)
            HDMITX_DumpReg(i);
        HDMITX_DumpReg(0x158);
    #endif          
    
#endif //TX_DISABLED
    return bSuccess;     
}



//=========================================================================
// Button ISR (Interrupt Service Routine)
//=========================================================================


void button_isr(void* context, alt_u32 id){
    static alt_u32 NextActiveTime = 0;
    bool bUpdateVPG = FALSE;
   // static alt_u8 disp_mode = 0;
    alt_u8 pushbutton_mask;
    
 //   if (id != PIO_BUTTON_IRQ)
 //       return;
    
    // get the edge capture mask
    pushbutton_mask = IORD_ALTERA_AVALON_PIO_EDGE_CAP(
    		HDMI_SUBSYSTEM_PIO_BUTTON_BASE) & 0x03;  // button0/1

    // Reset the edge capture register
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(HDMI_SUBSYSTEM_PIO_BUTTON_BASE,0);
    
    // the following function only work for tx-only mode
    if (gDemoMode != DEMO_TX_ONLY)  
        return; 
    
    if (pushbutton_mask & 0x02){ // BUTTON[1]     // play tone
        gbPlayTone = TRUE;
        #ifndef TX_VPG_COLOR_CTRL_DISABLED
            if (alt_nticks() > NextActiveTime){ 
                gVpgColor++;
                if (gVpgColor == COLOR_YUV422 && !HDMITX_IsSinkSupportYUV422())
                    gVpgColor++;
                if (gVpgColor == COLOR_YUV444 && !HDMITX_IsSinkSupportYUV444())
                    gVpgColor++;
                if (gVpgColor == COLOR_MODE_NUM)
                    gVpgColor = 0;  // RGB
                bUpdateVPG = TRUE;     
                NextActiveTime = alt_nticks() + alt_ticks_per_second()/2;
            }                
        #endif //TX_VPG_COLOR_CTRL_DISABLED
    }else if (pushbutton_mask & 0x01){ // BUTTON[0]    // change pattern generotor's pattern
        if (alt_nticks() > NextActiveTime){  // note. timer should have a highter IRQ priority than button
            // next mode
        	/*
            if (gVpgMode == MODE_1920x1080i120)
                gVpgMode = MODE_720x480;
            else    
                gVpgMode++;
            */
        	gVpgMode = MODE_1024x768;
            bUpdateVPG = TRUE;  
            NextActiveTime = alt_nticks() + alt_ticks_per_second()/2;
        }            
    }
    
    if (bUpdateVPG){
        HDMITX_DisableVideoOutput();
        VPG_Config(gVpgMode, gVpgColor);
        SetupTxVIC(gVpgMode);
        SetupColorSpace();             
        HDMITX_EnableVideoOutput();        
    }
      
}



//=========================================================================
// Main Function
//=========================================================================

void hdmi_main_process(void *pd) {
	hdmi_main();
}

int hdmi_main()
{
    bool bRxVideoOn = FALSE, bTxSinkOn = FALSE, bRxModeChanged = FALSE;
    alt_u8 led_mask;
    alt_u32 BlinkTime;
    bool bHwNg = FALSE;

    // disable color depth if button1 is pressed when system boot.  
    gEnableColorDepth = ((~IORD(HDMI_SUBSYSTEM_PIO_BUTTON_BASE,0)) & 0x02)?0:1;
    
    OS_PRINTF("\n======== HDMI Demo ==============\n");
    
    //-------------------------------   
    // HDMI TX init
    //-------------------------------   
#ifndef TX_DISABLED    
    if (!HDMITX_Init()){
        printf("Failed to find CAT6613 HDMI-TX Chip.\n");
        bHwNg = TRUE;
        //return 0;
    }
    
    // init tx i2s irq
    THDMI_TX_I2S_Start();     
    IOWR(HDMI_SUBSYSTEM_I2S_TX_BASE, I2S_REG_IRQ_CLEAR, 0x00);  //clear interrupt flag
#ifndef DISABLE_HDMI_TX_IRQS
    // hdmi i2s irq
    if ((alt_irq_register(HDMI_SUBSYSTEM_I2S_TX_IRQ, (void *)0, i2s_isr) != 0))
        OS_PRINTF("[I2S]register callback fail\n");
    else        
        OS_PRINTF("[I2S]register callback success\n");
#endif
    //   
    // button irq for generate audio    
    // enable interrupt, button0/1
    
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(HDMI_SUBSYSTEM_PIO_BUTTON_BASE, 0x03);

    // Reset the edge capture register
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(HDMI_SUBSYSTEM_PIO_BUTTON_BASE,0);
#ifndef DISABLE_HDMI_TX_IRQS
    if ((alt_irq_register(HDMI_SUBSYSTEM_PIO_BUTTON_IRQ, (void *)0, button_isr) != 0))
        OS_PRINTF("[I2S]register button callback fail\n");
    else        
        OS_PRINTF("[I2S]register button callback success\n");      
#endif

#endif //TX_DISABLED        


    //-------------------------------   
    // HDMI RX init
    //-------------------------------   

#ifndef RX_DISABLED     
   
    IOWR(HDMI_RX_HPD_N_BASE, 0, 0x03);    // pull-low hdmi connector hpd
    OS_DelayMS(1); // 1 ms
    if (!HDMIRX_Init(RX_PORT_AUTO))
        bHwNg = TRUE;
    IOWR(HDMI_RX_HPD_N_BASE, 0, 0x00); // pull-high hdmi connector hpd
    
#endif //RX_ENABLED    
    
        
    IOWR(HDMI_SUBSYSTEM_HDMI_RX_SYNC_BASE, 0,0x00);
    led_mask = ~0x01;
    IOWR(HDMI_SUBSYSTEM_PIO_LED_BASE, 0, led_mask);
    BlinkTime = alt_nticks() + alt_ticks_per_second()/4;
    
    if (bHwNg){
        led_mask = 0x00;
        while(1){
            if (alt_nticks() > BlinkTime){
                IOWR(HDMI_SUBSYSTEM_PIO_LED_BASE, 0, led_mask);
                led_mask ^= 0xFF;
                BlinkTime = alt_nticks() + alt_ticks_per_second()/4;
            }                
        }
    }
    
    //-------------------------------   
    // MAIN LOOP
    //-------------------------------   
    hdmi_tx_ready = 1;

    while(1){
    	 OSTimeDlyHMSM(0,0,0,LINNUX_DEFAULT_PROCESS_DLY_MS);

#ifndef TX_DISABLED
        //========== TX          
        if (HDMITX_DevLoopProc() || bRxModeChanged){
            bTxSinkOn = HDMITX_HPD();    
            if (bTxSinkOn){
                // update state
                gDemoMode = bRxVideoOn?DEMO_LOOPBACK: DEMO_TX_ONLY;
                //
                HDMITX_DisableVideoOutput();
                if (gDemoMode == DEMO_TX_ONLY){
                    // tx-only
                    VPG_Config(gVpgMode, gVpgColor);
                    SetupTxVIC(gVpgMode);
                }
                SetupColorSpace();
                HDMITX_EnableVideoOutput();
            }else{
                HDMITX_DisableVideoOutput();
            }
        }

#endif //
        
#ifndef RX_DISABLED
        //========== RX        
        bRxModeChanged = HDMIRX_DevLoopProc();
        if (HDMIRX_IsVideoOn() ^ bRxVideoOn){
            bRxVideoOn = HDMIRX_IsVideoOn();
            IOWR(HDMI_RX_SYNC_BASE, 0, bRxVideoOn?0x01:0x00);
            OS_PRINTF("[RX]Video On:%s\n", bRxVideoOn?"Yes":"No");
            // update state
            gDemoMode = !bTxSinkOn?DEMO_READY:(bRxVideoOn?DEMO_LOOPBACK:DEMO_TX_ONLY);
        }            
        
        if (bRxModeChanged && bRxVideoOn){
        #ifndef TX_DISABLED
            // bypass AviInfoFrame from source to sink
            alt_u8 VIC, ColorMode;
            bool b16x9, bITU709;
            if (HDMIRX_GetAVIInfoFrame(&VIC, &ColorMode, &b16x9, &bITU709)){
                HDMITX_ChangeVideoTimingAndColor(VIC, ColorMode);
            }
            //SetupColorSpace();    
        #endif
        }
#endif //RX_ENABLED        

        //===== LED indication
        if (alt_nticks() > BlinkTime){
            led_mask ^= 0x03;
            led_mask |= ~0x03;
            if (HDMITX_HPD())
                led_mask &= ~0x04;  // rx-source available (led is low-active)
            if (bRxVideoOn)
                led_mask &= ~0x08;  // rx-source available (led is low-active)
                
            IOWR(HDMI_SUBSYSTEM_PIO_LED_BASE, 0, led_mask);
            //led_mask ^= 0xFF;
            
            BlinkTime = alt_nticks() + alt_ticks_per_second()/4;
        }     
        
#if 0   // (DEBUG Purpose) dump register if button is pressed        
        alt_u8 mask;
        mask = (~IORD(PIO_BUTTON_BASE,0)) & 0x03;  // active low (PCI)
        if ((mask & 0x01)  == 0x01){  // BUTTON[0]
            HDMITX_DumpAllReg();
            HDMIRX_DumpAllReg();
        }    
#endif             
               
        
    }
   
}  

