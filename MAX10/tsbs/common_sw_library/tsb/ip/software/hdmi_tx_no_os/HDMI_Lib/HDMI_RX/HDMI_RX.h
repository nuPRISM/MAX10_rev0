#ifndef HDMI_RX_H_
#define HDMI_RX_H_

#include "HDMI_COMMON.h"

typedef enum{
    EDID_1280x1024 = 0
}EDID_TYPE;


typedef enum{
    RX0_EEPROM = 0,
    RX1_EEPROM
}RX_EEPROM_TYPE;


typedef enum{
    RX_PORT_A = 0,
    RX_PORT_B,
    RX_PORT_AUTO
}RX_PORT_CONFIG;


void HDMIRX_EnableEdid(void);

bool HDMIRX_WriteEeprom(RX_EEPROM_TYPE EepromType);
bool HDMIRX_VerifyEeprom(RX_EEPROM_TYPE EepromType);

bool HDMIRX_DevLoopProc(void);
bool HDMIRX_IsVideoOn(void);

bool HDMIRX_Init(RX_PORT_CONFIG PortConfig);
bool HDMIRX_ChipVerify(void);
bool HDMIRX_GetAVIInfoFrame(alt_u8 *pVIC, alt_u8 *pColorMode, bool *pb16x9, bool *pITU709);
bool HDMIRX_IsModeChange(void);
bool HDMIRX_GetSourceColor(int *pnColorMode);
void HDMIRX_SetOutputColor(COLOR_TYPE OutputColor);

#endif /*HDMI_RX_H_*/
