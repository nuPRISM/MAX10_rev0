
/******************************************************************************/
/***************************** Include Files **********************************/
/******************************************************************************/
#include "ad9523_driver.h"
#include <cstddef>
#include "xprintf.h"
#include <linnux_utils.h>
/******************************************************************************/

enum ad9523_channels {
	DAC_DEVICE_CLK,
	DAC_DEVICE_SYSREF,
	DAC_FPGA_CLK,
	DAC_FPGA_SYSREF,
	ADC_DEVICE_CLK,
	ADC_DEVICE_SYSREF,
	ADC_FPGA_CLK,
	ADC_FPGA_SYSREF,
};

void ad9523_driver::set_cs_active() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(1);
		    } else {
		    	xprintf("Error: set_cs_active: spi_driver is null! \n");
		    }
	}
void ad9523_driver::set_cs_inactive() {
		 if (spi_driver != NULL) {
			 spi_driver->set_cs_word(0);
		    } else {
		    	xprintf("Error: set_cs_inactive: spi_driver is null! \n");
		    }
	}


int32_t ad9523_driver::ad9523_setup(std::vector<std::pair<unsigned long,unsigned long> > register_address_value_pairs_in_order) {
	int32_t             ret = 0;
    set_cs_inactive();

	 for (unsigned int i=0; i < register_address_value_pairs_in_order.size(); i++) {
		 ad9523_write(register_address_value_pairs_in_order.at(i).first,register_address_value_pairs_in_order.at(i).second);
	  }
    return ret;

}

int32_t ad9523_driver::ad9523_soft_reset()
{
    int32_t             ret = 0;
    set_cs_inactive();
    ad9523_write(0x0,0x81); //soft reset, without it apparently spi writes don't work
    usleep(1000000);
    return ret;
}


void ad9523_driver::ad9523_init()
{
    int32_t             ret = 0;
    set_cs_inactive();
  //  ad9523_write(0x0,0x81); //soft reset, without it apparently spi writes don't work
    /*
   ad9523_write(0x0   ,0x0  );
   ad9523_write(0x1   ,0x0  );
   ad9523_write(0x2   ,0x0  );
   ad9523_write(0x3   ,0x3  );
   ad9523_write(0x4   ,0xDE );
   ad9523_write(0x5   ,0x0  );
   ad9523_write(0x6   ,0x2  );
   ad9523_write(0x8   ,0x3  );
   ad9523_write(0xa   ,0x7  );
   ad9523_write(0xb   ,0x1  );
   ad9523_write(0xc   ,0x56 );
   ad9523_write(0xd   ,0x4  );
   ad9523_write(0xf   ,0x0  );
   ad9523_write(0x3f  ,0x0  );
   ad9523_write(0x40  ,0x3F );
   ad9523_write(0x41  ,0x0  );
   ad9523_write(0x42  ,0xFF );
   ad9523_write(0x108 ,0x0  );
   ad9523_write(0x109 ,0x0  );
   ad9523_write(0x10a ,0x0  );
   ad9523_write(0x10b ,0x0  );
   ad9523_write(0x110 ,0x0  );
   ad9523_write(0x111 ,0x0  );
   ad9523_write(0x112 ,0xC0 );
   ad9523_write(0x113 ,0x0  );
   ad9523_write(0x114 ,0xC0 );
   ad9523_write(0x11a ,0xB  );
   ad9523_write(0x11b ,0x1  );
   ad9523_write(0x11c ,0x93 );
   ad9523_write(0x11e ,0x93 );
   ad9523_write(0x120 ,0x0  );
   ad9523_write(0x121 ,0x0  );
   ad9523_write(0x122 ,0x0  );
   ad9523_write(0x123 ,0x40 );
   ad9523_write(0x128 ,0x48 );
   ad9523_write(0x129 ,0x0  );
   ad9523_write(0x12a ,0x0  );
   ad9523_write(0x1ff ,0x0  );
   ad9523_write(0x200 ,0x0  );
   ad9523_write(0x201 ,0x0  );
   ad9523_write(0x245 ,0x0  );
   ad9523_write(0x247 ,0x0  );
   ad9523_write(0x248 ,0x0  );
   ad9523_write(0x249 ,0x0  );
   ad9523_write(0x24a ,0x0  );
   ad9523_write(0x24b ,0x0  );
   ad9523_write(0x24c ,0x0  );
   ad9523_write(0x26f ,0x0  );
   ad9523_write(0x270 ,0x0  );
   ad9523_write(0x271 ,0x80 );
   ad9523_write(0x272 ,0x0  );
   ad9523_write(0x273 ,0x0  );
   ad9523_write(0x274 ,0x1  );
   ad9523_write(0x275 ,0x0  );
   ad9523_write(0x276 ,0x0  );
   ad9523_write(0x277 ,0x0  );
   ad9523_write(0x278 ,0x0  );
   ad9523_write(0x279 ,0x0  );
   ad9523_write(0x27a ,0x2  );
   ad9523_write(0x550 ,0x4  );
   ad9523_write(0x551 ,0x0  );
   ad9523_write(0x552 ,0x0  );
   ad9523_write(0x553 ,0x0  );
   ad9523_write(0x554 ,0x0  );
   ad9523_write(0x555 ,0x0  );
   ad9523_write(0x556 ,0x0  );
   ad9523_write(0x557 ,0x0  );
   ad9523_write(0x558 ,0x0  );
   ad9523_write(0x559 ,0x0  );
   ad9523_write(0x55a ,0x0  );
   ad9523_write(0x561 ,0x1  );
   ad9523_write(0x562 ,0x0  );
   ad9523_write(0x563 ,0x0  );
   ad9523_write(0x564 ,0x0  );
   ad9523_write(0x56e ,0x10 );
   ad9523_write(0x56f ,0x80 );
   ad9523_write(0x571 ,0x14 );
   ad9523_write(0x572 ,0x0  );
   ad9523_write(0x573 ,0x0  );
   ad9523_write(0x574 ,0x0  );
   ad9523_write(0x578 ,0x0  );
   ad9523_write(0x580 ,0x0  );
   ad9523_write(0x581 ,0x0  );
   ad9523_write(0x583 ,0x0  );
   ad9523_write(0x584 ,0x1  );
   ad9523_write(0x585 ,0x2  );
   ad9523_write(0x586 ,0x3  );
   ad9523_write(0x58b ,0x83 );
   ad9523_write(0x58c ,0x1  );
   ad9523_write(0x58d ,0x1F );
   ad9523_write(0x58e ,0x1  );
   ad9523_write(0x58f ,0xF  );
   ad9523_write(0x590 ,0xF  );
   ad9523_write(0x591 ,0x21 );
   ad9523_write(0x592 ,0x0  );
   ad9523_write(0x5a0 ,0xE3 );
   ad9523_write(0x5a1 ,0xE4 );
   ad9523_write(0x5a2 ,0xE5 );
   ad9523_write(0x5a3 ,0xE6 );
   ad9523_write(0x5b0 ,0xAA );
   ad9523_write(0x5b2 ,0x0  );
   ad9523_write(0x5b3 ,0x11 );
   ad9523_write(0x5b5 ,0x22 );
   ad9523_write(0x5b6 ,0x33 );
   ad9523_write(0x5bf ,0x0  );
   ad9523_write(0x5c0 ,0x11 );
   ad9523_write(0x5c1 ,0x11 );
   ad9523_write(0x5c2 ,0x11 );
   ad9523_write(0x5c3 ,0x11 );
   ad9523_write(0x5c4 ,0x0  );
   ad9523_write(0x5c6 ,0x0  );
   ad9523_write(0x5c8 ,0x0  );
   ad9523_write(0x5ca ,0x0  );
   ad9523_write(0x701 ,0x2  );
   ad9523_write(0x73b ,0xBF );
   ad9523_write(0xdf8 ,0x0  );
   ad9523_write(0xdf9 ,0x0  );
   ad9523_write(0x1222,0x0  );
   ad9523_write(0x1228,0xF  );
   ad9523_write(0x1262,0x0  );
   ad9523_write(0x18a6,0x0  );
   ad9523_write(0x18e3,0x0  );
   ad9523_write(0x18e6,0x0  );
   ad9523_write(0x1908,0x0  );
   ad9523_write(0x1910,0xC  );
   ad9523_write(0x1a4c,0xF  );
   ad9523_write(0x1a4d,0xF  );
   ad9523_write(0x1b03,0x2  );
   ad9523_write(0x1b08,0xC1 );
   ad9523_write(0x1b10,0x0  );

    */
    usleep(1000000);
}

/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue  - The register's value or negative error code.
*******************************************************************************/
int32_t ad9523_driver::ad9523_read(int32_t registerAddress)
{
    uint32_t regAddress  = 0;
    uint8_t  rxBuffer[3] = {0, 0, 0};
    uint8_t  txBuffer[3] = {0, 0, 0};
    uint32_t regValue    = 0;
    uint8_t  i           = 0;
    int32_t  ret         = 0;

    regAddress = ad9523_READ + registerAddress;
      txBuffer[0] = (regAddress & 0xFF00) >> 8;
        txBuffer[1] = regAddress & 0x00FF;
        txBuffer[2] = 0;
        set_cs_active();
        ret         = spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),3, (char*)txBuffer, 3, (char*)rxBuffer, 1, 2);
        set_cs_inactive();

        if(ret < 0)
        {
            return ret;
        }
        regValue = rxBuffer[2];
#if DEBUG_ad9523_DEVICE_DRIVER
    xprintf("ad9523_read: read %x from %x \n",regValue,registerAddress);
#endif
    return regValue;
}

/***************************************************************************//**
 * @brief Writes a value to the selected register.
 *
 * @param registerAddress - The address of the register to write to.
 * @param registerValue   - The value to write to the register.
 *
 * @return Returns 0 in case of success or negative error code.
*******************************************************************************/
int32_t ad9523_driver::ad9523_write(int32_t registerAddress, int32_t registerValue)
{
    uint8_t  i           = 0;
    int32_t  ret         = 0;
    uint16_t regAddress  = 0;
    char     regValue    = 0;
    char     txBuffer[3] = {0, 0, 0};
    
     regAddress = ad9523_WRITE + registerAddress;
     regValue =    registerValue;
     txBuffer[0] = (regAddress & 0xFF00) >> 8;
     txBuffer[1] = regAddress & 0x00FF;
     txBuffer[2] = regValue;
     set_cs_active();
     ret =  spi_driver->SPI_TransferData((1<<(this->get_chipselect_index())),3, (char*)txBuffer, 0, NULL, 1, 100);
     set_cs_inactive();
     if(ret < 0)
     {
    
  	 #if DEBUG_ad9523_DEVICE_DRIVER
  	 	xprintf("ad9523_write: ABNORMAL: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
  	 #endif
    
         return ret;
     }
       

#if DEBUG_ad9523_DEVICE_DRIVER
    xprintf("ad9523_write: wrote %x to %x ret = %d\n",registerValue,registerAddress, ret);
#endif
    return (ret - 1);
}

/***************************************************************************//**
 * @brief Reads the value of the selected register.
 *
 * @param registerAddress - The address of the register to read.
 *
 * @return registerValue - The register's value or negative error code.
 *******************************************************************************/
int32_t ad9523_driver::ad9523_original_driver_spi_read(uint32_t reg_addr)
{
	uint8_t buf[3];

	int32_t ret = 0;
	uint8_t index;
	uint32_t new_reg_data;
	uint32_t reg_data;

	reg_data = 0;
	for(index = 0; index < AD9523_TRANSF_LEN(reg_addr); index++) {
		new_reg_data =  ad9523_read(reg_addr);
		reg_addr--;
		reg_data <<= 8;
		reg_data |= new_reg_data;
	}

	return reg_data;
}

/***************************************************************************//**
 * @brief Writes a value to the selected register.
 *
 * @param registerAddress - The address of the register to write to.
 * @param registerValue - The value to write to the register.
 *
 * @return Returns 0 in case of success or negative error code.
 *******************************************************************************/
int32_t ad9523_driver::ad9523_original_driver_spi_write(uint32_t reg_addr, uint32_t reg_data)
{
	uint8_t buf[3];

	int32_t ret = 0;
	uint8_t index;

	for(index = 0; index < AD9523_TRANSF_LEN(reg_addr); index++) {
		ret |= ad9523_write(reg_addr,(reg_data >> ((AD9523_TRANSF_LEN(reg_addr) - index - 1) * 8)) & 0xFF);
		reg_addr--;
	}

	return 0;
}



/* Helpers to avoid excess line breaks */
#define AD_IFE(_pde, _a, _b) ((dev->pdata->_pde) ? _a : _b)
#define AD_IF(_pde, _a) AD_IFE(_pde, _a, 0)


/***************************************************************************//**
 * @brief Updates the AD9523 configuration
 *
 * @return Returns 0 in case of success or negative error code.
 *******************************************************************************/
int32_t ad9523_driver::ad9523_io_update()
{
	return ad9523_original_driver_spi_write(
				AD9523_IO_UPDATE,
				AD9523_IO_UPDATE_EN);
}

/***************************************************************************//**
 * @brief Sets the clock provider for selected channel.
 *
 * @param ch - Selected channel.
 * @param out - Selected clock provider.
 *
 * @return Returns 0 in case of success or negative error code.
 *******************************************************************************/
int32_t ad9523_driver::ad9523_vco_out_map(
			   uint32_t ch,
			   uint32_t out)
{
	int32_t ret;
	uint32_t mask;
	uint32_t reg_data;

	switch (ch) {
	case 0 ... 3:
		ret = ad9523_original_driver_spi_read(AD9523_PLL1_OUTPUT_CHANNEL_CTRL);
		if (ret < 0)
			break;
		reg_data = ret;
		mask = AD9523_PLL1_OUTP_CH_CTRL_VCXO_SRC_SEL_CH0 << ch;
		if (out) {
			reg_data |= mask;
			out = AD9523_VCXO;
		} else {
			reg_data &= ~mask;
		}
		ret = ad9523_original_driver_spi_write(
				       AD9523_PLL1_OUTPUT_CHANNEL_CTRL,
				       reg_data);
		break;
	case 4 ... 6:
		ret = ad9523_original_driver_spi_read(AD9523_PLL1_OUTPUT_CTRL);

		if (ret < 0)
			break;
		reg_data = ret;

		mask = AD9523_PLL1_OUTP_CTRL_VCO_DIV_SEL_CH4_M2 << (ch - 4);
		if (out)
			reg_data |= mask;
		else
			reg_data &= ~mask;
		ret = ad9523_original_driver_spi_write(
				       AD9523_PLL1_OUTPUT_CTRL,
				       reg_data);
		break;
	case 7 ... 9:
		ret = ad9523_original_driver_spi_read(AD9523_PLL1_OUTPUT_CHANNEL_CTRL);
		if (ret < 0)
			break;
		reg_data = ret;
		mask = AD9523_PLL1_OUTP_CH_CTRL_VCO_DIV_SEL_CH7_M2 << (ch - 7);
		if (out)
			reg_data |= mask;
		else
			reg_data &= ~mask;
		ret = ad9523_original_driver_spi_write(
				       AD9523_PLL1_OUTPUT_CHANNEL_CTRL,
				       reg_data);
		break;
	default:
		return 0;
	}

	dev->ad9523_st.vco_out_map[ch] = out;

	return ret;
}

/***************************************************************************//**
 * @brief Updates the AD9523 configuration.
 *
 * @return Returns 0 in case of success or negative error code.
 *******************************************************************************/

// vco calibration on default setup may not work (as it is a buffered write)
// calibration requires all registers to be written (not in hold registers) first.

int32_t ad9523_driver::ad9523_calibrate()
{
	uint32_t reg_data;
	uint32_t timeout;

	ad9523_original_driver_spi_write(
			 AD9523_PLL2_VCO_CTRL,
			 AD9523_PLL2_VCO_CALIBRATE);
	ad9523_io_update();

	timeout = 0;
	while (timeout < 100) {
		low_level_system_usleep(1000);
		timeout = timeout + 1;
		reg_data = ad9523_original_driver_spi_read(AD9523_READBACK_1);
		if ((reg_data & 0x1) == 0x0)
			break;
	}
	reg_data = ad9523_original_driver_spi_read(AD9523_READBACK_1);
	if ((reg_data & 0x1) != 0x0) {
		printf("AD9523: VCO calibration failed (%x)!\n", reg_data);
		return(-1);
	}

	return(0);
}

/***************************************************************************//**
 * @brief Updates the AD9523 configuration.
 *
 * @return Returns 0 in case of success or negative error code.
 *******************************************************************************/

// status
// calibration requires all registers to be written (not in hold registers) first.

int32_t ad9523_driver::ad9523_status()
{
	int32_t ret;
	uint32_t reg_data;
	uint32_t status;
	uint32_t timeout;

	status = 0;

	// vcxo + pll2 must always be okay- (is it not?)

	status = status | AD9523_READBACK_0_STAT_VCXO;
	status = status | AD9523_READBACK_0_STAT_PLL2_LD;

	if (dev->pdata->pll1_bypass_en == 0) {
		status = status | AD9523_READBACK_0_STAT_PLL2_REF_CLK;
		status = status | AD9523_READBACK_0_STAT_PLL2_FB_CLK;
		status = status | AD9523_READBACK_0_STAT_REF_TEST;
		status = status | AD9523_READBACK_0_STAT_REFB;
		status = status | AD9523_READBACK_0_STAT_REFA;
		status = status | AD9523_READBACK_0_STAT_PLL1_LD;
	}

	timeout = 0;
	while (timeout < 100) {
		low_level_system_usleep(1000);
		timeout = timeout + 1;
		reg_data = ad9523_original_driver_spi_read(AD9523_READBACK_0);
		if ((reg_data & status) == status)
			break;
	}

	ret = 0;
	if ((reg_data & AD9523_READBACK_0_STAT_VCXO) != AD9523_READBACK_0_STAT_VCXO) {
		printf("AD9523: VCXO status errors (%x)!\n", reg_data);
		ret = -1;
	}
	if ((reg_data & AD9523_READBACK_0_STAT_PLL2_LD) != AD9523_READBACK_0_STAT_PLL2_LD) {
		printf("AD9523: PLL2 NOT locked (%x)!\n", reg_data);
		ret = -1;
	}
	return(ret);
}

/***************************************************************************//**
 * @brief Updates the AD9523 configuration.
 *
 * @return Returns 0 in case of success or negative error code.
 *******************************************************************************/
int32_t ad9523_driver::ad9523_sync()
{
	int32_t ret, tmp;
	uint32_t reg_data;

	ret = ad9523_original_driver_spi_read(AD9523_STATUS_SIGNALS);

	if (ret < 0)
		return ret;
	reg_data = ret;

	tmp = reg_data;
	tmp |= AD9523_STATUS_SIGNALS_SYNC_MAN_CTRL;

	ret = ad9523_original_driver_spi_write(
			       AD9523_STATUS_SIGNALS,
			       tmp);
	tmp = ret;
	if (ret < 0)
		return ret;

	ad9523_io_update();
	tmp &= ~AD9523_STATUS_SIGNALS_SYNC_MAN_CTRL;

	ret = ad9523_original_driver_spi_write(
			       AD9523_STATUS_SIGNALS,
			       tmp);
	if (ret < 0)
		return ret;

	return ad9523_io_update();

}

/***************************************************************************//**
 * @brief Initialize the AD9523 data structure with the default register values.
 *
 * @return Always return 0.
 *******************************************************************************/
int32_t ad9523_driver::ad9523_init_params(struct ad9523_init_param *init_param)
{

	int32_t i = 0;

	init_param->pdata->vcxo_freq = 0;
	init_param->pdata->spi3wire = 0;

	/* Differential/ Single-Ended Input Configuration */
	init_param->pdata->refa_diff_rcv_en = 0;
	init_param->pdata->refb_diff_rcv_en = 0;
	init_param->pdata->zd_in_diff_en = 0;
	init_param->pdata->osc_in_diff_en = 0;

	/*
	 * Valid if differential input disabled
	 * if not true defaults to pos input
	 */
	init_param->pdata->refa_cmos_neg_inp_en = 0;
	init_param->pdata->refb_cmos_neg_inp_en = 0;
	init_param->pdata->zd_in_cmos_neg_inp_en = 0;
	init_param->pdata->osc_in_cmos_neg_inp_en = 0;

	/* PLL1 Setting */
	init_param->pdata->refa_r_div = 1;
	init_param->pdata->refb_r_div = 1;
	init_param->pdata->pll1_feedback_div = 1;
	init_param->pdata->pll1_charge_pump_current_nA = 0;
	init_param->pdata->zero_delay_mode_internal_en = 0;
	init_param->pdata->osc_in_feedback_en = 0;
	init_param->pdata->pll1_bypass_en = 1;
	init_param->pdata->pll1_loop_filter_rzero = 1;

	/* Reference */
	init_param->pdata->ref_mode = 0;

	/* PLL2 Setting */
	init_param->pdata->pll2_charge_pump_current_nA = 0;
	init_param->pdata->pll2_ndiv_a_cnt = 0;
	init_param->pdata->pll2_ndiv_b_cnt = 4;
	init_param->pdata->pll2_freq_doubler_en = 0;
	init_param->pdata->pll2_r2_div = 0;
	init_param->pdata->pll2_vco_diff_m1 = 0; /* 3..5 */
	init_param->pdata->pll2_vco_diff_m2 = 0; /* 3..5 */

	/* Loop Filter PLL2 */
	init_param->pdata->rpole2 = 0;
	init_param->pdata->rzero = 0;
	init_param->pdata->cpole1 = 0;
	init_param->pdata->rzero_bypass_en = 0;

	/* Output Channel Configuration */
	for (i=0; i < init_param->pdata->num_channels; i++) {
		(&init_param->pdata->channels[i])->channel_num = 0;
		(&init_param->pdata->channels[i])->divider_output_invert_en = 0;
		(&init_param->pdata->channels[i])->sync_ignore_en = 0;
		(&init_param->pdata->channels[i])->low_power_mode_en = 0;
		(&init_param->pdata->channels[i])->use_alt_clock_src = 0;
		(&init_param->pdata->channels[i])->output_dis = 0;
		(&init_param->pdata->channels[i])->driver_mode = LVPECL_8mA;
		(&init_param->pdata->channels[i])->divider_phase = 0;
		(&init_param->pdata->channels[i])->channel_divider = 0;
	}
	return 0;
}


/***************************************************************************//**
 * @brief Setup the AD9523 device.
 *
 * @return Returns 0 in case of success or negative error code.
 *******************************************************************************/
int32_t ad9523_driver::ad9523_setup(const struct ad9523_init_param *init_param)

{
	struct ad9523_channel_spec *chan;
	uint32_t active_mask = 0;
	int32_t ret, i;
	uint32_t reg_data;
	uint32_t version_id;

	dev = (struct ad9523_dev *)malloc(sizeof(*dev));
	if (!dev)
		return -1;


	dev->pdata = init_param->pdata;

	ret = ad9523_original_driver_spi_write(
			       AD9523_READBACK_CTRL,
			       AD9523_READBACK_CTRL_READ_BUFFERED);
	if (ret < 0)
		return ret;

	ret = ad9523_io_update();
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_read(AD9523_EEPROM_CUSTOMER_VERSION_ID);
	if (ret < 0)
		return ret;
	version_id = ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_EEPROM_CUSTOMER_VERSION_ID,
			       0xAD95);
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_read(AD9523_EEPROM_CUSTOMER_VERSION_ID);
	if (ret < 0)
		return ret;
	reg_data = ret;
	if (reg_data != 0xAD95) {
		printf("AD9523: SPI write-verify failed (0x%X)!\n\r",
		       reg_data);
		return -1;
	}

	ret = ad9523_original_driver_spi_write(
			       AD9523_EEPROM_CUSTOMER_VERSION_ID,
			       version_id);
	if (ret < 0)
		return ret;

	/*
	 * PLL1 Setup
	 */
	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_REF_A_DIVIDER,
			       dev->pdata->refa_r_div);
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_REF_B_DIVIDER,
			       dev->pdata->refb_r_div);
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_FEEDBACK_DIVIDER,
			       dev->pdata->pll1_feedback_div);
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_CHARGE_PUMP_CTRL,
			       AD_IFE(pll1_bypass_en, AD9523_PLL1_CHARGE_PUMP_TRISTATE,
				      AD9523_PLL1_CHARGE_PUMP_CURRENT_nA(dev->pdata->
						      pll1_charge_pump_current_nA) |
				      AD9523_PLL1_CHARGE_PUMP_MODE_NORMAL |
				      AD9523_PLL1_BACKLASH_PW_MIN));
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_INPUT_RECEIVERS_CTRL,
			       AD_IFE(pll1_bypass_en, AD9523_PLL1_REFA_REFB_PWR_CTRL_EN |
				      AD_IF(osc_in_diff_en, AD9523_PLL1_OSC_IN_DIFF_EN) |
				      AD_IF(osc_in_cmos_neg_inp_en, AD9523_PLL1_OSC_IN_CMOS_NEG_INP_EN),
				      AD_IF(refa_diff_rcv_en, AD9523_PLL1_REFA_RCV_EN) |
				      AD_IF(refb_diff_rcv_en, AD9523_PLL1_REFB_RCV_EN) |
				      AD_IF(osc_in_diff_en, AD9523_PLL1_OSC_IN_DIFF_EN) |
				      AD_IF(osc_in_cmos_neg_inp_en,
					    AD9523_PLL1_OSC_IN_CMOS_NEG_INP_EN) |
				      AD_IF(refa_diff_rcv_en, AD9523_PLL1_REFA_DIFF_RCV_EN) |
				      AD_IF(refb_diff_rcv_en, AD9523_PLL1_REFB_DIFF_RCV_EN)));
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_REF_CTRL,
			       AD_IFE(pll1_bypass_en, AD9523_PLL1_BYPASS_FEEDBACK_DIV_EN |
				      AD9523_PLL1_ZERO_DELAY_MODE_INT,
				      AD_IF(zd_in_diff_en, AD9523_PLL1_ZD_IN_DIFF_EN) |
				      AD_IF(zd_in_cmos_neg_inp_en,
					    AD9523_PLL1_ZD_IN_CMOS_NEG_INP_EN) |
				      AD_IF(zero_delay_mode_internal_en,
					    AD9523_PLL1_ZERO_DELAY_MODE_INT) |
				      AD_IF(osc_in_feedback_en, AD9523_PLL1_OSC_IN_PLL_FEEDBACK_EN) |
				      AD_IF(refa_cmos_neg_inp_en, AD9523_PLL1_REFA_CMOS_NEG_INP_EN) |
				      AD_IF(refb_cmos_neg_inp_en, AD9523_PLL1_REFB_CMOS_NEG_INP_EN)));
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_MISC_CTRL,
			       AD9523_PLL1_REFB_INDEP_DIV_CTRL_EN |
			       AD9523_PLL1_REF_MODE(dev->pdata->ref_mode));
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL1_LOOP_FILTER_CTRL,
			       AD9523_PLL1_LOOP_FILTER_RZERO(dev->pdata->
					       pll1_loop_filter_rzero));
	if (ret < 0)
		return ret;

	/*
	 * PLL2 Setup
	 */

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL2_CHARGE_PUMP,
			       AD9523_PLL2_CHARGE_PUMP_CURRENT_nA(dev->pdata->
					       pll2_charge_pump_current_nA));
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL2_FEEDBACK_DIVIDER_AB,
			       AD9523_PLL2_FB_NDIV_A_CNT(dev->pdata->pll2_ndiv_a_cnt) |
			       AD9523_PLL2_FB_NDIV_B_CNT(dev->pdata->pll2_ndiv_b_cnt));
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL2_CTRL,
			       AD9523_PLL2_CHARGE_PUMP_MODE_NORMAL |
			       AD9523_PLL2_BACKLASH_CTRL_EN |
			       AD_IF(pll2_freq_doubler_en,
				     AD9523_PLL2_FREQ_DOUBLER_EN));
	if (ret < 0)
		return ret;

	dev->ad9523_st.vco_freq = (dev->pdata->vcxo_freq * (dev->pdata->pll2_freq_doubler_en ? 2 : 1)
				   / dev->pdata->pll2_r2_div) * AD9523_PLL2_FB_NDIV(dev->pdata->
						   pll2_ndiv_a_cnt,
						   dev->pdata->
						   pll2_ndiv_b_cnt);

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL2_VCO_CTRL,
			       AD9523_PLL2_VCO_CALIBRATE);
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL2_VCO_DIVIDER,
			       AD9523_PLL2_VCO_DIV_M1(dev->pdata->
					       pll2_vco_diff_m1) |
			       AD9523_PLL2_VCO_DIV_M2(dev->pdata->
					       pll2_vco_diff_m2) |
			       AD_IFE(pll2_vco_diff_m1,
				      0,
				      AD9523_PLL2_VCO_DIV_M1_PWR_DOWN_EN) |
			       AD_IFE(pll2_vco_diff_m2,
				      0,
				      AD9523_PLL2_VCO_DIV_M2_PWR_DOWN_EN));
	if (ret < 0)
		return ret;

	if (dev->pdata->pll2_vco_diff_m1)
		dev->ad9523_st.vco_out_freq[AD9523_VCO1] =
			dev->ad9523_st.vco_freq / dev->pdata->pll2_vco_diff_m1;

	if (dev->pdata->pll2_vco_diff_m2)
		dev->ad9523_st.vco_out_freq[AD9523_VCO2] =
			dev->ad9523_st.vco_freq / dev->pdata->pll2_vco_diff_m2;

	dev->ad9523_st.vco_out_freq[AD9523_VCXO] = dev->pdata->vcxo_freq;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL2_R2_DIVIDER,
			       AD9523_PLL2_R2_DIVIDER_VAL(dev->pdata->pll2_r2_div));
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_PLL2_LOOP_FILTER_CTRL,
			       AD9523_PLL2_LOOP_FILTER_CPOLE1(dev->pdata->cpole1) |
			       AD9523_PLL2_LOOP_FILTER_RZERO(dev->pdata->rzero) |
			       AD9523_PLL2_LOOP_FILTER_RPOLE2(dev->pdata->rpole2) |
			       AD_IF(rzero_bypass_en,
				     AD9523_PLL2_LOOP_FILTER_RZERO_BYPASS_EN));
	if (ret < 0)
		return ret;

	for (i = 0; i < dev->pdata->num_channels; i++) {
		chan = &dev->pdata->channels[i];
		if (chan->channel_num < AD9523_NUM_CHAN) {
			active_mask |= (1 << chan->channel_num);
			ret = ad9523_original_driver_spi_write(
					       AD9523_CHANNEL_CLOCK_DIST(chan->channel_num),
					       AD9523_CLK_DIST_DRIVER_MODE(chan->driver_mode) |
					       AD9523_CLK_DIST_DIV(chan->channel_divider) |
					       AD9523_CLK_DIST_DIV_PHASE(chan->divider_phase) |
					       (chan->sync_ignore_en ?
						AD9523_CLK_DIST_IGNORE_SYNC_EN : 0) |
					       (chan->divider_output_invert_en ?
						AD9523_CLK_DIST_INV_DIV_OUTPUT_EN : 0) |
					       (chan->low_power_mode_en ?
						AD9523_CLK_DIST_LOW_PWR_MODE_EN : 0) |
					       (chan->output_dis ?
						AD9523_CLK_DIST_PWR_DOWN_EN : 0));
			if (ret < 0)
				return ret;

			ret = ad9523_vco_out_map(
						 chan->channel_num,
						 chan->use_alt_clock_src);
			if (ret < 0)
				return ret;
		}
	}

	for(i = 0; i < AD9523_NUM_CHAN; i++) {
		if(!(active_mask & (1 << i))) {
			ad9523_original_driver_spi_write(
					 AD9523_CHANNEL_CLOCK_DIST(i),
					 AD9523_CLK_DIST_DRIVER_MODE(TRISTATE) |
					 AD9523_CLK_DIST_PWR_DOWN_EN);
		}
	}

	ret = ad9523_original_driver_spi_write(
			       AD9523_POWER_DOWN_CTRL,
			       0);
	if (ret < 0)
		return ret;

	ret = ad9523_original_driver_spi_write(
			       AD9523_STATUS_SIGNALS,
			       AD9523_STATUS_MONITOR_01_PLL12_LOCKED);
	if (ret < 0)
		return ret;

	ret = ad9523_io_update();
	if (ret < 0)
		return ret;

	ret = ad9523_sync();
	if (ret < 0)
		return ret;

	ad9523_original_driver_spi_write(
			 AD9523_READBACK_CTRL,
			 0x0);
	ad9523_io_update();
	ad9523_calibrate();
	ad9523_sync();

	return(ad9523_status());
}

void ad9523_driver::fmcdaq2_default_parameters_init() {
//******************************************************************************
// clock distribution device (AD9523) configuration
//******************************************************************************

	ad9523_pdata.num_channels = 8;
	ad9523_pdata.channels = &ad9523_channels[0];
	ad9523_param.pdata = &ad9523_pdata;
	ad9523_init_params(&ad9523_param);

	// dac device-clk-sysref, fpga-clk-sysref

	ad9523_channels[DAC_DEVICE_CLK].channel_num = 1;
	ad9523_channels[DAC_DEVICE_CLK].channel_divider = 1;
	ad9523_channels[DAC_DEVICE_SYSREF].channel_num = 7;
	ad9523_channels[DAC_DEVICE_SYSREF].channel_divider = 128;
	ad9523_channels[DAC_FPGA_CLK].channel_num = 9;
	ad9523_channels[DAC_FPGA_CLK].channel_divider = 2;
	ad9523_channels[DAC_FPGA_SYSREF].channel_num = 8;
	ad9523_channels[DAC_FPGA_SYSREF].channel_divider = 128;

	// adc device-clk-sysref, fpga-clk-sysref

	ad9523_channels[ADC_DEVICE_CLK].channel_num = 13;
	ad9523_channels[ADC_DEVICE_CLK].channel_divider = 1;
	ad9523_channels[ADC_DEVICE_SYSREF].channel_num = 6;
	ad9523_channels[ADC_DEVICE_SYSREF].channel_divider = 128;
	ad9523_channels[ADC_FPGA_CLK].channel_num = 4;
	ad9523_channels[ADC_FPGA_CLK].channel_divider = 4;
	ad9523_channels[ADC_FPGA_SYSREF].channel_num = 5;
	ad9523_channels[ADC_FPGA_SYSREF].channel_divider = 128;

	// VCXO 125MHz

	ad9523_pdata.vcxo_freq = 125000000;
	ad9523_pdata.spi3wire = 1;
	ad9523_pdata.osc_in_diff_en = 1;
	ad9523_pdata.pll2_charge_pump_current_nA = 413000;
	ad9523_pdata.pll2_freq_doubler_en = 0;
	ad9523_pdata.pll2_r2_div = 1;
	ad9523_pdata.pll2_ndiv_a_cnt = 0;
	ad9523_pdata.pll2_ndiv_b_cnt = 6;
	ad9523_pdata.pll2_vco_diff_m1 = 3;
	ad9523_pdata.pll2_vco_diff_m2 = 0;
	ad9523_pdata.rpole2 = 0;
	ad9523_pdata.rzero = 7;
	ad9523_pdata.cpole1 = 2;

}

void   ad9523_driver::fmcdaq2_set_configuration(FMCDAQ2_AD9523_CONFIGURATION_ENUM_TYPE the_config) {
	fmcdaq2_default_parameters_init();

	switch (the_config) {
	case ADC_1000MSPS_DAC_2000MSPS:
#if DEBUG_ad9523_DEVICE_DRIVER
		xprintf ("5 - ADC  1000 MSPS; DAC  2000 MSPS\n");
#endif
		/* REF clock = 100 MHz */
		ad9523_param.pdata->channels[DAC_DEVICE_CLK].channel_divider = 10;

		break;
	case ADC_600MSPS_DAC_600MSPS:
#if DEBUG_ad9523_DEVICE_DRIVER
		xprintf ("4 - ADC  600 MSPS; DAC  600 MSPS\n");
#endif
		ad9523_param.pdata->pll2_vco_diff_m1 = 5;
		ad9523_param.pdata->channels[DAC_FPGA_CLK].channel_divider = 2;
		ad9523_param.pdata->channels[DAC_DEVICE_CLK].channel_divider = 1;
		ad9523_param.pdata->channels[DAC_DEVICE_SYSREF].channel_divider = 128;
		ad9523_param.pdata->channels[DAC_FPGA_SYSREF].channel_divider = 128;
		ad9523_param.pdata->channels[ADC_FPGA_CLK].channel_divider = 2;
		ad9523_param.pdata->channels[ADC_DEVICE_CLK].channel_divider = 1;
		ad9523_param.pdata->channels[ADC_DEVICE_SYSREF].channel_divider = 128;
		ad9523_param.pdata->channels[ADC_FPGA_SYSREF].channel_divider = 128;

		break;
	case ADC_500MSPS_DAC_500MSPS:
#if DEBUG_ad9523_DEVICE_DRIVER
		xprintf ("3 - ADC  500 MSPS; DAC  500 MSPS\n");
#endif
		ad9523_param.pdata->pll2_vco_diff_m1 = 3;
		ad9523_param.pdata->channels[DAC_FPGA_CLK].channel_divider = 4;
		ad9523_param.pdata->channels[DAC_DEVICE_CLK].channel_divider = 2;
		ad9523_param.pdata->channels[DAC_DEVICE_SYSREF].channel_divider = 256;
		ad9523_param.pdata->channels[DAC_FPGA_SYSREF].channel_divider = 256;
		ad9523_param.pdata->channels[ADC_FPGA_CLK].channel_divider = 4;
		ad9523_param.pdata->channels[ADC_DEVICE_CLK].channel_divider = 2;
		ad9523_param.pdata->channels[ADC_DEVICE_SYSREF].channel_divider = 256;
		ad9523_param.pdata->channels[ADC_FPGA_SYSREF].channel_divider = 256;


		break;
	case ADC_500MSPS_DAC_1000MSPS:
#if DEBUG_ad9523_DEVICE_DRIVER
		xprintf ("2 - ADC  500 MSPS; DAC 1000 MSPS\n");
#endif
		ad9523_param.pdata->pll2_vco_diff_m1 = 3;
		ad9523_param.pdata->channels[DAC_FPGA_CLK].channel_divider = 2;
		ad9523_param.pdata->channels[DAC_DEVICE_CLK].channel_divider = 1;
		ad9523_param.pdata->channels[DAC_DEVICE_SYSREF].channel_divider = 128;
		ad9523_param.pdata->channels[DAC_FPGA_SYSREF].channel_divider = 128;
		ad9523_param.pdata->channels[ADC_FPGA_CLK].channel_divider = 4;
		ad9523_param.pdata->channels[ADC_DEVICE_CLK].channel_divider = 2;
		ad9523_param.pdata->channels[ADC_DEVICE_SYSREF].channel_divider = 256;
		ad9523_param.pdata->channels[ADC_FPGA_SYSREF].channel_divider = 256;

		break;
	case ADC_750MSPS_DAC_1000MSPS:
		ad9523_param.pdata->pll2_vco_diff_m1 = 4;
		break;
	case ADC_1000MSPS_DAC_1000MSPS:
	default:
#if DEBUG_ad9523_DEVICE_DRIVER
		xprintf  ("1 - ADC 1000 MSPS; DAC 1000 MSPS\n");
#endif
		break;
	}

	ad9523_setup(&ad9523_param);

}

