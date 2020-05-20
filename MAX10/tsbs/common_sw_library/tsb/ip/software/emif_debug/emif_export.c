typedef __builtin_va_list __gnuc_va_list;
typedef __gnuc_va_list va_list;
int alt_getchar();
int alt_putchar(int c);
int alt_putstr(const char* str);
void alt_printf(const char *fmt, ...);
typedef signed char alt_8;
typedef unsigned char alt_u8;
typedef signed short alt_16;
typedef unsigned short alt_u16;
typedef signed long alt_32;
typedef unsigned long alt_u32;
typedef long long alt_64;
typedef unsigned long long alt_u64;
typedef enum {
    DO_ROM_DQS_T,
    DO_ROM_DQS_C = DO_ROM_DQS_T + ((((144 / 4)) > ((144 / 4))) ? ((144 / 4)) : ((144 / 4))),
    DO_ROM_DM = DO_ROM_DQS_C + ((((144 / 4)) > ((144 / 4))) ? ((144 / 4)) : ((144 / 4))),
    DO_ROM_DQ = DO_ROM_DM + ((((144 / 4)) > ((144 / 4))) ? ((144 / 4)) : ((144 / 4))),
    NUM_DO_ROM_ENTRIES = DO_ROM_DQ + 144,
    DO_ROM_DQS_RD_T = DO_ROM_DQS_T,
    DO_ROM_DQS_RD_C = DO_ROM_DQS_RD_T + (((((144 / 4)) > ((144 / 4))) ? ((144 / 4)) : ((144 / 4))) / 2),
    DO_ROM_DQS_WR_T = DO_ROM_DQS_RD_C + (((((144 / 4)) > ((144 / 4))) ? ((144 / 4)) : ((144 / 4))) / 2),
    DO_ROM_DQS_WR_C = DO_ROM_DQS_WR_T + (((((144 / 4)) > ((144 / 4))) ? ((144 / 4)) : ((144 / 4))) / 2),
} ENUM_DO_ROM;
typedef enum {
    DDR3_AC_ROM_MR0 = 0,
    DDR3_AC_ROM_MR1 = 1,
    DDR3_AC_ROM_MR2 = 2,
    DDR3_AC_ROM_MR3 = 3,
    DDR4_AC_ROM_MR0 = 0,
    DDR4_AC_ROM_MR1 = 1,
    DDR4_AC_ROM_MR2 = 2,
    DDR4_AC_ROM_MR3 = 3,
    DDR4_AC_ROM_MR4 = 4,
    DDR4_AC_ROM_MR5 = 5,
    DDR4_AC_ROM_MR6 = 6,
    LPDDR3_AC_ROM_MR1 = 0,
    LPDDR3_AC_ROM_MR2 = 1,
    LPDDR3_AC_ROM_MR3 = 2,
    LPDDR3_AC_ROM_MR11 = 3,
    RLDRAM2_AC_ROM_MR0 = 0,
    RLDRAM3_AC_ROM_MR0 = 0,
    RLDRAM3_AC_ROM_MR1 = 1,
    RLDRAM3_AC_ROM_MR2 = 2,
    QDRIV_AC_ROM_MR0 = 0,
    QDRIV_AC_ROM_MR1 = 1,
    QDRIV_AC_ROM_MR2 = 2,
} ENUM_MR_INDEX;
typedef enum {
    DIMM_COMPONENT = 0,
    DIMM_UDIMM = 1,
    DIMM_RDIMM = 2,
    DIMM_SODIMM = 3,
    DIMM_LRDIMM = 4,
    DIMM_PINGPONG = 8,
    DIMM_PINGPONG_COMPONENT = DIMM_PINGPONG | DIMM_COMPONENT,
    DIMM_PINGPONG_UDIMM = DIMM_PINGPONG | DIMM_UDIMM,
    DIMM_PINGPONG_RDIMM = DIMM_PINGPONG | DIMM_RDIMM,
    DIMM_PINGPONG_SODIMM = DIMM_PINGPONG | DIMM_SODIMM,
    DIMM_PINGPONG_LRDIMM = DIMM_PINGPONG | DIMM_LRDIMM,
} ENUM_DIMM_TYPE;
typedef enum {
    CONTROLLER_HARD,
    CONTROLLER_SOFT,
} ENUM_CONTROLLER_TYPE;
typedef enum {
    CAL_ENABLE_POWERUP_CAL = (1 << 0),
    CAL_ENABLE_PHY_TRACKING = (1 << 1),
    CAL_ENABLE_TRACKING_MGR = (1 << 2),
    CAL_PRIORITY = (1 << 3),
    CAL_ENABLE_DYNAMIC_QUICK_RECAL = (1 << 6),
    CAL_ENABLE_DYNAMIC_FULL_RECAL = (1 << 7),
    CAL_ENABLE_NON_DESTRUCTIVE_RECAL = (1 << 8),
    CAL_DISABLE_ODT_TABLE = (1 << 9),
    CAL_USE_CSR_CA_DELAY = (1 << 10),
    CAL_COPY_HMC_TO_PT = (1 << 11),
    CAL_COPY_PT_to_HMC = (1 << 12),
    CAL_PERFORM_SKIP_CAL_CONFIG = (1 << 13),
    CAL_POST_CAL_DESKEW = (1 << 14),
    CAL_USE_STRESS_PATTERN = (1 << 15),
    CAL_MULTIRANK_DELAY_AVERAGING = (1 << 16),
    CAL_WARM_RESET_ENABLE = (1 << 17),
    CAL_MULTIRANK_RECAL_WITH_ACTUAL_SKEW = (1 << 18),
    CAL_USERMODE_OCT = (1 << 19),
    CAL_IS_HPS_EMIF = (1 << 20),
    CAL_FAST_SIM = (1 << 21),
    CAL_FULL_CAL_ON_RESET = (1 << 22),
    CAL_PERIODIC_OCT_RECAL = (1 << 23),
    CAL_SILICON_REV = (1 << 24),
} ENUM_CAL_CONFIG;
typedef enum {
    DBG_ENABLED = (1 << 0),
    DBG_DEBUG_IN_DEBUG_MODE = (1 << 16),
} ENUM_DBG_CONFIG;
extern const alt_u32 data_rom_init_dq_even[(32 / 4)];
extern const alt_u32 data_rom_init_dq_odd[(32 / 4)];
extern const alt_u32 data_rom_init_dm[(32 / 4)];
extern const alt_u8 data_rom_pattern_compact[9][32];
typedef enum {
    MEM_DDR3,
    MEM_DDR4,
    MEM_LPDDR3,
    MEM_RLDRAM3,
    MEM_RLDRAM2,
    MEM_QDRIV,
    MEM_QDRII,
    NUM_MEM_TYPES,
    MEM_NUMM = 0xFF
} ENUM_MEM_TYPE;
typedef enum {
    AC_ROM_DDR3_CKE_0,
    AC_ROM_DDR3_CKE_1,
    AC_ROM_DDR3_CKE_2,
    AC_ROM_DDR3_CKE_3,
    AC_ROM_DDR3_ODT_0,
    AC_ROM_DDR3_ODT_1,
    AC_ROM_DDR3_ODT_2,
    AC_ROM_DDR3_ODT_3,
    AC_ROM_DDR3_RESET,
    AC_ROM_DDR3_WE,
    AC_ROM_DDR3_CAS,
    AC_ROM_DDR3_RAS,
    AC_ROM_DDR3_CS_0,
    AC_ROM_DDR3_CS_1,
    AC_ROM_DDR3_CS_2,
    AC_ROM_DDR3_CS_3,
    AC_ROM_DDR3_BA_0,
    AC_ROM_DDR3_BA_1,
    AC_ROM_DDR3_BA_2,
    AC_ROM_DDR3_ADD_0,
    AC_ROM_DDR3_ADD_1,
    AC_ROM_DDR3_ADD_2,
    AC_ROM_DDR3_ADD_3,
    AC_ROM_DDR3_ADD_4,
    AC_ROM_DDR3_ADD_5,
    AC_ROM_DDR3_ADD_6,
    AC_ROM_DDR3_ADD_7,
    AC_ROM_DDR3_ADD_8,
    AC_ROM_DDR3_ADD_9,
    AC_ROM_DDR3_ADD_10,
    AC_ROM_DDR3_ADD_11,
    AC_ROM_DDR3_ADD_12,
    AC_ROM_DDR3_ADD_13,
    AC_ROM_DDR3_ADD_14,
    AC_ROM_DDR3_ADD_15,
    AC_ROM_DDR3_RM_0,
    AC_ROM_DDR3_RM_1,
    AC_ROM_DDR3_PAR_IN,
    REAL_AC_PIN_DDR3_NUM,
    AC_ROM_DDR3_RDATA_EN = REAL_AC_PIN_DDR3_NUM,
    AC_ROM_DDR3_MRNK_RD,
    AC_ROM_DDR3_WDATA_VALID,
    AC_ROM_DDR3_MRNK_WRT,
    AC_DDR3_NUM,
    AC_ROM_DDR3_ALERT0_N = REAL_AC_PIN_DDR3_NUM + 0,
    AC_ROM_DDR3_ALERT1_N = REAL_AC_PIN_DDR3_NUM + 1,
    AC_ROM_DDR3_CK0 = REAL_AC_PIN_DDR3_NUM + 2,
    AC_ROM_DDR3_CK0_N = REAL_AC_PIN_DDR3_NUM + 3,
    AC_ROM_DDR3_CK1 = REAL_AC_PIN_DDR3_NUM + 4,
    AC_ROM_DDR3_CK1_N = REAL_AC_PIN_DDR3_NUM + 5,
    AC_ROM_DDR3_CK2 = REAL_AC_PIN_DDR3_NUM + 6,
    AC_ROM_DDR3_CK2_N = REAL_AC_PIN_DDR3_NUM + 7,
    AC_ROM_DDR3_CK3 = REAL_AC_PIN_DDR3_NUM + 8,
    AC_ROM_DDR3_CK3_N = REAL_AC_PIN_DDR3_NUM + 9,
    AC_PIN_DDR3_NUM,
} ENUM_AC_ROM_DDR3;
typedef enum {
    AC_ROM_DDR4_CKE_0,
    AC_ROM_DDR4_CKE_1,
    AC_ROM_DDR4_CKE_2,
    AC_ROM_DDR4_CKE_3,
    AC_ROM_DDR4_ODT_0,
    AC_ROM_DDR4_ODT_1,
    AC_ROM_DDR4_ODT_2,
    AC_ROM_DDR4_ODT_3,
    AC_ROM_DDR4_RESET,
    AC_ROM_DDR4_ACT,
    AC_ROM_DDR4_CS_0,
    AC_ROM_DDR4_CS_1,
    AC_ROM_DDR4_CS_2,
    AC_ROM_DDR4_CS_3,
    AC_ROM_DDR4_C_0,
    AC_ROM_DDR4_C_1,
    AC_ROM_DDR4_C_2,
    AC_ROM_DDR4_BA_0,
    AC_ROM_DDR4_BA_1,
    AC_ROM_DDR4_BG_0,
    AC_ROM_DDR4_BG_1,
    AC_ROM_DDR4_ADD_0,
    AC_ROM_DDR4_ADD_1,
    AC_ROM_DDR4_ADD_2,
    AC_ROM_DDR4_ADD_3,
    AC_ROM_DDR4_ADD_4,
    AC_ROM_DDR4_ADD_5,
    AC_ROM_DDR4_ADD_6,
    AC_ROM_DDR4_ADD_7,
    AC_ROM_DDR4_ADD_8,
    AC_ROM_DDR4_ADD_9,
    AC_ROM_DDR4_ADD_10,
    AC_ROM_DDR4_ADD_11,
    AC_ROM_DDR4_ADD_12,
    AC_ROM_DDR4_ADD_13,
    AC_ROM_DDR4_ADD_14,
    AC_ROM_DDR4_ADD_15,
    AC_ROM_DDR4_ADD_16,
    AC_ROM_DDR4_ADD_17,
    AC_ROM_DDR4_ADD_18,
    AC_ROM_DDR4_ADD_19,
    AC_ROM_DDR4_PAR_IN,
    REAL_AC_PIN_DDR4_NUM,
    AC_ROM_DDR4_RDATA_EN = REAL_AC_PIN_DDR4_NUM,
    AC_ROM_DDR4_MRNK_RD,
    AC_ROM_DDR4_WDATA_VALID,
    AC_ROM_DDR4_MRNK_WRT,
    AC_DDR4_NUM,
    AC_ROM_DDR4_ALERT0_N = REAL_AC_PIN_DDR4_NUM + 0,
    AC_ROM_DDR4_ALERT1_N = REAL_AC_PIN_DDR4_NUM + 1,
    AC_ROM_DDR4_CK0 = REAL_AC_PIN_DDR4_NUM + 2,
    AC_ROM_DDR4_CK0_N = REAL_AC_PIN_DDR4_NUM + 3,
    AC_ROM_DDR4_CK1 = REAL_AC_PIN_DDR4_NUM + 4,
    AC_ROM_DDR4_CK1_N = REAL_AC_PIN_DDR4_NUM + 5,
    AC_ROM_DDR4_CK2 = REAL_AC_PIN_DDR4_NUM + 6,
    AC_ROM_DDR4_CK2_N = REAL_AC_PIN_DDR4_NUM + 7,
    AC_ROM_DDR4_CK3 = REAL_AC_PIN_DDR4_NUM + 8,
    AC_ROM_DDR4_CK3_N = REAL_AC_PIN_DDR4_NUM + 9,
    AC_PIN_DDR4_NUM,
} ENUM_AC_ROM_DDR4;
typedef enum {
    AC_ROM_LPDDR3_CKE_0,
    AC_ROM_LPDDR3_CKE_1,
    AC_ROM_LPDDR3_CKE_2,
    AC_ROM_LPDDR3_CKE_3,
    AC_ROM_LPDDR3_ODT_0,
    AC_ROM_LPDDR3_ODT_1,
    AC_ROM_LPDDR3_ODT_2,
    AC_ROM_LPDDR3_ODT_3,
    AC_ROM_LPDDR3_CS_0,
    AC_ROM_LPDDR3_CS_1,
    AC_ROM_LPDDR3_CS_2,
    AC_ROM_LPDDR3_CS_3,
    AC_ROM_LPDDR3_ADD_0,
    AC_ROM_LPDDR3_ADD_1,
    AC_ROM_LPDDR3_ADD_2,
    AC_ROM_LPDDR3_ADD_3,
    AC_ROM_LPDDR3_ADD_4,
    AC_ROM_LPDDR3_ADD_5,
    AC_ROM_LPDDR3_ADD_6,
    AC_ROM_LPDDR3_ADD_7,
    AC_ROM_LPDDR3_ADD_8,
    AC_ROM_LPDDR3_ADD_9,
    REAL_AC_PIN_LPDDR3_NUM,
    AC_ROM_LPDDR3_RDATA_EN = REAL_AC_PIN_LPDDR3_NUM,
    AC_ROM_LPDDR3_MRNK_RD,
    AC_ROM_LPDDR3_WDATA_VALID,
    AC_ROM_LPDDR3_MRNK_WRT,
    AC_LPDDR3_NUM,
    AC_ROM_LPDDR3_CK0 = REAL_AC_PIN_LPDDR3_NUM + 0,
    AC_ROM_LPDDR3_CK0_N = REAL_AC_PIN_LPDDR3_NUM + 1,
    AC_ROM_LPDDR3_CK1 = REAL_AC_PIN_LPDDR3_NUM + 2,
    AC_ROM_LPDDR3_CK1_N = REAL_AC_PIN_LPDDR3_NUM + 3,
    AC_ROM_LPDDR3_CK2 = REAL_AC_PIN_LPDDR3_NUM + 4,
    AC_ROM_LPDDR3_CK2_N = REAL_AC_PIN_LPDDR3_NUM + 5,
    AC_ROM_LPDDR3_CK3 = REAL_AC_PIN_LPDDR3_NUM + 6,
    AC_ROM_LPDDR3_CK3_N = REAL_AC_PIN_LPDDR3_NUM + 7,
    AC_PIN_LPDDR3_NUM,
} ENUM_AC_ROM_LPDDR3;
typedef enum {
    AC_ROM_RLDRAM3_RESET,
    AC_ROM_RLDRAM3_WE,
    AC_ROM_RLDRAM3_REF,
    AC_ROM_RLDRAM3_CS_0,
    AC_ROM_RLDRAM3_CS_1,
    AC_ROM_RLDRAM3_CS_2,
    AC_ROM_RLDRAM3_CS_3,
    AC_ROM_RLDRAM3_BA_0,
    AC_ROM_RLDRAM3_BA_1,
    AC_ROM_RLDRAM3_BA_2,
    AC_ROM_RLDRAM3_BA_3,
    AC_ROM_RLDRAM3_ADD_0,
    AC_ROM_RLDRAM3_ADD_1,
    AC_ROM_RLDRAM3_ADD_2,
    AC_ROM_RLDRAM3_ADD_3,
    AC_ROM_RLDRAM3_ADD_4,
    AC_ROM_RLDRAM3_ADD_5,
    AC_ROM_RLDRAM3_ADD_6,
    AC_ROM_RLDRAM3_ADD_7,
    AC_ROM_RLDRAM3_ADD_8,
    AC_ROM_RLDRAM3_ADD_9,
    AC_ROM_RLDRAM3_ADD_10,
    AC_ROM_RLDRAM3_ADD_11,
    AC_ROM_RLDRAM3_ADD_12,
    AC_ROM_RLDRAM3_ADD_13,
    AC_ROM_RLDRAM3_ADD_14,
    AC_ROM_RLDRAM3_ADD_15,
    AC_ROM_RLDRAM3_ADD_16,
    AC_ROM_RLDRAM3_ADD_17,
    AC_ROM_RLDRAM3_ADD_18,
    AC_ROM_RLDRAM3_ADD_19,
    AC_ROM_RLDRAM3_ADD_20,
    REAL_AC_PIN_RLDRAM3_NUM,
    AC_ROM_RLDRAM3_RDATA_EN = REAL_AC_PIN_RLDRAM3_NUM,
    AC_ROM_RLDRAM3_MRNK_RD,
    AC_ROM_RLDRAM3_WDATA_VALID,
    AC_ROM_RLDRAM3_MRNK_WRT,
    AC_RLDRAM3_NUM,
    AC_ROM_RLDRAM3_CK = REAL_AC_PIN_RLDRAM3_NUM + 0,
    AC_ROM_RLDRAM3_CK_N = REAL_AC_PIN_RLDRAM3_NUM + 1,
    AC_PIN_RLDRAM3_NUM,
} ENUM_AC_ROM_RLDRAM3;
typedef enum {
    AC_ROM_RLDRAM2_WE,
    AC_ROM_RLDRAM2_REF,
    AC_ROM_RLDRAM2_CS,
    AC_ROM_RLDRAM2_BA_0,
    AC_ROM_RLDRAM2_BA_1,
    AC_ROM_RLDRAM2_BA_2,
    AC_ROM_RLDRAM2_ADD_0,
    AC_ROM_RLDRAM2_ADD_1,
    AC_ROM_RLDRAM2_ADD_2,
    AC_ROM_RLDRAM2_ADD_3,
    AC_ROM_RLDRAM2_ADD_4,
    AC_ROM_RLDRAM2_ADD_5,
    AC_ROM_RLDRAM2_ADD_6,
    AC_ROM_RLDRAM2_ADD_7,
    AC_ROM_RLDRAM2_ADD_8,
    AC_ROM_RLDRAM2_ADD_9,
    AC_ROM_RLDRAM2_ADD_10,
    AC_ROM_RLDRAM2_ADD_11,
    AC_ROM_RLDRAM2_ADD_12,
    AC_ROM_RLDRAM2_ADD_13,
    AC_ROM_RLDRAM2_ADD_14,
    AC_ROM_RLDRAM2_ADD_15,
    AC_ROM_RLDRAM2_ADD_16,
    AC_ROM_RLDRAM2_ADD_17,
    AC_ROM_RLDRAM2_ADD_18,
    AC_ROM_RLDRAM2_ADD_19,
    AC_ROM_RLDRAM2_ADD_20,
    AC_ROM_RLDRAM2_ADD_21,
    AC_ROM_RLDRAM2_ADD_22,
    REAL_AC_PIN_RLDRAM2_NUM,
    AC_ROM_RLDRAM2_RDATA_EN = REAL_AC_PIN_RLDRAM2_NUM,
    AC_ROM_RLDRAM2_MRNK_RD,
    AC_ROM_RLDRAM2_WDATA_VALID,
    AC_ROM_RLDRAM2_MRNK_WRT,
    AC_RLDRAM2_NUM,
    AC_ROM_RLDRAM2_CK = REAL_AC_PIN_RLDRAM2_NUM + 0,
    AC_ROM_RLDRAM2_CK_N = REAL_AC_PIN_RLDRAM2_NUM + 1,
    AC_PIN_RLDRAM2_NUM,
} ENUM_AC_ROM_RLDRAM2;
typedef enum {
    AC_ROM_QDRIV_RESET,
    AC_ROM_QDRIV_CFG,
    AC_ROM_QDRIV_LDA,
    AC_ROM_QDRIV_LDB,
    AC_ROM_QDRIV_RWA,
    AC_ROM_QDRIV_RWB,
    AC_ROM_QDRIV_AINV,
    AC_ROM_QDRIV_AP,
    AC_ROM_QDRIV_ADD_0,
    AC_ROM_QDRIV_ADD_1,
    AC_ROM_QDRIV_ADD_2,
    AC_ROM_QDRIV_ADD_3,
    AC_ROM_QDRIV_ADD_4,
    AC_ROM_QDRIV_ADD_5,
    AC_ROM_QDRIV_ADD_6,
    AC_ROM_QDRIV_ADD_7,
    AC_ROM_QDRIV_ADD_8,
    AC_ROM_QDRIV_ADD_9,
    AC_ROM_QDRIV_ADD_10,
    AC_ROM_QDRIV_ADD_11,
    AC_ROM_QDRIV_ADD_12,
    AC_ROM_QDRIV_ADD_13,
    AC_ROM_QDRIV_ADD_14,
    AC_ROM_QDRIV_ADD_15,
    AC_ROM_QDRIV_ADD_16,
    AC_ROM_QDRIV_ADD_17,
    AC_ROM_QDRIV_ADD_18,
    AC_ROM_QDRIV_ADD_19,
    AC_ROM_QDRIV_ADD_20,
    AC_ROM_QDRIV_ADD_21,
    AC_ROM_QDRIV_ADD_22,
    AC_ROM_QDRIV_ADD_23,
    AC_ROM_QDRIV_ADD_24,
    AC_ROM_QDRIV_LBK_0,
    AC_ROM_QDRIV_LBK_1,
    REAL_AC_PIN_QDRIV_NUM,
    AC_ROM_QDRIV_RDATA_EN = REAL_AC_PIN_QDRIV_NUM,
    AC_ROM_QDRIV_MRNK_RD,
    AC_ROM_QDRIV_WDATA_VALID,
    AC_ROM_QDRIV_MRNK_WRT,
    AC_QDRIV_NUM,
    AC_ROM_QDRIV_PE = REAL_AC_PIN_QDRIV_NUM + 0,
    AC_ROM_QDRIV_CK = REAL_AC_PIN_QDRIV_NUM + 1,
    AC_ROM_QDRIV_CK_N = REAL_AC_PIN_QDRIV_NUM + 2,
    AC_PIN_QDRIV_NUM,
} ENUM_AC_ROM_QDRIV;
typedef enum {
    AC_ROM_QDRII_DOFF,
    AC_ROM_QDRII_WPS,
    AC_ROM_QDRII_RPS,
    AC_ROM_QDRII_ADD_0,
    AC_ROM_QDRII_ADD_1,
    AC_ROM_QDRII_ADD_2,
    AC_ROM_QDRII_ADD_3,
    AC_ROM_QDRII_ADD_4,
    AC_ROM_QDRII_ADD_5,
    AC_ROM_QDRII_ADD_6,
    AC_ROM_QDRII_ADD_7,
    AC_ROM_QDRII_ADD_8,
    AC_ROM_QDRII_ADD_9,
    AC_ROM_QDRII_ADD_10,
    AC_ROM_QDRII_ADD_11,
    AC_ROM_QDRII_ADD_12,
    AC_ROM_QDRII_ADD_13,
    AC_ROM_QDRII_ADD_14,
    AC_ROM_QDRII_ADD_15,
    AC_ROM_QDRII_ADD_16,
    AC_ROM_QDRII_ADD_17,
    AC_ROM_QDRII_ADD_18,
    AC_ROM_QDRII_ADD_19,
    AC_ROM_QDRII_ADD_20,
    AC_ROM_QDRII_ADD_21,
    AC_ROM_QDRII_ADD_22,
    REAL_AC_PIN_QDRII_NUM,
    AC_ROM_QDRII_RDATA_EN = REAL_AC_PIN_QDRII_NUM,
    AC_ROM_QDRII_MRNK_RD,
    AC_ROM_QDRII_WDATA_VALID,
    AC_ROM_QDRII_MRNK_WRT,
    AC_QDRII_NUM,
    AC_PIN_QDRII_NUM = REAL_AC_PIN_QDRII_NUM,
} ENUM_AC_ROM_QDRII;
extern const alt_u32 ac_rom_word_code_book[];
extern const alt_u8 ac_rom_code_book[];
extern const alt_u16 *ac_rom_init_cal_main[NUM_MEM_TYPES];
extern const alt_u32 ac_rom_size_cal_main[NUM_MEM_TYPES];
extern const alt_u8 real_ac_pin_num[NUM_MEM_TYPES];
extern const alt_u16 *inst_rom_init_cal_main[NUM_MEM_TYPES];
extern const alt_u32 inst_rom_size_cal_main[NUM_MEM_TYPES];
typedef enum {
    AC_BUS_BA,
    AC_BUS_ADD,
    AC_BUS_BG,
    AC_BUS_CS,
    AC_BUS_C,
    AC_BUS_ODT,
    AC_BUS_CKE,
    AC_BUS_RM,
    NUM_AC_BUSES
} ENUM_AC_BUS;
extern const alt_u8 ac_idx[NUM_MEM_TYPES][NUM_AC_BUSES];
extern const alt_u8 ac_width[NUM_MEM_TYPES][NUM_AC_BUSES];
typedef enum {
    DATA_PIN_MAP_DQ_ENCODING_INCREMENT = 0,
    DATA_PIN_MAP_DQ_ENCODING_DECREMENT = 1
} ENUM_DATA_PIN_MAP_DQ_ENCODING;
typedef struct {
    alt_u32 pt_GLOBAL_PAR_VER;
    alt_u32 pt_NIOS_C_VER;
    alt_u32 pt_COLUMN_ID;
    alt_u32 pt_NUM_IOPACKS;
    alt_u32 pt_NIOS_CLK_FREQ_KHZ;
    alt_u32 pt_PARAM_TABLE_SIZE;
    alt_u32 pt_INTERFACE_PAR_PTRS[11];
} global_param_t;
typedef enum {
    ODT_HIGH_ON_IDLE = (1 << 0),
    ODT_HIGH_ON_READ = (1 << 1),
    ODT_HIGH_ON_WRITE = (1 << 2),
    ODT_RESERVED = (1 << 3)
} ENUM_ODT_TABLE;
typedef struct {
    alt_u16 pt_IP_VER;
    alt_u16 pt_INTERFACE_PAR_VER;
    alt_u16 pt_DEBUG_DATA_PTR;
    alt_u16 pt_USER_COMMAND_PTR;
    alt_u8 pt_MEMORY_TYPE;
    alt_u8 pt_DIMM_TYPE;
    alt_u8 pt_CONTROLLER_TYPE;
    alt_u8 pt_RESERVED;
    alt_u32 pt_AFI_CLK_FREQ_KHZ;
    alt_u8 pt_BURST_LEN;
    alt_u8 pt_READ_LATENCY;
    alt_u8 pt_WRITE_LATENCY;
    alt_u8 pt_NUM_RANKS;
    alt_u8 pt_NUM_DIMMS;
    alt_u8 pt_NUM_DQS_WR;
    alt_u8 pt_NUM_DQS_RD;
    alt_u8 pt_NUM_DQ;
    alt_u8 pt_NUM_DM;
    alt_u8 pt_ADDR_WIDTH;
    alt_u8 pt_BANK_WIDTH;
    alt_u8 pt_CS_WIDTH;
    alt_u8 pt_CKE_WIDTH;
    alt_u8 pt_ODT_WIDTH;
    alt_u8 pt_C_WIDTH;
    alt_u8 pt_BANK_GROUP_WIDTH;
    alt_u8 pt_ADDR_MIRROR;
    alt_u8 pt_CK_WIDTH;
    alt_u8 pt_CAL_DATA_SIZE;
    alt_u8 pt_NUM_LRDIMM_CFG;
    alt_u8 pt_NUM_AC_ROM_ENUMS;
    alt_u8 pt_NUM_CENTERS;
    alt_u8 pt_NUM_CA_LANES;
    alt_u8 pt_NUM_DATA_LANES;
    alt_u32 pt_ODT_TABLE_LO;
    alt_u32 pt_ODT_TABLE_HI;
    alt_u32 pt_CAL_CONFIG;
    alt_u16 pt_DBG_CONFIG;
    alt_u16 pt_CAL_DATA_PTR;
    alt_u32 pt_DBG_SKIP_RANKS;
    alt_u32 pt_DBG_SKIP_GROUPS;
    alt_u32 pt_DBG_SKIP_STEPS;
    alt_u8 pt_NUM_MR;
    alt_u8 pt_NUM_DIMM_MR;
    alt_u16 pt_TILE_ID_PTR;
    alt_u16 pt_PIN_ADDR_PTR;
    alt_u16 pt_MR_PTR;
} mem_param_t;
extern global_param_t *glob_param;
extern mem_param_t *mem_param;
typedef enum {
    EC_SUCCESS = 0,
    EC_FAIL = (1 << 0),
    EC_WL_UNDERFLOW = (1 << 1),
    EC_CMD_UNDERFLOW = (1 << 2),
} ENUM_CAL_ERROR_CODE;
typedef enum {
    INIT_MODE_POWERUP = 0,
    INIT_MODE_DPD_ENTRY = 1,
    INIT_MODE_DYNAMIC_QUICK_RECAL = 2,
    INIT_MODE_DYNAMIC_FULL_RECAL = 3,
    INIT_MODE_PHY_RESET = 4,
    INIT_MODE_NO_INIT_PARAM_TABLE = 5,
} ENUM_INIT_MODE;
extern void init_user_cal_req(void);
extern ENUM_CAL_ERROR_CODE run_mem_calibrate(ENUM_INIT_MODE init_mode, alt_u32 skip_reset);
extern alt_u32 util_malloc(const alt_u32 size_in_words, alt_u32 **dest);
extern ENUM_CAL_ERROR_CODE mem_cal_main(alt_u32 mem_idx, ENUM_INIT_MODE init_mode, alt_u32 skip_reset);
extern void util_init_array(alt_u32 *ary, alt_u32 size, alt_u32 val);
extern alt_u8 * get_global_param_offs(alt_u32 byte_offset);
extern mem_param_t * get_mem_param(alt_u32 mem_idx);
extern alt_u32 mem_interface_exists(alt_u32 mem_idx);
extern void wait_oct_ready(void);
extern alt_u32 g_starting_vrefin;
extern alt_u32 g_starting_vrefout;
extern alt_u32 g_addr_io_center_base;
extern alt_u32 g_starting_vrefout_range;
extern alt_u32 g_skip_steps;
typedef enum {MALLOC_SET_RESET_POINT, DO_MALLOC_RESET} ENUM_MALLOC_RESET_MODE;
extern void util_malloc_reset(ENUM_MALLOC_RESET_MODE malloc_reset_mode);
alt_u32 g_debug_toolkit_connected;
extern alt_32 g_rank_shadow;
extern alt_32 g_out_delay_min;
extern alt_32 g_out_delay_max;
extern alt_32 g_in_rate;
extern alt_32 g_out_rate;
extern alt_u32 g_num_dm_per_dqs_write;
extern alt_u32 g_pt_MEMORY_TYPE;
extern alt_u32 g_pt_DIMM_TYPE;
extern alt_u32 g_pt_CONTROLLER_TYPE;
extern alt_u32 g_pt_AFI_RATE_RATIO;
extern alt_u32 g_pt_AFI_CLK_FREQ;
extern alt_u32 g_pt_NIOS_CLK_FREQ;
extern alt_u32 g_pt_BURST_LEN;
extern alt_u32 g_pt_READ_LATENCY;
extern alt_u32 g_pt_WRITE_LATENCY;
extern alt_u32 g_pt_NUM_RANKS;
extern alt_u32 g_pt_NUM_DIMMS;
extern alt_u32 g_pt_NUM_DQS_WR;
extern alt_u32 g_pt_NUM_DQS_RD;
extern alt_u32 g_pt_NUM_DQ;
extern alt_u32 g_pt_NUM_DM;
extern alt_u32 g_pt_ADDR_WIDTH;
extern alt_u32 g_pt_BANK_WIDTH;
extern alt_u32 g_pt_CS_WIDTH;
extern alt_u32 g_pt_CKE_WIDTH;
extern alt_u32 g_pt_ODT_WIDTH;
extern alt_u32 g_pt_ADDR_MIRROR;
extern alt_u32 g_pt_NUM_CENTERS;
extern alt_u32 g_pt_NUM_CA_LANES;
extern alt_u32 g_pt_NUM_DATA_LANES;
typedef enum {
    CAL_STAGE_NIL = 0,
    CAL_STAGE_CA_LEVEL = 1,
    CAL_STAGE_CA_DESKEW = 2,
    CAL_STAGE_DQS_EN = 3,
    CAL_STAGE_READ_DESKEW = 4,
    CAL_STAGE_WRITE_LEVEL = 5,
    CAL_STAGE_WRITE_DESKEW = 6,
    CAL_STAGE_LFIFO = 7,
    CAL_STAGE_CA_RANK_CENTER = 8,
    CAL_STAGE_VREF_IN = 9,
    CAL_STAGE_VREF_OUT = 10,
    CAL_STAGE_MARGINING = 11,
    CAL_STAGE_WRITE_LEVEL_EDGE = CAL_STAGE_WRITE_LEVEL | (1 << 16),
    CAL_STAGE_WRITE_LEVEL_CLOCK = CAL_STAGE_WRITE_LEVEL | (2 << 16),
    CAL_STAGE_WRITE_DESKEW_DM_CENTER = CAL_STAGE_WRITE_DESKEW | (1 << 16),
    CAL_STAGE_MARGINING_DQ = CAL_STAGE_MARGINING | (1 << 16),
    CAL_STAGE_MARGINING_DM = CAL_STAGE_MARGINING | (2 << 16),
} ENUM_CAL_STAGE;
typedef enum {
    CAL_ERR_SUCCESS = 0,
    CAL_ERR_L0_CALIBRATION_FAILED = 1,
    CAL_ERR_L0_MALLOC = 2,
    CAL_ERR_L0_RIGHT_EDGE_NOT_FOUND = 11,
    CAL_ERR_L0_HARDWARE_TIMEOUT = 12,
    CAL_ERR_L0_REFRESH_MISSED = 13,
    CAL_ERR_L0_BAD_LOCK_SPEED = 14,
    CAL_ERR_L0_RANK_SKEW_TOO_LARGE = 15,
    CAL_ERR_L1_CUSTOMER_VISIBLE_BOUNDARY = 150,
    CAL_ERR_L1_BAD_PARAMETER = 150,
    CAL_ERR_L1_BAD_ARGUMENT = 151,
    CAL_ERR_L1_BAD_CALCULATION = 153,
    CAL_ERR_L1_BAD_HARDWARE_STATE = 154,
    CAL_ERR_L1_PASSING_WINDOW_NOT_FOUND = 155,
    CAL_ERR_L2_ADVANCED_DEVELOPER_BOUNDARY = 200,
    CAL_ERR_L2_INTERNAL = 200,
    CAL_ERR_L2_BAD_PARAMETER = 201,
    CAL_ERR_L2_BAD_ARGUMENT = 202,
    CAL_ERR_L2_UNEXPECTED_ENTRY = 203,
    CAL_ERR_L2_BAD_CALCULATION = 204,
    CAL_ERR_L2_BAD_CONSTANT = 210,
    CAL_ERR_L2_UNEXPECTED_CODE_STATE = 211,
    CAL_ERR_L2_MALLOC = 211,
    CAL_ERR_L2_INTERNAL_TEST_FAILED = 212,
} ENUM_CAL_ERR;
typedef enum {
    CALIB_SKIP_DQS_ENA = (1 << 0),
    CALIB_SKIP_READ_DESKEW = (1 << 1),
    CALIB_SKIP_LFIFO = (1 << 2),
    CALIB_SKIP_WRITE_LEVEL = (1 << 3),
    CALIB_SKIP_WRITE_DESKEW = (1 << 4),
    CALIB_SKIP_CA_LEVEL = (1 << 5),
    CALIB_SKIP_CA_DESKEW = (1 << 6),
    CALIB_SKIP_DCD_CAL = (1 << 13),
    CALIB_SKIP_VREFIN_CAL = (1 << 14),
    CALIB_SKIP_VREFOUT_CAL = (1 << 15),
    CALIB_SKIP_DELAY_LOOPS = (1 << 8),
    CALIB_SKIP_DELAY_SWEEPS = (1 << 9),
    CALIB_SKIP_FAILED_STEPS = (1 << 10),
    CALIB_SKIP_DQ_MSB = (1 << 11),
    CALIB_FAST_DELAY_STEPPING= (1 << 12),
    CALIB_SKIP_ALL = CALIB_SKIP_DQS_ENA |
                               CALIB_SKIP_READ_DESKEW |
                               CALIB_SKIP_LFIFO |
                               CALIB_SKIP_WRITE_LEVEL |
                               CALIB_SKIP_WRITE_DESKEW |
                               CALIB_SKIP_CA_LEVEL |
                               CALIB_SKIP_CA_DESKEW,
    CALIB_SIM_SPEED_STEPS = CALIB_SKIP_DELAY_LOOPS |
                               CALIB_SKIP_DELAY_SWEEPS |
                               CALIB_SKIP_FAILED_STEPS |
                               CALIB_SKIP_DQ_MSB |
                               CALIB_FAST_DELAY_STEPPING,
    CALIB_SIM_MODE_FULL = CALIB_SKIP_DELAY_LOOPS |
                               CALIB_SKIP_FAILED_STEPS,
    CALIB_SIM_MODE_QUICK = CALIB_SKIP_CA_LEVEL |
                               CALIB_SKIP_CA_DESKEW |
                               CALIB_SKIP_WRITE_DESKEW |
                               CALIB_SIM_SPEED_STEPS,
    CALIB_SIM_MODE_SKIP = CALIB_SKIP_ALL |
                               CALIB_SIM_SPEED_STEPS,
} ENUM_DBG_CALIB_SKIP;
typedef struct debug_cal_data_struct {
    alt_u16 setting;
    alt_8 left_edge;
    alt_8 right_edge;
} debug_cal_data_t;
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
    alt_u32 rank_mask[((4 % 32) == 0 ? (4/32) : (4/32)+1)];
    alt_u32 group_mask[(((144 / 4) % 32) == 0 ? ((144 / 4)/32) : ((144 / 4)/32)+1)];
    alt_u32 groups_attempted_calibration[(((144 / 4) % 32) == 0 ? ((144 / 4)/32) : ((144 / 4)/32)+1)];
    alt_u8 in_out_rate;
} debug_summary_report_t;
typedef struct debug_cal_report_struct {
    alt_u32 data_size;
    debug_cal_data_t *cal_data_dq_in; debug_cal_data_t *cal_data_dq_out; debug_cal_data_t *cal_data_dm_dbi_in; debug_cal_data_t *cal_data_dm_dbi_out; debug_cal_data_t *cal_data_dqs_in; debug_cal_data_t *cal_data_dqs_en; debug_cal_data_t *cal_data_dqs_en_b; debug_cal_data_t *cal_data_dqs_out; debug_cal_data_t *vrefin; debug_cal_data_t *vrefout; debug_cal_data_t *cal_data_ca; debug_cal_status_per_group_t *cal_status_per_group; alt_u8 *vfifo; alt_u8 *lfifo;
    alt_u32 write_lat;
    alt_u32 read_lat;
} debug_cal_report_t;
typedef struct debug_data_struct {
    alt_u32 data_size;
    alt_u32 status;
    alt_u32 requested_command;
    alt_u32 command_status;
    alt_u32 command_parameters[4];
    debug_summary_report_t *mem_summary_report;
    debug_cal_report_t *mem_cal_report;
} debug_data_t;
extern debug_data_t *g_ptr_debug_data;
extern debug_cal_report_t *g_ptr_cal_report;
extern debug_summary_report_t *g_ptr_summary_report;
extern alt_u32 g_tcl_dbg_enabled;
extern debug_cal_data_t *g_ptr_calrpt_cal_data_dq_in; extern debug_cal_data_t *g_ptr_calrpt_cal_data_dq_out; extern debug_cal_data_t *g_ptr_calrpt_cal_data_dm_dbi_in; extern debug_cal_data_t *g_ptr_calrpt_cal_data_dm_dbi_out; extern debug_cal_data_t *g_ptr_calrpt_cal_data_dqs_in; extern debug_cal_data_t *g_ptr_calrpt_cal_data_dqs_en; extern debug_cal_data_t *g_ptr_calrpt_cal_data_dqs_en_b; extern debug_cal_data_t *g_ptr_calrpt_cal_data_dqs_out; extern debug_cal_data_t *g_ptr_calrpt_vrefin; extern debug_cal_data_t *g_ptr_calrpt_vrefout; extern debug_cal_data_t *g_ptr_calrpt_cal_data_ca; extern debug_cal_status_per_group_t *g_ptr_calrpt_cal_status_per_group; extern alt_u8 *g_ptr_calrpt_vfifo; extern alt_u8 *g_ptr_calrpt_lfifo;
extern void tclrpt_init(void)__attribute__((section(".soft_m20k.txt")));
extern void tclrpt_init_interface(void)__attribute__((section(".soft_m20k.txt")));
extern void tclrpt_wrap_up_interface(void)__attribute__((section(".soft_m20k.txt")));
extern void tclrpt_enable_report(alt_u32 en)__attribute__((section(".soft_m20k.txt")));
extern void tclrpt_loop(void)__attribute__((section(".soft_m20k.txt")));
    static void uart_puts(char *str) {
        int i = 0;
        while (str[i] != '\0') {
            alt_putchar(str[i]);
            i++;
        }
    }
    static alt_u32 uart_puth(alt_32 dont_put_zero, alt_u32 i) {
        static const char hex[16] = {'0', '1', '2', '3', '4', '5', '6', '7',
                                     '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        i = i & 15;
        if (i != 0 || !dont_put_zero) {
            alt_putchar(hex[i]);
            return 0;
        } else {
            return 1;
        }
    }
    static void uart_puti(alt_u32 i) {
        static alt_u32 dv[] = {
            1000000000,
             100000000,
              10000000,
               1000000,
                100000,
                 10000,
                  1000,
                   100,
                    10,
                     1,
        };
        alt_u32 *dp = dv;
        alt_u32 d;
        if (i) {
            char c;
            while (i < *dp) ++dp;
            do {
                d = *dp++;
                c = '0';
                while (i >= d) ++c, i -= d;
                alt_putchar(c);
            } while (!(d & 1));
        } else {
            alt_putchar('0');
        }
    }
void uart_printf(char *format, ...) {
        char c;
        alt_32 d;
        alt_u32 u;
        va_list a;
        __builtin_va_start(a,format);
        while ((c = *format++)) {
            if (c == '%') {
                switch (c = *format++) {
                case 's':
                    uart_puts(__builtin_va_arg(a,char*));
                    break;
                case 'd':
                    d = __builtin_va_arg(a,alt_32);
                    if (d < 0) d = -d, alt_putchar('-');
                    uart_puti((alt_u32)d);
                    break;
                case 'u':
                    u = __builtin_va_arg(a,alt_u32);
                    uart_puti(u);
                    break;
                case 'x':
                    u = __builtin_va_arg(a,alt_u32);
                    d = uart_puth(1, u >> 28);
                    d = uart_puth(d, u >> 24);
                    d = uart_puth(d, u >> 20);
                    d = uart_puth(d, u >> 16);
                    d = uart_puth(d, u >> 12);
                    d = uart_puth(d, u >> 8);
                    uart_puth(d, u >> 4);
                    uart_puth(0, u);
                    break;
                case 0:
                    break;
                default:
                    alt_putchar(c);
                }
            } else {
                alt_putchar(c);
            }
        }
        __builtin_va_end(a);
    }
alt_u8 ac_rom_pin_exists[REAL_AC_PIN_DDR4_NUM];
alt_u8 g_pipe_distance_in_mem_clks[(18 * 2)];
alt_16 g_dqs_en_b_delay_x4[(18 * 2) / 2][4];
alt_16 g_dqs_in_b_delay_x4[(18 * 2) / 2][4];
alt_32 g_max_pipe_distance_in_mem_clks;
alt_32 g_max_effective_dqs_en_phases;
alt_u32 g_mif_idx;
alt_u32 g_current_mirror;
alt_32 g_rank_shadow;
alt_32 g_cur_rank;
alt_u32 g_is_ca_bus_ddr;
alt_u32 g_is_rdimm;
alt_u32 g_is_lrdimm;
alt_u32 g_is_pingpong;
alt_u32 g_is_unpacked;
alt_u32 g_use_multi_rank_interpolator_delay;
alt_u32 g_is_true_x4;
alt_u32 g_ac_val_msb_used;
alt_u32 g_ddr3_parity_en;
alt_u32 g_ddr4_parity_en;
alt_u32 g_ddr4_parity_and_alert_pins_exist;
alt_u32 g_qdriv_parity_en;
alt_u32 g_qdriv_dbi_en;
alt_u32 g_dm_en;
alt_u32 g_dbi_read_en;
alt_u32 g_dbi_write_en;
alt_u32 g_dyn_oct_en;
alt_32 g_twl_effective;
alt_32 g_tcl_effective;
alt_32 g_tcl_fractional;
alt_32 g_vref_out_range;
alt_u32 g_curr_vref_out;
alt_u32 g_addr_io_center_base;
alt_u32 g_addr_cmd_run;
alt_u32 g_num_dm_per_dqs_write;
alt_u32 g_num_rd_dqs_per_write_dqs;
alt_u32 g_num_dq_per_dqs_read;
alt_u32 g_num_dq_per_dqs_write;
alt_u32 g_num_dq_per_dm;
alt_u32 g_num_lanes_per_dqs_read;
alt_u32 g_num_lanes_per_dqs_write;
alt_u32 g_num_lanes_per_dqs_read_shift;
alt_u32 g_num_lanes_per_dqs_write_shift;
alt_u32 g_num_cs_per_dimm;
alt_u32 g_num_cs_per_rank;
alt_32 g_num_effective_ranks;
alt_32 g_shrink;
alt_32 g_out_rate;
alt_32 g_in_rate;
alt_32 g_out_rate_shift;
alt_32 g_in_rate_shift;
alt_32 g_in_phases_per_mem_clk_shift;
alt_32 g_out_phases_per_mem_clk_shift;
alt_32 g_in_phases_per_mem_clk;
alt_32 g_out_phases_per_mem_clk;
alt_32 g_in_phases_per_PHY_clk_shift;
alt_32 g_out_phases_per_PHY_clk_shift;
alt_32 g_in_phases_per_PHY_clk;
alt_32 g_out_phases_per_PHY_clk;
alt_32 g_out_delay_tolerance;
alt_32 g_out_delay_min;
alt_32 g_out_delay_max;
alt_32 g_dqs_in_delay_max;
alt_32 g_dq_in_delay_max;
alt_32 g_dqs_en_shrink_adjustment;
alt_32 g_wlat_shrink_post_cal;
alt_32 g_output_delay_shrink_post_cal;
alt_32 g_data_delay_shrink_post_cal;
alt_32 g_max_phases_data_out_rank_skew;
alt_32 g_max_phases_dqs_en_rank_skew;
alt_u32 g_in_track_speed;
alt_u32 g_out_track_speed;
alt_u32 g_pt_MEMORY_TYPE;
alt_u32 g_pt_DIMM_TYPE;
alt_u32 g_pt_CONTROLLER_TYPE;
alt_u32 g_pt_AFI_CLK_FREQ_KHZ;
alt_u32 g_pt_BURST_LEN;
alt_u32 g_pt_NUM_RANKS;
alt_u32 g_pt_NUM_DIMMS;
alt_u32 g_pt_NUM_DQS_WR;
alt_u32 g_pt_NUM_DQS_RD;
alt_u32 g_pt_NUM_DQ;
alt_u32 g_pt_NUM_DM;
alt_u32 g_pt_ADDR_WIDTH;
alt_u32 g_pt_BANK_WIDTH;
alt_u32 g_pt_BANK_GROUP_WIDTH;
alt_u32 g_pt_CS_WIDTH;
alt_u32 g_pt_CK_WIDTH;
alt_u32 g_pt_C_WIDTH;
alt_u32 g_pt_CKE_WIDTH;
alt_u32 g_pt_ODT_WIDTH;
alt_u32 g_pt_ADDR_MIRROR;
alt_u32 g_pt_NUM_CENTERS;
alt_u32 g_pt_NUM_CA_LANES;
alt_u32 g_pt_NUM_DATA_LANES;
alt_u32 *g_pt_CAL_DATA;
alt_u32 g_starting_vrefin;
alt_u32 g_starting_vrefout;
alt_u32 g_starting_vrefout_range;
alt_u32 g_dcd_cal_tile_mask;
alt_u32 g_periodic_oct_recal_state;
alt_u32 g_debug_toolkit_connected;
alt_u32 g_pt_CENTER_OFFS[8];
alt_u32 g_pt_CA_LANE_OFFS[4];
alt_u32 g_pt_DATA_LANE_OFFS[18];
alt_u8 g_write_data_lane_id[(18 * 2)];
alt_u8 g_read_data_lane_id[(18 * 2)];
alt_u32 g_num_read_data_lanes;
alt_u32 g_num_write_data_lanes;
alt_u32 *g_pt_MR;
alt_u8 *g_pt_RDIMM_CONFIG_WORDS;
alt_u8 *g_pt_LRDIMM_EXT_CONFIG_WORDS;
alt_u32 g_data_addr[NUM_DO_ROM_ENTRIES];
alt_u32 g_ca_addr[AC_PIN_DDR4_NUM];
alt_u32 *g_dq_addr_wr;
alt_u32 *g_dq_addr_rd;
alt_u32 *g_dq_addr_dm;
alt_u32 *g_dqs_wr_t_addr;
alt_u32 *g_dqs_wr_c_addr;
alt_u32 *g_dqs_rd_t_addr;
alt_u32 *g_dqs_rd_c_addr;
alt_u32 g_fast_sim;
alt_u8 g_rtl_release;
alt_u32 g_num_read_test_loops_shift;
alt_u32 g_num_write_test_loops_shift;
alt_u32 g_addr_jump_cfg_0;
alt_u32 g_addr_jump_cfg_1;
alt_u32 g_addr_jump_cfg_2;
alt_u32 g_addr_jump_cfg_3;
alt_u32 g_addr_jump_cfg_4;
alt_u32 g_addr_jump_cfg_5;
alt_u32 g_addr_jump_cfg_6;
alt_u32 g_addr_jump_cfg_7;
alt_u32 g_cal_burst_len;
alt_u32 g_skip_steps;
alt_u32 g_abort_on_fail;
alt_32 g_command_delay;
alt_32 g_vfifo_latency;
alt_32 g_dqs_en_delay;
alt_32 g_dqs_out_delay;
alt_32 g_dq_out_delay;
alt_32 g_dqs_in_delay;
alt_32 g_dq_in_delay;
alt_32 g_lfifo_latency;
alt_32 g_rlat;
alt_32 g_wlat;
alt_32 g_inst_rom_min_wlat;
alt_32 g_dqs_en_gating_path_delay;
alt_u8 g_vfifo[(144 / 4)];
alt_u32 g_vfifo_first_rank_calibrated;
alt_u16 g_dq_pin_mask[(18 * 2)];
alt_16 g_ca_left_edge[4];
alt_16 g_ca_right_edge[4];
alt_16 g_ca_center[4];
const alt_u8 g_ddr4_parity_signals_full[] = {
    AC_ROM_DDR4_ACT,
    AC_ROM_DDR4_C_0,
    AC_ROM_DDR4_C_1,
    AC_ROM_DDR4_C_2,
    AC_ROM_DDR4_BA_0,
    AC_ROM_DDR4_BA_1,
    AC_ROM_DDR4_BG_0,
    AC_ROM_DDR4_BG_1,
    AC_ROM_DDR4_ADD_0,
    AC_ROM_DDR4_ADD_1,
    AC_ROM_DDR4_ADD_2,
    AC_ROM_DDR4_ADD_3,
    AC_ROM_DDR4_ADD_4,
    AC_ROM_DDR4_ADD_5,
    AC_ROM_DDR4_ADD_6,
    AC_ROM_DDR4_ADD_7,
    AC_ROM_DDR4_ADD_8,
    AC_ROM_DDR4_ADD_9,
    AC_ROM_DDR4_ADD_10,
    AC_ROM_DDR4_ADD_11,
    AC_ROM_DDR4_ADD_12,
    AC_ROM_DDR4_ADD_13,
    AC_ROM_DDR4_ADD_14,
    AC_ROM_DDR4_ADD_15,
    AC_ROM_DDR4_ADD_16,
    AC_ROM_DDR4_ADD_17,
    AC_ROM_DDR4_PAR_IN
};
const alt_u8 g_ddr4_parity_signals_quick[] = {
    AC_ROM_DDR4_ACT,
    AC_ROM_DDR4_ADD_15,
    AC_ROM_DDR4_PAR_IN
};
const alt_u8* g_ddr4_parity_signals;
alt_u8 g_ddr4_parity_signals_num;
alt_16 g_ca_deskew_min_left_edge[30];
alt_16 g_ca_deskew_max_right_edge[30];
alt_u32 g_tcl_dbg_enabled;
alt_u32 g_tclrpt_init_done;
alt_32 g_timer_shift;
typedef enum {
    RATE_FULL = 0,
    RATE_HALF = 1,
    RATE_QUARTER = 2,
    RATE_OCT = 3,
    NUM_IN_RATES = RATE_QUARTER + 1,
    NUM_OUT_RATES = RATE_OCT + 1,
} ENUM_RATE;
const alt_16 OUT_DELAY_MIN_NF5A[NUM_OUT_RATES][NUM_IN_RATES] =
    {{0x100, 0x280, 0x180},
     {0x180, 0x100, 0x380},
     {0x200, 0x100, 0x280},
     {0x200, 0x000, 0x380}};
const alt_16 OUT_DELAY_MAX_NF5A[NUM_OUT_RATES][NUM_IN_RATES] = {
     {0xA80, 0xBC0, 0xA00},
     {0xFFF, 0xFFF, 0xFFF},
     {0x1FFF, 0x1FFF, 0x1FFF},
     {0x1FFF, 0x1FFF, 0x1FFF}
};
const alt_16 OUT_DELAY_MAX[NUM_OUT_RATES][NUM_IN_RATES] = {
     {0xA00, 0x9C0, 0x900},
     {0xEFF, 0xF7F, 0xCFF},
     {0x1E7F, 0x1F7F, 0x1DFF},
     {0x1E7F, 0x207F, 0x1CFF}
};
  const alt_u8 MULTI_RANK_OFFSET_IN_OSC_CLKS[NUM_OUT_RATES] =
      {10, 13, 12, 17};
  const alt_u8 MULTI_RANK_OFFSET_AVL[NUM_OUT_RATES] =
      {11, 6, 3, 2};
alt_u32 util_div_no_check(alt_u32 dividend, alt_u32 divisor) {
    alt_u32 quotient = 0;
    while (dividend >= divisor) {
        dividend -= divisor;
        ++quotient;
    }
    return quotient;
}
alt_u32 util_div(alt_u32 dividend, alt_u32 divisor) {
    ;
    ;
    ;
    return util_div_no_check(dividend, divisor);
}
alt_u32 util_div_power_2_opt(alt_u32 dividend, alt_u32 divisor) {
    ;
    alt_u32 tmp_divisor = divisor;
    alt_u32 tmp_dividend = dividend;
    while (!(tmp_divisor & 1)) {
        tmp_dividend >>= 1;
        tmp_divisor >>= 1;
    }
    return (tmp_divisor == 1) ? tmp_dividend : util_div_no_check(dividend, divisor);
}
alt_u32 util_log2(alt_u32 data) {
    alt_u32 val = 0;
    while (data > 1) {
        data >>= 1;
        ++val;
    }
    return val;
}
alt_32 util_max(alt_32 a, alt_32 b) {
    return (a > b) ? a : b;
}
alt_32 util_min(alt_32 a, alt_32 b) {
    return (a < b) ? a : b;
}
alt_32 get_rank_offset_delay_in_osc_clks(alt_32 rank_skew_in_out_phases) {
    const alt_u32 MAX_LOCK_SPEED =
       (1 << (2 - 0 + 1)) - 1;
    return ((g_rtl_release == 2) ? 6 : 5) + (rank_skew_in_out_phases >> (MAX_LOCK_SPEED - 2));
}
alt_32 get_rank_offset(alt_32 rank_skew_in_out_phases) {
    return get_rank_offset_delay_in_osc_clks(rank_skew_in_out_phases) + 2;
}
alt_u32 get_lane_idx_read(alt_u32 dqs, alt_u32 lane) {
    return (dqs << g_num_lanes_per_dqs_read_shift) + lane;
}
alt_u32 get_lane_idx_write(alt_u32 dqs, alt_u32 lane) {
    return (dqs << g_num_lanes_per_dqs_write_shift) + lane;
}
alt_u32 out_delay_offset_write(alt_u32 addr) {
    return addr | ((2 << 22) + 0xd0) | (g_rank_shadow << 2);
}
alt_u32 out_delay_offset_read(alt_u32 addr) {
    return addr | ((2 << 22) + 0xc0);
}
alt_u32 dq_in_offset(alt_u32 dq_idx) {
    ;
    return (((g_dq_addr_rd[dq_idx]) & ~(((1 << (12 - 8)) - 1) << 8)))
            | (((2 << 22) + 0x1880) + (((((((((g_dq_addr_rd[dq_idx]) & (((1 << (12 - 8)) - 1) << 8)) >> 8)) >= 6) ? (((((g_dq_addr_rd[dq_idx]) & (((1 << (12 - 8)) - 1) << 8)) >> 8)) + 2) : ((((g_dq_addr_rd[dq_idx]) & (((1 << (12 - 8)) - 1) << 8)) >> 8))) << 2) + (g_rank_shadow)) << 2));
}
alt_u32 dbi_in_offset(alt_u32 dbi) {
    ;
    return (((g_data_addr[DO_ROM_DM + dbi]) & ~(((1 << (12 - 8)) - 1) << 8)))
            | (((2 << 22) + 0x1880) + (((((((((g_data_addr[DO_ROM_DM + dbi]) & (((1 << (12 - 8)) - 1) << 8)) >> 8)) >= 6) ? (((((g_data_addr[DO_ROM_DM + dbi]) & (((1 << (12 - 8)) - 1) << 8)) >> 8)) + 2) : ((((g_data_addr[DO_ROM_DM + dbi]) & (((1 << (12 - 8)) - 1) << 8)) >> 8))) << 2) + (g_rank_shadow)) << 2));
}
alt_u32 dq_out_offset_write(alt_u32 dq_idx) {
    ;
    return out_delay_offset_write(g_dq_addr_wr[dq_idx]);
}
alt_u32 dq_out_offset_read(alt_u32 dq_idx) {
    ;
    return out_delay_offset_read(g_dq_addr_wr[dq_idx]);
}
alt_u32 get_read_lane_addr(alt_u32 lane_idx) {
    return (((g_read_data_lane_id[lane_idx]) << 13) | (2 << 22));
}
alt_u32 get_write_lane_addr(alt_u32 lane_idx) {
    return (((g_write_data_lane_id[lane_idx]) << 13) | (2 << 22));
}
alt_u32 is_x4_dqs_b(alt_u32 dqs) {
    return (g_is_true_x4 && (((g_dqs_rd_t_addr[dqs]) & (((1 << (12 - 8)) - 1) << 8)) >> 8) == 8);
}
alt_u32 dqs_in_b_offset(alt_u32 dqs, alt_u32 lane) {
    alt_u32 lane_idx = get_lane_idx_read(dqs, lane);
    ;
    return get_read_lane_addr(lane_idx) | ((2 << 22) + 0x1960) | (1 ? 0 : (g_rank_shadow << 2));
}
alt_u32 dqs_in_offset(alt_u32 dqs, alt_u32 lane) {
    alt_u32 lane_idx = get_lane_idx_read(dqs, lane);
    ;
    return is_x4_dqs_b(dqs) ?
            dqs_in_b_offset(dqs, lane) :
            (get_read_lane_addr(lane_idx) | (((2 << 22) + 0x18e0) | (g_rank_shadow << 2)));
}
alt_u32 dqs_en_delay_offset(alt_u32 dqs, alt_u32 lane) {
    alt_u32 lane_idx = get_lane_idx_read(dqs, lane);
    ;
    return (get_read_lane_addr(lane_idx)
            | (is_x4_dqs_b(dqs) ?
                ((2 << 22) + 0x1970) :
                (((2 << 22) + 0x18f0) | (g_rank_shadow << 2))));
}
alt_u32 dqs_en_delay_b_offset(alt_u32 dqs, alt_u32 lane) {
    alt_u32 lane_idx = get_lane_idx_read(dqs, lane);
    ;
    return get_read_lane_addr(lane_idx) | ((2 << 22) + 0x1970) | (1 ? 0 : (g_rank_shadow << 2));
}
alt_u32 dqs_out_offset_write(alt_u32 dqs) {
    ;
    return out_delay_offset_write(g_dqs_wr_t_addr[dqs]);
}
alt_u32 dqs_out_offset_read(alt_u32 dqs) {
    ;
    return out_delay_offset_read(g_dqs_wr_t_addr[dqs]);
}
alt_u32 dm_dbi_out_offset_write(alt_u32 dm) {
    ;
    return out_delay_offset_write(g_data_addr[DO_ROM_DM + dm]);
}
alt_u32 vfifo_offset(alt_u32 dqs, alt_u32 lane) {
    alt_u32 lane_idx = get_lane_idx_read(dqs, lane);
    ;
    return (get_read_lane_addr(lane_idx) | ((2 << 22) + 0x1808));
}
alt_32 avl_read_with_voting(alt_u32 offset) {
    alt_32 same_value_count = 1;
    alt_32 last_value = __builtin_ldwio(((void *)((alt_u8*)(offset))));
    while (same_value_count < ((g_rtl_release > 1) ? 5 : 1)) {
        alt_32 curr_value = __builtin_ldwio(((void *)((alt_u8*)(offset))));
        if (last_value == curr_value) {
            ++same_value_count;
        } else {
            same_value_count = 0;
            last_value = curr_value;
        }
    }
    return last_value;
}
alt_32 get_dq_in_delay(alt_u32 dq_idx) {
    return (((alt_u32)(avl_read_with_voting(dq_in_offset(dq_idx))) & ((((alt_u32) 1 << (8 - 0 + 1)) - 1) << 0)) >> 0);
}
alt_32 get_dqs_lane_in_delay(alt_u32 dqs, alt_u32 lane) {
    ;
    ;
    return (((alt_u32)(avl_read_with_voting(dqs_in_offset(dqs, lane))) & ((((alt_u32) 1 << (9 - 0 + 1)) - 1) << 0)) >> 0);
}
alt_32 get_dqs_in_delay(alt_u32 dqs) {
    return get_dqs_lane_in_delay(dqs, 0);
}
alt_32 get_dqs_lane_in_b_delay(alt_u32 dqs, alt_u32 lane) {
    return (((alt_u32)(avl_read_with_voting(dqs_in_b_offset(dqs, lane))) & ((((alt_u32) 1 << (9 - 0 + 1)) - 1) << 0)) >> 0);
}
alt_32 get_dqs_en_delay(alt_u32 dqs) {
    ;
    ;
    return (((alt_u32)(__builtin_ldwio(((void *)((alt_u8*)(dqs_en_delay_offset(dqs , 0)))))) & ((((alt_u32) 1 << (12 - 0 + 1)) - 1) << 0)) >> 0);
}
alt_32 get_dqs_en_pattern_position(alt_u32 dqs) {
    return __builtin_ldwio(((void *)((alt_u8*)(((g_dqs_rd_t_addr[dqs]) & ~(((1 << (12 - 8)) - 1) << 8)) | ((2 << 22) + 0x1824)))));
}
alt_32 get_cur_dq_out_delay(alt_u32 dq_idx) {
    return __builtin_ldwio(((void *)((alt_u8*)(dq_out_offset_read(dq_idx)))));
}
alt_32 get_final_dq_out_delay(alt_u32 dq_idx) {
    return __builtin_ldwio(((void *)((alt_u8*)(dq_out_offset_write(dq_idx)))));
}
alt_32 get_cur_dqs_out_delay(alt_u32 dqs) {
    return __builtin_ldwio(((void *)((alt_u8*)(dqs_out_offset_read(dqs)))));
}
alt_32 get_final_dqs_out_delay(alt_u32 dqs) {
    return __builtin_ldwio(((void *)((alt_u8*)(dqs_out_offset_write(dqs)))));
}
alt_32 get_out_delay_csr(alt_u32 addr) {
    return (((alt_u32)(__builtin_ldwio(((void *)((alt_u8*)(addr | ((2 << 22) + 0xe8)))))) & ((((alt_u32) 1 << (12 - 0 + 1)) - 1) << 0)) >> 0);
}
alt_32 get_out_delay_write(alt_u32 addr) {
    return __builtin_ldwio(((void *)((alt_u8*)(out_delay_offset_write(addr)))));
}
alt_32 get_final_dm_dbi_out_delay(alt_u32 dm) {
    return __builtin_ldwio(((void *)((alt_u8*)(dm_dbi_out_offset_write(dm)))));
}
alt_32 get_vfifo_latency(alt_u32 dqs) {
    return (((alt_u32)(__builtin_ldwio(((void *)((alt_u8*)(vfifo_offset(dqs, 0)))))) & ((((alt_u32) 1 << (5 - 0 + 1)) - 1) << 0)) >> 0);
}
alt_32 get_lfifo_latency(alt_u32 dqs) {
    return (((alt_u32)(__builtin_ldwio(((void *)((alt_u8*)(((g_dqs_rd_t_addr[dqs]) & ~(((1 << (12 - 8)) - 1) << 8)) | ((2 << 22) + 0x180c)))))) & ((((alt_u32) 1 << (6 - 0 + 1)) - 1) << 0)) >> 0);
}
alt_32 get_ca_delay(alt_u32 ca_idx) {
    return __builtin_ldwio(((void *)((alt_u8*)(out_delay_offset_read(g_ca_addr[ca_idx])))));
}
void set_dq_in_delay(alt_u32 dq_idx, alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(dq_in_offset(dq_idx)))), ((alt_u32)(1) << 12) | ((alt_u32)(delay) << 0));
}
void set_dbi_in_delay(alt_u32 dqs, alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(dbi_in_offset(dqs)))), ((alt_u32)(1) << 12) | ((alt_u32)(delay) << 0));
}
void set_dqs_lane_in_b_delay(alt_u32 dqs, alt_u32 lane, alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(dqs_in_b_offset(dqs, lane)))), ((alt_u32)(1) << 12) | ((alt_u32)(delay) << 0));
}
void set_dqs_lane_in_a_delay(alt_u32 dqs, alt_u32 lane , alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(dqs_in_offset(dqs, lane)))), ((alt_u32)(1) << 12) | ((alt_u32)(delay) << 0));
}
void set_dqs_in_delay(alt_u32 dqs, alt_32 delay) {
    alt_u32 lane;
    for (lane = 0; lane < g_num_lanes_per_dqs_read; ++lane) {
        set_dqs_lane_in_a_delay(dqs, lane, delay);
        if ((g_pt_MEMORY_TYPE == MEM_QDRII)) {
            set_dqs_lane_in_b_delay(dqs, lane, delay);
        }
    }
}
void spread_dq_in_delay(alt_u32 dq_idx, alt_32 delay) {
    alt_32 delay_step = util_min(g_dq_in_delay_max, g_in_phases_per_mem_clk - 1) >> util_log2(g_num_dq_per_dqs_read);
    alt_32 final_delay = delay + util_min(g_dq_in_delay_max, g_in_phases_per_mem_clk - 1);
    alt_u32 dq;
    alt_32 d = delay;
    for (dq = 0; dq < (g_num_dq_per_dqs_read - 1); ++dq, ++dq_idx) {
        set_dq_in_delay(dq_idx, d);
        d = util_min(g_dq_in_delay_max, util_min(final_delay, (d + delay_step)));
    }
    set_dq_in_delay(dq_idx, util_min(g_dq_in_delay_max, final_delay));
}
typedef enum {SET_DQS_EN_SINGLE_RANK, SET_DQS_EN_MULTI_RANK} ENUM_SET_DQS_EN;
void set_dqs_en_delay_impl(alt_u32 dqs, alt_32 delay, ENUM_SET_DQS_EN set_dqs_en_sel) {
    alt_u32 lane;
    for (lane = 0; lane < g_num_lanes_per_dqs_read; ++lane) {
        if (g_rtl_release == 1 || !is_x4_dqs_b(dqs)) {
            __builtin_stwio(((void *)((alt_u8*)(dqs_en_delay_offset(dqs , lane)))), ((alt_u32)(1) << 15) | ((alt_u32)(delay) << 0));
        }
        if (!(g_rtl_release != 1)) {
            alt_u32 use_multi_rank_setting = (g_use_multi_rank_interpolator_delay && set_dqs_en_sel == SET_DQS_EN_MULTI_RANK);
            ;
            ;
            alt_32 dqs_en_b_delay = use_multi_rank_setting ? (delay - (9 * (1 << 7))) :
                (g_pt_MEMORY_TYPE == MEM_QDRII) ? delay + (g_out_phases_per_mem_clk >> 1) :
                delay;
            ;
            __builtin_stwio(((void *)((alt_u8*)(dqs_en_delay_b_offset(dqs , lane)))), ((alt_u32)(1) << 15) | ((alt_u32)(dqs_en_b_delay) << 0));
        } else {
            __builtin_stwio(((void *)((alt_u8*)(get_read_lane_addr(get_lane_idx_read(dqs, lane)) | ((2 << 22) + 0x1830)))), get_rank_offset(g_max_phases_dqs_en_rank_skew));
            if (is_x4_dqs_b(dqs) || (g_pt_MEMORY_TYPE == MEM_QDRII)) {
                alt_32 dqs_en_b_delay = (g_pt_MEMORY_TYPE == MEM_QDRII) ? delay + (g_out_phases_per_mem_clk >> 1) : delay;
                __builtin_stwio(((void *)((alt_u8*)(dqs_en_delay_b_offset(dqs , lane)))), ((alt_u32)(1) << 15) | ((alt_u32)(dqs_en_b_delay) << 0));
            }
        }
    }
}
void set_dqs_en_delay(alt_u32 dqs, alt_32 delay) {
    set_dqs_en_delay_impl(dqs, delay, SET_DQS_EN_MULTI_RANK);
}
void set_dqs_en_delay_single_rank(alt_u32 dqs, alt_32 delay) {
    set_dqs_en_delay_impl(dqs, delay, SET_DQS_EN_SINGLE_RANK);
}
void set_dq_out_delay(alt_u32 dq_idx, alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(dq_out_offset_write(dq_idx)))), delay);
}
void spread_dq_out_delay(alt_u32 dq_idx, alt_32 delay, alt_u32 spread_range_shift) {
    alt_32 delay_step = g_out_phases_per_mem_clk >> (util_log2(g_num_dq_per_dqs_write) + spread_range_shift);
    alt_32 final_delay = delay + (g_out_phases_per_mem_clk >> spread_range_shift);
    alt_u32 dq;
    alt_32 d = delay;
    for (dq = 0; dq < (g_num_dq_per_dqs_write - 1); ++dq, ++dq_idx) {
        set_dq_out_delay(dq_idx, util_min(final_delay, util_max(g_out_delay_min, d)));
        d += delay_step;
    }
    set_dq_out_delay(dq_idx, util_max(g_out_delay_min, final_delay));
}
void set_dqs_out_delay(alt_u32 dqs, alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(dqs_out_offset_write(dqs)))), delay);
}
void set_dm_dbi_out_delay(alt_u32 dm, alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(dm_dbi_out_offset_write(dm)))), delay);
}
void set_vfifo_latency(alt_u32 dqs, alt_32 latency) {
    ;
    alt_u32 lane;
    for (lane = 0; lane < g_num_lanes_per_dqs_read; ++lane) {
       __builtin_stwio(((void *)((alt_u8*)(vfifo_offset(dqs, lane)))), ((alt_u32)(1) << 15) | ((alt_u32)(latency) << 0));
    }
}
void set_lfifo_latency(alt_u32 dqs, alt_32 lfifo) {
    ;
    alt_u32 lane;
    for (lane = 0; lane < g_num_lanes_per_dqs_read; ++lane) {
        __builtin_stwio(((void *)((alt_u8*)(get_read_lane_addr(get_lane_idx_read(dqs, lane)) | ((2 << 22) + 0x180c)))), ((alt_u32)(1) << 15) | ((alt_u32)(lfifo) << 0));
    }
}
void set_ca_delay(alt_u32 ca_idx, alt_32 delay) {
    alt_32 ca_delay = delay;
    __builtin_stwio(((void *)((alt_u8*)(out_delay_offset_write(g_ca_addr[ca_idx])))), ca_delay);
}
void set_ca_delay_all(alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(out_delay_offset_write((((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 1) << 13) | (2 << 22)) | ((1 << 12) | (0 << 8))))))), delay);
    alt_32 ca;
    for (ca = 0; ca < real_ac_pin_num[g_pt_MEMORY_TYPE]; ++ca) {
        if (ac_rom_pin_exists[ca]) {
        }
    }
}
alt_32 get_smallest_vfifo(alt_32 dqs_en_clks) {
    alt_32 dqs_en_delay_clks_max = (((alt_u32)(g_out_delay_max - (g_out_phases_per_mem_clk << 1)) & ((((alt_u32) 1 << (31 - g_out_phases_per_mem_clk_shift + 1)) - 1) << g_out_phases_per_mem_clk_shift)) >> g_out_phases_per_mem_clk_shift);
    alt_32 new_vfifo = util_max(0, dqs_en_clks - dqs_en_delay_clks_max);
    ;
    return new_vfifo;
}
alt_u32 calc_lfifo_latency(alt_u32 effective_dqs_phases, alt_u32 burst_len) {
    alt_32 delay = (((alt_u32)(effective_dqs_phases + g_dqs_en_gating_path_delay) & ((((alt_u32) 1 << (31 - g_out_phases_per_mem_clk_shift + 1)) - 1) << g_out_phases_per_mem_clk_shift)) >> g_out_phases_per_mem_clk_shift)
                    + (burst_len >> 1)
                    + 3;
    alt_u32 lfifo =
        g_is_unpacked ?
            ((delay + g_in_rate - 1) >> g_in_rate_shift << g_in_rate_shift) :
            (g_in_rate == 4 ? ((delay + 2) & ~3) | 1 :
             g_in_rate == 2 ? delay | 1 :
                              delay);
    return lfifo;
}
alt_u32 calc_rlat(alt_32 lfifo_latency) {
    const alt_u32 rlat_adjust = 4;
    return ((lfifo_latency + g_in_rate - 1) >> g_in_rate_shift) + rlat_adjust;
}
void set_rlat(alt_32 rlat) {
    __builtin_stwio(((void *)((alt_u8*)(((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 4) << 13) | (2 << 22)) | ((2 << 22) + 0x414)))), rlat);
    __builtin_stwio(((void *)((alt_u8*)(((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 0) << 13) | (2 << 22)) | ((2 << 22) + 0xe44)))), rlat);
    __builtin_stwio(((void *)((alt_u8*)(((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 1) << 13) | (2 << 22)) | ((2 << 22) + 0xe44)))), rlat);
}
void set_wlat(alt_32 wlat) {
    __builtin_stwio(((void *)((alt_u8*)(((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 4) << 13) | (2 << 22)) | ((2 << 22) + 0x410)))), wlat);
    __builtin_stwio(((void *)((alt_u8*)(((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 0) << 13) | (2 << 22)) | ((2 << 22) + 0xe40)))), wlat);
    __builtin_stwio(((void *)((alt_u8*)(((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 1) << 13) | (2 << 22)) | ((2 << 22) + 0xe40)))), wlat);
}
void dbg_log_margins(debug_cal_data_t *data, alt_32 left_margin, alt_32 right_margin) {
}
void dbg_log_edges(debug_cal_data_t *data, alt_32 delay, alt_32 left_edge, alt_32 right_edge) {
    dbg_log_margins(data, left_edge - delay, delay - right_edge);
}
void set_dq_dbi_in_delay_all_groups(alt_32 delay) {
    alt_u32 pin;
    for (pin = 0; pin < 12; ++pin) {
        __builtin_stwio(((void *)((alt_u8*)(((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 0) << 13) | (2 << 22)) | (((2 << 22) + 0x1880) + ((((((pin) >= 6) ? ((pin) + 2) : (pin)) << 2) + (g_rank_shadow)) << 2))))), ((alt_u32)(1) << 12) | ((alt_u32)(delay) << 0));
    }
}
typedef enum {DQS_IN_SEL_ALL, DQS_IN_SEL_X4_A, DQS_IN_SEL_X4_B} ENUM_DQS_IN_SEL;
void set_dqs_in_delay_all_groups_impl(alt_32 delay, ENUM_DQS_IN_SEL dqs_in_sel) {
    alt_u32 dqs;
    for (dqs = 0; dqs < g_pt_NUM_DQS_RD; ++dqs) {
        if ((dqs_in_sel == DQS_IN_SEL_ALL) || (dqs_in_sel == DQS_IN_SEL_X4_B && is_x4_dqs_b(dqs)) || (dqs_in_sel == DQS_IN_SEL_X4_A && !is_x4_dqs_b(dqs))) {
            set_dqs_in_delay(dqs, delay);
        }
    }
}
void set_dqs_in_delay_all_groups(alt_32 delay) {
    set_dqs_in_delay_all_groups_impl(delay, DQS_IN_SEL_ALL);
}
void set_dqs_en_delay_all_groups(alt_32 delay) {
    alt_u32 dqs;
    for (dqs = 0; dqs < g_pt_NUM_DQS_RD; dqs++) {
        if ((g_pt_MEMORY_TYPE == MEM_QDRIV)) {
            if (dqs == (g_pt_NUM_DQS_RD >> 1)) {
                delay += g_out_phases_per_mem_clk >> 1;
            }
        }
        set_dqs_en_delay(dqs, delay);
    }
}
void set_dq_out_delay_all_groups(alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(out_delay_offset_write((((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 0) << 13) | (2 << 22)) | ((1 << 12) | (0 << 8))))))), delay);
    if ((g_pt_MEMORY_TYPE == MEM_QDRIV)) {
        alt_u32 dq;
        for (dq = (g_pt_NUM_DQ >> 1); dq < g_pt_NUM_DQ; ++dq) {
            set_dq_out_delay(dq, delay + (g_out_phases_per_mem_clk >> 1));
        }
    }
}
void set_dq_out_delay_individually_all_groups(alt_16 *delay) {
    alt_u32 dqs;
    for (dqs = 0; dqs < g_pt_NUM_DQS_WR; dqs++) {
        alt_u32 lane;
        for (lane = 0; lane < g_num_lanes_per_dqs_write; ++lane) {
            __builtin_stwio(((void *)((alt_u8*)(out_delay_offset_write(get_write_lane_addr(get_lane_idx_write(dqs, lane))) | ((1 << 12) | (0 << 8))))), delay[dqs]);
        }
    }
}
void set_dqs_out_delay_all_groups(alt_32 delay) {
    alt_u32 dqs;
    for (dqs = 0; dqs < g_pt_NUM_DQS_WR; dqs++) {
        set_dqs_out_delay(dqs, delay);
    }
}
void set_pipe_compensated_vfifo_latency_all_groups(alt_32 latency) {
    alt_u32 dqs;
    for (dqs = 0; dqs < g_pt_NUM_DQS_RD; ++dqs) {
        alt_32 pipe_distance = g_pipe_distance_in_mem_clks[get_lane_idx_read(dqs, 0)];
        set_vfifo_latency(dqs, latency - pipe_distance);
        ;
    }
}
void set_dm_dbi_out_delay_all_groups(alt_32 delay) {
    __builtin_stwio(((void *)((alt_u8*)(out_delay_offset_write((((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 0) << 13) | (2 << 22)) | ((1 << 12) | (2 << 8))))))), delay);
    if ((g_pt_MEMORY_TYPE == MEM_QDRIV)) {
       alt_u32 dm;
       for (dm = (g_pt_NUM_DM >> 1); dm < g_pt_NUM_DM; ++dm) {
           set_dm_dbi_out_delay(dm, delay + (g_out_phases_per_mem_clk >> 1));
       }
    }
}
void set_pipe_compensated_lfifo_latency_all_groups(alt_32 latency) {
    alt_u32 dqs;
    for (dqs = 0; dqs < g_pt_NUM_DQS_RD; ++dqs) {
        alt_32 pipe_distance = g_pipe_distance_in_mem_clks[get_lane_idx_read(dqs, 0)];
        set_lfifo_latency(dqs, latency - pipe_distance);
        ;
    }
}
void spread_dq_out_delay_all_groups(alt_32 delay, alt_u32 spread_range_shift) {
    alt_u32 dqs;
    alt_u32 dq_idx = 0;
    for (dqs = 0; dqs < g_pt_NUM_DQS_WR; ++dqs, dq_idx += g_num_dq_per_dqs_write) {
        spread_dq_out_delay(dq_idx, delay, spread_range_shift);
    }
}
void spread_dq_in_delay_all_groups(alt_32 delay) {
    alt_u32 dqs;
    alt_u32 dq_idx = 0;
    for (dqs = 0; dqs < g_pt_NUM_DQS_RD; ++dqs, dq_idx += g_num_dq_per_dqs_read) {
         spread_dq_in_delay(dq_idx, delay);
    }
}
alt_u8 * get_global_param_offs(alt_u32 byte_offset) {
    return &(((alt_u8 *) glob_param)[byte_offset]);
}
mem_param_t * get_mem_param(alt_u32 mem_idx) {
    return ((mem_param_t *) ((glob_param->pt_INTERFACE_PAR_PTRS[mem_idx] == 0) ? 0 :
                             get_global_param_offs(glob_param->pt_INTERFACE_PAR_PTRS[mem_idx] & 0x0000ffff)));
}
alt_u32 mem_interface_exists(alt_u32 mem_idx) {
    alt_u32 mem_ptr = (alt_u32) (get_mem_param(mem_idx));
    return (((alt_u32)(mem_ptr) & ((((alt_u32) 1 << (31 - 30 + 1)) - 1) << 30)) >> 30) == 0 && mem_ptr != 0;
}
typedef enum {STORE_ADDR_READ, STORE_ADDR_WRITE} ENUM_STORE_ADDR;
void store_lane_addr(ENUM_STORE_ADDR addr_type, alt_u32 dqs_idx, alt_u32 addr) {
    alt_u8 *data_lane_id = (addr_type == STORE_ADDR_WRITE) ? g_write_data_lane_id : g_read_data_lane_id;
    alt_u32 num_lanes_per_dqs = (addr_type == STORE_ADDR_WRITE) ? g_num_lanes_per_dqs_write : g_num_lanes_per_dqs_read;
    alt_u32 lane_idx = (addr_type == STORE_ADDR_WRITE) ? get_lane_idx_write(dqs_idx, 0) : get_lane_idx_read(dqs_idx, 0);
    alt_u32 *num_data_lanes = (addr_type == STORE_ADDR_WRITE) ? &g_num_write_data_lanes : &g_num_read_data_lanes;
    alt_u32 lane;
    for (lane = 0; lane < num_lanes_per_dqs; ++lane) {
        alt_u32 ln = lane_idx + lane;
        if (data_lane_id[ln] == (((addr) & (((1 << (22 - 13)) - 1) << 13)) >> 13)) {
            break;
        } else if (data_lane_id[ln] == (alt_u8) (~0)) {
            data_lane_id[ln] = (((addr) & (((1 << (22 - 13)) - 1) << 13)) >> 13);
            ++(*num_data_lanes);
            break;
        }
    }
    ;
}
void init_parameter_table(alt_u32 mem_idx) {
    ;
    alt_u32 i, j;
    g_mif_idx = mem_idx;
    mem_param = get_mem_param(mem_idx);
    alt_u32 actual_ac_width[NUM_AC_BUSES];
    g_pt_MEMORY_TYPE = mem_param->pt_MEMORY_TYPE;
    g_pt_DIMM_TYPE = mem_param->pt_DIMM_TYPE;
    g_pt_CONTROLLER_TYPE = mem_param->pt_CONTROLLER_TYPE;
    g_pt_AFI_CLK_FREQ_KHZ = mem_param->pt_AFI_CLK_FREQ_KHZ;
    g_pt_BURST_LEN = mem_param->pt_BURST_LEN;
    g_pt_NUM_RANKS = mem_param->pt_NUM_RANKS;
    g_pt_NUM_DIMMS = mem_param->pt_NUM_DIMMS;
    g_pt_NUM_DQS_WR = mem_param->pt_NUM_DQS_WR;
    g_pt_NUM_DQS_RD = mem_param->pt_NUM_DQS_RD;
    g_pt_NUM_DQ = mem_param->pt_NUM_DQ;
    g_pt_NUM_DM = mem_param->pt_NUM_DM;
    g_pt_ADDR_WIDTH = mem_param->pt_ADDR_WIDTH;
    g_pt_BANK_WIDTH = mem_param->pt_BANK_WIDTH;
    g_pt_BANK_GROUP_WIDTH = mem_param->pt_BANK_GROUP_WIDTH;
    g_pt_CS_WIDTH = mem_param->pt_CS_WIDTH;
    g_pt_CK_WIDTH = mem_param->pt_CK_WIDTH;
    g_pt_C_WIDTH = mem_param->pt_C_WIDTH;
    g_pt_CKE_WIDTH = mem_param->pt_CKE_WIDTH;
    g_pt_ODT_WIDTH = mem_param->pt_ODT_WIDTH;
    g_pt_ADDR_MIRROR = mem_param->pt_ADDR_MIRROR;
    g_pt_NUM_CENTERS = mem_param->pt_NUM_CENTERS;
    g_pt_NUM_CA_LANES = mem_param->pt_NUM_CA_LANES;
    g_pt_NUM_DATA_LANES = mem_param->pt_NUM_DATA_LANES;
    g_pt_CAL_DATA = (alt_u32 *) get_global_param_offs(mem_param->pt_CAL_DATA_PTR);
    alt_u32* tmp_pt_CAL_DATA = g_pt_CAL_DATA;
    if ((g_pt_MEMORY_TYPE == MEM_DDR3)) {
        g_pt_CAL_DATA = (alt_u32 *) get_global_param_offs(mem_param->pt_CAL_DATA_PTR);
    } else if ((g_pt_MEMORY_TYPE == MEM_DDR4) || (g_pt_MEMORY_TYPE == MEM_QDRIV) || (g_pt_MEMORY_TYPE == MEM_LPDDR3)) {
        g_starting_vrefin = (alt_u32) *(tmp_pt_CAL_DATA++);
        if ((g_pt_MEMORY_TYPE == MEM_DDR4)) {
        }
    }
    ;
    ;
    ;
    g_is_rdimm = (g_pt_DIMM_TYPE & ~DIMM_PINGPONG) == DIMM_RDIMM;
    g_is_lrdimm = (g_pt_DIMM_TYPE & ~DIMM_PINGPONG) == DIMM_LRDIMM;
    g_is_pingpong = (g_pt_DIMM_TYPE & DIMM_PINGPONG) != 0;
    g_is_ca_bus_ddr = (g_pt_MEMORY_TYPE == MEM_LPDDR3) || (g_pt_MEMORY_TYPE == MEM_QDRIV) || (((g_pt_MEMORY_TYPE == MEM_QDRII) || (g_pt_MEMORY_TYPE == MEM_QDRIV)) && g_pt_BURST_LEN == 2);
    ;
    if (g_pt_CS_WIDTH != g_pt_NUM_RANKS) {
        ;
    }
    g_num_cs_per_rank = util_div(g_pt_CS_WIDTH, g_pt_NUM_RANKS);
    g_num_cs_per_dimm = util_div(g_pt_CS_WIDTH, g_pt_NUM_DIMMS);
    g_num_effective_ranks = (g_pt_NUM_RANKS >> g_is_pingpong);
    g_pt_MR = (alt_u32 *) get_global_param_offs(mem_param->pt_MR_PTR);
    g_pt_RDIMM_CONFIG_WORDS = (alt_u8 *) (g_pt_MR + mem_param->pt_NUM_DIMM_MR);
    g_pt_LRDIMM_EXT_CONFIG_WORDS = (alt_u8 *) (g_pt_MR + mem_param->pt_NUM_DIMM_MR + mem_param->pt_NUM_LRDIMM_CFG);
    if ((g_pt_MEMORY_TYPE == MEM_DDR4)) {
        if (g_is_lrdimm) {
        } else {
            g_starting_vrefout_range = ((g_pt_MR[DDR4_AC_ROM_MR6] >> 6) & 1);
            g_starting_vrefout = (g_pt_MR[DDR4_AC_ROM_MR6] & 0x3f);
        }
    } else {
        g_starting_vrefout_range = 0;
        g_starting_vrefout = 0;
    }
    g_curr_vref_out = (g_pt_MEMORY_TYPE == MEM_DDR4) ? (g_pt_MR[DDR4_AC_ROM_MR6] & 0x3f) : 0;
    g_vref_out_range = (g_pt_MEMORY_TYPE == MEM_DDR4) ? g_starting_vrefout_range : 0;
    g_num_dq_per_dqs_write = util_div(g_pt_NUM_DQ, g_pt_NUM_DQS_WR);
    g_num_dq_per_dqs_read = util_div(g_pt_NUM_DQ, g_pt_NUM_DQS_RD);
    if ( g_pt_NUM_DM != 0 ) {
       g_num_dq_per_dm = util_div(g_pt_NUM_DQ, g_pt_NUM_DM);
    } else {
       g_num_dq_per_dm = 0;
    }
    g_num_read_data_lanes = 0;
    g_num_write_data_lanes = 0;
    ;
    ;
    g_num_lanes_per_dqs_write_shift =
        g_num_dq_per_dqs_write == 36 ? 2 :
        g_num_dq_per_dqs_write == 18 ? 1 : 0;
    g_num_lanes_per_dqs_read_shift =
        g_num_dq_per_dqs_read == 36 ? 2 :
        g_num_dq_per_dqs_read == 18 ? 1 : 0;
    g_num_lanes_per_dqs_write = 1 << g_num_lanes_per_dqs_write_shift;
    g_num_lanes_per_dqs_read = 1 << g_num_lanes_per_dqs_read_shift;
    alt_u8 *tid_addr = get_global_param_offs(mem_param->pt_TILE_ID_PTR);
    alt_u32 *offs[] = {g_pt_CENTER_OFFS, g_pt_CA_LANE_OFFS, g_pt_DATA_LANE_OFFS};
    alt_u32 num_offs[] = {g_pt_NUM_CENTERS, g_pt_NUM_CA_LANES, g_pt_NUM_DATA_LANES};
    for (i = 0; i < sizeof(offs)/sizeof(offs[0]); ++i) {
        alt_u32 idx;
        for (idx = 0; idx < num_offs[i]; ++idx) {
            offs[i][idx] = (((*tid_addr++) << 13) | (2 << 22));
        }
    }
    enum {PIN_CA,
          PIN_DQS_RD_T,
          PIN_DQS_RD_C,
          PIN_DQS_WR_T,
          PIN_DQS_WR_C,
          PIN_DM,
          PIN_DQ_RD,
          PIN_DQ_WR,
          NUM_PINS_PARSED,
    };
    alt_u32 is_dq_rd_wr_seperate = (g_pt_MEMORY_TYPE == MEM_QDRII);
    alt_u32 *pin_addrs[NUM_PINS_PARSED];
    pin_addrs[PIN_CA] = g_ca_addr;
    pin_addrs[PIN_DQS_RD_T] = &(g_data_addr[(((g_pt_MEMORY_TYPE == MEM_DDR3) || (g_pt_MEMORY_TYPE == MEM_DDR4)) || ((g_pt_MEMORY_TYPE == MEM_LPDDR3))) ? DO_ROM_DQS_T : DO_ROM_DQS_RD_T]);
    pin_addrs[PIN_DQS_RD_C] = &(g_data_addr[(((g_pt_MEMORY_TYPE == MEM_DDR3) || (g_pt_MEMORY_TYPE == MEM_DDR4)) || ((g_pt_MEMORY_TYPE == MEM_LPDDR3))) ? DO_ROM_DQS_C : DO_ROM_DQS_RD_C]);
    pin_addrs[PIN_DQS_WR_T] = &(g_data_addr[DO_ROM_DQS_WR_T]);
    pin_addrs[PIN_DQS_WR_C] = &(g_data_addr[DO_ROM_DQS_WR_C]);
    pin_addrs[PIN_DM] = &(g_data_addr[DO_ROM_DM]);
    pin_addrs[PIN_DQ_RD] = &(g_data_addr[DO_ROM_DQ]);
    pin_addrs[PIN_DQ_WR] = &(g_data_addr[DO_ROM_DQ + g_pt_NUM_DQ]);
    alt_u32 pin_size[NUM_PINS_PARSED];
    pin_size[PIN_CA] = ((g_pt_MEMORY_TYPE == MEM_DDR3) ? AC_PIN_DDR3_NUM : (g_pt_MEMORY_TYPE == MEM_DDR4) ? AC_PIN_DDR4_NUM : (g_pt_MEMORY_TYPE == MEM_LPDDR3) ? AC_PIN_LPDDR3_NUM : (g_pt_MEMORY_TYPE == MEM_RLDRAM3)? AC_PIN_RLDRAM3_NUM : 0? AC_PIN_RLDRAM2_NUM : (g_pt_MEMORY_TYPE == MEM_QDRII) ? AC_PIN_QDRII_NUM : (g_pt_MEMORY_TYPE == MEM_QDRIV) ? AC_PIN_QDRIV_NUM : AC_PIN_DDR3_NUM);
    pin_size[PIN_DQS_RD_T] = g_pt_NUM_DQS_RD;
    pin_size[PIN_DQS_RD_C] = g_pt_NUM_DQS_RD;
    pin_size[PIN_DQS_WR_T] = g_pt_NUM_DQS_WR;
    pin_size[PIN_DQS_WR_C] = g_pt_NUM_DQS_WR;
    pin_size[PIN_DM] = mem_param->pt_NUM_DM;
    pin_size[PIN_DQ_RD] = g_pt_NUM_DQ;
    pin_size[PIN_DQ_WR] = (is_dq_rd_wr_seperate ? g_pt_NUM_DQ : 0);
    alt_u8 *pin_addr_ptr = get_global_param_offs(mem_param->pt_PIN_ADDR_PTR);
    for (i = 0; i < (18 * 2); ++i) {
        g_read_data_lane_id[i] = (alt_u8) (~0);
        g_write_data_lane_id[i] = (alt_u8) (~0);
        g_dq_pin_mask[i] = 0;
    }
    for (i = 0; i < NUM_PINS_PARSED; ++i) {
        alt_u32 j;
        alt_u32 *lane_offs = (i == PIN_CA) ? g_pt_CA_LANE_OFFS : g_pt_DATA_LANE_OFFS;
        if ((((g_pt_MEMORY_TYPE == MEM_DDR3) || (g_pt_MEMORY_TYPE == MEM_DDR4)) || ((g_pt_MEMORY_TYPE == MEM_LPDDR3))) &&
            (i == PIN_DQS_WR_T ||
             i == PIN_DQS_WR_C)) {
            continue;
        }
        for (j = 0; j < pin_size[i]; ++j) {
            alt_u32 pin_code = *pin_addr_ptr++;
            alt_u32 lane_base_addr, pin_idx;
            alt_u8 lane_tile_index;
            if ((pin_code & 0xF) == 0xF) {
                pin_idx = pin_code >> 4;
                lane_tile_index = (*pin_addr_ptr++);
                lane_base_addr = g_pt_DATA_LANE_OFFS[lane_tile_index];
            } else {
                pin_idx = pin_code & 0xF;
                lane_tile_index = pin_code >> 4;
                lane_base_addr = lane_offs[lane_tile_index];
            }
            alt_32 pin_addr_idx = j;
            pin_addrs[i][pin_addr_idx] = lane_base_addr | (pin_idx << 8);
            if (i == PIN_DQS_RD_T || i == PIN_DQS_WR_T || i == PIN_DQ_RD || i == PIN_DQ_WR) {
                alt_u32 dqs_idx =
                    ((alt_32)i == PIN_DQS_RD_T || (alt_32)i == PIN_DQS_WR_T) ? (alt_u32) pin_addr_idx :
                    ((alt_32)i == PIN_DQ_RD) ? util_div_power_2_opt(pin_addr_idx, g_num_dq_per_dqs_read) :
                                               util_div_power_2_opt(pin_addr_idx, g_num_dq_per_dqs_write);
                store_lane_addr((i == PIN_DQS_RD_T || i == PIN_DQ_RD) ? STORE_ADDR_READ : STORE_ADDR_WRITE,
                                dqs_idx,
                                lane_base_addr);
            }
        }
    }
    if (!is_dq_rd_wr_seperate) {
        for (i = 0; i < g_num_read_data_lanes; ++i) {
            g_write_data_lane_id[i] = g_read_data_lane_id[i];
        }
        g_num_write_data_lanes = g_num_read_data_lanes;
    }
    g_is_true_x4 = (g_num_dq_per_dqs_read == 4) && (g_read_data_lane_id[0] == g_read_data_lane_id[1]);
    g_dq_addr_wr = ((g_pt_MEMORY_TYPE == MEM_QDRII) ? pin_addrs[PIN_DQ_WR] : pin_addrs[PIN_DQ_RD]);
    g_dq_addr_rd = pin_addrs[PIN_DQ_RD];
    g_dq_addr_dm = pin_addrs[PIN_DM];
    g_dqs_rd_t_addr = pin_addrs[PIN_DQS_RD_T];
    g_dqs_rd_c_addr = pin_addrs[PIN_DQS_RD_C];
    g_dqs_wr_t_addr = pin_addrs[(((g_pt_MEMORY_TYPE == MEM_DDR3) || (g_pt_MEMORY_TYPE == MEM_DDR4)) || ((g_pt_MEMORY_TYPE == MEM_LPDDR3))) ? PIN_DQS_RD_T : PIN_DQS_WR_T];
    g_dqs_wr_c_addr = pin_addrs[(((g_pt_MEMORY_TYPE == MEM_DDR3) || (g_pt_MEMORY_TYPE == MEM_DDR4)) || ((g_pt_MEMORY_TYPE == MEM_LPDDR3))) ? PIN_DQS_RD_C : PIN_DQS_WR_C];
    g_twl_effective = mem_param->pt_WRITE_LATENCY + (g_is_rdimm && (g_pt_MEMORY_TYPE == MEM_DDR3)) + ((g_pt_MEMORY_TYPE == MEM_LPDDR3));
    g_tcl_effective = (mem_param->pt_READ_LATENCY & 0x7f) + (g_is_rdimm && (g_pt_MEMORY_TYPE == MEM_DDR3));
    g_tcl_fractional = mem_param->pt_READ_LATENCY >> 7;
    alt_u32 mr5 = g_pt_MR[DDR4_AC_ROM_MR5];
    g_ddr4_parity_en = (g_pt_MEMORY_TYPE == MEM_DDR4) && ((mr5 & 7) || (g_is_rdimm || g_is_lrdimm));
    g_fast_sim = mem_param->pt_CAL_CONFIG & CAL_FAST_SIM;
    g_rtl_release = (mem_param->pt_CAL_CONFIG & 0x0f000000) >> 24;
    g_ddr4_parity_signals = g_fast_sim ? g_ddr4_parity_signals_quick : g_ddr4_parity_signals_full;
    g_ddr4_parity_signals_num = (g_fast_sim ? sizeof(g_ddr4_parity_signals_quick) : sizeof(g_ddr4_parity_signals_full)) / sizeof(g_ddr4_parity_signals[0]);
    g_ddr3_parity_en = (g_pt_MEMORY_TYPE == MEM_DDR3) && (g_is_rdimm || g_is_lrdimm);
    g_qdriv_parity_en = (g_pt_MEMORY_TYPE == MEM_QDRIV) && (g_pt_MR[QDRIV_AC_ROM_MR2] & (1 << 4));
    g_qdriv_dbi_en = (g_pt_MEMORY_TYPE == MEM_QDRIV) && (g_pt_MR[QDRIV_AC_ROM_MR2] & (1 << 6));
    alt_u32 qdriv_ainv_en = (g_pt_MEMORY_TYPE == MEM_QDRIV) && (g_pt_MR[QDRIV_AC_ROM_MR2] & (1 << 5));
    g_ddr4_parity_and_alert_pins_exist =
        g_ddr4_parity_en ||
        ((g_pt_MEMORY_TYPE == MEM_DDR4) &&
         !(mem_param->pt_DBG_SKIP_STEPS & CALIB_SKIP_CA_DESKEW));
    g_dm_en = (g_pt_NUM_DM != 0) && (!(g_pt_MEMORY_TYPE == MEM_DDR4) || (mr5 & (1 << 10)));
    g_dbi_write_en = (g_pt_MEMORY_TYPE == MEM_DDR4) && (mr5 & (1 << 11));
    g_dbi_read_en = (g_pt_MEMORY_TYPE == MEM_DDR4) && (mr5 & (1 << 12));
    g_current_mirror = 0;
    for (i = 0; i < real_ac_pin_num[g_pt_MEMORY_TYPE]; ++i)
        ac_rom_pin_exists[i] = 1;
    actual_ac_width[AC_BUS_BA] = g_pt_BANK_WIDTH;
    actual_ac_width[AC_BUS_ADD] = g_pt_ADDR_WIDTH;
    actual_ac_width[AC_BUS_BG] = g_pt_BANK_GROUP_WIDTH;
    actual_ac_width[AC_BUS_CS] = g_pt_CS_WIDTH;
    actual_ac_width[AC_BUS_C] = g_pt_C_WIDTH;
    actual_ac_width[AC_BUS_ODT] = g_pt_ODT_WIDTH;
    actual_ac_width[AC_BUS_CKE] = g_pt_CKE_WIDTH;
    actual_ac_width[AC_BUS_RM] = g_pt_C_WIDTH;
    for (i = 0; i < NUM_AC_BUSES; ++i)
        for (j = actual_ac_width[i]; j < ac_width[g_pt_MEMORY_TYPE][i]; ++j)
            ac_rom_pin_exists[ac_idx[g_pt_MEMORY_TYPE][i] + j] = 0;
    if ((g_pt_MEMORY_TYPE == MEM_DDR3) && !g_ddr3_parity_en) {
        ac_rom_pin_exists[AC_ROM_DDR3_PAR_IN] = 0;
    }
    if ((g_pt_MEMORY_TYPE == MEM_DDR4) && !g_ddr4_parity_and_alert_pins_exist) {
        ac_rom_pin_exists[AC_ROM_DDR4_PAR_IN] = 0;
    }
    if ((g_pt_MEMORY_TYPE == MEM_QDRIV) && !g_qdriv_parity_en) {
        ac_rom_pin_exists[AC_ROM_QDRIV_AP] = 0;
    }
    if ((g_pt_MEMORY_TYPE == MEM_QDRIV) && !qdriv_ainv_en) {
        ac_rom_pin_exists[AC_ROM_QDRIV_AINV] = 0;
    }
    if (0) {
        g_num_dm_per_dqs_write = 1;
    } else {
        g_num_dm_per_dqs_write = util_div(g_pt_NUM_DM, g_pt_NUM_DQS_WR);
    }
    g_num_rd_dqs_per_write_dqs = util_div_power_2_opt(g_num_dq_per_dqs_write, g_num_dq_per_dqs_read);
    g_addr_io_center_base = g_pt_CENTER_OFFS[0];
    g_addr_cmd_run = ((2 << 22) + 0x200) | g_pt_CENTER_OFFS[g_is_pingpong];
    g_addr_jump_cfg_0 = ((2 << 22) + 0x240) | ((((((((1 << (22 - 13)) - 1) << 13) >> 13) & ~7) | 4) << 13) | (2 << 22));
    g_addr_jump_cfg_1 = g_addr_jump_cfg_0 + 4;
    g_addr_jump_cfg_2 = g_addr_jump_cfg_0 + 8;
    g_addr_jump_cfg_3 = g_addr_jump_cfg_0 + 12;
    g_addr_jump_cfg_4 = g_addr_jump_cfg_0 + 16;
    g_addr_jump_cfg_5 = g_addr_jump_cfg_0 + 20;
    g_addr_jump_cfg_6 = g_addr_jump_cfg_0 + 24;
    g_addr_jump_cfg_7 = g_addr_jump_cfg_0 + 28;
    g_skip_steps = mem_param->pt_DBG_SKIP_STEPS;
    g_abort_on_fail = g_skip_steps & CALIB_SKIP_FAILED_STEPS;
    if (g_fast_sim) {
        g_num_read_test_loops_shift = 0;
        g_num_write_test_loops_shift = 0;
    } else {
        g_num_read_test_loops_shift = 3;
        g_num_write_test_loops_shift = 5;
    }
    ;
    ;
}
const alt_u8 real_ac_pin_num[NUM_MEM_TYPES] = {
    REAL_AC_PIN_DDR3_NUM,
    REAL_AC_PIN_DDR4_NUM,
    REAL_AC_PIN_LPDDR3_NUM,
    REAL_AC_PIN_RLDRAM3_NUM,
    REAL_AC_PIN_RLDRAM2_NUM,
    REAL_AC_PIN_QDRIV_NUM,
    REAL_AC_PIN_QDRII_NUM,
};
const alt_u8 ac_idx[NUM_MEM_TYPES][NUM_AC_BUSES] = {
    {
        AC_ROM_DDR3_BA_0,
        AC_ROM_DDR3_ADD_0,
        0,
        AC_ROM_DDR3_CS_0,
        0,
        AC_ROM_DDR3_ODT_0,
        AC_ROM_DDR3_CKE_0,
        AC_ROM_DDR3_RM_0,
    },
    {
        AC_ROM_DDR4_BA_0,
        AC_ROM_DDR4_ADD_0,
        AC_ROM_DDR4_BG_0,
        AC_ROM_DDR4_CS_0,
        AC_ROM_DDR4_C_0,
        AC_ROM_DDR4_ODT_0,
        AC_ROM_DDR4_CKE_0,
        0,
    },
    {
        0,
        AC_ROM_LPDDR3_ADD_0,
        0,
        AC_ROM_LPDDR3_CS_0,
        0,
        AC_ROM_LPDDR3_ODT_0,
        AC_ROM_LPDDR3_CKE_0,
        0,
    },
    {
        AC_ROM_RLDRAM3_BA_0,
        AC_ROM_RLDRAM3_ADD_0,
        0,
        AC_ROM_RLDRAM3_CS_0,
        0,
        0,
        0,
        0,
    },
    {
        AC_ROM_RLDRAM2_BA_0,
        AC_ROM_RLDRAM2_ADD_0,
        0,
        AC_ROM_RLDRAM2_CS,
        0,
        0,
        0,
        0,
    },
    {
        0,
        AC_ROM_QDRIV_ADD_0,
        0,
        0,
        0,
        0,
        0,
        0,
    },
    {
        0,
        AC_ROM_QDRII_ADD_0,
        0,
        0,
        0,
        0,
        0,
        0,
    },
};
const alt_u8 ac_width[NUM_MEM_TYPES][NUM_AC_BUSES] = {
    {
        3,
        16,
        0,
        4,
        0,
        4,
        4,
        2,
    },
    {
        2,
        20,
        2,
        4,
        3,
        4,
        4,
        0,
    },
    {
        0,
        20,
        0,
        4,
        0,
        4,
        4,
        0,
    },
    {
        4,
        21,
        0,
        4,
        0,
        0,
        0,
        0,
    },
    {
        3,
        23,
        0,
        1,
        0,
        0,
        0,
        0,
    },
    {
        0,
        25,
        0,
        0,
        0,
        0,
        0,
        0,
    },
    {
        0,
        23,
        0,
        0,
        0,
        0,
        0,
        0,
    },
};
void print_global_param(global_param_t *ptr) {
    int i;
    uart_printf("global_param_t : \n");
    uart_printf("  pt_GLOBAL_PAR_VER          = 0x%x\n", ptr->pt_GLOBAL_PAR_VER);
    uart_printf("  pt_NIOS_C_VER              = 0x%x\n", ptr->pt_NIOS_C_VER);
    uart_printf("  pt_COLUMN_ID               = 0x%x\n", ptr->pt_COLUMN_ID);
    uart_printf("  pt_NUM_IOPACKS             = 0x%x\n", ptr->pt_NUM_IOPACKS);
    uart_printf("  pt_NIOS_CLK_FREQ_KHZ       = 0x%x\n", ptr->pt_NIOS_CLK_FREQ_KHZ);
    uart_printf("  pt_PARAM_TABLE_SIZE        = 0x%x\n", ptr->pt_PARAM_TABLE_SIZE);
    for (i = 0; i < 11; i++) {
        uart_printf("  pt_INTERFACE_PAR_PTRS[%d]  = 0x%x\n", i, ptr->pt_INTERFACE_PAR_PTRS[i]);
    }
}
void print_mem_param(mem_param_t *ptr) {
    uart_printf("mem_param_t : \n");
    uart_printf("  pt_IP_VER               = 0x%x\n", ptr->pt_IP_VER);
    uart_printf("  pt_INTERFACE_PAR_VER    = 0x%x\n", ptr->pt_INTERFACE_PAR_VER);
    uart_printf("  pt_DEBUG_DATA_PTR       = 0x%x\n", ptr->pt_DEBUG_DATA_PTR);
    uart_printf("  pt_USER_COMMAND_PTR     = 0x%x\n", ptr->pt_USER_COMMAND_PTR);
    uart_printf("  pt_MEMORY_TYPE          = 0x%x\n", ptr->pt_MEMORY_TYPE);
    uart_printf("  pt_DIMM_TYPE            = 0x%x\n", ptr->pt_DIMM_TYPE);
    uart_printf("  pt_CONTROLLER_TYPE      = 0x%x\n", ptr->pt_CONTROLLER_TYPE);
    uart_printf("  pt_RESERVED             = 0x%x\n", ptr->pt_RESERVED);
    uart_printf("  pt_AFI_CLK_FREQ_KHZ     = 0x%x\n", ptr->pt_AFI_CLK_FREQ_KHZ);
    uart_printf("  pt_BURST_LEN            = 0x%x\n", ptr->pt_BURST_LEN);
    uart_printf("  pt_READ_LATENCY         = 0x%x\n", ptr->pt_READ_LATENCY);
    uart_printf("  pt_WRITE_LATENCY        = 0x%x\n", ptr->pt_WRITE_LATENCY);
    uart_printf("  pt_NUM_RANKS            = 0x%x\n", ptr->pt_NUM_RANKS);
    uart_printf("  pt_NUM_DIMMS            = 0x%x\n", ptr->pt_NUM_DIMMS);
    uart_printf("  pt_NUM_DQS_WR           = 0x%x\n", ptr->pt_NUM_DQS_WR);
    uart_printf("  pt_NUM_DQS_RD           = 0x%x\n", ptr->pt_NUM_DQS_RD);
    uart_printf("  pt_NUM_DQ               = 0x%x\n", ptr->pt_NUM_DQ);
    uart_printf("  pt_NUM_DM               = 0x%x\n", ptr->pt_NUM_DM);
    uart_printf("  pt_ADDR_WIDTH           = 0x%x\n", ptr->pt_ADDR_WIDTH);
    uart_printf("  pt_BANK_WIDTH           = 0x%x\n", ptr->pt_BANK_WIDTH);
    uart_printf("  pt_CS_WIDTH             = 0x%x\n", ptr->pt_CS_WIDTH);
    uart_printf("  pt_CKE_WIDTH            = 0x%x\n", ptr->pt_CKE_WIDTH);
    uart_printf("  pt_ODT_WIDTH            = 0x%x\n", ptr->pt_ODT_WIDTH);
    uart_printf("  pt_C_WIDTH              = 0x%x\n", ptr->pt_C_WIDTH);
    uart_printf("  pt_BANK_GROUP_WIDTH     = 0x%x\n", ptr->pt_BANK_GROUP_WIDTH);
    uart_printf("  pt_ADDR_MIRROR          = 0x%x\n", ptr->pt_ADDR_MIRROR);
    uart_printf("  pt_CK_WIDTH             = 0x%x\n", ptr->pt_CK_WIDTH);
    uart_printf("  pt_CAL_DATA_SIZE        = 0x%x\n", ptr->pt_CAL_DATA_SIZE);
    uart_printf("  pt_NUM_LRDIMM_CFG       = 0x%x\n", ptr->pt_NUM_LRDIMM_CFG);
    uart_printf("  pt_NUM_AC_ROM_ENUMS     = 0x%x\n", ptr->pt_NUM_AC_ROM_ENUMS);
    uart_printf("  pt_NUM_CENTERS          = 0x%x\n", ptr->pt_NUM_CENTERS);
    uart_printf("  pt_NUM_CA_LANES         = 0x%x\n", ptr->pt_NUM_CA_LANES);
    uart_printf("  pt_NUM_DATA_LANES       = 0x%x\n", ptr->pt_NUM_DATA_LANES);
    uart_printf("  pt_ODT_TABLE_LO         = 0x%x\n", ptr->pt_ODT_TABLE_LO);
    uart_printf("  pt_ODT_TABLE_HI         = 0x%x\n", ptr->pt_ODT_TABLE_HI);
    uart_printf("  pt_CAL_CONFIG           = 0x%x\n", ptr->pt_CAL_CONFIG);
    uart_printf("  pt_DBG_CONFIG           = 0x%x\n", ptr->pt_DBG_CONFIG);
    uart_printf("  pt_DBG_SKIP_RANKS       = 0x%x\n", ptr->pt_DBG_SKIP_RANKS);
    uart_printf("  pt_DBG_SKIP_GROUPS      = 0x%x\n", ptr->pt_DBG_SKIP_GROUPS);
    uart_printf("  pt_DBG_SKIP_STEPS       = 0x%x\n", ptr->pt_DBG_SKIP_STEPS);
    uart_printf("  pt_NUM_MR               = 0x%x\n", ptr->pt_NUM_MR);
    uart_printf("  pt_NUM_DIMM_MR          = 0x%x\n", ptr->pt_NUM_DIMM_MR);
    uart_printf("  pt_TILE_ID_PTR          = 0x%x\n", ptr->pt_TILE_ID_PTR);
    uart_printf("  pt_PIN_ADDR_PTR         = 0x%x\n", ptr->pt_PIN_ADDR_PTR);
    uart_printf("  pt_MR_PTR               = 0x%x\n", ptr->pt_MR_PTR);
}
void print_debug_data(debug_data_t *ptr) {
    int i;
    uart_printf("\ndebug_data : \n");
    uart_printf("  data_size               = 0x%x\n", ptr->data_size);
    uart_printf("  status                  = 0x%x\n", ptr->status);
    uart_printf("  requested_command       = 0x%x\n", ptr->requested_command);
    uart_printf("  command_status          = 0x%x\n", ptr->command_status);
    uart_printf("  command_parameters      = ");
    for (i = 0; i < 4; i++) uart_printf("%d ", ptr->command_parameters[i]); uart_printf("\n");
    uart_printf("  mem_summary_report      = 0x%x\n", (alt_u32) ((alt_u32) (alt_u32 *) ptr->mem_summary_report));
    uart_printf("  mem_cal_report          = 0x%x\n", (alt_u32) ((alt_u32) (alt_u32 *) ptr->mem_cal_report));
}
void print_summary_report(debug_summary_report_t *ptr) {
    int i;
    uart_printf("\nsummary_report : \n");
    uart_printf("  data_size               = 0x%x\n", ptr->data_size);
    uart_printf("  report_flags            = 0x%x\n", ptr->report_flags);
    uart_printf("  sequencer_signature     = 0x%x\n", ptr->sequencer_signature);
    uart_printf("  error_stage             = 0x%x\n", ptr->error_stage);
    uart_printf("  error_group             = 0x%x\n", ptr->error_group);
    uart_printf("  error_code              = 0x%x\n", ptr->error_code);
    uart_printf("  error_info              = 0x%x\n", ptr->error_info);
    uart_printf("  cur_stage               = 0x%x\n", ptr->cur_stage);
    uart_printf("  cur_interface_idx       = 0x%x\n", ptr->cur_interface_idx);
    uart_printf("  rank_mask_size          = 0x%x\n", ptr->rank_mask_size);
    uart_printf("  group_mask_size         = 0x%x\n", ptr->group_mask_size);
    uart_printf("  active_ranks            = 0x%x\n", ptr->active_ranks);
    uart_printf("  active_groups           = 0x%x\n", ptr->active_groups);
    uart_printf("  rank_mask               = ");
    for (i = 0; i < ((4 % 32) == 0 ? (4/32) : (4/32)+1); i++) {
        uart_printf("0x%x ", ptr->rank_mask[i]);
    }
    uart_printf("\n");
    uart_printf("  group_mask              = ");
    for (i = 0; i < (((144 / 4) % 32) == 0 ? ((144 / 4)/32) : ((144 / 4)/32)+1); i++) {
        uart_printf("0x%x ", ptr->group_mask[i]);
    }
    uart_printf("\n");
    uart_printf("  groups_attempted_calibration = ");
    for (i = 0; i < (((144 / 4) % 32) == 0 ? ((144 / 4)/32) : ((144 / 4)/32)+1); i++) {
        uart_printf("%d ", ptr->groups_attempted_calibration[i]);
    }
    uart_printf("\n");
    uart_printf("  in_rate                 = %d\n", ptr->in_out_rate & 0x7);
    uart_printf("  out_rate                = %d\n", ptr->in_out_rate >> 4);
}
void print_debug_cal_data_t(char *name, debug_cal_data_t *ptr, int size) {
    int i;
    for (i = 0; i < size; i++) {
        uart_printf("  %s[%d] : setting = 0x%x left_edge = 0x%x right_edge = 0x%x\n",
               name, i, ptr->setting & 0xFFFF, ptr->left_edge & 0xFF, ptr->right_edge & 0xFF);
        ptr++;
    }
}
void print_debug_cal_status_per_group_t(char *name, debug_cal_status_per_group_t *ptr, int size) {
    int i;
    for (i = 0; i < size; i++) {
        uart_printf("  %s[%d] : error_stage = 0x%x error_sub_stage = 0x%x\n",
               name, i, ptr->error_stage, ptr->error_sub_stage);
        ptr++;
    }
}
void print_alt_u8(char *name, alt_u8 *ptr, int size) {
    int i;
    for (i = 0; i < size; i++) {
        uart_printf("  %s[%d] = 0x%x\n", name, i, *ptr++);
    }
}
void print_cal_report(debug_cal_report_t *ptr) {
    uart_printf("\ndebug_cal_report : \n");
    uart_printf("  data_size               = 0x%x\n", ptr->data_size);
    uart_printf("  %s = 0x%x\n", "cal_data_dq_in", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dq_in)); uart_printf("  %s = 0x%x\n", "cal_data_dq_out", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dq_out)); uart_printf("  %s = 0x%x\n", "cal_data_dm_dbi_in", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dm_dbi_in)); uart_printf("  %s = 0x%x\n", "cal_data_dm_dbi_out", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dm_dbi_out)); uart_printf("  %s = 0x%x\n", "cal_data_dqs_in", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dqs_in)); uart_printf("  %s = 0x%x\n", "cal_data_dqs_en", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dqs_en)); uart_printf("  %s = 0x%x\n", "cal_data_dqs_en_b", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dqs_en_b)); uart_printf("  %s = 0x%x\n", "cal_data_dqs_out", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_dqs_out)); uart_printf("  %s = 0x%x\n", "vrefin", (alt_u32) ((alt_u32) (alt_u32 *) ptr->vrefin)); uart_printf("  %s = 0x%x\n", "vrefout", (alt_u32) ((alt_u32) (alt_u32 *) ptr->vrefout)); uart_printf("  %s = 0x%x\n", "cal_data_ca", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_data_ca)); uart_printf("  %s = 0x%x\n", "cal_status_per_group", (alt_u32) ((alt_u32) (alt_u32 *) ptr->cal_status_per_group)); uart_printf("  %s = 0x%x\n", "vfifo", (alt_u32) ((alt_u32) (alt_u32 *) ptr->vfifo)); uart_printf("  %s = 0x%x\n", "lfifo", (alt_u32) ((alt_u32) (alt_u32 *) ptr->lfifo));
    uart_printf("  write_lat               = 0x%x\n", ptr->write_lat);
    uart_printf("  read_lat                = 0x%x\n", ptr->read_lat);
    print_debug_cal_data_t("cal_data_dq_in", ptr->cal_data_dq_in, g_pt_NUM_DQ); print_debug_cal_data_t("cal_data_dq_out", ptr->cal_data_dq_out, g_pt_NUM_DQ); print_debug_cal_data_t("cal_data_dm_dbi_in", ptr->cal_data_dm_dbi_in, g_pt_NUM_DM); print_debug_cal_data_t("cal_data_dm_dbi_out", ptr->cal_data_dm_dbi_out, g_pt_NUM_DM); print_debug_cal_data_t("cal_data_dqs_in", ptr->cal_data_dqs_in, g_pt_NUM_DQS_RD); print_debug_cal_data_t("cal_data_dqs_en", ptr->cal_data_dqs_en, g_pt_NUM_DQS_RD); print_debug_cal_data_t("cal_data_dqs_en_b", ptr->cal_data_dqs_en_b, g_pt_NUM_DQS_RD); print_debug_cal_data_t("cal_data_dqs_out", ptr->cal_data_dqs_out, g_pt_NUM_DQS_WR); print_debug_cal_data_t("vrefin", ptr->vrefin, g_pt_NUM_DQS_RD); print_debug_cal_data_t("vrefout", ptr->vrefout, g_pt_NUM_DQS_WR); print_debug_cal_data_t("cal_data_ca", ptr->cal_data_ca, mem_param->pt_NUM_AC_ROM_ENUMS); print_debug_cal_status_per_group_t("cal_status_per_group", ptr->cal_status_per_group, g_pt_NUM_DQS_RD); print_alt_u8("vfifo", ptr->vfifo, g_pt_NUM_DQS_RD); print_alt_u8("lfifo", ptr->lfifo, g_pt_NUM_DQS_RD);
}
alt_32 get_dbi_in_delay(alt_u32 dbi_idx) {
    return (((alt_u32)(avl_read_with_voting(dbi_in_offset(dbi_idx))) & ((((alt_u32) 1 << (8 - 0 + 1)) - 1) << 0)) >> 0);
}
