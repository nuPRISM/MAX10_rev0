/*
 * ipmi.c
 *
 *  Created on: 2013-05-15
 *      Author: bryerton
 */
#include <stdio.h>
#include <stdlib.h>
#include "ipmi.h"
#include "basedef.h"
#include <string>
extern "C" {
#include "mem.h"
#include "my_mem_defs.h"

}

void GetTypeLength(tIPMI_TypeLength* tl, alt_u8 data);
alt_u8 ConvertTypeLengthToByte(tIPMI_TypeLength* tl);

alt_u8* GetField(pfnReadByte ReadByte, alt_u32* addr, alt_u8* checksum, tIPMI_TypeLength* tl_field, alt_u8 required_field);
std::string Get_String_Field(pfnReadByte ReadByte, alt_u32* addr, alt_u8* checksum, tIPMI_TypeLength* tl_field, alt_u8 required_field);

void WriteField(pfnWriteByte WriteByte, alt_u32* addr, alt_u8* checksum, tIPMI_TypeLength* tl_field, alt_u8* data, alt_u8 required_field);

ipmi_err ReadHeader(pfnReadByte ReadByte, tIPMI_CommonHeader* header);
ipmi_err ReadIUA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_IUA* header);
ipmi_err ReadBIA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_BIA* header);
ipmi_err ReadCIA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_CIA* header);
ipmi_err ReadPIA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_PIA* header);
ipmi_err ReadMRA(pfnReadByte ReadByte, alt_u32 offset, tIPMI_MRA_LIST* mra_start);

ipmi_err WriteHeader(pfnWriteByte WriteByte, tIPMI_CommonHeader* header);
ipmi_err WriteIUA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_IUA* area);
ipmi_err WriteCIA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_CIA* area);
ipmi_err WriteBIA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_BIA* area);
ipmi_err WritePIA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_PIA* area);
ipmi_err WriteMRA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_MRA_LIST* mra_list);

ipmi_err IPMI_GetInfo(pfnReadByte ReadByte, tIPMI_FRU_INFO* fmc) {
	ipmi_err err;

	if(!fmc) { return IPMI_ERR_OUT_OF_MEMORY; }

	// Read in Header
	if(ReadHeader(ReadByte, &fmc->header) == IPMI_ERR_OK) {
		fmc->iua = 0;
		if(fmc->header.IUA_Offset) {
			fmc->iua = new tIPMI_IUA;
			err = ReadIUA(ReadByte, fmc->header.IUA_Offset, fmc->iua);
		}

		fmc->cia = 0;
		if(fmc->header.CIA_Offset) {
			 fmc->cia = new tIPMI_CIA;
			err = ReadCIA(ReadByte, fmc->header.CIA_Offset, fmc->cia);
		}

		fmc->bia = 0;
		if(fmc->header.BIA_Offset) {
			fmc->bia = new tIPMI_BIA;
			err = ReadBIA(ReadByte, fmc->header.BIA_Offset, fmc->bia);
		}

		fmc->pia = 0;
		if(fmc->header.PIA_Offset) {
			fmc->pia = new tIPMI_PIA;
			err = ReadPIA(ReadByte, fmc->header.PIA_Offset, fmc->pia);
		}

		fmc->mra_list = 0;
		if(fmc->header.MRA_Offset) {
			fmc->mra_list = new tIPMI_MRA_LIST;
			err = ReadMRA(ReadByte, fmc->header.MRA_Offset, fmc->mra_list);
		}
	}

	return err;
}

ipmi_err IPMI_WriteInfo(pfnWriteByte WriteByte, tIPMI_FRU_INFO* fmc) {

	if(!fmc) { return IPMI_ERR_OUT_OF_MEMORY; }

	WriteHeader(WriteByte, &fmc->header);
	WriteIUA(WriteByte, fmc->header.IUA_Offset, fmc->iua);
	WriteCIA(WriteByte, fmc->header.CIA_Offset, fmc->cia);
	WriteBIA(WriteByte, fmc->header.BIA_Offset, fmc->bia);
	WritePIA(WriteByte, fmc->header.PIA_Offset, fmc->pia);
	WriteMRA(WriteByte, fmc->header.MRA_Offset, fmc->mra_list);

	return IPMI_ERR_OK;
}

ipmi_err WriteHeader(pfnWriteByte WriteByte, tIPMI_CommonHeader* header) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;

	if(!header) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = 0;
	err = IPMI_ERR_OK;
	WriteByte(addr++, header->version, &checksum);
	WriteByte(addr++, header->IUA_Offset, &checksum);
	WriteByte(addr++, header->CIA_Offset, &checksum);
	WriteByte(addr++, header->BIA_Offset, &checksum);
	WriteByte(addr++, header->PIA_Offset, &checksum);
	WriteByte(addr++, header->MRA_Offset, &checksum);
	WriteByte(addr++, 0, &checksum); // PAD

	// Get distance to zero
	WriteByte(addr++, (256 - checksum), &checksum);

	if(checksum != 0) { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err WriteIUA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_IUA* area) {

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	WriteByte((offset * 8), area->version, 0);

	return IPMI_ERR_OK;
}

ipmi_err WriteCIA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_CIA* area) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	WriteByte(addr++, area->version, &checksum);
	WriteByte(addr++, area->length, &checksum);
	WriteByte(addr++, area->type, &checksum);
	WriteField(WriteByte, &addr, &checksum, &area->part_num, (alt_u8 *) area->part_num_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->serial_num,(alt_u8 *) area->serial_num_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, 0, 0, 0); 	// End of Fields

	// Get distance to zero
	WriteByte(addr++, 256 - checksum, &checksum);

	if(checksum != 0) { err =  IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err WriteBIA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_BIA* area) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	WriteByte(addr++, area->version, &checksum);
	WriteByte(addr++, area->length, &checksum);
	WriteByte(addr++, area->lang_code, &checksum);
	WriteByte(addr++, (area->mfg_datetime >>  0) & 0xFF, &checksum);
	WriteByte(addr++, (area->mfg_datetime >>  8) & 0xFF, &checksum);
	WriteByte(addr++, (area->mfg_datetime >> 16) & 0xFF, &checksum);
	WriteField(WriteByte, &addr, &checksum, &area->manufacturer, (alt_u8 *) area->manufacturer_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->product,(alt_u8 *)  area->product_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->serial_num,(alt_u8 *)  area->serial_num_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->part_num,(alt_u8 *)  area->part_num_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->FRU_File_Id,(alt_u8 *)  area->FRU_File_Id_bytes.c_str(), 0);

	// Get distance to zero
	WriteByte(addr++, 256 - checksum, &checksum);

	if(checksum != 0) { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err WritePIA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_PIA* area) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	WriteByte(addr++, area->version, &checksum);
	WriteByte(addr++, area->length, &checksum);
	WriteByte(addr++, area->lang_code, &checksum);
	WriteField(WriteByte, &addr, &checksum, &area->manufacturer, (alt_u8 *) area->manufacturer_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->product,(alt_u8 *) area->product_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->part_num,(alt_u8 *) area->part_num_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->product_ver,(alt_u8 *) area->product_ver_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->serial_num,(alt_u8 *) area->serial_num_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->asset_tag,(alt_u8 *) area->asset_tag_bytes.c_str(), 1);
	WriteField(WriteByte, &addr, &checksum, &area->FRU_File_Id,(alt_u8 *) area->FRU_File_Id_bytes.c_str(), 0);
	WriteField(WriteByte, &addr, &checksum, 0, 0, 0); 	// End of Fields

	// Get distance to zero
	WriteByte(addr++, 256 - checksum, &checksum);

	if(checksum != 0) { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err WriteMRA(pfnWriteByte WriteByte, alt_u8 offset, tIPMI_MRA_LIST* mra_list) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;
	alt_u8  n;

	if(!mra_list) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	do {
		// Add in End Of List bit if necessary
		if(!mra_list->mra_next) { mra_list->mra.version |= IPMI_MRA_EOL; }

		// Write MRA Header
		WriteByte(addr++, mra_list->mra.type_id, &checksum);
		WriteByte(addr++, mra_list->mra.version, &checksum);
		WriteByte(addr++, mra_list->mra.rec_length, &checksum);
		WriteByte(addr++, mra_list->mra.rec_checksum, &checksum);
		WriteByte(addr++, 256 - checksum, &checksum);

		// Write MRA Data
		for(n = 0; n < mra_list->mra.rec_length; ++n) {
			WriteByte(addr++, mra_list->mra.data[n], 0);
		}

		mra_list = mra_list->mra_next;
	} while((mra_list != 0) && (checksum == 0));

	if(checksum != 0) { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err ReadHeader(pfnReadByte ReadByte, tIPMI_CommonHeader* header) {
	ipmi_err err;
	alt_u8 checksum;
	alt_u32 addr;

	addr = 0;
	checksum = 0;
	err = IPMI_ERR_OK;
	header->version 	= ReadByte(addr++, &checksum) & 0x0F;
	header->IUA_Offset 	= ReadByte(addr++, &checksum);
	header->CIA_Offset 	= ReadByte(addr++, &checksum);
	header->BIA_Offset  = ReadByte(addr++, &checksum);
	header->PIA_Offset 	= ReadByte(addr++, &checksum);
	header->MRA_Offset 	= ReadByte(addr++, &checksum);

	// Read PAD
	ReadByte(addr++, &checksum);

	// Read Checksum
	ReadByte(addr++, &checksum);

	// zero on success
	if(checksum != 0)  { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err ReadIUA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_IUA* area) {
	alt_u8 checksum;
	alt_u32 addr;

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;

	area->version = ReadByte(addr++, 0);

	return IPMI_ERR_OK;
}



// Returns zero on success
ipmi_err ReadBIA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_BIA* area) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	area->version = ReadByte(addr++, &checksum);
	area->length  = ReadByte(addr++, &checksum);
	area->lang_code = ReadByte(addr++, &checksum);
	area->mfg_datetime  = ReadByte(addr++, &checksum) <<  0;
	area->mfg_datetime |= ReadByte(addr++, &checksum) <<  8;
	area->mfg_datetime |= ReadByte(addr++, &checksum) << 16;

	area->manufacturer_bytes 	= Get_String_Field(ReadByte, &addr, &checksum, &area->manufacturer, 1) ;
	area->product_bytes 		= Get_String_Field(ReadByte, &addr, &checksum, &area->product, 1)      ;
	area->serial_num_bytes 		= Get_String_Field(ReadByte, &addr, &checksum, &area->serial_num, 1)   ;
	area->part_num_bytes 		= Get_String_Field(ReadByte, &addr, &checksum, &area->part_num, 1)     ;
	area->FRU_File_Id_bytes 	= Get_String_Field(ReadByte, &addr, &checksum, &area->FRU_File_Id, 0)  ;

	// Parse out the remain fields, unused except for checksumming purposes
	GetField(ReadByte, &addr, &checksum, 0, 0);

	// Read Checksum
	if(checksum != 0)  { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err ReadCIA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_CIA* area) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	area->version = ReadByte(addr++, &checksum);
	area->length  = ReadByte(addr++, &checksum);
	area->type	= ReadByte(addr++, &checksum);

	area->part_num_bytes 	= Get_String_Field(ReadByte, &addr, &checksum, &area->part_num, 1);
	area->serial_num_bytes 	= Get_String_Field(ReadByte, &addr, &checksum, &area->serial_num, 1);

	// Get Remaining fields
	GetField(ReadByte, &addr, &checksum, 0, 0);

	// Read Checksum
	if(checksum != 0)  { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err ReadPIA(pfnReadByte ReadByte, alt_u32 offset,  tIPMI_PIA* area) {
	ipmi_err err;
	alt_u32 addr;
	alt_u8  checksum;

	if(!area) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	area->version = ReadByte(addr++, &checksum);
	area->length  = ReadByte(addr++, &checksum);
	area->lang_code = ReadByte(addr++, &checksum);

	area->manufacturer_bytes 	= Get_String_Field(ReadByte, &addr, &checksum, &area->manufacturer, 1);
	area->product_bytes 		= Get_String_Field(ReadByte, &addr, &checksum, &area->product, 1)     ;
	area->part_num_bytes 		= Get_String_Field(ReadByte, &addr, &checksum, &area->part_num, 1)    ;
	area->product_ver_bytes 	= Get_String_Field(ReadByte, &addr, &checksum, &area->product_ver, 1) ;
	area->serial_num_bytes 		= Get_String_Field(ReadByte, &addr, &checksum, &area->serial_num, 1)  ;
	area->asset_tag_bytes 		= Get_String_Field(ReadByte, &addr, &checksum, &area->asset_tag, 1)   ;
	area->FRU_File_Id_bytes 	= Get_String_Field(ReadByte, &addr, &checksum, &area->FRU_File_Id, 0) ;

	// Get Remaining fields
	GetField(ReadByte, &addr, &checksum, 0, 0);

	// Read Checksum
	if(checksum != 0)  { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

ipmi_err ReadMRA(pfnReadByte ReadByte, alt_u32 offset, tIPMI_MRA_LIST* mra_start) {
	ipmi_err err;
	alt_u32 i;
	alt_u32 addr;
	alt_u8 checksum;
	tIPMI_MRA_LIST* mra_list;

	if(!mra_start) { return IPMI_ERR_OUT_OF_MEMORY; }

	checksum = 0;
	addr = offset * 8;
	err = IPMI_ERR_OK;

	mra_list = mra_start;	// We don't want to move the start of the list by accident
	do {
		mra_list->mra.type_id = ReadByte(addr++, &checksum);
		mra_list->mra.version = ReadByte(addr++, &checksum);
		mra_list->mra.rec_length = ReadByte(addr++, &checksum);
		mra_list->mra.rec_checksum = ReadByte(addr++, &checksum);
		// Get Checksum
		ReadByte(addr++, &checksum);
		// If the checksum fails, something has gone really wrong, don't go trying to read a bad length, just bail
		if(checksum != 0) { break; }

		// Grab available bytes
		if(mra_list->mra.rec_length) {
			checksum = mra_list->mra.rec_checksum;
			mra_list->mra.data.reserve(2*mra_list->mra.rec_length);
			for(i=0; i < mra_list->mra.rec_length; ++i) {
				mra_list->mra.data[i] = ReadByte(addr++, &checksum);
			}
			// Bail if record checksum fails
			if(checksum != 0) { break; }
		}

		// Was this the last record?
		mra_list->mra_next = 0;
		if((mra_list->mra.version & IPMI_MRA_EOL) != IPMI_MRA_EOL) {
			 mra_list->mra_next = new tIPMI_MRA_LIST;
		}
		mra_list = mra_list->mra_next;

		// Only continue if there is something left!
	} while(mra_list != 0);

	// Read Checksum
	if(checksum != 0)  { err = IPMI_ERR_BAD_CHECKSUM; }

	return err;
}

void GetTypeLength(tIPMI_TypeLength* tl, alt_u8 data) {
	if(!tl) { return; }

	tl->type_code = (data & IPMI_TL_CODE_MASK) >> IPMI_TL_CODE_SHFT;
	tl->num_bytes = (data & IPMI_TL_LEN_MASK) >> IPMI_TL_LEN_SHFT;
}

alt_u8 ConvertTypeLengthToByte(tIPMI_TypeLength* tl) {
	if(!tl) { return 0; }

	return ((tl->type_code << IPMI_TL_CODE_SHFT) | tl->num_bytes);
}

void WriteField(pfnWriteByte WriteByte, alt_u32* addr, alt_u8* checksum, tIPMI_TypeLength* tl_field, alt_u8* data, alt_u8 required_field) {
	tIPMI_TypeLength tl;
	alt_u32 n;

	if(!tl_field) {
		tl_field = &tl;
		tl_field->num_bytes = 0;
		tl_field->type_code = 0;
	}

	// Write TypeLength Byte
	WriteByte((*addr)++, ConvertTypeLengthToByte(tl_field), checksum);

	// Write NULL byte if required field and no other data will be written
	if ((tl_field->num_bytes == 0) || (!data)) {
		if(required_field) {
			WriteByte((*addr)++, 0, checksum);
		}

		// Write End of Record and finish padding
		WriteByte((*addr)++, IPMI_TL_EOR, checksum);
		while(((*addr) % 8) != 7) {
			WriteByte((*addr)++, 0, checksum);
		}
	} else {
		// This 'else' isn't strictly necessary, but it looks more 'reliable' :)
		// Write bytes
		for(n = 0; (n < tl_field->num_bytes) && (data); ++n) {
			WriteByte((*addr)++, data[n], checksum);
		}
	}
}

alt_u8* GetField(pfnReadByte ReadByte, alt_u32* addr, alt_u8* checksum, tIPMI_TypeLength* tl_field, alt_u8 required_field) {
	alt_u8* byte_array;
	alt_u8 i;
	tIPMI_TypeLength tl;

	// Skip an else and preset this to zero
	byte_array = 0;

	if(tl_field) {
		GetTypeLength(tl_field, ReadByte((*addr)++, checksum));

		// Skip out if we hit an End of Record (may be malformed record, but that is unrecoverable)
		if(ConvertTypeLengthToByte(tl_field) == IPMI_TL_EOR) { return 0; }

		if(tl_field->num_bytes) {
			byte_array = (alt_u8*)  my_mem_calloc(1,tl_field->num_bytes+1);
			for(i=0; (i < tl_field->num_bytes) && (byte_array != 0); i++) {
				byte_array[i] = ReadByte((*addr)++, checksum);
			}
			byte_array[tl_field->num_bytes]='\0'; //in case this is a string
		} else if(required_field) {
			(*addr)++;
		}
	} else {
		// No TypeLength field given, just parse till end of record (so we can verify checksum)
		GetTypeLength(&tl, ReadByte((*addr)++, checksum));

		// This will deal with zero value bytes OK
		while(ConvertTypeLengthToByte(&tl) != IPMI_TL_EOR) {
			// Parse through bytes
			for(i=0; i<tl.num_bytes;++i) {
				// Just read bytes and ignore result
				ReadByte((*addr)++, checksum);
			}
			// Read next type/length header
			GetTypeLength(&tl, ReadByte((*addr)++, checksum));
		}

		// Do the last of the padding (if necessary)
		while(((*addr) % 8) != 7) {
			// Read empty bytes, these should all be zero
			ReadByte((*addr)++, checksum);
		}

		// Read checksum
		ReadByte((*addr)++, checksum);
	}


	return byte_array;
}


std::string Get_String_Field(pfnReadByte ReadByte, alt_u32* addr, alt_u8* checksum, tIPMI_TypeLength* tl_field, alt_u8 required_field) {
	std::string byte_array;
	alt_u8 i;
	tIPMI_TypeLength tl;

	// Skip an else and preset this to zero
	byte_array = "";

	if(tl_field) {
		GetTypeLength(tl_field, ReadByte((*addr)++, checksum));

		// Skip out if we hit an End of Record (may be malformed record, but that is unrecoverable)
		if(ConvertTypeLengthToByte(tl_field) == IPMI_TL_EOR) { return 0; }

		if(tl_field->num_bytes) {
			for(i=0; (i < tl_field->num_bytes); i++) {
				byte_array.append(1,(char) ReadByte((*addr)++, checksum));
			}
		} else if(required_field) {
			(*addr)++;
		}
		printf("Get_String_Field: returning: %s\n",byte_array.c_str());

	} else {
		printf("Get_String_Field: No Typelength field given, skipping to end of record\n");
		// No TypeLength field given, just parse till end of record (so we can verify checksum)
		GetTypeLength(&tl, ReadByte((*addr)++, checksum));

		// This will deal with zero value bytes OK
		while(ConvertTypeLengthToByte(&tl) != IPMI_TL_EOR) {
			// Parse through bytes
			for(i=0; i<tl.num_bytes;++i) {
				// Just read bytes and ignore result
				ReadByte((*addr)++, checksum);
			}
			// Read next type/length header
			GetTypeLength(&tl, ReadByte((*addr)++, checksum));
		}

		// Do the last of the padding (if necessary)
		while(((*addr) % 8) != 7) {
			// Read empty bytes, these should all be zero
			ReadByte((*addr)++, checksum);
		}

		// Read checksum
		ReadByte((*addr)++, checksum);
		printf("Get_String_Field: Skipped to end of record\n");
	}


	return byte_array;
}
