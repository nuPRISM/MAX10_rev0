/*
 * uart_register_file.h
 *
 *  Created on: Apr 8, 2013
 *      Author: yairlinn
 */

#ifndef UART_REGISTER_FILE_H_
#define UART_REGISTER_FILE_H_

#include "uart_encapsulator.h"
#include "uart_vector_config_encapsulator.h"
#include "altera_pio_encapsulator.h"
#include "semaphore_locking_class.h"
#include "linnux_utils.h"
#include <stdio.h>
#include <string>
#include <map>
#include <vector>
#include "assert.h"
#include <sstream>
#include "uart_user_types.h"

#define UART_REGISTER_FILE_NUM_INFO_REGS (0x3E)

class uart_regfile_error_record {
public:
	unsigned int get_error() const {
		return error;
	}

	void set_error(unsigned int error) {
		this->error = error;
	}

	unsigned int get_secondary_uart_index() const {
		return secondary_uart_index;
	}

	void set_secondary_uart_index(unsigned int secondaryUartIndex) {
		secondary_uart_index = secondaryUartIndex;
	}

protected:
	unsigned int error;
	unsigned int secondary_uart_index;
};


class uart_regfile_primary_and_secondary_def {
protected:
	   unsigned int uart_primary_index;
	   unsigned int uart_secondary_index;
public:

	   uart_regfile_primary_and_secondary_def() {
		   uart_primary_index = 0;
		   uart_secondary_index = 0;
	   }

	unsigned int get_uart_primary_index() const {
		return uart_primary_index;
	}

	void set_uart_primary_index(unsigned int uartPrimaryIndex) {
		uart_primary_index = uartPrimaryIndex;
	}

	unsigned int get_uart_secondary_index() const {
		return uart_secondary_index;
	}

	void set_uart_secondary_index(unsigned int uartSecondaryIndex) {
		uart_secondary_index = uartSecondaryIndex;
	}

};

typedef std::map<std::string,uart_regfile_primary_and_secondary_def> uart_regfile_display_string_mapping_type;
typedef std::map<unsigned long, std::string> register_desc_map_type;
typedef std::map<std::string, unsigned long> register_desc_inverse_map_type;
typedef std::vector<unsigned long> uart_regfile_single_uart_included_regs_type;
typedef std::map<unsigned long,uart_regfile_single_uart_included_regs_type> uart_regfile_included_regs_type;
typedef std::vector<uart_regfile_primary_and_secondary_def> vector_of_uart_primary_and_secondary_defs;
typedef std::vector<std::pair<unsigned long,unsigned long long> > register_address_value_pairs_type;
class special_uart_override_class {
protected:
	register_desc_map_type ctrl_descs, status_descs;
	uart_regfile_single_uart_included_regs_type ctrl_included, status_included;
public:
	special_uart_override_class() {};
	register_desc_map_type& get_ctrl_descs() {
		return ctrl_descs;
	}

	register_desc_map_type& get_status_descs() {
			return status_descs;
		}

	uart_regfile_single_uart_included_regs_type& get_ctrl_included() {
		return ctrl_included;
	}

	uart_regfile_single_uart_included_regs_type& get_status_included() {
		return status_included;
	}

	void set_ctrl_descs (register_desc_map_type& the_ctrl_descs) {
		ctrl_descs = the_ctrl_descs;
	}

	void set_status_descs (register_desc_map_type& the_status_descs) {
			status_descs = the_status_descs;
	}

	void set_ctrl_included (uart_regfile_single_uart_included_regs_type& the_ctrl_included) {
		ctrl_included = the_ctrl_included;
	}

    void set_status_included (uart_regfile_single_uart_included_regs_type& the_status_included) {
		status_included = the_status_included;
	}
};

typedef std::map<uart_user_types,special_uart_override_class> special_uart_override_map_type;


class uart_register_file_info_struct {
public:
	unsigned long
	DATA_WIDTH,
	ADDRESS_WIDTH,
	STATUS_ADDRESS_START,
	NUM_OF_CONTROL_REGS,
	NUM_OF_STATUS_REGS,
	INIT_ALL_CONTROL_REGS_TO_DEFAULT,
	USE_AUTO_RESET,
	VERSION,
	USER_TYPE,
	NUM_SECONDARY_UARTS,
	ADDRESS_OF_THIS_UART,
	IS_SECONDARY_UART,
	IS_ACTUALLY_PRESENT,
	CLOCK_RATE_IN_HZ,
	WATCHDOG_LIMIT_IN_CLOCK_CYCLES,
	WATCHDOG_LIMIT_IN_SYSTEM_TICKS,
	ENABLE_ERROR_MONITORING,
	DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS,
	ENABLE_STATUS_WISHBONE_INTERFACE,
	ENABLE_CONTROL_WISHBONE_INTERFACE,
	STATUS_WISHBONE_NUM_ADDRESS_BITS,
	CONTROL_WISHBONE_NUM_ADDRESS_BITS,
	IGNORE_TIMING_TO_READ_LD,
	USE_GENERIC_ATTRIBUTE_FOR_READ_LD,
	WISHBONE_INTERFACE_IS_PART_OF_BRIDGE,
	WISHBONE_STATUS_BASE_ADDRESS,
	WISHBONE_CONTROL_BASE_ADDRESS;

	std::string DISPLAY_NAME;





	uart_register_file_info_struct() {
 		    DATA_WIDTH = 0;
			ADDRESS_WIDTH = 0;
			STATUS_ADDRESS_START = 0;
			NUM_OF_CONTROL_REGS = 0;
			NUM_OF_STATUS_REGS = 0;
			INIT_ALL_CONTROL_REGS_TO_DEFAULT = 0;
			USE_AUTO_RESET = 0;
			VERSION = 0;
			USER_TYPE = 0;
			NUM_SECONDARY_UARTS = 0;
			ADDRESS_OF_THIS_UART = 0;
			IS_SECONDARY_UART = 0;
			IS_ACTUALLY_PRESENT = 0;
			CLOCK_RATE_IN_HZ= 0;
			WATCHDOG_LIMIT_IN_CLOCK_CYCLES=0;
			WATCHDOG_LIMIT_IN_SYSTEM_TICKS=0;
			ENABLE_ERROR_MONITORING=0;
			DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS=0;
			IGNORE_TIMING_TO_READ_LD = 0;
			USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 0;
			ENABLE_STATUS_WISHBONE_INTERFACE=0;
			ENABLE_CONTROL_WISHBONE_INTERFACE=0;
			STATUS_WISHBONE_NUM_ADDRESS_BITS=0;
			CONTROL_WISHBONE_NUM_ADDRESS_BITS=0;
			WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 0;
			WISHBONE_STATUS_BASE_ADDRESS = 0;
			WISHBONE_CONTROL_BASE_ADDRESS = 0;
			DISPLAY_NAME = "";
	}
};

class uart_register_file: public uart_encapsulator , public semaphore_locking_class {
protected:
	bool this_has_been_initialized;
	bool auto_append_uart_indices_to_display_name;
	int primary_uart_num_if_known;
	special_uart_override_map_type* special_uart_maps;
	std::vector<uart_register_file_info_struct> regfile_params;
	void get_raw_info(std::vector<unsigned long>& raw_info,  unsigned long secondary_uart_address=0, int* errorptr = NULL);
	std::string get_uart_string_response(unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	std::string get_uart_status_or_control_description_ascii_response(unsigned long secondary_uart_address = 0,int* errorptr = NULL);
	unsigned long long get_uart_unsigned_long_long_response(unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	int max_secondary_uarts;
	uart_regfile_included_regs_type included_status_regs;
	uart_regfile_included_regs_type included_ctrl_regs;
	std::map< unsigned long,std::map<std::string,std::string> > named_param_map;
	altera_pio_encapsulator* lock_acquired_indication_pio;
	unsigned int lock_acquired_pio_bit;
	uart_regfile_error_record last_error;

public:

	uart_register_file(unsigned the_max_response_length = UART_MAX_RESPONSE_STRING_LENGTH, int the_timeout = 0, bool the_auto_append_uart_indices_to_display_name = false, int the_primary_uart_num_if_known = -1) : uart_encapsulator(the_max_response_length,the_timeout), semaphore_locking_class() {
		this_has_been_initialized = false;
		max_secondary_uarts = 0;
		special_uart_maps = NULL;
		lock_acquired_indication_pio = NULL;
		lock_acquired_pio_bit = 0;
		auto_append_uart_indices_to_display_name = the_auto_append_uart_indices_to_display_name;
		primary_uart_num_if_known = the_primary_uart_num_if_known;
	};
    virtual unsigned long long read_control_reg(unsigned long address, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
    virtual  void              write_control_reg(unsigned long address, unsigned long long data, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual void turn_on_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual void turn_off_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual unsigned long get_control_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual unsigned long get_status_bit(unsigned the_reg_num, unsigned long bit, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
	virtual void set_bit(unsigned the_reg_num, unsigned long bit, unsigned int val, unsigned long secondary_uart_address = 0, int* errorptr = NULL);




     virtual  unsigned long long read_status_reg(unsigned long address,  unsigned long secondary_uart_address = 0, int* errorptr = NULL);
      virtual  unsigned long long read_info_reg(unsigned long address,  unsigned long secondary_uart_address = 0, int* errorptr = NULL);
      virtual   unsigned long      get_version( unsigned long secondary_uart_address = 0);
       virtual unsigned long      is_actually_present(unsigned long secondary_uart_address);
       virtual std::string        get_control_desc(unsigned long address,  unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual std::string        get_status_desc(unsigned long address,  unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual std::string        unsafe_exec_internal_command(std::string the_command, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual std::string        exec_internal_command(std::string the_command,  unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual std::string        exec_internal_command_get_ascii_response(std::string the_command,  unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual std::string        read_all_ctrl(unsigned long secondary_uart_address = 0, int* errorptr = NULL, int pretty_format = 0, int hex_format = 0);
       virtual std::string        read_all_status(unsigned long secondary_uart_address = 0, int* errorptr = NULL, int pretty_format = 0, int hex_format = 0);
       virtual std::string        read_all_control_and_status(unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual std::string        read_all_ctrl_desc(unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual std::string        read_all_status_desc(unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual register_desc_map_type        read_all_ctrl_desc_as_map(unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual register_desc_map_type        read_all_status_desc_as_map(unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual void write_series_of_control_words(register_address_value_pairs_type register_address_value_pairs_in_order_in_order, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
       virtual register_address_value_pairs_type convert_string_to_register_address_value_pairs_in_order(std::string the_string, bool use_hex_notation);
       virtual void write_str_series_of_control_words(std::string the_string,  bool use_hex_notation, unsigned long secondary_uart_address = 0, int* errorptr = NULL);
      virtual void               init_params(map_of_str_to_uint_type* = NULL);
      virtual std::string        get_params_str(unsigned long secondary_uart_address = 0);
      virtual std::string  get_display_name(unsigned long secondary_uart_address = 0);
      virtual void make_named_param_map(unsigned long secondary_uart_address = 0);
      virtual int lock();
      virtual int unlock();
  	  virtual void set_lock_acquired_indication_pio (altera_pio_encapsulator* lock_acquired_indication_pio);
  	  virtual altera_pio_encapsulator* get_lock_acquired_indication_pio();
      virtual unsigned int  get_lock_acquired_pio_bit();
      virtual unsigned int set_lock_acquired_pio_bit(unsigned int lock_acquired_pio_bit);

      virtual int get_max_secondary_uarts() const {
		return max_secondary_uarts;
	}

	virtual  void set_max_secondary_uarts(int maxSecondaryUarts) {
		max_secondary_uarts = maxSecondaryUarts;
	}

	virtual bool is_valid_secondary_uart( int uart_addr ) {
		if ((this->is_enabled()) && (uart_addr >= 0 ) &&  (uart_addr <= get_max_secondary_uarts()) && (is_actually_present(uart_addr)))
		{
			return true;
		} else {
			return false;
		}
	}

	virtual bool secondary_uart_is_within_range( int uart_addr ) {
			if ((this->is_enabled()) && (uart_addr >= 0 ) &&  (uart_addr <= get_max_secondary_uarts()))
			{
				return true;
			} else {
				return false;
			}
		}

	template<class Valuetype>
	      Valuetype get_named_param(std::string key, unsigned long secondary_uart_address = 0){
              return convert_string_to_type<Valuetype>(named_param_map.at(secondary_uart_address).at(key)); //we want this to fail miserably if key is not present
	      }

	virtual unsigned long get_secondary_uart_timeout_in_ticks(unsigned long secondary_uart_address);

	virtual uart_regfile_single_uart_included_regs_type get_included_ctrl_regs(unsigned long secondary_uart_address = 0) ;

	virtual void set_included_ctrl_regs(uart_regfile_single_uart_included_regs_type includedCtrlRegs, unsigned long secondary_uart_address = 0);

	virtual uart_regfile_single_uart_included_regs_type get_included_status_regs(unsigned long  secondary_uart_address = 0) ;


	virtual void set_included_status_regs(uart_regfile_single_uart_included_regs_type includedStatusRegs, unsigned long  secondary_uart_address = 0);

    virtual std::string get_included_status_regs_as_string(unsigned long  secondary_uart_address = 0) ;

    virtual std::string get_included_ctrl_regs_as_string(unsigned long  secondary_uart_address = 0) ;

    virtual std::string get_semaphore_description()
    {
        return std::string("(").append(this->get_device_name()).append(std::string(" Semaphore)"));
    }
    virtual unsigned long get_max_included_ctrl_register   (unsigned long secondary_uart_address = 0);
    virtual unsigned long get_max_included_status_register (unsigned long secondary_uart_address = 0);
    virtual void set_special_uart_maps(special_uart_override_map_type* the_special_uart_maps) {
    	special_uart_maps = the_special_uart_maps;
    }
    virtual special_uart_override_map_type* get_special_uart_maps() {
       	 return special_uart_maps;
       }
    virtual uart_user_types get_user_type(unsigned long secondary_uart_address = 0);

    virtual void set_last_error(unsigned int error_number, unsigned int secondary_uart_address);

    virtual uart_regfile_error_record get_last_error() {
		return last_error;
	}
};

typedef std::vector<uart_register_file*> uart_register_vector_pointer_type;


class uart_regfile_repository_class : public uart_vector_config_encapsulator
 {
protected:
	uart_regfile_display_string_mapping_type uart_display_name_to_addr_map;
	uart_register_vector_pointer_type uart_vec;
public:
	uart_regfile_repository_class() : uart_vector_config_encapsulator() {};
	uart_regfile_repository_class(unsigned int max_uart_num, unsigned int max_virtual_uart_num, unsigned int base) : uart_vector_config_encapsulator(max_virtual_uart_num,base) {
		uart_vec.resize(max_uart_num,NULL);
	}

	uart_register_file* get_uart_ptr_from_number(unsigned int uart_num){
		/* if (uart_num >= uart_vec.size()) {
				   std::cout << "Error: uart_regfile_repository::get_uart_ptr_from_number File: " << __FILE__ << " Line: " << __LINE__ << " uart_num " << uart_num << " bigger or equal to uart_vec.size()" << uart_vec.size() << std::endl;
				   return NULL;
			   } else {
			   */
				   return uart_vec.at(uart_num); //we want this to fail miserably if we are out of range
			   /*}
			    *
			    */
	}

	unsigned int size() {
		return uart_vec.size();
	}

	uart_register_vector_pointer_type get_uart_vec() {
		return uart_vec;
	}

	uart_regfile_display_string_mapping_type get_uart_display_name_to_addr_map() {
			return uart_display_name_to_addr_map;
	}

	bool uart_exists(std::string display_name){
		return (uart_display_name_to_addr_map.find(strtolower(display_name)) != uart_display_name_to_addr_map.end());
	}
	uart_register_file* get_primary_uart_ptr_from_name(std::string display_name) {
		display_name = strtolower(display_name);
		if (uart_display_name_to_addr_map.find(display_name) != uart_display_name_to_addr_map.end()) {
                return get_uart_ptr_from_number(uart_display_name_to_addr_map[display_name].get_uart_primary_index());
		} else {
			  std::cout << "Error: uart_regfile_repository::get_primary_uart_ptr_from_name: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
			  return NULL;
		}
	}

	int get_secondary_uart_index_from_name(std::string display_name) {
		    display_name = strtolower(display_name);
			if (uart_display_name_to_addr_map.find(display_name) != uart_display_name_to_addr_map.end()) {
	                return (uart_display_name_to_addr_map[display_name].get_uart_secondary_index());
			} else {
				  std::cout << "Error: uart_regfile_repository::get_secondary_uart_index_from_name: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
				  return (LINNUX_RETVAL_ERROR);
			}
	}

	int get_primary_uart_index_from_name(std::string display_name) {
			    display_name = strtolower(display_name);
				if (uart_display_name_to_addr_map.find(display_name) != uart_display_name_to_addr_map.end()) {
		                return (uart_display_name_to_addr_map[display_name].get_uart_primary_index());
				} else {
					  std::cout << "Error: uart_regfile_repository::get_secondary_uart_index_from_name: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
					  return (LINNUX_RETVAL_ERROR);
				}
		}

	bool add_uart_ptr(unsigned int uart_num, uart_register_file* uart_ptr) {
	   if (uart_num >= uart_vec.size()) {
		   std::cout << "Error: uart_regfile_repository::add_uart_ptr File: " << __FILE__ << " Line: " << __LINE__ << " uart_num " << uart_num << " bigger or equal to uart_vec.size()" << uart_vec.size() << std::endl;
		   return false;
	   } else {
		   uart_vec.at(uart_num) = uart_ptr;
		   return true;
	   }
	}


	void add_current_uart_to_named_map(unsigned int uart_num, map_of_str_to_uint_type& current_uart_name_to_addr_map) {
		uart_regfile_primary_and_secondary_def current_uart_addresses;
		current_uart_addresses.set_uart_primary_index(uart_num);

		map_of_str_to_uint_type::iterator it;
		 for (it=current_uart_name_to_addr_map.begin(); it!=current_uart_name_to_addr_map.end(); ++it) {
			 current_uart_addresses.set_uart_secondary_index(it->second);
			 std::string proposed_uart_name = strtolower(it->first);
		//	 uart_regfile_display_string_mapping_type::iterator current_uart_name_is_taken_ptr =  uart_display_name_to_addr_map.find(proposed_uart_name);
		//	 if (current_uart_name_is_taken_ptr != uart_display_name_to_addr_map.end()) {
				 uart_display_name_to_addr_map[proposed_uart_name] = current_uart_addresses;
		//	 } else {
		//			std::ostringstream actual_uart_name;
		//		    actual_uart_name << proposed_uart_name << "_" << uart_num << "_" << it->second;
		//		    uart_display_name_to_addr_map[actual_uart_name.str()] = current_uart_addresses;
		//	 }
		 }
	}

	void display_uart_display_name_to_addr_map() {
		uart_regfile_display_string_mapping_type::iterator it;
		std::cout << " =========================================================== " << std::endl;
		std::cout << " UART Display Name Mapping:" << std::endl;
			 for (it=uart_display_name_to_addr_map.begin(); it!=uart_display_name_to_addr_map.end(); ++it) {
				 std::cout << it->first << " " << it->second.get_uart_primary_index() << " " << it->second.get_uart_secondary_index() << std::endl;
			 }
	    std::cout << " =========================================================== " << std::endl;
	}

	std::string get_all_uart_repository_params() {
		uart_regfile_display_string_mapping_type::iterator it;
		std::ostringstream ostr;

			 for (it=uart_display_name_to_addr_map.begin(); it!=uart_display_name_to_addr_map.end(); ++it) {
				 ostr << "{" << it->second.get_uart_primary_index();
				 if (it->second.get_uart_secondary_index() != 0) {
					 ostr << "_" << it->second.get_uart_secondary_index();
				 }
				 ostr <<"} {" << get_uart_ptr_from_number(it->second.get_uart_primary_index())->get_params_str(it->second.get_uart_secondary_index()) << "} ";
			 }

			 return (TrimSpacesFromString(ostr.str()));
	}

	std::string get_all_uart_repository_ctrl_included_regs() {
			uart_regfile_display_string_mapping_type::iterator it;
			std::ostringstream ostr;

				 for (it=uart_display_name_to_addr_map.begin(); it!=uart_display_name_to_addr_map.end(); ++it) {
					 ostr << "{" << it->second.get_uart_primary_index();
					 if (it->second.get_uart_secondary_index() != 0) {
						 ostr << "_" << it->second.get_uart_secondary_index();
					 }
					 ostr <<"} {" << get_uart_ptr_from_number(it->second.get_uart_primary_index())->get_included_ctrl_regs_as_string(it->second.get_uart_secondary_index()) << "} ";
				 }

				 return (TrimSpacesFromString(ostr.str()));
		}

	std::string get_all_uart_repository_status_included_regs() {
				uart_regfile_display_string_mapping_type::iterator it;
				std::ostringstream ostr;

					 for (it=uart_display_name_to_addr_map.begin(); it!=uart_display_name_to_addr_map.end(); ++it) {
						 ostr << "{" << it->second.get_uart_primary_index();
						 if (it->second.get_uart_secondary_index() != 0) {
							 ostr << "_" << it->second.get_uart_secondary_index();
						 }
						 ostr <<"} {" << get_uart_ptr_from_number(it->second.get_uart_primary_index())->get_included_status_regs_as_string(it->second.get_uart_secondary_index()) << "} ";
					 }

					 return (TrimSpacesFromString(ostr.str()));
			}

     unsigned long long named_read_control_reg (std::string display_name, unsigned long address, int* errorptr = NULL) {
    	 if (uart_exists(display_name)) {
    		 return get_primary_uart_ptr_from_name(display_name)->read_control_reg(address,this->get_secondary_uart_index_from_name(display_name),errorptr);
    	 } else {
    		 std::cout << "Error: uart_regfile_repository::named_read_control_reg: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
    		 return 0;
    	 }
     }

     void named_write_control_reg(std::string display_name, unsigned long address, unsigned long long data, int* errorptr = NULL){
    	 if (uart_exists(display_name)) {
    		 get_primary_uart_ptr_from_name(display_name)->write_control_reg(address,data,this->get_secondary_uart_index_from_name(display_name),errorptr);
    	 } else {
    		 std::cout << "Error: uart_regfile_repository::named_write_control_reg: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
    	 }
     };

     unsigned long long named_read_status_reg  (std::string display_name, unsigned long address, int* errorptr = NULL){
    	 if (uart_exists(display_name)) {
    		 return get_primary_uart_ptr_from_name(display_name)->read_status_reg(address,this->get_secondary_uart_index_from_name(display_name),errorptr);
    	 } else {
    		 std::cout << "Error: uart_regfile_repository::named_read_status_reg: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
    		 return 0;
    	 }
     };

     std::string named_get_control_desc (std::string display_name, unsigned long address, int* errorptr = NULL){
    	 if (uart_exists(display_name)) {
    	    		 return get_primary_uart_ptr_from_name(display_name)->get_control_desc(address,this->get_secondary_uart_index_from_name(display_name),errorptr);
    	    	 } else {
    	    		 std::cout << "Error: uart_regfile_repository::named_write_control_reg: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
    	    		 return 0;
    	    	 }
     };
     std::string named_get_status_desc  (std::string display_name, unsigned long address, int* errorptr = NULL){
    	 if (uart_exists(display_name)) {
    		 return get_primary_uart_ptr_from_name(display_name)->get_status_desc(address,this->get_secondary_uart_index_from_name(display_name),errorptr);
    	 } else {
    		 std::cout << "Error: uart_regfile_repository::named_get_status_desc: " << __FILE__ << " Line: " << __LINE__ << " Unknown UART: " << display_name << std::endl;
    		 return 0;
    	 }
     };
     vector_of_uart_primary_and_secondary_defs get_all_uarts_of_type(uart_user_types user_type);
     std::string  read_multiple_control_and_status(std::vector<std::string>& uarts_to_acquire, int* errorptr = NULL);
};

#endif /* UART_REGISTER_FILE_H_ */
