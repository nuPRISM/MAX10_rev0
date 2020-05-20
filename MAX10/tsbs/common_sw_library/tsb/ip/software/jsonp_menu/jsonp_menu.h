/*
 * jsonp_menu.h
 *
 *  Created on: Mar 14, 2014
 *      Author: yairlinn
 */

#ifndef JSONP_MENU_H_
#define JSONP_MENU_H_
#include <string>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <map>


// Value-Defintions of the different String values
enum JSONP_StringValue {
		JSONPevNotDefined,
		JSONPevCallSpectrumHandler,
		JSONPGetSpectrumList,
		JSONPCaptureDAC0,
		JSONPCaptureADCs,
		JSONPGetCardStatus
};

// Map to associate the strings with the enum values
typedef std::map<std::string, JSONP_StringValue> jsonp_menu_mapping_type;

void JSONP_Menu_System_Initialize(jsonp_menu_mapping_type&);


#endif /* JSONP_MENU_H_ */
