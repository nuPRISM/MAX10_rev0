/*
 * mod_uart_regfile.h
 *
 *  Created on: May 3, 2017
 *      Author: yairlinn
 */

#ifndef MOD_UART_REGFILE_H_
#define MOD_UART_REGFILE_H_

#include <unistd.h>
#include <esper.h>

eESPERResponse UART_Regfile_ModuleHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx);
void* UART_Regfile_ModuleInit(void* ctx, void* uart_ptr, unsigned long primary_uart_num, unsigned long secondary_uart_address, ModuleHandler High_level_ModuleHandler, ESPER_OPTIONS flags);


#endif /* MOD_UART_REGFILE_H_ */
