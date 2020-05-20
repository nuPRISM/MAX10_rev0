/*
 * pfl.h
 *
 *  Created on: 2013-05-21
 *      Author: bryerton
 */

#ifndef PFL_H_
#define PFL_H_

#include <alt_types.h>
#include <sys/alt_flash.h>
#include <string>
#include <iostream>
#include <sstream>
#include "basedef.h"

#include "jansson.hpp"
#include "json_serializer_class.h"

#define PFL_ADDR_VERSION	0x80
#define PFL_NUM_PAGES		8
#define PFL_POF_VERSION_7_1	0x03
#define PFL_POF_COMPRESSED	0x04


class tPFL_Page   : public json_serializer_class {

public:
	alt_u8 valid_n;
	alt_u32 start;
	alt_u32 end;
	json::Value get_json_object();
} ;

class tPFL   : public json_serializer_class {

public:
	tPFL_Page page_addr[PFL_NUM_PAGES]; // Page [0-7] Start Addresses
	alt_u8  pof_version;
	json::Value get_json_object();

};

void PFL_GetOptionBits(alt_flash_fd* flash, alt_u32 offset, tPFL* pfl);

#endif /* PFL_H_ */
