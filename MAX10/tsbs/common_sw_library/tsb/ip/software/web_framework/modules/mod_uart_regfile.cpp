/*
 * mod_uart_regfile.cpp
 *
 *  Created on: May 3, 2017
 *      Author: yairlinn
 */

extern "C" {
	#include "mod_uart_regfile.h"
}
#include "uart_encapsulator.h"
#include "uart_vector_config_encapsulator.h"
#include "semaphore_locking_class.h"
#include "linnux_utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string>
#include <sstream>
#include <map>
#include <vector>
#include "assert.h"
#include "uart_esper_liason.h"
#include "uart_register_file.h"

static uint8_t uart_regfile_control_reg_function_handler(tESPERMID mid, tESPERVID vid, struct _tESPERVar* var, eESPERRequest request, uint32_t offset, uint32_t num_elements, void* ctx) {

	 uart_esper_liason* uart_regfile_ctx = (uart_esper_liason*)ctx;
     unsigned long regnum = uart_regfile_ctx->control_regs_desc_to_num_map[std::string(var->info.key)];
 	uint32_t byte_count;
 	uint32_t byte_offset;
 	byte_offset = offset * ESPER_GetTypeSize(var->info.type);
 	byte_count = num_elements * ESPER_GetTypeSize(var->info.type);


	switch(request) {
	case ESPER_REQUEST_WRITE_POST:
		uart_regfile_ctx->uart_ptr->write_control_reg(regnum,uart_regfile_ctx->control_reg_shadow_buffer[regnum],uart_regfile_ctx->secondary_uart_address);
		//memcpy((void*)var->io + byte_offset, var->data + byte_offset, byte_count);
		break;
	case ESPER_REQUEST_READ_PRE:
		uart_regfile_ctx->control_reg_shadow_buffer[regnum] = uart_regfile_ctx->uart_ptr->read_control_reg(regnum,uart_regfile_ctx->secondary_uart_address) & 0xFFFFFFFF;
		//memcpy(var->data + byte_offset, (void*)var->io + byte_offset, byte_count);
		ESPER_TouchVar(mid, vid);
		break;

	default:
		break;
	}
//   std::cout << " uart_regfile_control_reg_function_handler var->info.key = " << var->info.key << " regnum = " << regnum << " val = 0x" << std::hex << uart_regfile_ctx->control_reg_shadow_io_buffer[regnum] << std::dec <<  " = " << uart_regfile_ctx->control_reg_shadow_io_buffer[regnum] << std::endl;

	return 1;
}

static uint8_t uart_regfile_status_reg_function_handler(tESPERMID mid, tESPERVID vid, struct _tESPERVar* var, eESPERRequest request, uint32_t offset, uint32_t num_elements, void* ctx) {
	 uart_esper_liason* uart_regfile_ctx = (uart_esper_liason*)ctx;
     unsigned long regnum = uart_regfile_ctx->status_regs_desc_to_num_map[std::string(var->info.key)];
 	uint32_t byte_count;
  	uint32_t byte_offset;
  	byte_offset = offset * ESPER_GetTypeSize(var->info.type);
  	byte_count = num_elements * ESPER_GetTypeSize(var->info.type);

   //  std::cout << " uart_regfile_status_reg_function_handler var->info.key = " << var->info.key << " regnum = " << regnum << std::endl;

	switch(request) {
	case ESPER_REQUEST_READ_PRE:
		uart_regfile_ctx->status_reg_shadow_io_buffer[regnum] = uart_regfile_ctx->uart_ptr->read_status_reg(regnum,uart_regfile_ctx->secondary_uart_address) & 0xFFFFFFFF;
		memcpy(var->data + byte_offset, (void*)var->io + byte_offset, byte_count);
		ESPER_TouchVar(mid, vid);

		break;

	default:
		break;
	}
   // std::cout << " uart_regfile_status_reg_function_handler var->info.key = " << var->info.key << " regnum = " << regnum << " val = 0x" << std::hex << uart_regfile_ctx->status_reg_shadow_io_buffer[regnum] << std::dec <<  " = " << uart_regfile_ctx->status_reg_shadow_io_buffer[regnum] << std::endl;

	return 1;
}

static int key_index = 0;

static const int confidence_multiplier = 10;
void *malloc_regspace(std::string name, uint32_t size) {
	void *outptr;
	uint32_t actual_size = size*confidence_multiplier;
	outptr = malloc ((sizeof(uint32_t))*(actual_size));
	std::cout << " Allocated for : " << name << " size: " << actual_size << " Starting at: 0x" << std::hex << (unsigned int) outptr << std::dec << std::endl;
	return (outptr);
}

static void Init(tESPERMID mid, uart_esper_liason* ctx) {

	std::cout << "Starting init for UART_" << ctx->primary_uart_num << "_" << ctx->secondary_uart_address << std::endl;
	ctx->control_regs_desc = ctx->uart_ptr->read_all_ctrl_desc_as_map(ctx->secondary_uart_address);
	ctx->status_regs_desc  =  ctx->uart_ptr->read_all_status_desc_as_map(ctx->secondary_uart_address);
	ctx->control_reg_shadow_buffer    = (uint32_t* )malloc_regspace   ( "control_reg_shadow_buffer   ",  (ctx->control_regs_desc.size()));
	ctx->status_reg_shadow_buffer     = (uint32_t* ) malloc_regspace  ( "status_reg_shadow_buffer    ", (ctx->status_regs_desc.size()));
	ctx->control_reg_shadow_io_buffer =  (uint32_t* ) malloc_regspace ( "control_reg_shadow_io_buffer", (ctx->control_regs_desc.size()));
	ctx->status_reg_shadow_io_buffer  =  (uint32_t* ) malloc_regspace ( "status_reg_shadow_io_buffer ", (ctx->status_regs_desc.size()));


	for (int i = 0; i < ctx->control_regs_desc.size(); i++) {
		std::ostringstream control_name;
		//control_name << "ctrl_" << key_index;
		//key_index++;
		control_name <<  "U" << ctx->primary_uart_num << "." << ctx->secondary_uart_address << std::hex << ".C." << i << (ctx->control_regs_desc[i] == "" ? "" : "_" ) <<  ctx->control_regs_desc[i] << std::dec;
		ctx->control_regs_desc_to_num_map[control_name.str()] = i;
		ESPER_CreateVarUInt32(mid,
			control_name.str().c_str(),
			ESPER_OPTION_WR_RD | ctx->flags, 1,
			&(ctx->control_reg_shadow_buffer[i]),
			&(ctx->control_reg_shadow_io_buffer[i]),
			uart_regfile_control_reg_function_handler);
    	    std::cout << "Creating Control variable name " << control_name.str() << std::endl;

			tESPERVID vid = ESPER_GetVarIdByKey(mid,control_name.str().c_str());

            ctx->is_status_reg[control_name.str()] = 0;
	}

	for (int i = 0; i < ctx->status_regs_desc.size(); i++) {
		    std::ostringstream status_name;

			status_name << "U" << ctx->primary_uart_num << "." << ctx->secondary_uart_address << std::hex << ".S." << i <<  (ctx->status_regs_desc[i] == "" ? "" : "_" ) <<  ctx->status_regs_desc[i] << std::dec;
			//status_name << "status_" << key_index;
			//key_index++;
			ctx->status_regs_desc_to_num_map[status_name.str()] = i;
			ESPER_CreateVarUInt32(mid,
				status_name.str().c_str(),
				ESPER_OPTION_RD | ctx->flags, 1,
				&(ctx->status_reg_shadow_buffer[i]),
				&(ctx->status_reg_shadow_io_buffer[i]),
				uart_regfile_status_reg_function_handler);
    	        std::cout << "Creating Status variable name " << status_name.str() << std::endl;
    	        tESPERVID vid = ESPER_GetVarIdByKey(mid,status_name.str().c_str());
    	        ctx->is_status_reg[status_name.str()] = 1;
		}

	std::cout << "finished  Init for " << "U" << ctx->primary_uart_num << "." << ctx->secondary_uart_address << std::endl;
    std::cout.flush();
	return;
}
void* UART_Regfile_ModuleInit(void* ctx, void* uart_ptr, unsigned long primary_uart_num, unsigned long secondary_uart_address, ModuleHandler High_level_ModuleHandler, ESPER_OPTIONS flags) {
	if(!ctx) return 0;
	uart_esper_liason* context = (uart_esper_liason*) ctx;
	context->primary_uart_num = primary_uart_num;
	context->secondary_uart_address = secondary_uart_address;
	context->uart_ptr = (uart_register_file*) uart_ptr;
	context->High_level_ModuleHandler = High_level_ModuleHandler;
	context->flags = flags;
	return ctx;
}

static void Start(tESPERMID mid, uart_register_file* ctx) {

	return;
}

static void Update(tESPERMID mid, uart_esper_liason* ctx) {
//	tESPERVID ESPER_GetVarIdByKey(tESPERMID mid, const char* key, eESPERError* err) {
//	eESPERError ESPER_WriteVarUInt32(tESPERMID mid, tESPERVID vid,uint32_t offset, uint32_t data)	{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_UINT32, offset, &num_elements, &data, &len); }

	register_desc_inverse_map_type::iterator it;


	for (it=ctx->key_to_vid_map.begin();  it!=ctx->key_to_vid_map.end(); it++) {
		std::string key = it->first;
       	if (ctx->is_status_reg[key]) {
	                unsigned long regnum = ctx->status_regs_desc_to_num_map[std::string(key)];
                    uint32_t data = ctx->uart_ptr->read_status_reg(regnum,ctx->secondary_uart_address) & 0xFFFFFFFF;
                    tESPERVID vid = it->second;
                	//eESPERError err_code = ESPER_WriteVarUInt32(mid,vid,0,data);
                    ctx->status_reg_shadow_io_buffer[regnum] = data;
                    ESPER_TouchVar(mid,vid);

			} else {
				 unsigned long regnum = ctx->control_regs_desc_to_num_map[std::string(key)];
				 uint32_t data = ctx->uart_ptr->read_control_reg(regnum,ctx->secondary_uart_address) & 0xFFFFFFFF;
				 tESPERVID vid = it->second;
				 //eESPERError err_code = ESPER_WriteVarUInt32(mid,vid,0,data);
				  ESPER_WriteVarUInt32(mid,vid,0,data);

			}
	}

	return;
}


eESPERResponse UART_Regfile_ModuleHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx) {
	uart_esper_liason* context = (uart_esper_liason*) ctx;

	switch(state) {
	case ESPER_STATE_INIT:

		Init(mid, (uart_esper_liason*) ctx);
		std::cout << "Finished init in UART_Regfile_ModuleHandler" << std::endl;
        std::cout.flush();
		break;

	case ESPER_STATE_START:
		 Start(mid, (uart_register_file*)ctx);
		 break;
	case ESPER_STATE_UPDATE:
		 Update(mid, (uart_esper_liason*) ctx);
		 //std::cout << "Finished update in UART_Regfile_ModuleHandler" << std::endl;
		 //std::cout.flush();
		 break;

	case ESPER_STATE_STOP:
		break;
	}
	if (context->High_level_ModuleHandler != NULL)
	{
	   context->High_level_ModuleHandler(mid, gid, state, ctx);
	}
	return ESPER_RESP_OK;
}



