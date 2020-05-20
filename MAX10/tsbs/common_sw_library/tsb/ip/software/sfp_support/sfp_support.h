/*
 * sfp_support.h
 *
 *  Created on: May 26, 2014
 *      Author: yairlinn
 */

#ifndef SFP_SUPPORT_H_
#define SFP_SUPPORT_H_


// TSE Register Offsets (General)

#define TSE_REV                    0x00000000
#define TSE_CMD_CONFIG             0x00000008
#define TSE_MAC_0                  0x0000000C
#define TSE_MAC_1                  0x00000010
#define TSE_FRM_LENGTH             0x00000014
#define TSE_RX_SECTION_EMPTY       0x0000001C
#define TSE_RX_SECTION_FULL        0x00000020
#define TSE_TX_SECTION_EMPTY       0x00000024
#define TSE_TX_SECTION_FULL        0x00000028
#define TSE_RX_ALMOST_EMPTY        0x0000002C
#define TSE_RX_ALMOST_FULL         0x00000030
#define TSE_TX_ALMOST_EMPTY        0x00000034
#define TSE_TX_ALMOST_FULL         0x00000038
#define TSE_TX_IPG_LENGTH          0x0000005C


// SFP Module PHY Registers Definition

#define SFP_PHY_CONTROL                 0x00
#define SFP_PHY_STATUS                  0x01
#define SFP_PHY_ID0                     0x02
#define SFP_PHY_ID1                     0x03
#define SFP_PHY_AUTONEG_ADVERTISEMENT   0x04
#define SFP_PHY_LINK_PARTNER_ABILITY    0x05
#define SFP_PHY_1000BASET_CONTROL       0x09
#define SFP_PHY_PHY_SPECIFIC_STAT       0x11
#define SFP_PHY_EXT_PHY_SPECIFIC_STAT   0x1B

typedef void (*sfp_reg_write_function_type)(void *additional_data, int reg_addr,int val);
typedef int (*sfp_reg_read_function_type)(void *additional_data, int reg_addr);

void sfp_support_setup_params(
		unsigned long the_tse_mac_base,
		void *the_additional_data,
		sfp_reg_write_function_type the_sfp_write_func,
		sfp_reg_read_function_type the_sfp_read_func);

int tseSfpConfigureLink(unsigned int speed, unsigned int duplex, unsigned long long timeout_baset, unsigned long long timeout_basex);
void tseSfpConfigureMAC(unsigned int speed, unsigned int duplex);


#endif /* SFP_SUPPORT_H_ */
