// Header file for Altera EMIF On-Chip Debug functions
// Quartus Version: 17.0std

#include "sys/alt_stdio.h"
#include "io.h"
#include "alt_types.h"
#include <system.h>

extern alt_32 g_rank_shadow;

#define MAX_NUM_RANKS 4 
#define MAX_MEM_DATA_WIDTH 144 

#if (COMPILE_DDR3 || COMPILE_DDR4)
  #define MIN_DQ_PER_DQS 4 
#else
  #define MIN_DQ_PER_DQS 8 
#endif

#if COMPILE_QDRII
  #define MAX_DQ_PER_DQS 36 
#elif (COMPILE_QDRIV || COMPILE_RLDRAM3 || COMPILE_RLDRAM2)
  #define MAX_DQ_PER_DQS 18 
#else
  #define MAX_DQ_PER_DQS 8 
#endif

#define MAX_DQ_PER_READ_DQS   MAX_DQ_PER_DQS
#define MAX_DQ_PER_WRITE_DQS  MAX_DQ_PER_DQS

#define MAX_READ_DQS_WIDTH (MAX_MEM_DATA_WIDTH / MIN_DQ_PER_DQS)
#define MAX_WRITE_DQS_WIDTH (MAX_MEM_DATA_WIDTH / MIN_DQ_PER_DQS)

#define MAX_NUM_DM_PER_WRITE_GROUP 1

#ifndef MIN
  #define MIN(a, b) (((a) > (b)) ? (b) : (a))
#endif

#ifndef MAX
  #define MAX(a, b) (((a) > (b)) ? (a) : (b))
#endif

#ifndef NULL
  #define NULL 0 
#endif


#define MAX_NUM_MEM_INTERFACES 11
// ****************************************************************************
// TCL Commands
// ****************************************************************************
// The wait command
#define TCLDBG_CMD_WAIT_CMD 1000

// No operation command
#define TCLDBG_CMD_NOP 0

// Command response acknowledged
#define TCLDBG_CMD_RESPONSE_ACK 1

// Run memory calibration
//  command_parameters[0]: Interface ID
//  command_parameters[1]: Initialization mode (typically INIT_MODE_DYNAMIC_FULL_RECAL)
#define TCLDBG_RUN_MEM_CALIBRATE 5

// Mark all ranks as being valid for calibration
#define TCLDBG_MARK_ALL_RANKS_AS_VALID 17

// Mark a specific rank to be skipped for calibration
//  command_parameters[0]: Rank to skip
#define TCLDBG_MARK_RANK_AS_SKIP 18

// Run memory calibration in non-destructive mode
#define TCLDBG_RUN_MEM_CALIBRATE_NO_RESET 25

// Set the starting value of VREF IN for the next recalibration.
//  command_parameters[0]: VREF setting
#define TCLDBG_SET_VREF_IN 26

// Set the starting value of VREF OUT for the next recalibration.
//  command_parameters[0]: VREF setting
//  command_parameters[1]: VREF range
#define TCLDBG_SET_VREF_OUT 27

// Set the calibration steps to skip
//  command_parameters[0]: flags indicating steps to skip (ENUM_DBG_CALIB_SKIP)
#define TCLDBG_SET_SKIP_STEPS 30

// Issue OCT Calibration Command (valid for usermode OCT only)
#define TCLDBG_CALIBRATE_OCT 32

// ****************************************************************************
// TCL Command Status Codes
// ****************************************************************************
// Interface ready to accept commands
#define TCLDBG_TX_STATUS_CMD_READY 0

// Response not ready as command is running
#define TCLDBG_TX_STATUS_CMD_EXE 1

// Illegal command received
#define TCLDBG_TX_STATUS_ILLEGAL_CMD 2

// Response ready
#define TCLDBG_TX_STATUS_RESPONSE_READY 3

#define DEBUG_STATUS_PRINTF_ENABLED_BIT 0
#define DEBUG_STATUS_CALIBRATION_STARTED 1
#define DEBUG_STATUS_CALIBRATION_ENDED 2

#define DEBUG_REPORT_STATUS_REPORT_READY 0x00000001
#define DEBUG_REPORT_STATUS_REPORT_GEN_ENABLED 0x00000002
#define DEBUG_REPORT_VERSION 0x01000000
#define NUM_RANK_MASK_WORDS ((MAX_NUM_RANKS % 32) == 0 ? \
                             (MAX_NUM_RANKS/32) : (MAX_NUM_RANKS/32)+1)
#define NUM_GROUP_MASK_WORDS ((MAX_READ_DQS_WIDTH % 32) == 0 ? \
                              (MAX_READ_DQS_WIDTH/32) : (MAX_READ_DQS_WIDTH/32)+1)

#define COMMAND_PARAM_WORDS 4

// Data structures for EMIF Toolkit
// The values of left_edge and write_edge are offset values from the "setting"
// value.  That is, the delay setting corresponding to the left edge is
//  setting - left_edge
// and the delay setting for the right edge is
//  setting + right_edge

// Data of a typical delay setting together with left and right margins
typedef struct debug_cal_data_struct {
    alt_u16 setting;
    alt_8  left_edge;
    alt_8  right_edge;
} debug_cal_data_t;

#if COMPILE_MARGIN_REPORT
typedef struct debug_cal_margin_struct {
    alt_8  left_edge;
    alt_8  right_edge;
} debug_cal_margin_t;
#endif

typedef struct debug_cal_status_per_group_struct {
    alt_u16 error_stage;
    alt_u16 error_sub_stage;
} debug_cal_status_per_group_t;

typedef struct debug_summary_report_struct {
    alt_u32 data_size;                          
    alt_u32 report_flags;
    alt_u32 sequencer_signature;

    alt_u32 error_stage;
    alt_u32 error_group;
    alt_u32 error_code; 
    alt_u32 error_info; 

    alt_u32 cur_stage;
    alt_u32 cur_interface_idx;

    alt_u32 rank_mask_size;
    alt_u32 group_mask_size;

    alt_u32 active_ranks;
    alt_u32 active_groups;
    alt_u32 rank_mask[NUM_RANK_MASK_WORDS];
    alt_u32 group_mask[NUM_GROUP_MASK_WORDS];

    alt_u32 groups_attempted_calibration[NUM_GROUP_MASK_WORDS];

    alt_u8  in_out_rate;  
} debug_summary_report_t;

#if COMPILE_MARGIN_REPORT
  #define LIST_CAL_REPORT_DATA_MARGIN_REPORT(func) \
    func(cal_margin_dq_in,      debug_cal_margin_t, g_pt_NUM_DQ) \
    func(cal_margin_dm_dbi_in,  debug_cal_margin_t, g_pt_NUM_DM) \
    func(cal_margin_dq_out,     debug_cal_margin_t, g_pt_NUM_DQ) \
    func(cal_margin_dm_dbi_out, debug_cal_margin_t, g_pt_NUM_DM)
#else
  #define LIST_CAL_REPORT_DATA_MARGIN_REPORT(func)
#endif

#define LIST_CAL_REPORT_DATA(func) \
    func(cal_data_dq_in,        debug_cal_data_t,   g_pt_NUM_DQ) \
    func(cal_data_dq_out,       debug_cal_data_t,   g_pt_NUM_DQ) \
    func(cal_data_dm_dbi_in,    debug_cal_data_t,   g_pt_NUM_DM) \
    func(cal_data_dm_dbi_out,   debug_cal_data_t,   g_pt_NUM_DM) \
    func(cal_data_dqs_in,       debug_cal_data_t,   g_pt_NUM_DQS_RD) \
    func(cal_data_dqs_en,       debug_cal_data_t,   g_pt_NUM_DQS_RD) \
    func(cal_data_dqs_en_b,     debug_cal_data_t,   g_pt_NUM_DQS_RD) \
    func(cal_data_dqs_out,      debug_cal_data_t,   g_pt_NUM_DQS_WR) \
    func(vrefin,                debug_cal_data_t,   g_pt_NUM_DQS_RD) \
    func(vrefout,               debug_cal_data_t,   g_pt_NUM_DQS_WR) \
    func(cal_data_ca,           debug_cal_data_t,   mem_param->pt_NUM_AC_ROM_ENUMS) \
    LIST_CAL_REPORT_DATA_MARGIN_REPORT(func) \
    func(cal_status_per_group,  debug_cal_status_per_group_t, g_pt_NUM_DQS_RD) \
    func(vfifo,                 alt_u8,             g_pt_NUM_DQS_RD) \
    func(lfifo,                 alt_u8,             g_pt_NUM_DQS_RD) \

typedef struct debug_cal_report_struct {
    alt_u32 data_size;                         

    #define DECLARE_CAL_REPORT_DATA(name, type, size) type *name;

    LIST_CAL_REPORT_DATA(DECLARE_CAL_REPORT_DATA)

    #undef DECLARE_CAL_REPORT_DATA

    alt_u32 write_lat;                         
    alt_u32 read_lat;                          
} debug_cal_report_t;

typedef struct debug_data_struct {             
    alt_u32 data_size;                         
    alt_u32 status;                            

    alt_u32 requested_command;                 
    alt_u32 command_status;                    
    alt_u32 command_parameters[COMMAND_PARAM_WORDS];   

    debug_summary_report_t *mem_summary_report; 
    debug_cal_report_t *mem_cal_report;        
} debug_data_t;

extern debug_data_t *g_ptr_debug_data;
extern debug_cal_report_t *g_ptr_cal_report;
extern debug_summary_report_t *g_ptr_summary_report;
extern alt_u32 g_tcl_dbg_enabled;

#define DECLARE_EXTERN_CAL_REPORT_DATA(name, type, size) extern type *g_ptr_calrpt_##name;

LIST_CAL_REPORT_DATA(DECLARE_EXTERN_CAL_REPORT_DATA)

#undef DECLARE_EXTERN_CAL_REPORT_DATA

// Heap starting address. Since the global parameter table is at the beginning of the heap,
// this is also address of global parameter table.
#define G_HEAP_STARTING_ADDR           0x3800

typedef struct {
    alt_u32 pt_GLOBAL_PAR_VER;        
    alt_u32 pt_NIOS_C_VER;            
    alt_u32 pt_COLUMN_ID;             
    alt_u32 pt_NUM_IOPACKS;           
    alt_u32 pt_NIOS_CLK_FREQ_KHZ;     
    alt_u32 pt_PARAM_TABLE_SIZE;      
    alt_u32 pt_INTERFACE_PAR_PTRS[MAX_NUM_MEM_INTERFACES]; 
} global_param_t;

#define INTERFACE_PAR_PTRS_PHY_TYPE_HI 31
#define INTERFACE_PAR_PTRS_PHY_TYPE_LO 30

#define USER_INTERFACE_ID(mif_idx) (glob_param->pt_INTERFACE_PAR_PTRS[mif_idx] >> 16)


typedef enum {
    ODT_HIGH_ON_IDLE  = (1 << 0),
    ODT_HIGH_ON_READ  = (1 << 1),
    ODT_HIGH_ON_WRITE = (1 << 2),
    ODT_RESERVED      = (1 << 3) 
} ENUM_ODT_TABLE;

typedef struct {
    alt_u16 pt_IP_VER;                
    alt_u16 pt_INTERFACE_PAR_VER;     
    alt_u16 pt_DEBUG_DATA_PTR;        
    alt_u16 pt_USER_COMMAND_PTR;      
    alt_u8  pt_MEMORY_TYPE;           
    alt_u8  pt_DIMM_TYPE;             
    alt_u8  pt_CONTROLLER_TYPE;       
    alt_u8  pt_RESERVED;              
    alt_u32 pt_AFI_CLK_FREQ_KHZ;      
    alt_u8  pt_BURST_LEN;             
    alt_u8  pt_READ_LATENCY;          
    alt_u8  pt_WRITE_LATENCY;         
    alt_u8  pt_NUM_RANKS;             
    alt_u8  pt_NUM_DIMMS;             
    alt_u8  pt_NUM_DQS_WR;            
    alt_u8  pt_NUM_DQS_RD;            
    alt_u8  pt_NUM_DQ;                
    alt_u8  pt_NUM_DM;                
    alt_u8  pt_ADDR_WIDTH;            
    alt_u8  pt_BANK_WIDTH;            
    alt_u8  pt_CS_WIDTH;              
    alt_u8  pt_CKE_WIDTH;             
    alt_u8  pt_ODT_WIDTH;             
    alt_u8  pt_C_WIDTH;               
    alt_u8  pt_BANK_GROUP_WIDTH;      
    alt_u8  pt_ADDR_MIRROR;           
    alt_u8  pt_CK_WIDTH;              
    alt_u8  pt_CAL_DATA_SIZE;         
    alt_u8  pt_NUM_LRDIMM_CFG;        
    alt_u8  pt_NUM_AC_ROM_ENUMS;      
    alt_u8  pt_NUM_CENTERS;           
    alt_u8  pt_NUM_CA_LANES;          
    alt_u8  pt_NUM_DATA_LANES;        
    alt_u32 pt_ODT_TABLE_LO;          
    alt_u32 pt_ODT_TABLE_HI;          
    alt_u32 pt_CAL_CONFIG;            
    alt_u16 pt_DBG_CONFIG;            
    alt_u16 pt_CAL_DATA_PTR;          
    alt_u32 pt_DBG_SKIP_RANKS;        
    alt_u32 pt_DBG_SKIP_GROUPS;       
    alt_u32 pt_DBG_SKIP_STEPS;        
    alt_u8  pt_NUM_MR;                
    alt_u8  pt_NUM_DIMM_MR;           
    alt_u16 pt_TILE_ID_PTR;           
    alt_u16 pt_PIN_ADDR_PTR;          
    alt_u16 pt_MR_PTR;                
} mem_param_t;

// Initialization mode for sequencer
typedef enum {
    INIT_MODE_POWERUP = 0,
    INIT_MODE_DPD_ENTRY = 1,
    INIT_MODE_DYNAMIC_QUICK_RECAL = 2,
    // Full re-calibration. Mostly same as power up calibration. Sequencer does not have to reset.
    // Typical recalibration requests should use this option.
    INIT_MODE_DYNAMIC_FULL_RECAL = 3,
    INIT_MODE_PHY_RESET = 4,
    INIT_MODE_NO_INIT_PARAM_TABLE = 5,
} ENUM_INIT_MODE;

//  Custom simplified version of printf to avoid using stdio.h
//  which can take up too much code space
void uart_printf(char *format, ...) ;

//  Get the input delay of a DQ pin
//  Arguments:
//   dq_idx - DQ pin index
alt_32 get_dq_in_delay(alt_u32 dq_idx) ;

//  Get the input delay of a DQS A pin
//  Arguments:
//   dqs - DQS pin index
//   lane - lane within a DQS group (0 if not applicable)
alt_32 get_dqs_lane_in_delay(alt_u32 dqs, alt_u32 lane) ;

//  Get the input delay of a DQS pin
//  Arguments:
//   dqs - DQS pin index
alt_32 get_dqs_in_delay(alt_u32 dqs) ;

//  Get the input delay of a DQS B pin
//  Arguments:
//   dqs - DQS pin index
//   lane - lane within a DQS group (0 if not applicable)
alt_32 get_dqs_lane_in_b_delay(alt_u32 dqs, alt_u32 lane) ;

//  Get the DQS enable delay for a DQS group
//  Arguments:
//   dqs - DQS pin index
alt_32 get_dqs_en_delay(alt_u32 dqs) ;

//  Get the output delay of a DQ pin
//  Arguments:
//   dq_idx - DQ pin index
alt_32 get_final_dq_out_delay(alt_u32 dq_idx) ;

//  Get the output delay of a DQS pin
//  Arguments:
//   dqs - DQS pin index
alt_32 get_final_dqs_out_delay(alt_u32 dqs) ;

//  Get the output delay of a DM/DBI pin
//  Arguments:
//   dm - DM/DBI pin index
alt_32 get_final_dm_dbi_out_delay(alt_u32 dm) ;

//  Get the VFIFO latency for a DQS group
//  Arguments:
//   dqs - DQS pin index
alt_32 get_vfifo_latency(alt_u32 dqs) ;

//  Get the LFIFO latency for a DQS group
//  Arguments:
//   dqs - DQS pin index
alt_32 get_lfifo_latency(alt_u32 dqs) ;

//  Get the delay of a command/address pin
//  Arguments:
//   ca - CA pin index (see EMIF Toolkit report for pin index)
alt_32 get_ca_delay(alt_u32 ca_idx) ;

//  Set the input delay of a DQ pin
//  Arguments:
//   dq - DQ pin index
//   value - value of delay to set
void set_dq_in_delay(alt_u32 dq_idx, alt_32 delay) ;

//  Set the input delay of a DBI pin
//  Arguments:
//   dbi - DBI pin index
//   value - value of delay to set
void set_dbi_in_delay(alt_u32 dqs, alt_32 delay) ;

//  Set the input delay of a DQS B pin
//  Arguments:
//   dqs - DQS pin index
//   lane - lane within the DQS group
//   value - value of delay to set
void set_dqs_lane_in_b_delay(alt_u32 dqs, alt_u32 lane, alt_32 delay) ;

//  Set the input delay of a DQS A pin
//  Arguments:
//   dqs - DQS pin index
//   lane - lane within the DQS group
//   value - value of delay to set
void set_dqs_lane_in_a_delay(alt_u32 dqs, alt_u32 lane , alt_32 delay) ;

//  Set the input delay of DQS pins (all lanes)
//  Arguments:
//   dqs - DQS pin index
//   value - value of delay to set
void set_dqs_in_delay(alt_u32 dqs, alt_32 delay) ;

//  Set the DQS enable delay
//  Arguments:
//   dqs - DQS pin index
//   value - value of delay to set
void set_dqs_en_delay(alt_u32 dqs, alt_32 delay) ;

//  Set the output delay of a DQ pin
//  Arguments:
//   dq - DQ pin index
//   value - value of delay to set
void set_dq_out_delay(alt_u32 dq_idx, alt_32 delay) ;

//  Set the output delay of a DQS pin
//  Arguments:
//   dqs - DQS pin index
//   value - value of delay to set
void set_dqs_out_delay(alt_u32 dqs, alt_32 delay) ;

//  Set the output delay of a DM/DBI pin
//  Arguments:
//   dm - DM/DBI pin index
//   value - value of delay to set
void set_dm_dbi_out_delay(alt_u32 dm, alt_32 delay) ;

//  Set the VFIFO latency for a DQS group
//  Arguments:
//   dqs - DQS pin index
//   value - value of latency to set
void set_vfifo_latency(alt_u32 dqs, alt_32 latency) ;

//  Set the LFIFO latency for a DQS group
//  Arguments:
//   dqs - DQS pin index
//   value - value of latency to set
void set_lfifo_latency(alt_u32 dqs, alt_32 lfifo) ;

//  Set the output delay of a command/address pin
//  Arguments:
//   ca - CA pin index (see EMIF Toolkit report for pin index)
//   value - value of delay to set
void set_ca_delay(alt_u32 ca_idx, alt_32 delay) ;

//  Set global parameters for the selected memory interface
//  Arguments:
//   mem_idx: memory interface ID
void init_parameter_table(alt_u32 mem_idx) ;

//  Prints the contents of the global parameter table.
//  Arguments:
//   ptr - pointer to the global parameter table
void print_global_param(global_param_t *ptr) ;

//  Prints the contents of an EMIF parameter table.
//  Arguments:
//   ptr - pointer to the interface parameter table
void print_mem_param(mem_param_t *ptr) ;

//  Prints the top-level debug data structure.
//  Arguments:
//   ptr - pointer to the debug data structure
void print_debug_data(debug_data_t *ptr) ;

//  Prints the summary report.
//  Arguments:
//   ptr - pointer to the summary report
void print_summary_report(debug_summary_report_t *ptr) ;

//  Prints the calibration report.
//  Arguments:
//   ptr - pointer to the calibration report
void print_cal_report(debug_cal_report_t *ptr) ;

// Get the input delay of a DBI pin
// Arguments:
//  dbi_idx - DBI pin index
alt_32 get_dbi_in_delay(alt_u32 dbi_idx);
