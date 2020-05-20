/*
 * http.h
 *
 *  Created on: Nov 23, 2016
 *      Author: bryerton
 */

#ifndef CLIENT_HTTP_H_
#define CLIENT_HTTP_H_

#include <esper.h>
#include <mongoose/mongoose.h>
#include <json/jsmn.h>

#define MAX_JSON_TOKENS			128

#define MSG_SYM_DONE			0x00
#define MSG_SYM_NODE_UPDATE 	0x01
#define MSG_SYM_NODE_INFO		0x02
#define MSG_SYM_MODULE_UPDATE 	0x03
#define MSG_SYM_MODULE_INFO		0x04
#define MSG_SYM_VAR_UPDATE 		0x05
#define MSG_SYM_VAR_INFO		0x06
#define MSG_SYM_ATTR_INFO		0x07
#define MSG_SYM_VAR_DATA		0x08
#define MSG_SYM_ATTR_DATA		0x09
#define MSG_SYM_ERROR			0xFF

#define ESPER_MOD_HTTP_PARAM_CALLBACK "cb"
#define ESPER_MOD_HTTP_PARAM_TIMESTAMP "ts"
#define ESPER_MOD_HTTP_PARAM_WRITECOUNT "wc"
#define ESPER_MOD_HTTP_PARAM_MID "mid"
#define ESPER_MOD_HTTP_PARAM_VID "vid"
#define ESPER_MOD_HTTP_PARAM_AID "aid"
#define ESPER_MOD_HTTP_PARAM_AID_IDX "aidIdx"
#define ESPER_MOD_HTTP_PARAM_INCLUDE_VARIABLES "includeVars"
#define ESPER_MOD_HTTP_PARAM_INCLUDE_MODULES "includeMods"
#define ESPER_MOD_HTTP_PARAM_INCLUDE_ATTRIBUTES "includeAttrs"
#define ESPER_MOD_HTTP_PARAM_NUM_ELEMENTS "len"
#define ESPER_MOD_HTTP_PARAM_OFFSET	"offset"
#define ESPER_MOD_HTTP_PARAM_USE_BINARY "binary"
#define ESPER_MOD_HTTP_PARAM_INCLUDE_HIDDEN "hidden"
#define ESPER_MOD_HTTP_PARAM_INCLUDE_DATA "includeData"
#define ESPER_MOD_HTTP_PARAM_DATA_ONLY "dataOnly"

#define ESPER_MOD_HTTP_NAME_LEN 32
#define ESPER_MOD_HTTP_WEBROOT_LEN 512

typedef struct {
	jsmn_parser json_parser;
	jsmntok_t json_tokens[MAX_JSON_TOKENS];
	uint32_t max_json_tokens;
	struct mg_server *http_ctx;
	uint16_t port;
	char name[ESPER_MOD_HTTP_NAME_LEN];
	char webroot_dir[ESPER_MOD_HTTP_WEBROOT_LEN];
} tESPERModuleHTTP;

eESPERResponse ModuleHTTPHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx);
tESPERModuleHTTP* ModuleHTTPInit(const char* name, const char* webroot, uint16_t port, tESPERModuleHTTP* ctx);

#endif /* CLIENT_HTTP_H_ */
