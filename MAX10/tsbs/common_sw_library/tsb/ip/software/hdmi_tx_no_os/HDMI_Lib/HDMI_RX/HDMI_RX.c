#include "hdmi_terasic_includes.h"
#include "HDMI_RX.h"
#include "mcu.h"
#include "hdmi_i2c.h"
#include "it6605.h"

extern Video_State_Type VState;
static RX_PORT_CONFIG RxPortConfig = RX_PORT_A;
static RX_PORT_CONFIG RxActivePort = RX_PORT_A;
static bool bModeChanged = FALSE;

const unsigned char szDefaultEDID[] = {
0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x0C, 0x34, 0x60, 0x66, 0x00, 0x00, 0x00, 0x00, 
0x32, 0x10, 0x01, 0x03, 0x80, 0x3C, 0x22, 0x78, 0x2A, 0x03, 0x20, 0xA7, 0x55, 0x45, 0x96, 0x24, 
0x11, 0x49, 0x4B, 0x1F, 0xDF, 0x00, 0x45, 0x59, 0xA9, 0x40, 0x81, 0x80, 0x31, 0x59, 0x01, 0x01, 
0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x1D, 0x80, 0x18, 0x71, 0x1C, 0x16, 0x20, 0x58, 0x2C, 
0x25, 0x00, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x9E, 0x8C, 0x0A, 0xD0, 0x8A, 0x20, 0xE0, 0x2D, 0x10, 
0x10, 0x3E, 0x96, 0x00, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0xFC, 0x00, 0x43, 
0x41, 0x54, 0x2D, 0x36, 0x30, 0x36, 0x36, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x00, 0x00, 0x00, 0xFD, 
0x00, 0x38, 0x4B, 0x1F, 0x32, 0x08, 0x00, 0x0A, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x01, 0xD1, 
0x02, 0x03, 0x25, 0x71, 0x4F, 0x85, 0x02, 0x03, 0x04, 0x01, 0x06, 0x07, 0x11, 0x12, 0x13, 0x14, 
0x15, 0x16, 0x10, 0x1F, 0x23, 0x09, 0x07, 0x07, 0x83, 0x01, 0x00, 0x00, 0x68, 0x03, 0x0C, 0x00, 
0x10, 0x00, 0x38, 0x2D, 0x00, 0x01, 0x1D, 0x80, 0xD0, 0x72, 0x1C, 0x16, 0x20, 0x10, 0x2C, 0x25, 
0x80, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x9E, 0x8C, 0x0A, 0xA0, 0x14, 0x51, 0xF0, 0x16, 0x00, 0x26, 
0x7C, 0x43, 0x00, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x98, 0x01, 0x1D, 0x00, 0x72, 0x51, 0xD0, 0x1E, 
0x20, 0x6E, 0x28, 0x55, 0x00, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x1E, 0x01, 0x1D, 0x00, 0xBC, 0x52, 
0xD0, 0x1E, 0x20, 0xB8, 0x28, 0x55, 0x40, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x1E, 0x00, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 
};


/*


unsigned char szDefaultEDID[] = {
0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x04, 0x21, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
0x01, 0x00, 0x01, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01,
0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x64, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x10,
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38,
0x02, 0x03, 0x25, 0x71, 0x4F, 0x85, 0x02, 0x03, 0x04, 0x01, 0x06, 0x07, 0x11, 0x12, 0x13, 0x14, 
0x15, 0x16, 0x10, 0x1F, 0x23, 0x09, 0x07, 0x07, 0x83, 0x01, 0x00, 0x00, 0x68, 0x03, 0x0C, 0x00, 
0x10, 0x00, 0x38, 0x2D, 0x00, 0x01, 0x1D, 0x80, 0xD0, 0x72, 0x1C, 0x16, 0x20, 0x10, 0x2C, 0x25, 
0x80, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x9E, 0x8C, 0x0A, 0xA0, 0x14, 0x51, 0xF0, 0x16, 0x00, 0x26, 
0x7C, 0x43, 0x00, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x98, 0x01, 0x1D, 0x00, 0x72, 0x51, 0xD0, 0x1E, 
0x20, 0x6E, 0x28, 0x55, 0x00, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x1E, 0x01, 0x1D, 0x00, 0xBC, 0x52, 
0xD0, 0x1E, 0x20, 0xB8, 0x28, 0x55, 0x40, 0x5B, 0x56, 0x21, 0x00, 0x00, 0x1E, 0x00, 0x00, 0x00, 
0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50, 
};*/


void EDID_WriteProtect(bool bEnable){
    IOWR(HDMI_SUBSYSTEM_HDMI_RX_EDID_WP_BASE, 0, bEnable?0x00:0x01); // high: write protetion
}

void HDMIRX_EnableEdid(void){
    // set eeprom i2c pin as input pin to FPGA, so source can read EDID.
    I2C_Close(HDMI_SUBSYSTEM_HDMI_RX0_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX0_EP_SDA_BASE);
    I2C_Close(HDMI_SUBSYSTEM_HDMI_RX1_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX1_EP_SDA_BASE);
}

bool HDMIRX_IsVideoOn(void){
    if (VState == VSTATE_VideoOn)
        return TRUE;
    return FALSE;    
}

bool HDMIRX_WriteEeprom(RX_EEPROM_TYPE EepromType){
    bool bSuccess = TRUE;
    int i;
    const alt_u8 *pEdid = szDefaultEDID;
    int nNum = sizeof(szDefaultEDID)/sizeof(szDefaultEDID[0]);
    
        
    if (EepromType == RX0_EEPROM)    
        I2C_Open(HDMI_SUBSYSTEM_HDMI_RX0_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX0_EP_SDA_BASE);
    else        
        I2C_Open(HDMI_SUBSYSTEM_HDMI_RX1_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX1_EP_SDA_BASE);
        
    for(i=0;i<nNum && bSuccess;i++){
        if (EepromType == RX0_EEPROM)
            bSuccess = HDMIRX_EEPROM0_WriteI2C_Byte(i, *(pEdid+i));
        else                
            bSuccess = HDMIRX_EEPROM1_WriteI2C_Byte(i, *(pEdid+i));
    }
    
    if (EepromType == RX0_EEPROM)  
        I2C_Close(HDMI_SUBSYSTEM_HDMI_RX0_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX0_EP_SDA_BASE);
    else        
        I2C_Close(HDMI_SUBSYSTEM_HDMI_RX1_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX1_EP_SDA_BASE);
        
    return bSuccess;
}

bool HDMIRX_VerifyEeprom(RX_EEPROM_TYPE EepromType){
    bool bSuccess = TRUE;
    alt_u8 szEDID[256];
    int i;
    const alt_u8 *pEdid = szDefaultEDID;
    int nNum = sizeof(szDefaultEDID)/sizeof(szDefaultEDID[0]);
    
    if (EepromType == RX0_EEPROM)    
        I2C_Open(HDMI_SUBSYSTEM_HDMI_RX0_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX0_EP_SDA_BASE);
    else        
        I2C_Open(HDMI_SUBSYSTEM_HDMI_RX1_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX1_EP_SDA_BASE);
    
    for(i=0;i<nNum && bSuccess;i++){
        if (EepromType == RX0_EEPROM)
            bSuccess = HDMIRX_EEPROM0_ReadI2C_Byte(i, &szEDID[i]);
        else                
            bSuccess = HDMIRX_EEPROM1_ReadI2C_Byte(i, &szEDID[i]); 
    }
    
    if (EepromType == RX0_EEPROM)  
        I2C_Close(HDMI_SUBSYSTEM_HDMI_RX0_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX0_EP_SDA_BASE);
    else        
        I2C_Close(HDMI_SUBSYSTEM_HDMI_RX1_EP_SCL_BASE, HDMI_SUBSYSTEM_HDMI_RX1_EP_SDA_BASE);
    
    // compare
    if (bSuccess){
        for(i=0;i<nNum && bSuccess;i++){
            if (szEDID[i] != *(pEdid+i))
                bSuccess = FALSE;
        }
    }        
    return bSuccess;
}

void HDMIRX_ShowInfo(void){
    BYTE FreqIndex, ChannelMask, gcp_cd, color_depth=0;
  //  BYTE szAVIInfoFrame[3+AVI_INFOFRAME_LEN];
    int display_width, display_height;
    display_width = getIT6605HorzActive();
    display_height = getIT6605VertActive();
    gcp_cd = getIT6605OutputColorDepth();
    switch(gcp_cd){
            case 4: color_depth = 24; break;
            case 5: color_depth = 30; break;
            case 6: color_depth = 36; break;
            case 7: color_depth = 48; break;
    }

    if (color_depth)
        OS_PRINTF("===== Input Display Res.: %d x %d @%dbps =====\n", display_width, display_height, color_depth);
    else            
        OS_PRINTF("===== Input Display Res.: %d x %d =====\n", display_width, display_height);
    
    if (getIT6605AudioInfo(&FreqIndex, &ChannelMask)){
        int Freq = 0; 
        switch(FreqIndex){
            case 0: Freq = 44100; break;
            case 2: Freq = 48000; break;
            case 3: Freq = 32000; break;
            case 8: Freq = 88300; break;
            case 10: Freq = 96000; break;
            case 12: Freq = 176400; break;
            case 14: Freq = 192000; break;
        }
        OS_PRINTF("===== Input Audio: Rate=%d, Valid-Channel Mask=%02Xh =====\n", Freq, ChannelMask);
    }else{
        OS_PRINTF("===== Audio: unknown =====\n");
    }    
         
    OS_PRINTF("H_Total    = %d\n",getIT6605HorzTotal()) ;
    OS_PRINTF("H_Display  = %d\n",display_width) ;
    OS_PRINTF("H_FPorch   = %d\n",getIT6605HorzFrontPorch()) ;
    OS_PRINTF("H_Sync     = %d\n",getIT6605HorzSyncWidth()) ;
    OS_PRINTF("H_BPorch   = %d\n",getIT6605HorzBackPorch()) ;
    
    OS_PRINTF("V_Total    = %d\n",getIT6605VertTotal()) ;
    OS_PRINTF("V_Display  = %d\n",display_height) ;
    OS_PRINTF("V_FPorch   = %d\n",getIT6605VertFrontPorch()) ;
    OS_PRINTF("V_Sync     = %d\n",getIT6605HorzSyncWidth()) ;
    OS_PRINTF("V_BPorch   = %d\n",getIT6605VertSyncWidth()) ;
    OS_PRINTF("V_SycnToDE = %d\n",getIT6605VertSyncToDE()) ;
    
    //

    alt_u8 VIC, InputColorMode;
    bool b16x9, bITU709;
    if (HDMIRX_GetAVIInfoFrame(&VIC, &InputColorMode, &b16x9, &bITU709)){
        if (VIC == 16)
            OS_PRINTF("VIC: 16 (1920x1080p@60)\n");    
        else if (VIC == 5)
            OS_PRINTF("VIC: 5 (1920x1080i@60)\n");    
        else if (VIC == 4)
            OS_PRINTF("VIC: 4 (1280x720p@60)\n");    
        else if (VIC == 3)
            OS_PRINTF("VIC: 3 (720x480p@60)\n");    
        else
            OS_PRINTF("VIC: %d\n", VIC);
        OS_PRINTF("Aspect Ratio = %s\n", b16x9?"16:9":"4:3"); 
        OS_PRINTF("ITU709 = %s\n", bITU709?"Yes":"No"); 
        OS_PRINTF("Color Space = %s\n", (InputColorMode == F_MODE_RGB444)?"RGB444": 
            ((InputColorMode == F_MODE_YUV444)?"YUV444":"YUV422"));
    }else{
         OS_PRINTF("Failed to get AVIInfoFrame\n"); 
    }


    OS_PRINTF("========\n");      
}

bool HDMIRX_DevLoopProc(void){
    static alt_u32 RxCheckTime = 0;
    static bool bSignal = FALSE;
    static alt_u32 NextSwitchPortTime = 0;
    const alt_u32 PollingDur = alt_ticks_per_second()*3;
    bool bOldSignal, bChangeMode ;
    
    if(ReadRXIntPin()){
        Check_HDMInterrupt() ;
    }
    
    if(alt_nticks() > RxCheckTime)
    {
#if 0   // dump register if button is pressed        
        alt_u8 mask;
        mask = (~IORD(PIO_BUTTON_BASE,0)) & 0x03;  // active low
        if ((mask & 0x02)  == 0x02)
            HDMIRX_DumpReg();
#endif                    
        bOldSignal = bSignal ;
        bSignal = CheckHDMIRX() ;
        bChangeMode = ( bSignal != bOldSignal ) ;
        RxCheckTime = alt_nticks() + 1; //alt_ticks_per_second()/10;
    }    
    
    if (bChangeMode && bSignal){
        HDMIRX_ShowInfo();
    }
    
    // auto swich input port A/B
    if (RxPortConfig == RX_PORT_AUTO){
        if (VState == VSTATE_PwrOff){
            if (alt_nticks() > NextSwitchPortTime){
                if (NextSwitchPortTime > 0){
                    // switch prot
                    RxActivePort = (RxActivePort == RX_PORT_A)?RX_PORT_B:RX_PORT_A;
                    // 1. power down hdmi
                    PowerDownHDMI();
                    // 2. Select HDMI Port
                    SelectHDMIPort((RxActivePort == RX_PORT_A)?CAT_HDMI_PORTA:CAT_HDMI_PORTB);
                    // 3. Call InitIT6605
                    InitIT6605();
                    OS_PRINTF("[RX]Active Port: %s\n", (RxActivePort == RX_PORT_A)?"A":"B");
                }                    
                NextSwitchPortTime = alt_nticks() + PollingDur;
            }                
        }else{
            NextSwitchPortTime = alt_nticks() + PollingDur;
        }
    }
    
    return bChangeMode;
}

bool HDMIRX_Init(RX_PORT_CONFIG PortConfig){
    bool bSuccess = TRUE, bE2Success = TRUE, bWriteSuccess;
    int i;
    
    // check EEPROM
    EDID_WriteProtect(TRUE);
    HDMIRX_Reset(); // reset before write eeprom
    for(i=0;i<2;i++){
        RX_EEPROM_TYPE Type = (RX_EEPROM_TYPE)i;
        if (!HDMIRX_VerifyEeprom(Type)){
            EDID_WriteProtect(FALSE);
            bWriteSuccess = HDMIRX_WriteEeprom(Type);
            EDID_WriteProtect(TRUE);
            if (!bWriteSuccess){
                OS_PRINTF("write eeporm-%d fail\n", i);
                bE2Success = FALSE;
            }else{
                if (!HDMIRX_VerifyEeprom(Type)){
                    OS_PRINTF("verify write eeporm-%d fail\n", i);
                    bE2Success = FALSE;
                }else{
                    OS_PRINTF("write eeporm-%d success\n", i);
                }    
            }
        }
    }
    
    HDMIRX_EnableEdid();  // set fpga's i2c clk/data as input, so other master can access edid    
    
    if (!bE2Success)
        return FALSE;
         
    HDMIRX_Reset();
    usleep(500*1000);
    if (!HDMIRX_ChipVerify()){
        OS_PRINTF("Failed to find IT6613 HDMI-RX Chip.\n");
        bSuccess = FALSE;
    }else{     
        BYTE ucPort;
        RxPortConfig = PortConfig;
        switch(PortConfig){
            case RX_PORT_B:
                ucPort = CAT_HDMI_PORTB;
                RxActivePort = RX_PORT_B;
                break;
            case RX_PORT_A:
            case RX_PORT_AUTO:
            default:
                ucPort = CAT_HDMI_PORTA;
                RxActivePort = RX_PORT_A;
                break;
        }
        SelectHDMIPort(ucPort);
        InitIT6605();
        OS_PRINTF("[RX]Active Port: %s\n", (RxActivePort == RX_PORT_A)?"A":"B");
    }        
    
    return bSuccess;
}



bool HDMIRX_ChipVerify(void){
    bool bPass = FALSE;
    alt_u8 szID[5];
    int i;
    
    
    for(i=0;i<5;i++)
        szID[i] = HDMIRX_ReadI2C_Byte(i);
        
//    if (szID[0] == 0x00 && szID[1] == 0xCA && szID[1] == 0x13 && szID[1] == 0x06) szID[0] ???
    if (szID[2] == 0x23 && szID[3] == 0x60){
        bPass = TRUE;
        OS_PRINTF("RX Chip Revision ID: %02Xh\n", szID[4]);     
    }else{
        OS_PRINTF("NG, Read RX Chip ID:%02X%02Xh (expected:6023h)\n", szID[3], szID[2]);     
    }
                    
    return bPass;
}

           
bool HDMIRX_GetAVIInfoFrame(alt_u8 *pVIC, alt_u8 *pColorMode, bool *pb16x9, bool *pITU709)
{
    alt_u8 szBuf[AVI_INFOFRAME_LEN + 3];
    alt_u8 *szInfo = szBuf + 3;
    
    if (GetAVIInfoFrame(szBuf) != ER_SUCCESS)
        return FALSE;

    *pVIC = szInfo[3] & 0x7F;       
    *pb16x9 = (szInfo[1] & (2<<4))?TRUE:FALSE;
    *pITU709 = (szInfo[1] & (2<<6))?TRUE:FALSE;

    if ((szInfo[0] & ((3<<5)|(1<<4))) == ((2<<5)|(1<<4)))    
        *pColorMode = F_MODE_YUV444;
    else if ((szInfo[0] & ((3<<5)|(1<<4))) == ((1<<5)|(1<<4)))    
        *pColorMode = F_MODE_YUV422;
    else        
        *pColorMode = F_MODE_RGB444;
    
    return TRUE;
}

bool HDMIRX_IsModeChange(void){
    return bModeChanged;
}

bool HDMIRX_GetSourceColor(int *pnColorMode){
    bool bSuccess = FALSE;
    alt_u8 VIC, InputColorMode;
    bool b16x9, bITU709;
    if (HDMIRX_GetAVIInfoFrame(&VIC, &InputColorMode, &b16x9, &bITU709)){
        bSuccess = TRUE;
        if (InputColorMode == F_MODE_RGB444)
            *pnColorMode = COLOR_RGB444;
        else if (InputColorMode == F_MODE_YUV444)
            *pnColorMode = COLOR_YUV444;
        else
            *pnColorMode = COLOR_YUV422;
    }
    return bSuccess;                    
}


void HDMIRX_SetOutputColor(COLOR_TYPE OutputColor){
    alt_u8 uc;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_PG_CTRL2) & ~(M_OUTPUT_COLOR_MASK<<O_OUTPUT_COLOR_MODE);
    switch(OutputColor)
    {
    case COLOR_YUV444:
        uc |= B_OUTPUT_YUV444 << O_OUTPUT_COLOR_MODE ;
        break ;
    case COLOR_YUV422:
        uc |= B_OUTPUT_YUV422 << O_OUTPUT_COLOR_MODE ;
        break ;
    }
    
    HDMIRX_WriteI2C_Byte(REG_RX_PG_CTRL2, uc) ;
    
}
