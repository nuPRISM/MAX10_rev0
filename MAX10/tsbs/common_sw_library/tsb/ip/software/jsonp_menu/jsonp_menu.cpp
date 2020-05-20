/*
 * jsonp_menu.cpp
 *
 *  Created on: Mar 14, 2014
 *      Author: yairlinn
 */

#include "jsonp_menu/jsonp_menu.h"

void JSONP_Menu_System_Initialize(jsonp_menu_mapping_type& s_mapStringValues)
{
	s_mapStringValues["callspechandler"] = JSONPevCallSpectrumHandler;
	s_mapStringValues["getspectrumlist"] = JSONPGetSpectrumList;
	s_mapStringValues["capturedac0"] =     JSONPCaptureDAC0;
	s_mapStringValues["captureadcs"] =     JSONPCaptureADCs;
	s_mapStringValues["jsonp"] =           JSONPGetCardStatus;
}


