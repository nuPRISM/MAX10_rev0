#include "storage_linux_file.h"

static eESPERResponse Handler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx);
static const void* Load(tESPERMID mid, const char* key, void* ctx);
static const void* Save(tESPERMID mid, const char* key, void* ctx);

tESPERStorage* LinuxFileStorage(tESPERStorage* ctx) {
	if(ctx) {
		ctx->ModuleHandler = Handler;
		ctx->Load = Load;
		ctx->Save = Save;
	} else {
        ESPER_LOG(ESPER_DEBUG_LEVEL_CRIT, "Null Context Passed to Linux Storage");
    }

    return ctx;
}

static eESPERResponse Handler(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx) {

	switch(state) {
	case ESPER_STATE_INIT:
		return ESPER_RESP_OK;
	case ESPER_STATE_START:
		return ESPER_RESP_OK;
	case ESPER_STATE_UPDATE:
		return ESPER_RESP_OK;
	case ESPER_STATE_STOP:
		return ESPER_RESP_OK;
	}

	return ESPER_RESP_OK;
}

static const void* Load(tESPERMID mid, const char* key, void* ctx) {
	return 0;
}

static const void* Save(tESPERMID mid, const char* key, void* ctx) {
	return 0;
}