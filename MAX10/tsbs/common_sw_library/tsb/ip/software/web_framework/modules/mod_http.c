/*
 * http.c

 *
 *  Created on: Nov 23, 2016
 *      Author: bryerton
 */

#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <ctype.h>
#include "mod_http.h"
#include "basedef.h"
#include <chan_fatfs/ff.h>

static int ev_handler(struct mg_connection *conn, enum mg_event ev);
static int send_static_file(struct mg_connection *conn);
static int json_error_msg(struct mg_connection* conn, eESPERResponse resp, const char* msg);
static int binary_error_msg(struct mg_connection* conn, eESPERResponse resp);

static int esper_read_node(struct mg_connection* conn);
static int esper_read_module(struct mg_connection* conn);
static int esper_read_var(struct mg_connection* conn);
static int esper_read_attr(struct mg_connection* conn);
static int esper_write_var(struct mg_connection* conn);
static int esper_help_page(struct mg_connection* conn);

static int binary_read_node(struct mg_connection* conn, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc);
static int binary_read_module(struct mg_connection* conn, tESPERMID mid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc);
static int binary_read_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc);
static int binary_read_attr(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid);
static int binary_write_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements);

static int json_read_node(struct mg_connection* conn, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc);
static int json_read_module(struct mg_connection* conn, tESPERMID mid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc);
static int json_read_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc);
static int json_read_attr(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid);
static int json_write_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements);

static void binary_frag_mod_read(struct mg_connection* conn, tESPERMID mid, tESPERModuleInfo* info, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t includeData);
static void binary_frag_var_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t includeData, uint8_t dataOnly);
static void binary_frag_attr_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info);
static void binary_frag_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements, uint8_t dataOnly);
static void binary_frag_attr_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info);

static int json_frag_mod_read(struct mg_connection* conn, tESPERMID mid, tESPERModuleInfo* info, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t was_printed, uint8_t includeData);
static int json_frag_var_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t was_printed, uint8_t includeData, uint8_t dataOnly);
static int json_frag_attr_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info, uint8_t was_printed);

static void json_frag_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements);
static void json_frag_attr_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info);

static eESPERResponse binary_frag_write_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements);
static eESPERResponse json_frag_write_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements);

static eESPERResponse write_json_token_to_data(const char* json_buffer, jsmntok_t* json_token, ESPER_TYPE type, tESPERMID mid, tESPERVID vid, uint32_t offset);

static ESPER_TIMESTAMP get_timestamp(struct mg_connection* conn);
static tESPERMID get_module_id(struct mg_connection* conn);
static tESPERVID get_var_id(struct mg_connection* conn, tESPERMID mid);
static tESPERAID get_attr_id(struct mg_connection* conn, tESPERMID mid, tESPERVID vid);
static char* get_jsonp_callback(struct mg_connection* conn);
static uint32_t get_offset(struct mg_connection* conn);
static uint32_t get_num_elements(struct mg_connection* conn, const tESPERVarInfo* info);
static uint32_t get_write_count(struct mg_connection* conn);
static uint8_t get_use_binary(struct mg_connection* conn);
static char is_attr_set(struct mg_connection* conn, char* attr);
static uint16_t get_http_code_based_on_response(eESPERResponse resp);

static eESPERResponse Init(tESPERMID mid, tESPERModuleHTTP* ctx);
static eESPERResponse Start(tESPERMID mid, tESPERModuleHTTP* ctx);
static eESPERResponse Update(tESPERMID mid, tESPERModuleHTTP* ctx);
static eESPERResponse Stop(tESPERMID mid, tESPERModuleHTTP* ctx);

typedef int (*esper_http_cmd_func)(struct mg_connection* conn);

typedef struct {
	char* cmd;
	char* desc;
	esper_http_cmd_func cmd_func;
} tESPERHTTPRequest;

static tESPERHTTPRequest g_json_requests [] = {
		{ "/read_node",		"Read Node Data",		esper_read_node },
		{ "/read_module",	"Read Module Data",		esper_read_module },
		{ "/read_var", 		"Read Variable Data",	esper_read_var },
		{ "/read_attr", 	"Read Attribute Data",	esper_read_attr },

		{ "/write_var",		"Write Variable Data", 	esper_write_var },
		{ "/list_cmds", 	"JSON Command List",	esper_help_page },
		{ 0 }
};

tESPERModuleHTTP* ModuleHTTPInit(const char* name, const char* webroot, uint16_t port, tESPERModuleHTTP* ctx) {
	if(!ctx) return 0;

	esper_strcpy(ctx->name, name, sizeof(ctx->name));
	esper_strcpy(ctx->webroot_dir, webroot, sizeof(ctx->webroot_dir));
	ctx->port = port;
	ctx->max_json_tokens = MAX_JSON_TOKENS;

	return ctx;
}

eESPERResponse ModuleHTTPHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx) {

	switch(state) {
	case ESPER_STATE_INIT:
		return Init(mid, (tESPERModuleHTTP*)ctx);
	case ESPER_STATE_START:
		return Start(mid, (tESPERModuleHTTP*)ctx);
	case ESPER_STATE_UPDATE:
		return Update(mid, (tESPERModuleHTTP*)ctx);
	case ESPER_STATE_STOP:
		return Stop(mid, (tESPERModuleHTTP*)ctx);
	}

	return ESPER_RESP_OK;
}

static eESPERResponse Init(tESPERMID mid, tESPERModuleHTTP* ctx) {
	tESPERVID vid;

	vid = ESPER_CreateVarASCII(mid, "name", ESPER_OPTION_RD, ESPER_MOD_HTTP_NAME_LEN, ctx->name, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Server Name");

	vid = ESPER_CreateVarUInt16(mid, "port", 	ESPER_OPTION_RD, 1, &ctx->port, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Port");

	vid = ESPER_CreateVarASCII(mid, "webroot", 	ESPER_OPTION_RD, ESPER_MOD_HTTP_WEBROOT_LEN, ctx->webroot_dir, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Web Root Directory");

	vid = ESPER_CreateVarUInt32(mid, "max_json_tokens", ESPER_OPTION_RD, 1, &ctx->max_json_tokens, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Max JSON Tokens");

	return ESPER_RESP_OK;
}

static eESPERResponse Start(tESPERMID mid, tESPERModuleHTTP* ctx) {
	char strPort[6]; // maximum characters needed to express a positive 16bit uint is 5, +1 for null

	snprintf(strPort, sizeof(strPort), "%d", ctx->port);

	// Create and configure the server
	ctx->http_ctx = mg_create_server(ctx, ev_handler);
	mg_set_option(ctx->http_ctx, "document_root", ctx->webroot_dir);
	mg_set_option(ctx->http_ctx, "listening_port", strPort);
	mg_set_option(ctx->http_ctx, "auth_domain", ctx->name);

	return ESPER_RESP_OK;
}

static eESPERResponse Update(tESPERMID mid, tESPERModuleHTTP* ctx) {
	mg_poll_server(ctx->http_ctx, 250);

	return ESPER_RESP_OK;
}

static eESPERResponse Stop(tESPERMID mid, tESPERModuleHTTP* ctx) {
	mg_destroy_server(&ctx->http_ctx);

	return ESPER_RESP_OK;
}

static int esper_help_page(struct mg_connection* conn) {
	tESPERHTTPRequest* req;

	mg_send_status(conn, 200);
	mg_send_header(conn, "Access-Control-Allow-Origin","*");
	if(get_jsonp_callback(conn)) {
		mg_send_header(conn, "Content-Type", "application/javascript");
		mg_printf_data(conn, "%s(", get_jsonp_callback(conn));
	} else {
		mg_send_header(conn, "Content-Type", "application/json");
	}

	mg_printf_data(conn, "[");

	for(req = g_json_requests; req->cmd != 0; req++) {
		mg_printf_data(conn, "\t\t{ \"url\": \"%s\", \"desc\": \"%s\" }", req->cmd, req->desc);
		if(req[1].cmd != 0) mg_printf_data(conn, ", \n");
	}

	mg_printf_data(conn, "]");
	if(get_jsonp_callback(conn)) {
		mg_printf_data(conn, ");");
	}

	return MG_TRUE;
}



static int ev_handler(struct mg_connection *conn, enum mg_event ev) {
	tESPERHTTPRequest* req;

	if (ev == MG_AUTH) {
		return MG_TRUE;
	}

	if(ev == MG_POLL) {
		return MG_TRUE;
	}

	if (ev == MG_REQUEST) {

		for(req = g_json_requests; req->cmd_func != 0; req++) {
			if(!strncmp(conn->uri, req->cmd, strlen(req->cmd))) { 
				return req->cmd_func(conn); 
			}
		}

		return send_static_file(conn);
	}

	return MG_FALSE;
}
static int send_static_file(struct mg_connection *conn) {

	//FILE* pFile;
	FIL FileObject;
	FRESULT error_code;
	char buffer[1024];
	int webroot_dir_len;
	int r;
	int zipfs_name_len;
	UINT bytes_actually_read;
	tESPERModuleHTTP* ctx;
	ctx = (tESPERModuleHTTP*)conn->server_param;
	webroot_dir_len = strlen(ctx->webroot_dir);

	esper_strcpy(buffer, ctx->webroot_dir, 1024);

	// If no file is requested, hand over index.html
	if((conn->uri[0] == '/') && (conn->uri[1] == '\0')) {
		esper_strcpy(buffer+webroot_dir_len, "/index.html", 1024-webroot_dir_len);
	} else {
		esper_strcpy(buffer+webroot_dir_len, conn->uri, 1024-webroot_dir_len);
	}

	/*pFile = fopen(buffer, "r");*/

	if (   (
			error_code = f_open (&FileObject,			/* Pointer to the blank file object */
					buffer,	/* Pointer to the file name */
					FA_READ
					)
	) != FR_OK )			/* Access mode and file open mode flags */
	{
mg_send_status(conn, 404);
		mg_send_header(conn, "Content-Type", "text/plain");
		mg_printf_data(conn, "File not found");
		return MG_TRUE;
	} else {
		
		/*
		 r = sizeof(buffer);
		 do {
			r = fread(buffer, 1, r, pFile);
			if(r != 0) {
				mg_send_data(conn, buffer, r);
			}
		} while(r != 0);
        */
		do {
		error_code = f_read (  &FileObject,    /* Pointer to the file object structure */
				buffer,       /* Pointer to the buffer to store read data */
				sizeof(buffer)-1,    /* Number of bytes to read */
				&bytes_actually_read      /* Pointer to the variable to return number of bytes read */
		);
		if ((error_code == FR_OK ) && (bytes_actually_read > 0))
		{
		  mg_send_data(conn, buffer, bytes_actually_read);
		} else
		{
			f_close(&FileObject);
			break;
		}
		} while (1);
				
		//fclose(pFile);
	}

	return MG_TRUE;
}


static uint16_t get_http_code_based_on_response(eESPERResponse resp) {
	switch(resp) {
	case ESPER_RESP_OK:
		return 200;

	case ESPER_RESP_ERROR:
		return 500; // unknown internal error

	case ESPER_RESP_RESET:
	case ESPER_RESP_SHUTDOWN:
		return 200; // we should never get this!
	
	case ESPER_RESP_OUT_OF_RANGE:
		return 416; 
	
	case ESPER_RESP_BUFF_TOO_SMALL:
		return 413;
	
	case ESPER_RESP_WRITE_ONLY:
	case ESPER_RESP_READ_ONLY:
	case ESPER_RESP_LOCKED:
		return 405;

	case ESPER_RESP_UNKNOWN_TYPE:
	case ESPER_RESP_TYPE_MISMATCH:
		return 400;

	case ESPER_RESP_VID_NOT_FOUND:
	case ESPER_RESP_MID_NOT_FOUND:
	case ESPER_RESP_AID_NOT_FOUND:
		return 404;
	
	case ESPER_RESP_NULL_PTR_PASSED:
	default:
		return 500;

	}

	return 500;
}

static char* get_jsonp_callback(struct mg_connection* conn) {
	static char str_callback[80];

	if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_CALLBACK, str_callback, sizeof(str_callback)) < 1) {
		return 0;
	}

	return str_callback;
}

static uint32_t get_offset(struct mg_connection* conn) {
	uint32_t offset;
	char str[ESPER_KEY_LEN];
	char* endptr;

	// Fail by putting mod_id to ESPER_BAD_MODULE_ID but leave the error as "OK",
	offset = 0;

	if(mg_get_var(conn,  ESPER_MOD_HTTP_PARAM_OFFSET, str, sizeof(str)) > 0) {
		// Check first to see if the module is an integer
		offset = strtol(str, &endptr, 0);

		// If it is not, attempt to find it based on the string passed in
		if(*endptr != 0) {
			offset = 0;
		}
	}

	return offset;
}

static uint32_t get_num_elements(struct mg_connection* conn, const tESPERVarInfo* info) {
	uint32_t num_elements;
	char str[ESPER_KEY_LEN];
	char* endptr;

	num_elements = 0;

	if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_NUM_ELEMENTS, str, sizeof(str)) > 0) {
		// Check first to see if the module is an integer
		num_elements = strtol(str, &endptr, 0);

		// If it is found, just default to gtting one element
		if(*endptr != 0) {
			num_elements = 0;
		}
	}

	if(info && !num_elements) {
		num_elements = 1;
	}

	return num_elements;
}

static ESPER_WRITECOUNT get_write_count(struct mg_connection* conn) {
	ESPER_WRITECOUNT write_count;
	char str[ESPER_KEY_LEN];
	char* endptr;

	// Fail by putting mod_id to ESPER_BAD_MODULE_ID but leave the error as "OK",
	write_count = 0;

	if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_WRITECOUNT, str, sizeof(str)) > 0) {
		// Check first to see if the module is an integer
		write_count = strtol(str, &endptr, 0);

		// If it is not, attempt to find it based on the string passed in
		if(*endptr != 0) {
			write_count = 0;
		}
	}

	return write_count;
}


static ESPER_TIMESTAMP get_timestamp(struct mg_connection* conn) {
	ESPER_TIMESTAMP ts;
	char str[ESPER_KEY_LEN];
	char* endptr;

	// Fail by putting mod_id to ESPER_BAD_MODULE_ID but leave the error as "OK",
	ts = 0;

	if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_TIMESTAMP, str, sizeof(str)) > 0) {
		// Check first to see if the module is an integer
		ts = strtol(str, &endptr, 0);

		// If it is not, attempt to find it based on the string passed in
		if(*endptr != 0) {
			ts = 0;
		}
	}

	return ts;
}

static tESPERMID get_module_id(struct mg_connection* conn) {
	tESPERMID mid;
	char strMID[ESPER_KEY_LEN];
	char* endptr;

	// Fail by putting mod_id to ESPER_BAD_MODULE_ID but leave the error as "OK",
	mid = ESPER_INVALID_MID;

	if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_MID, strMID, sizeof(strMID)) > 0) {
		// Check first to see if the module is an integer
		mid = strtol(strMID, &endptr, 0);

		// If it is not, attempt to find it based on the string passed in
		if(*endptr != 0) {
			mid = ESPER_GetModuleIdByKey(strMID);
		}
	}

	return mid;
}

static tESPERVID get_var_id(struct mg_connection* conn, tESPERMID mid) {
	tESPERVID vid;
	char strVID[ESPER_KEY_LEN];
	char* endptr;

	vid = ESPER_INVALID_VID;

	if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_VID, strVID, sizeof(strVID)) > 0) {
		// Check first to see if the module is an integer
		vid = strtol(strVID, &endptr, 0);

		// If it is not, attempt to find it based on the string passed in
		if(*endptr != 0) {
			vid = ESPER_GetVarIdByKey(mid, strVID);
		}
	}

	return vid;
}

static tESPERAID get_attr_id(struct mg_connection* conn, tESPERMID mid, tESPERVID vid) {
	tESPERAID aid;
	tESPERAID idx;
	char strNum[ESPER_KEY_LEN];
	char strIdx[ESPER_KEY_LEN];
	char* endptr;

	aid = ESPER_INVALID_AID;

	if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_AID, strNum, sizeof(strNum)) > 0) {
		// Check first to see if the module is an integer
		aid = strtol(strNum, &endptr, 0);

		// If it is not, attempt to find it based on the string passed in
		if(*endptr != 0) {
			// if it's a string, we need the KEY idx as well, as attributes can have duplicate keys!
			idx = 0;
			if(mg_get_var(conn, ESPER_MOD_HTTP_PARAM_AID_IDX, strIdx, sizeof(strIdx)) > 0) {
				// Check first to see if the module is an integer
				idx = strtol(strIdx, &endptr, 0);
				if(*endptr != 0) {
					idx = 0;
				}
			} 
			aid = ESPER_GetAttrIdByKey(mid, vid, strNum, idx);
		}
	}

	return aid;
}

static char is_attr_set(struct mg_connection* conn, char* attr) {
	char strAttr[32];
	int result;

	result = mg_get_var(conn, attr, strAttr, sizeof(strAttr));

	if((result == 0) || (result > 0)) {
		return 1;
	} 
	
		return 0;
}

static int json_error_msg(struct mg_connection* conn, eESPERResponse resp, const char* msg) {
	uint16_t status_code;
	
	status_code = get_http_code_based_on_response(resp);
	mg_send_status(conn, status_code);
	mg_send_header(conn, "Access-Control-Allow-Origin","*");
	if(get_jsonp_callback(conn)) {
		mg_send_header(conn, "Content-Type", "application/javascript");
		mg_printf_data(conn, "%s(", get_jsonp_callback(conn));
	} else {
		mg_send_header(conn, "Content-Type", "application/json");
	}

	mg_printf_data(conn, "{\"error\":{\"status\":%u,\"code\":%u,\"meaning\":\"%s\",\"message\":\"%s\"}}", status_code, resp, ESPER_GetResponseString(resp), msg);
	if(get_jsonp_callback(conn)) {
		mg_printf_data(conn, ");");
	}

	return MG_TRUE;
}

static int binary_error_msg(struct mg_connection* conn, eESPERResponse resp) {
	uint32_t data;

	mg_send_status(conn, get_http_code_based_on_response(resp));
	mg_send_header(conn, "Access-Control-Allow-Origin","*");
	mg_send_header(conn, "Content-Type", "application/octet-stream");
	data = MSG_SYM_ERROR;
	mg_send_data(conn, &data, 1);
	data = resp;
	mg_send_data(conn, &data, 4);

	return MG_TRUE;
}

static int esper_read_node(struct mg_connection* conn) {
	ESPER_TIMESTAMP ts;
	ESPER_WRITECOUNT wc;

	ts = get_timestamp(conn);
	wc = get_write_count(conn);

	// force refresh of node, causing variables to update timestamps/writecounts if they have changed
	if((ts !=0) || (wc != 0)) {
		ESPER_RefreshNode();
	}

	if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_USE_BINARY)) {
		return binary_read_node(conn, ts, wc);
	} else {
		return json_read_node(conn, ts, wc);
	}

	return MG_TRUE;
}

static int binary_read_node(struct mg_connection* conn, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc) {
	tESPERNodeInfo node_info;
	tESPERModuleInfo module_info;
	uint32_t data;
	tESPERMID n;
	eESPERResponse resp;

	if(ESPER_GetNodeInfo(&node_info, &resp)) {
		mg_send_status(conn, 200);
		mg_send_header(conn, "Access-Control-Allow-Origin","*");
		mg_send_header(conn, "Content-Type", "application/octet-stream");

		// Optionally include modules
		if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_MODULES)) {
			for(n=0; n<node_info.num_modules; n++) {
				if(ESPER_GetModuleInfo(n, &module_info, 0)) {
					binary_frag_mod_read(conn, n, &module_info, ts, wc, is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_DATA));
				}
			}
		}

		// Regrab the node info, the timestamp and/or writecount may have updated 
		ESPER_GetNodeInfo(&node_info, 0);

		if((ts != 0) || (wc != 0)) {
			data = MSG_SYM_NODE_UPDATE;
			mg_send_data(conn, &data, 1);
		} else {
			data = MSG_SYM_NODE_INFO;
			mg_send_data(conn, &data, 1);
			data = node_info.num_modules;
			mg_send_data(conn, &data, 4);
			data = node_info.num_vars;
			mg_send_data(conn, &data, 4);
			data = node_info.num_attrs;
			mg_send_data(conn, &data, 4);
		}

			data = node_info.last_modified;
			mg_send_data(conn, &data, 4);
			data = node_info.write_count;
			mg_send_data(conn, &data, 4);

	} else {
		binary_error_msg(conn, resp);
	}
	return MG_TRUE;
}

static int json_read_node(struct mg_connection* conn, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc) {
	tESPERNodeInfo node_info;
	tESPERModuleInfo module_info;
	uint8_t mod_printed;
	uint32_t n;
	eESPERResponse resp;

	if(ESPER_GetNodeInfo(&node_info, &resp)) {
		mg_send_status(conn, 200);
		mg_send_header(conn, "Access-Control-Allow-Origin","*");
		if(get_jsonp_callback(conn)) {
			mg_send_header(conn, "Content-Type", "application/javascript");
			mg_printf_data(conn, "%s(", get_jsonp_callback(conn));
		} else {
			mg_send_header(conn, "Content-Type", "application/json");
		}

		mg_printf_data(conn, "{");

		mg_printf_data(conn, "\"module\":[");
		if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_MODULES)) {
			mod_printed = 0;
			for(n=0; n<node_info.num_modules; n++) {
				if(ESPER_GetModuleInfo(n, &module_info, 0)) {
					if(json_frag_mod_read(conn, n, &module_info, ts, wc, mod_printed, is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_DATA))) {
					mod_printed = 1;
				}
			}
		}
			// close off module: {}
		}
		mg_printf_data(conn, "],"); 
	
	
		// Regrab the node info, the timestamp and/or writecount may have updated 
		ESPER_GetNodeInfo(&node_info, 0);

		if((ts == 0) && (wc == 0)) {
			mg_printf_data(conn, "\"num_mod\":%u,\"num_var\":%u,\"num_attr\":%u,",
				node_info.num_modules,
				node_info.num_vars,
				node_info.num_attrs);
		}

		mg_printf_data(conn, "\"%s\":%u,\"%s\":%u}",
			ESPER_MOD_HTTP_PARAM_TIMESTAMP,
			node_info.last_modified,
			ESPER_MOD_HTTP_PARAM_WRITECOUNT,
			node_info.write_count);

		if(get_jsonp_callback(conn)) {
			mg_printf_data(conn, ");");
		}
	} else {
		json_error_msg(conn, resp, "");
	}

	return MG_TRUE;
}

static int esper_read_module(struct mg_connection* conn) {
	ESPER_TIMESTAMP ts;
	ESPER_WRITECOUNT wc;
	tESPERMID mid;
	
	ts = get_timestamp(conn);
	wc = get_write_count(conn);
	
	// Refresh the module if an update is being requested, otherwise we will return everything, so skip refresh
	mid = get_module_id(conn);
	if((ts != 0) || (wc !=0)) {
		ESPER_RefreshModule(mid);		
	}

	if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_USE_BINARY)) {
		return binary_read_module(conn, mid, ts, wc);
	} else {
		return json_read_module(conn, mid, ts, wc);
	}
}

static int binary_read_module(struct mg_connection* conn, tESPERMID mid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc) {
	tESPERModuleInfo module_info;
	eESPERResponse resp;

	if(ESPER_GetModuleInfo(mid, &module_info, &resp)) {
		mg_send_status(conn, 200);
		mg_send_header(conn, "Access-Control-Allow-Origin","*");
		mg_send_header(conn, "Content-Type", "application/octet-stream");
		binary_frag_mod_read(conn, mid, &module_info, ts, wc, is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_DATA));
	} else {
		binary_error_msg(conn, resp);
	}
	return MG_TRUE;
}

static int json_read_module(struct mg_connection* conn, tESPERMID mid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc) {
	tESPERModuleInfo module_info;
	eESPERResponse resp;

	if(ESPER_GetModuleInfo(mid, &module_info, &resp)) {
	mg_send_status(conn, 200);
	mg_send_header(conn, "Access-Control-Allow-Origin","*");
		if(get_jsonp_callback(conn)) {
		mg_send_header(conn, "Content-Type", "application/javascript");
			mg_printf_data(conn, "%s(", get_jsonp_callback(conn));
	} else {
		mg_send_header(conn, "Content-Type", "application/json");
	}

		json_frag_mod_read(conn, mid, &module_info, ts, wc, 0, is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_DATA));

		if(get_jsonp_callback(conn)) {
			mg_printf_data(conn, ");");
		}
	} else {
		json_error_msg(conn, resp, "");
	}

	return MG_TRUE;
}

static int esper_read_var(struct mg_connection* conn) {
	ESPER_TIMESTAMP ts;
	ESPER_WRITECOUNT wc;
	tESPERMID mid;
	tESPERVID vid;

	ts = get_timestamp(conn);
	wc = get_write_count(conn);

	mid = get_module_id(conn);
	vid = get_var_id(conn, mid);

	if((ts != 0) || (wc != 0)) {
		ESPER_RefreshVar(mid, vid);
	}

	if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_USE_BINARY)) {
		return binary_read_var(conn, mid, vid, ts, wc);
	} else {
		return json_read_var(conn, mid, vid, ts, wc);
	}
}

static int binary_read_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc) {
	tESPERVarInfo info;
	uint32_t offset;
	uint32_t num_elements;
	eESPERResponse resp;

	if(ESPER_GetVarInfo(mid, vid, &info, &resp)) {
	offset = get_offset(conn);
		num_elements = get_num_elements(conn, &info);

		mg_send_status(conn, 200);
		mg_send_header(conn, "Access-Control-Allow-Origin","*");
		mg_send_header(conn, "Content-Type", "application/octet-stream");

		binary_frag_var_read(conn, mid, vid, &info, offset, num_elements, ts, wc, is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_DATA), is_attr_set(conn, ESPER_MOD_HTTP_PARAM_DATA_ONLY));
	} else {
		return binary_error_msg(conn, resp);
	}
	return MG_TRUE;
}

static int json_read_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc) {
	tESPERVarInfo info;
	eESPERResponse resp;
	uint32_t offset;
	uint32_t num_elements;

	if(ESPER_GetVarInfo(mid, vid, &info, &resp)) {
		offset = get_offset(conn);
		num_elements = get_num_elements(conn, &info);

	mg_send_status(conn, 200);
	mg_send_header(conn, "Access-Control-Allow-Origin","*");
		if(get_jsonp_callback(conn)) {
		mg_send_header(conn, "Content-Type", "application/javascript");
			mg_printf_data(conn, "%s(", get_jsonp_callback(conn));
	} else {
		mg_send_header(conn, "Content-Type", "application/json");
	}

		json_frag_var_read(conn, mid, vid, &info, offset, num_elements, ts, wc, 0, is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_DATA), is_attr_set(conn, ESPER_MOD_HTTP_PARAM_DATA_ONLY));

		if(get_jsonp_callback(conn)) {
			mg_printf_data(conn, ");");
	}
	} else {
		json_error_msg(conn, resp, "");
	}

	return MG_TRUE;
}

static int esper_read_attr(struct mg_connection* conn) {
	tESPERMID mid;
	tESPERVID vid;
	tESPERAID aid;

	mid = get_module_id(conn);
	vid = get_var_id(conn, mid);
	aid = get_attr_id(conn, mid, vid);

	if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_USE_BINARY)) {
		return binary_read_attr(conn, mid, vid, aid);
	} else {
		return json_read_attr(conn, mid, vid, aid);
	}
}

static int binary_read_attr(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid) {
	tESPERAttrInfo info;
	eESPERResponse resp;

	if(ESPER_GetAttrInfo(mid, vid, aid, &info, &resp)) {
		mg_send_status(conn, 200);
		mg_send_header(conn, "Access-Control-Allow-Origin","*");
		mg_send_header(conn, "Content-Type", "application/octet-stream");
		binary_frag_attr_read(conn, mid, vid, aid, &info);
	} else {
		return binary_error_msg(conn, resp);
	}

	return MG_TRUE;
}

static int json_read_attr(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid) {
	tESPERAttrInfo info;
	eESPERResponse resp;

	if(ESPER_GetAttrInfo(mid, vid, aid, &info, &resp)) {
	mg_send_status(conn, 200);
	mg_send_header(conn, "Access-Control-Allow-Origin","*");
		if(get_jsonp_callback(conn)) {
		mg_send_header(conn, "Content-Type", "application/javascript");
			mg_printf_data(conn, "%s(", get_jsonp_callback(conn));
	} else {
		mg_send_header(conn, "Content-Type", "application/json");
	}

		json_frag_attr_read(conn, mid, vid, aid, &info, 0);

		if(get_jsonp_callback(conn)) {
			mg_printf_data(conn, ");");
	}

	} else {
		return json_error_msg(conn, resp, "");
	}

	return MG_TRUE;
}

static void binary_frag_mod_read(struct mg_connection* conn, tESPERMID mid, tESPERModuleInfo* info, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t includeData) {
	tESPERVarInfo var_info;
	eESPERResponse resp;
	uint32_t n;
	uint32_t data;
	uint8_t var_include_data;

	if(
		((ts==0) && (wc == 0)) || 
		(ts < info->last_modified) ||
		((wc < info->write_count) && (ts == info->last_modified))
	) {
		if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_VARIABLES)) {
			for(n=0; n<info->num_vars; n++) {
				if(ESPER_GetVarInfo(mid, n, &var_info, 0)) {
					// skip hidden vars if not requested to show
					if(!is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_HIDDEN) && ((var_info.options & ESPER_OPTION_HIDDEN))) continue;
					// don't send out data for raw variables unless they are requested directly via read_var
					var_include_data = (var_info.type == ESPER_TYPE_RAW) ? 0 : includeData;
					binary_frag_var_read(conn, mid, n, &var_info, 0, var_info.num_elements, ts, wc, var_include_data, 0);
				}
			}
		}

		// Reload info to catch any updated timestamp or writecount info
		ESPER_GetModuleInfo(mid, info, 0);
		
		if((ts != 0) || (wc != 0)) {
			data = MSG_SYM_MODULE_UPDATE;
			mg_send_data(conn, &data, 1);
		} else {
			data = MSG_SYM_MODULE_INFO;
			mg_send_data(conn, &data, 1);
			data = strlen(info->key);
			mg_send_data(conn, &data, 1); // we know the KEY can't be more than 255 characters...
			if(data) mg_send_data(conn, info->key, strlen(info->key));
			data = strlen(info->name);
			mg_send_data(conn, &data, 1); // we know the KEY can't be more than 255 characters...
			if(data) mg_send_data(conn, info->name, strlen(info->name));
			data = info->group_id;
			mg_send_data(conn, &data, 4);
			data = info->num_vars;
			mg_send_data(conn, &data, 4);
		}
		data = mid;
		mg_send_data(conn, &data, 4);
			data = info->last_modified;
			mg_send_data(conn, &data, 4);
			data = info->write_count;
			mg_send_data(conn, &data, 4);
		}
}


static int json_frag_mod_read(struct mg_connection* conn, tESPERMID mid, tESPERModuleInfo* info, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t was_printed, uint8_t includeData) {
	tESPERVarInfo var_info;
	uint32_t n;
	uint8_t var_printed;
	uint8_t var_include_data;

	if(
		((ts==0) && (wc == 0)) || 
		(ts < info->last_modified) ||
		((wc < info->write_count) && (ts == info->last_modified))
	) {		

		if(was_printed) { mg_printf_data(conn, ","); }
		mg_printf_data(conn, "{");

		mg_printf_data(conn, "\"var\":[");
		if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_VARIABLES)) {
			var_printed = 0;
			for(n=0; n<info->num_vars; n++) {
				if(ESPER_GetVarInfo(mid, n, &var_info, 0)) {
					// skip hidden vars if not requested to show
					if(!is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_HIDDEN) && ((var_info.options & ESPER_OPTION_HIDDEN))) continue;
					// don't send out data for raw variables unless they are requested directly via read_var
					var_include_data = (var_info.type == ESPER_TYPE_RAW) ? 0 : includeData;

					if(json_frag_var_read(conn, mid, n, &var_info, 0, var_info.num_elements, ts, wc, var_printed, var_include_data, 0)) {
					var_printed = 1;
				}
			}
		}
		}
		mg_printf_data(conn, "],");


		if((wc == 0) & (ts == 0)) {
			mg_printf_data(conn, "\"key\":\"%s\",\"name\":\"%s\",\"gid\":%u,\"num_vars\":%u,",
				info->key,
				info->name,
				info->group_id,
				info->num_vars);
	}

		mg_printf_data(conn, "\"id\":%u,\"ts\":%u,\"wc\":%u}",
				mid,
				info->last_modified,
				info->write_count);	

		return MG_TRUE;
}

	return MG_FALSE;
}

static void binary_frag_var_update(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info) {
	uint32_t data;

	ESPER_GetVarInfo(mid, vid, info, 0);

	data = MSG_SYM_VAR_UPDATE;
			mg_send_data(conn, &data, 1);
	data = mid;
	mg_send_data(conn, &data, 4);
	data = vid;
	mg_send_data(conn, &data, 4);
			data = info->last_modified;
			mg_send_data(conn, &data, 4);
			data = info->write_count;
			mg_send_data(conn, &data, 4);
	data = info->num_elements;
	mg_send_data(conn, &data, 4);
			data = info->status;
			mg_send_data(conn, &data, 1);
}

static void binary_frag_var_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t includeData, uint8_t dataOnly) {
	tESPERAttrInfo attr_info;
	uint32_t n;
	uint32_t data;

	if(
		((ts==0) && (wc == 0)) || 
		(ts < info->last_modified) ||
		((wc < info->write_count) && (ts == info->last_modified))
	) {		

		// if data only is set, skip everything and just send the data 
		
		if((ts != 0) || (wc != 0) || (dataOnly)) {
			if(includeData || dataOnly) {
				binary_frag_var_data(conn, mid, vid, info, offset, num_elements, dataOnly);
			} else {
				binary_frag_var_update(conn, mid, vid, info);
			} 
		} else {
			if(includeData) {
				binary_frag_var_data(conn, mid, vid, info, offset, num_elements, 0);
			}	
			data = MSG_SYM_VAR_INFO;
			mg_send_data(conn, &data, 1);
			data = mid;
			mg_send_data(conn, &data, 4);
			data = vid;
			mg_send_data(conn, &data, 4);
			data = strlen(info->key);
			mg_send_data(conn, &data, 1); // we know the KEY can't be more than 16/32 characters...
			if(data) mg_send_data(conn, info->key, strlen(info->key));
			data = info->options;
			mg_send_data(conn, &data, 1);
			data = info->type;
			mg_send_data(conn, &data, 1);
			data = info->num_elements;
			mg_send_data(conn, &data, 4);
			data = info->max_elements_per_request;
			mg_send_data(conn, &data, 4);
			data = info->last_modified;
			mg_send_data(conn, &data, 4);
			data = info->write_count;
			mg_send_data(conn, &data, 4);
			data = info->status;
			mg_send_data(conn, &data, 1);

			if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_ATTRIBUTES)) {
			for(n=0; n<info->num_attrs; n++) {
					if(ESPER_GetAttrInfo(mid, vid, n, &attr_info, 0)) {
						binary_frag_attr_read(conn, mid, vid, n, &attr_info);
				}
			}
		}
		}
	}
}

static int json_frag_var_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements, ESPER_TIMESTAMP ts, ESPER_WRITECOUNT wc, uint8_t was_printed, uint8_t includeData, uint8_t dataOnly) {
	tESPERAttrInfo attr_info;
	uint32_t n;
	uint8_t printed;

	if(
		((ts==0) && (wc == 0)) || 
		(ts < info->last_modified) ||
		((wc < info->write_count) && (ts == info->last_modified))
	) {		

		if(was_printed) { mg_printf_data(conn, ","); }
		if(!dataOnly) mg_printf_data(conn, "{");

		// if data only is set, skip everything and just send the data 
		if(!dataOnly) mg_printf_data(conn, "\"d\":");
		if(includeData || dataOnly) {
			json_frag_var_data(conn, mid, vid, info, offset, num_elements);
		} else {
			mg_printf_data(conn, "null");
		}
		if(!dataOnly) mg_printf_data(conn, ",");
		
		if(!dataOnly) {
			if((ts == 0) || (wc == 0)) {

				mg_printf_data(conn, "\"attr\":[");
				if(is_attr_set(conn, ESPER_MOD_HTTP_PARAM_INCLUDE_ATTRIBUTES)) {
					printed = 0;
			for(n=0; n<info->num_attrs; n++) {
						if(ESPER_GetAttrInfo(mid, vid, n, &attr_info, 0)) {
							if(json_frag_attr_read(conn, mid, vid, n, &attr_info, printed)) {
								printed = 1;
				}
				}
			}
		}
				mg_printf_data(conn, "],");

				mg_printf_data(conn, "\"key\":\"%s\",\"opt\":%u,\"type\":%u,\"max_req_size\":%u,",
					info->key,
					info->options,
					info->type,
					info->max_elements_per_request);
			} 

			mg_printf_data(conn, "\"id\":%u,\"mid\":%u,\"ts\":%u,\"wc\":%u,\"len\":%u,\"stat\":%u}",
				vid,
				mid,
				info->last_modified,
				info->write_count,
				info->num_elements,
				info->status);
		}

		return MG_TRUE;
	}

	return MG_FALSE;
}

static void binary_frag_attr_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info) {
	uint32_t data;

	data = MSG_SYM_ATTR_INFO;
	mg_send_data(conn, &data, 1);
	data = mid;
	mg_send_data(conn, &data, 4);
	data = vid;
	mg_send_data(conn, &data, 4);
	data = aid;
	mg_send_data(conn, &data, 4);
	data = strlen(info->key);
	mg_send_data(conn, &data, 1); // we know the KEY can't be more than 255 characters...
	if(data) mg_send_data(conn, info->key, strlen(info->key));
	data = strlen(info->name);
	mg_send_data(conn, &data, 1); // we know the NAME can't be more than 255 characters...
	if(data) mg_send_data(conn, info->name, data);
	data = info->type;
	mg_send_data(conn, &data, 1);

	binary_frag_attr_data(conn, mid, vid, aid, info);
}

static int json_frag_attr_read(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info, uint8_t was_printed) {

	if(was_printed) { mg_printf_data(conn, ","); }
	mg_printf_data(conn, "{");

	mg_printf_data(conn, "\"d\":");
	json_frag_attr_data(conn, mid, vid, aid, info);
	mg_printf_data(conn, ",");

	mg_printf_data(conn, "\"key\":\"%s\",\"mid\":%u,\"vid\":%u,\"id\":%u,\"name\":\"%s\",\"type\":%u}",
		info->key,
		mid,
		vid,
		aid,
		info->name,
		info->type);

	return MG_TRUE;
}

static void binary_frag_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements, uint8_t dataOnly) {
	const uint8_t* buffer;
	uint32_t buffer_len;
	uint32_t data;
	eESPERResponse resp;

	if(!info) {
		// @TODO: log critical respor 
		return;
	}

	// var contains no info, just return
	if(info->num_elements == 0) {
		return;
	}

	if(!num_elements) {
		// nothing to do, bail out 
		return;
	}

	// convert data into string
	switch(info->type) {
	case ESPER_TYPE_NULL:
		buffer = 0;
		resp = ESPER_RESP_OK;
		break;
	case ESPER_TYPE_RAW:
		buffer = (const uint8_t*)ESPER_ReadVarRawArray(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_UINT8:
		buffer = (const uint8_t*)ESPER_ReadVarUInt8Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_UINT16:
		buffer = (const uint8_t*)ESPER_ReadVarUInt16Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_UINT32:
		buffer = (const uint8_t*)ESPER_ReadVarUInt32Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_UINT64:
		buffer = (const uint8_t*)ESPER_ReadVarUInt64Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_SINT8:
		buffer = (const uint8_t*)ESPER_ReadVarSInt8Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_SINT16:
		buffer = (const uint8_t*)ESPER_ReadVarSInt16Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_SINT32:
		buffer = (const uint8_t*)ESPER_ReadVarSInt32Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_SINT64:
		buffer = (const uint8_t*)ESPER_ReadVarSInt64Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_FLOAT32:
		buffer = (const uint8_t*)ESPER_ReadVarFloat32Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_FLOAT64:
		buffer = (const uint8_t*)ESPER_ReadVarFloat64Array(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_ASCII:
		buffer = (const uint8_t*)ESPER_ReadVarASCIIArray(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	case ESPER_TYPE_BOOL:
		buffer = (const uint8_t*)ESPER_ReadVarBoolArray(mid, vid, offset, num_elements, &buffer_len, &resp);
		break;
	default:
		num_elements = 0;
		break;
	}

	if(resp == ESPER_RESP_OK) {
		if(!dataOnly) {
			// regrab info
			ESPER_GetVarInfo(mid, vid, info, 0);

			data = MSG_SYM_VAR_DATA;
			mg_send_data(conn, &data, 1);
			data = mid;
			mg_send_data(conn, &data, 4);
			data = vid;
			mg_send_data(conn, &data, 4);
			data = info->type;
			mg_send_data(conn, &data, 1);
			mg_send_data(conn, &offset, sizeof(offset));
			mg_send_data(conn, &num_elements, sizeof(num_elements) );
			data = info->last_modified;
			mg_send_data(conn, &data, 4);
			data = info->write_count;
			mg_send_data(conn, &data, 4);
			data = info->status;
			mg_send_data(conn, &data, 1);		
		}
		
		if((buffer_len > 0) && (buffer != 0)) {
			mg_send_data(conn, buffer, buffer_len);
		}
	}
}

static void json_frag_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements) {
	uint32_t n;
	uint32_t k;
	char c;

	if(!info) return;

	// convert data into string
	switch(info->type) {
	case ESPER_TYPE_NULL:
		mg_printf_data(conn, "null");	
		break;
	case ESPER_TYPE_RAW:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%x", ESPER_ReadVarUInt8(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_UINT8:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%u", ESPER_ReadVarUInt8(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_UINT16:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%u", ESPER_ReadVarUInt16(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_UINT32:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%u", ESPER_ReadVarUInt32(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_UINT64:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%lu", ESPER_ReadVarUInt64(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_SINT8:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%d", ESPER_ReadVarSInt8(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_SINT16:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%d", ESPER_ReadVarSInt16(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_SINT32:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%d", ESPER_ReadVarSInt32(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_SINT64:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%ld", ESPER_ReadVarSInt64(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_FLOAT32:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%f", ESPER_ReadVarFloat32(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_FLOAT64:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			mg_printf_data(conn, "%lf", ESPER_ReadVarFloat64(mid, vid, n, 0));
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	case ESPER_TYPE_ASCII:
		mg_printf_data(conn, "\"");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			c = ESPER_ReadVarASCII(mid, vid, n, 0);
			if(c == 0) break;
			mg_printf_data(conn, "%c", c);
		}
		mg_printf_data(conn, "\"");
		break;
	case ESPER_TYPE_BOOL:
		mg_printf_data(conn, "[");
		for(k=0, n=offset; (n<info->num_elements) && (k<num_elements); n++, k++) {
			if(ESPER_ReadVarBool(mid, vid, n, 0)) {
				mg_printf_data(conn, "true");
			} else {
				mg_printf_data(conn, "false");
			}
			if((n < (info->num_elements-1)) && (k< (num_elements-1))) { mg_printf_data(conn, ","); }
		}
		mg_printf_data(conn, "]");	
		break;
	default:
		break;
	}
}

// @TODO: Test
static void binary_frag_attr_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info) {
	uESPERData data;
	uint8_t num_elements;

	if(!info) {
		return;
	}

	data.u8 = MSG_SYM_ATTR_DATA;
	mg_send_data(conn, &data, 1);
	data.u32 = mid;
	mg_send_data(conn, &data, 4);
	data.u32 = vid;
	mg_send_data(conn, &data, 4);
	data.u32 = aid;
	mg_send_data(conn, &data, 4);
	data.u8 = info->type;
	mg_send_data(conn, &data, 1);

	// convert data into string
	switch(info->type) {
	case ESPER_TYPE_NULL:
		data.u8 = 0;
		break;
	case ESPER_TYPE_UINT8:
		data.u8 = ESPER_ReadAttrUInt8(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_UINT16:
		data.u16 = ESPER_ReadAttrUInt16(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_UINT32:
		data.u32 = ESPER_ReadAttrUInt32(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_UINT64:
		data.u64 = ESPER_ReadAttrUInt64(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_SINT8:
		data.s8 = ESPER_ReadAttrSInt8(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_SINT16:
		data.s16 = ESPER_ReadAttrSInt16(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_SINT32:
		data.s32 = ESPER_ReadAttrSInt32(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_SINT64:
		data.s64 = ESPER_ReadAttrSInt16(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_FLOAT32:
		data.f32 = ESPER_ReadAttrFloat32(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_FLOAT64:
		data.f64 = ESPER_ReadAttrFloat32(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	case ESPER_TYPE_ASCII:
		esper_strcpy(data.str, ESPER_ReadAttrASCII(mid, vid, aid, 0), ESPER_ATTR_LEN);
		num_elements = strlen(data.str);
		mg_send_data(conn, &num_elements, 1);
		if(num_elements) {
			mg_send_data(conn, data.str, num_elements);
		}
		break;
	case ESPER_TYPE_BOOL:
		data.b = ESPER_ReadAttrBool(mid, vid, aid, 0);
		mg_send_data(conn, &data, ESPER_GetTypeSize(info->type));
		break;
	default:
		data.u8 = 0;
		break;
	}

}

static void json_frag_attr_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info) {
	uint32_t n;
	char c;

	if(!info) return;

	// convert data into string
	switch(info->type) {
	case ESPER_TYPE_UINT8:
		mg_printf_data(conn, "%u", ESPER_ReadAttrUInt8(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_UINT16:
		mg_printf_data(conn, "%u", ESPER_ReadAttrUInt16(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_UINT32:
		mg_printf_data(conn, "%u", ESPER_ReadAttrUInt32(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_UINT64:
		mg_printf_data(conn, "%lu", ESPER_ReadAttrUInt64(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_SINT8:
		mg_printf_data(conn, "%d", ESPER_ReadAttrSInt8(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_SINT16:
		mg_printf_data(conn, "%d", ESPER_ReadAttrSInt16(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_SINT32:
		mg_printf_data(conn, "%d", ESPER_ReadAttrSInt32(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_SINT64:
		mg_printf_data(conn, "%ld", ESPER_ReadAttrSInt64(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_FLOAT32:
		mg_printf_data(conn, "%f", ESPER_ReadAttrFloat32(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_FLOAT64:
		mg_printf_data(conn, "%lf", ESPER_ReadAttrFloat64(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_ASCII:
		mg_printf_data(conn, "\"%s\"", ESPER_ReadAttrASCII(mid, vid, aid, 0));
		break;
	case ESPER_TYPE_BOOL:
		if(ESPER_ReadAttrBool(mid, vid, aid, 0)) {
				mg_printf_data(conn, "true");
			} else {
				mg_printf_data(conn, "false");
			}
		break;
	case ESPER_TYPE_NULL:
	default:
		mg_printf_data(conn, "null");
		break;
	}
}

static int esper_write_var(struct mg_connection* conn) {
	tESPERMID mid;
	tESPERVID vid;
	uint32_t offset;
	uint32_t num_elements;
	tESPERVarInfo info;

	mid = get_module_id(conn);
	vid = get_var_id(conn, mid);
	offset = get_offset(conn);
	
	num_elements = get_num_elements(conn, ESPER_GetVarInfo(mid, vid, &info, 0)); 
	
	if(is_attr_set(conn, "binary")) {
		return binary_write_var(conn, mid, vid, offset, num_elements);
	} else {
		return json_write_var(conn, mid, vid, offset, num_elements);
	}
}

static int binary_write_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements) {
	tESPERVarInfo var_info;
	eESPERResponse resp;

	if(ESPER_GetVarInfo(mid, vid, &var_info, &resp)) {
		resp = binary_frag_write_var_data(conn, mid, vid, &var_info, offset, num_elements);
		if(resp == ESPER_RESP_OK) {
		mg_send_status(conn, 200);
		mg_send_header(conn, "Access-Control-Allow-Origin","*");
		mg_send_header(conn, "Content-Type", "application/octet-stream");

		 	binary_frag_var_update(conn, mid, vid, &var_info);
	} else {
			return binary_error_msg(conn, resp);	
		}
	} else {
		return binary_error_msg(conn, resp);
	}

	return MG_TRUE;
}

static int json_write_var(struct mg_connection* conn, tESPERMID mid, tESPERVID vid,uint32_t offset, uint32_t num_elements) {
	tESPERVarInfo info;
	eESPERResponse resp;

	if(ESPER_GetVarInfo(mid, vid, &info, &resp)) {
		resp = json_frag_write_var_data(conn, mid, vid, &info, offset, num_elements);
		if(resp == ESPER_RESP_OK) {
	mg_send_status(conn, 200);
	mg_send_header(conn, "Access-Control-Allow-Origin","*");
			if(get_jsonp_callback(conn)) {
		mg_send_header(conn, "Content-Type", "application/javascript");
				mg_printf_data(conn, "%s(", get_jsonp_callback(conn));
	} else {
		mg_send_header(conn, "Content-Type", "application/json");
	}

			ESPER_GetVarInfo(mid, vid, &info, 0);
			mg_printf_data(conn, "{\"mid\":%u,\"id\":%u,\"ts\":%u,\"wc\":%u,\"len\":%u,\"stat\":%u}",
				mid,
				vid,
				info.last_modified,
				info.write_count,
				info.num_elements,
				info.status);

			if(get_jsonp_callback(conn)) {
		mg_printf_data(conn, ");");
	}
		} else {
			return json_error_msg(conn, resp, "");
}
	} else {
		return json_error_msg(conn, resp, "");
}

	return MG_TRUE;
	}

static eESPERResponse write_json_token_to_data(const char* json_buffer, jsmntok_t* json_token, ESPER_TYPE type, tESPERMID mid, tESPERVID vid, uint32_t offset) {
	char* endptr;
	char str_data[32];
	eESPERResponse resp;
	uESPERData data;
	uint32_t str_to_test_len;	
	
	str_to_test_len = (json_token->end - json_token->start)+1;
	if(str_to_test_len > sizeof(str_data)) str_to_test_len = sizeof(str_data);
	esper_strcpy(str_data, json_buffer + json_token->start, str_to_test_len);
	
	switch(type) {
	case ESPER_TYPE_NULL:		return ESPER_RESP_OK;
	case ESPER_TYPE_RAW:		return ESPER_RESP_ERROR; // ESPER_WriteVarRaw(mid, vid, offset, strtoul(json_buffer + json_token->start, 0, 0));
	case ESPER_TYPE_UINT8:
		data.u8 = strtoul(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarUInt8(mid, vid, offset, data.u8); }
		break;
	case ESPER_TYPE_UINT16:
		data.u16 = strtoul(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarUInt16(mid, vid, offset, data.u16); }
		break;
	case ESPER_TYPE_UINT32:
		data.u32 = strtoul(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarUInt32(mid, vid, offset, data.u32); }
		break;
	case ESPER_TYPE_UINT64:
		data.u64 = strtoul(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarUInt32(mid, vid, offset, data.u64); }
		break;
	case ESPER_TYPE_SINT8:
		data.s8 = strtol(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarSInt8(mid, vid, offset, data.s8); }
		break;
	case ESPER_TYPE_SINT16:
		data.s16 = strtol(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarSInt16(mid, vid, offset, data.s16); }
		break;
	case ESPER_TYPE_SINT32:
		data.s32 = strtol(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarSInt16(mid, vid, offset, data.s32); }
		break;
	case ESPER_TYPE_SINT64:
		data.s64 = strtoll(str_data, &endptr, 0);
		if(*endptr == 0) {	return ESPER_WriteVarSInt16(mid, vid, offset, data.s64); }
		break;
	case ESPER_TYPE_FLOAT32:
		data.f32 = strtof(str_data, &endptr);
		if(*endptr == 0) {	return ESPER_WriteVarFloat32(mid, vid, offset, data.f32); }
		break;
	case ESPER_TYPE_FLOAT64:
		data.f64 = strtod(str_data, &endptr);
		if(*endptr == 0) {	return ESPER_WriteVarFloat64(mid, vid, offset, data.f64); }
		break;
	case ESPER_TYPE_ASCII:
		return ESPER_RESP_BAD_DATA_FORMAT; // handled by not passing a string inside an array!
	case ESPER_TYPE_BOOL:
		if(strcmp(str_data, "true") == 0) {
			return ESPER_WriteVarBool(mid, vid, offset, 1);
		} else if(strcmp(str_data, "false") == 0) {
			return ESPER_WriteVarBool(mid, vid, offset, 0);
		}
		break;
	default:
		break;
	}

	return ESPER_RESP_BAD_DATA_FORMAT;
	}

static eESPERResponse json_frag_write_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements) {
	int json_resp;
	int n;
	tESPERModuleHTTP* ctx;
	uESPERData data;
	uint32_t buff_len;
	eESPERResponse resp;

	ctx = (tESPERModuleHTTP*)conn->server_param;

	jsmn_init(&ctx->json_parser);

	json_resp = jsmn_parse(&ctx->json_parser, (uint8_t*)conn->content, conn->content_len, ctx->json_tokens, sizeof(ctx->json_tokens)/sizeof(ctx->json_tokens[0]));
	if(json_resp < 0) {
		// parse failure
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Malformed JSON Write Attempt");
		return ESPER_RESP_BAD_DATA_FORMAT;
}

	if((json_resp == 1) && (((ctx->json_tokens[0].type == JSMN_PRIMITIVE)) || ((info->type == ESPER_TYPE_ASCII) && (ctx->json_tokens[0].type == JSMN_STRING)) )) {
		// either string or single value 
		if(info->type == ESPER_TYPE_ASCII) {
			// attempt to write string into var
			//mid, vid, offset, &num_elements, (char*)buffer, &buffer_len); 
			buff_len = ctx->json_tokens[0].size;
			num_elements = ctx->json_tokens[0].size;
			return ESPER_WriteVarASCIIArray(mid, vid, offset, num_elements, (uint8_t*)(conn->content + ctx->json_tokens[0].start), &buff_len);
		} else {
			// attempt to parse JSON token into value 
			return write_json_token_to_data(conn->content, &ctx->json_tokens[0], info->type, mid, vid, offset);
		}
	} else if((json_resp > 1) && (ctx->json_tokens[0].type == JSMN_ARRAY)) {
		for(n=1; n<json_resp; n++) {
			if(ctx->json_tokens[n].type != JSMN_PRIMITIVE) {
				ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "JSON Write array contains non-primitives!");
				return ESPER_RESP_BAD_DATA_FORMAT;
	}

			resp = write_json_token_to_data(conn->content, &ctx->json_tokens[n], info->type, mid, vid, offset+(n-1));
			if(resp != ESPER_RESP_OK) {
				ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Error transforming JSON to primitive");
				return resp;
		}
	}

		return ESPER_RESP_OK;
	}

	return ESPER_RESP_BAD_DATA_FORMAT;
	}

static eESPERResponse binary_frag_write_var_data(struct mg_connection* conn, tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, uint32_t offset, uint32_t num_elements) {
	uint32_t buffer_len;
	uint8_t* buffer;
	uint32_t data;
	eESPERResponse resp;

	if(!info) return ESPER_RESP_ERROR;

	buffer = (uint8_t*)conn->content;
	buffer_len = conn->content_len;

	switch(info->type) {
	case ESPER_TYPE_NULL:
		resp = ESPER_WriteVarNullArray(mid, vid, offset, num_elements);
		break;
	case ESPER_TYPE_RAW:
		resp = ESPER_WriteVarRawArray(mid, vid, offset, num_elements, buffer, &buffer_len);
		break;
	case ESPER_TYPE_UINT8:
		resp = ESPER_WriteVarUInt8Array(mid, vid, offset, num_elements, buffer, &buffer_len);
		break;
	case ESPER_TYPE_UINT16:
		resp = ESPER_WriteVarUInt16Array(mid, vid, offset, num_elements, (uint16_t*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_UINT32:
		resp = ESPER_WriteVarUInt32Array(mid, vid, offset, num_elements, (uint32_t*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_UINT64:
		resp = ESPER_WriteVarUInt64Array(mid, vid, offset, num_elements, (uint64_t*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_SINT8:
		resp = ESPER_WriteVarSInt8Array(mid, vid, offset, num_elements, (int8_t*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_SINT16:
		resp = ESPER_WriteVarSInt16Array(mid, vid, offset, num_elements, (int16_t*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_SINT32:
		resp = ESPER_WriteVarSInt32Array(mid, vid, offset, num_elements, (int32_t*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_SINT64:
		resp = ESPER_WriteVarSInt64Array(mid, vid, offset, num_elements, (int64_t*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_FLOAT32:
		resp = ESPER_WriteVarFloat32Array(mid, vid, offset, num_elements, (float*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_FLOAT64:
		resp = ESPER_WriteVarFloat64Array(mid, vid, offset, num_elements, (double*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_ASCII:
		resp = ESPER_WriteVarASCIIArray(mid, vid, offset, num_elements, (char*)buffer, &buffer_len);
		break;
	case ESPER_TYPE_BOOL:
		resp = ESPER_WriteVarBoolArray(mid, vid, offset, num_elements, (uint8_t*)buffer, &buffer_len);
		break;
	default:
		buffer_len = 0;
		resp = ESPER_RESP_UNKNOWN_TYPE;
		break;
}

	return resp;
}

