/*********************************************************************************
 * IT6605 HDMI RX sample code                                                   *
 *********************************************************************************/
#include "it6605.h"
#ifndef DEBUG_PORT_ENABLE
#define DEBUG_PORT_ENABLE 0
#else
#pragma message("DEBUG_PORT_ENABLE defined\n") 
#endif


static BOOL Is_A2   = TRUE;
static BOOL AcceptCDRReset = TRUE;  // use for A2 verion only
void CDR_Reset();


///////////////////////////////////////////////////////////
// Definition.
///////////////////////////////////////////////////////////
// #define SetVideoMUTE(x) SetMUTE(~(B_TRI_VIDEOIO|B_TRI_VIDEO),(x)?(B_TRI_VIDEOIO|B_TRI_VIDEO):0)
#define SetSPDIFMUTE(x) SetMUTE(~(1<<O_TRI_SPDIF),(x)?(1<<O_TRI_SPDIF):0)
#define SetI2S3MUTE(x) SetMUTE(~(1<<O_TRI_I2S3),  (x)?(1<<O_TRI_I2S3):0)
#define SetI2S2MUTE(x) SetMUTE(~(1<<O_TRI_I2S2),  (x)?(1<<O_TRI_I2S2):0)
#define SetI2S1MUTE(x) SetMUTE(~(1<<O_TRI_I2S1),  (x)?(1<<O_TRI_I2S1):0)
#define SetI2S0MUTE(x) SetMUTE(~(1<<O_TRI_I2S0),  (x)?(1<<O_TRI_I2S0):0)
#define SetAVMUTE() SetMUTE(B_VDO_MUTE_DISABLE,(B_VDO_MUTE_DISABLE|B_TRI_ALL))

#define SwitchHDMIRXBank(x) HDMIRX_WriteI2C_Byte(REG_RX_BANK, (x)&1) 

// richard #ifndef _MCU_
char * VStateStr[] = {
    "VSTATE_PwrOff",
    "VSTATE_SyncWait ",
    "VSTATE_SWReset", 
    "VSTATE_SyncChecking",
    "VSTATE_HDCPSet",
    "VSTATE_HDCP_Reset",
    "VSTATE_ModeDetecting",
    "VSTATE_VideoOn",
    "VSTATE_Reserved"
} ;


char *AStateStr[] = {
    "ASTATE_AudioOff",
    "ASTATE_RequestAudio",
    "ASTATE_ResetAudio",
    "ASTATE_WaitForReady",
    "ASTATE_AudioOn",
    "ASTATE_Reserved"
};
// richard #endif

typedef struct {
    WORD HActive ;
    WORD VActive ;
    WORD HTotal ;
    WORD VTotal ;
    LONG PCLK ;
    BYTE xCnt ;
    WORD HFrontPorch ;
    WORD HSyncWidth ;
    WORD HBackPorch ;
    BYTE VFrontPorch ;
    BYTE VSyncWidth ;
    BYTE VBackPorch ;
    BYTE ScanMode:1 ;
    BYTE VPolarity:1 ;
    BYTE HPolarity:1 ;
} VTiming ;

#define PROG 1 
#define INTERLACE 0
#define Vneg 0
#define Hneg 0
#define Vpos 1
#define Hpos 1

///////////////////////////////////////////////////////////
// Public Data
///////////////////////////////////////////////////////////
_IDATA Video_State_Type VState = VSTATE_PwrOff ;
_IDATA Audio_State_Type AState = ASTATE_AudioOff ;

///////////////////////////////////////////////////////////
// Global Data
///////////////////////////////////////////////////////////
static _IDATA USHORT VideoCountingTimer = 0 ;
static _IDATA USHORT AudioCountingTimer = 0 ;
static _IDATA USHORT MuteResumingTimer = 0 ;
static BOOL MuteAutoOff = FALSE ;
static _IDATA BYTE bGetSyncFailCount = 0 ;
static BYTE _IDATA bOutputVideoMode = F_MODE_EN_UDFILT | F_MODE_RGB24 ;

BYTE _XDATA bDisableAutoAVMute = 0 ; 

BYTE _XDATA bHDCPMode = 0 ;
#define HDCP_RECEIVER   0
#define HDCP_REPEATER   1
#define HDCP_RDY_TIMEOUT    (1<<1)
#define HDCP_INVALID_V      (1<<2)
#define HDCP_OVER_DOWNSTREAM    (1<<3)
#define HDCP_OVER_CASCADE   (1<<4)


#define MS_TimeOut(x) (((x)+7)/8)


#define VSTATE_MISS_SYNC_COUNT MS_TimeOut(15000) // 2000ms, 2sec (richard ???)
#define VSATE_CONFIRM_SCDT_COUNT MS_TimeOut(150)  // 150ms
#define AUDIO_READY_TIMEOUT MS_TimeOut(200)
#define MUTE_RESUMING_TIMEOUT MS_TimeOut(2500) // 2.5 sec
#define HDCP_WAITING_TIMEOUT MS_TimeOut(3000) // 3 sec
#define VSTATE_SWRESET_COUNT MS_TimeOut(500) // 500ms
#define FORCE_SWRESET_TIMEOUT  MS_TimeOut(45000) // 5000ms, 5sec (richard ????)
#define VIDEO_TIMER_CHECK_COUNT MS_TimeOut(250)

static _XDATA USHORT SWResetTimeOut = FORCE_SWRESET_TIMEOUT;

static _XDATA BYTE ucHDMIAudioErrorCount = 0 ;
static _XDATA BYTE ucAudioSampleClock = 0x03 ; // 32KHz, to changed 48KHz

BOOL bIntPOL = FALSE ; 
static BOOL NewAVIInfoFrameF = FALSE ;
static BOOL MuteByPKG = OFF ;
static _XDATA BYTE bInputVideoMode ;

// 2006/12/04 added by jj_tseng@chipadvanced.com
static _XDATA BYTE prevAVIDB1 = 0 ;
static _XDATA BYTE prevAVIDB2 = 0 ;
//~jjtseng 2006/12/04

static _XDATA USHORT currHTotal ;
static _XDATA BYTE currXcnt ;
static BOOL currScanMode ;
static BOOL bGetSyncInfo() ;
// BYTE iVTimingIndex = 0xFF ;



static _XDATA VTiming *pVTiming ;
static _XDATA VTiming s_CurrentVM ;

static _XDATA BYTE Vr[20] ;
static _XDATA BYTE M0[8] ;

static _XDATA BYTE KSVList[]=
{
    0x35,0x79,0x6A,0x17,0x2E,//Bksv0
    0x47,0x8E,0x71,0xE2,0x0F,//Bksv1
    0x74,0xE8,0x53,0x97,0xA6,//Bksv2
};

///////////////////////////////////////////////////////////////////////
// Global Table
///////////////////////////////////////////////////////////////////////

static VTiming _CODE s_VMTable[] = {
    {640,480,800,525,25175L,0x89,16,96,48,10,2,33,PROG,Vneg,Hneg},    //640x480@60Hz
    {720,480,858,525,27000L,0x80,16,62,60,9,6,30,PROG,Vneg,Hneg},    //720x480@60Hz
    {1280,720,1650,750,74000L,0x2E,110,40,220,5,5,20,PROG,Vpos,Hpos},    //1280x720@60Hz
    {1920,540,2200,562,74000L,0x2E,88,44,148,2,5,15,INTERLACE,Vpos,Hpos},    //1920x1080(I)@60Hz
    {720,240,858,262,13500L,0xFF,19,62,57,4,3,15,INTERLACE,Vneg,Hneg},    //720x480(I)@60Hz
    {720,240,858,262,13500L,0xFF,19,62,57,4,3,15,PROG,Vneg,Hneg},    //720x480(I)@60Hz
    {1440,240,1716,262,27000L,0x80,38,124,114,5,3,15,INTERLACE,Vneg,Hneg},    //1440x480(I)@60Hz
    {1440,240,1716,263,27000L,0x80,38,124,114,5,3,15,PROG,Vneg,Hneg},    //1440x240@60Hz
    {2880,240,3432,262,54000L,0x40,76,248,288,4,3,15,INTERLACE,Vneg,Hneg},    //2880x480(I)@60Hz
    {2880,240,3432,262,54000L,0x40,76,248,288,4,3,15,PROG,Vneg,Hneg},    //2880x240@60Hz
    {2880,240,3432,263,54000L,0x40,76,248,288,5,3,15,PROG,Vneg,Hneg},    //2880x240@60Hz
    {1440,480,1716,525,54000L,0x40,32,124,120,9,6,30,PROG,Vneg,Hneg},    //1440x480@60Hz
    {1920,1080,2200,1125,148352L,0x17,88,44,148,4,5,36,PROG,Vpos,Hpos},    //1920x1080@60Hz
    {720,576,864,625,27000L,0x80,12,64,68,5,5,36,PROG,Vneg,Hneg},    //720x576@50Hz
    {1280,720,1980,750,74000L,0x2E,440,40,220,5,5,20,PROG,Vpos,Hpos},    //1280x720@50Hz
    {1920,540,2640,562,74000L,0x2E,528,44,148,2,5,15,INTERLACE,Vpos,Hpos},    //1920x1080(I)@50Hz
    {1440/2,288,1728/2,312,13500L,0xFF,24/2,126/2,138/2,2,3,19,INTERLACE,Vneg,Hneg},    //1440x576(I)@50Hz
    {1440,288,1728,312,27000L,0x80,24,126,138,2,3,19,INTERLACE,Vneg,Hneg},    //1440x576(I)@50Hz
    {1440/2,288,1728/2,312,13500L,0xFF,24/2,126/2,138/2,2,3,19,PROG,Vneg,Hneg},    //1440x288@50Hz
    {1440,288,1728,313,27000L,0x80,24,126,138,3,3,19,PROG,Vneg,Hneg},    //1440x288@50Hz
    {1440,288,1728,314,27000L,0x80,24,126,138,4,3,19,PROG,Vneg,Hneg},    //1440x288@50Hz
    {2880,288,3456,312,54000L,0x40,48,252,276,2,3,19,INTERLACE,Vneg,Hneg},    //2880x576(I)@50Hz
    {2880,288,3456,312,54000L,0x40,48,252,276,2,3,19,PROG,Vneg,Hneg},    //2880x288@50Hz
    {2880,288,3456,313,54000L,0x40,48,252,276,3,3,19,PROG,Vneg,Hneg},    //2880x288@50Hz
    {2880,288,3456,314,54000L,0x40,48,252,276,4,3,19,PROG,Vneg,Hneg},    //2880x288@50Hz
    {1440,576,1728,625,54000L,0x40,24,128,136,5,5,39,PROG,Vpos,Hneg},    //1440x576@50Hz
    {1920,1080,2640,1125,148000L,0x17,528,44,148,4,5,36,PROG,Vpos,Hpos},    //1920x1080@50Hz
    {1920,1080,2750,1125,74000L,0x2E,638,44,148,4,5,36,PROG,Vpos,Hpos},    //1920x1080@24Hz
    {1920,1080,2640,1125,74000L,0x2E,528,44,148,4,5,36,PROG,Vpos,Hpos},    //1920x1080@25Hz
    {1920,1080,2200,1125,74000L,0x2E,88,44,148,4,5,36,PROG,Vpos,Hpos},    //1920x1080@30Hz
    // VESA mode
    {640,350,832,445,31500L,0x6D,32,64,96,32,3,60,PROG,Vneg,Hpos},         // 640x350@85
    {640,400,832,445,31500L,0x6D,32,64,96,1,3,41,PROG,Vneg,Hneg},          // 640x400@85
    {832,624,1152,667,57283L,0x3C,32,64,224,1,3,39,PROG,Vneg,Hneg},        // 832x624@75Hz
    {720,350,900,449,28322L,0x7A,18,108,54,59,2,38,PROG,Vneg,Hneg},        // 720x350@70Hz
    {720,400,900,449,28322L,0x7A,18,108,54,13,2,34,PROG,Vpos,Hneg},        // 720x400@70Hz
    {720,400,936,446,35500L,0x61,36,72,108,1,3,42,PROG,Vpos,Hneg},         // 720x400@85
    {640,480,800,525,25175L,0x89,16,96,48,10,2,33,PROG,Vneg,Hneg},         // 640x480@60
    {640,480,832,520,31500L,0x6D,24,40,128,9,3,28,PROG,Vneg,Hneg},         // 640x480@72
    {640,480,840,500,31500L,0x6D,16,64,120,1,3,16,PROG,Vneg,Hneg},         // 640x480@75
    {640,480,832,509,36000L,0x60,56,56,80,1,3,25,PROG,Vneg,Hneg},          // 640x480@85
    {800,600,1024,625,36000L,0x60,24,72,128,1,2,22,PROG,Vpos,Hpos},        // 800x600@56
    {800,600,1056,628,40000L,0x56,40,128,88,1,4,23,PROG,Vpos,Hpos},        // 800x600@60
    {800,600,1040,666,50000L,0x45,56,120,64,37,6,23,PROG,Vpos,Hpos},       // 800x600@72
    {800,600,1056,625,49500L,0x45,16,80,160,1,3,21,PROG,Vpos,Hpos},        // 800x600@75
    {800,600,1048,631,56250L,0x3D,32,64,152,1,3,27,PROG,Vpos,Hpos},        // 800X600@85
    {848,480,1088,517,33750L,0x66,16,112,112,6,8,23,PROG,Vpos,Hpos},       // 840X480@60
    {1024,384,1264,408,44900L,0x4d,8,176,56,0,4,20,INTERLACE,Vpos,Hpos},    //1024x768(I)@87Hz
    {1024,768,1344,806,65000L,0x35,24,136,160,3,6,29,PROG,Vneg,Hneg},      // 1024x768@60
    {1024,768,1328,806,75000L,0x2E,24,136,144,3,6,29,PROG,Vneg,Hneg},      // 1024x768@70
    {1024,768,1312,800,78750L,0x2B,16,96,176,1,3,28,PROG,Vpos,Hpos},       // 1024x768@75
    {1024,768,1376,808,94500L,0x24,48,96,208,1,3,36,PROG,Vpos,Hpos},       // 1024x768@85
    {1152,864,1600,900,108000L,0x20,64,128,256,1,3,32,PROG,Vpos,Hpos},     // 1152x864@75
    {1280,768,1440,790,68250L,0x32,48,32,80,3,7,12,PROG,Vneg,Hpos},        // 1280x768@60-R
    {1280,768,1664,798,79500L,0x2B,64,128,192,3,7,20,PROG,Vpos,Hneg},      // 1280x768@60
    {1280,768,1696,805,102250L,0x21,80,128,208,3,7,27,PROG,Vpos,Hneg},     // 1280x768@75
    {1280,768,1712,809,117500L,0x1D,80,136,216,3,7,31,PROG,Vpos,Hneg},     // 1280x768@85
    {1280,960,1800,1000,108000L,0x20,96,112,312,1,3,36,PROG,Vpos,Hpos},    // 1280x960@60
    {1280,960,1728,1011,148500L,0x17,64,160,224,1,3,47,PROG,Vpos,Hpos},    // 1280x960@85
    {1280,1024,1688,1066,108000L,0x20,48,112,248,1,3,38,PROG,Vpos,Hpos},   // 1280x1024@60
    {1280,1024,1688,1066,135000L,0x19,16,144,248,1,3,38,PROG,Vpos,Hpos},   // 1280x1024@75
    {1280,1024,1728,1072,157500L,0x15,64,160,224,1,3,44,PROG,Vpos,Hpos},   // 1280X1024@85
    {1360,768,1792,795,85500L,0x28,64,112,256,3,6,18,PROG,Vpos,Hpos},      // 1360X768@60
    {1400,1050,1560,1080,101000L,0x22,48,32,80,3,4,23,PROG,Vneg,Hpos},     // 1400x768@60-R
    {1400,1050,1864,1089,121750L,0x1C,88,144,232,3,4,32,PROG,Vpos,Hneg},   // 1400x768@60
    {1400,1050,1896,1099,156000L,0x16,104,144,248,3,4,42,PROG,Vpos,Hneg},  // 1400x1050@75
    {1400,1050,1912,1105,179500L,0x13,104,152,256,3,4,48,PROG,Vpos,Hneg},  // 1400x1050@85
    {1440,900,1600,926,88750L,0x26,48,32,80,3,6,17,PROG,Vneg,Hpos},        // 1440x900@60-R
    {1440,900,1904,934,106500L,0x20,80,152,232,3,6,25,PROG,Vpos,Hneg},     // 1440x900@60
    {1440,900,1936,942,136750L,0x19,96,152,248,3,6,33,PROG,Vpos,Hneg},     // 1440x900@75
    {1440,900,1952,948,157000L,0x16,104,152,256,3,6,39,PROG,Vpos,Hneg},    // 1440x900@85
    {1600,1200,2160,1250,162000L,0x15,64,192,304,1,3,46,PROG,Vpos,Hpos},   // 1600x1200@60
    {1600,1200,2160,1250,175500L,0x13,64,192,304,1,3,46,PROG,Vpos,Hpos},   // 1600x1200@65
    {1600,1200,2160,1250,189000L,0x12,64,192,304,1,3,46,PROG,Vpos,Hpos},   // 1600x1200@70
    {1600,1200,2160,1250,202500L,0x11,64,192,304,1,3,46,PROG,Vpos,Hpos},   // 1600x1200@75
    {1600,1200,2160,1250,229500L,0x0F,64,192,304,1,3,46,PROG,Vpos,Hpos},   // 1600x1200@85
    {1680,1050,1840,1080,119000L,0x1D,48,32,80,3,6,21,PROG,Vneg,Hpos},     // 1680x1050@60-R
    {1680,1050,2240,1089,146250L,0x17,104,176,280,3,6,30,PROG,Vpos,Hneg},  // 1680x1050@60 
    {1680,1050,2272,1099,187000L,0x12,120,176,296,3,6,40,PROG,Vpos,Hneg},  // 1680x1050@75
    {1680,1050,2288,1105,214750L,0x10,128,176,304,3,6,46,PROG,Vpos,Hneg},  // 1680x1050@85
    {1792,1344,2448,1394,204750L,0x10,128,200,328,1,3,46,PROG,Vpos,Hneg},  // 1792x1344@60
    {1792,1344,2456,1417,261000L,0x0D,96,216,352,1,3,69,PROG,Vpos,Hneg},   // 1792x1344@75
    {1856,1392,2528,1439,218250L,0x0F,96,224,352,1,3,43,PROG,Vpos,Hneg},   // 1856x1392@60
    {1856,1392,2560,1500,288000L,0x0C,128,224,352,1,3,104,PROG,Vpos,Hneg}, // 1856x1392@75
    {1920,1200,2080,1235,154000L,0x16,48,32,80,3,6,26,PROG,Vneg,Hpos},     // 1920x1200@60-R
    {1920,1200,2592,1245,193250L,0x11,136,200,336,3,6,36,PROG,Vpos,Hneg},  // 1920x1200@60
    {1920,1200,2608,1255,245250L,0x0E,136,208,344,3,6,46,PROG,Vpos,Hneg},  // 1920x1200@75
    {1920,1200,2624,1262,281250L,0x0C,144,208,352,3,6,53,PROG,Vpos,Hneg},  // 1920x1200@85
    {1920,1440,2600,1500,234000L,0x0E,128,208,344,1,3,56,PROG,Vpos,Hneg},  // 1920x1440@60
    {1920,1440,2640,1500,297000L,0x0B,144,224,352,1,3,56,PROG,Vpos,Hneg},  // 1920x1440@75
};

#define     SizeofVMTable    (sizeof(s_VMTable)/sizeof(VTiming))    

// Y,C,RGB offset
static BYTE _CODE bCSCOffset_16_235[] =
{
    0x00, 0x80, 0x00
};

static BYTE _CODE bCSCOffset_0_255[] =
{
    0x10, 0x80, 0x10
};

#ifdef OUTPUT_YUV
    static BYTE _CODE bCSCMtx_RGB2YUV_ITU601_16_235[] =
    {
        0xB2,0x04,0x64,0x02,0xE9,0x00,
        0x93,0x3C,0x16,0x04,0x56,0x3F,
        0x49,0x3D,0x9F,0x3E,0x16,0x04
    } ;

    static BYTE _CODE bCSCMtx_RGB2YUV_ITU601_0_255[] =
    {
        0x09,0x04,0x0E,0x02,0xC8,0x00,
        0x0E,0x3D,0x83,0x03,0x6E,0x3F,
        0xAC,0x3D,0xD0,0x3E,0x83,0x03
    } ;
    
    static BYTE _CODE bCSCMtx_RGB2YUV_ITU709_16_235[] =
    {
        0xB8,0x05,0xB4,0x01,0x93,0x00,
        0x49,0x3C,0x16,0x04,0x9F,0x3F,
        0xD9,0x3C,0x10,0x3F,0x16,0x04
    } ;
    
    static BYTE _CODE bCSCMtx_RGB2YUV_ITU709_0_255[] =
    {
        0xE5,0x04,0x78,0x01,0x81,0x00,
        0xCE,0x3C,0x83,0x03,0xAE,0x3F,
        0x49,0x3D,0x33,0x3F,0x83,0x03
    } ;
#endif

#ifdef OUTPUT_RGB

    static BYTE _CODE bCSCMtx_YUV2RGB_ITU601_16_235[] =
    {
        0x00,0x08,0x6A,0x3A,0x4F,0x3D,
        0x00,0x08,0xF7,0x0A,0x00,0x00,
        0x00,0x08,0x00,0x00,0xDB,0x0D
    } ;

    static BYTE _CODE bCSCMtx_YUV2RGB_ITU601_0_255[] =
    {
        0x4F,0x09,0x81,0x39,0xDF,0x3C,
        0x4F,0x09,0xC2,0x0C,0x00,0x00,
        0x4F,0x09,0x00,0x00,0x1E,0x10
    } ;

    static BYTE _CODE bCSCMtx_YUV2RGB_ITU709_16_235[] =
    {
        0x00,0x08,0x53,0x3C,0x89,0x3E,
        0x00,0x08,0x51,0x0C,0x00,0x00,
        0x00,0x08,0x00,0x00,0x87,0x0E
    } ;

    static BYTE _CODE bCSCMtx_YUV2RGB_ITU709_0_255[] =
    {
        0x4F,0x09,0xBA,0x3B,0x4B,0x3E,
        0x4F,0x09,0x56,0x0E,0x00,0x00,
        0x4F,0x09,0x00,0x00,0xE7,0x10
    } ;
#endif

static BYTE ucCurrentHDMIPort = 1;   // richard note. change input port a/b here


///////////////////////////////////////////////////////////
// Function Prototype
///////////////////////////////////////////////////////////
BOOL CheckHDMIRX() ;

void DumpHDMIRX() ;
// void DumpSync(PSYNC_INFO pSyncInfo) ;
// void GetSyncInfo(PSYNC_INFO pSyncInfo) ;
// static BOOL CheckOutOfRange(PSYNC_INFO pSyncInfo) ;
// BOOL ValidateMode(PSYNC_INFO pSyncInfo) ;
void Interrupt_Handler() ;
void Timer_Handler() ;
void Video_Handler() ;

static void HWReset_HDMIRX() ;
static void SWReset_HDMIRX() ;
static void Terminator_Reset() ;
static void Terminator_Off() ;
static void Terminator_On() ;

void Check_RDROM() ;
void RDROM_Reset() ;
void SetDefaultRegisterValue() ;
// static void LoadDefaultSyncPolarity() ;
// static void LoadDefaultHWMuteControl() ;
// static void LoadDefaultHWAmpControl() ;
// static void LoadDefaultAudioOutputMap() ;
// static void LoadDefaultVideoOutput() ;
// static void LoadDefaultInterruptType() ;
// static void LoadDefaultAudioSampleClock() ;
// static void LoadDefaultROMSetting() ;
static void LoadCustomizeDefaultSetting() ;

BOOL ReadRXIntPin() ;
// USHORT GetVFreq() ;
static void ClearIntFlags(BYTE flag) ;
static void ClearHDCPIntFlags() ;
static BOOL IsSCDT() ;
BOOL CheckPlg5VPwr() ;
// BOOL CheckPlg5VPwrOn() ;
// BOOL CheckPlg5VPwrOff() ;
BOOL CheckHDCPFail() ;
void SetMUTE(BYTE AndMask, BYTE OrMask) ;
void SetMCLKInOUt(BYTE MCLKSelect) ;
void SetIntMask1(BYTE AndMask,BYTE OrMask) ;
void SetIntMask2(BYTE AndMask,BYTE OrMask) ;
void SetIntMask3(BYTE AndMask,BYTE OrMask) ;
void SetIntMask4(BYTE AndMask,BYTE OrMask) ;
void SetGeneralPktType(BYTE type) ;
BOOL IsIT6605HDMIMode() ;
///////////////////////////////////////////////////////////
// Audio Macro
///////////////////////////////////////////////////////////

#define SetForceHWMute() { SetHWMuteCTRL((~B_HW_FORCE_MUTE),(B_HW_FORCE_MUTE)) ; }
#define SetHWMuteClrMode() { SetHWMuteCTRL((~B_HW_AUDMUTE_CLR_MODE),(B_HW_AUDMUTE_CLR_MODE)) ;}
#define SetHWMuteClr() { SetHWMuteCTRL((~B_HW_MUTE_CLR),(B_HW_MUTE_CLR)) ; }
#define SetHWMuteEnable() { SetHWMuteCTRL((~B_HW_MUTE_EN),(B_HW_MUTE_EN)) ; }
#define ClearForceHWMute() { SetHWMuteCTRL((~B_HW_FORCE_MUTE),0) ; }
#define ClearHWMuteClrMode() { SetHWMuteCTRL((~B_HW_AUDMUTE_CLR_MODE),0) ; }
#define ClearHWMuteClr() { SetHWMuteCTRL((~B_HW_MUTE_CLR),0) ; }
#define ClearHWMuteEnable() { SetHWMuteCTRL((~B_HW_MUTE_EN),0) ;}
///////////////////////////////////////////////////////////
// Function Prototype
///////////////////////////////////////////////////////////
void RXINT_5V_PwrOn() ;
void RXINT_5V_PwrOff() ;
void RXINT_SCDT_On() ;
void RXINT_SCDT_Off() ;
void RXINT_VideoMode_Chg() ;
void RXINT_HDMIMode_Chg() ;
void RXINT_AVMute_Set() ;
void RXINT_AVMute_Clear() ;
void RXINT_SetNewAVIInfo() ;
void RXINT_ResetAudio() ;
void RXINT_ResetHDCP() ;
void TimerServiceISR() ;
static void VideoTimerHandler() ;
static void AudioTimerHandler() ;
static void MuteProcessTimerHandler() ;

void AssignVideoTimerTimeout(USHORT TimeOut) ;
void ResetVideoTimerTimeout() ;
void SwitchVideoState(Video_State_Type state) ;

void AssignAudioTimerTimeout(USHORT TimeOut) ;
void ResetAudioTimerTimeout() ;
void SwitchAudioState(Audio_State_Type state) ;
#define EnableMuteProcessTimer() { MuteResumingTimer = MuteByPKG?MUTE_RESUMING_TIMEOUT:0 ; }
#define DisableMuteProcessTimer() { MuteResumingTimer = 0 ; }

static void DumpSyncInfo(VTiming *pVTiming) ;
#define StartAutoMuteOffTimer() { MuteAutoOff = ON ; }
#define EndAutoMuteOffTimer() { MuteAutoOff = OFF ; }


static void SetVideoInputFormatWithoutInfoFrame(BYTE bInMode) ;
static void SetColorimetryByMode(/* PSYNC_INFO pSyncInfo */) ;
void SetVideoInputFormatWithInfoFrame() ;
BOOL SetColorimetryByInfoFrame() ;
void SetColorSpaceConvert() ;
// BOOL CompareSyncInfo(PSYNC_INFO pSyncInfo1,PSYNC_INFO pSyncInfo2) ;
void HDCP_Reset() ;
void SetDVIVideoOutput() ;
void SetNewInfoVideoOutput() ;
void ResetAudio() ;
void SetHWMuteCTRL(BYTE AndMask, BYTE OrMask) ;
void SetAudioMute(BOOL bMute) ;
static void SetVideoMUTE(BOOL bMute) ;
// void DelayUS(ULONG us) ;
//richard void DelayMS(USHORT ms) ;
//richard void ErrorF(char *fmt,...) ;

#if 1
static void ErrorF(char *fmt,...);
void ErrorF(char *fmt,...){
}
#endif

///////////////////////////////////////////////////////////
// Connection Interface
///////////////////////////////////////////////////////////
void
Check_HDMInterrupt()
{
    Interrupt_Handler() ;
}


BOOL
CheckHDMIRX()
{
    
    // richard add
    static Video_State_Type PreVState = -1;
    static Audio_State_Type PreAState = -1;
    static OS_TICK ScdtStableTimeout = 0;
    static OS_TICK SyncTimeout = 0;
    //
    Timer_Handler() ;
    Video_Handler() ;
    
    //===== richard add
    // SCDT stable detection
#if 1    
    if (VState == VSTATE_SyncChecking){
        if (PreVState != VState)
            ScdtStableTimeout = OS_GetTicks() + VSATE_CONFIRM_SCDT_COUNT*OS_TicksPerSecond()/1000;
        else if (OS_GetTicks() > ScdtStableTimeout)     
            SwitchVideoState(VSTATE_ModeDetecting) ;      
    }
    
    if (VState == VSTATE_SyncWait){
        if (PreVState != VState)
            SyncTimeout = OS_GetTicks() + VSTATE_MISS_SYNC_COUNT*OS_TicksPerSecond()/1000;
        else if (OS_GetTicks() > SyncTimeout)     
            SWReset_HDMIRX();      
    }
    
#endif         
    
    if (PreVState != VState){
        OS_PRINTF("[RX] VState = %d, %s\n", VState, VStateStr[VState]);
        PreVState = VState;
    }   
    if (PreAState != AState){
        OS_PRINTF("[RX] AState = %d, %s\n", AState, AStateStr[AState]);
        PreAState =AState;
    }            
  
    //===== richard end
    
    if( VState == VSTATE_VideoOn && (!MuteByPKG))
    {
        return TRUE ;
    }
    
    return FALSE ;
}

void
SelectHDMIPort(BYTE ucPort)
{

    if(ucPort != CAT_HDMI_PORTA)
    {
        ucPort = CAT_HDMI_PORTB ;
    }
    
    if( ucPort != ucCurrentHDMIPort )
    {
        ucCurrentHDMIPort = ucPort ;
    }

    ErrorF("SelectHDMIPort ucPort = %d, ucCurrentHDMIPort = %d\n",ucPort, ucCurrentHDMIPort) ;
    // switch HDMI port should 
    // 1. power down HDMI
    // 2. Select HDMI Port
    // 3. call InitCAT6011() ;
}

BYTE 
GetCurrentHDMIPort()
{
    return ucCurrentHDMIPort ;
}
static _XDATA BYTE SHABuff[64] ;
static SYS_STATUS
HDCP_GenVR(/*BYTE cInstance,*/ BYTE pM0[], USHORT BStatus, BYTE pKSVList[], int cDownStream/*, BYTE Vr[]*/)
{
    extern void SHA_Simple(void *p, LONG len, BYTE *output);

    int i, n ;
    
    for( i = 0 ; i < cDownStream*5 ; i++ )
    {
        SHABuff[i] = pKSVList[i] ;
    }
    SHABuff[i++] = BStatus & 0xFF ;
    SHABuff[i++] = (BStatus>>8) & 0xFF ;
    for( n = 0 ; n < 8 ; n++, i++ )
    {
        SHABuff[i] = pM0[n] ;
    }
    n = i ;
    // SHABuff[i++] = 0x80 ; // end mask
    for( ; i < 64 ; i++ )
    {
        SHABuff[i] = 0 ;
    }
    // n = cDownStream * 5 + 2 /* for BStatus */ + 8 /* for M0 */ ;
    // n *= 8 ;
    // SHABuff[62] = (n>>8) & 0xff ;
    // SHABuff[63] = (n>>8) & 0xff ;
    /*
    for( i = 0 ; i < 64 ; i++ )
    {
        if( i % 16 == 0 ) printf("SHA[]: ") ;
        printf(" %02X",SHABuff[i]) ;
        if( (i%16)==15) printf("\n") ;
    }
    */
    SHA_Simple(SHABuff, (LONG)n, Vr) ;
    ErrorF("n=%2X\n",n);
    /*
    printf("V[] =") ;
    for( i = 0 ; i < 20 ; i++ )
    {
        printf(" %02X",V[i]) ;
    }
    printf("\nVr[] =") ;
    for( i = 0 ; i < 20 ; i++ )
    {
        printf(" %02X",Vr[i]) ;
    }
        
    for( i = 0 ; i < 20 ; i++ )
    {
        if( V[i] != Vr[i] )
        {
            return ER_FAIL ;
        }
    }
    */
    return ER_SUCCESS ;
}



void RxHDCPSetReceiver()
{
    PowerDownHDMI() ;
    bHDCPMode = HDCP_RECEIVER ;
    InitIT6605() ;

}

void RxHDCPSetRepeater()
{
    PowerDownHDMI() ;
    bHDCPMode = HDCP_REPEATER ;
    InitIT6605() ;
}

void RxHDCPSetRdyTimeOut() 
{
    PowerDownHDMI() ;
    bHDCPMode = HDCP_REPEATER | HDCP_RDY_TIMEOUT ;
    InitIT6605() ;
}

void RxHDCPSetInvalidV() 
{
    PowerDownHDMI() ;
    bHDCPMode = HDCP_REPEATER | HDCP_INVALID_V ;
    InitIT6605() ;
}

void RxHDCPSetOverDownStream()
{
    PowerDownHDMI() ;
    bHDCPMode = HDCP_REPEATER | HDCP_OVER_DOWNSTREAM ;
    InitIT6605() ;
}

void RxHDCPSetOverCascade()
{
    PowerDownHDMI() ;
    bHDCPMode = HDCP_REPEATER | HDCP_OVER_CASCADE ;
    InitIT6605() ;
}


void RxHDCPRepeaterCapabilitySet(BYTE uc)
{
    HDMIRX_WriteI2C_Byte(REG_CDEPTH_CTRL,HDMIRX_ReadI2C_Byte(REG_CDEPTH_CTRL)|uc);
    ErrorF("RxHDCPRepeaterCapabilitySet=%2X\n",uc) ;
}
void RxHDCPRepeaterCapabilityClear(BYTE uc)
{
    HDMIRX_WriteI2C_Byte(REG_CDEPTH_CTRL,HDMIRX_ReadI2C_Byte(REG_CDEPTH_CTRL)&(~uc));
    ErrorF("RxHDCPRepeaterCapabilityClear=%2X\n",uc) ;  
}
SYS_STATUS RxGetKSVFifoList(BYTE *pKSVList)
{
    BYTE i=0;
    if( !pKSVList)
    {
        return ER_FAIL ;
    }

    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,1);
 //   HDMITX_ReadI2C_ByteN(REG_RX_KSV_FIFO00,pKSVList,20) ;
 //   HDMITX_ReadI2C_ByteN(REG_RX_KSV_FIFO40,pKSVList+20,20) ;
    
    for(;i<20;i++)
    {
        *(pKSVList+i)=HDMIRX_ReadI2C_Byte(REG_RX_KSV_FIFO00+i);
    }
    for(;i<40;i++)
    {
        *(pKSVList+i)=HDMIRX_ReadI2C_Byte(REG_RX_KSV_FIFO40+(i-20));
    }
    
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,0);
    return ER_SUCCESS;
}
SYS_STATUS RxSetKSVFifoList(BYTE *pKSVList)
{
    BYTE i=0;
    if( !pKSVList)
    {
        return ER_FAIL ;
    }

    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,1);
//    HDMITX_WriteI2C_ByteN(REG_RX_KSV_FIFO00,pKSVList,20) ;
//    HDMITX_WriteI2C_ByteN(REG_RX_KSV_FIFO40,pKSVList+20,20) ;
    for(;i<20;i++)
    {
        HDMIRX_WriteI2C_Byte(REG_RX_KSV_FIFO00+i,*(pKSVList+i));
    }
    for(;i<40;i++)
    {
        HDMIRX_WriteI2C_Byte(REG_RX_KSV_FIFO40+(i-20),*(pKSVList+i));
    }
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,0);   
    return ER_SUCCESS;  
}
SYS_STATUS RxHDCPGetM0(BYTE *pM0)
{
    BYTE i=0;
    if( !pM0)
    {
        return ER_FAIL ;
    }
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,1);
//    HDMITX_ReadI2C_ByteN(REG_RX_M0_B0,pM0,8) ;    
    for(;i<8;i++)
    {
        *(pM0+i)=HDMIRX_ReadI2C_Byte(REG_RX_M0_B0+i);
    }
    
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,0);
    ErrorF("RxHDCPGetM0\n") ;   
    return ER_SUCCESS;
}
SYS_STATUS RxHDCPGetBstatus(USHORT *pBstatus)
{
    if( !pBstatus)
    {
        return ER_FAIL ;
    }
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,1);
    *pBstatus=HDMITX_ReadI2C_Byte(REG_RX_BSTATUSL)+(HDMITX_ReadI2C_Byte(REG_RX_BSTATUSH)<<8) ;
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,0);   
    ErrorF("RxHDCPGetBstatus\n") ;      
    return ER_SUCCESS;  
}
void RxAuthSetBStatus(WORD bstatus)
{
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,1);
    HDMIRX_WriteI2C_Byte(REG_RX_BSTATUSH,(BYTE)((bstatus>>8) & 0x0F));
    HDMIRX_WriteI2C_Byte(REG_RX_BSTATUSL,(BYTE)(bstatus & 0xFF));

    ErrorF("Bstatus = %04X\n",bstatus) ;
//    HDMIRX_WriteI2C_Byte(REG_RX_BSTATUSH,0x01);
//    HDMIRX_WriteI2C_Byte(REG_RX_BSTATUSL,0x03);
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,0);   
//  return ER_SUCCESS;  
}


SYS_STATUS RxHDCPWriteVR(BYTE *pVr)
{
    BYTE i,j,k;
    if( !pVr)
    {
        return ER_FAIL ;
    }
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,1);   
    //HDMITX_WriteI2C_ByteN(REG_RX_SHA1_H00,(PBYTE)pVr,20) ;
    i=0;
    for(j=0;j<5;j++)
        {
            for(k=4;k>0;k--)
                {
                    HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H00+i,*(pVr+(j*4)+(k-1)));
                    if(!(i%5))ErrorF("\n") ;                
                    ErrorF("SHA1[%2X]=%2X ,",i,*(pVr+(j*4)+(k-1))) ;
                    i++;
                }
        }
/*
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H00,*(pVr+3));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H01,*(pVr+2));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H02,*(pVr+1));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H03,*(pVr+0));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H10,*(pVr+7));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H11,*(pVr+6));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H12,*(pVr+5));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H13,*(pVr+4));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H20,*(pVr+11));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H21,*(pVr+10));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H22,*(pVr+9));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H23,*(pVr+8));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H30,*(pVr+15));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H31,*(pVr+14));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H32,*(pVr+13));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H33,*(pVr+12));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H40,*(pVr+19));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H41,*(pVr+18));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H42,*(pVr+17));
        HDMIRX_WriteI2C_Byte(REG_RX_SHA1_H43,*(pVr+16));
  */  
    HDMIRX_WriteI2C_Byte(REG_RX_BLOCK_SEL,0);
    //for(i=0;i<20;i++)
    //  {
    //      if(!(i%5))ErrorF("\n") ;                
    //      ErrorF("Vr[%2X]=%2X ,",i,Vr[i]) ;
    //  }
    ErrorF("\n") ;              
    return ER_SUCCESS;  
}
void RxAuthStartInt()
{
    RxHDCPRepeaterCapabilityClear(B_KSV_READY);
    ErrorF("RxAuthStartInt\n") ;            
}

SYS_STATUS RxAuthDoneInt()
{
    BYTE i=0;
    BYTE cDownStream=3 ;
    WORD Bstatus=0x0103;
    
    if( bHDCPMode & HDCP_RDY_TIMEOUT )
    {
        ErrorF("Auth Done, ignore ready.\n") ;
        return ER_SUCCESS ;
    }
    RxSetKSVFifoList(KSVList);
    if(IsIT6605HDMIMode()) Bstatus|=B_CAP_HDMI_MODE;
    
    if( bHDCPMode & HDCP_OVER_DOWNSTREAM )
    {
        Bstatus &= 0xFF7F ;
        Bstatus |= 0x0080 ;
    }

    if( bHDCPMode & HDCP_OVER_CASCADE )
    {
        Bstatus &= 0xF7FF ;
        Bstatus |= 0x0800 ;
    }
    
    RxAuthSetBStatus(Bstatus);
    if(RxHDCPGetM0(M0)==ER_FAIL)
    {
        return ER_FAIL ;
    }
    for(i=0;i<8;i++)
        {
            ErrorF("M0[%2X]=%2X ,",i,M0[i]) ;   
        }
    ErrorF("\n") ;              
    
    if( (bHDCPMode & HDCP_INVALID_V ) == 0)
    {
        HDCP_GenVR(M0,Bstatus,KSVList,cDownStream);
        RxHDCPWriteVR(Vr);
    }
    RxHDCPRepeaterCapabilitySet(B_KSV_READY);   
    ErrorF("RxAuthDoneInt\n") ;             
    return ER_SUCCESS;  
}

void
InitIT6605()
{
    BYTE uc ;

    HWReset_HDMIRX() ;
    
    //////////////////////////////////////////////
    // Initialize HDMIRX chip uc.
    //////////////////////////////////////////////
    
    // find chip revision
    uc = HDMIRX_ReadI2C_Byte(REG_RX_DEVREV);
    if (uc == 0xA2){
        Is_A2 = TRUE;
        AcceptCDRReset = TRUE;
        OS_PRINTF("Revision of Receiver:%Xh\n", uc);
    }else{    
        Is_A2 = FALSE;
    }        
    //
    
    HDMIRX_WriteI2C_Byte(REG_RX_PWD_CTRL0, 0) ;

    #if 0 // for 6023 test.
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, B_REGRST) ; // register reset
    DelayMS(1) ; // wait for B_REGRST down to zero

    uc = HDMIRX_ReadI2C_Byte(REG_RX_HDCP_CTRL) ;
    // uc |= 1 << 3 ;
    #endif 
    
    
    // uc = 0x89 ; // for external ROM 
    uc = B_EXTROM | B_HDCP_ROMDISWR | B_HDCP_EN ;
    HDMIRX_WriteI2C_Byte(REG_RX_HDCP_CTRL, uc) ;
    
    
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, B_SWRST|B_CDRRST) ; // sw reset
    DelayMS(1) ; 

    if (ucCurrentHDMIPort==CAT_HDMI_PORTA)
    {
        uc = B_PORT_SEL_A|B_PWD_AFEALL|B_PWDC_ETC ;
    }
    else
    {
        uc = B_PORT_SEL_B|B_PWD_AFEALL|B_PWDC_ETC ;
    }
    HDMIRX_WriteI2C_Byte(REG_RX_PWD_CTRL1, uc);
    OS_PRINTF("InitIT6605(): reg07 = %02X, ucCurrentHDMIPort = %d\n", HDMIRX_ReadI2C_Byte(07), ucCurrentHDMIPort) ;
    
    SetIntMask1(0,B_PWR5VON|B_SCDTON|B_PWR5VOFF|B_SCDTOFF) ;
    SetIntMask2(0,B_NEW_AVI_PKG|B_PKT_SET_MUTE|B_PKT_CLR_MUTE) ;
    SetIntMask3(0,B_ECCERR|B_R_AUTH_DONE|B_R_AUTH_START) ;
    SetIntMask4(0,0) ;
    #if 1
    SetDefaultRegisterValue() ;
    // 2006/10/31 modified by jjtseng
    // LoadDefaultROMSetting() ;
    LoadCustomizeDefaultSetting() ;
    //~jjtseng 2006/10/31 
    #else
    HDMIRX_WriteI2C_Byte(0x3D, 0x00) ;
    HDMIRX_WriteI2C_Byte(0x6E, 0x0C) ;
    HDMIRX_WriteI2C_Byte(0x75, 0x61) ;
    #endif
    
    SetAVMUTE() ; // MUTE ALL with tristate video, SPDIF and all I2S channel

    // 2006/10/31 marked by jjtseng
    // HDMIRX_WriteI2C_Byte(REG_RX_REGPKTFLAG_CTRL,B_INT_EVERYAVI) ;
    //~jjtseng 2006/10/31
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, 0) ; // normal operation
    bDisableAutoAVMute = FALSE ;

    DelayMS(200) ; // delay 0.2 sec by TPV project experience.

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // DO NOT MOVE THE ACTION LOCATION!!
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // it should be after Reg6E = 0x0C and Reg05 = 0x00
    RDROM_Reset() ; // it should be do SWRESET again AFTER RDROM_Reset().
    
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, B_SWRST) ; // sw reset
    DelayMS(1) ;
    SetAVMUTE() ;
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, 0) ; // normal operation
    
    Terminator_Reset() ;

    // 2006/10/26 modified by jjtseng
    // SwitchVideoState(VSTATE_SyncWait) ;
    SwitchVideoState(VSTATE_PwrOff) ;
    //~jjtseng 2006/10/26
    
    if( bHDCPMode & HDCP_REPEATER )
    {
        RxHDCPRepeaterCapabilitySet(B_ENABLE_REPEATER);    
    }
    else
    {
        RxHDCPRepeaterCapabilityClear(B_KSV_READY|B_ENABLE_REPEATER);
        SetIntMask3(~(B_R_AUTH_DONE|B_R_AUTH_START),B_ECCERR) ;

    }
    
    if (Is_A2){
        HDMIRX_WriteI2C_Byte(REG_RX_HDCP_CTRL, 0x09) ; 
        HDMIRX_WriteI2C_Byte(REG_RX_HDCP_CTRL, 0x19) ;

        HDMIRX_WriteI2C_Byte(0x3B, 0x40);              
        HDMIRX_WriteI2C_Byte(0x6b, 0x11);

        AcceptCDRReset = TRUE;
    }else{        
        HDMIRX_WriteI2C_Byte(REG_RX_HDCP_CTRL, 0x89) ;  // for external ROM
    }     
}

void PowerDownHDMI()
{
    HDMIRX_WriteI2C_Byte(REG_RX_PWD_CTRL1, B_PWD_AFEALL|B_PWDC_ETC|B_PWDC_SRV|B_EN_AUTOPWD) ;
    HDMIRX_WriteI2C_Byte(REG_RX_PWD_CTRL0, B_PWD_ALL) ;
}


WORD getIT6605HorzTotal()
{
    BYTE uc[2] ;
    WORD hTotal ;
    
    uc[0] = HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_L) ;
    uc[1] = HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_H) ;
    hTotal = (WORD)(uc [1] & M_HTOTAL_H) ;
    hTotal <<= 8 ;
    hTotal |= (WORD)uc[0] ;
    
    return hTotal ;
}

WORD getIT6605HorzActive()
{
    BYTE uc[3] ;

    WORD hTotal, hActive ;
    
    uc[0] = HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_L) ;
    uc[1] = HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_H) ;
    uc[2] = HDMIRX_ReadI2C_Byte(REG_RX_VID_HACT_L) ;
    
    hTotal = (WORD)(uc [1] & M_HTOTAL_H) ;
    hTotal <<= 8 ;
    hTotal |= (WORD)uc[0] ;
    
    hActive = (WORD)(uc[1] >> O_HACT_H)& M_HACT_H ;
    hActive <<= 8 ;
    hActive |= (WORD)uc[2] ;
    
    if( (hActive | (1<<11)) < hTotal )
    {
        hActive |= 1<<11 ;
    }
    
    return hActive ;

}

WORD getIT6605HorzFrontPorch()
{
    BYTE uc[2] ;
    WORD hFrontPorch ;
    
    uc[0] = HDMIRX_ReadI2C_Byte(REG_RX_VID_H_FT_PORCH_L) ;
    uc[1] = (HDMIRX_ReadI2C_Byte(REG_RX_VID_HSYNC_WID_H) >> O_H_FT_PORCH ) & M_H_FT_PORCH ;
    hFrontPorch = (WORD)uc[1] ;
    hFrontPorch <<= 8 ;
    hFrontPorch |= (WORD)uc[0] ;
    
    return hFrontPorch ;    
}

WORD getIT6605HorzSyncWidth()
{
    BYTE uc[2] ;
    WORD hSyncWidth ;
    
    uc[0] = HDMIRX_ReadI2C_Byte(REG_RX_VID_HSYNC_WID_L) ;
    uc[1] = HDMIRX_ReadI2C_Byte(REG_RX_VID_HSYNC_WID_H)  & M_HSYNC_WID_H ;
    
    hSyncWidth = (WORD)uc[1] ;
    hSyncWidth <<= 8 ;
    hSyncWidth |= (WORD)uc[0] ;
    
    return hSyncWidth ; 
}

WORD getIT6605HorzBackPorch()
{
    WORD hBackPorch ;
    
    hBackPorch = getIT6605HorzTotal() - getIT6605HorzActive() - getIT6605HorzFrontPorch() - getIT6605HorzSyncWidth() ;
    
    return hBackPorch ;
}

WORD getIT6605VertTotal()
{
    BYTE uc[3] ;
    WORD vTotal, vActive ;
    uc[0] = HDMIRX_ReadI2C_Byte(REG_RX_VID_VTOTAL_L) ;
    uc[1] = HDMIRX_ReadI2C_Byte(REG_RX_VID_VTOTAL_H) ;
    uc[2] = HDMIRX_ReadI2C_Byte(REG_RX_VID_VACT_L) ;
    
    vTotal = (WORD)uc[1] & M_VTOTAL_H ;
    vTotal <<= 8 ;
    vTotal |= (WORD)uc[0] ;
    
    vActive = (WORD)(uc[1] >> O_VACT_H ) & M_VACT_H ;
    vActive |= (WORD)uc[2] ;
    
    if( vTotal > (vActive | (1<<10)))
    {
        vActive |= 1<<10 ;
    }
    
    // for vertical front porch bit lost, ...
    #if 0
    if( vActive == 600 && vTotal == 634 )
    {
        vTotal = 666 ; // fix the 800x600@72 issue
    }
    #endif
    
    return vTotal ;
}

WORD getIT6605VertActive()
{
    BYTE uc[3] ;
    WORD vTotal, vActive ;
    uc[0] = HDMIRX_ReadI2C_Byte(REG_RX_VID_VTOTAL_L) ;
    uc[1] = HDMIRX_ReadI2C_Byte(REG_RX_VID_VTOTAL_H) ;
    uc[2] = HDMIRX_ReadI2C_Byte(REG_RX_VID_VACT_L) ;
    
    vTotal = (WORD)uc[1] & M_VTOTAL_H ;
    vTotal <<= 8 ;
    vTotal |= (WORD)uc[0] ;

    vActive = (WORD)(uc[1] >> O_VACT_H ) & M_VACT_H ;
    vActive <<= 8 ;
    vActive |= (WORD)uc[2] ;
    
    if( vTotal > (vActive | (1<<10))) 
    {
        vActive |= 1<<10 ;
    }
    
    return vActive ;
}

WORD getIT6605VertFrontPorch()
{
    WORD vFrontPorch ;
    
    vFrontPorch = (WORD)HDMIRX_ReadI2C_Byte(REG_RX_VID_V_FT_PORCH) & 0xF ;
    
    if( getIT6605VertActive() == 600 && getIT6605VertTotal() == 666 )
    {
        vFrontPorch |= 0x20 ;
    }
    
    return vFrontPorch ;

}

WORD getIT6605VertSyncToDE()
{
    WORD vSync2DE ;
    
    vSync2DE = (WORD)HDMIRX_ReadI2C_Byte(REG_RX_VID_VSYNC2DE) ;
    return vSync2DE ;
}

WORD getIT6605VertSyncWidth()
{
    WORD vSync2DE ;
    WORD vTotal, vActive, hActive  ;
    
    vSync2DE = getIT6605VertSyncToDE() ;
    vTotal = getIT6605VertTotal() ;
    vActive = getIT6605VertActive() ;
    hActive = getIT6605HorzActive() ;
#ifndef IT6605_A1
    // estamite value.
    if( vActive < 300 )
    {
        return 3 ;
    }
    
    if( hActive == 640 && hActive == 480 )
    {
        if( HDMIRX_ReadI2C_Byte(REG_RX_VID_XTALCNT_128PEL) < 0x80 )
        {
            return 3 ;
        }
        
        return 2; 
    }
    
    return 5 ;
#endif
}

WORD getIT6605VertSyncBackPorch()
{
    WORD vBackPorch ;
    
    vBackPorch = getIT6605VertSyncToDE() - getIT6605VertSyncWidth() ;
    return vBackPorch ;
}

BYTE getIT6605xCnt()
{
    return HDMIRX_ReadI2C_Byte(REG_RX_VID_XTALCNT_128PEL) ;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// BOOL getIT6605AudioInfo (BYTE *pbSampleFreq, BYTE *pbValidCh) ;
// Parameter:   pointer of BYTE pbSampleFreq - return sample freq 
// pointer of BYTE pbValidCh - return valid audio channel.
// Return:  FALSE - no valid audio information during DVI mode.
//         TRUE - valid audio information returned.
// Remark:  if pbSampleFreq is not NULL, *pbSampleFreq will be filled in with one of the following values:
//         0 - 44.1KHz
//         2 - 48KHz
//         3 - 32KHz
//         8 - 88.2 KHz
//         10 - 96 KHz
//         12 - 176.4 KHz
//         14 - 192KHz
//         Otherwise - invalid audio frequence.
//         if pbValidCh is not NULL, *pbValidCh will be identified with the bit valie:
//         bit[0] - '0' means audio channel 0 is not valid, '1' means it is valid.
//         bit[1] - '0' means audio channel 1 is not valid, '1' means it is valid.
//         bit[2] - '0' means audio channel 2 is not valid, '1' means it is valid.
//         bit[3] - '0' means audio channel 3 is not valid, '1' means it is valid.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////

BOOL getIT6605AudioInfo(BYTE *pbAudioSampleFreq, BYTE *pbValidCh)
{
    if(IsIT6605HDMIMode())
    {
        if( pbAudioSampleFreq )
        {
            *pbAudioSampleFreq = HDMIRX_ReadI2C_Byte(REG_RX_FS) & M_Fs ;
        }
        
        if( pbValidCh )
        {
            *pbValidCh = HDMIRX_ReadI2C_Byte(REG_RX_AUDIO_CH_STAT) ;
            if( *pbValidCh & B_AUDIO_LAYOUT )
            {
                *pbValidCh &= M_AUDIO_CH ;
            }
            else
            {
                *pbValidCh = B_AUDIO_SRC_VALID_0 ;
            }
        }
        return TRUE ;
    }
    else
    {
        return FALSE ;
    }
}

///////////////////////////////////////////////////////////
// Get Info Frame and HDMI Package
// Need upper program pass information and read them.
///////////////////////////////////////////////////////////
#ifdef GET_PACKAGE
// 2006/07/03 added by jjtseng
BOOL
GetAVIInfoFrame(BYTE *pData)
{
    // BYTE checksum ;
    // int i ;
    
    if( pData == NULL )
    {
        return ER_FAIL ;
    }
    
    pData[0] = AVI_INFOFRAME_TYPE ; // AVI InfoFrame
    pData[1] = HDMIRX_ReadI2C_Byte(REG_RX_AVI_VER) ;
    pData[2] = AVI_INFOFRAME_LEN ;
    
    HDMIRX_ReadI2C_ByteN(REG_RX_AVI_DB1, pData+3,AVI_INFOFRAME_LEN) ;
    
    return ER_SUCCESS ;
}
//~jjtseng 2006/07/03

// 2006/07/03 added by jjtseng
BOOL
GetAudioInfoFrame(BYTE *pData)
{
    // BYTE checksum ;
    // int i ;
    
    if( pData == NULL )
    {
        return FALSE ;
    }
    
    pData[0] = AUDIO_INFOFRAME_TYPE ; // AUDIO InfoFrame
    pData[1] = HDMIRX_ReadI2C_Byte(REG_RX_AUDIO_VER) ;
    pData[2] = AUDIO_INFOFRAME_LEN ;
    
    HDMIRX_ReadI2C_ByteN(REG_RX_AUDIO_DB1, pData+3,AUDIO_INFOFRAME_LEN) ;
    
    return TRUE ;
}
//~jjtseng 2006/07/03


// 2006/07/03 added by jjtseng
BOOL
GetMPEGInfoFrame(BYTE *pData)
{
    // BYTE checksum ;
    // int i ;
   
    if( pData == NULL )
    {
        return FALSE ;
    }
    
    pData[0] = MPEG_INFOFRAME_TYPE ; // MPEG InfoFrame
    pData[1] = HDMIRX_ReadI2C_Byte(REG_RX_MPEG_VER) ;
    pData[2] = MPEG_INFOFRAME_LEN ;
    
    HDMIRX_ReadI2C_ByteN(REG_RX_MPEG_DB1, pData+3,MPEG_INFOFRAME_LEN) ;
    
    return TRUE ;
}
//~jjtseng 2006/07/03

// 2006/07/03 added by jjtseng
BOOL
GetVENDORSPECInfoFrame(BYTE *pData)
{
    // BYTE checksum ;
    // int i ;
    
    if( pData == NULL )
    {
        return FALSE ;
    }
    
    pData[0] = VENDORSPEC_INFOFRAME_TYPE ; // VENDORSPEC InfoFrame
    pData[1] = HDMIRX_ReadI2C_Byte(REG_RX_VS_VER) ;
    pData[2] = VENDORSPEC_INFOFRAME_LEN ;
    
    HDMIRX_ReadI2C_ByteN(REG_RX_VS_DB1, pData+3,VENDORSPEC_INFOFRAME_LEN) ;
    
    return TRUE ;
}
//~jjtseng 2006/07/03

// 2006/07/03 added by jjtseng
BOOL
GetACPPacket(BYTE *pData)
{
    // BYTE checksum ;
    // int i ;
    
    if( pData == NULL )
    {
        return FALSE ;
    }
    
    HDMIRX_ReadI2C_ByteN(REG_RX_ACP_TYPE, pData,ACP_PKT_LEN) ;
    
    return TRUE ;
}


#endif
//~jjtseng 2006/07/03
    
///////////////////////////////////////////////////////////
//  Testing Function
///////////////////////////////////////////////////////////

void
getIT6605Regs(BYTE *pData)
{
    int i, j ;
    
    SwitchHDMIRXBank(0) ;
    for( i = j = 0 ; i < 256 ; i++,j++ )
    {
        pData[j] = HDMIRX_ReadI2C_Byte((BYTE)(i&0xFF)) ;
    }
    SwitchHDMIRXBank(1) ;
    for( i = 0xA0 ; i <= 0xF2 ; i++, j++ )
    {
        pData[j] = HDMIRX_ReadI2C_Byte((BYTE)(i&0xFF)) ;
    }
    SwitchHDMIRXBank(0) ;
}

BYTE 
getIT6605OutputColorMode()
{
    return bOutputVideoMode & F_MODE_CLRMOD_MASK ;
}

BYTE
getIT6605OutputColorDepth()
{
    BYTE uc ;
    
    uc = HDMIRX_ReadI2C_Byte(REG_RX_FS) & M_GCP_CD ;
    return uc >> O_GCP_CD ;
}

// Initialization
///////////////////////////////////////////////////////////

static void
HWReset_HDMIRX()
{
    OS_PRINTF("+++++++++++ RX HW Reset +++++++++ \n");
    // reset HW Reset Pin.
#ifdef _MCU_
    // Write HDMIRX pin = 1 ;
    HDMIRX_Reset(); // richard add
#else
    
    BYTE uc ;
    // 4. ResetN=> output => Pin14, ~C3
    // Reset = Low means reset
    DelayMS(100) ; // avoid ROM DDC break .
    
    uc = Read_Port_UCHAR(PORT_PRN_CTRL) ;
    uc |= (1<<3) ; // set reset pin to zero, reset.
    Write_Port_UCHAR(PORT_PRN_CTRL, uc) ;
    DelayMS(1) ; // dealy 10 microsec
    uc &= ~(1<<3) ;
    Write_Port_UCHAR(PORT_PRN_CTRL, uc) ;
#endif    
}

static void
Terminator_Off() 
{
    BYTE uc ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_PWD_CTRL1) | (B_PWD_AFEALL|B_PWDC_ETC);
    HDMIRX_WriteI2C_Byte(REG_RX_PWD_CTRL1, uc ) ;
    ErrorF("Terminator_Off, reg07 = %02x\n",uc) ;
}

static void
Terminator_On() 
{
    BYTE uc ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_PWD_CTRL1) & ~(B_PWD_AFEALL|B_PWDC_ETC);
    HDMIRX_WriteI2C_Byte(REG_RX_PWD_CTRL1, uc) ;
    ErrorF("Terminator_On, reg07 = %02x\n",uc) ;
}


static void
Terminator_Reset()
{
    Terminator_Off() ;
    DelayMS(500) ; // delay 500 ms
    Terminator_On() ;
}

void
RDROM_Reset()
{
    BYTE i ;
    BYTE uc ;
    
    ErrorF("RDROM_Reset()\n") ;
    // uc = ((bDisableAutoAVMute)?B_VDO_MUTE_DISABLE:0)|1;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_RDROM_CLKCTRL) & ~(B_ROM_CLK_SEL_REG|B_ROM_CLK_VALUE) ;
    for(i=0 ;i < 16 ; i++ )
    {
        HDMIRX_WriteI2C_Byte(REG_RX_RDROM_CLKCTRL, B_ROM_CLK_SEL_REG|uc) ;
        HDMIRX_WriteI2C_Byte(REG_RX_RDROM_CLKCTRL, B_ROM_CLK_SEL_REG|B_ROM_CLK_VALUE|uc) ;
    }
    // 2006/10/31 modified by jjtseng
    // added oring bDisableAutoAVMute
    HDMIRX_WriteI2C_Byte(REG_RX_RDROM_CLKCTRL,uc) ;
    //~jjtseng 2006/10/31
}

void
Check_RDROM()
{
    BYTE uc ;
    ErrorF("Check_HDCP_RDROM()\n") ;
    
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, 0) ;

    if( IsSCDT() )
    {
        int count ;
        for( count = 0 ;; count++ )
        {
            uc = HDMIRX_ReadI2C_Byte(REG_RX_RDROM_STATUS) ;
            if( uc & B_ROMIDLE ) 
            {
                return ;
            }
            DelayMS(1) ;
            if( count >= 150 )
            {
                RDROM_Reset() ; 
                return ;
            }
        }
    }
    ErrorF("Check_HDCP_RDROM() done.\n") ;
}

static void
SWReset_HDMIRX()
{
    Check_RDROM() ;
    
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, B_SWRST) ; // sw reset
    DelayMS(1) ;
    SetAVMUTE() ;
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, 0) ; // normal operation
    
    // Terminator_Reset() ;

    // 2006/10/26 modified by jjtseng
    // SwitchVideoState(VSTATE_SyncWait) ;
    // SwitchVideoState(VSTATE_PwrOff) ;
    //~jjtseng 2006/10/26
    
    Terminator_Off() ;
    SwitchVideoState(VSTATE_SWReset) ;
}

// 2006/10/31 added by jjtseng
// for customized uc
typedef struct _REGPAIR {
    BYTE ucAddr ;
    BYTE ucValue ;
} REGPAIR ;
//~jjtseng 2006/10/31

/////////////////////////////////////////////////////////////////
// Customer Defined uc area.
/////////////////////////////////////////////////////////////////
// 2006/10/31 added by jjtseng
// for customized uc
static REGPAIR _CODE acCustomizeValue[] =
{
#if 0    
    {REG_RX_INTERRUPT_CTRL,0x30},
    {REG_RX_MISC_CTRL,0x14},
    {REG_RX_VIDEO_MAP,0x00},
    {REG_RX_VIDEO_CTRL1,0x00},
    {REG_RX_PG_CTRL2,0x00},
    // for 6023 demoboard
    // {REG_RX_I2S_CTRL,0x60},
    {REG_RX_I2S_CTRL,0x61},
    {REG_RX_I2S_MAP,0xE4},
    {REG_RX_HWMUTE_RATE,0x20},
    {REG_RX_HWMUTE_CTRL,0x08},
    {REG_RX_HWAMP_CTRL,0x00},
#else
    {REG_RX_PG_CTRL2,0x00},
    // richard {REG_RX_I2S_CTRL,0x61},
    {REG_RX_I2S_CTRL,0x60},
#endif
    {REG_RX_MCLK_CTRL, 0xC1},
    {0xFF,0xFF}
} ;
// jjtseng 2006/10/31

static void
LoadCustomizeDefaultSetting()
{
    BYTE i, uc ;
    for( i = 0 ; acCustomizeValue[i].ucAddr != 0xFF ; i++ )
    {
        HDMIRX_WriteI2C_Byte(acCustomizeValue[i].ucAddr,acCustomizeValue[i].ucValue) ;
    }
    
    uc = HDMIRX_ReadI2C_Byte(REG_RX_PG_CTRL2) & ~(M_OUTPUT_COLOR_MASK<<O_OUTPUT_COLOR_MODE);
    switch(bOutputVideoMode&F_MODE_CLRMOD_MASK)
    {
    case F_MODE_YUV444:
        uc |= B_OUTPUT_YUV444 << O_OUTPUT_COLOR_MODE ;
        break ;
    case F_MODE_YUV422:
        uc |= B_OUTPUT_YUV422 << O_OUTPUT_COLOR_MODE ;
        break ;
    }
    HDMIRX_WriteI2C_Byte(REG_RX_PG_CTRL2, uc) ;
    bIntPOL = (HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT_CTRL) & B_INTPOL)?LO_ACTIVE:HI_ACTIVE ;
}

//////////////////////////////////////////////////
// SetDefaultRegisterValue
// some register value have to be hard coded and
// need to adjust by case. Set here.
//////////////////////////////////////////////////
//  There are some register default setting has changed, please make sure 
// when release to customer.
// 1. Reg-05 = 20
// 2. Reg-08 = BB (for N. Corp. board, others need fine tune again)
// 3. Reg-1D= 30 (for N. Corp. board, others need fine tune again)
// 4. Reg-57 = 19
// 5. Reg-69 = 00
// 6. Reg-6A= E8 (when no external Rext resistor)
//     Reg-6A= A8 ( when external Rext resistor on)
// 7. Reg-6C= 87 
//////////////////////////////////////////////////

// 2006/10/31 added by jjtseng
#if 0
static REGPAIR _CODE acDefaultValue[] =
{
    {REG_RX_VIO_CTRL,0xBB}, // Reg08
    {REG_RX_VCLK_CTRL, 0x30}, // Reg1D
    {REG_RX_I2C_CTRL, 0x19}, // Reg57
    {REG_RX_TERM_CTRL1, 0x80}, // Reg69
    #ifdef NO_EXTERNAL_REXT_RESISTOR
        {REG_RX_TERM_CTRL2, 0xE8}, // Reg6A
    #else    
        {REG_RX_TERM_CTRL2, 0xA8}, // Reg6A
    #endif
    // {REG_RX_PLL_CTRL, 0x4B}, // Reg68 = 0x4B
    // {REG_RX_EQUAL_CTRL2, 0x80}, // Reg6C
    // {REG_RX_DES_CTRL1, 0x00}, // Reg6D = 0x00
    {REG_RX_DES_CTRL2, 0x0C}, // CDR Auto Reset, only CDR
    {0xFF,0xFF}
} ;
#else
static REGPAIR _CODE acDefaultValue[] =
{
    // 2008/01/08 added by jj_tseng@chipadvanced.com
    // request by RD site, equalizer modify.
    {REG_RX_EQUAL_CTRL2, 0x03},
    //~jj_tseng@chipadvanced.com
    {REG_RX_DES_CTRL2, 0x0C}, // CDR Auto Reset, only CDR
    {0xFF,0xFF}
} ;
#endif

//~jjtseng 2006/10/31

void
SetDefaultRegisterValue()
{
    BYTE i, uc ;
    
    for( i = 0 ; acDefaultValue[i].ucAddr != 0xFF ; i++ )
    {
        HDMIRX_WriteI2C_Byte(acDefaultValue[i].ucAddr, acDefaultValue[i].ucValue ) ;
    }

    uc = HDMIRX_ReadI2C_Byte(REG_RX_VID_XTALCNT_128PEL) ;

#if 0    
    #ifdef FOR_ATC
    if( uc < 0x28 ) // High Freq
    {
        HDMIRX_WriteI2C_Byte(REG_RX_PLL_CTRL, 0x4B) ;
        HDMIRX_WriteI2C_Byte(REG_RX_EQUAL_CTRL2, 0x42) ;
        HDMIRX_WriteI2C_Byte(REG_RX_DES_CTRL1, 0x64) ;
    }
    else
    {
        HDMIRX_WriteI2C_Byte(REG_RX_PLL_CTRL, 0x4B) ;
        HDMIRX_WriteI2C_Byte(REG_RX_EQUAL_CTRL2, 0x42) ;
        HDMIRX_WriteI2C_Byte(REG_RX_DES_CTRL1, 0x00) ;
    }
    #else // for release
    if( uc < 0x28 ) // High Freq
    {
        HDMIRX_WriteI2C_Byte(REG_RX_PLL_CTRL, 0x03) ;
        HDMIRX_WriteI2C_Byte(REG_RX_EQUAL_CTRL2, 0x80) ;
        HDMIRX_WriteI2C_Byte(REG_RX_DES_CTRL1, 0x64) ;
    }
    else
    {
        HDMIRX_WriteI2C_Byte(REG_RX_PLL_CTRL, 0x4B) ;
        HDMIRX_WriteI2C_Byte(REG_RX_EQUAL_CTRL2, 0x80) ;
        HDMIRX_WriteI2C_Byte(REG_RX_DES_CTRL1, 0x64) ;
    }
    #endif
#endif    
}

///////////////////////////////////////////////////////////
// Basic IO
///////////////////////////////////////////////////////////
static void
ClearIntFlags(BYTE flag) 
{
    BYTE uc ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT_CTRL) ;
    uc &= FLAG_CLEAR_INT_MASK ;
    uc |= flag ;
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_CTRL,uc) ;
    DelayMS(1);
    uc &= FLAG_CLEAR_INT_MASK ;
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_CTRL,uc) ;  // write 1, then write 0, the corresponded clear action is activated.
    DelayMS(1);
    // ErrorF("ClearIntFlags with %02X\n",uc) ;
}

static void
ClearHDCPIntFlags() 
{
    BYTE uc ;
    
    uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT_CTRL1) ;
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_CTRL1, B_CLR_HDCP_INT|uc ) ;
    DelayMS(1);
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_CTRL1, uc&((BYTE)~B_CLR_HDCP_INT) ) ;
}

///////////////////////////////////////////////////
// IsSCDT()
// return TRUE if SCDT ON
// return FALSE if SCDT OFF
///////////////////////////////////////////////////

static BOOL
IsSCDT()
{
    BYTE uc ;

    uc = HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE) & (B_SCDT|B_VCLK_DET/*|B_PWR5V_DET*/) ;
    return (uc==(B_SCDT|B_VCLK_DET/*|B_PWR5V_DET*/))?TRUE:FALSE ;
}

#if 0
//BOOL
//IsSCDTOn()
//{    
//    BYTE bData ;
//    
//    bData = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1) ;
//    // ErrorF("IsSCDTOn(): Int1 = %02X\n",bData) ;    
//    
//    return (bData&B_SCDTON)?TRUE:FALSE ;
//}
//
//BOOL
//IsSCDTOff()
//{
//    BYTE bData ;
//    
//    bData = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1) ;
//    // ErrorF("IsSCDTOff(): Int1 = %02X\n",bData) ;    
//    return (bData&B_SCDTOFF)?TRUE:FALSE ;
//}
//
//BOOL
//IsSCDTOnOff()
//{
//    BYTE bData ;
//    
//    bData = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1) ;
//    return (bData&(B_SCDTOFF|B_SCDTON))?TRUE:FALSE ;
//}
#endif


BOOL
CheckPlg5VPwr()
{
    BYTE uc ;
    
    // HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1,&uc) ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE) ;
    // ErrorF("CheckPlg5VPwr(): REG_RX_SYS_STATE = %02X %s\n",uc,(uc&B_PWR5V_DET)?"TRUE":"FALSE") ;    
    
    if( ucCurrentHDMIPort == CAT_HDMI_PORTB )
    {
        return (uc&B_PWR5V_DET_PORTB)?TRUE:FALSE ;

    }

    return (uc&B_PWR5V_DET_PORTA)?TRUE:FALSE ;
}

//BOOL
//CheckPlg5VPwrOn()
//{
//    BYTE uc ;
//    
//    uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1) ;
//    // ErrorF("CheckPlg5VPwrOn(): REG_RX_INTERRUPT1 = %02X %s\n",uc,(uc&B_PWR5VON)?"TRUE":"FALSE") ;    
//    return (uc&B_PWR5VON)?TRUE:FALSE ;
//}
//
//BOOL
//CheckPlg5VPwrOff()
//{
//    BYTE uc ;
//    
//    uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1) ;
//    // ErrorF("CheckPlg5VPwrOff(): REG_RX_INTERRUPT1 = %02X %s\n",uc,(uc&B_PWR5VOFF)?"TRUE":"FALSE") ;    
//    return (uc&B_PWR5VOFF)?TRUE:FALSE ;
//}

BOOL
CheckHDCPFail()
{
    BYTE uc ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT3) ;
    //ErrorF("CheckHDCPFail, uc = %02X, %s\n",uc,(uc&B_ECCERR)?"TRUE":"FALSE") ;
    return (uc&B_ECCERR)?TRUE:FALSE ;
}

void
SetMUTE(BYTE AndMask, BYTE OrMask)
{
    BYTE uc ;

    ErrorF("SetMUTE(%02X,%02X) ",AndMask,OrMask) ;    
    
    if( AndMask )
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
        ErrorF("%02X ",uc) ;
    }
    uc &= AndMask ;
    uc |= OrMask ;
    HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL,uc) ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
    ErrorF("-> %02x\n",uc ) ;
}

#if 0
//void
//SetMCLKInOUt(BYTE MCLKSelect)
//{
//    BYTE uc ;
//    uc = HDMIRX_ReadI2C_Byte(REG_RX_MCLK_CTRL) ;
//    uc &= ~M_MCLKSEL ;
//    uc |= MCLKSelect ;
//    HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL, uc) ;
//}
#endif

void 
SetIntMask1(BYTE AndMask,BYTE OrMask)
{
    BYTE uc ;
    if( AndMask != 0 )
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT_MASK1) ;
    }
    uc &= AndMask ;
    uc |= OrMask ;
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_MASK1, uc) ;
}

void 
SetIntMask2(BYTE AndMask,BYTE OrMask)
{
    BYTE uc ;
    if( AndMask != 0 )
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT_MASK2) ;
    }
    uc &= AndMask ;
    uc |= OrMask ;
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_MASK2, uc) ;
}

void 
SetIntMask3(BYTE AndMask,BYTE OrMask)
{
    BYTE uc ;
    if( AndMask != 0 )
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT_MASK3) ;
    }
    uc &= AndMask ;
    uc |= OrMask ;
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_MASK3, uc) ;
}

void 
SetIntMask4(BYTE AndMask,BYTE OrMask)
{
    BYTE uc ;
    if( AndMask != 0 )
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT_MASK4) ;
    }
    uc &= AndMask ;
    uc |= OrMask ;
    HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_MASK4, uc) ;
}

#if 0
void
SetGeneralPktType(BYTE type)
{
    HDMIRX_WriteI2C_Byte(REG_RX_PKT_REC_TYPE,type) ; 
}
#endif

BOOL
IsIT6605HDMIMode()
{
    BYTE uc ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE) ;
    // ErrorF("IsIT6605HDMIMode(): read %02x from reg%02x, result is %s\n",
    //    uc, REG_RX_SYS_STATE, (uc&B_HDMIRX_MODE)?"TRUE":"FALSE") ;
    return (uc&B_HDMIRX_MODE)?TRUE:FALSE ;  
}

///////////////////////////////////////////////////////////
// Interrupt Service
///////////////////////////////////////////////////////////

void
Interrupt_Handler()
{
    BYTE int1data = 0 ;
    BYTE int2data = 0 ;
    BYTE int3data = 0 ;
    BYTE sys_state ;
    BYTE flag = FLAG_CLEAR_INT_ALL;

    // ClearIntFlags(0) ;
    if( VState == VSTATE_SWReset )
    {
        return ; // if SWReset, ignore all interrupt.
    }

    sys_state = HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE) ;
    int1data = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1) ; 
    if( int1data )
    {
        ErrorF("system state = %02X\n",sys_state) ;
        ErrorF("Interrupt 1 = %02X\n",int1data) ;
        ClearIntFlags(B_CLR_MODE_INT) ;
        
        if(!CheckPlg5VPwr())
        {
            if( VState != VSTATE_SWReset && VState != VSTATE_PwrOff )
            {
                SWReset_HDMIRX() ;
                return ;
            }
        }

        if( int1data & B_PWR5VOFF )
        {
            ErrorF("5V Power Off interrupt\n") ;
            RXINT_5V_PwrOff() ;
        }

        if( int1data & B_SCDTOFF )
        {
            ErrorF("SCDT Off interrupt\n") ;
            RXINT_SCDT_Off() ;
        }

        if( int1data & B_PWR5VON )
        {
            ErrorF("5V Power On interrupt\n") ;
            RXINT_5V_PwrOn() ;
        }
        
        if( int1data & B_VIDMODE_CHG )
        {
            ErrorF("Video mode change interrupt.\n:") ;
            RXINT_VideoMode_Chg() ;
            if( VState == VSTATE_SWReset )
            {
                return ;
            }
        }
        
        if( int1data & B_HDMIMODE_CHG )
        {
            ErrorF("HDMI Mode change interrupt.\n") ;
            RXINT_HDMIMode_Chg() ;
        }

        if( int1data & B_SCDTON )
        {
            ErrorF("SCDT On interrupt\n") ;
            RXINT_SCDT_On() ;
        }
        
    }
    
    int2data = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT2) ;
    if( int2data )
    {
        BYTE vid_stat = HDMIRX_ReadI2C_Byte(REG_RX_VID_INPUT_ST) ;
        ErrorF("Interrupt 2 = %02X\n",int2data) ;
        ClearIntFlags(B_CLR_PKT_INT|B_CLR_MUTECLR_INT|B_CLR_MUTESET_INT) ;
        
        if( int2data & B_PKT_SET_MUTE )
        {
            ErrorF("AVMute set interrupt.\n" );
            RXINT_AVMute_Set() ;
        }
        
        if( int2data & B_NEW_AVI_PKG )
        {
            ErrorF("New AVI Info Frame Change interrupt\n") ;
            RXINT_SetNewAVIInfo() ;
        }

        if( ( int2data & B_PKT_CLR_MUTE ))
        {
            ErrorF("AVMute clear interrupt.\n" );
            RXINT_AVMute_Clear() ;
        }
    }


    int3data = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT3) ;
    
    if( int3data &(B_R_AUTH_DONE|B_R_AUTH_START))
    {
        ClearHDCPIntFlags() ;
        if( bHDCPMode & HDCP_REPEATER )
        {
            if( int3data & B_R_AUTH_START )
            {
                ErrorF(" B_R_AUTH_START\n") ;
                RxAuthStartInt() ;
            }
            if( int3data & B_R_AUTH_DONE )
            {
                ErrorF("B_R_AUTH_DONE \n") ;
                RxAuthDoneInt() ;
            }
        }

    }
        
    if( VState == VSTATE_VideoOn || VState == VSTATE_HDCP_Reset)
    {
        if( int3data &(B_ECCERR|B_AUDFIFOERR|B_AUTOAUDMUTE))
        {
            ClearIntFlags(B_CLR_AUDIO_INT|B_CLR_ECC_INT) ;
            // HDMIRX_WriteI2C_Byte(REG_RX_INTERRUPT_CTRL1,B_CLR_HDCP_INT) ;    
            if( AState != ASTATE_AudioOff)
            {
                ErrorF("Interrupt 3 = %02X\n",int3data) ;
                if( int3data & (B_AUTOAUDMUTE|B_AUDFIFOERR)) 
                {
                    ErrorF("Audio Error interupt\n") ;
                    RXINT_ResetAudio() ;
                }
            }
            
            if( int3data & B_ECCERR )
            {
                ErrorF("ECC error interrupt\n") ;
                RXINT_ResetHDCP() ;
            }
        }
    }
    
    if( int1data | int2data )
    {
        ErrorF("%02X %02X %02X\n",
            HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1),
            HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT2),
            HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE)) ;
    }

}

void
RXINT_5V_PwrOn()
{
    BYTE sys_state ;
    
    if( VState == VSTATE_PwrOff )
    {
        sys_state = HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE) ;
        
        if( sys_state & B_PWR5VON )
        {
            //OS_PRINTF("RXINT_5V_PwrOn, ->VSTATE_SyncWait\n");
            SwitchVideoState(VSTATE_SyncWait) ;
        }
    }
}

void
RXINT_5V_PwrOff()
{
    BYTE sys_state ;
    
    sys_state = HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE) ;
    
    SWReset_HDMIRX() ;
}

void
RXINT_SCDT_On()
{
    if( VState == VSTATE_SyncWait )
    {
        if(IsSCDT())
        {
            //OS_PRINTF("RXINT_SCDT_On, ->VSTATE_SyncChecking\n");
            SwitchVideoState(VSTATE_SyncChecking) ;
        }
    }
}

void
RXINT_SCDT_Off()
{
    
    if( VState != VSTATE_PwrOff )
    {
        //OS_PRINTF("RXINT_SCDT_Off, ->VSTATE_SyncWait\n");
        ErrorF("GetSCDT OFF\n") ;
        SetAVMUTE() ;
        SwitchVideoState(VSTATE_SyncWait) ;
    }
}

void
RXINT_VideoMode_Chg()
{
    BYTE sys_state ;

    ErrorF("RXINT_VideoMode_Chg\n") ;
    
    sys_state = HDMIRX_ReadI2C_Byte(REG_RX_SYS_STATE) ;
    SetAVMUTE() ;

    if(CheckPlg5VPwr()) 
    {
        OS_PRINTF("RXINT_VideoMode_Chg, -> VSTATE_SyncWait\n"); 
        // richard add condition
       // if (VState != VSTATE_SyncChecking)
            SwitchVideoState(VSTATE_SyncWait) ;
    }
    else
    {
        SWReset_HDMIRX() ;
    }
}

void
RXINT_HDMIMode_Chg()
{
    if(VState == VSTATE_VideoOn )
    {
        if( IsIT6605HDMIMode() )
        {
            ErrorF("HDMI Mode.\n") ;
            SwitchAudioState(ASTATE_RequestAudio) ;
            // wait for new AVIInfoFrame to switch color space.
        }
        else
        {
            ErrorF("DVI Mode.\n") ;
            SwitchAudioState(ASTATE_AudioOff) ;
            NewAVIInfoFrameF = FALSE ;

            // should switch input color mode to RGB24 mode.
            SetDVIVideoOutput() ;
            // No info frame active.
        }
    }
}

void
RXINT_AVMute_Set()
{
    BYTE uc ;
    MuteByPKG = ON ;
    SetAVMUTE() ;
    StartAutoMuteOffTimer() ; // start AutoMute Timer.
    SetIntMask2(~(B_PKT_CLR_MUTE),(B_PKT_CLR_MUTE)) ; // enable the CLR MUTE interrupt.
    
    bDisableAutoAVMute = 0 ;
//     uc = HDMIRX_ReadI2C_Byte(REG_RX_RDROM_CLKCTRL) ;
    uc = HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
    uc &= ~B_VDO_MUTE_DISABLE ;
//     HDMIRX_WriteI2C_Byte(REG_RX_RDROM_CLKCTRL, uc) ;
    HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;
}

void
RXINT_AVMute_Clear()
{
    BYTE uc ;
    MuteByPKG = OFF ;

    bDisableAutoAVMute = 0 ;
    // HDMIRX_WriteI2C_Byte(REG_RX_RDROM_CLKCTRL, HDMIRX_ReadI2C_Byte(REG_RX_RDROM_CLKCTRL)&(~B_VDO_MUTE_DISABLE)) ;
    uc =  HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
    uc &= ~B_VDO_MUTE_DISABLE ;
    HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;
    
    EndAutoMuteOffTimer() ;

    if(VState == VSTATE_VideoOn ) 
    {
        SetVideoMUTE(OFF) ;

    }

    if(AState == ASTATE_AudioOn )
    {
        SetHWMuteClr() ;
        ClearHWMuteClr() ;

        SetAudioMute(OFF) ;
    }
    SetIntMask2(~(B_PKT_CLR_MUTE),0) ; // clear the CLR MUTE interrupt.
}

void
RXINT_SetNewAVIInfo()
{
    NewAVIInfoFrameF = TRUE ;
    
    if( VState == VSTATE_VideoOn )
    {
        SetNewInfoVideoOutput() ;
    }
    
    prevAVIDB1 = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB1) ;
    prevAVIDB2 = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB2) ;
    
}

void
RXINT_ResetAudio()
{
    // audio error.
    if(AState != ASTATE_AudioOff)
    {
        SetAudioMute(ON) ;
        SwitchAudioState(ASTATE_RequestAudio) ;
    }
}


void
RXINT_ResetHDCP()
{
    BYTE uc ;

    if( VState == VSTATE_VideoOn )
    {
        ClearIntFlags(B_CLR_ECC_INT) ;
        DelayMS(1) ;
        uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT3) ;
        
        if( uc & B_ECCERR )
        {
            SetAVMUTE() ;
            SwitchVideoState(VSTATE_HDCP_Reset) ;       
            // SWReset_HDMIRX() ;
        }

        // HDCP_Reset() ;
        // SetVideoMUTE(MuteByPKG) ;
        // RXINT_ResetAudio() ; // reset Audio
    }
}

///////////////////////////////////////////////////////////
// Timer Service
///////////////////////////////////////////////////////////

void
Timer_Handler()
{
    Interrupt_Handler() ;        
    VideoTimerHandler() ;
    MuteProcessTimerHandler() ;
    AudioTimerHandler() ;
}

static void
VideoTimerHandler()
{
    UCHAR uc ;
    
    // monitor if no state
    if( VState == VSTATE_SWReset )
    {
        if(VideoCountingTimer==0)
        {
            Terminator_On() ;
            SwitchVideoState(VSTATE_PwrOff) ;
            return ;
        }
        VideoCountingTimer-- ;
        return ;
    }
    
    if( VState == VSTATE_PwrOff )
    {
        if(CheckPlg5VPwr())
        {
            SwitchVideoState(VSTATE_SyncWait) ;
            return ;
        }
    }
    
    if((VState != VSTATE_PwrOff)&&(VState != VSTATE_SyncWait)&&(VState != VSTATE_SWReset))
    {
        if(!IsSCDT())
        {
            OS_PRINTF("SCDT off, ->VSTATE_SyncWait\n");
            SwitchVideoState(VSTATE_SyncWait) ;
            return ;
        }
    }
    else if ((VState != VSTATE_PwrOff)&&(VState != VSTATE_SWReset))
    {
        if(!CheckPlg5VPwr())
        {
            // SwitchVideoState(VSTATE_PwrOff) ;
            SWReset_HDMIRX() ;
            return ;
        }
    }

    // 2007/01/12 added by jjtseng
    // add the software reset timeout setting.
    if( VState == VSTATE_SyncWait || VState == VSTATE_SyncChecking )
    {
        SWResetTimeOut-- ;
        if( SWResetTimeOut == 0 )
        {
            OS_PRINTF("[RX] SWResetTimeOut, change state\n");             
            SWReset_HDMIRX() ;
            return ;
        }
        
    }
    //~jjtseng 
    
    if( VState == VSTATE_SyncWait )
    {
        if( VideoCountingTimer == 0 )
        {
            ErrorF("VsyncWaitResetTimer up, call SWReset_HDMIRX()\n",VideoCountingTimer) ;
            SWReset_HDMIRX() ;
            return ;
            // AssignVideoTimerTimeout(VSTATE_MISS_SYNC_COUNT) ;
        }
        else
        {
            if( IsSCDT() )
            {
                SwitchVideoState(VSTATE_SyncChecking) ;
                return ;
            }
            VideoCountingTimer-- ;
        }
    }
    
    if( VState == VSTATE_SyncChecking )
    {
        // ErrorF("SyncChecking %d\n",VideoCountingTimer) ;
        //OS_PRINTF("SyncChecking %d\n",VideoCountingTimer) ;
        if( VideoCountingTimer == 0)
        {
            SwitchVideoState(VSTATE_ModeDetecting) ;
            return ;
        }
        else
        {
            VideoCountingTimer-- ;
        }
    }
    
    if( VState == VSTATE_HDCP_Reset )
    {
        // ErrorF("SyncChecking %d\n",VideoCountingTimer) ;
        if( --VideoCountingTimer == 0)
        {
            ErrorF("HDCP timer reach, reset !!\n") ;
            // SwitchVideoState(VSTATE_PwrOff) ;
            SWReset_HDMIRX() ;
            return ;
        }
        else
        {
            ErrorF("VideoTimerHandler[VSTATE_HDCP_Reset](%d)\n",VideoCountingTimer) ;
            do {
                ClearIntFlags(B_CLR_ECC_INT) ;
                DelayMS(1) ;
                uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT3) ;
                if(uc & B_ECCERR)
                {
                    break ;
                }
                DelayMS(1) ;
                ClearIntFlags(B_CLR_ECC_INT) ;
                DelayMS(1) ;
                uc = HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT3) ;
                if(!(uc & B_ECCERR))
                {
                    SwitchVideoState(VSTATE_VideoOn) ;
                    return ;
                }
            }while(0) ;
        }
    }
    
    if( VState == VSTATE_VideoOn )
    {
        char diff ;
        unsigned short HTotal ;
        unsigned char xCnt ;
        BOOL bVidModeChange = FALSE ;
        BOOL ScanMode ;
        // bGetSyncInfo() ;
        
        HTotal = (unsigned short)HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_L) ;
        HTotal |= (unsigned short)(HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_H)&M_HTOTAL_H) << 8 ;
        if(abs((int)HTotal -(int)currHTotal)>4)
        {
            bVidModeChange = TRUE ;
            ErrorF("HTotal changed.\n") ;
        }

        if(!bVidModeChange)
        {
            xCnt = (unsigned char)HDMIRX_ReadI2C_Byte(REG_RX_VID_XTALCNT_128PEL) ;
            
            diff = (char)currXcnt - (char)xCnt ;
    
            if( xCnt > 0x80 )
            {
                if( abs(diff) > 6 )
                {
                    ErrorF("Xcnt changed. %02x -> %02x ",(int)xCnt,(int)currXcnt) ;
                    ErrorF("diff = %d\r\n",(int)diff) ;
                    bVidModeChange = TRUE ;
                }
            }
            else if ( xCnt > 0x40 )
            {
                if( abs(diff) > 4 )
                {
                    ErrorF("Xcnt changed. %02x -> %02x ",(int)xCnt,(int)currXcnt) ;
                    ErrorF("diff = %d\r\n",(int)diff) ;
                    bVidModeChange = TRUE ;
                }
            }
            else if ( xCnt > 0x20 )
            {
                if( abs(diff) > 2 )
                {
                    ErrorF("Xcnt changed. %02x -> %02x ",(int)xCnt,(int)currXcnt) ;
                    ErrorF("diff = %d\n\r",(int)diff) ;
                    bVidModeChange = TRUE ;
                }
            }
            else
            {
                if( abs(diff) > 1 )
                {
                    ErrorF("Xcnt changed. %02x -> %02x ",(int)xCnt,(int)currXcnt) ;
                    ErrorF("diff = %d\r\n",(int)diff) ;
                    bVidModeChange = TRUE ;
                }
            }
        }

        if(pVTiming->VActive < 300)
        {
            if( !bVidModeChange )
            {
                ScanMode = (HDMIRX_ReadI2C_Byte(REG_RX_VID_MODE)&B_INTERLACE)?INTERLACE:PROG ;
                if( ScanMode != currScanMode )
                {
                    ErrorF("ScanMode change.\r\n") ;
                    bVidModeChange = TRUE ;
                }
            }
        }

        if(bVidModeChange)
        {
            OS_PRINTF("Video Mode Chagne, -> VSTATE_SyncWait");
            SwitchVideoState(VSTATE_SyncWait) ;
        }
        else        
        {
            unsigned char currAVI_DB1, currAVI_DB2 ;
            static unsigned char prevAVI_DB1 = 0 ;
            static unsigned char prevAVI_DB2 = 0 ;
            
            currAVI_DB1 = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB1) ;
            currAVI_DB2 = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB2) ;

            if( IsIT6605HDMIMode()){
                if( (currAVI_DB1 != prevAVI_DB1)||(currAVI_DB2 != prevAVI_DB2)){
                    RXINT_SetNewAVIInfo() ;
                }
            }
            prevAVI_DB1 = currAVI_DB1 ;
            prevAVI_DB2 = currAVI_DB2 ;
        }
    }
}

static void
AudioTimerHandler()
{
    // BOOL b1080p60Fix = FALSE ;
    BYTE uc ;
    switch(AState)
    {
    case ASTATE_RequestAudio:
        
        // 2007/05/28 added by jjtseng
        // 1080p fixed
        // if mode = 1080p60 and Fs = 44.1K || Fs = 32K || Fs == 48K
        
        #ifndef USING_SPDIF
        // if( HDMIRX_ReadI2C_Byte(REG_RX_AUDIO_FMT) & B_LPCM )
        // {
        #endif
            // if( pVTiming -> HTotal == 2200 && pVTiming -> VTotal == 1125 && pVTiming -> xCnt == 0x17 )
            // {
            //     uc = HDMIRX_ReadI2C_Byte(REG_RX_FS) & 0xf ;
            //     if( uc == B_Fs_44p1KHz || uc == B_Fs_48KHz || uc == B_Fs_32KHz ) 
            //     {
            //         b1080p60Fix = TRUE ;
            //         HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL, 0x49) ;
            //     }
            // }
            //~jjtseng 2007/05/28
            
            ucHDMIAudioErrorCount++ ;
            uc = HDMIRX_ReadI2C_Byte(REG_RX_AUDIO_CTRL) ;
            if( ucHDMIAudioErrorCount > 10 )
            {
                switch(ucAudioSampleClock)
                {
                case 0x02: ucAudioSampleClock = 0x00 ; break ; // 48KHz -> 44.1KHz
                case 0x00: ucAudioSampleClock = 0x03 ; break ; // 44.1KHz -> 32KHz
                default: ucAudioSampleClock = 0x02 ; break ; // ? -> 48KHz
                }
                ucHDMIAudioErrorCount = 0 ;
                uc |= B_FORCE_FS ;
                ErrorF("Force enable audio FS, ucAudioSampleClock = %02X\n\r",(int)ucAudioSampleClock) ;
            }
            
            // a. if find Audio Error in a period timers, assue the FS message is wrong, then try to force FS setting.
            // b. set Reg0x77[6]=1 => select Force FS mode.
            HDMIRX_WriteI2C_Byte(REG_RX_AUDIO_CTRL, uc) ; // reg77[6] = ?
            if( uc & B_FORCE_FS )
            {
                // c. set Reg0x78[5]=1 => CTSINI_EN=1
                uc = HDMIRX_ReadI2C_Byte(REG_RX_MCLK_CTRL)|B_CTSINI_EN ;
                HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL,uc) ; 
            }
           
            
            ErrorF("AState change to ASTATE_RequestAudio\n") ;
            SetHWMuteClrMode() ;
            // d. set Reg0x05=04 => reset Audio
            // e. set Reg0x05=0
            ResetAudio() ;
            if(  HDMIRX_ReadI2C_Byte(REG_RX_AUDIO_CTRL) & B_FORCE_FS )
            {
                // f. set Reg0x7e[3:0]=0 ( at leasst three times) => force FS value
                // g. if Audio still Error, then repeat b~f setps.(on f setp, set another FS value
                // 0:44,1K, 2: 48K, 3:32K, 8:88.2K, A:96K, C:176.4K, E:192K)
                HDMIRX_WriteI2C_Byte(REG_RX_FS_SET, ucAudioSampleClock) ; 
                HDMIRX_WriteI2C_Byte(REG_RX_FS_SET, ucAudioSampleClock) ;
                HDMIRX_WriteI2C_Byte(REG_RX_FS_SET, ucAudioSampleClock) ;
                HDMIRX_WriteI2C_Byte(REG_RX_FS_SET, ucAudioSampleClock) ;
            }
            // else
            // {
            //     // 2007/05/28 added by jjtseng
            //     // 1080p fixed
            //     // if mode = 1080p60 and Fs = 44.1K || Fs = 32K || Fs == 48K
            //     if( b1080p60Fix )
            //     {
            //         HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL, 0x41) ;
            //     }
            //     //~jjtseng 2007/05/28
            // }
    
                
            ClearIntFlags(B_CLR_AUDIO_INT) ;
            SetIntMask3(~(B_AUTOAUDMUTE|B_AUDFIFOERR),(B_AUTOAUDMUTE|B_AUDFIFOERR)) ;
            SwitchAudioState(ASTATE_WaitForReady) ;
        #ifndef USING_SPDIF
        // }
        // else
        // {
        //     SwitchAudioState(ASTATE_AudioOff) ;
        // }
        #endif
        break ;
        
    case ASTATE_WaitForReady:
        if( AudioCountingTimer == 0 )
        {
            SwitchAudioState(ASTATE_AudioOn) ;
        }
        else
        {
            AudioCountingTimer -- ;
        }
        break ;
    }
    
}

static void
MuteProcessTimerHandler()
{
    BYTE uc ;
    BOOL TurnOffMute = FALSE ;

    if( MuteByPKG == ON )
    {
        // ErrorF("MuteProcessTimerHandler()\n") ;
        if( (MuteResumingTimer > 0)&&(AState == ASTATE_AudioOn)) 
        {
            MuteResumingTimer -- ;
            uc = HDMIRX_ReadI2C_Byte(REG_RX_VID_INPUT_ST) ;
            // ErrorF("MuteResumingTimer = %d uc = %02X\n",MuteResumingTimer , uc) ;

            if(!(uc&B_AVMUTE))
            {
                TurnOffMute = TRUE ;
                MuteByPKG = OFF ;
            }            
            else if((MuteResumingTimer == 0))
            {
                bDisableAutoAVMute = B_VDO_MUTE_DISABLE ;
                
                uc = HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
                uc |= B_VDO_MUTE_DISABLE ;
                HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;
                
                TurnOffMute = TRUE ;
                MuteByPKG = OFF ;
            }
        }
        
        if ( MuteAutoOff )
        {
            uc = HDMIRX_ReadI2C_Byte(REG_RX_VID_INPUT_ST) ;
            if(!(uc & B_AVMUTE))
            {
                EndAutoMuteOffTimer() ;
                TurnOffMute = TRUE ;
            }
        }
    }

    if( TurnOffMute )
    {
        if(VState == VSTATE_VideoOn ) 
        {
            SetVideoMUTE(OFF) ;
            if(AState == ASTATE_AudioOn )
            {
                SetAudioMute(OFF) ;
            }
        }
    }    
}


void
AssignVideoTimerTimeout(USHORT TimeOut)
{
    VideoCountingTimer = TimeOut ;
}

void
AssignAudioTimerTimeout(USHORT TimeOut)
{
    AudioCountingTimer = TimeOut ;
    
}

#if 0
void
ResetVideoTimerTimeout()
{
    VideoCountingTimer = 0 ;
}

void
ResetAudioTimerTimeout()
{
    AudioCountingTimer = 0 ;
}
#endif

void
SwitchVideoState(Video_State_Type state)
{
    if( VState == state )
    {
        return ;
    }
        
    if( VState == VSTATE_VideoOn && state != VSTATE_VideoOn)
    {
        SetAVMUTE() ;
        SwitchAudioState(ASTATE_AudioOff) ;
    }
    
    VState = state ;
    #ifndef _MCU_
    ErrorF("VState -> %s\n",VStateStr[VState]) ;
    #endif
    
    
  
    if( VState != VSTATE_SyncWait && VState != VSTATE_SyncChecking )
// richad new    if( VState == VSTATE_SyncWait || VState == VSTATE_SyncChecking )
    {
        SWResetTimeOut = FORCE_SWRESET_TIMEOUT;
        // init the SWResetTimeOut, decreasing when timer. 
        // if down to zero when SyncWait or SyncChecking,
        // SWReset.        
    }
        
        
    switch(VState)
    {
    case VSTATE_SWReset:
        AssignVideoTimerTimeout(VSTATE_SWRESET_COUNT);     
        break ;
    case VSTATE_SyncWait:
        if( Is_A2 && AcceptCDRReset == TRUE )
        {
            CDR_Reset();            
        }
        // 2006/10/31 marked by jjtseng
        // HDMIRX_WriteI2C_Byte(REG_RX_REGPKTFLAG_CTRL,B_INT_EVERYAVI) ;
        //~jjtseng 2006/10/31
        AssignVideoTimerTimeout(VSTATE_MISS_SYNC_COUNT);     
        break ;
    case VSTATE_SyncChecking:
        AssignVideoTimerTimeout(VSATE_CONFIRM_SCDT_COUNT);     
        break ;
    case VSTATE_HDCP_Reset:
        AssignVideoTimerTimeout(HDCP_WAITING_TIMEOUT);
        break ;        
    case VSTATE_VideoOn:
        // SetVideoMUTE(MuteByPKG) ; // turned on Video.
        // 2006/10/31 marked by jjtseng
        // HDMIRX_WriteI2C_Byte(REG_RX_REGPKTFLAG_CTRL, 0) ; // never need detect every AVI infoframe
        //~jjtseng 2006/10/31
        // AssignVideoTimerTimeout(VIDEO_TIMER_CHECK_COUNT) ;
        OS_PRINTF("==== RX Video On ====\n");
        if (Is_A2)
            AcceptCDRReset = TRUE ;

        if(!NewAVIInfoFrameF)
        {
            SetVideoInputFormatWithoutInfoFrame(F_MODE_RGB24) ;
            SetColorimetryByMode(/*&SyncInfo*/) ;
            SetColorSpaceConvert() ;
        }

        if( !IsIT6605HDMIMode())
        {
            SetIntMask1(~(B_SCDTOFF|B_PWR5VOFF),(B_SCDTOFF|B_PWR5VOFF)) ;
            SetVideoMUTE(OFF) ; // turned on Video.
            SwitchAudioState(ASTATE_AudioOff) ;
            NewAVIInfoFrameF = FALSE ;
        }
        else
        {
            BYTE uc ;
            
            if( NewAVIInfoFrameF )
            {
                SetNewInfoVideoOutput() ;
            }

            if( bHDCPMode & HDCP_REPEATER )
            {
                SetIntMask3(0,B_ECCERR|B_R_AUTH_DONE|B_R_AUTH_START) ;
            }
            else
            {
                SetIntMask3(~(B_R_AUTH_DONE|B_R_AUTH_START),B_ECCERR) ;
            }
            
            SetIntMask2(~(B_NEW_AVI_PKG|B_PKT_SET_MUTE|B_PKT_CLR_MUTE),(B_NEW_AVI_PKG|B_PKT_SET_MUTE|B_PKT_CLR_MUTE)) ;
            SetIntMask1(~(B_SCDTOFF|B_PWR5VOFF),(B_SCDTOFF|B_PWR5VOFF)) ;
            
            MuteByPKG =  (HDMIRX_ReadI2C_Byte(REG_RX_VID_INPUT_ST) & B_AVMUTE)?TRUE:FALSE ;
            
            SetVideoMUTE(MuteByPKG) ; // turned on Video.

            ucHDMIAudioErrorCount = 0 ;
            uc = HDMIRX_ReadI2C_Byte(REG_RX_AUDIO_CTRL) ;
            uc &= ~B_FORCE_FS ;
            HDMIRX_WriteI2C_Byte(REG_RX_AUDIO_CTRL, uc) ;
            
            uc = HDMIRX_ReadI2C_Byte(REG_RX_MCLK_CTRL) & (~B_CTSINI_EN);
            HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL, uc) ;
            
            ErrorF("[%s:%d] reg%02X = %02X\n",__FILE__,__LINE__,REG_RX_AUDIO_CTRL, uc) ;

            // Enable Audio
            SetHWMuteClrMode() ;
            ResetAudio() ;
            ClearIntFlags(B_CLR_AUDIO_INT) ;
            SetIntMask3(~(B_AUTOAUDMUTE|B_AUDFIFOERR),(B_AUTOAUDMUTE|B_AUDFIFOERR)) ;
            DelayMS(5) ;
            
            if( HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT3) & (B_AUTOAUDMUTE|B_AUDFIFOERR) )
            {
                SwitchAudioState(ASTATE_RequestAudio) ;
            }
            else
            {
                SwitchAudioState(ASTATE_AudioOn) ;
            }
        }            

        currHTotal = pVTiming->HTotal ;
        currXcnt = pVTiming->xCnt ;
        currScanMode = pVTiming->ScanMode ;
        break ;
    }
}
 
void
SwitchAudioState(Audio_State_Type state)
{
    AState = state ;
    #ifndef _MCU_
    ErrorF("AState -> %s\n",AStateStr[AState]) ;
    #endif
    
    switch(AState)
    {
    case ASTATE_AudioOff:
        SetAudioMute(TRUE) ;
        break ;
        
    case ASTATE_WaitForReady:
        AssignAudioTimerTimeout(AUDIO_READY_TIMEOUT) ;
        break ;        
    case ASTATE_AudioOn:
        SetAudioMute(MuteByPKG) ;
        if( MuteByPKG )
        {
            ErrorF("AudioOn, but still in mute.\n") ;
            EnableMuteProcessTimer() ;
        }
        break ;         
    }
}



static void 
DumpSyncInfo(VTiming *pVTiming)
{
    double VFreq ;
    ErrorF("{%4d,",pVTiming->HActive) ;
    ErrorF("%4d,",pVTiming->VActive) ;
    ErrorF("%4d,",pVTiming->HTotal) ;
    ErrorF("%4d,",pVTiming->VTotal) ;
    ErrorF("%8ld,",pVTiming->PCLK) ;
    ErrorF("0x%02x,",pVTiming->xCnt) ;
    ErrorF("%3d,",pVTiming->HFrontPorch) ;
    ErrorF("%3d,",pVTiming->HSyncWidth) ;
    ErrorF("%3d,",pVTiming->HBackPorch) ;
    ErrorF("%2d,",pVTiming->VFrontPorch) ;
    ErrorF("%2d,",pVTiming->VSyncWidth) ;
    ErrorF("%2d,",pVTiming->VBackPorch) ;
    ErrorF("%s,",pVTiming->ScanMode?"PROG":"INTERLACE") ;
    ErrorF("%s,",pVTiming->VPolarity?"Vpos":"Vneg") ;
    ErrorF("%s},",pVTiming->HPolarity?"Hpos":"Hneg") ;
    VFreq = (double)pVTiming->PCLK ;
    VFreq *= 1000.0 ;
    VFreq /= pVTiming->HTotal ;
    VFreq /= pVTiming->VTotal ;
    ErrorF("// %dx%d@%5.2lfHz\n",pVTiming->HActive,pVTiming->VActive,VFreq) ;
}

static BOOL 
bGetSyncInfo()
{
    long diff ;
    
    BYTE uc1, uc2, uc3 ;
    int i ;
    
    pVTiming = NULL ;
    pVTiming = &s_CurrentVM ;
    uc1 = HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_L) ; 
    uc2 = HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_H) ; 
    uc3 = HDMIRX_ReadI2C_Byte(REG_RX_VID_HACT_L) ; 
    
    s_CurrentVM.HTotal = ((WORD)(uc2&0xF)<<8) | (WORD)uc1;
    s_CurrentVM.HActive = ((WORD)(uc2 & 0x70)<<4) | (WORD)uc3 ;
    if( (s_CurrentVM.HActive | (1<<11)) <s_CurrentVM.HTotal )
    {
        s_CurrentVM.HActive |= (1<<11) ;
    }
    uc1 = HDMIRX_ReadI2C_Byte(REG_RX_VID_HSYNC_WID_L) ; 
    uc2 = HDMIRX_ReadI2C_Byte(REG_RX_VID_HSYNC_WID_H) ; 
    uc3 = HDMIRX_ReadI2C_Byte(REG_RX_VID_H_FT_PORCH_L) ; 

    s_CurrentVM.HSyncWidth = ((WORD)(uc2&0x1)<<8) | (WORD)uc1;
    s_CurrentVM.HFrontPorch = ((WORD)(uc2 & 0xf0)<<4) | (WORD)uc3 ;
    s_CurrentVM.HBackPorch = s_CurrentVM.HTotal - s_CurrentVM.HActive - s_CurrentVM.HSyncWidth - s_CurrentVM.HFrontPorch ;
    
    uc1 = HDMIRX_ReadI2C_Byte(REG_RX_VID_VTOTAL_L) ; 
    uc2 = HDMIRX_ReadI2C_Byte(REG_RX_VID_VTOTAL_H) ; 
    uc3 = HDMIRX_ReadI2C_Byte(REG_RX_VID_VACT_L) ; 

    s_CurrentVM.VTotal = ((WORD)(uc2&0x7)<<8) | (WORD)uc1;
    s_CurrentVM.VActive = ((WORD)(uc2 & 0x30)<<4) | (WORD)uc3 ;
    if( (s_CurrentVM.VActive | (1<<10)) <s_CurrentVM.VTotal )
    {
        s_CurrentVM.VActive |= (1<<10) ;
    }
    
    s_CurrentVM.VBackPorch = HDMIRX_ReadI2C_Byte(REG_RX_VID_VSYNC2DE) ; 
    s_CurrentVM.VFrontPorch = HDMIRX_ReadI2C_Byte(REG_RX_VID_V_FT_PORCH) ; 
    s_CurrentVM.VSyncWidth = 0 ;
    
    s_CurrentVM.ScanMode = (HDMIRX_ReadI2C_Byte(REG_RX_VID_MODE)&B_INTERLACE)?INTERLACE:PROG ;
    
    s_CurrentVM.xCnt = HDMIRX_ReadI2C_Byte(REG_RX_VID_XTALCNT_128PEL) ;
    
    if(  s_CurrentVM.xCnt )
    {
        s_CurrentVM.PCLK = 128L * 27000L / s_CurrentVM.xCnt ;
    }
    else
    {
        ErrorF("s_CurrentVM.xCnt == %02x\n",s_CurrentVM.xCnt) ;
        s_CurrentVM.PCLK = 1234 ;
        for( i = 0x58 ; i < 0x66 ; i++ )
        {
            ErrorF("HDMIRX_ReadI2C_Byte(%02x) = %02X\n",i,HDMIRX_ReadI2C_Byte(i)) ;
        }
        return FALSE ;
    }

    //ErrorF("Current Get: ") ; DumpSyncInfo(&s_CurrentVM) ;
    // ErrorF("Matched %d Result in loop 1: ", i) ; DumpSyncInfo(pVTiming) ;
    // return TRUE ;
    for( i = 0 ; i < SizeofVMTable ; i++ )
    {
        // 2006/10/17 modified by jjtseng
        // Compare PCLK in 3% difference instead of comparing xCnt

        // diff = (long)s_VMTable[i].xCnt - (long)s_CurrentVM.xCnt ;
        // if( abs(diff) > 1 )
        // {
        //     continue ;
        // }
        //~jjtseng 2006/10/17
        
        diff = abs(s_VMTable[i].PCLK - s_CurrentVM.PCLK) ;
        diff *= 100 ;
        diff /= s_VMTable[i].PCLK ;
        
        if( diff > 3 )
        {
            // over 3%
            continue ;
        }
        
        if( s_VMTable[i].HActive != s_CurrentVM.HActive )
        {
            continue ;
        }
        
        //if( s_VMTable[i].VActive != s_CurrentVM.VActive )
        //{
        //    continue ;
        //}
        
        diff = (long)s_VMTable[i].HTotal - (long)s_CurrentVM.HTotal ;
        if( abs(diff)>4)
        {
            continue ;
        }
        
        diff = (long)s_VMTable[i].VActive - (long)s_CurrentVM.VActive ;
        if( abs(diff)>10)
        {
            continue ;
        }
        
        diff = (long)s_VMTable[i].VTotal - (long)s_CurrentVM.VTotal ;
        if( abs(diff)>40)
        {
            continue ;
        }

        if( s_VMTable[i].ScanMode != s_CurrentVM.ScanMode )
        {
            continue ;
        } 
        
        pVTiming = s_VMTable+i ;
        // ErrorF("Matched %d Result in loop 1: ", i) ; DumpSyncInfo(pVTiming) ;
        return TRUE ;
    }    
    

    for( i = 0 ; i < SizeofVMTable ; i++ )
    {
        // 2006/10/17 modified by jjtseng
        // Compare PCLK in 3% difference instead of comparing xCnt

        // diff = (long)s_VMTable[i].xCnt - (long)s_CurrentVM.xCnt ;
        // if( abs(diff) > 1 )
        // {
        //     continue ;
        // }
        //~jjtseng 2006/10/17
        
        diff = abs(s_VMTable[i].PCLK - s_CurrentVM.PCLK) ;
        diff *= 100 ;
        diff /= s_VMTable[i].PCLK ;
        
        if( diff > 3 )
        {
            // over 3%
            continue ;
        }
        
        if( s_VMTable[i].HActive != s_CurrentVM.HActive )
        {
            continue ;
        }
        
        //if( s_VMTable[i].VActive != s_CurrentVM.VActive )
        //{
        //    continue ;
        //}
        
        diff = (long)s_VMTable[i].HTotal - (long)s_CurrentVM.HTotal ;
        if( abs(diff)>4)
        {
            continue ;
        }
        
        diff = (long)s_VMTable[i].VActive - (long)s_CurrentVM.VActive ;
        if( abs(diff)>10)
        {
            continue ;
        }
        
        diff = (long)s_VMTable[i].VTotal - (long)s_CurrentVM.VTotal ;
        if( abs(diff)>40)
        {
            continue ;
        }
        pVTiming = s_VMTable+i ;
        // ErrorF("Matched %d Result in loop 2: ", i) ; DumpSyncInfo(pVTiming) ;
        return TRUE ;
    }    
    
    return FALSE ;
}


#define SIZE_OF_CSCOFFSET (REG_RX_CSC_RGBOFF - REG_RX_CSC_YOFF + 1)
#define SIZE_OF_CSCMTX  (REG_RX_CSC_MTX33_H - REG_RX_CSC_MTX11_L + 1)
#define SIZE_OF_CSCGAIN (REG_RX_CSC_GAIN3V_H - REG_RX_CSC_GAIN1V_L + 1)

///////////////////////////////////////////////////////////
// video.h
///////////////////////////////////////////////////////////
void
Video_Handler()
{
    // SYNC_INFO SyncInfo, NewSyncInfo ;
    BOOL bHDMIMode;
    // BYTE uc ;

    if(VState == VSTATE_ModeDetecting)
    {
        ErrorF("Video_Handler, VState = VSTATE_ModeDetecting.\n") ;
        // ErrorF("Video Mode Detecting ... , REG_RX_RST_CTRL = %02X -> ",HDMIRX_ReadI2C_Byte(REG_RX_RST_CTRL)) ;
        // HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL,HDMIRX_ReadI2C_Byte(REG_RX_RST_CTRL) & ~B_HDCPRST) ; 
        // ErrorF("%02X\n",HDMIRX_ReadI2C_Byte(REG_RX_RST_CTRL)) ;
        ClearIntFlags(B_CLR_MODE_INT) ;
        
        if(!bGetSyncInfo())
        {
            //OS_PRINTF("[RX] Failed to bGetSyncInfo (%d), VState->VSTATE_SyncWait \n", bGetSyncFailCount); 
            ErrorF("Current Get: ") ; DumpSyncInfo(&s_CurrentVM) ;
            
            SwitchVideoState(VSTATE_SyncWait) ;
            bGetSyncFailCount ++ ;
            ErrorF("bGetSyncInfo() fail, bGetSyncFailCount = %d ", bGetSyncFailCount) ;
            if( bGetSyncFailCount % 32 == 31 )
            {
                //OS_PRINTF("Failed to bGetSyncInfo, SWReset\n");
                ErrorF(" called SWReset\n") ;
                SWReset_HDMIRX() ;
            }
            else if( bGetSyncFailCount % 8 == 7)
            {
                //OS_PRINTF("Failed to bGetSyncInfo, reset video\n");
                ErrorF(" reset video.\n") ;
                
                HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, B_VDORST ) ;
                DelayMS(1) ;
                HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, 0) ;

            }
            else
            {
                ErrorF("\n") ;
            }
            return ;            
        }
        else
        {
            ErrorF("Current Get:    ") ; DumpSyncInfo(&s_CurrentVM) ;
            ErrorF("Matched Result: ") ; DumpSyncInfo(pVTiming) ;
            bGetSyncFailCount = 0 ;
        }
        
        SetDefaultRegisterValue() ;

        bHDMIMode = IsIT6605HDMIMode() ;
        
        if(!bHDMIMode)
        {
            // DVI Mode.
            ErrorF("This is DVI Mode.\n") ;            
            NewAVIInfoFrameF = FALSE ;
        }

        // GetSyncInfo(&NewSyncInfo) ;
        
        // if(CompareSyncInfo(&NewSyncInfo,&SyncInfo))
        
        if( HDMIRX_ReadI2C_Byte(REG_RX_INTERRUPT1) & (B_VIDMODE_CHG|B_SCDTOFF|B_PWR5VOFF))
        {
            SwitchVideoState(VSTATE_SyncWait) ;
            // SwitchAudioState(ASTATE_AudioOff) ; // SwitchVideoState will switch audio state to AudioOff if any non VideoOn mode.
        }
        else
        {
            // HDCP_Reset() ; // even though in DVI mode, Tx also can set HDCP.

            SwitchVideoState(VSTATE_VideoOn) ;
        }
        
        return ;
    }
}

static void
SetVideoInputFormatWithoutInfoFrame(BYTE bInMode)
{
    BYTE uc ;

    // ErrorF("SetVideoInputFormat: NewAVIInfoFrameF = %s, bInMode = %d",(NewAVIInfoFrameF==TRUE)?"TRUE":"FALSE",bInMode) ;
    // only set force input color mode selection under no AVI Info Frame case
    uc = HDMIRX_ReadI2C_Byte(REG_RX_CSC_CTRL) ;
    uc |= B_FORCE_COLOR_MODE ;
    bInputVideoMode &= ~F_MODE_CLRMOD_MASK ;
    // bInputVideoMode |= (bInMode)&F_MODE_CLRMOD_MASK ;
    
    switch(bInMode)
    {
    case F_MODE_YUV444:
        uc &= ~(M_INPUT_COLOR_MASK<<O_INPUT_COLOR_MODE) ;
        uc |= B_INPUT_YUV444 << O_INPUT_COLOR_MODE ;
        bInputVideoMode |= F_MODE_YUV444 ;
        break ;
    case F_MODE_YUV422:
        uc &= ~(M_INPUT_COLOR_MASK<<O_INPUT_COLOR_MODE) ;
        uc |= B_INPUT_YUV422 << O_INPUT_COLOR_MODE ;
        bInputVideoMode |= F_MODE_YUV422 ;
        break ;
    case F_MODE_RGB24:
        uc &= ~(M_INPUT_COLOR_MASK<<O_INPUT_COLOR_MODE) ;
        uc |= B_INPUT_RGB24 << O_INPUT_COLOR_MODE ;
        bInputVideoMode |= F_MODE_RGB24 ;
        break ;
    default:
        ErrorF("Invalid Color mode %d, ignore.\n", bInMode) ;
        return ;
    }
    HDMIRX_WriteI2C_Byte(REG_RX_CSC_CTRL, uc) ;

}

static void
SetColorimetryByMode(/*PSYNC_INFO pSyncInfo*/)
{
    // USHORT HRes, VRes ;
    bInputVideoMode &= ~F_MODE_ITU709 ; 
    // HRes = pVTiming->HActive ;
    // VRes = pVTiming->VActive ;
    // VRes *= ( pSyncInfo->Mode & F_MODE_INTERLACE )?2:1 ;
    if( pVTiming == NULL ) 
    {
        return ;
    }
    if((pVTiming->HActive == 1920)||(pVTiming->HActive == 1280 && pVTiming->VActive == 720) )
    {
        // only 1080p, 1080i, and 720p use ITU 709
        bInputVideoMode |= F_MODE_ITU709 ;
    }
    else
    {
        // 480i,480p,576i,576p,and PC mode use 601
        bInputVideoMode &= ~F_MODE_ITU709 ; // set mode as ITU601
    }
}

void
SetVideoInputFormatWithInfoFrame()
{
    BYTE uc ;
    BOOL bAVIColorModeIndicated = FALSE ;
    BOOL bOldInputVideoMode = bInputVideoMode ;
    
    ErrorF("SetVideoInputFormatWithInfoFrame(): ") ;

    uc = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB1) ;
    ErrorF("REG_RX_AVI_DB1 %02X get uc %02X ",REG_RX_AVI_DB1,uc) ;
    bInputVideoMode &= ~F_MODE_CLRMOD_MASK ;
    
    switch((uc>>O_AVI_COLOR_MODE)&M_AVI_COLOR_MASK)
    {
    case B_AVI_COLOR_YUV444:
        ErrorF("input YUV444 mode ") ;
        bInputVideoMode |= F_MODE_YUV444 ;
        break ;
    case B_AVI_COLOR_YUV422:
        ErrorF("input YUV422 mode ") ;
        bInputVideoMode |= F_MODE_YUV422 ;        
        break ; 
    case B_AVI_COLOR_RGB24:
        ErrorF("input RGB24 mode ") ;
        bInputVideoMode |= F_MODE_RGB24 ;        
        break ; 
    default:
        ErrorF("Invalid input color mode, ignore.\n") ;
        return ; // do nothing.
    }
    
    if( (bInputVideoMode & F_MODE_CLRMOD_MASK)!=(bOldInputVideoMode & F_MODE_CLRMOD_MASK))
    {
        ErrorF("Input Video mode changed.") ;
    }
    
    uc = HDMIRX_ReadI2C_Byte(REG_RX_CSC_CTRL) ;
    uc &= ~B_FORCE_COLOR_MODE ; // color mode indicated by Info Frame.
    HDMIRX_WriteI2C_Byte(REG_RX_CSC_CTRL, uc) ;

    ErrorF("\n") ;
}

BOOL
SetColorimetryByInfoFrame()
{
    BYTE uc ;
    BOOL bOldInputVideoMode = bInputVideoMode ;
    
    ErrorF("SetColorimetryByInfoFrame: NewAVIInfoFrameF = %s ",NewAVIInfoFrameF?"TRUE":"FALSE") ;

    if(NewAVIInfoFrameF)
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB2) ;
        uc &= M_AVI_CLRMET_MASK<<O_AVI_CLRMET ;
        if(uc == (B_AVI_CLRMET_ITU601<<O_AVI_CLRMET))
        {
            ErrorF("F_MODE_ITU601\n") ;
            bInputVideoMode &= ~F_MODE_ITU709 ;
            return TRUE ;
        }
        else if(uc == (B_AVI_CLRMET_ITU709<<O_AVI_CLRMET))
        {
            ErrorF("F_MODE_ITU709\n") ;
            bInputVideoMode |= F_MODE_ITU709 ;
            return TRUE ;
        }
        // if no uc, ignore
        if( (bInputVideoMode & F_MODE_ITU709)!=(bOldInputVideoMode & F_MODE_ITU709))
        {
            ErrorF("Input Video mode changed.") ;
            // SetVideoMUTE(ON) ; // turned off Video for input color format change .
        }
    }
    ErrorF("\n") ;
    return FALSE ;
}

void
SetColorSpaceConvert()
{
    BYTE uc, csc ;
    BYTE filter = 0 ; // filter is for Video CTRL DN_FREE_GO, EN_DITHER, and ENUDFILT

    // ErrorF("Input mode is YUV444 ") ;
    switch(bOutputVideoMode&F_MODE_CLRMOD_MASK)
    {
    #ifdef OUTPUT_YUV444
    case F_MODE_YUV444:
        // ErrorF("Output mode is YUV444\n") ;
        switch(bInputVideoMode&F_MODE_CLRMOD_MASK)
        {
        case F_MODE_YUV444:
            // ErrorF("Input mode is YUV444\n") ;
            csc = B_CSC_BYPASS ;
            break ;
        case F_MODE_YUV422:
            // ErrorF("Input mode is YUV422\n") ;
            csc = B_CSC_BYPASS ;
            if( bOutputVideoMode & F_MODE_EN_UDFILT) // RGB24 to YUV422 need up/dn filter.
            {
                filter |= B_RX_EN_UDFILTER ;
            }

            if( bOutputVideoMode & F_MODE_EN_DITHER) // RGB24 to YUV422 need up/dn filter.
            {
                filter |= B_RX_EN_UDFILTER | B_RX_DNFREE_GO ;
            }

            break ;
        case F_MODE_RGB24:
            // ErrorF("Input mode is RGB444\n") ;
            csc = B_CSC_RGB2YUV ;
            break ;
        }
        break ;
    #endif // OUTPUT_YUV444
    #ifdef OUTPUT_YUV422
    case F_MODE_YUV422:
        switch(bInputVideoMode&F_MODE_CLRMOD_MASK)
        {
        case F_MODE_YUV444:
            // ErrorF("Input mode is YUV444\n") ;
            if( bOutputVideoMode & F_MODE_EN_UDFILT)
            {
                filter |= B_RX_EN_UDFILTER ;
            }
            csc = B_CSC_BYPASS ;
            break ;
        case F_MODE_YUV422:
            // ErrorF("Input mode is YUV422\n") ;
            csc = B_CSC_BYPASS ;

            // if output is YUV422 and 16 bit or 565, then the dither is possible when
            // the input is YUV422 with 24bit input, however, the dither should be selected
            // by customer, thus the requirement should set in ROM, no need to check
            // the register value .
            if( bOutputVideoMode & F_MODE_EN_DITHER) // RGB24 to YUV422 need up/dn filter.
            {
                filter |= B_RX_EN_UDFILTER | B_RX_DNFREE_GO ;
            }
            break ;
        case F_MODE_RGB24:
            // ErrorF("Input mode is RGB444\n") ;
            if( bOutputVideoMode & F_MODE_EN_UDFILT) // RGB24 to YUV422 need up/dn filter.
            {
                filter |= B_RX_EN_UDFILTER ;
            }
            csc = B_CSC_RGB2YUV ;
            break ;
        }
        break ;
    #endif // OUTPUT_YUV422
    #ifdef OUTPUT_RGB444 
    case F_MODE_RGB24:
        // ErrorF("Output mode is RGB24\n") ;
        switch(bInputVideoMode&F_MODE_CLRMOD_MASK)
        {
        case F_MODE_YUV444:
            // ErrorF("Input mode is YUV444\n") ;
            csc = B_CSC_YUV2RGB ;
            break ;
        case F_MODE_YUV422:
            // ErrorF("Input mode is YUV422\n") ;
            csc = B_CSC_YUV2RGB ;
            if( bOutputVideoMode & F_MODE_EN_UDFILT) // RGB24 to YUV422 need up/dn filter.
            {
                filter |= B_RX_EN_UDFILTER ;
            }
            if( bOutputVideoMode & F_MODE_EN_DITHER) // RGB24 to YUV422 need up/dn filter.
            {
                filter |= B_RX_EN_UDFILTER | B_RX_DNFREE_GO ;
            }
            break ;
        case F_MODE_RGB24:
            // ErrorF("Input mode is RGB444\n") ;
            csc = B_CSC_BYPASS ;
            break ;
        }
        break ;
    #endif // OUTPUT_RGB444
    }
   

    #ifdef OUTPUT_YUV
    // set the CSC associated registers
    if( csc == B_CSC_RGB2YUV )
    {
        // ErrorF("CSC = RGB2YUV ") ;
        if(bInputVideoMode & F_MODE_ITU709)
        {
            ErrorF("ITU709 ") ;

            if(bInputVideoMode & F_MODE_16_235)
            {
                ErrorF(" 16-235\n") ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_16_235,sizeof(bCSCOffset_16_235)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_RGB2YUV_ITU709_16_235,sizeof(bCSCMtx_RGB2YUV_ITU709_16_235)) ;
            }
            else
            {
                ErrorF(" 0-255\n") ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_0_255,sizeof(bCSCOffset_0_255)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_RGB2YUV_ITU709_0_255,sizeof(bCSCMtx_RGB2YUV_ITU709_0_255)) ;
            }
        }
        else
        {
            ErrorF("ITU601 ") ;
            if(bInputVideoMode & F_MODE_16_235)
            {
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_16_235,sizeof(bCSCOffset_16_235)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_RGB2YUV_ITU601_16_235,sizeof(bCSCMtx_RGB2YUV_ITU601_16_235)) ;
                ErrorF(" 16-235\n") ;
            }
            else
            {
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_0_255,sizeof(bCSCOffset_0_255)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_RGB2YUV_ITU601_0_255,sizeof(bCSCMtx_RGB2YUV_ITU601_0_255)) ;
                ErrorF(" 0-255\n") ;
            }
        }
    }
    #endif // OUTPUT_YUV

    #ifdef OUTPUT_RGB
    if ( csc == B_CSC_YUV2RGB )
    {
        ErrorF("CSC = YUV2RGB ") ;
        if(bInputVideoMode & F_MODE_ITU709)
        {
            ErrorF("ITU709 ") ;
            if(bOutputVideoMode & F_MODE_16_235)
            {
                ErrorF("16-235\n") ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_16_235,sizeof(bCSCOffset_16_235)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_YUV2RGB_ITU709_16_235,sizeof(bCSCMtx_YUV2RGB_ITU709_16_235)) ;
            }
            else
            {
                ErrorF("0-255\n") ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_0_255,sizeof(bCSCOffset_0_255)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_YUV2RGB_ITU709_0_255,sizeof(bCSCMtx_YUV2RGB_ITU709_0_255)) ;
            }
        }
        else
        {
            ErrorF("ITU601 ") ;
            if(bOutputVideoMode & F_MODE_16_235)
            {
                ErrorF("16-235\n") ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_16_235,sizeof(bCSCOffset_16_235)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_YUV2RGB_ITU601_16_235,sizeof(bCSCMtx_YUV2RGB_ITU601_16_235)) ;
            }
            else
            {
                ErrorF("0-255\n") ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_YOFF,bCSCOffset_0_255,sizeof(bCSCOffset_0_255)) ;
                HDMIRX_WriteI2C_ByteN(REG_RX_CSC_MTX11_L,bCSCMtx_YUV2RGB_ITU601_0_255,sizeof(bCSCMtx_YUV2RGB_ITU601_0_255)) ;
            }
        }

    }
    #endif // OUTPUT_RGB


    uc = HDMIRX_ReadI2C_Byte(REG_RX_CSC_CTRL) ;
    uc = (uc & ~M_CSC_SEL_MASK)|csc ;
    HDMIRX_WriteI2C_Byte(REG_RX_CSC_CTRL,uc) ;

    // set output Up/Down Filter, Dither control

    uc = HDMIRX_ReadI2C_Byte(REG_RX_VIDEO_CTRL1) ;
    uc &= ~(B_RX_DNFREE_GO|B_RX_EN_DITHER|B_RX_EN_UDFILTER) ;
    uc |= filter ;
    HDMIRX_WriteI2C_Byte(REG_RX_VIDEO_CTRL1, uc) ;
}


void
SetDVIVideoOutput()
{
    // SYNC_INFO SyncInfo ;
    // GetSyncInfo(&SyncInfo) ;
    SetVideoInputFormatWithoutInfoFrame(F_MODE_RGB24) ;
    SetColorimetryByMode(/*&SyncInfo*/) ;
    SetColorSpaceConvert() ;
}

void
SetNewInfoVideoOutput()
{
    BYTE db1,db2,db3 ;
    
    do {
        DelayMS(10) ;
        db1 = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB1) ;
        DelayMS(10) ;
        db2 = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB1) ;
        DelayMS(10) ;
        db3 = HDMIRX_ReadI2C_Byte(REG_RX_AVI_DB1) ;
        ErrorF("SetNewInfoVideoOutput(): %02X %02X %02X\n",db1,db2,db3) ;
    } while ( (db1 != db2)||(db2!=db3)) ;
    
    SetVideoInputFormatWithInfoFrame() ;
    SetColorimetryByInfoFrame() ;
    SetColorSpaceConvert() ;
}


///////////////////////////////////////////////////////////
// Audio Function
///////////////////////////////////////////////////////////


void
ResetAudio() 
{
    // 2007/04/02 modified by jjtseng
    //This issue has clarified, This is Audio H/W issue when source is on
    //1080P@60Hz, and Audio sample freq is 32K/44.1K/48K, and this issue
    //can using following S/W setting to work-around, so please all of you can
    //implement in all IT6605 platforms include Splitter solution. Thanks!
    // 
    //1. After mode detect ready
    //2. if mode= 1080p@60Hz and Audio Fs = 32k or 44.1K or 48K(Reg0x84)
    //    if not, jump to step-7.
    //3. before Turn on Audio, set Reg0x78=41 ( default is C1)
    //    (this setting will cause Audio H/W mute, so need reset Audio as following)
    //4. reset Audio, Reg0x05=04 => delay 100ms => Reg0x05=00
    //5. Set Reg0x78=49
    //6. Turn on Audio I/O. (Reg0x89)
    // 
    //7. reset Audio, Reg0x05=04 => delay 1ms => Reg0x05=00
    //8 Turn on Audio I/O. (Reg0x89)
    
    // BYTE reg ;
    // BOOL bFixedAudio = FALSE ;
    // WORD hTotal, hActive ;
    // 
    // if( HDMIRX_ReadI2C_Byte(REG_RX_VID_XTALCNT_128PEL) < 0x20 )
    // {
    //     // clock > 108MHz
    //     reg = HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_H) ;
    //     hTotal = (WORD)(reg&0xF)<<8 ; // hTotal[11:8] 
    //     hActive = (WORD)(reg&0x70)<<4 ; // hActive[10:8]
    //     hTotal |= (WORD)HDMIRX_ReadI2C_Byte(REG_RX_VID_HTOTAL_L) ;
    //     hActive |= (WORD)HDMIRX_ReadI2C_Byte(REG_RX_VID_HACT_L) ;
    //     if( hTotal == 2200 && hActive == 1920 )
    //     {
    //         // xCnt < 0x20 , hTotal == 2200, and hActive == 1920
    //         // should be 1080p60
    //         reg = HDMIRX_ReadI2C_Byte(REG_RX_FS) & 0xF ; // only 48KHz, 44.1KHz, or 32KHz
    //         
    //         if((reg == B_Fs_32KHz)||(reg == B_Fs_44p1KHz)||(reg == B_Fs_48KHz))
    //         {
    //             bFixedAudio = TRUE ;
    //         }
    //     }
    // }
    // 
    // if( bFixedAudio )
    // {
    //     HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL, 0x41) ;
    // }
    // else
    // {
    //     HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL, 0xC1) ;
    // }
    // 

    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, B_AUDRST) ;
    DelayMS(1) ; 
    HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL, 0) ;

    // if( bFixedAudio )
    // {
    //     HDMIRX_WriteI2C_Byte(REG_RX_MCLK_CTRL, 0x49) ;
    // }
}

void
SetHWMuteCTRL(BYTE AndMask, BYTE OrMask)
{
    BYTE uc ;
    
    if( AndMask )
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_HWMUTE_CTRL) ;
    }
    uc &= AndMask ;
    uc |= OrMask ;
    HDMIRX_WriteI2C_Byte(REG_RX_HWMUTE_CTRL,uc) ;
    
}

void
SetVideoMUTE(BOOL bMute)
{
    BYTE uc ;
    if( bMute )
    {
        uc = HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
        uc |= B_TRI_VIDEO | B_TRI_VIDEOIO ;
        HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;
    }
    else
    {
        if( VState == VSTATE_VideoOn )
        {
            uc = HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
            uc &= ~(B_TRI_VIDEO | B_TRI_VIDEOIO) ;
            if(HDMIRX_ReadI2C_Byte(REG_RX_VID_INPUT_ST)&B_AVMUTE)
            {
                uc |= B_VDO_MUTE_DISABLE ;
                HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;
            }
            else
            {
                uc &= ~B_VDO_MUTE_DISABLE ;
                HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;

                // enable video io gatting
                uc = HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL) ;
                uc |= B_TRI_VIDEOIO ;
                HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;
                ErrorF("reg %02X <- %02X = %02X\n",REG_RX_TRISTATE_CTRL,uc, HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL)) ;
                uc &= ~B_TRI_VIDEOIO ;
                HDMIRX_WriteI2C_Byte(REG_RX_TRISTATE_CTRL, uc) ;
                ErrorF("reg %02X <- %02X = %02X\n",REG_RX_TRISTATE_CTRL,uc, HDMIRX_ReadI2C_Byte(REG_RX_TRISTATE_CTRL)) ;
        
                uc = HDMIRX_ReadI2C_Byte(REG_RX_CSC_CTRL) ;     
                uc |= B_VDIO_GATTING ;
                HDMIRX_WriteI2C_Byte(REG_RX_CSC_CTRL, uc) ;
                ErrorF("reg %02X <- %02X = %02X\n",REG_RX_CSC_CTRL,uc, HDMIRX_ReadI2C_Byte(REG_RX_CSC_CTRL)) ;
                uc &= ~B_VDIO_GATTING ;
                HDMIRX_WriteI2C_Byte(REG_RX_CSC_CTRL, uc) ;
                ErrorF("reg %02X <- %02X = %02X\n",REG_RX_CSC_CTRL,uc, HDMIRX_ReadI2C_Byte(REG_RX_CSC_CTRL)) ;
            }

        }
    }
}

void
SetAudioMute(BOOL bMute)
{
    if( bMute )
    {
        SetMUTE(~B_TRI_AUDIO, B_TRI_AUDIO) ;
    }
    else
    {
        // uc = ReadEEPROMByte(EEPROM_AUD_TRISTATE) ;
        // uc &= B_TRI_AUDIO ;
        SetMUTE(~B_TRI_AUDIO, 0) ;
    }
}



void CDR_Reset()
{
    BYTE uc ;

     OS_PRINTF("CDR_RESET, reg10 = %02x\r\n",HDMIRX_ReadI2C_Byte(0x10)) ;


     uc = HDMIRX_ReadI2C_Byte(0x97);
     HDMIRX_WriteI2C_Byte(0x97,uc|0x20);
     //DelayUS(100);
     DelayMS(1);
     HDMIRX_WriteI2C_Byte(0x97,uc&(~0x20));


     uc = HDMIRX_ReadI2C_Byte(REG_RX_RST_CTRL);
     HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL,uc|B_CDRRST | B_SWRST);
     //DelayUS(100);
     DelayMS(1);
     HDMIRX_WriteI2C_Byte(REG_RX_RST_CTRL,uc&(~(B_CDRRST| B_SWRST)));


     uc = HDMIRX_ReadI2C_Byte(REG_CDEPTH_CTRL);

     HDMIRX_WriteI2C_Byte(REG_CDEPTH_CTRL,uc|B_RSTCD); 
     //DelayUS(100);
     DelayMS(1);
     HDMIRX_WriteI2C_Byte(REG_CDEPTH_CTRL,uc&(~B_RSTCD));
        
    AcceptCDRReset = FALSE ;
}


