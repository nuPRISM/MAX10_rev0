
`timescale 1ns / 1ns




module mpfe_top #(
    parameter
        SLAVE_COUNT             = 16,

        SLV_ADDR_WIDTH          = 16,
        MST_ADDR_WIDTH          = 16+3, // SLV_ADDR_WIDTH + log2(DATA_WIDTH/8)
        DATA_WIDTH              = 256,
        NARROW_DATA_WIDTH       = 32,
        OFFSET                  = 3,

        BCOUNT_WIDTH            = 3,
        CRITICAL_PORTS          = 0,

        SLV_0_BW_RATIO          = 1,
        SLV_1_BW_RATIO          = 1,
        SLV_2_BW_RATIO          = 1,
        SLV_3_BW_RATIO          = 1,
        SLV_4_BW_RATIO          = 1,
        SLV_5_BW_RATIO          = 1,
        SLV_6_BW_RATIO          = 1,
        SLV_7_BW_RATIO          = 1,
        SLV_8_BW_RATIO          = 1,
        SLV_9_BW_RATIO          = 1,
        SLV_10_BW_RATIO         = 1,
        SLV_11_BW_RATIO         = 1,
        SLV_12_BW_RATIO         = 1,
        SLV_13_BW_RATIO         = 1,
        SLV_14_BW_RATIO         = 1,
        SLV_15_BW_RATIO         = 1,

        DEBUG_PORT_ENABLED      = 1,
        INTERNAL_JTAGNODE       = 0,
        MONITOR_INSTANCE_ID     = 8'hf1


    )
    (
        input                            clk,
        input                            reset_n,

        // Avalon slave 0
        // --------------------
        // Avalon interface from user's master 0
        input                            slv_0_write_req,
        input                            slv_0_read_req,
        input [SLV_ADDR_WIDTH - 1 : 0]   slv_0_addr,
        input [DATA_WIDTH - 1 : 0]       slv_0_wdata,
        input [DATA_WIDTH/8-1 : 0]       slv_0_byteenable,
        input [BCOUNT_WIDTH-1 : 0]       slv_0_burst_count,
        input                            slv_0_burst_begin,
        output                           slv_0_waitrequest,
        output                           slv_0_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_0_rdata,

        // Avalon slave 1
        // --------------------
        // Avalon interface from user's master 1
        input                            slv_1_write_req,
        input                            slv_1_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_1_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_1_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_1_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_1_burst_count,
        input                            slv_1_burst_begin,
        output                           slv_1_waitrequest,
        output                           slv_1_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_1_rdata,

        // Avalon slave 2
        // --------------------
        // Avalon interface from user's master 2
        input                            slv_2_write_req,
        input                            slv_2_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_2_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_2_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_2_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_2_burst_count,
        input                            slv_2_burst_begin,
        output                           slv_2_waitrequest,
        output                           slv_2_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_2_rdata,

        // Avalon slave 3
        // --------------------
        // Avalon interface from user's master 3
        input                            slv_3_write_req,
        input                            slv_3_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_3_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_3_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_3_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_3_burst_count,
        input                            slv_3_burst_begin,
        output                           slv_3_waitrequest,
        output                           slv_3_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_3_rdata,

        // Avalon slave 4
        // --------------------
        // Avalon interface from user's master 4
        input                            slv_4_write_req,
        input                            slv_4_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_4_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_4_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_4_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_4_burst_count,
        input                            slv_4_burst_begin,
        output                           slv_4_waitrequest,
        output                           slv_4_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_4_rdata,

        // Avalon slave 5
        // --------------------
        // Avalon interface from user's master 5
        input                            slv_5_write_req,
        input                            slv_5_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_5_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_5_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_5_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_5_burst_count,
        input                            slv_5_burst_begin,
        output                           slv_5_waitrequest,
        output                           slv_5_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_5_rdata,

        // Avalon slave 6 (this side of the width-adapting slave port is 32 data bits and SLV_ADDR_WIDTH + OFFSET address bits)
        // --------------------
        // Avalon interface from user's master 6
        input                                       slv_6_write_req,
        input                                       slv_6_read_req,
        input  [SLV_ADDR_WIDTH+OFFSET - 1 : 0]      slv_6_addr,
        input  [NARROW_DATA_WIDTH  - 1 : 0]         slv_6_wdata,
        input  [NARROW_DATA_WIDTH/8-1 : 0]          slv_6_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]                 slv_6_burst_count,
        input                                       slv_6_burst_begin,
        output                                      slv_6_waitrequest,
        output                                      slv_6_rdata_valid,
        output [NARROW_DATA_WIDTH - 1 : 0]          slv_6_rdata,

        // Avalon slave 7 (this side of the width-adapting slave port is 32 data bits and SLV_ADDR_WIDTH + OFFSET address bits)
        // --------------------
        // Avalon interface from user's master 7
        input                                       slv_7_write_req,
        input                                       slv_7_read_req,
        input  [SLV_ADDR_WIDTH+OFFSET - 1 : 0]      slv_7_addr,
        input  [NARROW_DATA_WIDTH  - 1 : 0]         slv_7_wdata,
        input  [NARROW_DATA_WIDTH/8-1 : 0]          slv_7_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]                 slv_7_burst_count,
        input                                       slv_7_burst_begin,
        output                                      slv_7_waitrequest,
        output                                      slv_7_rdata_valid,
        output [NARROW_DATA_WIDTH - 1 : 0]          slv_7_rdata,

        // Avalon slave 8
        // --------------------
        // Avalon interface from user's master 8
        input                            slv_8_write_req,
        input                            slv_8_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_8_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_8_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_8_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_8_burst_count,
        input                            slv_8_burst_begin,
        output                           slv_8_waitrequest,
        output                           slv_8_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_8_rdata,

        // Avalon slave 9
        // --------------------
        // Avalon interface from user's master 9
        input                            slv_9_write_req,
        input                            slv_9_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_9_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_9_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_9_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_9_burst_count,
        input                            slv_9_burst_begin,
        output                           slv_9_waitrequest,
        output                           slv_9_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_9_rdata,

        // Avalon slave 10
        // --------------------
        // Avalon interface from user's master 10
        input                            slv_10_write_req,
        input                            slv_10_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_10_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_10_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_10_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_10_burst_count,
        input                            slv_10_burst_begin,
        output                           slv_10_waitrequest,
        output                           slv_10_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_10_rdata,

        // Avalon slave 11
        // --------------------
        // Avalon interface from user's master 11
        input                            slv_11_write_req,
        input                            slv_11_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_11_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_11_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_11_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_11_burst_count,
        input                            slv_11_burst_begin,
        output                           slv_11_waitrequest,
        output                           slv_11_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_11_rdata,

        // Avalon slave 12
        // --------------------
        // Avalon interface from user's master 12
        input                            slv_12_write_req,
        input                            slv_12_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_12_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_12_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_12_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_12_burst_count,
        input                            slv_12_burst_begin,
        output                           slv_12_waitrequest,
        output                           slv_12_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_12_rdata,

        // Avalon slave 13
        // --------------------
        // Avalon interface from user's master 13
        input                            slv_13_write_req,
        input                            slv_13_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_13_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_13_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_13_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_13_burst_count,
        input                            slv_13_burst_begin,
        output                           slv_13_waitrequest,
        output                           slv_13_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_13_rdata,

        // Avalon slave 14
        // --------------------
        // Avalon interface from user's master 14
        input                            slv_14_write_req,
        input                            slv_14_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_14_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_14_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_14_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_14_burst_count,
        input                            slv_14_burst_begin,
        output                           slv_14_waitrequest,
        output                           slv_14_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_14_rdata,

        // Avalon slave 15
        // --------------------
        // Avalon interface from user's master 15
        input                            slv_15_write_req,
        input                            slv_15_read_req,
        input  [SLV_ADDR_WIDTH - 1 : 0]  slv_15_addr,
        input  [DATA_WIDTH - 1 : 0]      slv_15_wdata,
        input  [DATA_WIDTH/8-1 : 0]      slv_15_byteenable,
        input  [BCOUNT_WIDTH-1 : 0]      slv_15_burst_count,
        input                            slv_15_burst_begin,
        output                           slv_15_waitrequest,
        output                           slv_15_rdata_valid,
        output [DATA_WIDTH - 1 : 0]      slv_15_rdata,


        // Avalon master
        // --------------------
        // Avalon interface to shared slave
        output                              mst_write_req,
        output                              mst_read_req,
        //output                              mst_burst_begin,
        output [BCOUNT_WIDTH - 1 : 0]       mst_burst_count,
        output [MST_ADDR_WIDTH - 1 : 0]     mst_addr,
        output [DATA_WIDTH - 1 : 0]         mst_wdata,
        output [DATA_WIDTH/8-1 : 0]         mst_byteenable,
        input                               mst_waitrequest,
        input                               mst_rdata_valid,
        input  [DATA_WIDTH - 1 : 0]         mst_rdata,

        // Debug slave port
        // --------------------
        input wire                          dbg_write_req,
        input wire                          dbg_read_req,
        input wire [7:0]                    dbg_addr,
        input wire [31:0]                   dbg_wdata,
        output wire                         dbg_rdata_valid,
        output wire [31:0]                  dbg_rdata


    );



    // Avalon slave 0
    wire                            arb_0_write_req;
    wire                            arb_0_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_0_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_0_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_0_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_0_burst_count;
    wire                            arb_0_burst_begin;
    reg                             arb_0_waitrequest;
    wire                            arb_0_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_0_rdata;

    // Avalon slave 1
    wire                            arb_1_write_req;
    wire                            arb_1_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_1_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_1_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_1_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_1_burst_count;
    wire                            arb_1_burst_begin;
    reg                             arb_1_waitrequest;
    wire                            arb_1_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_1_rdata;

    // Avalon slave 2
    wire                            arb_2_write_req;
    wire                            arb_2_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_2_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_2_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_2_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_2_burst_count;
    wire                            arb_2_burst_begin;
    reg                             arb_2_waitrequest;
    wire                            arb_2_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_2_rdata;

    // Avalon slave 3
    wire                            arb_3_write_req;
    wire                            arb_3_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_3_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_3_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_3_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_3_burst_count;
    wire                            arb_3_burst_begin;
    reg                             arb_3_waitrequest;
    wire                            arb_3_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_3_rdata;

    // Avalon slave 4
    wire                            arb_4_write_req;
    wire                            arb_4_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_4_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_4_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_4_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_4_burst_count;
    wire                            arb_4_burst_begin;
    reg                             arb_4_waitrequest;
    wire                            arb_4_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_4_rdata;

    // Avalon slave 5
    wire                            arb_5_write_req;
    wire                            arb_5_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_5_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_5_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_5_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_5_burst_count;
    wire                            arb_5_burst_begin;
    reg                             arb_5_waitrequest;
    wire                            arb_5_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_5_rdata;


    // Avalon slave 6 (this side of the width-adapting slave is 256 data bits, SLV_ADDR_WIDTH address bits
    wire                            arb_6_write_req;
    wire                            arb_6_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_6_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_6_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_6_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_6_burst_count;
    wire                            arb_6_burst_begin;
    reg                             arb_6_waitrequest;
    wire                            arb_6_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_6_rdata;

    // Avalon slave 7 (this side of the width-adapting slave is 256 data bits, SLV_ADDR_WIDTH address bits
    wire                            arb_7_write_req;
    wire                            arb_7_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_7_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_7_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_7_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_7_burst_count;
    wire                            arb_7_burst_begin;
    reg                             arb_7_waitrequest;
    wire                            arb_7_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_7_rdata;

    // Avalon slave 8
    wire                            arb_8_write_req;
    wire                            arb_8_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_8_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_8_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_8_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_8_burst_count;
    wire                            arb_8_burst_begin;
    reg                             arb_8_waitrequest;
    wire                            arb_8_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_8_rdata;

    // Avalon slave 9
    wire                            arb_9_write_req;
    wire                            arb_9_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_9_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_9_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_9_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_9_burst_count;
    wire                            arb_9_burst_begin;
    reg                             arb_9_waitrequest;
    wire                            arb_9_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_9_rdata;

    // Avalon slave 10
    wire                            arb_10_write_req;
    wire                            arb_10_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_10_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_10_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_10_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_10_burst_count;
    wire                            arb_10_burst_begin;
    reg                             arb_10_waitrequest;
    wire                            arb_10_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_10_rdata;

    // Avalon slave 11
    wire                            arb_11_write_req;
    wire                            arb_11_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_11_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_11_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_11_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_11_burst_count;
    wire                            arb_11_burst_begin;
    reg                             arb_11_waitrequest;
    wire                            arb_11_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_11_rdata;

    // Avalon slave 12
    wire                            arb_12_write_req;
    wire                            arb_12_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_12_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_12_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_12_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_12_burst_count;
    wire                            arb_12_burst_begin;
    reg                             arb_12_waitrequest;
    wire                            arb_12_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_12_rdata;

    // Avalon slave 13
    wire                            arb_13_write_req;
    wire                            arb_13_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_13_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_13_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_13_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_13_burst_count;
    wire                            arb_13_burst_begin;
    reg                             arb_13_waitrequest;
    wire                            arb_13_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_13_rdata;

    // Avalon slave 14
    wire                            arb_14_write_req;
    wire                            arb_14_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_14_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_14_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_14_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_14_burst_count;
    wire                            arb_14_burst_begin;
    reg                             arb_14_waitrequest;
    wire                            arb_14_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_14_rdata;

    // Avalon slave 15
    wire                            arb_15_write_req;
    wire                            arb_15_read_req;
    wire [SLV_ADDR_WIDTH - 1 : 0]   arb_15_addr;
    wire [DATA_WIDTH - 1 : 0]       arb_15_wdata;
    wire [DATA_WIDTH/8-1 : 0]       arb_15_byteenable;
    wire [BCOUNT_WIDTH-1 : 0]       arb_15_burst_count;
    wire                            arb_15_burst_begin;
    reg                             arb_15_waitrequest;
    wire                            arb_15_rdata_valid;
    wire [DATA_WIDTH - 1 : 0]       arb_15_rdata;

    // Slaves req/grant bus to the arbiter
    reg  [SLAVE_COUNT-1 :0 ]        arb_req;
    wire [SLAVE_COUNT-1 :0 ]        arb_grant;
    reg  [SLAVE_COUNT-1 :0 ]        arb_grant_r;
    reg  [SLAVE_COUNT-1 :0 ]        arb_burst_count [BCOUNT_WIDTH -1 : 0];
    wire                            arb_granted_rd;
    wire                            arb_granted_wr;

    // Resolved, arbitrated Avalon signals
    reg                             resolved_write_req;
    reg                             resolved_read_req;
    reg  [SLV_ADDR_WIDTH - 1 : 0]   resolved_addr;
    reg  [DATA_WIDTH - 1 : 0]       resolved_wdata;
    reg  [DATA_WIDTH/8-1 : 0]       resolved_byteenable;
    reg  [BCOUNT_WIDTH-1 : 0]       resolved_burst_count;
    reg                             resolved_burst_begin;
    wire                            resolved_waitrequest;
    wire                            resolved_rdata_valid;
    reg                             rdata_valid_r;
    reg                             rdata_valid_out;
    wire [DATA_WIDTH - 1 : 0]       resolved_rdata;
    reg [DATA_WIDTH - 1 : 0]        resolved_rdata_r;

    wire                            mst_burst_begin;

    // wires/regs for the rdata master fifo
    wire [SLAVE_COUNT+BCOUNT_WIDTH -1 : 0] addr_fifo_data_in;
    wire [SLAVE_COUNT+BCOUNT_WIDTH -1 : 0] addr_fifo_data_out;
    wire                         addr_fifo_wren;
    wire                         addr_fifo_empty;
    wire                         addr_fifo_almost_empty;
    wire                         addr_fifo_full;
    reg                          addr_fifo_rden;
    reg [SLAVE_COUNT+BCOUNT_WIDTH -1 : 0] entries_in_fifo;

    // wires/regs for the rdata master fifo
    wire [DATA_WIDTH -1 : 0] data_fifo_data_out;
    wire                     data_fifo_empty;
    wire                     data_fifo_almost_empty;
    wire                     data_fifo_full;
    reg                      data_fifo_rden;

    wire new_port_granted;

    reg [2:0] rdata_state;

    reg  [SLAVE_COUNT-1:0]       rdata_master;
    wire [SLAVE_COUNT-1:0]       rdata_next_master;
    reg  [BCOUNT_WIDTH -1 : 0]   rdata_burstcount;
    wire [BCOUNT_WIDTH -1 : 0]   rdata_next_bcount;

    // Temporary wires for selecting internal JTAG
    wire                          avdbg_write_req;
    wire                          avdbg_read_req;
    wire [7:0]                    avdbg_addr;
    wire [31:0]                   avdbg_wdata;
    wire                          avdbg_rdata_valid;
    wire [31:0]                   avdbg_rdata;
    reg                           avdbg_waitrequest;


    //--------------------------------------------------------------------------
    // Slave port 0
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_0 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_0_addr          ),
        .slv_write_req       (slv_0_write_req     ),
        .slv_read_req        (slv_0_read_req      ),
        .slv_burst_begin     (slv_0_burst_begin   ),
        .slv_burst_count     (slv_0_burst_count   ),
        .slv_wdata           (slv_0_wdata         ),
        .slv_byteenable      (slv_0_byteenable    ),
        .slv_rdata           (slv_0_rdata         ),
        .slv_rdata_valid     (slv_0_rdata_valid   ),
        .slv_waitrequest     (slv_0_waitrequest   ),

        .arb_addr            (arb_0_addr          ),
        .arb_write_req       (arb_0_write_req     ),
        .arb_read_req        (arb_0_read_req      ),
        .arb_burst_begin     (arb_0_burst_begin   ),
        .arb_burst_count     (arb_0_burst_count   ),
        .arb_wdata           (arb_0_wdata         ),
        .arb_byteenable      (arb_0_byteenable    ),
        .arb_rdata           (arb_0_rdata         ),
        .arb_rdata_valid     (arb_0_rdata_valid   ),
        .arb_waitrequest     (arb_0_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // Slave port 1
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_1 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_1_addr          ),
        .slv_write_req       (slv_1_write_req     ),
        .slv_read_req        (slv_1_read_req      ),
        .slv_burst_begin     (slv_1_burst_begin   ),
        .slv_burst_count     (slv_1_burst_count   ),
        .slv_wdata           (slv_1_wdata         ),
        .slv_byteenable      (slv_1_byteenable    ),
        .slv_rdata           (slv_1_rdata         ),
        .slv_rdata_valid     (slv_1_rdata_valid   ),
        .slv_waitrequest     (slv_1_waitrequest   ),

        .arb_addr            (arb_1_addr          ),
        .arb_write_req       (arb_1_write_req     ),
        .arb_read_req        (arb_1_read_req      ),
        .arb_burst_begin     (arb_1_burst_begin   ),
        .arb_burst_count     (arb_1_burst_count   ),
        .arb_wdata           (arb_1_wdata         ),
        .arb_byteenable      (arb_1_byteenable    ),
        .arb_rdata           (arb_1_rdata         ),
        .arb_rdata_valid     (arb_1_rdata_valid   ),
        .arb_waitrequest     (arb_1_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // Slave port 2
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_2 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_2_addr          ),
        .slv_write_req       (slv_2_write_req     ),
        .slv_read_req        (slv_2_read_req      ),
        .slv_burst_begin     (slv_2_burst_begin   ),
        .slv_burst_count     (slv_2_burst_count   ),
        .slv_wdata           (slv_2_wdata         ),
        .slv_byteenable      (slv_2_byteenable    ),
        .slv_rdata           (slv_2_rdata         ),
        .slv_rdata_valid     (slv_2_rdata_valid   ),
        .slv_waitrequest     (slv_2_waitrequest   ),

        .arb_addr            (arb_2_addr          ),
        .arb_write_req       (arb_2_write_req     ),
        .arb_read_req        (arb_2_read_req      ),
        .arb_burst_begin     (arb_2_burst_begin   ),
        .arb_burst_count     (arb_2_burst_count   ),
        .arb_wdata           (arb_2_wdata         ),
        .arb_byteenable      (arb_2_byteenable    ),
        .arb_rdata           (arb_2_rdata         ),
        .arb_rdata_valid     (arb_2_rdata_valid   ),
        .arb_waitrequest     (arb_2_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // Slave port 3
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_3 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_3_addr          ),
        .slv_write_req       (slv_3_write_req     ),
        .slv_read_req        (slv_3_read_req      ),
        .slv_burst_begin     (slv_3_burst_begin   ),
        .slv_burst_count     (slv_3_burst_count   ),
        .slv_wdata           (slv_3_wdata         ),
        .slv_byteenable      (slv_3_byteenable    ),
        .slv_rdata           (slv_3_rdata         ),
        .slv_rdata_valid     (slv_3_rdata_valid   ),
        .slv_waitrequest     (slv_3_waitrequest   ),

        .arb_addr            (arb_3_addr          ),
        .arb_write_req       (arb_3_write_req     ),
        .arb_read_req        (arb_3_read_req      ),
        .arb_burst_begin     (arb_3_burst_begin   ),
        .arb_burst_count     (arb_3_burst_count   ),
        .arb_wdata           (arb_3_wdata         ),
        .arb_byteenable      (arb_3_byteenable    ),
        .arb_rdata           (arb_3_rdata         ),
        .arb_rdata_valid     (arb_3_rdata_valid   ),
        .arb_waitrequest     (arb_3_waitrequest   )
    );


    //--------------------------------------------------------------------------
    // Slave port 4
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_4 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_4_addr          ),
        .slv_write_req       (slv_4_write_req     ),
        .slv_read_req        (slv_4_read_req      ),
        .slv_burst_begin     (slv_4_burst_begin   ),
        .slv_burst_count     (slv_4_burst_count   ),
        .slv_wdata           (slv_4_wdata         ),
        .slv_byteenable      (slv_4_byteenable    ),
        .slv_rdata           (slv_4_rdata         ),
        .slv_rdata_valid     (slv_4_rdata_valid   ),
        .slv_waitrequest     (slv_4_waitrequest   ),

        .arb_addr            (arb_4_addr          ),
        .arb_write_req       (arb_4_write_req     ),
        .arb_read_req        (arb_4_read_req      ),
        .arb_burst_begin     (arb_4_burst_begin   ),
        .arb_burst_count     (arb_4_burst_count   ),
        .arb_wdata           (arb_4_wdata         ),
        .arb_byteenable      (arb_4_byteenable    ),
        .arb_rdata           (arb_4_rdata         ),
        .arb_rdata_valid     (arb_4_rdata_valid   ),
        .arb_waitrequest     (arb_4_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // Slave port 5
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_5 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_5_addr          ),
        .slv_write_req       (slv_5_write_req     ),
        .slv_read_req        (slv_5_read_req      ),
        .slv_burst_begin     (slv_5_burst_begin   ),
        .slv_burst_count     (slv_5_burst_count   ),
        .slv_wdata           (slv_5_wdata         ),
        .slv_byteenable      (slv_5_byteenable    ),
        .slv_rdata           (slv_5_rdata         ),
        .slv_rdata_valid     (slv_5_rdata_valid   ),
        .slv_waitrequest     (slv_5_waitrequest   ),

        .arb_addr            (arb_5_addr          ),
        .arb_write_req       (arb_5_write_req     ),
        .arb_read_req        (arb_5_read_req      ),
        .arb_burst_begin     (arb_5_burst_begin   ),
        .arb_burst_count     (arb_5_burst_count   ),
        .arb_wdata           (arb_5_wdata         ),
        .arb_byteenable      (arb_5_byteenable    ),
        .arb_rdata           (arb_5_rdata         ),
        .arb_rdata_valid     (arb_5_rdata_valid   ),
        .arb_waitrequest     (arb_5_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // Slave port 6
    //--------------------------------------------------------------------------
    // mpfe_slave_port #(
    mpfe_width_adapting_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ), // address bus in master side is 3 bits more than arbiter side
        .DATA_WIDTH          (NARROW_DATA_WIDTH   ), // width on master side is 32, width on arbiter side is 256
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_6 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_6_addr          ), // SLV_ADDR_WIDTH+3
        .slv_write_req       (slv_6_write_req     ),
        .slv_read_req        (slv_6_read_req      ),
        .slv_burst_begin     (slv_6_burst_begin   ),
        .slv_burst_count     (slv_6_burst_count   ),
        .slv_wdata           (slv_6_wdata         ),
        .slv_byteenable      (slv_6_byteenable    ),
        .slv_rdata           (slv_6_rdata         ),
        .slv_rdata_valid     (slv_6_rdata_valid   ),
        .slv_waitrequest     (slv_6_waitrequest   ),

        .arb_addr            (arb_6_addr          ), //SLV_ADDR_WIDTH
        .arb_write_req       (arb_6_write_req     ),
        .arb_read_req        (arb_6_read_req      ),
        .arb_burst_begin     (arb_6_burst_begin   ),
        .arb_burst_count     (arb_6_burst_count   ),
        .arb_wdata           (arb_6_wdata         ),
        .arb_byteenable      (arb_6_byteenable    ),
        .arb_rdata           (arb_6_rdata         ),
        .arb_rdata_valid     (arb_6_rdata_valid   ),
        .arb_waitrequest     (arb_6_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // Slave port 7
    //--------------------------------------------------------------------------
    mpfe_width_adapting_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ), // address bus in master side is 3 bits more than arbiter side
        .DATA_WIDTH          (NARROW_DATA_WIDTH   ), // width on master side is 32, width on arbiter side is 256
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_7 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_7_addr          ), // SLV_ADDR_WIDTH+3
        .slv_write_req       (slv_7_write_req     ),
        .slv_read_req        (slv_7_read_req      ),
        .slv_burst_begin     (slv_7_burst_begin   ),
        .slv_burst_count     (slv_7_burst_count   ),
        .slv_wdata           (slv_7_wdata         ),
        .slv_byteenable      (slv_7_byteenable    ),
        .slv_rdata           (slv_7_rdata         ),
        .slv_rdata_valid     (slv_7_rdata_valid   ),
        .slv_waitrequest     (slv_7_waitrequest   ),

        .arb_addr            (arb_7_addr          ), //SLV_ADDR_WIDTH
        .arb_write_req       (arb_7_write_req     ),
        .arb_read_req        (arb_7_read_req      ),
        .arb_burst_begin     (arb_7_burst_begin   ),
        .arb_burst_count     (arb_7_burst_count   ),
        .arb_wdata           (arb_7_wdata         ),
        .arb_byteenable      (arb_7_byteenable    ),
        .arb_rdata           (arb_7_rdata         ),
        .arb_rdata_valid     (arb_7_rdata_valid   ),
        .arb_waitrequest     (arb_7_waitrequest   )
    );



    //--------------------------------------------------------------------------
    // Slave port 8
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_8 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_8_addr          ),
        .slv_write_req       (slv_8_write_req     ),
        .slv_read_req        (slv_8_read_req      ),
        .slv_burst_begin     (slv_8_burst_begin   ),
        .slv_burst_count     (slv_8_burst_count   ),
        .slv_wdata           (slv_8_wdata         ),
        .slv_byteenable      (slv_8_byteenable    ),
        .slv_rdata           (slv_8_rdata         ),
        .slv_rdata_valid     (slv_8_rdata_valid   ),
        .slv_waitrequest     (slv_8_waitrequest   ),

        .arb_addr            (arb_8_addr          ),
        .arb_write_req       (arb_8_write_req     ),
        .arb_read_req        (arb_8_read_req      ),
        .arb_burst_begin     (arb_8_burst_begin   ),
        .arb_burst_count     (arb_8_burst_count   ),
        .arb_wdata           (arb_8_wdata         ),
        .arb_byteenable      (arb_8_byteenable    ),
        .arb_rdata           (arb_8_rdata         ),
        .arb_rdata_valid     (arb_8_rdata_valid   ),
        .arb_waitrequest     (arb_8_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // Slave port 9
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_9 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_9_addr          ),
        .slv_write_req       (slv_9_write_req     ),
        .slv_read_req        (slv_9_read_req      ),
        .slv_burst_begin     (slv_9_burst_begin   ),
        .slv_burst_count     (slv_9_burst_count   ),
        .slv_wdata           (slv_9_wdata         ),
        .slv_byteenable      (slv_9_byteenable    ),
        .slv_rdata           (slv_9_rdata         ),
        .slv_rdata_valid     (slv_9_rdata_valid   ),
        .slv_waitrequest     (slv_9_waitrequest   ),

        .arb_addr            (arb_9_addr          ),
        .arb_write_req       (arb_9_write_req     ),
        .arb_read_req        (arb_9_read_req      ),
        .arb_burst_begin     (arb_9_burst_begin   ),
        .arb_burst_count     (arb_9_burst_count   ),
        .arb_wdata           (arb_9_wdata         ),
        .arb_byteenable      (arb_9_byteenable    ),
        .arb_rdata           (arb_9_rdata         ),
        .arb_rdata_valid     (arb_9_rdata_valid   ),
        .arb_waitrequest     (arb_9_waitrequest   )
    );

        //--------------------------------------------------------------------------
    // Slave port 10
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_10 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_10_addr          ),
        .slv_write_req       (slv_10_write_req     ),
        .slv_read_req        (slv_10_read_req      ),
        .slv_burst_begin     (slv_10_burst_begin   ),
        .slv_burst_count     (slv_10_burst_count   ),
        .slv_wdata           (slv_10_wdata         ),
        .slv_byteenable      (slv_10_byteenable    ),
        .slv_rdata           (slv_10_rdata         ),
        .slv_rdata_valid     (slv_10_rdata_valid   ),
        .slv_waitrequest     (slv_10_waitrequest   ),

        .arb_addr            (arb_10_addr          ),
        .arb_write_req       (arb_10_write_req     ),
        .arb_read_req        (arb_10_read_req      ),
        .arb_burst_begin     (arb_10_burst_begin   ),
        .arb_burst_count     (arb_10_burst_count   ),
        .arb_wdata           (arb_10_wdata         ),
        .arb_byteenable      (arb_10_byteenable    ),
        .arb_rdata           (arb_10_rdata         ),
        .arb_rdata_valid     (arb_10_rdata_valid   ),
        .arb_waitrequest     (arb_10_waitrequest   )
    );

        //--------------------------------------------------------------------------
    // Slave port 11
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_11 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_11_addr          ),
        .slv_write_req       (slv_11_write_req     ),
        .slv_read_req        (slv_11_read_req      ),
        .slv_burst_begin     (slv_11_burst_begin   ),
        .slv_burst_count     (slv_11_burst_count   ),
        .slv_wdata           (slv_11_wdata         ),
        .slv_byteenable      (slv_11_byteenable    ),
        .slv_rdata           (slv_11_rdata         ),
        .slv_rdata_valid     (slv_11_rdata_valid   ),
        .slv_waitrequest     (slv_11_waitrequest   ),

        .arb_addr            (arb_11_addr          ),
        .arb_write_req       (arb_11_write_req     ),
        .arb_read_req        (arb_11_read_req      ),
        .arb_burst_begin     (arb_11_burst_begin   ),
        .arb_burst_count     (arb_11_burst_count   ),
        .arb_wdata           (arb_11_wdata         ),
        .arb_byteenable      (arb_11_byteenable    ),
        .arb_rdata           (arb_11_rdata         ),
        .arb_rdata_valid     (arb_11_rdata_valid   ),
        .arb_waitrequest     (arb_11_waitrequest   )
    );

        //--------------------------------------------------------------------------
    // Slave port 12
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_12 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_12_addr          ),
        .slv_write_req       (slv_12_write_req     ),
        .slv_read_req        (slv_12_read_req      ),
        .slv_burst_begin     (slv_12_burst_begin   ),
        .slv_burst_count     (slv_12_burst_count   ),
        .slv_wdata           (slv_12_wdata         ),
        .slv_byteenable      (slv_12_byteenable    ),
        .slv_rdata           (slv_12_rdata         ),
        .slv_rdata_valid     (slv_12_rdata_valid   ),
        .slv_waitrequest     (slv_12_waitrequest   ),

        .arb_addr            (arb_12_addr          ),
        .arb_write_req       (arb_12_write_req     ),
        .arb_read_req        (arb_12_read_req      ),
        .arb_burst_begin     (arb_12_burst_begin   ),
        .arb_burst_count     (arb_12_burst_count   ),
        .arb_wdata           (arb_12_wdata         ),
        .arb_byteenable      (arb_12_byteenable    ),
        .arb_rdata           (arb_12_rdata         ),
        .arb_rdata_valid     (arb_12_rdata_valid   ),
        .arb_waitrequest     (arb_12_waitrequest   )
    );

        //--------------------------------------------------------------------------
    // Slave port 13
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_13 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_13_addr          ),
        .slv_write_req       (slv_13_write_req     ),
        .slv_read_req        (slv_13_read_req      ),
        .slv_burst_begin     (slv_13_burst_begin   ),
        .slv_burst_count     (slv_13_burst_count   ),
        .slv_wdata           (slv_13_wdata         ),
        .slv_byteenable      (slv_13_byteenable    ),
        .slv_rdata           (slv_13_rdata         ),
        .slv_rdata_valid     (slv_13_rdata_valid   ),
        .slv_waitrequest     (slv_13_waitrequest   ),

        .arb_addr            (arb_13_addr          ),
        .arb_write_req       (arb_13_write_req     ),
        .arb_read_req        (arb_13_read_req      ),
        .arb_burst_begin     (arb_13_burst_begin   ),
        .arb_burst_count     (arb_13_burst_count   ),
        .arb_wdata           (arb_13_wdata         ),
        .arb_byteenable      (arb_13_byteenable    ),
        .arb_rdata           (arb_13_rdata         ),
        .arb_rdata_valid     (arb_13_rdata_valid   ),
        .arb_waitrequest     (arb_13_waitrequest   )
    );

        //--------------------------------------------------------------------------
    // Slave port 14
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_14 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_14_addr          ),
        .slv_write_req       (slv_14_write_req     ),
        .slv_read_req        (slv_14_read_req      ),
        .slv_burst_begin     (slv_14_burst_begin   ),
        .slv_burst_count     (slv_14_burst_count   ),
        .slv_wdata           (slv_14_wdata         ),
        .slv_byteenable      (slv_14_byteenable    ),
        .slv_rdata           (slv_14_rdata         ),
        .slv_rdata_valid     (slv_14_rdata_valid   ),
        .slv_waitrequest     (slv_14_waitrequest   ),

        .arb_addr            (arb_14_addr          ),
        .arb_write_req       (arb_14_write_req     ),
        .arb_read_req        (arb_14_read_req      ),
        .arb_burst_begin     (arb_14_burst_begin   ),
        .arb_burst_count     (arb_14_burst_count   ),
        .arb_wdata           (arb_14_wdata         ),
        .arb_byteenable      (arb_14_byteenable    ),
        .arb_rdata           (arb_14_rdata         ),
        .arb_rdata_valid     (arb_14_rdata_valid   ),
        .arb_waitrequest     (arb_14_waitrequest   )
    );

        //--------------------------------------------------------------------------
    // Slave port 15
    //--------------------------------------------------------------------------
    mpfe_slave_port #(
        .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
        .DATA_WIDTH          (DATA_WIDTH          ),
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
    ) slave_port_15 (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        // Avalon interface
        .slv_addr            (slv_15_addr          ),
        .slv_write_req       (slv_15_write_req     ),
        .slv_read_req        (slv_15_read_req      ),
        .slv_burst_begin     (slv_15_burst_begin   ),
        .slv_burst_count     (slv_15_burst_count   ),
        .slv_wdata           (slv_15_wdata         ),
        .slv_byteenable      (slv_15_byteenable    ),
        .slv_rdata           (slv_15_rdata         ),
        .slv_rdata_valid     (slv_15_rdata_valid   ),
        .slv_waitrequest     (slv_15_waitrequest   ),

        .arb_addr            (arb_15_addr          ),
        .arb_write_req       (arb_15_write_req     ),
        .arb_read_req        (arb_15_read_req      ),
        .arb_burst_begin     (arb_15_burst_begin   ),
        .arb_burst_count     (arb_15_burst_count   ),
        .arb_wdata           (arb_15_wdata         ),
        .arb_byteenable      (arb_15_byteenable    ),
        .arb_rdata           (arb_15_rdata         ),
        .arb_rdata_valid     (arb_15_rdata_valid   ),
        .arb_waitrequest     (arb_15_waitrequest   )
    );

    //--------------------------------------------------------------------------
    // the Arbiter
    //--------------------------------------------------------------------------
    mpfe_arbiter #(
        .BCOUNT_WIDTH        (BCOUNT_WIDTH        ),
        .SLAVE_COUNT         (SLAVE_COUNT         ),
        .CRITICAL_PORTS      (CRITICAL_PORTS      ),
        .SLV_0_BW_RATIO      (SLV_0_BW_RATIO      ),
        .SLV_1_BW_RATIO      (SLV_1_BW_RATIO      ),
        .SLV_2_BW_RATIO      (SLV_2_BW_RATIO      ),
        .SLV_3_BW_RATIO      (SLV_3_BW_RATIO      ),
        .SLV_4_BW_RATIO      (SLV_4_BW_RATIO      ),
        .SLV_5_BW_RATIO      (SLV_5_BW_RATIO      ),
        .SLV_6_BW_RATIO      (SLV_6_BW_RATIO      ),
        .SLV_7_BW_RATIO      (SLV_7_BW_RATIO      ),
        .SLV_8_BW_RATIO      (SLV_8_BW_RATIO      ),
        .SLV_9_BW_RATIO      (SLV_9_BW_RATIO      ),
        .SLV_10_BW_RATIO     (SLV_10_BW_RATIO     ),
        .SLV_11_BW_RATIO     (SLV_11_BW_RATIO     ),
        .SLV_12_BW_RATIO     (SLV_12_BW_RATIO     ),
        .SLV_13_BW_RATIO     (SLV_13_BW_RATIO     ),
        .SLV_14_BW_RATIO     (SLV_14_BW_RATIO     ),
        .SLV_15_BW_RATIO     (SLV_15_BW_RATIO     )

    )  arbiter
    (
        .clk                 (clk                 ),
        .reset_n             (reset_n             ),

        .arb_0_write_req     (arb_0_write_req     ),
        .arb_0_read_req      (arb_0_read_req      ),
        .arb_0_burst_begin   (arb_0_burst_begin   ),
        .arb_0_burst_count   (arb_0_burst_count   ),
        .arb_0_waitrequest   (arb_0_waitrequest   ),

        .arb_1_write_req     (arb_1_write_req     ),
        .arb_1_read_req      (arb_1_read_req      ),
        .arb_1_burst_begin   (arb_1_burst_begin   ),
        .arb_1_burst_count   (arb_1_burst_count   ),
        .arb_1_waitrequest   (arb_1_waitrequest   ),

        .arb_2_write_req     (arb_2_write_req     ),
        .arb_2_read_req      (arb_2_read_req      ),
        .arb_2_burst_begin   (arb_2_burst_begin   ),
        .arb_2_burst_count   (arb_2_burst_count   ),
        .arb_2_waitrequest   (arb_2_waitrequest   ),

        .arb_3_write_req     (arb_3_write_req     ),
        .arb_3_read_req      (arb_3_read_req      ),
        .arb_3_burst_begin   (arb_3_burst_begin   ),
        .arb_3_burst_count   (arb_3_burst_count   ),
        .arb_3_waitrequest   (arb_3_waitrequest   ),

        .arb_4_write_req     (arb_4_write_req     ),
        .arb_4_read_req      (arb_4_read_req      ),
        .arb_4_burst_begin   (arb_4_burst_begin   ),
        .arb_4_burst_count   (arb_4_burst_count   ),
        .arb_4_waitrequest   (arb_4_waitrequest   ),

        .arb_5_write_req     (arb_5_write_req     ),
        .arb_5_read_req      (arb_5_read_req      ),
        .arb_5_burst_begin   (arb_5_burst_begin   ),
        .arb_5_burst_count   (arb_5_burst_count   ),
        .arb_5_waitrequest   (arb_5_waitrequest   ),

        .arb_6_write_req     (arb_6_write_req     ),
        .arb_6_read_req      (arb_6_read_req      ),
        .arb_6_burst_begin   (arb_6_burst_begin   ),
        .arb_6_burst_count   (arb_6_burst_count   ),
        .arb_6_waitrequest   (arb_6_waitrequest   ),

        .arb_7_write_req     (arb_7_write_req     ),
        .arb_7_read_req      (arb_7_read_req      ),
        .arb_7_burst_begin   (arb_7_burst_begin   ),
        .arb_7_burst_count   (arb_7_burst_count   ),
        .arb_7_waitrequest   (arb_7_waitrequest   ),

        .arb_8_write_req     (arb_8_write_req     ),
        .arb_8_read_req      (arb_8_read_req      ),
        .arb_8_burst_begin   (arb_8_burst_begin   ),
        .arb_8_burst_count   (arb_8_burst_count   ),
        .arb_8_waitrequest   (arb_8_waitrequest   ),

        .arb_9_write_req     (arb_9_write_req     ),
        .arb_9_read_req      (arb_9_read_req      ),
        .arb_9_burst_begin   (arb_9_burst_begin   ),
        .arb_9_burst_count   (arb_9_burst_count   ),
        .arb_9_waitrequest   (arb_9_waitrequest   ),

        .arb_10_write_req     (arb_10_write_req     ),
        .arb_10_read_req      (arb_10_read_req      ),
        .arb_10_burst_begin   (arb_10_burst_begin   ),
        .arb_10_burst_count   (arb_10_burst_count   ),
        .arb_10_waitrequest   (arb_10_waitrequest   ),

        .arb_11_write_req     (arb_11_write_req     ),
        .arb_11_read_req      (arb_11_read_req      ),
        .arb_11_burst_begin   (arb_11_burst_begin   ),
        .arb_11_burst_count   (arb_11_burst_count   ),
        .arb_11_waitrequest   (arb_11_waitrequest   ),

        .arb_12_write_req     (arb_12_write_req     ),
        .arb_12_read_req      (arb_12_read_req      ),
        .arb_12_burst_begin   (arb_12_burst_begin   ),
        .arb_12_burst_count   (arb_12_burst_count   ),
        .arb_12_waitrequest   (arb_12_waitrequest   ),

        .arb_13_write_req     (arb_13_write_req     ),
        .arb_13_read_req      (arb_13_read_req      ),
        .arb_13_burst_begin   (arb_13_burst_begin   ),
        .arb_13_burst_count   (arb_13_burst_count   ),
        .arb_13_waitrequest   (arb_13_waitrequest   ),

        .arb_14_write_req     (arb_14_write_req     ),
        .arb_14_read_req      (arb_14_read_req      ),
        .arb_14_burst_begin   (arb_14_burst_begin   ),
        .arb_14_burst_count   (arb_14_burst_count   ),
        .arb_14_waitrequest   (arb_14_waitrequest   ),

        .arb_15_write_req     (arb_15_write_req     ),
        .arb_15_read_req      (arb_15_read_req      ),
        .arb_15_burst_begin   (arb_15_burst_begin   ),
        .arb_15_burst_count   (arb_15_burst_count   ),
        .arb_15_waitrequest   (arb_15_waitrequest   ),

        .mst_waitrequest      (mst_waitrequest      ),

        .new_port_granted     (new_port_granted     ),
        .arb_req              (arb_req              ),
        .arb_grant            (arb_grant            ),
        .arb_granted_wr       (arb_granted_wr       ),
        .arb_granted_rd       (arb_granted_rd       )
    );

    //--------------------------------------------------------------------------
    // Debug slave port
    //--------------------------------------------------------------------------
    generate
        if (DEBUG_PORT_ENABLED) begin
            mpfe_debug_port #(
                .SLAVE_COUNT         (SLAVE_COUNT         ),
                .SLV_ADDR_WIDTH      (SLV_ADDR_WIDTH      ),
                .BCOUNT_WIDTH        (BCOUNT_WIDTH        )
            ) debug_port (
                .clk                 (clk                 ),
                .reset_n             (reset_n             ),

                .mst_waitrequest     (mst_waitrequest     ),
                .mst_write_req       (mst_write_req       ),
                .rdata_valid_out     (rdata_valid_out     ),

                .arb_0_burst_count   (arb_0_burst_count   ),
                .arb_1_burst_count   (arb_1_burst_count   ),
                .arb_2_burst_count   (arb_2_burst_count   ),
                .arb_3_burst_count   (arb_3_burst_count   ),
                .arb_4_burst_count   (arb_4_burst_count   ),
                .arb_5_burst_count   (arb_5_burst_count   ),
                .arb_6_burst_count   (arb_6_burst_count   ),
                .arb_7_burst_count   (arb_7_burst_count   ),
                .arb_8_burst_count   (arb_8_burst_count   ),
                .arb_9_burst_count   (arb_9_burst_count   ),
                .arb_10_burst_count  (arb_10_burst_count  ),
                .arb_11_burst_count  (arb_11_burst_count  ),
                .arb_12_burst_count  (arb_12_burst_count  ),
                .arb_13_burst_count  (arb_13_burst_count  ),
                .arb_14_burst_count  (arb_14_burst_count  ),
                .arb_15_burst_count  (arb_15_burst_count  ),

                // arbitration decisions
                .new_port_granted    (new_port_granted    ),
                .arb_req             (arb_req             ),
                .arb_grant           (arb_grant           ),
                .arb_granted_wr      (arb_granted_wr      ),
                .arb_granted_rd      (arb_granted_rd      ),

                .dbg_write_req       (avdbg_write_req       ),
                .dbg_read_req        (avdbg_read_req        ),
                .dbg_addr            (avdbg_addr            ),
                .dbg_wdata           (avdbg_wdata           ),
                .dbg_rdata_valid     (avdbg_rdata_valid     ),
                .dbg_rdata           (avdbg_rdata           )
            );
        end
    endgenerate

//----------------------------------------------------------------------------
generate
if (INTERNAL_JTAGNODE > 0) begin:g_internal_jtagnode1
//simulation
//in simulation drive this bus from the testbench ...
//synthesis translate_off
reg  [15:0] avjtag_address;
reg         avjtag_waitrequest;
reg   [3:0] avjtag_byteenable;
reg         avjtag_write;
reg  [31:0] avjtag_writedata;
reg         avjtag_read;
wire [31:0] avjtag_readdata;

//synthesis translate_on

//synthesis
//alt_jtagavalon is little endian ... do a byte-swap
//
//*** these comments are stripped for synthesis ***
//synthesis read_comments_as_HDL on
/*
wire [15:0] avjtag_address;
wire        avjtag_waitrequest;
wire        avjtag_write_n;
wire        avjtag_write;
wire  [3:0] avjtag_byteenable = 4'hf;
wire [31:0] avjtag_writedata;
wire        avjtag_read_n;
wire        avjtag_read;
wire [31:0] avjtag_readdata;

alt_jtagavalon #(
    .ADDR_WIDTH         (16),
    .DATA_WIDTH         (32),
    .MODE_WIDTH         (3),
    .INSTANCE_ID        (MONITOR_INSTANCE_ID),
    .OWNER_ID           (8'h01),
    .USAGE_ID           (12'h002),
    .USER_ID1           (8'h00),
    .USER_ID2           (12'h000)
)alt_jtagavalon(
    .clk                (clk),
    .rst_n              (reset_n),
    .av_address         (avjtag_address),
    .av_waitrequest     (avjtag_waitrequest),
    .av_write_n         (avjtag_write_n),
    .av_writedata       (avjtag_writedata),
    .av_read_n          (avjtag_read_n),
    .av_readdata        (avjtag_readdata)
);
assign avjtag_write = ~avjtag_write_n;
assign avjtag_read  = ~avjtag_read_n;



*/
//synthesis read_comments_as_HDL off
reg avdbg_read_req_reg, avdbg_write_req_reg;
reg avdbg_waitrequest_reg;

always @(posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        avdbg_waitrequest <= 1'b1;
        avdbg_waitrequest_reg <= 1'b1;
        avdbg_read_req_reg <= 1'b0;
        avdbg_write_req_reg <= 1'b0;
    end
    else begin
        avdbg_read_req_reg <= avdbg_read_req;
        avdbg_write_req_reg <= avdbg_write_req;
        avdbg_waitrequest_reg <= avdbg_waitrequest;
        //1WS 
        // avdbg_waitrequest <= (1'b1 & (avdbg_read_req | avdbg_write_req) & avdbg_waitrequest) ? 1'b0 : 1'b1;
        //2WS - MPFE debug needs 2 - reg in & reg out
        avdbg_waitrequest <= (1'b1 & (avdbg_read_req_reg | avdbg_write_req_reg) & avdbg_waitrequest & avdbg_waitrequest_reg) ? 1'b0 : 1'b1;
    end
end

//    assign avhost_waitrequest = 1'b0;
    assign dbg_rdata    = 32'h0;
//    assign avhost_readvalid   = 1'b0;
//    assign avdbg_addr[7:0]   = {avjtag_address[5:0], 2'b00}; //make byte address
//    assign avdbg_addr[7:0]   = avjtag_address[7:0]; //make byte address
    assign avdbg_addr[7:0]   = avjtag_address[9:2]; //make word address for MPFE
    assign avjtag_waitrequest = avdbg_waitrequest;
//    assign av_byteenable      = avjtag_byteenable;
    assign avdbg_write_req    = avjtag_write;
    assign avdbg_wdata        = avjtag_writedata;
    assign avdbg_read_req     = avjtag_read;
    assign avjtag_readdata    = avdbg_rdata;
end
else begin:g_internal_jtagnode0

    assign avdbg_addr[7:0]   = {dbg_addr[7:0]}; // may need to map straight through
//    assign avhost_waitrequest = av_waitrequest; //no waitrequest
//    assign av_byteenable      = avhost_byteenable; //no byte enables
    assign avdbg_write_req    = dbg_write_req;
    assign avdbg_wdata        = dbg_wdata;
    assign avdbg_read_req     = dbg_read_req;
    assign dbg_rdata          = avdbg_rdata;
    assign dbg_rdata_valid    = avdbg_rdata_valid;
end
endgenerate




    // pack into an array
    always @(*) begin
        arb_req[0] = arb_0_write_req || arb_0_read_req;
        arb_req[1] = arb_1_write_req || arb_1_read_req;
        arb_req[2] = arb_2_write_req || arb_2_read_req;
        arb_req[3] = arb_3_write_req || arb_3_read_req;
        arb_req[4] = arb_4_write_req || arb_4_read_req;
        arb_req[5] = arb_5_write_req || arb_5_read_req;
        arb_req[6] = arb_6_write_req || arb_6_read_req;
        arb_req[7] = arb_7_write_req || arb_7_read_req;
        arb_req[8] = arb_8_write_req || arb_8_read_req;
        arb_req[9] = arb_9_write_req || arb_9_read_req;
        arb_req[10] = arb_10_write_req || arb_10_read_req;
        arb_req[11] = arb_11_write_req || arb_11_read_req;
        arb_req[12] = arb_12_write_req || arb_12_read_req;
        arb_req[13] = arb_13_write_req || arb_13_read_req;
        arb_req[14] = arb_14_write_req || arb_14_read_req;
        arb_req[15] = arb_15_write_req || arb_15_read_req;
    end




    always @(*) begin
        arb_0_waitrequest = resolved_waitrequest || ( !arb_grant[0]);
        arb_1_waitrequest = resolved_waitrequest || ( !arb_grant[1]);
        arb_2_waitrequest = resolved_waitrequest || ( !arb_grant[2]);
        arb_3_waitrequest = resolved_waitrequest || ( !arb_grant[3]);
        arb_4_waitrequest = resolved_waitrequest || ( !arb_grant[4]);
        arb_5_waitrequest = resolved_waitrequest || ( !arb_grant[5]);
        arb_6_waitrequest = resolved_waitrequest || ( !arb_grant[6]);
        arb_7_waitrequest = resolved_waitrequest || ( !arb_grant[7]);
        arb_8_waitrequest = resolved_waitrequest || ( !arb_grant[8]);
        arb_9_waitrequest = resolved_waitrequest || ( !arb_grant[9]);
        arb_10_waitrequest = resolved_waitrequest || ( !arb_grant[10]);
        arb_11_waitrequest = resolved_waitrequest || ( !arb_grant[11]);
        arb_12_waitrequest = resolved_waitrequest || ( !arb_grant[12]);
        arb_13_waitrequest = resolved_waitrequest || ( !arb_grant[13]);
        arb_14_waitrequest = resolved_waitrequest || ( !arb_grant[14]);
        arb_15_waitrequest = resolved_waitrequest || ( !arb_grant[15]);
    end

    always @(*) begin
        if (arb_grant[0]) begin
            resolved_write_req       = arb_0_write_req && arb_granted_wr;
            resolved_read_req        = arb_0_read_req  && arb_granted_rd;
            resolved_addr            = arb_0_addr;
            resolved_wdata           = arb_0_wdata;
            resolved_byteenable      = arb_0_byteenable;
            resolved_burst_count     = arb_0_burst_count;
            resolved_burst_begin     = arb_0_burst_begin;
        end
        else if (arb_grant[1]) begin
            resolved_write_req       = arb_1_write_req && arb_granted_wr;
            resolved_read_req        = arb_1_read_req  && arb_granted_rd;
            resolved_addr            = arb_1_addr;
            resolved_wdata           = arb_1_wdata;
            resolved_byteenable      = arb_1_byteenable;
            resolved_burst_count     = arb_1_burst_count;
            resolved_burst_begin     = arb_1_burst_begin;
        end
        else if (arb_grant[2]) begin
            resolved_write_req       = arb_2_write_req && arb_granted_wr;
            resolved_read_req        = arb_2_read_req  && arb_granted_rd;
            resolved_addr            = arb_2_addr;
            resolved_wdata           = arb_2_wdata;
            resolved_byteenable      = arb_2_byteenable;
            resolved_burst_count     = arb_2_burst_count;
            resolved_burst_begin     = arb_2_burst_begin;
        end
        else if (arb_grant[3]) begin
            resolved_write_req       = arb_3_write_req && arb_granted_wr;
            resolved_read_req        = arb_3_read_req  && arb_granted_rd;
            resolved_addr            = arb_3_addr;
            resolved_wdata           = arb_3_wdata;
            resolved_byteenable      = arb_3_byteenable;
            resolved_burst_count     = arb_3_burst_count;
            resolved_burst_begin     = arb_3_burst_begin;
        end
        else if (arb_grant[4]) begin
            resolved_write_req       = arb_4_write_req && arb_granted_wr;
            resolved_read_req        = arb_4_read_req  && arb_granted_rd;
            resolved_addr            = arb_4_addr;
            resolved_wdata           = arb_4_wdata;
            resolved_byteenable      = arb_4_byteenable;
            resolved_burst_count     = arb_4_burst_count;
            resolved_burst_begin     = arb_4_burst_begin;
        end
        else if (arb_grant[5]) begin
            resolved_write_req       = arb_5_write_req && arb_granted_wr;
            resolved_read_req        = arb_5_read_req  && arb_granted_rd;
            resolved_addr            = arb_5_addr;
            resolved_wdata           = arb_5_wdata;
            resolved_byteenable      = arb_5_byteenable;
            resolved_burst_count     = arb_5_burst_count;
            resolved_burst_begin     = arb_5_burst_begin;
        end
        else if (arb_grant[6]) begin
            resolved_write_req       = arb_6_write_req && arb_granted_wr;
            resolved_read_req        = arb_6_read_req  && arb_granted_rd;
            resolved_addr            = arb_6_addr;
            resolved_wdata           = arb_6_wdata;
            resolved_byteenable      = arb_6_byteenable;
            resolved_burst_count     = arb_6_burst_count;
            resolved_burst_begin     = arb_6_burst_begin;
        end
        else if (arb_grant[7]) begin
            resolved_write_req       = arb_7_write_req && arb_granted_wr;
            resolved_read_req        = arb_7_read_req  && arb_granted_rd;
            resolved_addr            = arb_7_addr;
            resolved_wdata           = arb_7_wdata;
            resolved_byteenable      = arb_7_byteenable;
            resolved_burst_count     = arb_7_burst_count;
            resolved_burst_begin     = arb_7_burst_begin;
        end
        else if (arb_grant[8]) begin
            resolved_write_req       = arb_8_write_req && arb_granted_wr;
            resolved_read_req        = arb_8_read_req  && arb_granted_rd;
            resolved_addr            = arb_8_addr;
            resolved_wdata           = arb_8_wdata;
            resolved_byteenable      = arb_8_byteenable;
            resolved_burst_count     = arb_8_burst_count;
            resolved_burst_begin     = arb_8_burst_begin;
        end
        else if (arb_grant[9]) begin
            resolved_write_req       = arb_9_write_req && arb_granted_wr;
            resolved_read_req        = arb_9_read_req  && arb_granted_rd;
            resolved_addr            = arb_9_addr;
            resolved_wdata           = arb_9_wdata;
            resolved_byteenable      = arb_9_byteenable;
            resolved_burst_count     = arb_9_burst_count;
            resolved_burst_begin     = arb_9_burst_begin;
        end
        else if (arb_grant[10]) begin
            resolved_write_req       = arb_10_write_req && arb_granted_wr;
            resolved_read_req        = arb_10_read_req  && arb_granted_rd;
            resolved_addr            = arb_10_addr;
            resolved_wdata           = arb_10_wdata;
            resolved_byteenable      = arb_10_byteenable;
            resolved_burst_count     = arb_10_burst_count;
            resolved_burst_begin     = arb_10_burst_begin;
        end
        else if (arb_grant[11]) begin
            resolved_write_req       = arb_11_write_req && arb_granted_wr;
            resolved_read_req        = arb_11_read_req  && arb_granted_rd;
            resolved_addr            = arb_11_addr;
            resolved_wdata           = arb_11_wdata;
            resolved_byteenable      = arb_11_byteenable;
            resolved_burst_count     = arb_11_burst_count;
            resolved_burst_begin     = arb_11_burst_begin;
        end
        else if (arb_grant[12]) begin
            resolved_write_req       = arb_12_write_req && arb_granted_wr;
            resolved_read_req        = arb_12_read_req  && arb_granted_rd;
            resolved_addr            = arb_12_addr;
            resolved_wdata           = arb_12_wdata;
            resolved_byteenable      = arb_12_byteenable;
            resolved_burst_count     = arb_12_burst_count;
            resolved_burst_begin     = arb_12_burst_begin;
        end
        else if (arb_grant[13]) begin
            resolved_write_req       = arb_13_write_req && arb_granted_wr;
            resolved_read_req        = arb_13_read_req  && arb_granted_rd;
            resolved_addr            = arb_13_addr;
            resolved_wdata           = arb_13_wdata;
            resolved_byteenable      = arb_13_byteenable;
            resolved_burst_count     = arb_13_burst_count;
            resolved_burst_begin     = arb_13_burst_begin;
        end
        else if (arb_grant[14]) begin
            resolved_write_req       = arb_14_write_req && arb_granted_wr;
            resolved_read_req        = arb_14_read_req  && arb_granted_rd;
            resolved_addr            = arb_14_addr;
            resolved_wdata           = arb_14_wdata;
            resolved_byteenable      = arb_14_byteenable;
            resolved_burst_count     = arb_14_burst_count;
            resolved_burst_begin     = arb_14_burst_begin;
        end
        else if (arb_grant[15]) begin
            resolved_write_req       = arb_15_write_req && arb_granted_wr;
            resolved_read_req        = arb_15_read_req  && arb_granted_rd;
            resolved_addr            = arb_15_addr;
            resolved_wdata           = arb_15_wdata;
            resolved_byteenable      = arb_15_byteenable;
            resolved_burst_count     = arb_15_burst_count;
            resolved_burst_begin     = arb_15_burst_begin;
        end

        else begin
            resolved_write_req       = 1'b0;
            resolved_read_req        = 1'b0;
            resolved_addr            = 0;
            resolved_wdata           = 0;
            resolved_byteenable      = 0;
            resolved_burst_count     = 0;
            resolved_burst_begin     = 0;
        end
    end




    //--------------------------------------------------------------------------
    // FIFO to store which master to return the read data to
    //
    // write side
    //--------------------------------------------------------------------------
    assign addr_fifo_data_in = {arb_grant_r, mst_burst_count};
    assign addr_fifo_wren = (mst_burst_begin && mst_read_req);

    assign rdata_next_bcount  = addr_fifo_data_out[BCOUNT_WIDTH-1: 0];
    assign rdata_next_master  = addr_fifo_data_out[SLAVE_COUNT+BCOUNT_WIDTH-1: BCOUNT_WIDTH];

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            arb_grant_r <= 0;
        end
        else begin
            arb_grant_r <= arb_grant;
        end
    end


    //--------------------------------------------------------------------------
    // FIFO to store which master to return the read data to
    //
    // read side
    //--------------------------------------------------------------------------

    always @(posedge clk, negedge reset_n) begin
        if (!reset_n)
            begin
                rdata_state <= 0;
                addr_fifo_rden <= 1'b0;
                rdata_burstcount <= 0;
                rdata_master <= 0;
                rdata_valid_out <= 0;
                data_fifo_rden <= 0;
            end
        else begin

            if (data_fifo_rden && rdata_burstcount > 0) rdata_burstcount <= rdata_burstcount - 1'b1;

            data_fifo_rden <= (((rdata_burstcount > 1) && !data_fifo_almost_empty) || (!data_fifo_rden && rdata_burstcount == 1 && !data_fifo_empty));
            rdata_valid_out <= data_fifo_rden;

            case (rdata_state)
                'h0 :  // reset state
                    begin
                        addr_fifo_rden <= 1'b0;
                        rdata_state <= 'h1;
                    end
                'h1 : // Idle
                    begin

                        if (!data_fifo_empty && !addr_fifo_empty && rdata_burstcount <= 1) begin
                            addr_fifo_rden <= 1'b1;
                            rdata_state <= 'h2;
                        end
                    end
                'h2 :
                    begin
                        addr_fifo_rden <= 1'b0;
                        rdata_state <= 'h3;
                    end
                'h3 :
                    begin
                        if (!data_fifo_empty) begin
                            addr_fifo_rden <= 1'b0;
                            rdata_state <= 'h1;
                            rdata_master <= rdata_next_master;
                            rdata_burstcount <= rdata_next_bcount;
                        end
                    end
                default :
                    begin
                        rdata_state <= 'h1;
                    end
            endcase
        end
    end


    // fan out rdata to all the waiting masters
    assign arb_0_rdata = data_fifo_data_out;
    assign arb_1_rdata = data_fifo_data_out;
    assign arb_2_rdata = data_fifo_data_out;
    assign arb_3_rdata = data_fifo_data_out;
    assign arb_4_rdata = data_fifo_data_out;
    assign arb_5_rdata = data_fifo_data_out;
    assign arb_6_rdata = data_fifo_data_out;
    assign arb_7_rdata = data_fifo_data_out;
    assign arb_8_rdata = data_fifo_data_out;
    assign arb_9_rdata = data_fifo_data_out;
    assign arb_10_rdata = data_fifo_data_out;
    assign arb_11_rdata = data_fifo_data_out;
    assign arb_12_rdata = data_fifo_data_out;
    assign arb_13_rdata = data_fifo_data_out;
    assign arb_14_rdata = data_fifo_data_out;
    assign arb_15_rdata = data_fifo_data_out;

    assign arb_0_rdata_valid = rdata_master[0] && rdata_valid_out;
    assign arb_1_rdata_valid = rdata_master[1] && rdata_valid_out;
    assign arb_2_rdata_valid = rdata_master[2] && rdata_valid_out;
    assign arb_3_rdata_valid = rdata_master[3] && rdata_valid_out;
    assign arb_4_rdata_valid = rdata_master[4] && rdata_valid_out;
    assign arb_5_rdata_valid = rdata_master[5] && rdata_valid_out;
    assign arb_6_rdata_valid = rdata_master[6] && rdata_valid_out;
    assign arb_7_rdata_valid = rdata_master[7] && rdata_valid_out;
    assign arb_8_rdata_valid = rdata_master[8] && rdata_valid_out;
    assign arb_9_rdata_valid = rdata_master[9] && rdata_valid_out;
    assign arb_10_rdata_valid = rdata_master[10] && rdata_valid_out;
    assign arb_11_rdata_valid = rdata_master[11] && rdata_valid_out;
    assign arb_12_rdata_valid = rdata_master[12] && rdata_valid_out;
    assign arb_13_rdata_valid = rdata_master[13] && rdata_valid_out;
    assign arb_14_rdata_valid = rdata_master[14] && rdata_valid_out;
    assign arb_15_rdata_valid = rdata_master[15] && rdata_valid_out;

    // register inputs from slave
    always @(posedge clk, negedge reset_n) begin
        if (!reset_n) begin
            resolved_rdata_r <= 0;
            rdata_valid_r <= 0;
        end
        else begin
            resolved_rdata_r <= resolved_rdata;
            rdata_valid_r <= resolved_rdata_valid;
        end
    end

    // Read data return FIFO
    mpfe_fifo #(
        .FIFO_WIDTH      (DATA_WIDTH),
        .FIFO_DEPTH      (128),
        .FIFO_DEPTH_BITS (7)
    ) data_fifo (
        .clock          (clk),
        .data           (resolved_rdata_r ),
        .rdreq          (data_fifo_rden),
        .wrreq          (rdata_valid_r),
        .empty          (data_fifo_empty),
        .almost_empty   (data_fifo_almost_empty),
        .full           (data_fifo_full),
        .q              (data_fifo_data_out)

    );

    // Address FIFO to manage where to return the data to
    mpfe_fifo #(
        .FIFO_WIDTH      (SLAVE_COUNT+BCOUNT_WIDTH),
        .FIFO_DEPTH      (128),
        .FIFO_DEPTH_BITS (7)
    ) addr_fifo (
        .clock          (clk),
        .data           (addr_fifo_data_in ),
        .rdreq          (addr_fifo_rden),
        .wrreq          (addr_fifo_wren),
        .empty          (addr_fifo_empty),
        .almost_empty   (addr_fifo_almost_empty),
        .full           (addr_fifo_full),
        .q              (addr_fifo_data_out)

    );

    // synopsys translate_off
    always @(posedge clk) begin

        if (addr_fifo_empty && addr_fifo_rden) begin
            $display($time, " : ERROR - MPFE Read return - ADDRESS fifo underflow!");
            $stop;
        end

        if (addr_fifo_full) begin
            $display($time, " : ERROR - MPFE Read return - ADDRESS fifo overflow!");
            $stop;
        end

        if (data_fifo_full) begin
            $display($time, " : ERROR - MPFE Read return - DATA fifo overflow!");
            $stop;
        end

        if (data_fifo_empty && data_fifo_rden) begin
            $display($time, " : ERROR - MPFE Read return - DATA fifo underflow!");
            $stop;
        end
    end;
    // synopsys translate_on




    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    mpfe_master_port #(
        .SLV_ADDR_WIDTH (SLV_ADDR_WIDTH   ),
        .MST_ADDR_WIDTH (MST_ADDR_WIDTH   ),
        .DATA_WIDTH     (DATA_WIDTH   ),
        .BCOUNT_WIDTH   (BCOUNT_WIDTH )
    ) master     (
        .clk                    (clk                   ),
        .reset_n                (reset_n               ),

        // Avalon interface
        .res_addr               (resolved_addr         ),
        .res_write_req          (resolved_write_req    ),
        .res_read_req           (resolved_read_req     ),
        .res_burst_count        (resolved_burst_count  ),
        .res_burst_begin        (resolved_burst_begin  ),
        .res_wdata              (resolved_wdata        ),
        .res_byteenable         (resolved_byteenable   ),
        .res_rdata              (resolved_rdata        ),
        .res_rdata_valid        (resolved_rdata_valid  ),
        .res_waitrequest        (resolved_waitrequest  ),

        .mst_addr               (mst_addr              ),
        .mst_write_req          (mst_write_req         ),
        .mst_read_req           (mst_read_req          ),
        .mst_burst_count        (mst_burst_count       ),
        .mst_burst_begin        (mst_burst_begin       ),
        .mst_wdata              (mst_wdata             ),
        .mst_byteenable         (mst_byteenable        ),
        .mst_rdata              (mst_rdata             ),
        .mst_rdata_valid        (mst_rdata_valid       ),
        .mst_waitrequest        (mst_waitrequest       )
    );


endmodule



