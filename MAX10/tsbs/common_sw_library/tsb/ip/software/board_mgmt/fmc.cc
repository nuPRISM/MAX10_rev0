/*
 * fmc.c
 *
 *  Created on: 2013-05-16
 *      Author: bryerton
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "fmc.h"

static void CreateMRA_FMCBase(tIPMI_MRA* mra, tIPMI_FMC_BASE* base);
static void CreateMRA_DCOutput(tIPMI_MRA* mra, tIPMI_DC_OUTPUT* output);
static void CreateMRA_DCLoad(tIPMI_MRA* mra, tIPMI_DC_LOAD* load);

static alt_u8 CalculateOffsetOfIUA(alt_u8* offset, tIPMI_IUA* area);
static alt_u8 CalculateOffsetOfCIA(alt_u8* offset, tIPMI_CIA* area);
static alt_u8 CalculateOffsetOfBIA(alt_u8* offset, tIPMI_BIA* area);
static alt_u8 CalculateOffsetOfPIA(alt_u8* offset, tIPMI_PIA* area);

void GetFMCInfo(pfnReadByte ReadByte, tFMCInfo* fmc_info, tIPMI_FRU_INFO* fru_info) {
	tIPMI_MRA_LIST* mra_list;
	tIPMI_DC_OUTPUT* output;
	tIPMI_DC_LOAD* load;
	alt_u8 output_num;

	// Read the Board Information
	IPMI_GetInfo(ReadByte, fru_info);

	// Convert to FMC FRU
	//memcpy(&fmc_info->board_info, fru_info->bia, sizeof(tIPMI_BIA));


if (fru_info->bia != NULL) {
	fmc_info->board_info.set_to(*fru_info->bia);



	 std::cout << "fru_info->bia->version = ( " << fru_info->bia->version << ")\n";  std::cout.flush()                                               ;
	 std::cout << " length    		          = " <<  fru_info->bia->length<< ")\n"; std::cout.flush()                          ;
	 std::cout << " lang_code    		      = " <<  fru_info->bia->lang_code<< ")\n"; std::cout.flush()                       ;
	 std::cout << " mfg_datetime     	      = " << 	 fru_info->bia->mfg_datetime<< ")\n"; std::cout.flush()                 ;
	 std::cout << " manufacturer    	      = " << 	 fru_info->bia->manufacturer.num_bytes <<  " " << fru_info->bia->manufacturer.type_code << ")\n"; std::cout.flush()                 ;
	 std::cout << " manufacturer_bytes        = " <<     		 fru_info->bia->manufacturer_bytes<< ")\n"; std::cout.flush()   ;
	 std::cout << " product    		          = " <<  fru_info->bia->product.num_bytes << " " << fru_info->bia->product.type_code <<  ")\n"; std::cout.flush()                         ;
	 std::cout << " product_bytes             = " << 	 fru_info->bia->product_bytes<< ")\n"; std::cout.flush()                ;
	 std::cout << " serial_num    	          = " << 	 fru_info->bia->serial_num.num_bytes <<  " " << fru_info->bia->serial_num.type_code << ")\n"; std::cout.flush()                   ;
	 std::cout << " serial_num_bytes          = " <<   		 fru_info->bia->serial_num_bytes<< ")\n"; std::cout.flush()         ;
	 std::cout << " part_num    		      = " <<  fru_info->bia->part_num.num_bytes << " " << fru_info->bia->part_num.type_code << ")\n"; std::cout.flush()                        ;
	 std::cout << " part_num_bytes            = " << 		 fru_info->bia->part_num_bytes<< ")\n"; std::cout.flush()           ;
	 std::cout << " FRU_File_Id    	          = " << 	 fru_info->bia->FRU_File_Id.num_bytes <<" "  << fru_info->bia->FRU_File_Id.type_code  << ")\n"; std::cout.flush()                  ;
	 std::cout << " FRU_File_Id_bytes         = " <<    		 fru_info->bia->FRU_File_Id_bytes<< ")\n"; std::cout.flush()    ;

	mra_list = fru_info->mra_list;
	while(mra_list != 0) {
		switch(mra_list->mra.type_id) {
		case IPMI_RECORD_TYPE_POWER_SUPPLY: // Power supply information
			break;

		case IPMI_RECORD_TYPE_DC_OUTPUT: // DC Output (expecting 6 or 12 depending on width)
			output_num = mra_list->mra.data[0] & 0x0F;
			switch(output_num) {
			case 3:
				output = &fmc_info->p1_vio_b_m2c;
				break;

			case 4:
				output = &fmc_info->p1_vref_a_m2c;
				break;

			case 5:
				output = &fmc_info->p1_vref_b_m2c;
				break;

			case 9:
				output = &fmc_info->p2_vio_b_m2c;
				break;

			case 10:
				output = &fmc_info->p2_vref_a_m2c;
				break;

			case 11:
				output = &fmc_info->p2_vref_b_m2c;
				break;

			default:
				output = 0;
				break;
			}

			if(output) {
				output->standby = (mra_list->mra.data[0] & 0x80) >> 7;
				output->output_num =  (mra_list->mra.data[0] & 0x0F);
				output->nominal_voltage = (mra_list->mra.data[2] << 8) | mra_list->mra.data[1];
				output->max_neg_volt_dev = (mra_list->mra.data[4] << 8) | mra_list->mra.data[3];
				output->max_pos_volt_dev = (mra_list->mra.data[6] << 8) | mra_list->mra.data[5];
				output->ripple_noise_pk2pk = (mra_list->mra.data[8] << 8) | mra_list->mra.data[7];
				output->min_current_draw = (mra_list->mra.data[10] << 8) | mra_list->mra.data[9];
				output->max_current_draw = (mra_list->mra.data[12] << 8) | mra_list->mra.data[11];
			}
			break;

		case IPMI_RECORD_TYPE_DC_LOAD: // DC Load
			output_num = mra_list->mra.data[0] & 0x0F;
			switch(output_num) {
			case 0:
				load = &fmc_info->p1_vadj;
				break;

			case 1:
				load = &fmc_info->p1_3p3v;
				break;

			case 2:
				load = &fmc_info->p1_12p0v;
				break;

			case 6:
				load = &fmc_info->p2_vadj;
				break;

			case 7:
				load = &fmc_info->p2_3p3v;
				break;

			case 8:
				load = &fmc_info->p2_12p0v;
				break;

			default:
				load = 0;
				break;
			}

			if(load) {
				load->output_num =  (mra_list->mra.data[0] & 0x0F);
				load->nominal_voltage = (mra_list->mra.data[2] << 8) | mra_list->mra.data[1];
				load->max_neg_volt_dev = (mra_list->mra.data[4] << 8) | mra_list->mra.data[3];
				load->max_pos_volt_dev = (mra_list->mra.data[6] << 8) | mra_list->mra.data[5];
				load->ripple_noise_pk2pk = (mra_list->mra.data[8] << 8) | mra_list->mra.data[7];
				load->min_current_draw = (mra_list->mra.data[10] << 8) | mra_list->mra.data[9];
				load->max_current_draw = (mra_list->mra.data[12] << 8) | mra_list->mra.data[11];
			}
			break;

		case IPMI_RECORD_TYPE_MANAGEMENT_ACC: // Management Access
			break;

		case BOARDMANAGEMENT_0_IPMI_RECORD_TYPE_FMC_BASE: // OEM record type
			if((mra_list->mra.data[0] == 0xA2) && (mra_list->mra.data[1] == 0x12) && (mra_list->mra.data[2] == 0x00)) {
				fmc_info->base.subtype = (mra_list->mra.data[3] & 0xF0) >> 4;
				fmc_info->base.version = (mra_list->mra.data[3] & 0x0F) >> 0;
				fmc_info->base.module_size = (mra_list->mra.data[4] & 0xC0) >> 6;
				fmc_info->base.p1_conn_size = (mra_list->mra.data[4] & 0x30) >> 4;
				fmc_info->base.p2_conn_size = (mra_list->mra.data[4] & 0x0C) >> 2;
				fmc_info->base.p1_bank_a_num_sig = mra_list->mra.data[5];
				fmc_info->base.p1_bank_b_num_sig = mra_list->mra.data[6];
				fmc_info->base.p2_bank_a_num_sig = mra_list->mra.data[7];
				fmc_info->base.p2_bank_b_num_sig = mra_list->mra.data[8];
				fmc_info->base.p1_gbt_num_sig = (mra_list->mra.data[9] & 0xF0) >> 4;
				fmc_info->base.p2_gbt_num_sig = (mra_list->mra.data[9] & 0x0F) >> 0;
				fmc_info->base.max_clock_for_tck = mra_list->mra.data[10];
			}
			break;

		default:
			break;
		}
		mra_list = mra_list->mra_next;
	}
} else {
	printf("[GetFMCInfo] fru_info->bia = NULL! Returning\n");
  }
  return;
}

/// Assumes fmc_info is properly populated
tIPMI_FRU_INFO* CreateFRUInfo(tFMCInfo* fmc_info) {
	tIPMI_FRU_INFO* fru;
	alt_u32 addr;
	alt_u8 checksum;
	alt_u8 offset;
	tIPMI_MRA_LIST* mra_list;

	fru = new tIPMI_FRU_INFO;
	if(!fru) { return 0; }

	checksum = 0;
	addr = 0;
	offset = 1; // Starting offset

	fru->bia = &fmc_info->board_info;
	fru->cia = 0;
	fru->iua = 0;
	fru->pia = 0;

	mra_list = fru->mra_list = new tIPMI_MRA_LIST;

	// FMC Base Record Type (OEM)
	CreateMRA_FMCBase(&mra_list->mra, &fmc_info->base);

	// P1
	mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
	CreateMRA_DCLoad(&mra_list->mra, &fmc_info->p1_vadj);

	mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
	CreateMRA_DCLoad(&mra_list->mra, &fmc_info->p1_3p3v);

	mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
	CreateMRA_DCLoad(&mra_list->mra, &fmc_info->p1_12p0v);

	mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
	CreateMRA_DCOutput(&mra_list->mra, &fmc_info->p1_vio_b_m2c);

	mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
	CreateMRA_DCOutput(&mra_list->mra, &fmc_info->p1_vref_a_m2c);

	mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
	CreateMRA_DCOutput(&mra_list->mra, &fmc_info->p1_vref_b_m2c);

	// P2 - if necessary
	if(fmc_info->base.module_size == IPMI_FMC_MODULE_SIZE_DOUBLE) {
		mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
		CreateMRA_DCLoad(&mra_list->mra, &fmc_info->p2_vadj);
		mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
		CreateMRA_DCLoad(&mra_list->mra, &fmc_info->p2_3p3v);
		mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
		CreateMRA_DCLoad(&mra_list->mra, &fmc_info->p2_12p0v);
		mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
		CreateMRA_DCOutput(&mra_list->mra, &fmc_info->p2_vio_b_m2c);
		mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
		CreateMRA_DCOutput(&mra_list->mra, &fmc_info->p2_vref_a_m2c);
		mra_list = mra_list->mra_next = new tIPMI_MRA_LIST;
		CreateMRA_DCOutput(&mra_list->mra, &fmc_info->p2_vref_b_m2c);
	}

	mra_list->mra.version |= IPMI_MRA_EOL;
	mra_list->mra_next = 0;

	// Calculate Header
	fru->header.version = 1;
	fru->header.IUA_Offset = CalculateOffsetOfIUA(&offset, fru->iua);
	fru->header.CIA_Offset = CalculateOffsetOfCIA(&offset, fru->cia);
	fru->header.BIA_Offset = CalculateOffsetOfBIA(&offset, fru->bia);
	fru->header.PIA_Offset = CalculateOffsetOfPIA(&offset, fru->pia);
	fru->header.MRA_Offset = offset;

	return fru;
}

static void CreateMRA_FMCBase(tIPMI_MRA* mra, tIPMI_FMC_BASE* base) {
	static alt_u8 rec_length = 11;
	alt_u8 n;

	mra->type_id = BOARDMANAGEMENT_0_IPMI_RECORD_TYPE_FMC_BASE;
	mra->version = 2;
	mra->rec_checksum = 0;
	mra->rec_length = rec_length;
	mra->data.reserve(2*rec_length);

	mra->data[0] = 0xA2;
	mra->data[1] = 0x12;
	mra->data[2] = 0x00;
	mra->data[3] = 0; // must be zero for subtype and version
	mra->data[4] = ((base->module_size & 0x03) << 6) | ((base->p1_conn_size & 0x03) << 4) | ((base->p2_conn_size & 0x03) << 2);
	mra->data[5] = base->p1_bank_a_num_sig;
	mra->data[6] = base->p1_bank_b_num_sig;
	mra->data[7] = base->p2_bank_a_num_sig;
	mra->data[8] = base->p2_bank_b_num_sig;
	mra->data[9] = ((base->p1_gbt_num_sig & 0x0F) << 4) | ((base->p2_gbt_num_sig & 0x0F));
	mra->data[10] = base->max_clock_for_tck;

	for(n = 0; n < rec_length; ++n) {
		mra->rec_checksum += mra->data[n];
	}

	mra->rec_checksum = 256 - mra->rec_checksum;
}

static void CreateMRA_DCOutput(tIPMI_MRA* mra, tIPMI_DC_OUTPUT* output) {
	static alt_u8 rec_length = 13;
	alt_u8 n;

	mra->type_id = IPMI_RECORD_TYPE_DC_OUTPUT;
	mra->version = 2;
	mra->rec_checksum = 0;
	mra->rec_length = rec_length;
	mra->data.reserve(2*rec_length);

	// Stored LSByte first
	mra->data[0] = ((output->standby & 0x80) << 7) | (output->output_num & 0x0F);
	mra->data[1] = (output->nominal_voltage & 0x00FF) >> 0;
	mra->data[2] = (output->nominal_voltage & 0xFF00) >> 8;
	mra->data[3] = (output->max_neg_volt_dev & 0x00FF) >> 0;
	mra->data[4] = (output->max_neg_volt_dev & 0xFF00) >> 8;
	mra->data[5] = (output->max_pos_volt_dev & 0x00FF) >> 0;
	mra->data[6] = (output->max_pos_volt_dev & 0xFF00) >> 8;
	mra->data[7] = (output->ripple_noise_pk2pk & 0x00FF) >> 0;
	mra->data[8] = (output->ripple_noise_pk2pk & 0xFF00) >> 8;
	mra->data[9] = (output->min_current_draw & 0x00FF) >> 0;
	mra->data[10] = (output->min_current_draw & 0xFF00) >> 8;
	mra->data[11] = (output->max_current_draw & 0x00FF) >> 0;
	mra->data[12] = (output->max_current_draw & 0xFF00) >> 8;

	for(n = 0; n < rec_length; ++n) {
		mra->rec_checksum += mra->data[n];
	}

	mra->rec_checksum = 256 - mra->rec_checksum;
}

static void CreateMRA_DCLoad(tIPMI_MRA* mra, tIPMI_DC_LOAD* load) {
	static alt_u8 rec_length = 13;
	alt_u8 n;

	mra->type_id = IPMI_RECORD_TYPE_DC_LOAD;
	mra->version = 2;
	mra->rec_checksum = 0;
	mra->rec_length = rec_length;
	mra->data.reserve(2*rec_length);

	mra->data[0] = load->output_num & 0x0F;
	mra->data[1] = (load->nominal_voltage & 0x00FF) >> 0;
	mra->data[2] = (load->nominal_voltage & 0xFF00) >> 8;
	mra->data[3] = (load->max_neg_volt_dev & 0x00FF) >> 0;
	mra->data[4] = (load->max_neg_volt_dev & 0xFF00) >> 8;
	mra->data[5] = (load->max_pos_volt_dev & 0x00FF) >> 0;
	mra->data[6] = (load->max_pos_volt_dev & 0xFF00) >> 8;
	mra->data[7] = (load->ripple_noise_pk2pk & 0x00FF) >> 0;
	mra->data[8] = (load->ripple_noise_pk2pk & 0xFF00) >> 8;
	mra->data[9] = (load->min_current_draw & 0x00FF) >> 0;
	mra->data[10] = (load->min_current_draw & 0xFF00) >> 8;
	mra->data[11] = (load->max_current_draw & 0x00FF) >> 0;
	mra->data[12] = (load->max_current_draw & 0xFF00) >> 8;

	for(n = 0; n < rec_length; ++n) {
		mra->rec_checksum += mra->data[n];
	}

	mra->rec_checksum = 256 - mra->rec_checksum;
}

static alt_u8 CalculateOffsetOfIUA(alt_u8* offset, tIPMI_IUA* area) {
	alt_u8 original_offset;

	original_offset = *offset;

	if(area) { (*offset)++; } else { original_offset = 0; }

	return original_offset;
}

static alt_u8 CalculateOffsetOfCIA(alt_u8* offset, tIPMI_CIA* area) {
	alt_u8 cnt;
	alt_u8 original_offset;

	original_offset = *offset;
	cnt = 0;

	if(area) {
		cnt += 1; // Version
		cnt += 1; // Length
		cnt += 1; // Type
		cnt += 1; // Part Number
		cnt += area->part_num.num_bytes;
		cnt += 1; // Serial Number
		cnt += area->serial_num.num_bytes;
		cnt += 1; // End of Fields
		while((cnt % 8) != 7) { cnt++; } // Count required padding, if any
		cnt += 1; // Checksum
	} else {
		original_offset = 0;
	}

	(*offset) += (cnt / 8);

	return original_offset;
}

static alt_u8 CalculateOffsetOfBIA(alt_u8* offset, tIPMI_BIA* area) {
	alt_u8 cnt;
	alt_u8 original_offset;

	original_offset = *offset;
	cnt = 0;

	if(area) {
		cnt += 1; // Version
		cnt += 1; // Length
		cnt += 1; // Language code
		cnt += 3; // Datetime
		cnt += 1; // Manufacturer
		cnt += area->manufacturer.num_bytes;
		cnt += 1; // Product Name
		cnt += area->product.num_bytes;
		cnt += 1; // Serial Number
		cnt += area->serial_num.num_bytes;
		cnt += 1; // Part Number
		cnt += area->part_num.num_bytes;
		cnt += 1; // FRU - Added to match 4DSP style, allowed to be NULL in spec
		cnt += area->FRU_File_Id.num_bytes;
		cnt += 1; // End of Fields
		while((cnt % 8) != 7) { cnt++; } // Count required padding, if any
		cnt += 1; // Checksum
	} else {
		original_offset = 0;
	}

	(*offset) += (cnt / 8);

	return original_offset;
}

static alt_u8 CalculateOffsetOfPIA(alt_u8* offset, tIPMI_PIA* area) {
	alt_u8 cnt;
	alt_u8 original_offset;

	original_offset = *offset;
	cnt = 0;

	if(area) {
		cnt += 1; // Version
		cnt += 1; // Length
		cnt += 1; // Language code
		cnt += 1; // Manufacturer
		cnt += area->manufacturer.num_bytes;
		cnt += 1; // Product Name
		cnt += area->product.num_bytes;
		cnt += 1; // Part Number
		cnt += area->part_num.num_bytes;
		cnt += 1; // Product version
		cnt += area->product_ver.num_bytes;
		cnt += 1; // Serial Number
		cnt += area->serial_num.num_bytes;
		cnt += 1; // Asset Tag
		cnt += area->asset_tag.num_bytes;
		cnt += 1; // FRU - Added to match 4DSP style, allowed to be NULL in spec
		cnt += area->FRU_File_Id.num_bytes;
		cnt += 1; // End of Fields
		while((cnt % 8) != 7) { cnt++; } // Count required padding, if any
		cnt += 1; // Checksum
	} else {
		original_offset = 0;
	}

	(*offset) += (cnt / 8);

	return original_offset;
}
