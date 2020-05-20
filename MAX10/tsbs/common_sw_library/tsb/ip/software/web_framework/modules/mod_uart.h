/*
 * mod_uart.h
 *
 *  Created on: Dec 12, 2016
 *      Author: admin
 */

#ifndef MOD_UART_H_
#define MOD_UART_H_

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <sys/time.h>
#include <esper.h>

typedef struct {
	FILE* dev;
	char* buff;
	uint32_t buff_len;
	tESPERMID active_module;
} tESPERModuleUART;

tESPERModuleUART* ModuleUARTInit(FILE* dev, char* uart_buff, uint32_t uart_buff_sz, tESPERModuleUART* ctx);
eESPERResponse ModuleUARTHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx);

#endif /* MOD_UART_H_ */
