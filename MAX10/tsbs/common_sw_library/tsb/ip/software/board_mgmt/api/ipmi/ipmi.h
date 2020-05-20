/*
 * ipmi.h
 *
 *  Created on: 2013-04-30
 *      Author: bryerton
 */

#ifndef IPMI_H_
#define IPMI_H_

#include <alt_types.h>
#include "basedef.h"

#include "jansson.hpp"
#include "json_serializer_class.h"
#include <string>

#define IPMI_TYPE_CODE_BINARY			0x00
#define IPMI_TYPE_CODE_BCDPLUS			0x01
#define IPMI_TYPE_CODE_6BITASCII		0x02
#define IPMI_TYPE_CODE_INTERPRETED		0x03

#define IPMI_CHASSIS_TYPE_OTHER			0x01
#define IPMI_CHASSIS_TYPE_UNKNOWN		0x02
#define IPMI_CHASSIS_TYPE_DESKTOP		0x03
#define IPMI_CHASSIS_TYPE_LP_DESKTOP	0x04
#define IPMI_CHASSIS_TYPE_PIZZA_BOX		0x05
#define IPMI_CHASSIS_TYPE_MINI_TOWER	0x06
#define IPMI_CHASSIS_TYPE_TOWER			0x07
#define IPMI_CHASSIS_TYPE_PORTABLE		0x08
#define IPMI_CHASSIS_TYPE_LAPTOP		0x09
#define IPMI_CHASSIS_TYPE_NOTEBOOK		0x0A
#define IPMI_CHASSIS_TYPE_HANDHELD		0x0B
#define IPMI_CHASSIS_TYPE_DOCKING_STAT	0x0C
#define IPMI_CHASSIS_TYPE_ALL_IN_ONE	0x0D
#define IPMI_CHASSIS_TYPE_SUB_NOTEBOOK	0x0E
#define IPMI_CHASSIS_TYPE_SPACE_SAVING	0x0F
#define IPMI_CHASSIS_TYPE_LUNCH_BOX		0x10
#define IPMI_CHASSIS_TYPE_MAIN_SERVER	0x11
#define IPMI_CHASSIS_TYPE_EXPANSION		0x12
#define IPMI_CHASSIS_TYPE_SUB_CHASSIS	0x13
#define IPMI_CHASSIS_TYPE_BUS_EXPANSION	0x14
#define IPMI_CHASSIS_TYPE_PERIPHERAL	0x15
#define IPMI_CHASSIS_TYPE_RAID			0x16
#define IPMI_CHASSIS_TYPE_RACK_MOUNT	0x17

#define IPMI_RECORD_TYPE_POWER_SUPPLY	0x00
#define IPMI_RECORD_TYPE_DC_OUTPUT		0x01
#define IPMI_RECORD_TYPE_DC_LOAD		0x02
#define IPMI_RECORD_TYPE_MANAGEMENT_ACC	0x03
#define BOARDMANAGEMENT_0_IPMI_RECORD_TYPE_BASE_COMPAT	0x04
#define IPMI_RECORD_TYPE_EXT_COMPAT		0x05
// Range for Reserved MRA Record Types
#define IPMI_RECORD_TYPE_RESERVED_START 0x06
#define IPMI_RECORD_TYPE_RESERVED_END	0xBF
// Range for OEM MRA Record Types
#define IPMI_RECORD_TYPE_OEM_START		0xC0
#define IPMI_RECORD_TYPE_OEM_END		0xFF

#define IPMI_TL_CODE_MASK 				0xC0
#define IPMI_TL_LEN_MASK				0x3F
#define IPMI_TL_CODE_SHFT				6
#define IPMI_TL_LEN_SHFT				0
#define IPMI_TL_EOR						0xC1

#define IPMI_ERR_OK						0
#define IPMI_ERR_OUT_OF_MEMORY			1
#define IPMI_ERR_BAD_CHECKSUM			2

class tIPMI_TypeLength : public json_serializer_class {

public:
	alt_u8 type_code;		// 2 bits - MSB
	alt_u8 num_bytes;		// 6 bits - LSB
    json::Value get_json_object();
    tIPMI_TypeLength() {
    	type_code = 0;
    	num_bytes = 0;
    }
};

class tIPMI_CommonHeader : public json_serializer_class {

public:
	alt_u8 version;		// Common Header Format Version 7:4 reserved. 0000b. 3:0 = 0x1h for this spec
	alt_u8 IUA_Offset; 	// Internal Use Area Starting Offset (in multiples of 8 bytes) 0x0h indicates not used
	alt_u8 CIA_Offset;	// Chassis Info Area ""
	alt_u8 BIA_Offset;	// Board Info Area "" ""
	alt_u8 PIA_Offset;	// Product Info Area "" ""
	alt_u8 MRA_Offset;	// Multi-Record Area "" ""
    json::Value get_json_object();
    tIPMI_CommonHeader() {
    version   = 0;
    IUA_Offset= 0;
    CIA_Offset= 0;
    BIA_Offset= 0;
    PIA_Offset= 0;
    MRA_Offset= 0;

    }
} ;

#define IPMI_IUA_VERSION_MASK	0x0F
#define IPMI_IUA_VERSION_SHFT	0

class tIPMI_IUA : public json_serializer_class {

public:
	alt_u8 version;		//  7:4 reserved. 0000b. 3:0 = 0x1h for this spec
	// Free to add anything desired in here, not currently used
    json::Value get_json_object();
    tIPMI_IUA() {
    	version = 0;
    }
};

class tIPMI_CIA : public json_serializer_class {

public:
	alt_u8 version;
	alt_u8 length;
	alt_u8 type;
	tIPMI_TypeLength part_num;
	std::string part_num_bytes;
	tIPMI_TypeLength serial_num;
	std::string serial_num_bytes;
    json::Value get_json_object();
    tIPMI_CIA() {
    }
};

class tIPMI_BIA : public json_serializer_class {

public:
	alt_u8 version;
	alt_u8 length;
	alt_u8 lang_code;
	alt_u32 mfg_datetime; // minutes since 0:00 1/1/96 LSB (little endian)
	tIPMI_TypeLength manufacturer;
	std::string manufacturer_bytes;
	tIPMI_TypeLength product;
	std::string product_bytes;
	tIPMI_TypeLength serial_num;
	std::string serial_num_bytes;
	tIPMI_TypeLength part_num;
	std::string part_num_bytes;
	tIPMI_TypeLength FRU_File_Id;
	std::string FRU_File_Id_bytes;
    json::Value get_json_object();
    tIPMI_BIA() {
       version = 0;
       length = 0;
       lang_code = 0;
       mfg_datetime = 0;

    }
    void set_to (const tIPMI_BIA& x) {
 version    	    = x.version;
 length    		    = x.length;
 lang_code    		= x.lang_code;
 mfg_datetime     	=	 x.mfg_datetime;
 manufacturer    	=	 x.manufacturer;
 manufacturer_bytes=    		 x.manufacturer_bytes;
 product    		= x.product;
 product_bytes    	=	 x.product_bytes;
 serial_num    	=	 x.serial_num;
 serial_num_bytes  =  		 x.serial_num_bytes;
 part_num    		= x.part_num;
 part_num_bytes    =		 x.part_num_bytes;
 FRU_File_Id    	=	 x.FRU_File_Id;
 FRU_File_Id_bytes =   		 x.FRU_File_Id_bytes;
    }

    /*
    tIPMI_BIA& operator=(const tIPMI_BIA& x) {

       this->version = x.version;
       this->length = x.length;
       this->lang_code = x.lang_code;
       this->mfg_datetime = x.mfg_datetime;
       this->manufacturer = x.manufacturer;
       memcpy((char *)this->manufacturer_bytes,(char *)x.manufacturer_bytes,x.manufacturer.num_bytes);
       this->product = x.product;
       memcpy((char *)this->product_bytes,(char *)x.product_bytes,x.product.num_bytes);
       this->serial_num = x.serial_num;
       memcpy((char *)this->serial_num_bytes,(char *)x.serial_num_bytes,x.serial_num.num_bytes);
       this->part_num = x.part_num;
       memcpy((char *)this->part_num_bytes,(char *)x.part_num_bytes,x.part_num.num_bytes);
       this->FRU_File_Id = x.FRU_File_Id;
       memcpy((char *)this->FRU_File_Id_bytes,(char *)x.FRU_File_Id_bytes,x.FRU_File_Id.num_bytes);
       return *this;
    }
    */
} ;

class tIPMI_PIA : public json_serializer_class {

public:
	alt_u8 version;
	alt_u8 length;
	alt_u8 lang_code;
	tIPMI_TypeLength manufacturer;
	std::string manufacturer_bytes;
	tIPMI_TypeLength product;
	std::string product_bytes;
	tIPMI_TypeLength part_num;
	std::string part_num_bytes;
	tIPMI_TypeLength product_ver;
	std::string product_ver_bytes;
	tIPMI_TypeLength serial_num;
	std::string serial_num_bytes;
	tIPMI_TypeLength asset_tag;
	std::string asset_tag_bytes;
	tIPMI_TypeLength FRU_File_Id;
	std::string FRU_File_Id_bytes;
    json::Value get_json_object();
    tIPMI_PIA () {
    }
};

class tIPMI_MRA : public json_serializer_class {

public:
	alt_u8 type_id;
	alt_u8 version; // 7:7 - end of list, 6:4 - reserved 000b, 3:0 - record format version, 0x02h
	alt_u8 rec_length;
	alt_u8 rec_checksum;
	std::string data; 	// Associated Data... cast into appropriate struct
    json::Value get_json_object();
    tIPMI_MRA() {
    	 type_id=0;
    	 version=0; // 7:
    	 rec_length=0;
    	 rec_checksum=0;

    }
} ;

#define IPMI_MRA_EOL		0x80
#define IPMI_MRA_VERSION	0x0F

class tIPMI_MRA_LIST : public json_serializer_class{

public:
	tIPMI_MRA mra;
	tIPMI_MRA_LIST* mra_next;
    json::Value get_json_object();
    tIPMI_MRA_LIST() {
    	mra_next = NULL;
    }
};

class tIPMI_OEM  : public json_serializer_class{

public:
	alt_u8 manufacturer_id[3];
	alt_u8* data;
    json::Value get_json_object();
    tIPMI_OEM() {
    	data = NULL;
    }
} ;

class tIPMI_DC_OUTPUT : public json_serializer_class {

public:
	alt_u8  standby;				// 0x80 MASK - Works in standby mode?
	alt_u8  output_num;			// 0x0F MASK - Output Number
	alt_u16 nominal_voltage;	// 10 mV
	alt_u16 max_neg_volt_dev;	// 10 mV
	alt_u16 max_pos_volt_dev;	// 10 mV
	alt_u16 ripple_noise_pk2pk;	// 10 Hz to 30 MHz (mV)
	alt_u16 min_current_draw;	// mA
	alt_u16 max_current_draw;	// mA
    json::Value get_json_object();
    tIPMI_DC_OUTPUT() {

    	 standby=0;
    	 output_num=0;
    	 nominal_voltage=0;
    	 max_neg_volt_dev=0;
    	 max_pos_volt_dev=0;
    	 ripple_noise_pk2pk=0;
    	 min_current_draw=0;
        max_current_draw=0;
    }
};

class tIPMI_DC_LOAD : public json_serializer_class {

public:
	alt_8 output_num;			// 0x0F MASK
	alt_u16 nominal_voltage;	// 10 mV
	alt_u16 max_neg_volt_dev;	// 10 mV
	alt_u16 max_pos_volt_dev;	// 10 mV
	alt_u16 ripple_noise_pk2pk;	// 10 Hz to 30 MHz (mV)
	alt_u16 min_current_draw;	// mA
	alt_u16 max_current_draw;	// mA
    json::Value get_json_object();
    tIPMI_DC_LOAD(){
    output_num=0;			// 0x0F MASK
    nominal_voltage=0;	// 10 mV
    max_neg_volt_dev=0;	// 10 mV
    max_pos_volt_dev=0;	// 10 mV
    ripple_noise_pk2pk=0;	// 10 Hz to 30 MHz (mV)
    min_current_draw=0;	// mA
    max_current_draw=0;	// mA

    }

} ;

class tIPMI_FRU_INFO : public json_serializer_class {

public:
	tIPMI_CommonHeader header;
	tIPMI_IUA* iua;
	tIPMI_CIA* cia;
	tIPMI_BIA* bia;
	tIPMI_PIA* pia;
	tIPMI_MRA_LIST* mra_list;
    json::Value get_json_object();
    tIPMI_FRU_INFO() {
    	iua = NULL;
    	cia = NULL;
    	bia = NULL;
    	pia	= NULL;
    	mra_list = NULL;
    }
} ;

typedef alt_u8 ipmi_err;

typedef alt_u8 (*pfnReadByte)(alt_u32 addr, alt_u8* checksum);
typedef void   (*pfnWriteByte)(alt_u32 addr, alt_u8 data, alt_u8* checksum);

ipmi_err IPMI_GetInfo(pfnReadByte ReadByte, tIPMI_FRU_INFO* fmc);
ipmi_err IPMI_WriteInfo(pfnWriteByte WriteByte, tIPMI_FRU_INFO* fmc);


#endif /* IPMI_H_ */
