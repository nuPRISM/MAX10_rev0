/*
 * comm_uart.c
 *
 *  Created on: Dec 12, 2016
 *      Author: admin
 */

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include "mod_uart.h"

#define CMD_HELP "?"
#define CMD_UPTIME "up"
#define CMD_SET_MOD "sm"
#define CMD_LIST_MOD "lm"
#define CMD_LIST_VAR "lv"
#define CMD_WR_VAR "wr"
#define CMD_RD_VAR "rd"

static eESPERResponse Init(tESPERModuleUART* ctx);
static eESPERResponse Start(tESPERModuleUART* ctx);
static eESPERResponse Stop(tESPERModuleUART* ctx);
static eESPERResponse Update(tESPERModuleUART* ctx);

static void print_help(tESPERModuleUART* ctx, char* params);
static void print_uptime(tESPERModuleUART* ctx, char* params);
static void set_module(tESPERModuleUART* ctx, char* params);
static void list_modules(tESPERModuleUART* ctx, char* params);
static void list_vars(tESPERModuleUART* ctx, char* params);
static void write_var(tESPERModuleUART* ctx, char* params);
static void read_var(tESPERModuleUART* ctx, char* params);

static void print_error(tESPERModuleUART* ctx, eESPERError err);
static void print_var(tESPERModuleUART* ctx, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info);

typedef struct {
	char* cmd;
	char* desc;
	void (*fnCmd)(tESPERModuleUART* ctx, char* params);
} tCmdList;

static tCmdList cmd_list[] = {
	{ CMD_HELP, 	"Help", print_help },
	{ CMD_UPTIME, 	"Node Uptime", print_uptime },
	{ CMD_SET_MOD, 	"Set Active Module", set_module },
	{ CMD_LIST_MOD, "List Available Modules", list_modules },
	{ CMD_LIST_VAR, "List Module Variables", list_vars },
	{ CMD_WR_VAR, 	"Write Variable", write_var },
	{ CMD_RD_VAR, 	"Read Variable", read_var },
	{0}
};

tESPERModuleUART* ModuleUARTInit(FILE* dev, char* uart_buff, uint32_t uart_buff_sz, tESPERModuleUART* ctx) {
	uint32_t n;

	ctx->buff = uart_buff;
	ctx->buff_len = uart_buff_sz;
	ctx->dev = dev;
	ctx->active_module = 0;

	for(n=0; n<uart_buff_sz; n++ ) {
		ctx->buff[n] = 0;
	}

	fcntl(fileno(ctx->dev), F_SETFL, O_NONBLOCK);

	return ctx;
}

eESPERResponse ModuleUARTHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx) {
	switch(state) {
	case ESPER_MOD_STATE_INIT:
		return Init((tESPERModuleUART*)ctx);
	case ESPER_MOD_STATE_START:
		return Start((tESPERModuleUART*)ctx);
	case ESPER_MOD_STATE_STOP:
		return Stop((tESPERModuleUART*)ctx);
	case ESPER_MOD_STATE_UPDATE:
		return Update((tESPERModuleUART*)ctx);
	}

	return ESPER_RESP_OK;
}

static eESPERResponse Init(tESPERModuleUART* ctx) {
	return ESPER_RESP_OK;
}

static eESPERResponse Start(tESPERModuleUART* ctx) {

	fprintf(ctx->dev, "\nESPER Console Initialized\nType '%s' for help\n", CMD_HELP);
	return ESPER_ERR_OK;
}

static eESPERResponse Stop(tESPERModuleUART* ctx) {
	return ESPER_RESP_OK;
}

static eESPERResponse Update(tESPERModuleUART* ctx) {
	char* str;
	tCmdList* cmd;

	str = fgets(ctx->buff, ctx->buff_len, ctx->dev);
	if(str != 0) {
		for(cmd=cmd_list; cmd->cmd  != 0; cmd++) {
			if(strncmp(ctx->buff, cmd->cmd, strlen(cmd->cmd)) == 0) {
				cmd->fnCmd(ctx, &ctx->buff[strlen(cmd->cmd)+1]);
				break;
			}
		}

		if(cmd->cmd == 0) {
			fprintf(ctx->dev, "\nUnknown command: %s\n", ctx->buff);
			print_help(ctx, 0);
		}
	}

	return ESPER_RESP_OK;
}

static void print_help(tESPERModuleUART* ctx, char* params) {
	tCmdList* cmd;

	fprintf(ctx->dev, "ESPER Commands:\n");
	for(cmd=cmd_list; cmd->cmd != 0; cmd++) {
		fprintf(ctx->dev, "%s - %s\n", cmd->cmd, cmd->desc);
	}
	fprintf(ctx->dev, "\n");
}

static void print_uptime(tESPERModuleUART* ctx, char* params) {
	ESPER_TIMESTAMP ts;

	ts = ESPER_GetUptime();

	fprintf(ctx->dev, "Node Uptime: %lu", ts);
}

static void set_module(tESPERModuleUART* ctx, char* params) {
	tESPERModuleInfo info;
	eESPERError err;
	uint32_t n;
	char* endstr;

	n = strtol(params, &endstr, 0);
	if((endstr == params) || (n < 0) || (n >= ESPER_GetNumModules())) {
		fprintf(ctx->dev, "Invalid Module ID\n");
		return;
	}

	if(ESPER_GetModuleInfo(n, &info, &err) == 0) {
		print_error(ctx, err);
		return;
	}

	ctx->active_module = n;
	fprintf(ctx->dev, "Setting Active Module to %s\n", info.key);
}

static void list_modules(tESPERModuleUART* ctx, char* params) {
	uint32_t n;
	uint32_t max_modules;
	tESPERModuleInfo info;
	eESPERError err;

	max_modules = ESPER_GetNumModules();

	fprintf(ctx->dev, "Id   Key  		   Last Modified\n--- ---             -------------\n");
	for(n=0; n<max_modules; n++) {
		if(ESPER_GetModuleInfo(n, &info, &err) == 0) {
			print_error(ctx, err);
			return;
		}
		fprintf(ctx->dev, "%-4lu %-16.16s%.8lu\n", n, info.key, info.last_modified);
	}
}

static void list_vars(tESPERModuleUART* ctx, char* params) {
	uint32_t n;
	uint32_t max_vars;
	tESPERVarInfo varInfo;
	eESPERError err;

	max_vars = ESPER_GetNumModuleVars(ctx->active_module);
	if(!max_vars) {
		print_error(ctx, ESPER_ERR_VID_NOT_FOUND);
		return;
	}

	fprintf(ctx->dev, "Id   Key              Type       Elements Modified Data\n--   ---              ----       -------- -------- ----\n");
	for(n=0; n<max_vars; n++) {
		ESPER_GetVarInfo(ctx->active_module, n, &varInfo, &err);
		if(err != ESPER_ERR_OK) {
			print_error(ctx, err);
			return;
		}
		print_var(ctx, ctx->active_module, n, &varInfo);
	}
}

static void write_var(tESPERModuleUART* ctx, char* params) {
	fprintf(ctx->dev, "%s", params);
}

static void read_var(tESPERModuleUART* ctx, char* params) {
	uint32_t n;
	uint32_t max_vars;
	tESPERVarInfo varInfo;
	eESPERError err;
	char* endstr;

	max_vars = ESPER_GetNumModuleVars(ctx->active_module);
	if(!max_vars) {
		print_error(ctx, ESPER_ERR_VID_NOT_FOUND);
		return;
	}


	n = strtol(params, &endstr, 0);
	if((endstr == params) || (n >= max_vars)) {
		fprintf(ctx->dev, "Invalid Variable ID\n");
		return;
	}

	ESPER_GetVarInfo(ctx->active_module, n, &varInfo, &err);
	if(err != ESPER_ERR_OK) {
		print_error(ctx, err);
		return;
	}

	fprintf(ctx->dev, "Id   Key              Type       Elements Modified Data\n--   ---              ----       -------- -------- ----\n");
	print_var(ctx, ctx->active_module, n, &varInfo);
}

static void print_error(tESPERModuleUART* ctx, eESPERError err) {
	fprintf(ctx->dev, "%s\n", ESPER_GetErrorString(err));
}


static void print_var(tESPERModuleUART* ctx, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info) {
	uint32_t n;

	char data_str[32];
	char data_buff[80];

	// convert data into string
	switch(info->type) {
	case ESPER_TYPE_NULL:
		strlcpy(data_buff, "[ null ]", sizeof(data_str) );
		break;
	case ESPER_TYPE_UINT8:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%u ", ESPER_ReadVarUInt8(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_UINT16:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%u ", ESPER_ReadVarUInt16(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_UINT32:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%lu ", ESPER_ReadVarUInt32(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_UINT64:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%llu ", ESPER_ReadVarUInt64(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_SINT8:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%d ", ESPER_ReadVarSInt8(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_SINT16:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%d ", ESPER_ReadVarSInt16(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_SINT32:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%ld ", ESPER_ReadVarSInt32(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_SINT64:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%lld ", ESPER_ReadVarSInt64(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_FLOAT32:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%f ", ESPER_ReadVarFloat32(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_FLOAT64:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%f ", ESPER_ReadVarFloat64(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	case ESPER_TYPE_ASCII:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			sprintf(data_str, "%c", ESPER_ReadVarASCII(mid, vid, n));
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, " ]", 80);

		break;
	case ESPER_TYPE_BOOL:
		strlcpy(data_buff, "[ ", 80);
		for(n=0; n<info->num_elements; n++) {
			if(ESPER_ReadVarBool(mid, vid, n)) {
				sprintf(data_str, "true ");
			} else {
				sprintf(data_str, "false ");
			}
			strlcat(data_buff, data_str, 80);
		}
		strlcat(data_buff, "]", 80);
		break;
	}

	fprintf(ctx->dev, "%-4lu %-16.16s %-10.10s %-8lu %.8lu %s\n", vid, info->key, ESPER_GetTypeString(info->type), info->num_elements, info->last_modified, data_buff);
}
