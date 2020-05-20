
unsigned int func_get_fw_version(char* command_params, char* result_str, internal_parser_command* self_ptr) {
	unsigned long fw_version = c_pio_encapsulator_read(&pio_instance_table[FW_VERSION_PIO_TABLE_INDEX]);
	debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sFirmware Version is (%u = 0x%X)\n",COMMENT_STR,fw_version,fw_version);
    xsprintf(result_str,"%u",fw_version);
   return TRUE;
}

unsigned int func_get_pc(char* command_params, char* result_str, internal_parser_command* self_ptr) {
	unsigned long pc_value = read_main_nios_pc();
	debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sPC is 0x%X\n",COMMENT_STR,pc_value);
    xsprintf(result_str,"%u",pc_value);
   return TRUE;
}

unsigned int func_set_debug_level(char* command_params, char* result_str, internal_parser_command* self_ptr) {
	  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
	  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0010);
	  int the_debug_level = the_params[0];
	  if ((numargs < 1) || (the_debug_level > LDB_DEBUG_LEVEL_SHOW_LOW_LEVEL_DIAGNOSTIC_MESSAGES) || (the_debug_level < LDB_DEBUG_LEVEL_DONT_SHOW_ANY_MESSAGES))   {
		 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
		 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
	     return FALSE;
	  } else  {
		        current_debug_level = the_debug_level;
		 	    return TRUE;
	  }
}

unsigned int func_get_debug_level(char* command_params, char* result_str, internal_parser_command* self_ptr) {
    xsprintf(result_str,"debug_level = %u",(unsigned int) current_debug_level);
    return TRUE;
}


unsigned int func_set_benchmarking_mode(char* command_params, char* result_str, internal_parser_command* self_ptr) {
	  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
	  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0010);
	  unsigned int the_benchmarking_mode = the_params[0];
	  if ((numargs < 1) || (the_benchmarking_mode > 1))   {
		 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
		 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
	     return FALSE;
	  } else  {
		  in_benchmarking_mode = the_benchmarking_mode;
		  return TRUE;
	  }
}

unsigned int func_get_benchmarking_mode(char* command_params, char* result_str, internal_parser_command* self_ptr) {
    xsprintf(result_str,"%u",(unsigned int) in_benchmarking_mode);
    return TRUE;
}


void bedrock_func_pio_turn_bit_on_or_off(pio_table_indices pio_instance_index, unsigned char pio_bit_to_toggle, unsigned char turn_on) {
    if (turn_on) {
           c_pio_encapsulator_turn_on_bit(&pio_instance_table[pio_instance_index], pio_bit_to_toggle );
    } else {
		   c_pio_encapsulator_turn_off_bit(&pio_instance_table[pio_instance_index], pio_bit_to_toggle );
    }
}
unsigned long bedrock_func_pio_get_bit(pio_table_indices pio_instance_index, unsigned char pio_bit) {
    return c_pio_encapsulator_get_bit(&pio_instance_table[pio_instance_index], pio_bit);
}


void func_bedrock_pio_toggle_bit(pio_bit_info_struct * pio_info, unsigned int turn_on) {
	 unsigned int pio_instance_index = pio_info->pio_ptr->index;
     unsigned int pio_bit_to_toggle = pio_info->bit_number;
     debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sAccessing PIO (%s) to toggle bit %u (%s), turn (%s)\n",COMMENT_STR,pio_instance_table[pio_instance_index].name,pio_bit_to_toggle,pio_info->name,turn_on ? "on" : "off");
     bedrock_func_pio_turn_bit_on_or_off(pio_instance_index,pio_bit_to_toggle,turn_on);
}

unsigned int func_pio_turn_bit_on_or_off(char* command_params, char* result_str, internal_parser_command* self_ptr, char turn_on) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0000);
  unsigned int pio_instance_index = the_params[0];
  unsigned int pio_bit_to_toggle = the_params[1];
  if ((numargs < 2) || (pio_instance_index >= PIO_INSTANCE_COUNT))   {
	 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {
	 		  debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 		  debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sAccessing PIO (%s) to turn (%s) bit (%d)\n",COMMENT_STR,pio_instance_table[pio_instance_index].name, turn_on ? "ON" : "OFF", pio_bit_to_toggle);
	          bedrock_func_pio_turn_bit_on_or_off(pio_instance_index,pio_bit_to_toggle,turn_on);
	 		  return TRUE;
  }
}

unsigned int func_pio_turn_on_bit(char* command_params, char* result_str, internal_parser_command* self_ptr) {
	return func_pio_turn_bit_on_or_off(command_params, result_str, self_ptr,1);
}

unsigned int func_pio_turn_off_bit(char* command_params, char* result_str, internal_parser_command* self_ptr) {
	return func_pio_turn_bit_on_or_off(command_params, result_str, self_ptr,0);

}

unsigned long func_bedrock_pio_get_bit(pio_bit_info_struct * pio_info, int silent) {
	 unsigned int pio_instance_index = pio_info->pio_ptr->index;
     unsigned int pio_bit_to_read = pio_info->bit_number;
     if (!silent) {
        debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sAccessing PIO (%s) to read bit %u (%s)\n",COMMENT_STR,pio_instance_table[pio_instance_index].name,pio_bit_to_read,pio_info->name);
     }
     return bedrock_func_pio_get_bit(pio_instance_index,pio_bit_to_read);
}
unsigned int func_pio_read(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  unsigned int retval;
  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0);
  unsigned int pio_instance_index = the_params[0];
  debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
  if ((numargs < 1) || (pio_instance_index >= PIO_INSTANCE_COUNT))   {
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {
	 		  debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sAccessing PIO (%s) for read\n",COMMENT_STR,pio_instance_table[pio_instance_index].name);
	 		  retval = c_pio_encapsulator_read(&pio_instance_table[pio_instance_index]);
	 		  debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sread (%u = 0x%X)\n",COMMENT_STR,retval,retval);
	 		  xsprintf(result_str,"%u",retval);
	 		  return TRUE;
  }
  return TRUE;
}
unsigned int func_print_memory(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0001);
  unsigned int mem_address = the_params[0];
  unsigned int length = the_params[1];
  unsigned int do_raw_printout = (numargs > 2) ? the_params[2] : 0;
  unsigned int hexdump_cols    = (numargs > 3) ? the_params[3] : 16;

  debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
  if (numargs < 2)   {
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {
	  hexdump_to_comment_var_length(mem_address,length,do_raw_printout,0,COMMENT_STR,hexdump_cols);
	  //put_dump((char*) mem_address, mem_address, length, DW_CHAR);
	  return TRUE;
  }
 return TRUE;
}

unsigned int func_pio_write(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0010);
  unsigned int pio_instance_index = the_params[0];
  unsigned int pio_data_to_write_hex = the_params[1];
  if ((numargs < 2) || (pio_instance_index >= PIO_INSTANCE_COUNT))   {
	 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {
	 		  debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
              debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sAccessing PIO (%s) for write of value (%u = 0x%X)\n",COMMENT_STR,pio_instance_table[pio_instance_index].name,pio_data_to_write_hex,pio_data_to_write_hex);
              c_pio_encapsulator_write(&pio_instance_table[pio_instance_index], pio_data_to_write_hex );
	 		  return TRUE;
  }
 return TRUE;
}

unsigned int func_device_driver_read(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  unsigned int retval;
  int success = 1;
  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0);
  unsigned int device_instance_index = the_params[0];
  unsigned int reg_instance_index  = the_params[1];

  if ((numargs < 2) || (device_instance_index >= GENERIC_DEVICE_DRIVER_COUNT))   {
	 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {

	 		  debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 		  debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,
	 				  "%sAccessing Device Driver (%s) for read of register (%u) \n",COMMENT_STR,
	 				  generic_device_drivers[device_instance_index].name, reg_instance_index );
	 		  retval = c_generic_driver_encapsulator_read(&generic_device_drivers[device_instance_index], reg_instance_index, &success);
	 		  xsprintf(result_str,"%u",retval);
	 		  return success;
  }
  return TRUE;
}


unsigned int func_device_driver_write(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0100);
  unsigned int device_instance_index = the_params[0];
  unsigned int reg_instance_index  = the_params[1];
  unsigned int pio_data_to_write_hex = the_params[2];

  if ((numargs < 3) || (device_instance_index >= GENERIC_DEVICE_DRIVER_COUNT))   {
	 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {
	 		  debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
              debug_xprintf(LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES,"%sAccessing PIO (%s) for write to reg (%d) of data (0x%x)\n",
            		  COMMENT_STR,generic_device_drivers[device_instance_index].name, reg_instance_index, pio_data_to_write_hex);
              return c_generic_driver_encapsulator_write(&generic_device_drivers[device_instance_index], reg_instance_index, pio_data_to_write_hex );
  }
  return TRUE;
}

#ifdef PROJECT_NAME
unsigned int func_get_project_name(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  xsprintf(result_str,"%s",PROJECT_NAME);
  return TRUE;
}
#endif

unsigned int func_sw_date_str(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  xsprintf(result_str,"sw_date = %s %s",__DATE__, __TIME__ );
  return TRUE;
}

unsigned int bedrock_func_set_pio_bit(char* pio_bit_name, unsigned int turn_on) {
	pio_bit_info_struct* pio_bit_struct_ptr =
	find_pio_bit_info_struct(pio_bit_list_head,pio_bit_name);

	if (pio_bit_struct_ptr) {
			func_bedrock_pio_toggle_bit(pio_bit_struct_ptr,turn_on);
			return TRUE;
	} else {
		debug_xprintf(LDB_DEBUG_LEVEL_NO_DEBUG_MESSAGES_JUST_ERROR_MESSAGES,"%sUnknown pio bit name (%s)\n",COMMENT_STR,pio_bit_name);
		return FALSE;
	}
}

unsigned int bedrock_func_get_pio_bit(char* pio_bit_name, unsigned long* result) {
	pio_bit_info_struct* pio_bit_struct_ptr =
	find_pio_bit_info_struct(pio_bit_list_head,pio_bit_name);

	if (pio_bit_struct_ptr) {
			*result = func_bedrock_pio_get_bit(pio_bit_struct_ptr,0);
			return TRUE;
	} else {
		debug_xprintf(LDB_DEBUG_LEVEL_NO_DEBUG_MESSAGES_JUST_ERROR_MESSAGES,"%sUnknown pio bit name (%s)\n",COMMENT_STR,pio_bit_name);
		return FALSE;
	}
}

unsigned int func_set_pio_bit(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];

  char pio_bit_name[INTERNAL_COMMAND_BUFFER_LENGTH];
  get_first_string(command_params, pio_bit_name, INTERNAL_COMMAND_BUFFER_LENGTH);

  char* actual_command_params=get_second_string_pointer(command_params);
  int numargs = parse_unsigned_int_params (actual_command_params, &the_params, 0b0000);
  unsigned int turn_on = the_params[0];
  if ((numargs < 1) || (turn_on >= 2))   {
	 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {
	        return bedrock_func_set_pio_bit(pio_bit_name,turn_on);
   }
}
unsigned int bedrock_func_set_pio_bit_by_index(int index, unsigned int turn_on) {
	pio_bit_info_struct* pio_bit_struct_ptr =
	find_pio_bit_info_struct_by_index(pio_bit_list_head,index);

	if (pio_bit_struct_ptr) {
			func_bedrock_pio_toggle_bit(pio_bit_struct_ptr,turn_on);
			return TRUE;
	} else {
		debug_xprintf(LDB_DEBUG_LEVEL_NO_DEBUG_MESSAGES_JUST_ERROR_MESSAGES,"%sUnknown pio index (%u)\n",COMMENT_STR,index);
		return FALSE;
	}
}

unsigned int func_set_pio_bit_by_index(char* command_params, char* result_str, internal_parser_command* self_ptr) {
	 unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
	  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0000);
	  unsigned int pio_bit_index = the_params[0];
	  unsigned int pio_bit_value = the_params[1];
	  if ((numargs < 2) || (pio_bit_value > 1))   {
		 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
		 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
	     return FALSE;
	  } else  {
	     return bedrock_func_set_pio_bit_by_index(pio_bit_index,pio_bit_value);
	  }
}


unsigned int func_get_pio_bit(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  char pio_bit_name[INTERNAL_COMMAND_BUFFER_LENGTH];
  get_first_string(command_params, pio_bit_name, INTERNAL_COMMAND_BUFFER_LENGTH);
  unsigned long bit_val;
  if (bedrock_func_get_pio_bit(pio_bit_name,&bit_val)) {
	  xsprintf(result_str,"%u",bit_val);
      return TRUE;
  } else {
	  return FALSE;
  }
}



unsigned int func_list_pio_bits(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  xprintf("%s\n%sPIO BIT List",COMMENT_STR,COMMENT_STR);
  print_underline();
  for (pio_bit_info_struct* pio_bit_ptr = pio_bit_list_head; pio_bit_ptr != NULL; pio_bit_ptr=pio_bit_ptr->next) {
  xprintf("%sName: %-40s PIO:%-25s Bit Number: %3u Global: %d Val:%d\n",
  		COMMENT_STR,
  		pio_bit_ptr->name,
  		pio_bit_ptr->pio_ptr->name,
  		pio_bit_ptr->bit_number,
  		pio_bit_ptr->global_index,
  		func_bedrock_pio_get_bit(pio_bit_ptr,1)
  		);
  }
  return TRUE;
}


unsigned int func_usleep(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  int numargs = parse_unsigned_int_params (command_params, &the_params, 0b0000);
  unsigned int sleep_time_us = the_params[0];
  if (numargs < 1)   {
	 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
	 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
     return FALSE;
  } else  {
     usleep(sleep_time_us);
	 return TRUE;
   }
}
