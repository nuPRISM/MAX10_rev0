
#define JIM_check_argc(argc,argc_desired_val) do { if (argc < argc_desired_val)  \
	                                                {\
	                                                    std::ostringstream retstr; \
	                                                    retstr << "Jim Error: File: [" << __FILE__ << "] Line: [" << __LINE__ << "] Function:  " << __FUNCTION__ << " Argc is: [" << argc << "] but desired val is: [" << argc_desired_val << "]" <<  std::endl; \
	                                                    out_to_all_streams(retstr.str()); \
	                                                    safe_print(std::cout << retstr.str());\
	                                                    char *buf=NULL; \
	                                                    buf = my_mem_strdup(retstr.str().c_str()); \
	                                                    Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf)); \
	                                                    my_mem_free(buf); \
	                                                    Jim_SetResult (interp, result); \
	                                                    return JIM_ERR; \
                                                      } else if (argc > argc_desired_val) { \
                                                    	 std::ostringstream retstr; \
                                                    	 retstr << "Jim Error: File: [" << __FILE__ << "] Line: [" << __LINE__ << "] Function:  " << __FUNCTION__ << " Argc is: [" << argc << "] but desired val is: [" << argc_desired_val << "]" <<  std::endl; \
                                                    	 out_to_all_streams(retstr.str()); \
                                                    	 safe_print(std::cout << retstr.str());\
                                                    	 char *buf=NULL; \
                                                    	 buf = my_mem_strdup(retstr.str().c_str()); \
                                                    	 Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf)); \
                                                    	 my_mem_free(buf); \
                                                    	 Jim_SetResult (interp, result); \
                                                    	 return JIM_ERR; \
                                                      } \
                                                  } while (0)

string assemble_jim_tcl_str_from_argc_and_argv(int argc, Jim_Obj * const *argv)
{
	std::string command_str = "";
	for (int j = 1; j < argc; j++)
	{
		command_str += Jim_GetString(argv[j], NULL);
		if (j != (argc - 1))
			command_str += " ";
	}
	return command_str;
}


int exec_csv_line_read_command_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,3);
	std::string result_str;
    result_str =
	convert_csv_string_to_relevant_string(string(Jim_GetString(argv[1],NULL)), string(Jim_GetString(argv[2],NULL)));
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}
int exec_send_mail_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,7);
	std::string result_str;
    result_str =
    		send_smtp_mail(
    				string(Jim_GetString(argv[1],NULL)),
    				string(Jim_GetString(argv[2],NULL)),
    				string(Jim_GetString(argv[3],NULL)),
    				string(Jim_GetString(argv[4],NULL)),
    				string(Jim_GetString(argv[5],NULL)),
    				string(Jim_GetString(argv[6],NULL))
    				);
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_convert_decimal_uint_as_str_to_hex_str_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,2);
	std::string result_str;
    result_str = convert_decimal_uint_as_str_to_hex_str(string(Jim_GetString(argv[1],NULL)));
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}




int exec_convert_decimal_hex_as_str_to_uint_str_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,2);
	std::string result_str;
	ostringstream result_stream;
	result_stream << conv_hex_string_to_unsigned_long(string(Jim_GetString(argv[1],NULL)));
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_convert_decimal_hex_as_str_to_int_str_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,2);
	std::string result_str;
	ostringstream result_stream;
	result_stream << conv_hex_string_to_signed_long(string(Jim_GetString(argv[1],NULL)));
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_floor_jimtcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,2);
	ostringstream result_stream;
	std::string result_str;
	result_stream << floor(atof(Jim_GetString(argv[1],NULL)));
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}
int exec_TrimSpacesFromString(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	JIM_check_argc(argc,2);
	std::string result_str;
	result_str = TrimSpacesFromString(string(Jim_GetString(argv[1],NULL)));
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_convert_decimal_int_as_str_to_hex_str_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	std::string result_str;
	if (argc < 3)
    {
		JIM_check_argc(argc,2);
		result_str = convert_decimal_int_as_str_to_hex_str(string(Jim_GetString(argv[1],NULL)));
    } else
    {
    	result_str = convert_decimal_int_as_str_to_hex_str(string(Jim_GetString(argv[1],NULL)),atoi(Jim_GetString(argv[2],NULL)));
    }
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_convert_decimal_uint_as_str_to_binary_str_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string result_str;
	if (argc < 5)
    {
		out_to_all_streams("error: linnux_main::exec_convert_decimal_uint_as_str_to_binary_str_from_jim_tcl insufficient number of parameters - returning 0\n");
		result_str = "0";
    } else
    {
    	result_str = binary_base_converter.ConvertToBase(atoi(Jim_GetString(argv[1],NULL)),atoi(Jim_GetString(argv[2],NULL)),atoi(Jim_GetString(argv[3],NULL)),atoi(Jim_GetString(argv[4],NULL)));
    }
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_convert_binary_str_to_decimal_uint_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	ostringstream result_stream;
	std::string result_str;
	if (argc < 2)
    {
		out_to_all_streams("error: linnux_main::exec_convert_binary_str_to_decimal_uint_from_jim_tcl insufficient number of parameters - returning 0\n");
		result_stream << "0";
    } else
    {
    	result_stream << bin2dec(string(Jim_GetString(argv[1],NULL)));
    }
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_write_str_to_file(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,3);
	ostringstream result_stream;
	std::string result_str;
	result_stream << linnux_sd_card_write_string_to_file(atoi(Jim_GetString(argv[1],NULL)),string(Jim_GetString(argv[2],NULL)));
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_tcl_gets(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	ostringstream result_stream;
	std::string result_str;
	getline(cin, result_str);
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_get_tcl_stop_request_val(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	ostringstream result_stream;
	std::string result_str;
	result_stream << (get_interrupt_positions(STOP_TCL_SCRIPT_REQUEST_MASK) != 0);
	out_to_all_streams("In exec_get_tcl_stop_request_val button_irq_edge_capture = " << button_irq_edge_capture << " STOP_TCL_SCRIPT_REQUEST_MASK =" << STOP_TCL_SCRIPT_REQUEST_MASK << " result_stream = " << result_stream.str() << endl);
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_clear_tcl_stop_request_val(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	ostringstream result_stream;
	std::string result_str;
	out_to_all_streams("In exec_clear_tcl_stop_request_val, before,  button_irq_edge_capture = " << button_irq_edge_capture << endl);
	clear_tcl_stop_request_irq_edge_capture();
	out_to_all_streams("In exec_clear_tcl_stop_request_val, after,  button_irq_edge_capture = " << button_irq_edge_capture << endl);

	result_str = "";
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_write_sevenseg(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	JIM_check_argc(argc,2);
	std::string result_str;
	result_str = "";
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}



int exec_enter_verbose_mode(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string result_str;
	print_messages_even_when_in_tcl_shell = 1;
	out_to_all_streams("Shell is now in verbose mode");
	result_str = "";
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_exit_verbose_mode(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string result_str;
	print_messages_even_when_in_tcl_shell = 0;
	out_to_all_streams("Shell is now not in verbose mode");
	result_str = "";
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}



int exec_reset_matlab_curve_string_generator_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	matlab_curve_linetype_generator_for_tcl.reset_curve_count();
	matlab_curve_linetype_generator_for_tcl.set_mode(MATLAB_CURVE_LINEGEN_MANUAL);
	matlab_curve_linetype_generator_for_tcl.set_increase_every(7, 4, 1);
	std::string result_str;
	result_str = "";
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_get_next_matlab_curve_string_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string result_str;
	result_str = matlab_curve_linetype_generator_for_tcl.get_next_curve_type();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_linnux_command_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	//safe_print(std::cout << "Found Command String : " << command_str << std::endl);
	char *buf=NULL;
	std::string result_str;
	result_str = bedrock_exec_linnux_command_from_picol(command_str.c_str());

	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);

	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_linnux_control_command_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	//safe_print(std::cout << "Found Command String : " << command_str << std::endl);
	char *buf=NULL;
	std::string result_str;
	result_str = bedrock_exec_linnux_control_command_from_tcl(command_str.c_str());

	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);

	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_register_jim_tcl_before_BER_func(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	//safe_print(std::cout << "Found Command String : " << command_str << std::endl);
	JIM_check_argc(argc,3);
    int retcode;
	string the_script_filename  = string(Jim_GetString(argv[1],NULL));
	tcl_proc_name_run_before_BER_func_in_SJTOL = string(Jim_GetString(argv[2],NULL));
    tcl_script_file_to_load_before_BER_func_in_SJTOL = read_from_sd_card_into_string(the_script_filename);
	if (tcl_script_file_to_load_before_BER_func_in_SJTOL != "") {
		tcl_script_registered_as_before_BER_func = 1;
		retcode = Jim_Eval(Jim_persistent_autonomous_TCL_shell, tcl_script_file_to_load_before_BER_func_in_SJTOL.c_str());

		if (retcode == JIM_ERR)
		{
	     #ifdef LINNUX_USE_JIM_51
			Jim_PrintErrorMessage(interp);
	     #else
			Jim_MakeErrorMessage(interp);
	     #endif
			out_to_all_streams("Warning: Due to error, disabling TCL Before BER function!\n");
			tcl_script_registered_as_before_BER_func = 0;
		}
	} else {
		out_to_all_streams("Error: could not open filename: " << the_script_filename << " or file is empty\n");
		tcl_script_registered_as_before_BER_func = 0;
	}

	char *buf=NULL;
	ostringstream result_stream;
	std::string result_str;
	result_stream << (tcl_script_registered_as_before_BER_func != 0); //if we are not registered, an error has occured
	result_str = result_stream.str();
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_deregister_jim_tcl_before_BER_func(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	tcl_script_registered_as_before_BER_func = 0;
	char *buf=NULL;
	std::string result_str;
	result_str = "";
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);

	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_register_jim_tcl_for_DUT_diag(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	//std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	//safe_print(std::cout << "Found Command String : " << command_str << std::endl);
	JIM_check_argc(argc,3);
    int retcode;
	string the_script_filename  = string(Jim_GetString(argv[1],NULL));
	tcl_proc_name_for_DUT_diag = string(Jim_GetString(argv[2],NULL));
    tcl_script_file_to_load_for_DUT_diag_proc = read_from_sd_card_into_string(the_script_filename);
	if (tcl_script_file_to_load_for_DUT_diag_proc != "") {
		tcl_script_registered_DUT_diag_func = 1;
		retcode = Jim_Eval(Jim_persistent_autonomous_TCL_shell_for_DUT_diag, tcl_script_file_to_load_for_DUT_diag_proc.c_str());
		if (retcode == JIM_ERR)
		{
	     #ifdef LINNUX_USE_JIM_51
			Jim_PrintErrorMessage(interp);
	     #else
			Jim_MakeErrorMessage(interp);
	     #endif
			out_to_all_streams("Warning: Due to error, disabling TCL DUT Diag function!\n");
			tcl_script_registered_DUT_diag_func = 0;
		}
	} else {
		out_to_all_streams("Error: could not open filename: " << the_script_filename << " or file is empty\n");
		tcl_script_registered_DUT_diag_func = 0;
	}

	char *buf=NULL;
	ostringstream result_stream;
	std::string result_str;
	result_stream << (tcl_script_registered_DUT_diag_func != 0); //if we are not registered, an error has occured
	result_str = result_stream.str();
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_deregister_jim_tcl_for_DUT_diag(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	tcl_script_registered_DUT_diag_func = 0;
	char *buf=NULL;
	std::string result_str;
	result_str = "";
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);

	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_convert_decimal_uint_as_str_to_justified_hex_str_from_jim_tcl(Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	JIM_check_argc(argc,3);
	std::string result_str;
    result_str = convert_decimal_uint_as_str_to_hex_str_0_justified(string(Jim_GetString(argv[1],NULL)),atoi(Jim_GetString(argv[2],NULL)));
	char *buf;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}
int exec_bitwise_from_jim_tcl (Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);

	JIM_check_argc(argc,4);
	ostringstream result_stream;
	std::string result_str;
	unsigned long a, b;

	sscanf(Jim_GetString(argv[1],NULL),"%lu",&a);
	sscanf(Jim_GetString(argv[3],NULL),"%lu",&b);

	result_stream << bitwise_operate(a,b,std::string(Jim_GetString(argv[2],NULL)));
	result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_bitwise_hex_from_jim_tcl (Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);

	JIM_check_argc(argc,4);
	ostringstream result_stream;
	std::string result_str;
	unsigned long a, b;
	sscanf(Jim_GetString(argv[1],NULL),"%lx",&a);
	sscanf(Jim_GetString(argv[3],NULL),"%lx",&b);

	result_stream << bitwise_operate(a,b,std::string(Jim_GetString(argv[2],NULL)));


    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}


int exec_bitwise_not_from_jim_tcl (Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);

	JIM_check_argc(argc,2);
	ostringstream result_stream;
	std::string result_str;
	unsigned long a, b;
	sscanf(Jim_GetString(argv[1],NULL),"%lu",&a);
	result_stream << (~a);
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}

int exec_bitwise_hex_not_from_jim_tcl (Jim_Interp *interp, int argc, Jim_Obj * const *argv)
{
	std::string command_str = assemble_jim_tcl_str_from_argc_and_argv(argc, argv);
	JIM_check_argc(argc,2);
	ostringstream result_stream;
	std::string result_str;
	unsigned long a, b;
	sscanf(Jim_GetString(argv[1],NULL),"%lx",&a);
	result_stream << (~a);
    result_str = result_stream.str();
	char *buf=NULL;
	buf = my_mem_strdup(result_str.c_str());
	Jim_Obj *result = Jim_NewStringObj(interp, buf, strlen(buf));
	my_mem_free(buf);
	Jim_SetResult (interp, result);
	return JIM_OK;
}



void register_yl_commands_tcl(Jim_Interp* the_interp)
{
	int is_control_shell = (OSTCBCur->OSTCBPrio == LINNUX_CONTROL_TASK_PRIORITY);
	if (!is_control_shell) {
	  Jim_CreateCommand(the_interp, "ylcmd", exec_linnux_command_from_jim_tcl, NULL, NULL);
	  Jim_CreateCommand(the_interp, "register_tcl_sjtol_proc", exec_register_jim_tcl_before_BER_func, NULL, NULL);
	  Jim_CreateCommand(the_interp, "deregister_tcl_sjtol_proc", exec_deregister_jim_tcl_before_BER_func, NULL, NULL);
	  Jim_CreateCommand(the_interp, "register_tcl_dut_diag_proc", exec_register_jim_tcl_for_DUT_diag, NULL, NULL);
	  Jim_CreateCommand(the_interp, "deregister_tcl_dut_diag_proc", exec_deregister_jim_tcl_for_DUT_diag, NULL, NULL);
	  Jim_CreateCommand(the_interp, "reset_matlab_curve_string_generator", exec_reset_matlab_curve_string_generator_from_jim_tcl, NULL, NULL);
	  Jim_CreateCommand(the_interp, "get_next_matlab_curve_string", exec_get_next_matlab_curve_string_from_jim_tcl, NULL, NULL);
	} else {
	  Jim_CreateCommand(the_interp, "clcmd", exec_linnux_control_command_from_jim_tcl, NULL, NULL);
	}
	Jim_CreateCommand(the_interp, "parse_csv_line", exec_csv_line_read_command_from_jim_tcl, NULL, NULL);
	Jim_CreateCommand(the_interp, "conv_uint_to_hex", exec_convert_decimal_uint_as_str_to_hex_str_from_jim_tcl, NULL, NULL);
	Jim_CreateCommand(the_interp, "conv_hex_to_uint", exec_convert_decimal_hex_as_str_to_uint_str_from_jim_tcl, NULL, NULL);
	Jim_CreateCommand(the_interp, "conv_int_to_hex", exec_convert_decimal_int_as_str_to_hex_str_from_jim_tcl, NULL, NULL);
	Jim_CreateCommand(the_interp, "conv_hex_to_int", exec_convert_decimal_hex_as_str_to_int_str_from_jim_tcl, NULL, NULL);
	Jim_CreateCommand(the_interp, "conv_uint_to_hex_justified", exec_convert_decimal_uint_as_str_to_justified_hex_str_from_jim_tcl, NULL, NULL);
	Jim_CreateCommand(the_interp, "trim_spaces", exec_TrimSpacesFromString, NULL, NULL);
	Jim_CreateCommand(the_interp, "write_str_to_file", exec_write_str_to_file, NULL, NULL);
	Jim_CreateCommand(the_interp, "write_7seg", exec_write_sevenseg, NULL, NULL);
    Jim_CreateCommand(the_interp, "enter_verbose_mode", exec_enter_verbose_mode, NULL, NULL);
    Jim_CreateCommand(the_interp, "exit_verbose_mode", exec_exit_verbose_mode, NULL, NULL);
    Jim_CreateCommand(the_interp, "floor", exec_floor_jimtcl, NULL, NULL);
    Jim_CreateCommand(the_interp, "get_tcl_stop_request_val", exec_get_tcl_stop_request_val, NULL, NULL);
    Jim_CreateCommand(the_interp, "clear_tcl_stop_request_val", exec_clear_tcl_stop_request_val, NULL, NULL);
    Jim_CreateCommand(the_interp, "gets", exec_tcl_gets, NULL, NULL);
    Jim_CreateCommand(the_interp, "convert_uint_to_bin",exec_convert_decimal_uint_as_str_to_binary_str_from_jim_tcl, NULL, NULL);
    Jim_CreateCommand(the_interp, "convert_bin_to_uint",exec_convert_binary_str_to_decimal_uint_from_jim_tcl,NULL, NULL);
    Jim_CreateCommand(the_interp, "bitwise",exec_bitwise_from_jim_tcl,NULL, NULL);
    Jim_CreateCommand(the_interp, "bitwise_hex",exec_bitwise_hex_from_jim_tcl,NULL, NULL);
    Jim_CreateCommand(the_interp, "bitwise_not",exec_bitwise_not_from_jim_tcl,NULL, NULL);
    Jim_CreateCommand(the_interp, "bitwise_hex_not",exec_bitwise_hex_not_from_jim_tcl,NULL, NULL);
    Jim_CreateCommand(the_interp, "send_mail",exec_send_mail_jim_tcl,NULL, NULL);
}

int Jim_Source_tcl_script_from_file(char *filename, int persistent)
{
	Jim_Interp* temp_jim_interp;
	std::string str;
	int retcode;


	char *buf = NULL;
	str = read_from_sd_card_into_string(string(filename));
	buf = my_mem_strdup(str.c_str());
	if (persistent)
	{
		retcode = Jim_Eval(Jim_interactive_TCL_shell, buf);
		if (retcode == JIM_ERR)
		{
#ifdef LINNUX_USE_JIM_51
			Jim_PrintErrorMessage(Jim_interactive_TCL_shell);
#else
			Jim_MakeErrorMessage(Jim_interactive_TCL_shell);
#endif
		}
	} else
	{
		/* Create an interpreter */
		temp_jim_interp = Jim_CreateInterp();
		/* Add all the Jim core commands */
		Jim_RegisterCoreCommands(temp_jim_interp);
		register_yl_commands_tcl(temp_jim_interp);
		retcode = Jim_Eval(temp_jim_interp, buf);
		if (retcode == JIM_ERR)
		{
#ifdef LINNUX_USE_JIM_51
			Jim_PrintErrorMessage(temp_jim_interp);
#else
			Jim_MakeErrorMessage(temp_jim_interp);
#endif
		}
		Jim_FreeInterp(temp_jim_interp);
	}
	if (buf != NULL) {
	  my_mem_free(buf);
	}
	//let C++ dispose of the string "str"
	return retcode;
}

int Jim_Source_autonomous_tcl_script(Jim_Interp* temp_jim_interp, string the_string)
{
	char *buf=NULL;
	int retcode;
	buf = my_mem_strdup(the_string.c_str());
    int is_a_new_interpreter = 0;

	if (temp_jim_interp == NULL) {
		    is_a_new_interpreter = 1;
			/* Create an interpreter */
			temp_jim_interp = Jim_CreateInterp();
			/* Add all the Jim core commands */
			Jim_RegisterCoreCommands(temp_jim_interp);
			register_yl_commands_tcl(temp_jim_interp);
	}
	retcode = Jim_Eval(temp_jim_interp, buf);

	if (retcode == JIM_ERR)
	{
#ifdef LINNUX_USE_JIM_51
		Jim_PrintErrorMessage(temp_jim_interp);
#else
		Jim_MakeErrorMessage(temp_jim_interp);
#endif
	}

	if (is_a_new_interpreter)
		{
		  Jim_FreeInterp(temp_jim_interp);
		}
	my_mem_free(buf);
	return retcode;
}

//==========================================================================================================================
//
// End Interface to JIM TCL
//
//==========================================================================================================================

