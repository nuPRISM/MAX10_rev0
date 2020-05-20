/*
 * fmc_loopback.c
 *
 *  Created on: 2013-05-24
 *      Author: bryerton
 */

#include <stdlib.h>
#include "fmc_deap_clkgen.h"

tFMCInfo* CreateFMCDeapClkGen(void) {
	tFMCInfo* fmc = new tFMCInfo;

	static char* str_manufacturer = MANUFACTURER;
	static char* str_product = PRODUCT_NAME;
	static char* str_serial  = SERIAL_NUM;
	static char* str_part	 = PART_NUM;

	fmc->board_info.version = 0;
	fmc->board_info.lang_code = 0;
	fmc->board_info.length = 12 + sizeof(MANUFACTURER) + sizeof(PRODUCT_NAME) + sizeof(SERIAL_NUM) + sizeof(PART_NUM);

	// Pad length
	if(fmc->board_info.length % 8 != 0) {
		fmc->board_info.length += 8 - (fmc->board_info.length % 8);
	}

	fmc->board_info.mfg_datetime = 0;

	fmc->board_info.manufacturer.type_code = 0x03;
	fmc->board_info.manufacturer.num_bytes = sizeof(MANUFACTURER);
	fmc->board_info.manufacturer_bytes = str_manufacturer;

	fmc->board_info.product.type_code = 0x03;
	fmc->board_info.product.num_bytes = sizeof(PRODUCT_NAME);
	fmc->board_info.product_bytes = str_product;

	fmc->board_info.serial_num.type_code = 0x03;
	fmc->board_info.serial_num.num_bytes = sizeof(SERIAL_NUM);
	fmc->board_info.serial_num_bytes = str_serial;

	fmc->board_info.part_num.type_code = 0x03;
	fmc->board_info.part_num.num_bytes = sizeof(PART_NUM);
	fmc->board_info.part_num_bytes = str_part;

	fmc->board_info.FRU_File_Id.type_code = 0;
	fmc->board_info.FRU_File_Id.num_bytes = 0;
	fmc->board_info.FRU_File_Id_bytes = "";

	fmc->base.module_size = IPMI_FMC_MODULE_SIZE_SINGLE;
	fmc->base.p1_conn_size = IPMI_FMC_CONN_SIZE_HPC;
	fmc->base.p2_conn_size = IPMI_FMC_CONN_SIZE_NONE;
	fmc->base.p1_bank_a_num_sig = 116;
	fmc->base.p1_bank_b_num_sig = 44;
	fmc->base.p2_bank_a_num_sig = 0;
	fmc->base.p2_bank_b_num_sig = 0;
	fmc->base.p1_gbt_num_sig = 10;
	fmc->base.p2_gbt_num_sig = 10;
	fmc->base.max_clock_for_tck = 0;

	// P1
	fmc->p1_vadj.output_num 		= 0;
	fmc->p1_vadj.nominal_voltage	= P1_VADJ_NOMINAL_VOLTAGE;
	fmc->p1_vadj.max_neg_volt_dev 	= P1_VADJ_NOMINAL_VOLTAGE - P1_VADJ_DEVIATION;
	fmc->p1_vadj.max_pos_volt_dev 	= P1_VADJ_NOMINAL_VOLTAGE + P1_VADJ_DEVIATION;
	fmc->p1_vadj.ripple_noise_pk2pk	= 10;
	fmc->p1_vadj.min_current_draw	= 0;
	fmc->p1_vadj.max_current_draw	= P1_VADJ_MAX_CURRENT;

	fmc->p1_3p3v.output_num 		= 1;
	fmc->p1_3p3v.nominal_voltage	= P1_3V3_NOMINAL_VOLTAGE;
	fmc->p1_3p3v.max_neg_volt_dev 	= P1_3V3_NOMINAL_VOLTAGE - P1_3V3_DEVIATION;
	fmc->p1_3p3v.max_pos_volt_dev 	= P1_3V3_NOMINAL_VOLTAGE + P1_3V3_DEVIATION;
	fmc->p1_3p3v.ripple_noise_pk2pk	= 10;
	fmc->p1_3p3v.min_current_draw	= 0;
	fmc->p1_3p3v.max_current_draw	= P1_3V3_MAX_CURRENT;

	fmc->p1_12p0v.output_num 		= 2;
	fmc->p1_12p0v.nominal_voltage	= P1_12V_NOMINAL_VOLTAGE;
	fmc->p1_12p0v.max_neg_volt_dev 	= P1_12V_NOMINAL_VOLTAGE - P1_12V_DEVIATION;
	fmc->p1_12p0v.max_pos_volt_dev 	= P1_12V_NOMINAL_VOLTAGE + P1_12V_DEVIATION;
	fmc->p1_12p0v.ripple_noise_pk2pk	= 50;
	fmc->p1_12p0v.min_current_draw	= 0;
	fmc->p1_12p0v.max_current_draw	= P1_12V_MAX_CURRENT;

	fmc->p1_vio_b_m2c.standby			= 0;
	fmc->p1_vio_b_m2c.output_num		= 3;
	fmc->p1_vio_b_m2c.nominal_voltage	= P1_VIO_B_NOMINAL_VOLTAGE;
	fmc->p1_vio_b_m2c.max_neg_volt_dev	= P1_VIO_B_NOMINAL_VOLTAGE - P1_VIO_B_DEVIATION;
	fmc->p1_vio_b_m2c.max_pos_volt_dev	= P1_VIO_B_NOMINAL_VOLTAGE + P1_VIO_B_DEVIATION;
	fmc->p1_vio_b_m2c.ripple_noise_pk2pk = 10;
	fmc->p1_vio_b_m2c.min_current_draw	= 0;
	fmc->p1_vio_b_m2c.max_current_draw	= P1_VIO_B_MAX_CURRENT;

	fmc->p1_vref_a_m2c.standby			= 0;
	fmc->p1_vref_a_m2c.output_num		= 4;
	fmc->p1_vref_a_m2c.nominal_voltage  = P1_VREF_A_NOMINAL_VOLTAGE;
	fmc->p1_vref_a_m2c.max_neg_volt_dev	= P1_VREF_A_NOMINAL_VOLTAGE - P1_VREF_A_DEVIATION;
	fmc->p1_vref_a_m2c.max_pos_volt_dev	= P1_VREF_A_NOMINAL_VOLTAGE + P1_VREF_A_DEVIATION;
	fmc->p1_vref_a_m2c.ripple_noise_pk2pk = 10;
	fmc->p1_vref_a_m2c.min_current_draw	= 0;
	fmc->p1_vref_a_m2c.max_current_draw	= P1_VREF_A_MAX_CURRENT;

	fmc->p1_vref_b_m2c.standby			= 0;
	fmc->p1_vref_b_m2c.output_num		= 5;
	fmc->p1_vref_b_m2c.nominal_voltage	= P1_VREF_B_NOMINAL_VOLTAGE;
	fmc->p1_vref_b_m2c.max_neg_volt_dev	= P1_VREF_B_NOMINAL_VOLTAGE - P1_VREF_B_DEVIATION;
	fmc->p1_vref_b_m2c.max_pos_volt_dev	= P1_VREF_B_NOMINAL_VOLTAGE + P1_VREF_B_DEVIATION;
	fmc->p1_vref_b_m2c.ripple_noise_pk2pk = 10;
	fmc->p1_vref_b_m2c.min_current_draw	= 0;
	fmc->p1_vref_b_m2c.max_current_draw	= P1_VREF_B_MAX_CURRENT;

	// P2

	fmc->p2_vadj.output_num 		= 6;
	fmc->p2_vadj.nominal_voltage	= 250;
	fmc->p2_vadj.max_neg_volt_dev 	= 237;
	fmc->p2_vadj.max_pos_volt_dev 	= 263;
	fmc->p2_vadj.ripple_noise_pk2pk	= 10;
	fmc->p2_vadj.min_current_draw	= 0;
	fmc->p2_vadj.max_current_draw	= 4000;

	fmc->p2_3p3v.output_num 		= 7;
	fmc->p2_3p3v.nominal_voltage	= 330;
	fmc->p2_3p3v.max_neg_volt_dev 	= 313;
	fmc->p2_3p3v.max_pos_volt_dev 	= 347;
	fmc->p2_3p3v.ripple_noise_pk2pk	= 10;
	fmc->p2_3p3v.min_current_draw	= 0;
	fmc->p2_3p3v.max_current_draw	= 3000;

	fmc->p2_12p0v.output_num 		= 8;
	fmc->p2_12p0v.nominal_voltage	= 1200;
	fmc->p2_12p0v.max_neg_volt_dev 	= 1140;
	fmc->p2_12p0v.max_pos_volt_dev 	= 1260;
	fmc->p2_12p0v.ripple_noise_pk2pk	= 50;
	fmc->p2_12p0v.min_current_draw	= 0;
	fmc->p2_12p0v.max_current_draw	= 1000;

	fmc->p2_vio_b_m2c.standby			= 0;
	fmc->p2_vio_b_m2c.output_num		= 9;
	fmc->p2_vio_b_m2c.nominal_voltage	= 250;
	fmc->p2_vio_b_m2c.max_neg_volt_dev	= 0;
	fmc->p2_vio_b_m2c.max_pos_volt_dev	= 320;
	fmc->p2_vio_b_m2c.ripple_noise_pk2pk = 10;
	fmc->p2_vio_b_m2c.min_current_draw	= 0;
	fmc->p2_vio_b_m2c.max_current_draw	= 1150;

	fmc->p2_vref_a_m2c.standby			= 0;
	fmc->p2_vref_a_m2c.output_num		= 10;
	fmc->p2_vref_a_m2c.nominal_voltage	= 250;
	fmc->p2_vref_a_m2c.max_neg_volt_dev	= 0;
	fmc->p2_vref_a_m2c.max_pos_volt_dev	= 320;
	fmc->p2_vref_a_m2c.ripple_noise_pk2pk = 10;
	fmc->p2_vref_a_m2c.min_current_draw	= 0;
	fmc->p2_vref_a_m2c.max_current_draw	= 1;

	fmc->p2_vref_b_m2c.standby			= 0;
	fmc->p2_vref_b_m2c.output_num		= 11;
	fmc->p2_vref_b_m2c.nominal_voltage	= 250;
	fmc->p2_vref_b_m2c.max_neg_volt_dev	= 0;
	fmc->p2_vref_b_m2c.max_pos_volt_dev	= 320;
	fmc->p2_vref_b_m2c.ripple_noise_pk2pk = 10;
	fmc->p2_vref_b_m2c.min_current_draw	= 0;
	fmc->p2_vref_b_m2c.max_current_draw	= 1;

	return fmc;
}
