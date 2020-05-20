
#pragma GCC push_options
#pragma GCC optimize ("O0")

/*

* esper_internal.c
 *
 *  Created on: Dec 15, 2016
 *      Author: bryerton
 */

#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <esper.h>

static uint32_t g_esper_version = ESPER_VERSION;

static tESPERModuleSystem* SystemModuleInit(const char* name, tESPERModuleSystem* ctx);
static eESPERResponse SystemModuleHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx);

static tESPERNodeInfo g_node_info;
static tESPERAttr*	g_attrs;
static tESPERModule* g_modules;
static tESPERVar*	g_vars;
static uint32_t g_write_count;
static tESPERStorage* g_storage;

static tESPERStorage _defaultStorage;
static tESPERModuleSystem g_mod_sys_ctx;

static tESPERVID CreateVar(tESPERMID mid, const char* key, ESPER_TYPE type, ESPER_OPTIONS options,uint32_t num_elements, VarHandler fnVarHandler, void* data, volatile void* io);
static eESPERResponse WriteVar(tESPERMID mid, tESPERVID vid, ESPER_TYPE type, uint32_t offset, const uint32_t num_elements, const void* buff, uint32_t* buff_len);
static const void* ReadVar(tESPERMID mid, tESPERVID vid, ESPER_TYPE type, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);

static tESPERAID CreateAttr(tESPERMID mid, tESPERVID vid, const char* key, const char* name, ESPER_TYPE type, const void* data);
static void* ReadAttr(tESPERMID mid, tESPERVID vid, tESPERAID aid, ESPER_TYPE type, eESPERResponse* resp);
static tESPERModule* GetModuleById(tESPERMID mid);
static tESPERVar* GetVarById(tESPERMID mid, tESPERVID vid);
static tESPERAttr* GetAttrById(tESPERMID mid, tESPERVID vid, tESPERAID aid);

static uint8_t defaultVarHandler(tESPERMID mid, tESPERVID vid, tESPERVar* var, eESPERRequest request, uint32_t offset, uint32_t num_elements, void* module_ctx);
static const void* defaultStorageLoad(tESPERMID mid, const char* key, void* ctx);
static const void* defaultStorageSave(tESPERMID mid, const char* key, void* ctx);

static eESPERResponse SystemModuleStateInit(tESPERMID mid, tESPERModuleSystem* ctx);
static eESPERResponse SystemModuleStateStart(tESPERMID mid, tESPERModuleSystem* ctx);
static eESPERResponse SystemModuleStateUpdate(tESPERMID mid, tESPERModuleSystem* ctx);
static uint8_t SystemModuleUptimeHandler(tESPERMID mid, tESPERVID vid, tESPERVar* var, eESPERRequest request, uint32_t offset, uint32_t num_elements, void* ctx);


const char* ESPER_GetDebugLevelStr(uint8_t level) {
	switch(level) {
	case ESPER_DEBUG_LEVEL_CRIT:
		return "CRIT";
	case ESPER_DEBUG_LEVEL_WARN:
		return "WARN";
	case ESPER_DEBUG_LEVEL_INFO:
		return "INFO";
	default:
		return "INFO";
	}
}

uint32_t esper_strcpy(char* to, const char* from, uint32_t maxlen) {
	uint32_t num_copied;

	if(!to) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "NULL to %s from %s", to, from);
		return 0;
	}

	if(!from) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "NULL to %s from %s", to, from);
		return 0;
	}

	for(num_copied = 0; (from[num_copied] != '\0') && (num_copied < maxlen); num_copied++) {
		to[num_copied] = from[num_copied];
	}

	if((num_copied == maxlen) && (maxlen != 0)) {
		to[num_copied-1] = '\0';
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "String truncated to %s", to);
	} else if (maxlen != 0) {
		to[num_copied] = '\0';
	} else {
		to[0] = '\0';
	}

	return num_copied;
}

void esper_log(uint8_t level, const char* file, const char* func, int32_t line, const char* msg, ...) {
	char debug_string[320];

	// Only log the message if our set debug level calls for it
	if(level <= g_mod_sys_ctx.debug_level) {
		va_list args;
		va_start(args, msg);
		vsnprintf(debug_string, sizeof(debug_string), msg , args);
		va_end(args);
		//printf("%u:%s:%s:%s():%d\t%s\n", ESPER_GetUptime(), ESPER_GetDebugLevelStr(level), basename(file), func, line, debug_string );
		printf("%lu\t%s\t%s\n", ESPER_GetUptime(), ESPER_GetDebugLevelStr(level), debug_string );
	}
}

eESPERResponse ESPER_Init(const char* name, tESPERModule* modules, tESPERVar* vars, tESPERAttr* attrs, uint32_t num_modules, uint32_t num_vars, uint32_t num_attrs, tESPERStorage* storage) {
	g_mod_sys_ctx.debug_level = ESPER_DEBUG_LEVEL; // set to the compiled default until the system module comes online and overrides

	g_modules = modules;
	if(!g_modules) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "No Modules Allocated");
		return ESPER_RESP_ERROR;
	}

	g_vars = vars;
	if(!g_vars) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "No Vars Allocated");
		return ESPER_RESP_ERROR;
	}

	g_attrs = attrs;
	if(!g_attrs) {
		if(num_attrs) {
			ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "No Attributes Allocated");
		} else {
			ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "No Attributes Allocated");
		}
		return ESPER_RESP_ERROR;
	}

	g_node_info.max_modules = num_modules;
	g_node_info.max_vars = num_vars;
	g_node_info.max_attrs = num_attrs;
	g_node_info.last_modified = 0;
	g_node_info.write_count = 0;

	ESPER_LOG(ESPER_DEBUG_LEVEL_INFO, "Num Modules: %u", num_modules);
	ESPER_LOG(ESPER_DEBUG_LEVEL_INFO, "Num Variables: %u", num_vars);
	ESPER_LOG(ESPER_DEBUG_LEVEL_INFO, "Num Attributes: %u", num_attrs);

	if(!storage) {
		_defaultStorage.ModuleHandler = 0;
		_defaultStorage.Load = defaultStorageLoad;
		_defaultStorage.Save = defaultStorageSave;
		g_storage = &_defaultStorage;
		ESPER_LOG(ESPER_DEBUG_LEVEL_INFO, "No Storage Module Loaded");
	} else {
		g_storage = storage;
	}

	if(ESPER_CreateModule(ESPER_MODULE_SYSTEM_KEY, ESPER_MODULE_SYSTEM_NAME, 0, SystemModuleHandler, SystemModuleInit(name, &g_mod_sys_ctx)) != 0) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "System Module is not located at MID 0!");
	}

	if(g_storage->ModuleHandler ) {
		ESPER_CreateModule(ESPER_MODULE_STORAGE_KEY, ESPER_MODULE_STORAGE_NAME, 0, g_storage->ModuleHandler, (void*)g_storage);
	}

	return ESPER_RESP_OK;
}

tESPERMID ESPER_CreateModule(const char* key, const char* name, tESPERGID gid, ModuleHandler fnHandler, void* ctx) {
	tESPERModule* module;
	tESPERMID mid;

	if(!key) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module Passed null Key");
		return ESPER_INVALID_MID;
	}

	if(!fnHandler) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %s has no handler", key);
		return ESPER_INVALID_MID;
	}

	if(!(g_node_info.num_modules < g_node_info.max_modules)) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %s could not be created, would exceeds mem alloc for modules [%u]", key, g_node_info.max_modules);
		return ESPER_INVALID_MID;
	}

	if((g_node_info.num_modules + 1) == ESPER_INVALID_MID) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %s could not be created, would overrun into ESPER_INVALID_MID", key);
		return ESPER_INVALID_MID;		
	}

	if(ESPER_GetModuleIdByKey(key) != ESPER_INVALID_MID) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %s could not be created, key already in use", key);
		return ESPER_INVALID_MID;				
	}

	mid = g_node_info.num_modules++;
	module = &g_modules[mid];
	module->info.num_vars = 0;
	module->info.last_modified = 0;
	module->info.write_count = 0;
	module->vars = 0;
	module->ctx = ctx;

	module->info.group_id  = gid;
	module->Handler = fnHandler;

	esper_strcpy(module->info.key, key, ESPER_KEY_LEN);
	if(name) {
		esper_strcpy(module->info.name, name, ESPER_NAME_LEN);
	} else {
		esper_strcpy(module->info.name, key, ESPER_KEY_LEN);
	}
	
	module->info.state = ESPER_STATE_INIT;
	if(module->Handler(mid, gid, ESPER_STATE_INIT, ctx) != ESPER_RESP_OK) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %s Init failed", key);
		return ESPER_INVALID_MID;
	}

	ESPER_LOG(ESPER_DEBUG_LEVEL_INFO, "Module %s [%u] successfully created", key, mid);

	return mid;
}


uint32_t ESPER_GetNumModules(void) {
	return g_node_info.num_modules;
}


uint32_t ESPER_GetNumModuleVars(tESPERMID mid) {
	tESPERModule* module;

	module = GetModuleById(mid);
	if(!module) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %u not found", mid);
		return 0;
	}

	return module->info.num_vars;
}

const tESPERNodeInfo* ESPER_GetNodeInfo(tESPERNodeInfo* info, eESPERResponse* resp) {
	if(!info) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Pointer Passed");
		if(resp) { *resp = ESPER_RESP_NULL_PTR_PASSED; }
		return 0;
	}

	memcpy(info, &g_node_info, sizeof(tESPERNodeInfo));

	if(resp) { *resp = ESPER_RESP_OK; }
	return info;
}

const tESPERModuleInfo* ESPER_GetModuleInfo(tESPERMID mid, tESPERModuleInfo* info, eESPERResponse* resp) {
	tESPERModule* module;

	if(!info) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Pointer Passed");
		if(resp) { *resp = ESPER_RESP_NULL_PTR_PASSED; }
		return 0;
	}

	module = GetModuleById(mid);
	if(!module) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %u not found", mid);
		if(resp) { *resp = ESPER_RESP_MID_NOT_FOUND; }
		return 0;
	}

	memcpy(info, &module->info, sizeof(tESPERModuleInfo));

	if(resp) { *resp = ESPER_RESP_OK; }
	return info;
}

const tESPERVarInfo* ESPER_GetVarInfo(tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, eESPERResponse* resp) {
	tESPERModule* module;
	tESPERVar* var;

	if(!info) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Pointer Passed");
		if(resp) { *resp = ESPER_RESP_NULL_PTR_PASSED; }
		return 0;
	}

	module = GetModuleById(mid);
	if(!module) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %u not found", mid);
		if(resp) { *resp = ESPER_RESP_MID_NOT_FOUND; }
		return 0;
	}

	var = GetVarById(mid, vid);
	if(!var) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Variable %u not found in Module %u", vid, mid);
		if(resp) { *resp = ESPER_RESP_VID_NOT_FOUND; }
		return 0;
	}

	memcpy(info, &var->info, sizeof(tESPERVarInfo));
	if(resp) { *resp = ESPER_RESP_OK; }
	return info;
}

const tESPERAttrInfo* ESPER_GetAttrInfo(tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info, eESPERResponse* resp) {
	tESPERModule* module;
	tESPERVar* var;
	tESPERAttr* attr;

	if(!info) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Pointer Passed");
		if(resp) { *resp = ESPER_RESP_NULL_PTR_PASSED; }
		return 0;
	}

	module = GetModuleById(mid);
	if(!module) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %u not found", mid);
		if(resp) { *resp = ESPER_RESP_MID_NOT_FOUND; }
		return 0;
	}

	var = GetVarById(mid, vid);
	if(!var) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Variable %u not found in Module %u", vid, mid);
		if(resp) { *resp = ESPER_RESP_VID_NOT_FOUND; }
		return 0;
	}

	attr = GetAttrById(mid, vid, aid);
	if(!attr) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Attribute %u not found in Variable %u Module %u", aid, vid, mid);
		if(resp) { *resp = ESPER_RESP_AID_NOT_FOUND; }
		return 0;
	}

	memcpy(info, &attr->info, sizeof(tESPERAttrInfo));
	if(resp) { *resp = ESPER_RESP_OK; }
	return info;
}

// Turns out this just works under linux OR niosii
volatile ESPER_TIMESTAMP ESPER_GetUptime(void) {
	static time_t start_time;

	// Get current time 
	if (start_time == 0) { start_time = time(NULL); } 

	// We want the time since we started, this won't start until ESPER_GetUptime() is called the first time!
	return (ESPER_TIMESTAMP)(time(NULL) - start_time);
}

eESPERResponse ESPER_Update(void) {
	tESPERModule* module;
	tESPERMID mod_idx;
	eESPERResponse response;

	for(mod_idx=0; mod_idx < ESPER_GetNumModules(); mod_idx++) {
		module = GetModuleById(mod_idx);
		if(!module) {
			ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %u not found", mod_idx);
			return ESPER_RESP_ERROR;
		}

		module->info.state = ESPER_STATE_UPDATE;
		response = module->Handler(mod_idx, module->info.group_id, ESPER_STATE_UPDATE, module->ctx);
		if(response != ESPER_RESP_OK) {
			switch(response) {
			case ESPER_RESP_ERROR:
				ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %s Update Failed", module->info.key);
				break;
			case ESPER_RESP_RESET:
				ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %s Requested Reset", module->info.key);
				break;
			case ESPER_RESP_SHUTDOWN:
				ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %s Requested Shutdown", module->info.key);
				break;
			default:
				ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Unhandled Response received in ESPER_Update()");
				break;
			}
			return response;
		}
	}

	return ESPER_RESP_OK;
}


eESPERResponse ESPER_Start(void) {
	tESPERModule* module;
	tESPERMID n;
	eESPERResponse response;

	for(n=0; n < ESPER_GetNumModules(); n++) {
		module = GetModuleById(n);
		if(!module) {
			ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %u not found", n);
			return ESPER_RESP_ERROR;
		}
		
		module->info.state = ESPER_STATE_START;
		response = module->Handler(n, module->info.group_id, ESPER_STATE_START, module->ctx);
		if(response != ESPER_RESP_OK) {
			ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %s Start Failed", module->info.key);
			return response;
		}
	}

	return ESPER_RESP_OK;
}

eESPERResponse ESPER_Stop(void) {
	tESPERModule* module;
	tESPERMID n;
	eESPERResponse response;

	for(n=0; n < ESPER_GetNumModules(); n++) {
		module = GetModuleById(n);
		if(!module) {
			ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module %u not found", n);
			return ESPER_RESP_ERROR;
		}
		
		module->info.state = ESPER_STATE_STOP;
		response = module->Handler(n, module->info.group_id, ESPER_STATE_STOP, module->ctx);
		if(response != ESPER_RESP_OK) {
			ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %s Stop Failed", module->info.key);
			return response;
		}
	}

	return ESPER_RESP_OK;
}

char* ESPER_GetTypeString(ESPER_TYPE type) {
	switch(type) {
	case ESPER_TYPE_NULL:
		return "NULL";
	case ESPER_TYPE_UINT8:
		return "UINT8";
	case ESPER_TYPE_UINT16:
		return "UINT16";
	case ESPER_TYPE_UINT32:
		return "UINT32";
	case ESPER_TYPE_UINT64:
		return "UINT64";
	case ESPER_TYPE_SINT8:
		return "INT8";
	case ESPER_TYPE_SINT16:
		return "INT16";
	case ESPER_TYPE_SINT32:
		return "INT32";
	case ESPER_TYPE_SINT64:
		return "INT64";
	case ESPER_TYPE_FLOAT32:
		return "FLOAT32";
	case ESPER_TYPE_FLOAT64:
		return "FLOAT64";
	case ESPER_TYPE_ASCII:
		return "ASCII";
	case ESPER_TYPE_BOOL:
		return "BOOL";
	case ESPER_TYPE_RAW:
		return "RAW";
	default:
		return "UNKNOWN";
	}
}

uint32_t ESPER_GetTypeSize(ESPER_TYPE type) {
	switch(type) {
	case ESPER_TYPE_NULL:
		return 0;
	case ESPER_TYPE_UINT8:
		return sizeof(uint8_t);
	case ESPER_TYPE_UINT16:
		return sizeof(uint16_t);
	case ESPER_TYPE_UINT32:
		return sizeof(uint32_t);
	case ESPER_TYPE_UINT64:
		return sizeof(uint64_t);
	case ESPER_TYPE_SINT8:
		return sizeof(int8_t);
	case ESPER_TYPE_SINT16:
		return sizeof(int16_t);
	case ESPER_TYPE_SINT32:
		return sizeof(int32_t);
	case ESPER_TYPE_SINT64:
		return sizeof(int64_t);
	case ESPER_TYPE_FLOAT32:
		return sizeof(float);
	case ESPER_TYPE_FLOAT64:
		return sizeof(double);
	case ESPER_TYPE_ASCII:
		return sizeof(char);
	case ESPER_TYPE_BOOL:
		return sizeof(uint8_t);
	case ESPER_TYPE_RAW:
		return sizeof(uint8_t);
	default:
		return 0;
	}
}

char* ESPER_GetResponseString(eESPERResponse resp) {
	switch(resp) {
	case ESPER_RESP_OK: 				return "OK";
	case ESPER_RESP_RESET:				return "Reset";
	case ESPER_RESP_SHUTDOWN:			return "Shutdown";
	case ESPER_RESP_OUT_OF_RANGE:		return "Out of range";
	case ESPER_RESP_BUFF_TOO_SMALL:		return "Buffer is too small";	
	case ESPER_RESP_WRITE_ONLY:			return "Resource is write-only";
	case ESPER_RESP_READ_ONLY:			return "Resource is read-only";
	case ESPER_RESP_LOCKED:				return "Resource is locked";
	case ESPER_RESP_UNKNOWN_TYPE:		return "Uknown type used";
	case ESPER_RESP_TYPE_MISMATCH:		return "Type mismatch";
	case ESPER_RESP_VID_NOT_FOUND:		return "Variable not found";
	case ESPER_RESP_MID_NOT_FOUND:		return "Module not found";
	case ESPER_RESP_AID_NOT_FOUND:		return "Attribute not found";	
	case ESPER_RESP_NULL_PTR_PASSED:	return "Null pointer passed";
	case ESPER_RESP_BAD_DATA_FORMAT:	return "Bad Data Format Used";
	case ESPER_RESP_REQUEST_TOO_LARGE:	return "Request too large";
	case ESPER_RESP_ERROR:
	default:
		return "Unknown Error";
	}
}

tESPERMID ESPER_GetModuleIdByKey(const char* key) {
	tESPERMID mid;

	if(!key) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Pointer Passed");
		return ESPER_INVALID_MID;
	}


	for(mid=0; mid < g_node_info.num_modules; mid++) {
		if(strncmp(g_modules[mid].info.key, key, ESPER_KEY_LEN) == 0) {
			return mid;
		}
	}

	return ESPER_INVALID_MID;
}

tESPERVID ESPER_GetVarIdByKey(tESPERMID mid, const char* key) {
	tESPERModule* module;
	tESPERVID vid;

	if(!key) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Pointer Passed");
		return ESPER_INVALID_MID;
	}

	module = GetModuleById(mid);
	if(!module) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module %u not found", mid);
		return ESPER_INVALID_MID;
	}

	for(vid=0; vid < module->info.num_vars; vid++) {
		if(strncmp(module->vars[vid].info.key, key, ESPER_KEY_LEN) == 0) {
			return vid;
		}
	}

	return ESPER_INVALID_VID;
}

tESPERAID ESPER_GetAttrIdByKey(tESPERMID mid, tESPERVID vid, const char* key, tESPERAID idx) {
	tESPERVar* var;
	tESPERAID aid;
	tESPERAID found_count;

	if(!key) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Pointer Passed");
		return ESPER_INVALID_MID;
	}

	var = GetVarById(mid, vid);
	if(!var) {
		return ESPER_INVALID_AID;
	}

	found_count = 0;
	for(aid=0; aid < var->info.num_attrs; aid++) {
		if(strncmp(var->attrs[aid].info.key, key, ESPER_KEY_LEN) == 0) {
			if(found_count == idx) {
			return aid;
		}
			found_count++;
		}
	}

	return ESPER_INVALID_AID;
}

tESPERVID ESPER_CreateVarNull (tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, VarHandler fnVarHandler)										{ return CreateVar(mid, key, ESPER_TYPE_NULL, options, num_elements, fnVarHandler, 0, 0); }
tESPERVID ESPER_CreateVarBool (tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint8_t* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_BOOL, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarASCII(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, char* data, volatile void* io, VarHandler fnVarHandler) 		{ return CreateVar(mid, key, ESPER_TYPE_ASCII, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarUInt8 (tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint8_t*  data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_UINT8, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarUInt16(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint16_t* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_UINT16, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarUInt32(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint32_t* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_UINT32, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarUInt64(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint64_t* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_UINT64, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarSInt8 (tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int8_t*  data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_SINT8, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarSInt16(tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int16_t* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_SINT16, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarSInt32(tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int32_t* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_SINT32, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarSInt64(tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int64_t* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_SINT64, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarFloat32(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, float* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_FLOAT32, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarFloat64(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, double* data, volatile void* io, VarHandler fnVarHandler) 	{ return CreateVar(mid, key, ESPER_TYPE_FLOAT64, options, num_elements, fnVarHandler,  data, io); }
tESPERVID ESPER_CreateVarRaw(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint8_t*  data, volatile void* io, VarHandler fnVarHandler) 		{ return CreateVar(mid, key, ESPER_TYPE_RAW, options, num_elements, fnVarHandler,  data, io); }


tESPERAID ESPER_CreateAttrNull(tESPERMID mid, tESPERVID vid, const char* key, const char* name)						{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_NULL, 0); }
tESPERAID ESPER_CreateAttrASCII(tESPERMID mid, tESPERVID vid, const char* key, const char* name, const char* data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_ASCII, data); }
tESPERAID ESPER_CreateAttrBool(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint8_t data) 		{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_BOOL, &data); }
tESPERAID ESPER_CreateAttrUInt8(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint8_t data) 		{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_UINT8, &data); }
tESPERAID ESPER_CreateAttrUInt16(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint16_t data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_UINT16, &data); }
tESPERAID ESPER_CreateAttrUInt32(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint32_t data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_UINT32, &data); }
tESPERAID ESPER_CreateAttrUInt64(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint64_t data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_UINT64, &data); }
tESPERAID ESPER_CreateAttrSInt8(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int8_t data) 	    { return CreateAttr(mid, vid, key, name, ESPER_TYPE_SINT8, &data); }
tESPERAID ESPER_CreateAttrSInt16(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int16_t data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_SINT16, &data); }
tESPERAID ESPER_CreateAttrSInt32(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int32_t data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_SINT32, &data); }
tESPERAID ESPER_CreateAttrSInt64(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int64_t data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_SINT64, &data); }
tESPERAID ESPER_CreateAttrFloat32(tESPERMID mid, tESPERVID vid, const char* key, const char* name, float* data) 		{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_FLOAT32, data); }
tESPERAID ESPER_CreateAttrFloat64(tESPERMID mid, tESPERVID vid, const char* key, const char* name, double* data) 	{ return CreateAttr(mid, vid, key, name, ESPER_TYPE_FLOAT64, data); }

eESPERResponse ESPER_WriteVarNull(tESPERMID mid, tESPERVID vid,uint32_t offset) 					{ uint32_t num_elements = 1; return WriteVar(mid, vid, ESPER_TYPE_NULL, offset, num_elements, 0, 0); }
eESPERResponse ESPER_WriteVarBool(tESPERMID mid, tESPERVID vid,uint32_t offset, uint8_t data) 		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_BOOL, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarASCII(tESPERMID mid, tESPERVID vid,uint32_t offset, char data)			{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_ASCII, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarUInt8(tESPERMID mid, tESPERVID vid,uint32_t offset, uint8_t data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_UINT8, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarUInt16(tESPERMID mid, tESPERVID vid,uint32_t offset, uint16_t data)	{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_UINT16, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarUInt32(tESPERMID mid, tESPERVID vid,uint32_t offset, uint32_t data)	{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_UINT32, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarUInt64(tESPERMID mid, tESPERVID vid,uint32_t offset, uint64_t data)	{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_UINT64, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarSInt8(tESPERMID mid, tESPERVID vid,uint32_t offset, int8_t data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_SINT8, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarSInt16(tESPERMID mid, tESPERVID vid,uint32_t offset, int16_t data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_SINT16, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarSInt32(tESPERMID mid, tESPERVID vid,uint32_t offset, int32_t data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_SINT32, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarSInt64(tESPERMID mid, tESPERVID vid,uint32_t offset, int64_t data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_SINT64, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarFloat32(tESPERMID mid, tESPERVID vid,uint32_t offset, float data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_FLOAT32, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarFloat64(tESPERMID mid, tESPERVID vid,uint32_t offset, double data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_FLOAT64, offset, num_elements, &data, &len); }
eESPERResponse ESPER_WriteVarRaw(tESPERMID mid, tESPERVID vid,uint32_t offset, uint8_t data)		{ uint32_t num_elements = 1; uint32_t len = sizeof(data);	return WriteVar(mid, vid, ESPER_TYPE_RAW, offset, num_elements, &data, &len); }

eESPERResponse ESPER_WriteVarNullArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements) 												{ return WriteVar(mid, vid, ESPER_TYPE_NULL, offset, num_elements, 0, 0); }
eESPERResponse ESPER_WriteVarBoolArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint8_t* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_BOOL, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarASCIIArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const char* buff, uint32_t* buff_len)			{ return WriteVar(mid, vid, ESPER_TYPE_ASCII, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarUInt8Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint8_t* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_UINT8, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarUInt16Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint16_t* buff, uint32_t* buff_len)	{ return WriteVar(mid, vid, ESPER_TYPE_UINT16, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarUInt32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint32_t* buff, uint32_t* buff_len)	{ return WriteVar(mid, vid, ESPER_TYPE_UINT32, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarUInt64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint64_t* buff, uint32_t* buff_len)	{ return WriteVar(mid, vid, ESPER_TYPE_UINT64, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarSInt8Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int8_t* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_SINT8, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarSInt16Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int16_t* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_SINT16, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarSInt32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int32_t* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_SINT32, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarSInt64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int64_t* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_SINT64, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarFloat32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const float* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_FLOAT32, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarFloat64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const double* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_FLOAT64, offset, num_elements, buff, buff_len); }
eESPERResponse ESPER_WriteVarRawArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint8_t* buff, uint32_t* buff_len)		{ return WriteVar(mid, vid, ESPER_TYPE_RAW, offset, num_elements, buff, buff_len); }

uint8_t ESPER_ReadVarBool(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_BOOL, 	offset, num_elements, &bytelen, resp); return (val) ? *((uint8_t*)val) : 0; }
char ESPER_ReadVarASCII(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_ASCII, 	offset, num_elements, &bytelen, resp); return (val) ? *((char*)val) : 0; }
uint8_t ESPER_ReadVarUInt8(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)		{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_UINT8, 	offset, num_elements, &bytelen, resp); return (val) ? *((uint8_t*)val) : 0; }
uint16_t ESPER_ReadVarUInt16(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_UINT16, 	offset, num_elements, &bytelen, resp); return (val) ? *((uint16_t*)val) : 0; }
uint32_t ESPER_ReadVarUInt32(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_UINT32, 	offset, num_elements, &bytelen, resp); return (val) ? *((uint32_t*)val) : 0; }
uint64_t ESPER_ReadVarUInt64(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_UINT64, 	offset, num_elements, &bytelen, resp); return (val) ? *((uint64_t*)val) : 0; }
int8_t ESPER_ReadVarSInt8(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)		{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_SINT8, 	offset, num_elements, &bytelen, resp); return (val) ? *((int8_t*)val) : 0; }
int16_t ESPER_ReadVarSInt16(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_SINT16, 	offset, num_elements, &bytelen, resp); return (val) ? *((int16_t*)val) : 0; }
int32_t ESPER_ReadVarSInt32(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_SINT32, 	offset, num_elements, &bytelen, resp); return (val) ? *((int32_t*)val) : 0; }
int64_t ESPER_ReadVarSInt64(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_SINT64, 	offset, num_elements, &bytelen, resp); return (val) ? *((int64_t*)val) : 0; }
float ESPER_ReadVarFloat32(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)		{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_FLOAT32, offset, num_elements, &bytelen, resp); return (val) ? *((float*)val) : 0.0; }
double ESPER_ReadVarFloat64(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)	{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_FLOAT64, offset, num_elements, &bytelen, resp); return (val) ? *((double*)val) : 0.0; }
uint8_t ESPER_ReadVarRaw(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp)		{ uint32_t num_elements = 1; uint32_t bytelen; const void* val; val = ReadVar(mid, vid, ESPER_TYPE_RAW, 	offset, num_elements, &bytelen, resp); return (val) ? *((uint8_t*)val) : 0; }

const uint8_t* ESPER_ReadVarBoolArray(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_BOOL, offset, num_elements, buf_len, resp); }
const char* ESPER_ReadVarASCIIArray(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)			{ return ReadVar(mid, vid, ESPER_TYPE_ASCII, offset, num_elements, buf_len, resp); }
const uint8_t* ESPER_ReadVarUInt8Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_UINT8, offset, num_elements, buf_len, resp); }
const uint16_t* ESPER_ReadVarUInt16Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)	{ return ReadVar(mid, vid, ESPER_TYPE_UINT16, offset, num_elements, buf_len, resp); }
const uint32_t* ESPER_ReadVarUInt32Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)	{ return ReadVar(mid, vid, ESPER_TYPE_UINT32, offset, num_elements, buf_len, resp); }
const uint64_t* ESPER_ReadVarUInt64Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)	{ return ReadVar(mid, vid, ESPER_TYPE_UINT64, offset, num_elements, buf_len, resp); }
const int8_t* ESPER_ReadVarSInt8Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_SINT8, offset, num_elements, buf_len, resp); }
const int16_t* ESPER_ReadVarSInt16Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_SINT16, offset, num_elements, buf_len, resp); }
const int32_t* ESPER_ReadVarSInt32Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_SINT32, offset, num_elements, buf_len, resp); }
const int64_t* ESPER_ReadVarSInt64Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_SINT64, offset, num_elements, buf_len, resp); }
const float* ESPER_ReadVarFloat32Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_FLOAT32, offset, num_elements, buf_len, resp); }
const double* ESPER_ReadVarFloat64Array(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_FLOAT64, offset, num_elements, buf_len, resp); }
const uint8_t* ESPER_ReadVarRawArray(tESPERMID mid, tESPERVID vid,  uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp)		{ return ReadVar(mid, vid, ESPER_TYPE_RAW, offset, num_elements, buf_len, resp); }

uint8_t ESPER_ReadAttrBool(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp) 		{ return *(uint8_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_BOOL, resp); }
const char* ESPER_ReadAttrASCII(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp) 	{ return ReadAttr(mid, vid, aid, ESPER_TYPE_ASCII, resp); }
uint8_t ESPER_ReadAttrUInt8(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)		{ return *(uint8_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_UINT8, resp);}
uint16_t ESPER_ReadAttrUInt16(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)	{ return *(uint16_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_UINT16, resp);}
uint32_t ESPER_ReadAttrUInt32(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)	{ return *(uint32_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_UINT32, resp);}
uint64_t ESPER_ReadAttrUInt64(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)	{ return *(uint64_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_UINT64, resp);}
int8_t ESPER_ReadAttrSInt8(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)		{ return *(int8_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_SINT8, resp);}
int16_t ESPER_ReadAttrSInt16(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)		{ return *(int16_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_SINT16, resp);}
int32_t ESPER_ReadAttrSInt32(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)		{ return *(int32_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_SINT32, resp);}
int64_t ESPER_ReadAttrSInt64(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)		{ return *(int64_t*)ReadAttr(mid, vid, aid, ESPER_TYPE_SINT64, resp);}
float ESPER_ReadAttrFloat32(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)		{ return *(float*)ReadAttr(mid, vid, aid, ESPER_TYPE_FLOAT32, resp);}
double ESPER_ReadAttrFloat64(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp)		{ return *(double*)ReadAttr(mid, vid, aid, ESPER_TYPE_FLOAT64, resp);}

void ESPER_RefreshNode(void) {
	tESPERMID mod_idx;

	for(mod_idx=0; mod_idx < ESPER_GetNumModules(); mod_idx++) {
		ESPER_RefreshModule(mod_idx);
	}
}

void ESPER_RefreshModule(tESPERMID mid) {
	uint32_t var_idx;

	if(!GetModuleById(mid))  {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module not found %u attempting refresh", mid);
		return;
	}

	for(var_idx=0; var_idx < ESPER_GetNumModuleVars(mid); var_idx++) {
		ESPER_RefreshVar(mid, var_idx);
	}
}

void ESPER_RefreshVar(tESPERMID mid, tESPERVID vid) {
	tESPERVar* var;
	tESPERModule* mod;

	mod = GetModuleById(mid);
	if(!mod)  {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Module not found %u attempting refresh", mid);
		return;
	}

	var = GetVarById(mid, vid);
	if(!var) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Variable not found %u attempting refresh on mod %u", vid, mid);
		return;
	}

	// Let the read handler optionally call touch_var on change
	var->Handler(mid, vid, var, ESPER_REQUEST_READ_PRE, 0, var->info.max_elements_per_request, mod->ctx);
}

static uint8_t defaultVarHandler(tESPERMID mid, tESPERVID vid, tESPERVar* var, eESPERRequest request, uint32_t offset, uint32_t num_elements, void* module_ctx) {
	uint32_t byte_count;
	uint32_t byte_offset;

	byte_offset = offset * ESPER_GetTypeSize(var->info.type);
	byte_count = num_elements * ESPER_GetTypeSize(var->info.type);	
	
	switch(request) {
	case ESPER_REQUEST_INIT:
		if(var->info.type == ESPER_TYPE_ASCII) {
			((char*)var->data)[var->info.max_elements_per_request-1] = '\0';
			var->info.num_elements = strlen(var->data);
		}
		break;

	case ESPER_REQUEST_READ_PRE:
		// Update FROM IO to ESPER if we notice a difference between the two, and update the ts+wc info
		if(var->io) {		
			if(memcmp(var->data + byte_offset, (void*)var->io + byte_offset, byte_count) != 0) {
				memcpy(var->data + byte_offset, (void*)var->io + byte_offset, byte_count);
				ESPER_TouchVar(mid, vid);
			}
		}
		break;

	case ESPER_REQUEST_WRITE_PRE:
		break;
	case ESPER_REQUEST_WRITE_POST:
		// Update the IO after if we've been sent new ESPER data
		if(var->io) {	
			// Perform the write regardless, in-case the fabric is looking for a write		
			memcpy((void*)var->io + byte_offset, var->data + byte_offset, byte_count);
	}

		if(var->info.type == ESPER_TYPE_ASCII) {
			((char*)var->data)[var->info.max_elements_per_request-1] = '\0';
			var->info.num_elements = strlen(var->data);
		}
		break;
	}

	return 1;
}



static const void* defaultStorageLoad(tESPERMID mid, const char* key, void* ctx) {
	return 0;
}

static const void* defaultStorageSave(tESPERMID mid, const char* key, void* ctx) {
	return 0;
}

static tESPERVID CreateVar(tESPERMID mid, const char* key, ESPER_TYPE type, ESPER_OPTIONS options,uint32_t num_elements, VarHandler fnVarHandler, void* data, volatile void* io) {
	tESPERModule* module;
	tESPERVar* var;
	tESPERVID vid;

	module = GetModuleById(mid);
	if(!module)  {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Module not found %u attempting to create var", mid);
		return ESPER_INVALID_VID;
	}

	if(!key) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Var Key passed in Mod %s", module->info.key);
		return ESPER_INVALID_VID;
	}

	if(module->info.state != ESPER_STATE_INIT) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Variable creation attempted outside of ESPER_STATE_INIT. Mod: %s Var: %s", module->info.key, key);
		return ESPER_INVALID_VID;
	}

	if(!(g_node_info.num_vars < g_node_info.max_vars)) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Variable %s could not be created, would exceeds mem alloc for vars [%u]", key, g_node_info.max_vars);
		return ESPER_INVALID_VID;
	}

	if((g_node_info.num_vars + 1) == ESPER_INVALID_VID) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Variable %s could not be created in Mod %s, would overrun into ESPER_INVALID_VID", key, module->info.key);
		return ESPER_INVALID_VID;		
	}

	if(ESPER_GetVarIdByKey(mid, key) != ESPER_INVALID_VID) {
		ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Variable %s could not be created in Mod %s, key already in use", key, module->info.key);
		return ESPER_INVALID_VID;				
	}

	var = &g_vars[g_node_info.num_vars++];
	vid = module->info.num_vars++;
	var->info.last_modified = 0;
	var->info.write_count = 0;
	var->info.status = 0;
	var->info.num_attrs = 0;
	var->attrs = 0;
	var->info.options = options;
	var->info.type = type;
	var->info.num_elements = num_elements;
	var->info.max_elements_per_request = num_elements;
	var->data = data;
	var->io = io;

	// If we have IO, load it into data by default
	// Loading from DISK/FLASH/NETWORK will occur later, as the Handler may require other variables to exist, but this is safe to do
	if(var->data && var->io) memcpy(var->data, (void*)var->io, num_elements * ESPER_GetTypeSize(type));

	var->Handler = (fnVarHandler) ? fnVarHandler : defaultVarHandler;

	esper_strcpy(var->info.key, key, ESPER_KEY_LEN);

	// Add first var if necessary to module
	if(module->vars == 0) {
		module->vars = var;
	}

	var->Handler(mid, vid, var, ESPER_REQUEST_INIT, 0, var->info.num_elements, module->ctx);

	ESPER_LOG(ESPER_DEBUG_LEVEL_INFO, "Variable %s created [%u]", key, vid);

	return vid;
}

static tESPERAID CreateAttr(tESPERMID mid, tESPERVID vid, const char* key, const char* name, ESPER_TYPE type, const void* data) {
	tESPERModule* module;
	tESPERVar* var;
	tESPERAttr* attr;
	tESPERAID aid;

	if(!key) return ESPER_INVALID_AID;

	module = GetModuleById(mid);
	if(!module) return ESPER_INVALID_AID;

	var = GetVarById(mid, vid);
	if(!var) return ESPER_INVALID_AID;

	if((g_node_info.num_attrs >= g_node_info.max_attrs) || (var->info.num_attrs == ESPER_INVALID_AID)) return ESPER_INVALID_AID;

	// TODO: Add check to make sure we are still in 'init' phase of, can't create variables during normal operation!
	// TODO: Add check to make sure key does not exist in vars

	attr = &g_attrs[g_node_info.num_attrs++];
	aid = var->info.num_attrs++;
	attr->info.type = type;
	esper_strcpy(attr->info.key, key, ESPER_KEY_LEN);
	esper_strcpy(attr->info.name, name, ESPER_NAME_LEN);

	// Add first var if necessary to module
	if(var->attrs == 0) {
		var->attrs = attr;
	}

	if(type != ESPER_TYPE_NULL) {
		if(type == ESPER_TYPE_ASCII) {
			esper_strcpy(attr->data.str, data, ESPER_ATTR_LEN);
		} else {
			memcpy(&attr->data, data, ESPER_GetTypeSize(type));
		}
	}

	ESPER_LOG(ESPER_DEBUG_LEVEL_INFO, "Attribute %u:%s:%s created", aid, key, name);

	return aid;
}

void ESPER_TouchVar(tESPERMID mid, tESPERVID vid) {
	tESPERModule* module;
	tESPERVar* var;
	ESPER_TIMESTAMP current_ts;

	module = GetModuleById(mid);
	if(!module) return;

	var = GetVarById(mid, vid);
	if(!var) return;

	g_write_count++;
	var->info.write_count = g_write_count;
	module->info.write_count = g_write_count;
	g_node_info.write_count = g_write_count;

	current_ts = ESPER_GetUptime();
	var->info.last_modified = current_ts;
	module->info.last_modified = current_ts;
	g_node_info.last_modified = current_ts;
}

static eESPERResponse WriteVar(tESPERMID mid, tESPERVID vid, ESPER_TYPE type, uint32_t offset, const uint32_t num_elements, const void* buff, uint32_t* buff_len) {
	tESPERModule* module;
	tESPERVar* var;
	uint32_t var_size;
	uint32_t data_offset;

	module = GetModuleById(mid);
	if(!module) return ESPER_RESP_MID_NOT_FOUND;

	var = GetVarById(mid, vid);
	if(!var) return ESPER_RESP_VID_NOT_FOUND;

	// START internal errors, if these occur, there is a bug in a module or the internal esper code 
	if(type != var->info.type) return ESPER_RESP_ERROR;
	if(!num_elements) return ESPER_RESP_ERROR;
	// END internal errors 

	var_size = ESPER_GetTypeSize(type);

	if(!(var->info.options & ESPER_OPTION_WR)) return ESPER_RESP_READ_ONLY;
	if((var->info.status & ESPER_STATUS_LOCKED)) return ESPER_RESP_LOCKED;

	if(buff_len) {
		if(*buff_len < (var_size * num_elements)) {
			ESPER_LOG(ESPER_DEBUG_LEVEL_WARN, "Undersized buffer. Buffer Len: %u, Var size: %u, Num Elements: %u", *buff_len, var_size, num_elements);
			return ESPER_RESP_BUFF_TOO_SMALL;
		} else {
			*buff_len = var_size * num_elements;
		}
	}

	if(var->info.options & ESPER_OPTION_WINDOW) {
		data_offset = 0;
	} else {
		data_offset = offset;
		}

	if((num_elements + data_offset) > var->info.max_elements_per_request)  { // Bail if attempt is made to write more than is possible to var
		return ESPER_RESP_OUT_OF_RANGE;
	}

	// WARNING: Never put a return or break between the two WriteHandle() calls, certain operations may hold a mutex while the write is occurring, the PRE/POST call counts must match!
	// throwing const on num_elements, we could break up read/write handlers to avoid this, but it means  separate functions...
	if(var->Handler(mid, vid, var, ESPER_REQUEST_WRITE_PRE, offset, num_elements, module->ctx)) {
		// Only write data if we can, otherwise just 'touch' the var modified
		if(var->data && (num_elements > 0) && (buff_len) && (buff)) {
			memcpy(var->data + (data_offset*var_size) , buff,  num_elements * var_size);
}

		if(var->Handler(mid, vid, var, ESPER_REQUEST_WRITE_POST, offset, num_elements, module->ctx)) {
			ESPER_TouchVar(mid,vid);
		}
	}

	return ESPER_RESP_OK;
}

// TODO: There is an assumption here that void* data can contain num_elements * size_of_type
static const void* ReadVar(tESPERMID mid, tESPERVID vid, ESPER_TYPE type, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp) {
	tESPERModule* module;
	tESPERVar* var;
	uint32_t var_size;
	uint32_t data_offset;

	module = GetModuleById(mid);
	if(!module) {
		if(resp) { *resp = ESPER_RESP_MID_NOT_FOUND; }
		if(buf_len) *buf_len = 0;
		return 0;
	}

	var = GetVarById(mid, vid);
	if(!var) {
		if(resp) { *resp = ESPER_RESP_VID_NOT_FOUND; }
		if(buf_len) *buf_len = 0;
		return 0;
	}

	if(!(var->info.options & ESPER_OPTION_RD)) {
		if(resp) { *resp = ESPER_RESP_WRITE_ONLY; }
		if(buf_len) *buf_len = 0;
		return 0;
	}

	if(type != var->info.type) {
		if(resp) { *resp = ESPER_RESP_TYPE_MISMATCH; }
		if(buf_len) *buf_len = 0;
		return 0;		
	}

	if(!num_elements) { 
		if(resp) { *resp = ESPER_RESP_OUT_OF_RANGE; }
		if(buf_len) *buf_len = 0;
		return 0;
	}

	if(!buf_len) {
		if(resp) { *resp = ESPER_RESP_BUFF_TOO_SMALL; }
		if(buf_len) *buf_len = 0;
		return 0;
	}

	// Adjust the offset if its a WINDOW var  
	if(var->info.options & ESPER_OPTION_WINDOW) {
		data_offset = 0;
	} else {
		data_offset = offset;
		}

	var_size = ESPER_GetTypeSize(var->info.type);

	if(num_elements > var->info.max_elements_per_request) {
		*buf_len = 0;
		if(resp) { *resp = ESPER_RESP_REQUEST_TOO_LARGE; }
		return 0;
		}

	// Does the request fit inside the range of the variable?
	if((num_elements + offset) > var->info.num_elements)  { 
		*buf_len = 0;
		if(resp) { *resp = ESPER_RESP_OUT_OF_RANGE; }
		return 0;
		}

	// Useful for prefetch of data on read request
	// If ReadHandler is set, let it take care of doing whatever is desired with IO 
	if(resp) { *resp = ESPER_RESP_OK; }

	var->Handler(mid, vid, var, ESPER_REQUEST_READ_PRE, offset, num_elements, module->ctx);

	*buf_len = num_elements * var_size;	

	return var->data + (data_offset * var_size);
	}

//! This is used if we can't find the attribute asked for in ReadAttr(), we must return something, lets make it valid
static uESPERData defaultAttrData;

static void* ReadAttr(tESPERMID mid, tESPERVID vid, tESPERAID aid, ESPER_TYPE type, eESPERResponse *resp) {
	tESPERAttr* attr;

	attr = GetAttrById(mid, vid, aid);
	if(!attr) {
		if(resp) {
			*resp = ESPER_RESP_AID_NOT_FOUND;
		}
		return &defaultAttrData;
	}

	if(type != attr->info.type) {
		if(resp) {
			*resp = ESPER_RESP_ERROR;
	}
		return &defaultAttrData;
	}

	if(resp) {
		*resp = ESPER_RESP_OK;
	}

	return &attr->data;
}

static tESPERModule* GetModuleById(tESPERMID mid) {

	if(!(mid < g_node_info.num_modules)) {
		return 0;
	}

	return &g_modules[mid];
}

static tESPERVar* GetVarById(tESPERMID mid, tESPERVID vid) {
	tESPERModule* module;

	module = GetModuleById(mid);
	if(!module) return 0;

	if(!(vid < module->info.num_vars)) return 0;

	return &module->vars[vid];
}

static tESPERAttr* GetAttrById(tESPERMID mid, tESPERVID vid, tESPERAID aid) {
	tESPERVar* var;

	var = GetVarById(mid, vid);
	if(!var) return 0;

	if(!(aid < var->info.num_attrs)) return 0;

	return &var->attrs[aid];
}

static tESPERModuleSystem* SystemModuleInit(const char* device, tESPERModuleSystem* ctx) {
	if(!ctx) return 0;
	if(!device) return 0;

	esper_strcpy(ctx->device, device, sizeof(ctx->device));

	return ctx;
}

static eESPERResponse SystemModuleHandler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx) {
	switch(state) {
	case ESPER_STATE_INIT:
		return SystemModuleStateInit(mid, (tESPERModuleSystem*)ctx);
	case ESPER_STATE_START:
		return SystemModuleStateStart(mid, (tESPERModuleSystem*)ctx);
	case ESPER_STATE_UPDATE:
		return SystemModuleStateUpdate(mid, (tESPERModuleSystem*)ctx);
	case ESPER_STATE_STOP:
		break;
	}
	return ESPER_RESP_OK;
}

static eESPERResponse SystemModuleStateInit(tESPERMID mid, tESPERModuleSystem* ctx) {
	tESPERVID vid;

	vid = ESPER_CreateVarASCII(mid, "device", ESPER_OPTION_RD, sizeof(ctx->device), ctx->device, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name","Device");
	
	vid = ESPER_CreateVarUInt32(mid, "version", ESPER_OPTION_RD, 1, &g_esper_version, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name","Framework Version");
	
	vid = ESPER_CreateVarUInt32(mid, SYS_VAR_UPTIME, ESPER_OPTION_RD, 1, &ctx->uptime, 0, SystemModuleUptimeHandler);
	ESPER_CreateAttrNull(mid, vid, "name", "Uptime");
	ESPER_CreateAttrNull(mid, vid, "format", "uptime");
	
	vid = ESPER_CreateVarUInt8(mid, SYS_VAR_DEBUG_LEVEL, ESPER_OPTION_WR_RD, 1, &ctx->debug_level, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Debug Level");
	ESPER_CreateAttrNull(mid, vid, "format", "select");
	ESPER_CreateAttrUInt8(mid, vid, "option", "CRIT", ESPER_DEBUG_LEVEL_CRIT);
	ESPER_CreateAttrUInt8(mid, vid, "option", "WARN", ESPER_DEBUG_LEVEL_WARN);
	ESPER_CreateAttrUInt8(mid, vid, "option", "INFO", ESPER_DEBUG_LEVEL_INFO);

	vid = ESPER_CreateVarUInt32(mid, "num_modules", ESPER_OPTION_RD, 1, &g_node_info.num_modules, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Modules Created");
	
	vid = ESPER_CreateVarUInt32(mid, "num_vars", ESPER_OPTION_RD, 1, &g_node_info.num_vars, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Variables Created");
	
	vid = ESPER_CreateVarUInt32(mid, "num_attrs", ESPER_OPTION_RD, 1, &g_node_info.num_attrs, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Attributes Created");
	
	vid = ESPER_CreateVarUInt32(mid, "max_modules", ESPER_OPTION_RD, 1, &g_node_info.max_modules, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Modules Allocated");
	
	vid = ESPER_CreateVarUInt32(mid, "max_vars", ESPER_OPTION_RD, 1, &g_node_info.max_vars, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Variables Allocated");
	
	vid = ESPER_CreateVarUInt32(mid, "max_attrs", ESPER_OPTION_RD, 1, &g_node_info.max_attrs, 0, 0);
	ESPER_CreateAttrNull(mid, vid, "name", "Attributes Allocated");
	
	return ESPER_RESP_OK;
}

static eESPERResponse SystemModuleStateStart(tESPERMID mid, tESPERModuleSystem* ctx) {
	ctx->uptime = ESPER_GetUptime();
	ctx->debug_level = ESPER_DEBUG_LEVEL; // start at a default debug level
	
	return ESPER_RESP_OK;
}

static eESPERResponse SystemModuleStateUpdate(tESPERMID mid, tESPERModuleSystem* ctx) {
	return ESPER_RESP_OK;
}


static uint8_t SystemModuleUptimeHandler(tESPERMID mid, tESPERVID vid, tESPERVar* var, eESPERRequest request, uint32_t offset, uint32_t num_elements, void* ctx) {
	ESPER_TIMESTAMP curr_time;
	tESPERModuleSystem* sys_ctx = ctx;
	
	switch(request) {
		case ESPER_REQUEST_READ_PRE:
			curr_time = ESPER_GetUptime();
			if(sys_ctx->uptime != curr_time) {
				sys_ctx->uptime = curr_time;
				ESPER_TouchVar(mid, vid);
			} 
			break;
		default:
			break;
	}

	return 0;
}

uint32_t ESPER_GetVersion(void) {
	return g_esper_version; //!< Don't point this at the constant directly
}

#pragma GCC pop_options
