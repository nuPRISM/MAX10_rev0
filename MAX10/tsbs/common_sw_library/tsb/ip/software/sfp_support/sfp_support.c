
#include "sfp_support.h"
#include "basedef.h"
#include "cpp_to_c_header_interface.h"
#include <stdio.h>
#include "io.h"

static unsigned long tse_mac_base = 0;
static sfp_reg_write_function_type sfp_reg_write = NULL;
static sfp_reg_read_function_type sfp_reg_read = NULL;
static void *additional_data = NULL;
#define dprintf(args...) do { if (DEBUG_SFP_SUPPORT) { printf(args); } } while (0)

void sfp_support_setup_params(
		                      unsigned long the_tse_mac_base,
							  void *the_additional_data,
		                      sfp_reg_write_function_type the_sfp_write_func,
		                      sfp_reg_read_function_type the_sfp_read_func

		                      )
{
	tse_mac_base = the_tse_mac_base;
	sfp_reg_write = the_sfp_write_func;
	sfp_reg_read = the_sfp_read_func;
    additional_data = the_additional_data;
}


int sfp_config (int register4, int register9, unsigned long long timeout_baset, unsigned long long timeout_basex )
{
    int status;
    int readdata;

    if (!NICHESTACK_ETHERNET_IS_SFP) {
    	printf("Ethernet is not SFP, sfp_config is doing nothing\n");
        return TRUE;
    }
    unsigned long long end_time, start_time;
    unsigned long long total_runtime;
    char start_TS[50],end_TS[50],total_TS[50];


    if ((sfp_reg_read == NULL) || (sfp_reg_write == NULL)) {
       printf("[sfp_config] Error: sfp_reg_read = %d  sfp_reg_write = %d\n", (int) sfp_reg_read, (int) sfp_reg_write );
       return TRUE;
    }
    // ===================================================
    // Configure the SFP Module to Auto-Neg at selected mode
    // ===================================================

    sfp_reg_write (additional_data,SFP_PHY_EXT_PHY_SPECIFIC_STAT, 0x9084);
    sfp_reg_write (additional_data,SFP_PHY_CONTROL, 0x9140);
    sfp_reg_write (additional_data,SFP_PHY_1000BASET_CONTROL, register9);
    sfp_reg_write (additional_data,SFP_PHY_AUTONEG_ADVERTISEMENT, register4);
    sfp_reg_write (additional_data,SFP_PHY_CONTROL, 0x9140);


    status = 0x0;
    start_time=c_os_critical_low_level_system_timestamp();
    while (!(status & 0x4)) {
        status = sfp_reg_read (additional_data,SFP_PHY_STATUS);
        dprintf("[sfp_config]Waiting for SFP PHY Status & 0x4, got 0x%x \n",status);
        end_time=c_os_critical_low_level_system_timestamp(); if (start_time > end_time) { /* in case of some weird timer wrap */ start_time = end_time; }
        total_runtime = (end_time - start_time);
        if (total_runtime > timeout_baset )
        {
          c_convert_ull_to_string(start_time,start_TS);
          c_convert_ull_to_string(end_time,end_TS);
          c_convert_ull_to_string(total_runtime,total_TS);
          printf("\n[sfp_config][TS_Sec=%lu] Timed out waiting for  1000BASE-T AUTO_NEG! start=%s end = %s total=%s\n",os_critical_c_low_level_system_timestamp_in_secs(),start_TS,end_TS,total_TS);
          return FALSE;
        }
        usleep(1000000);
    };

    dprintf("[sfp_config] 1000BASE-T AUTO_NEG DONE! \n");

    // ===================================================
    // Configure registers to SGMII
    // ===================================================
    IOWR_32DIRECT(tse_mac_base, TSE_PCS_CONTROL, 0x00001200);

    // Poll TSE0 PCS Status register to see if Link_Up
	dprintf("[sfp_config] waiting for link ...\n");
    status = 0x0;
    readdata = 0;
    start_time=c_os_critical_low_level_system_timestamp();
    while (!(status & 0x20))
    {
       status = IORD_32DIRECT(tse_mac_base, TSE_PCS_STATUS);
       dprintf("[sfp_config]Waiting for TSE PHY Status & 0x20 , got 0x%x \n",status);
       dprintf("[sfp_config]Waiting for SFP PHY Status & 0x4, got 0x%x \n",status);
       end_time=c_os_critical_low_level_system_timestamp(); if (start_time > end_time) { /* in case of some weird timer wrap */ start_time = end_time; }
       total_runtime = (end_time - start_time);
       if (total_runtime > timeout_basex)
       {
         c_convert_ull_to_string(start_time,start_TS);
         c_convert_ull_to_string(end_time,end_TS);
         c_convert_ull_to_string(total_runtime,total_TS);
         printf("\n[sfp_config][TS_Sec=%lu] Timed out waiting for  1000BASE-X AUTO_NEG! start=%s end = %s total=%s\n",os_critical_c_low_level_system_timestamp_in_secs(),start_TS,end_TS,total_TS);
         return FALSE;
       }
       usleep(1000000);
    };
    readdata = IORD_32DIRECT(tse_mac_base, TSE_PCS_PARTNER_ABILITY);

    dprintf("[sfp_config] TSE PCS -- LINK PARTNER ABILITY => 0x%x\n", readdata);
    dprintf("1000BASE-X AUTO_NEG DONE! :) \n\n");

    return TRUE;

}


void restartPCSAutonegotiation() {
    IOWR_32DIRECT(tse_mac_base, TSE_PCS_CONTROL, 0x00001300);
}

void deIsolatePCSFromMAC() {
    IOWR_32DIRECT(tse_mac_base, TSE_PCS_CONTROL, 0);
}
void tseSfpConfigureMAC(unsigned int speed, unsigned int duplex)
{

    int cmd_config;
    if ((speed == 100)&&(duplex==1))
    {
        cmd_config = 0x00000223;
    }
    else if ((speed == 100)&&(duplex==FALSE))
    {
        cmd_config = 0x00000623;
    }
    else if ((speed == 10)&&(duplex==TRUE))
    {
        cmd_config = 0x02000223;

    }
    else if ((speed == 10)&&(duplex==FALSE))
    {
        cmd_config = 0x02000623;
    }
    else //((speed == 1000)
    {
        cmd_config = 0x0000022B;
    }

    IOWR_32DIRECT(tse_mac_base, TSE_CMD_CONFIG, cmd_config);
}



int tseSfpConfigureLink(unsigned int speed, unsigned int duplex, unsigned long long timeout_baset, unsigned long long timeout_basex )
{

    int reg4, reg9, cmd_config;
    int success;

    if ((speed == 100)&&(duplex==1))
    {
        reg4 = 0x0D01;
        reg9 = 0x0C00;
    }
    else if ((speed == 100)&&(duplex==FALSE))
    {
        reg4 = 0x0C81;
        reg9 = 0x0C00;
    }
    else if ((speed == 10)&&(duplex==TRUE))
    {
        reg4 = 0x0C41;
        reg9 = 0x0C00;

    }
    else if ((speed == 10)&&(duplex==FALSE))
    {
        reg4 = 0x0C21;
        reg9 = 0x0C00;
    }
    else //((speed == 1000)
    {
        reg4 = 0x0C01;
        reg9 = 0x0E00;
    }

    success = sfp_config (reg4, reg9,timeout_baset,timeout_basex);
    tseSfpConfigureMAC(speed,duplex);

    return success;
}
