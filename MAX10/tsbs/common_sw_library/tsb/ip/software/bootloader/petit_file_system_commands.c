
#ifndef GET_MIN_VAL(x,y)
#define GET_MIN_VAL(x,y) ((x > y) ? (y) : (x))
#endif

#ifndef GET_MAX_VAL(x,y)
#define GET_MAX_VAL(x,y) ((x > y) ? (x) : (y))
#endif

#ifndef DEFAULT_SECTOR_SIZE_FOR_FILE_SYSTEM_CARD
#define DEFAULT_SECTOR_SIZE_FOR_FILE_SYSTEM_CARD (512)
#endif

static void put_rc (FRESULT rc)
{
	const char *p;
	static const char str[] =
		"OK\0DISK_ERR\0NOT_READY\0NO_FILE\0NOT_OPENED\0NOT_ENABLED\0NO_FILE_SYSTEM\0";
	FRESULT i;

	for (p = str, i = 0; i != rc && *p; i++) {
		while(*p++);
	}
	xprintf("%src=%u FR_%s\n", COMMENT_STR, (UINT)rc, p);
}


unsigned int func_ls(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  DIR dir;				/* Directory object */
  FILINFO fno;			/* File information object */
  UINT bw, br, i;
  FRESULT rc;
  long p1, p2, p3;
  BYTE res, buff[1024];
  UINT w, cnt, s1, s2, ofs;
  char filename[INTERNAL_COMMAND_BUFFER_LENGTH];

#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(1);
#endif

  get_first_string(command_params,filename,INTERNAL_COMMAND_BUFFER_LENGTH-1);
  make_string_uppercase(filename);
  trim_trailing_spaces(filename);
  res = pf_opendir(&dir, filename);
  if (res) { put_rc(res); return FALSE; }
  p1 = s1 = s2 = 0;
  for(;;) {
  	res = pf_readdir(&dir, &fno);
  	if (res != FR_OK) {
		put_rc(res);
	#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
	  get_control_of_sd_card(0);
	#endif
		return FALSE;
  	}
  	if (!fno.fname[0]) break;
  	if (fno.fattrib & AM_DIR) {
  		s2++;
  	} else {
  		s1++; p1 += fno.fsize;
  	}
  	xprintf("%c%c%c%c%c %u/%02u/%02u %02u:%02u %9lu  %s",
  			(fno.fattrib & AM_DIR) ? 'D' : '-',
  			(fno.fattrib & AM_RDO) ? 'R' : '-',
  			(fno.fattrib & AM_HID) ? 'H' : '-',
  			(fno.fattrib & AM_SYS) ? 'S' : '-',
  			(fno.fattrib & AM_ARC) ? 'A' : '-',
  			(fno.fdate >> 9) + 1980, (fno.fdate >> 5) & 15, fno.fdate & 31,
  			(fno.ftime >> 11), (fno.ftime >> 5) & 63, fno.fsize, fno.fname);
  	xprintf("\n");
  }
  xprintf("%4u File(s),%10lu bytes total\n%4u Dir(s)\n", s1, p1, s2);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
 return TRUE;
}

unsigned int func_mount(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  DIR dir;				/* Directory object */
  FILINFO fno;			/* File information object */
  UINT bw, br, i;
  BYTE buff[64];
  FRESULT rc;
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(1);
#endif

  rc = pf_mount(&fatfs);
  xprintf("%sMount operation returned %d\n",COMMENT_STR,rc);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif

  if (rc) return FALSE;
  return TRUE;
}

unsigned int func_disk_status(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  DIR dir;				/* Directory object */
  FILINFO fno;			/* File information object */
  UINT bw, br, i;
  BYTE buff[64];
  FRESULT rc;

	if (!fatfs.fs_type) { xprintf("Not mounted.\n"); return FALSE; }
	xprintf("FAT type = %u\nBytes/Cluster = %lu\n"
			"Root DIR entries = %u\nNumber of clusters = %lu\n"
			"FAT start (lba) = %lu\nDIR start (lba,clustor) = %lu\nData start (lba) = %lu\n\n",
			fatfs.fs_type, (DWORD)fatfs.csize * 512,
			fatfs.n_rootdir, (DWORD)fatfs.n_fatent - 2,
			fatfs.fatbase, fatfs.dirbase, fatfs.database
	);

	return TRUE;
}




unsigned int func_file_type_contents(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  DIR dir;				/* Directory object */
  FILINFO fno;			/* File information object */
  UINT bw, br, i;
  FRESULT rc;
  long p1, p2, p3;
  BYTE res, buff[1024];
  UINT w, cnt, s1, s2, ofs;
  char filename[INTERNAL_COMMAND_BUFFER_LENGTH];
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(1);
#endif
  int print_raw_file = (int) self_ptr->additional_info;
  get_first_string(command_params,filename,INTERNAL_COMMAND_BUFFER_LENGTH-1);
  make_string_uppercase(filename);
  trim_trailing_spaces(filename);
  res =  pf_open(filename);
  if (res != FR_OK) { put_rc(res);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
  return FALSE;
  }
  p1 = fatfs.fsize; //length of file
  ofs = fatfs.fptr;
  while (p1) {
  	if ((UINT)p1 >= 16) { cnt = 16; p1 -= 16; }
  	else 				{ cnt = (UINT)p1; p1 = 0; }
  	res = pf_read(buff, cnt, &w);
  	if (res != FR_OK) { put_rc(res);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
  	return FALSE;
  	}
  	if (!w) break;
  	buff[w] = '\0';
  	if (print_raw_file) {
  	    xprintf(buff);
  	} else {
  		put_dump(buff, ofs, cnt, DW_CHAR);
  	}
  	ofs += 16;
  }
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
 return TRUE;
}




unsigned int func_copy_binary_file_contents_to_mem(char* command_params, char* result_str, internal_parser_command* self_ptr) {
  DIR dir;				/* Directory object */
  FILINFO fno;			/* File information object */
  UINT bw, br, i;
  FRESULT rc;
  long p1, p2, p3;
  const int MAX_NUM_OF_BYTES_TO_READ_EACH_TIME = DEFAULT_SECTOR_SIZE_FOR_FILE_SYSTEM_CARD;
  BYTE res, buff[MAX_NUM_OF_BYTES_TO_READ_EACH_TIME+1];
  UINT w, cnt, s1, s2, ofs;
  char filename[INTERNAL_COMMAND_BUFFER_LENGTH];

  get_first_string(command_params,filename,INTERNAL_COMMAND_BUFFER_LENGTH-1);
  char* memory_location_ptr = get_second_string_pointer(command_params);
  unsigned int the_params[MAX_PARAMS_FOR_COMMANDS];
  int numargs = parse_unsigned_int_params (memory_location_ptr, &the_params, 0b01);

  if (numargs < 3) {
 		 debug_print_params_to_uart(result_str,the_params,numargs,self_ptr->name,PRINT_DEBUG_MESSAGES_IMMEDIATELY);
 		 result_str+=print_out_of_range_error_message(result_str,the_params,numargs,PRINT_OUT_OF_RANGE_MESSAGE_IMMEDIATELY);
 	     return FALSE;
  }
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(1);
#endif
  unsigned int memory_location = the_params[0];
  unsigned int length_to_write = the_params[1];
  unsigned int verbose         = the_params[2];
  make_string_uppercase(filename);
  trim_trailing_spaces(filename);
  res =  pf_open(filename);
  if (res != FR_OK) { put_rc(res); return FALSE; }
  p1 = GET_MIN_VAL(fatfs.fsize,length_to_write); //length of file
  ofs = fatfs.fptr;
  unsigned int charcnt = 0;
  while (p1) {
  	if ((UINT)p1 >= MAX_NUM_OF_BYTES_TO_READ_EACH_TIME) { cnt = MAX_NUM_OF_BYTES_TO_READ_EACH_TIME; p1 -= MAX_NUM_OF_BYTES_TO_READ_EACH_TIME; }
  	else 				{ cnt = (UINT)p1; p1 = 0; }
  	res = pf_read(buff, cnt, &w);
  	if (res != FR_OK) {
  		put_rc(res);
  		xsprintf(result_str,"%u",charcnt);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
  	return FALSE;
  	}
  	if (!w) break;
  	if (verbose) {
  		put_dump(buff, ofs, cnt, DW_CHAR);
  	}
  	memcpy((void *)(memory_location+charcnt),buff,cnt);
  	ofs += MAX_NUM_OF_BYTES_TO_READ_EACH_TIME;
  	charcnt += cnt;

  }
  xsprintf(result_str,"%u",charcnt);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
  return TRUE;
}

unsigned int func_read_file_into_buffer(char* filename, char* result_str, int max_chars_to_read, int print_raw_file) {
  DIR dir;				/* Directory object */
  FILINFO fno;			/* File information object */
  UINT bw, br, i;
  FRESULT rc;
  long p1, p2, p3;
  BYTE res;
  char* buff;
  UINT w, cnt, s1, s2, ofs;
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(1);
#endif
  make_string_uppercase(filename);
  trim_trailing_spaces(filename);
  res =  pf_open(filename);
  if (res != FR_OK) { put_rc(res);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
  return FALSE;
  }
  p1 = fatfs.fsize; //length of file
  ofs = fatfs.fptr;
  buff = result_str;
  while (p1) {	  
    
  	if ((UINT)p1 >= 16 ) { cnt = 16; p1 -= 16; }
  	else 				{ cnt = (UINT)p1; p1 = 0; }
	
	if (ofs + cnt > max_chars_to_read) {
		cnt = max_chars_to_read - ofs - 1;
		p1 = 0;
	}
  	res = pf_read(buff, cnt, &w);
  	if (res != FR_OK) { put_rc(res);
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
  	return FALSE;
  	}
  	if (!w) break;
  	buff[w] = '\0';
	
  	if (print_raw_file) {
  	    xprintf(buff);
  	}
  	/*
  	else {
  		put_dump(buff, ofs, cnt, DW_CHAR);
  	}
  	*/
	buff += w;
  	ofs += w;
  }
#if GET_CONTROL_OF_SD_CARD_FOR_EACH_COMMAND
  get_control_of_sd_card(0);
#endif
 return TRUE;
}
