/*! @addtogroup ESPER
 *  @{
 *  @brief ESPER Documentation
 *  @details The ESPER framework 
 *  @author Bryerton Shaw
 *  @version 1.0
 */

#ifndef ESPER_H_
#define ESPER_H_

#include <stdint.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

#define ESPER_VERSION 1

#define ESPER_KEY_LEN 100		//!< Do not change
#define ESPER_NAME_LEN 100		//!< Do not change
#define ESPER_ATTR_LEN 100		//!< Do not change

#define SYS_VAR_UPTIME "uptime"
#define SYS_VAR_NAME   "name"
#define SYS_VAR_DEBUG_LEVEL "debug_level"

#define ESPER_MODULE_SYSTEM_KEY "system"	//!< Standard SYSTEM module key, do not change!
#define ESPER_MODULE_STORAGE_KEY "storage"	//!< Standard STORAGE module key, do not change!
#define ESPER_MODULE_LOGGER_KEY "logger"	//!< Standard LOGGER module key, do not change!

#define ESPER_MODULE_SYSTEM_NAME "System"	//!< Standard SYSTEM module name, do not change!
#define ESPER_MODULE_STORAGE_NAME "Storage"	//!< Standard STORAGE module name, do not change!
#define ESPER_MODULE_LOGGER_NAME "Logger"	//!< Standard LOGGER module name, do not change!

typedef uint8_t ESPER_LOG_LEVEL;
#define ESPER_DEBUG_LEVEL_CRIT 0
#define ESPER_DEBUG_LEVEL_WARN 1
#define ESPER_DEBUG_LEVEL_INFO 2
#define ESPER_DEBUG_LEVEL ESPER_DEBUG_LEVEL_INFO

//! Define ESPER_LOG elsewhere if you wish to call your own log function (or none at all)
#ifndef ESPER_LOG
#define ESPER_LOG(level, msg, ...) esper_log(level, __FILE__, __FUNCTION__ , __LINE__, msg, ##__VA_ARGS__);
#endif

//! ESPER Variable Data Types
typedef uint8_t ESPER_TYPE;
#define ESPER_TYPE_NULL		0	//!< NULL means no memory has been allocated. Useful for @Requests
#define ESPER_TYPE_UINT8	1
#define ESPER_TYPE_UINT16	2
#define ESPER_TYPE_UINT32	3
#define ESPER_TYPE_UINT64	4	//!< Be warned, some platforms (such as javascript), do not support 64-bit integers!
#define ESPER_TYPE_SINT8	5
#define ESPER_TYPE_SINT16	6
#define ESPER_TYPE_SINT32	7
#define ESPER_TYPE_SINT64	8	//!< Be warned, some platforms (such as javascript), do not support 64-bit integers!
#define ESPER_TYPE_FLOAT32	9
#define ESPER_TYPE_FLOAT64	10
#define ESPER_TYPE_ASCII	11	//!< Currently only ASCII is supported, UTF8 is a possibility. 
#define ESPER_TYPE_BOOL		12	//!< Stored as uint8_t
#define ESPER_TYPE_RAW		13  //!< special case of uint8_t

//! ESPER Variable Options
typedef uint8_t ESPER_OPTIONS;
#define ESPER_OPTION_RD 		(1 << 0) //! Make var data read-able
#define ESPER_OPTION_WR			(1 << 1) //! Make var data write-able
#define ESPER_OPTION_WR_RD		(ESPER_OPTION_WR | ESPER_OPTION_RD) //! Make var data read-write
#define ESPER_OPTION_RD_WR		(ESPER_OPTION_WR_RD) //! Make var data read-write
#define ESPER_OPTION_HIDDEN 	(1 << 2) //! Hidden vars must be specifically requested to be read out, useful to hide large or expert variables
#define ESPER_OPTION_STORABLE	(1 << 3) //! Indicates the variable will be stored on a save
#define ESPER_OPTION_LOCKABLE	(1 << 4) //! Indicates the variable can be locked on request @see Locking
#define ESPER_OPTION_WINDOW		(1 << 5) //! Vindow variables accept any offset, but always read/write from offset 0 in their data, useful when combined with PRE read/POST write @Requests to create windows

//! ESPER Variable Statuses										
typedef uint8_t ESPER_STATUS;
#define ESPER_STATUS_LOCKED		(1 << 0) //! Variable is temporarily locked (non-writeable)
#define ESPER_STATUS_STORED		(1 << 1) //! Variable hasn't been modified since last save to storage
#define ESPER_STATUS_LOGGED		(1 << 2) //! Variable will log additional info when set, overrides debug_level @see Debugging

//! ESPER Timestamp
typedef uint32_t ESPER_TIMESTAMP;

//! ESPER Writecount
typedef uint32_t ESPER_WRITECOUNT;

#define ESPER_INVALID_GID 0xFFFFFFFF
#define ESPER_INVALID_MID 0xFFFFFFFF
#define ESPER_INVALID_VID 0xFFFFFFFF
#define ESPER_INVALID_AID 0xFFFFFFFF

//! @note These sizes may seem low, but if you exceed them, you probably need something more than ESPER, or more use of arrays
typedef uint32_t tESPERGID;
typedef uint32_t tESPERMID;
typedef uint32_t tESPERVID;
typedef uint32_t tESPERAID;

//! ESPER Requests
//! @NOTE: READ and WRITE are separated so it's possible to re-use the same Handler for READ/WRITE, differentiated requests using this ENUM
typedef enum {
	ESPER_REQUEST_WRITE_PRE,	//!< Pre-Write Request, called before data is written to variable
	ESPER_REQUEST_WRITE_POST,	//!< Post-Write Request, called after data is written to variable
	ESPER_REQUEST_READ_PRE,		//!< Pre-Read Request, called before data is read from variable
	ESPER_REQUEST_INIT			//!< Called during CreateVar
} eESPERRequest;

//! ESPER State
typedef enum {
	ESPER_STATE_INIT,	//!< Initialization state, variables can be created at this time in modules 
	ESPER_STATE_START,	//!< Startup state, any services should be started, once a module starts, it's vars can be used
	ESPER_STATE_UPDATE,	//!< Update state, variables inside module may be updated internally
	ESPER_STATE_STOP,	//!< Stopped state, variables inside a stopped module can not be accessed
} eESPERState;

typedef enum {
	ESPER_RESP_OK = 0,				//!< Module is reporting is is OK
	ESPER_RESP_ERROR = 1,			//!< Module is reporting it errored 
	ESPER_RESP_RESET = 2,			//!< Module is requesting ESPER reset
	ESPER_RESP_SHUTDOWN = 3,		//!< Module is requesting ESPER shutdown
	ESPER_RESP_OUT_OF_RANGE = 4,	//!< Request is trying to access a resource out of range
	ESPER_RESP_BUFF_TOO_SMALL = 5,	//!< Request is trying to read/write using a buffer that is too small
	ESPER_RESP_WRITE_ONLY = 6, 		//!< Request is trying to read from a write-only resource
	ESPER_RESP_READ_ONLY = 7,		//!< Request is trying to write to a read-only resource
	ESPER_RESP_LOCKED = 8,			//!< Request is trying to access a resource that is locked
	ESPER_RESP_UNKNOWN_TYPE = 9,	//!< Request requested/sent an unknown type
	ESPER_RESP_TYPE_MISMATCH = 10,
	ESPER_RESP_NULL_PTR_PASSED = 11,
	ESPER_RESP_MID_NOT_FOUND = 12,	//!< Request is trying to access an MID that does not exist
	ESPER_RESP_VID_NOT_FOUND = 13,	//!< Request is trying to access an VID that does not exist
	ESPER_RESP_AID_NOT_FOUND = 14,	//!< Request is trying to access an AID that does not exist
	ESPER_RESP_BAD_DATA_FORMAT = 15,
	ESPER_RESP_REQUEST_TOO_LARGE = 16
} eESPERResponse;

//! @TODO: Sort storage out
typedef const void* (*StorageLoad)(tESPERMID mid, const char* key, void* ctx);
typedef const void* (*StorageSave)(tESPERMID mid, const char* key, void* ctx);

typedef void (*LogMessage)(ESPER_LOG_LEVEL log_level, const char* message);

struct _tESPERVar;

typedef uint8_t (*VarHandler)(tESPERMID mid, tESPERVID vid, struct _tESPERVar* var, eESPERRequest request, uint32_t offset, uint32_t num_elements, void* ctx);
typedef eESPERResponse (*ModuleHandler)(tESPERMID mid, tESPERGID gid, eESPERState state, void* ctx);

typedef struct {
	ModuleHandler ModuleHandler;
	StorageLoad Load;
	StorageSave Save;
	void* ctx;
} tESPERStorage;

typedef struct {
	ModuleHandler ModuleHandler;
	LogMessage Log;
	void* ctx;
} tESPERLogger;

typedef struct _tESPERAttrInfo {
	char key[ESPER_KEY_LEN];
	char name[ESPER_NAME_LEN];
	ESPER_TYPE type;
} tESPERAttrInfo;

typedef struct _tESPERVarInfo {
	char key[ESPER_KEY_LEN];
	ESPER_TYPE type;
	ESPER_OPTIONS options;
	ESPER_STATUS status;
	ESPER_TIMESTAMP last_modified;
	ESPER_WRITECOUNT write_count;
	uint32_t max_elements_per_request; // number of elements that can be stored in var data 
	uint32_t num_elements; // number of elements that can be accessed in var, may exceed var data size if using OPTION_WINDOW
	tESPERAID num_attrs;
} tESPERVarInfo;

typedef struct _tESPERModuleInfo {
	char key[ESPER_KEY_LEN];
	char name[ESPER_NAME_LEN];
	ESPER_TIMESTAMP last_modified;
	ESPER_WRITECOUNT write_count;
	tESPERVID num_vars;
	eESPERState state;
	tESPERGID group_id;
} tESPERModuleInfo;

typedef struct _tESPERNodeInfo {
	ESPER_TIMESTAMP last_modified;
	ESPER_WRITECOUNT write_count;
	uint32_t num_modules;
	uint32_t num_vars;
	uint32_t num_attrs;
	uint32_t max_modules;
	uint32_t max_vars;
	uint32_t max_attrs;
} tESPERNodeInfo;

typedef union {
	uint8_t  b;
	uint8_t  u8;
	uint16_t u16;
	uint32_t u32;
	uint64_t u64;
	int8_t   s8;
	int16_t  s16;
	int32_t  s32;
	int64_t  s64;
	float    f32;
	double   f64;
	char 	 str[ESPER_ATTR_LEN];
} uESPERData;

typedef struct _tESPERAttr {
	tESPERAttrInfo info;
	uESPERData data;
} tESPERAttr;

typedef struct _tESPERVar {
	tESPERVarInfo info;
	tESPERAttr* attrs;
	void* data; // pointer to data, allowed to be null
	volatile void* io;
	VarHandler Handler;
} tESPERVar;

typedef struct _tESPERModule {
	tESPERModuleInfo info;
	tESPERVar* vars;
	void* ctx;
	ModuleHandler Handler;
} tESPERModule;

typedef struct {
	char device[ESPER_NAME_LEN];
	uint32_t uptime;
	uint8_t debug_level;
} tESPERModuleSystem;

uint32_t esper_strcpy(char* to, const char* from, uint32_t maxlen);
void esper_log(uint8_t level, const char* file, const char* func, int32_t line, const char* msg, ...);

uint32_t ESPER_GetVersion(void);

tESPERMID ESPER_CreateModule(const char* key, const char* name, tESPERGID gid, ModuleHandler fnHandler, void* ctx);

tESPERVID ESPER_CreateVarNull (tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarBool (tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint8_t* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarASCII(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, char* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarUInt8 (tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint8_t*  data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarUInt16(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint16_t* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarUInt32(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint32_t* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarUInt64(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint64_t* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarSInt8 (tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int8_t*  data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarSInt16(tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int16_t* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarSInt32(tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int32_t* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarSInt64(tESPERMID mid, const char* key, ESPER_OPTIONS options, int32_t num_elements, int64_t* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarFloat32(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, float* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarFloat64(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, double* data, volatile void* io, VarHandler fnVarHandler);
tESPERVID ESPER_CreateVarRaw(tESPERMID mid, const char* key, ESPER_OPTIONS options, uint32_t num_elements, uint8_t*  data, volatile void* io, VarHandler fnVarHandler);


tESPERAID ESPER_CreateAttrNull(tESPERMID mid, tESPERVID vid, const char* key, const char* null);
tESPERAID ESPER_CreateAttrBool(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint8_t data);
tESPERAID ESPER_CreateAttrASCII(tESPERMID mid, tESPERVID vid, const char* key, const char* name, const char* data);
tESPERAID ESPER_CreateAttrUInt8(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint8_t data);
tESPERAID ESPER_CreateAttrUInt16(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint16_t data);
tESPERAID ESPER_CreateAttrUInt32(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint32_t data);
tESPERAID ESPER_CreateAttrUInt64(tESPERMID mid, tESPERVID vid, const char* key, const char* name, uint64_t data);
tESPERAID ESPER_CreateAttrSInt8(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int8_t data);
tESPERAID ESPER_CreateAttrSInt16(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int16_t data);
tESPERAID ESPER_CreateAttrSInt32(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int32_t data);
tESPERAID ESPER_CreateAttrSInt64(tESPERMID mid, tESPERVID vid, const char* key, const char* name, int64_t data);
tESPERAID ESPER_CreateAttrFloat32(tESPERMID mid, tESPERVID vid, const char* key, const char* name, float* data);
tESPERAID ESPER_CreateAttrFloat64(tESPERMID mid, tESPERVID vid, const char* key, const char* name, double* data);

eESPERResponse ESPER_WriteVarNull(tESPERMID mid, tESPERVID vid, uint32_t offset);
eESPERResponse ESPER_WriteVarBool(tESPERMID mid, tESPERVID vid, uint32_t offset, uint8_t data);
eESPERResponse ESPER_WriteVarASCII(tESPERMID mid, tESPERVID vid, uint32_t offset, char data);
eESPERResponse ESPER_WriteVarUInt8(tESPERMID mid, tESPERVID vid, uint32_t offset, uint8_t data);
eESPERResponse ESPER_WriteVarUInt16(tESPERMID mid, tESPERVID vid, uint32_t offset, uint16_t data);
eESPERResponse ESPER_WriteVarUInt32(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t data);
eESPERResponse ESPER_WriteVarUInt64(tESPERMID mid, tESPERVID vid, uint32_t offset, uint64_t data);
eESPERResponse ESPER_WriteVarSInt8(tESPERMID mid, tESPERVID vid, uint32_t offset, int8_t data);
eESPERResponse ESPER_WriteVarSInt16(tESPERMID mid, tESPERVID vid, uint32_t offset, int16_t data);
eESPERResponse ESPER_WriteVarSInt32(tESPERMID mid, tESPERVID vid, uint32_t offset, int32_t data);
eESPERResponse ESPER_WriteVarSInt64(tESPERMID mid, tESPERVID vid, uint32_t offset, int64_t data);
eESPERResponse ESPER_WriteVarFloat32(tESPERMID mid, tESPERVID vid, uint32_t offset, float data);
eESPERResponse ESPER_WriteVarFloat64(tESPERMID mid, tESPERVID vid, uint32_t offset, double data);
eESPERResponse ESPER_WriteVarRaw(tESPERMID mid, tESPERVID vid, uint32_t offset, uint8_t data);

eESPERResponse ESPER_WriteVarNullArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements);
eESPERResponse ESPER_WriteVarBoolArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint8_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarASCIIArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const char* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarUInt8Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint8_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarUInt16Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint16_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarUInt32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint32_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarUInt64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint64_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarSInt8Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int8_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarSInt16Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int16_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarSInt32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int32_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarSInt64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const int64_t* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarFloat32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const float* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarFloat64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const double* buff, uint32_t* buff_len);
eESPERResponse ESPER_WriteVarRawArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, const uint8_t* buff, uint32_t* buff_len);

void ESPER_ReadVarNull(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
uint8_t ESPER_ReadVarBool(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
char ESPER_ReadVarASCII(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
uint8_t ESPER_ReadVarUInt8(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
uint16_t ESPER_ReadVarUInt16(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
uint32_t ESPER_ReadVarUInt32(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
uint64_t ESPER_ReadVarUInt64(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
int8_t ESPER_ReadVarSInt8(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
int16_t ESPER_ReadVarSInt16(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
int32_t ESPER_ReadVarSInt32(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
int64_t ESPER_ReadVarSInt64(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
float ESPER_ReadVarFloat32(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
double ESPER_ReadVarFloat64(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);
uint8_t ESPER_ReadVarRaw(tESPERMID mid, tESPERVID vid, uint32_t offset, eESPERResponse* resp);


void ESPER_ReadVarNullArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, eESPERResponse* resp);
const uint8_t* ESPER_ReadVarBoolArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const char* ESPER_ReadVarASCIIArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const uint8_t* ESPER_ReadVarUInt8Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const uint16_t* ESPER_ReadVarUInt16Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const uint32_t* ESPER_ReadVarUInt32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const uint64_t* ESPER_ReadVarUInt64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const int8_t* ESPER_ReadVarSInt8Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const int16_t* ESPER_ReadVarSInt16Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const int32_t* ESPER_ReadVarSInt32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const int64_t* ESPER_ReadVarSInt64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const float* ESPER_ReadVarFloat32Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const double* ESPER_ReadVarFloat64Array(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);
const uint8_t* ESPER_ReadVarRawArray(tESPERMID mid, tESPERVID vid, uint32_t offset, uint32_t num_elements, uint32_t* buf_len, eESPERResponse* resp);

uint8_t ESPER_ReadAttrBool(tESPERMID mid, tESPERVID vid, tESPERAID aid,eESPERResponse* resp);
const char* ESPER_ReadAttrASCII(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
uint8_t ESPER_ReadAttrUInt8(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
uint16_t ESPER_ReadAttrUInt16(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
uint32_t ESPER_ReadAttrUInt32(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
uint64_t ESPER_ReadAttrUInt64(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
int8_t ESPER_ReadAttrSInt8(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
int16_t ESPER_ReadAttrSInt16(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
int32_t ESPER_ReadAttrSInt32(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
int64_t ESPER_ReadAttrSInt64(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
float ESPER_ReadAttrFloat32(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);
double ESPER_ReadAttrFloat64(tESPERMID mid, tESPERVID vid, tESPERAID aid, eESPERResponse* resp);

char* ESPER_GetResponseString(eESPERResponse resp);
char* ESPER_GetTypeString(ESPER_TYPE type);
uint32_t ESPER_GetTypeSize(ESPER_TYPE type);

eESPERResponse ESPER_Init(const char* name, tESPERModule* modules, tESPERVar* vars, tESPERAttr* attrs, uint32_t num_modules, uint32_t num_vars, uint32_t num_attrs, tESPERStorage* storage);
eESPERResponse ESPER_Start(void);
eESPERResponse ESPER_Update(void);
eESPERResponse ESPER_Stop(void);

// Force refresh of shadow IO and 'update on read' functions
void ESPER_RefreshNode(void);
void ESPER_RefreshModule(tESPERMID mid);
void ESPER_RefreshVar(tESPERMID mid, tESPERVID vid);
void ESPER_TouchVar(tESPERMID mid, tESPERVID vid);

volatile ESPER_TIMESTAMP ESPER_GetUptime(void);
uint32_t ESPER_GetNumModules(void);
uint32_t ESPER_GetNumModuleVars(tESPERMID mid);
const tESPERNodeInfo* ESPER_GetNodeInfo(tESPERNodeInfo* info, eESPERResponse* resp);
const tESPERModuleInfo* ESPER_GetModuleInfo(tESPERMID mid, tESPERModuleInfo* info, eESPERResponse* resp);
const tESPERVarInfo* ESPER_GetVarInfo(tESPERMID mid, tESPERVID vid, tESPERVarInfo* info, eESPERResponse* resp);
const tESPERAttrInfo* ESPER_GetAttrInfo(tESPERMID mid, tESPERVID vid, tESPERAID aid, tESPERAttrInfo* info, eESPERResponse* resp);

tESPERMID ESPER_GetModuleIdByKey(const char* key);
tESPERVID ESPER_GetVarIdByKey(tESPERMID mid, const char* key);
tESPERAID ESPER_GetAttrIdByKey(tESPERMID mid, tESPERVID vid, const char* key, tESPERAID idx);

const char* ESPER_GetDebugLevelStr(uint8_t level);

#ifdef __cplusplus
}
#endif

#endif /* ESPER_H_ */
//! @}
