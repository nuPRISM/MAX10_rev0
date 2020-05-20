#ifndef ___SIMPLE_DEBUG_H___
#define ___SIMPLE_DEBUG_H___

typedef enum {
	LDB_DEBUG_LEVEL_DONT_SHOW_ANY_MESSAGES = -1,
	LDB_DEBUG_LEVEL_NO_DEBUG_MESSAGES_JUST_ERROR_MESSAGES = 0,
	LDB_DEBUG_LEVEL_SHOW_WARNING_MESSAGES = 1,
	LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES = 2,
	LDB_DEBUG_LEVEL_SHOW_ALL_INFO_MESSAGES = 3,
	LDB_DEBUG_LEVEL_SHOW_LOW_LEVEL_DIAGNOSTIC_MESSAGES = 4
} ldb_debug_level_type;

#ifndef DEFAULT_LDB_DEBUG_LEVEL
#define DEFAULT_LDB_DEBUG_LEVEL (LDB_DEBUG_LEVEL_SHOW_IMPORTANT_INFO_MESSAGES)
#endif

#define debug_xprintf(level,...) do { if (level <= current_debug_level) { xprintf(__VA_ARGS__); }; } while (0)
#define debug_do(level,x) do { if (level <= current_debug_level) { x; }; } while (0)


#endif
