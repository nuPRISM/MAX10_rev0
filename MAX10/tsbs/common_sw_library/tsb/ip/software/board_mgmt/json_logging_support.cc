/*
 * json_logging_support.cc
 *
 *  Created on: Sep 13, 2013
 *      Author: yairlinn
 */

#include "board_management.h"
#include "basedef.h"


#include "jansson.hpp"
#include "cpp_utils.h"
#include <string>
#include <iostream>
#include <sstream>
#include "fmc.h"

using namespace std;


#define MAX(a,b) ((b > a) ? b : a)

json::Value tPM::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("pg_2v5",json::Value(pg_2v5));
	jo.set_key("pg_1v8",json::Value(pg_1v8));
	jo.set_key("pg_1v5",json::Value(pg_1v5));
	jo.set_key("pg_1v2",json::Value(pg_1v2));
	jo.set_key("pg_1v1",json::Value(pg_1v1));
	jo.set_key("pg_0v9",json::Value(pg_0v9));
	for (int i = 0; i < NUM_FMC_CARDS; i++) {
		std::ostringstream ostr;
		ostr << "vadj_" << i;
		jo.set_key(ostr.str(),v_adj[i].get_json_object());
	}

	jo.set_key("v_3v3",v_3v3.get_json_object());

	return jo;
}


json::Value tZL9101::get_json_object() {
	json::Value jo(json::object());
	std::string condensed_devid = remove_nonalphanumeric(device_id);
	jo.set_key("device_id"     ,json::Value(condensed_devid         ));
	jo.set_key("pwr_good"      ,json::Value((double) pwr_good       ));
	jo.set_key("internal_temp" ,json::Value((double) internal_temp  ));
	jo.set_key("v_in"          ,json::Value((double) v_in           ));
	jo.set_key("v_out"         ,json::Value((double) v_out          ));
	jo.set_key("v_out_set"     ,json::Value((double) v_out_set      ));
	jo.set_key("i_out"         ,json::Value((double) i_out          ));
	jo.set_key("status"        ,json::Value((double) status         ));
	jo.set_key("stat_vout"	   ,json::Value((double) stat_vout	    ));
	jo.set_key("stat_iout"	   ,json::Value((double) stat_iout	    ));
	jo.set_key("stat_input"	   ,json::Value((double) stat_input	    ));
	jo.set_key("stat_mfr"	   ,json::Value((double) stat_mfr	    ));
	jo.set_key("stat_cml"	   ,json::Value((double) stat_cml	    ));
	jo.set_key("stat_temp" 	   ,json::Value((double) stat_temp 	    ));

	return jo;
}

json::Value tFlash::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("name"             , json::Value((name == "") ?  std::string("Undefined") : name));
	jo.set_key("num_regions"      , json::Value(num_regions));

	return jo;
}


json::Value tSpartan::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("flash_idx",json::Value(flash_idx             ));
	jo.set_key("offset"   ,json::Value(offset                ));
	jo.set_key("spi_base" ,json::Value(spi_base              ));
	jo.set_key("info"     ,json::Value(info.get_json_object()));

	return jo;
}


json::Value tSpartanInfo::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("filename"  , json::Value( (filename == NULL) ? std::string("Undefined"): std::string(filename)));
	jo.set_key("partname"  , json::Value( (partname == NULL) ? std::string("Undefined"): std::string(partname)));
	jo.set_key("board_id"  , json::Value( board_id));
	jo.set_key("datetime"  , json::Value( datetime));
	jo.set_key("length"    , json::Value( length));
	return jo;
}


json::Value tPFL_Page::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("valid_n", json::Value(valid_n));
	jo.set_key("start"  , json::Value(start) );
	jo.set_key("end"    , json::Value(end));

	return jo;
}


json::Value tPFL::get_json_object() {
    json::Value jo(json::object());
    json::Value ja(json::array());
	jo.set_key("pof_version",json::Value(pof_version));

	for (int i = 0; i < PFL_NUM_PAGES; i++) {
	   ja.set_at(i,page_addr[i].get_json_object());
	}

	jo.set_key("page_addr",json::Value(ja));
	return jo;
}

json::Value tTemp::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("board_temp" ,  json::Value(board_temp));
	jo.set_key("strat_temp" ,  json::Value(strat_temp));

	return jo;
}


json::Value tBoard::get_json_object() {
	json::Value jo(json::object());
    json::Value ja(json::array());
	for (int i = 0; i < NUM_SPARTANS; i++) {
		 ja.set_at(i,spartan[i].get_json_object());
	}
	jo.set_key("spartan",ja);

    json::Value ja2(json::array());

	for (int i = 0; i < NUM_FLASH_DEVICES; i++) {
	    ja2.set_at(i,flash[i].get_json_object());
	}
	jo.set_key("flash",ja2);



	jo.set_key("pfl"     , pfl.get_json_object());
	jo.set_key("pm"      , pm.get_json_object());
	jo.set_key("temp"    , temp.get_json_object());
	jo.set_key("user_dip", json::Value(user_dip));


	return jo;
}


json::Value tIPMI_FMC_BASE::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("subtype"            , json::Value(subtype          ));
	jo.set_key("version"            , json::Value(version          ));
	jo.set_key("module_size"        , json::Value(module_size      ));
	jo.set_key("p1_conn_size"       , json::Value(p1_conn_size     ));
	jo.set_key("p2_conn_size"       , json::Value(p2_conn_size     ));
	jo.set_key("p1_bank_a_num_sig"  , json::Value(p1_bank_a_num_sig));
	jo.set_key("p1_bank_b_num_sig"  , json::Value(p1_bank_b_num_sig));
	jo.set_key("p2_bank_a_num_sig"  , json::Value(p2_bank_a_num_sig));
	jo.set_key("p2_bank_b_num_sig"  , json::Value(p2_bank_b_num_sig));
	jo.set_key("p1_gbt_num_sig"     , json::Value(p1_gbt_num_sig   ));
	jo.set_key("p2_gbt_num_sig"     , json::Value(p2_gbt_num_sig   ));
	jo.set_key("max_clock_for_tck"  , json::Value(max_clock_for_tck));

	return jo;

}


json::Value tMIC2080::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("manufacturer_id"       , json::Value(manufacturer_id       ));
	jo.set_key("die_revision"          , json::Value(die_revision          ));
	jo.set_key("local_temp"            , json::Value(local_temp            ));
	jo.set_key("local_temp_low_limit"  , json::Value(local_temp_low_limit  ));
	jo.set_key("local_temp_high_limit" , json::Value(local_temp_high_limit ));
	jo.set_key("local_temp_crit_limit" , json::Value(local_temp_crit_limit ));
	jo.set_key("remote_temp"           , json::Value(remote_temp           ));
	jo.set_key("remote_temp_low_limit" , json::Value(remote_temp_low_limit ));
	jo.set_key("remote_temp_high_limit", json::Value(remote_temp_high_limit));
	jo.set_key("remote_temp_crit_limit", json::Value(remote_temp_crit_limit));


	return jo;

}


json::Value tFMCInfo::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("base"       ,base.get_json_object()      );
	jo.set_key("board_info" ,board_info.get_json_object());
	jo.set_key("p1_vadj"    ,p1_vadj.get_json_object()   );

	return jo;

}


json::Value tIPMI_TypeLength::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("type_code", json::Value(type_code));
	jo.set_key("num_bytes", json::Value(num_bytes));

	return jo;

}

json::Value tIPMI_CommonHeader::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("version"    , json::Value(version   ));
	jo.set_key("IUA_Offset" , json::Value(IUA_Offset));
	jo.set_key("CIA_Offset" , json::Value(CIA_Offset));
	jo.set_key("BIA_Offset" , json::Value(BIA_Offset));
	jo.set_key("PIA_Offset" , json::Value(PIA_Offset));
	jo.set_key("MRA_Offset" , json::Value(MRA_Offset));

	return jo;

}


json::Value tIPMI_CIA::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("version"          , json::Value(version));
	jo.set_key("length"           , json::Value(length));
	jo.set_key("type"             , json::Value(type));
	jo.set_key("part_num"         , part_num.get_json_object());
	jo.set_key("part_num_bytes"   , json::Value((part_num_bytes == "") ?  std::string("Undefined") : std::string(part_num_bytes)));
	jo.set_key("serial_num"       , serial_num.get_json_object());
	jo.set_key("serial_num_bytes" , json::Value((serial_num_bytes == "") ?  std::string("Undefined") : std::string(serial_num_bytes)));

	return jo;

}


json::Value tIPMI_BIA::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("version"           , json::Value(version));
	jo.set_key("length"            , json::Value(length));
	jo.set_key("mfg_datetime"      , json::Value(mfg_datetime));
	jo.set_key("manufacturer"      , manufacturer.get_json_object());
	jo.set_key("manufacturer_bytes",json::Value((manufacturer_bytes == "") ?  std::string("Undefined") : std::string(manufacturer_bytes)));
	jo.set_key("product"           , product.get_json_object());
	jo.set_key("product_bytes"     ,json::Value((product_bytes == "") ?  std::string("Undefined") : std::string(product_bytes)));
    jo.set_key("serial_num"        , serial_num.get_json_object());
	jo.set_key("serial_num_bytes"  ,json::Value((serial_num_bytes == "") ?  std::string("Undefined") :  std::string(serial_num_bytes)));
    jo.set_key("part_num"          , part_num.get_json_object());
	jo.set_key("part_num_bytes"    ,json::Value((part_num_bytes == "") ?  std::string("Undefined") : std::string(part_num_bytes)));
    jo.set_key("FRU_File_Id"       , FRU_File_Id.get_json_object());
	jo.set_key("FRU_File_Id_bytes" ,json::Value((FRU_File_Id_bytes == "") ?  std::string("Undefined") : std::string(FRU_File_Id_bytes)));

	return jo;
}



json::Value tIPMI_PIA::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("version"            ,  json::Value(version));
	jo.set_key("length"             ,  json::Value(length));
	jo.set_key("lang_code"          ,  json::Value(lang_code));
	jo.set_key("manufacturer"       ,  manufacturer.get_json_object());
	jo.set_key("manufacturer_bytes" , json::Value((manufacturer_bytes == "") ?  std::string("Undefined") : std::string(manufacturer_bytes)));
	jo.set_key("product"            ,  product.get_json_object());
	jo.set_key("product_bytes"      , json::Value((product_bytes == "") ?  std::string("Undefined") :  std::string(product_bytes)));
	jo.set_key("part_num"           ,  part_num.get_json_object());
	jo.set_key("part_num_bytes"     , json::Value((part_num_bytes == "") ?  std::string("Undefined") :  std::string(part_num_bytes)));
	jo.set_key("product_ver"        ,  product_ver.get_json_object());
	jo.set_key("product_ver_bytes"  , json::Value((product_ver_bytes == "") ?  std::string("Undefined") :   std::string(product_ver_bytes)));
    jo.set_key("serial_num"         ,  serial_num.get_json_object());
	jo.set_key("serial_num_bytes"   , json::Value((serial_num_bytes == "") ?  std::string("Undefined") :   std::string(serial_num_bytes)));
    jo.set_key("asset_tag"          ,  asset_tag.get_json_object());
	jo.set_key("asset_tag_bytes"    , json::Value((asset_tag_bytes == "") ?  std::string("Undefined") :   std::string(asset_tag_bytes)));
    jo.set_key("FRU_File_Id"        ,  FRU_File_Id.get_json_object());
	jo.set_key("FRU_File_Id_bytes"  , json::Value((FRU_File_Id_bytes == "") ?  std::string("Undefined") :   std::string(FRU_File_Id_bytes)));

	return jo;
}


json::Value tIPMI_MRA::get_json_object() {
		json::Value jo(json::object());
	jo.set_key("type_id"      ,json::Value(type_id)     );
	jo.set_key("version"      ,json::Value(version)     );
	jo.set_key("rec_length"   ,json::Value(rec_length)  );
	jo.set_key("rec_checksum" ,json::Value(rec_checksum));

	return jo;
}



json::Value tIPMI_OEM::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("manufacturer_id",json::Value((manufacturer_id == NULL) ?  std::string("Undefined") :  std::string(std::string((char *)manufacturer_id,3))));
	return jo;
}


json::Value tIPMI_IUA::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("version",json::Value(version));
	return jo;
}

json::Value tIPMI_MRA_LIST::get_json_object() {
	  json::Value jo(json::object());
	  jo.set_key("first_mra_need_to_implement_list",mra.get_json_object());
	  return jo;
  }


json::Value tFMC::get_json_object() {
	 json::Value jo(json::object());
	 jo.set_key("present", json::Value(present))   ;	// FMC Present?
	 jo.set_key("pwr_good",json::Value(pwr_good))   ;		// Power Good?
	 jo.set_key("configured", json::Value(configured));
	 jo.set_key("vadj",   json::Value(vadj))   ;
	 jo.set_key("info",  info.get_json_object())    ; // FMC specific FRU info (mapped to FRU memory)
	 jo.set_key("fru_info", fru_info.get_json_object()) ; // Memory containing all of the found FRU information
	  return jo;
  }

json::Value tIPMI_DC_OUTPUT::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("standby"                ,json::Value(standby)           );
	jo.set_key("output_num"             ,json::Value(output_num)        );
	jo.set_key("nominal_voltage"        ,json::Value(nominal_voltage)   );
	jo.set_key("max_neg_volt_dev"       ,json::Value(max_neg_volt_dev)  );
	jo.set_key("typmax_pos_volt_dev_id" ,json::Value(max_pos_volt_dev)  );
	jo.set_key("ripple_noise_pk2pk"     ,json::Value(ripple_noise_pk2pk));
	jo.set_key("min_current_draw"       ,json::Value(min_current_draw)  );
	jo.set_key("max_current_draw"       ,json::Value(max_current_draw)  );


	return jo;
}


json::Value tIPMI_DC_LOAD::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("output_num"            , json::Value(output_num)        );
	jo.set_key("nominal_voltage"       , json::Value(nominal_voltage)   );
	jo.set_key("max_neg_volt_dev"      , json::Value(max_neg_volt_dev)  );
	jo.set_key("max_pos_volt_dev"      , json::Value(max_pos_volt_dev)  );
	jo.set_key("ripple_noise_pk2pk"    , json::Value(ripple_noise_pk2pk));
	jo.set_key("min_current_draw"      , json::Value(min_current_draw)  );
	jo.set_key("max_current_draw"      , json::Value(max_current_draw)  );
	return jo;
}



json::Value tIPMI_FRU_INFO::get_json_object() {
	json::Value jo(json::object());
	jo.set_key("header",header.get_json_object());
	if (iua) { jo.set_key("iua" , iua->get_json_object());   } else {  jo.set_key("iua" ,json::Value( std::string(std::string("NULL"))));}
	if (cia) { jo.set_key("cia" , cia->get_json_object());   } else {  jo.set_key("cia" ,json::Value( std::string(std::string("NULL"))));}
	if (bia) { jo.set_key("bia" , bia->get_json_object());   } else {  jo.set_key("bia" ,json::Value( std::string(std::string("NULL"))));}
	if (pia) { jo.set_key("pia" , pia->get_json_object());   } else {  jo.set_key("pia" ,json::Value( std::string(std::string("NULL"))));}

	return jo;
}

