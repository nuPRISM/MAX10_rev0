
`timescale 1ns / 1ns

module mpfe_arbiter #( 
    parameter
        BCOUNT_WIDTH            = 3,
        WINDOW_SIZE_LIMIT       = 15,
        
        SLAVE_COUNT             = 16,
        CRITICAL_PORTS          = 1,
        
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
        SLV_15_BW_RATIO         = 1
    )
    (
        input wire                      clk,
        input wire                      reset_n,
        
        input wire                      arb_0_write_req,
        input wire                      arb_0_read_req,
        input wire                      arb_0_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_0_burst_count,
        input wire                      arb_0_waitrequest,
        
        input wire                      arb_1_write_req,
        input wire                      arb_1_read_req,
        input wire                      arb_1_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_1_burst_count,
        input wire                      arb_1_waitrequest,
 
        input wire                      arb_2_write_req,
        input wire                      arb_2_read_req,
        input wire                      arb_2_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_2_burst_count,
        input wire                      arb_2_waitrequest,

        input wire                      arb_3_write_req,
        input wire                      arb_3_read_req,
        input wire                      arb_3_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_3_burst_count,
        input wire                      arb_3_waitrequest,

        input wire                      arb_4_write_req,
        input wire                      arb_4_read_req,
        input wire                      arb_4_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_4_burst_count,
        input wire                      arb_4_waitrequest,

        input wire                      arb_5_write_req,
        input wire                      arb_5_read_req,
        input wire                      arb_5_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_5_burst_count,
        input wire                      arb_5_waitrequest,

        input wire                      arb_6_write_req,
        input wire                      arb_6_read_req,
        input wire                      arb_6_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_6_burst_count,
        input wire                      arb_6_waitrequest,
        
        input wire                      arb_7_write_req,
        input wire                      arb_7_read_req,
        input wire                      arb_7_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_7_burst_count,
        input wire                      arb_7_waitrequest,        

        input wire                      arb_8_write_req,
        input wire                      arb_8_read_req,
        input wire                      arb_8_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_8_burst_count,
        input wire                      arb_8_waitrequest,  

        input wire                      arb_9_write_req,
        input wire                      arb_9_read_req,
        input wire                      arb_9_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_9_burst_count,
        input wire                      arb_9_waitrequest,  

        input wire                      arb_10_write_req,
        input wire                      arb_10_read_req,
        input wire                      arb_10_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_10_burst_count,
        input wire                      arb_10_waitrequest,  

        input wire                      arb_11_write_req,
        input wire                      arb_11_read_req,
        input wire                      arb_11_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_11_burst_count,
        input wire                      arb_11_waitrequest,  

        input wire                      arb_12_write_req,
        input wire                      arb_12_read_req,
        input wire                      arb_12_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_12_burst_count,
        input wire                      arb_12_waitrequest,  

        input wire                      arb_13_write_req,
        input wire                      arb_13_read_req,
        input wire                      arb_13_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_13_burst_count,
        input wire                      arb_13_waitrequest,  

        input wire                      arb_14_write_req,
        input wire                      arb_14_read_req,
        input wire                      arb_14_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_14_burst_count,
        input wire                      arb_14_waitrequest,  

        input wire                      arb_15_write_req,
        input wire                      arb_15_read_req,
        input wire                      arb_15_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0] arb_15_burst_count,
        input wire                      arb_15_waitrequest,  
        
        input wire                      mst_waitrequest,
        
        output reg                      new_port_granted,
        input wire [SLAVE_COUNT-1:0]    arb_req,
        output reg [SLAVE_COUNT-1:0]    arb_grant,
        output reg                      arb_granted_wr,
        output reg                      arb_granted_rd
        
        
    );  
    
    localparam NON_CRIT_PORTS_WEIGHT = 12;
    localparam ARB_SUM = SLV_0_BW_RATIO + SLV_1_BW_RATIO + SLV_2_BW_RATIO + SLV_3_BW_RATIO + SLV_4_BW_RATIO + SLV_5_BW_RATIO + SLV_6_BW_RATIO + SLV_7_BW_RATIO + SLV_8_BW_RATIO + SLV_9_BW_RATIO + SLV_10_BW_RATIO + SLV_11_BW_RATIO + SLV_12_BW_RATIO + SLV_13_BW_RATIO + SLV_14_BW_RATIO + SLV_15_BW_RATIO;
    localparam SLV_0_WEIGHT = (CRITICAL_PORTS[0]  == 1 ?  (1.0/SLV_0_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);         
    localparam SLV_1_WEIGHT = (CRITICAL_PORTS[1]  == 1 ?  (1.0/SLV_1_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_2_WEIGHT = (CRITICAL_PORTS[2]  == 1 ?  (1.0/SLV_2_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_3_WEIGHT = (CRITICAL_PORTS[3]  == 1 ?  (1.0/SLV_3_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_4_WEIGHT = (CRITICAL_PORTS[4]  == 1 ?  (1.0/SLV_4_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_5_WEIGHT = (CRITICAL_PORTS[5]  == 1 ?  (1.0/SLV_5_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_6_WEIGHT = (CRITICAL_PORTS[6]  == 1 ?  (1.0/SLV_6_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_7_WEIGHT = (CRITICAL_PORTS[7]  == 1 ?  (1.0/SLV_7_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_8_WEIGHT = (CRITICAL_PORTS[8]  == 1 ?  (1.0/SLV_8_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_9_WEIGHT = (CRITICAL_PORTS[9]  == 1 ?  (1.0/SLV_9_BW_RATIO*ARB_SUM)  : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_10_WEIGHT =(CRITICAL_PORTS[10] == 1 ?  (1.0/SLV_10_BW_RATIO*ARB_SUM) : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_11_WEIGHT =(CRITICAL_PORTS[11] == 1 ?  (1.0/SLV_11_BW_RATIO*ARB_SUM) : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_12_WEIGHT =(CRITICAL_PORTS[12] == 1 ?  (1.0/SLV_12_BW_RATIO*ARB_SUM) : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_13_WEIGHT =(CRITICAL_PORTS[13] == 1 ?  (1.0/SLV_13_BW_RATIO*ARB_SUM) : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_14_WEIGHT =(CRITICAL_PORTS[14] == 1 ?  (1.0/SLV_14_BW_RATIO*ARB_SUM) : NON_CRIT_PORTS_WEIGHT);
    localparam SLV_15_WEIGHT =(CRITICAL_PORTS[15] == 1 ?  (1.0/SLV_15_BW_RATIO*ARB_SUM) : NON_CRIT_PORTS_WEIGHT);
                         
                         
    
    reg   [SLAVE_COUNT-1:0]  red_write_req;
    reg   [SLAVE_COUNT-1:0]  red_read_req;
    reg   [SLAVE_COUNT-1:0]  blk_write_req;
    reg   [SLAVE_COUNT-1:0]  blk_read_req;
    reg   [SLAVE_COUNT-1:0]  burst_begin;
    reg   [SLAVE_COUNT-1:0]  waitrequest;
    reg   [BCOUNT_WIDTH-1:0] burst_count [SLAVE_COUNT-1:0];

    reg [BCOUNT_WIDTH-1:0] current_grant_burstcount;
    
    reg [SLAVE_COUNT-1:0] granted_rd_in_this_cycle; 
    reg [SLAVE_COUNT-1:0] granted_wr_in_this_cycle; 
    
    reg [3:0] arb_state; 
    reg [3:0] arb_state_r; 
    integer i;

    reg   [SLAVE_COUNT-1:0] wr_bw_available; // bandwidth limit not exceeded
    reg   [SLAVE_COUNT-1:0] rd_bw_available; // bandwidth limit not exceeded
    reg   [SLAVE_COUNT-1:0] red_wr_req_allowed; // gated red write req
    reg   [SLAVE_COUNT-1:0] red_rd_req_allowed; // gated red read req
    reg   [WINDOW_SIZE_LIMIT-1:0] wr_data_in_window [SLAVE_COUNT-1:0]; // amount of data used in the sliding window
    reg   [WINDOW_SIZE_LIMIT-1:0] rd_data_in_window [SLAVE_COUNT-1:0]; // amount of data used in the sliding window
    wire  [WINDOW_SIZE_LIMIT-1:0] window_data_limit [SLAVE_COUNT-1:0]; // amount of data allowed
    
    reg   [SLAVE_COUNT-1:0] last_beat_wr; 
    reg   [SLAVE_COUNT-1:0] last_beat_rd; 

    reg first_clk;
    //reg new_port_granted;
    // reg restart_count;
    
    reg no_reads_try_writes;
    reg no_writes_try_reads;
    
    // // pack the values into a vector so we can use for-loops later... 
    assign window_data_limit[0] =   SLV_0_WEIGHT; // SLV_0_BW_RATIO;
    assign window_data_limit[1] =   SLV_1_WEIGHT; // SLV_1_BW_RATIO;
    assign window_data_limit[2] =   SLV_2_WEIGHT; // SLV_2_BW_RATIO;
    assign window_data_limit[3] =   SLV_3_WEIGHT; // SLV_3_BW_RATIO;
    assign window_data_limit[4] =   SLV_4_WEIGHT; // SLV_4_BW_RATIO;
    assign window_data_limit[5] =   SLV_5_WEIGHT; // SLV_5_BW_RATIO;
    assign window_data_limit[6] =   SLV_6_WEIGHT; // SLV_6_BW_RATIO;
    assign window_data_limit[7] =   SLV_7_WEIGHT; // SLV_7_BW_RATIO;
    assign window_data_limit[8] =   SLV_8_WEIGHT; // SLV_8_BW_RATIO;
    assign window_data_limit[9] =   SLV_9_WEIGHT; // SLV_9_BW_RATIO;
    assign window_data_limit[10] =  SLV_10_WEIGHT; // SLV_10_BW_RATIO;
    assign window_data_limit[11] =  SLV_11_WEIGHT; // SLV_11_BW_RATIO;
    assign window_data_limit[12] =  SLV_12_WEIGHT; // SLV_12_BW_RATIO;
    assign window_data_limit[13] =  SLV_13_WEIGHT; // SLV_13_BW_RATIO;
    assign window_data_limit[14] =  SLV_14_WEIGHT; // SLV_14_BW_RATIO;
    assign window_data_limit[15] =  SLV_15_WEIGHT; // SLV_15_BW_RATIO;

    // pack the connections into busses so we can use for-loops later...    
    always @(*) begin
        red_write_req[0] = arb_0_write_req && CRITICAL_PORTS[0]; 
        red_read_req[0]  = arb_0_read_req && CRITICAL_PORTS[0];
        blk_write_req[0] = arb_0_write_req && ~CRITICAL_PORTS[0]; 
        blk_read_req[0]  = arb_0_read_req && ~CRITICAL_PORTS[0];
        burst_begin[0]   = arb_0_burst_begin; 
        burst_count[0]   = arb_0_burst_count; 
        waitrequest[0]   = arb_0_waitrequest; 

        red_write_req[1] = arb_1_write_req && CRITICAL_PORTS[1]; 
        red_read_req[1]  = arb_1_read_req && CRITICAL_PORTS[1];
        blk_write_req[1] = arb_1_write_req && ~CRITICAL_PORTS[1]; 
        blk_read_req[1]  = arb_1_read_req && ~CRITICAL_PORTS[1];
        burst_begin[1]   = arb_1_burst_begin; 
        burst_count[1]   = arb_1_burst_count; 
        waitrequest[1]   = arb_1_waitrequest; 
  
        red_write_req[2] = arb_2_write_req && CRITICAL_PORTS[2]; 
        red_read_req[2]  = arb_2_read_req && CRITICAL_PORTS[2];
        blk_write_req[2] = arb_2_write_req && ~CRITICAL_PORTS[2]; 
        blk_read_req[2]  = arb_2_read_req && ~CRITICAL_PORTS[2];
        burst_begin[2]   = arb_2_burst_begin; 
        burst_count[2]   = arb_2_burst_count; 
        waitrequest[2]   = arb_2_waitrequest; 
        
        red_write_req[3] = arb_3_write_req && CRITICAL_PORTS[3]; 
        red_read_req[3]  = arb_3_read_req && CRITICAL_PORTS[3];
        blk_write_req[3] = arb_3_write_req && ~CRITICAL_PORTS[3]; 
        blk_read_req[3]  = arb_3_read_req && ~CRITICAL_PORTS[3];
        burst_begin[3]   = arb_3_burst_begin; 
        burst_count[3]   = arb_3_burst_count; 
        waitrequest[3]   = arb_3_waitrequest;       
        
        red_write_req[4] = arb_4_write_req && CRITICAL_PORTS[4]; 
        red_read_req[4]  = arb_4_read_req && CRITICAL_PORTS[4];
        blk_write_req[4] = arb_4_write_req && ~CRITICAL_PORTS[4]; 
        blk_read_req[4]  = arb_4_read_req && ~CRITICAL_PORTS[4];
        burst_begin[4]   = arb_4_burst_begin; 
        burst_count[4]   = arb_4_burst_count; 
        waitrequest[4]   = arb_4_waitrequest;   

        red_write_req[5] = arb_5_write_req && CRITICAL_PORTS[5]; 
        red_read_req[5]  = arb_5_read_req && CRITICAL_PORTS[5];
        blk_write_req[5] = arb_5_write_req && ~CRITICAL_PORTS[5]; 
        blk_read_req[5]  = arb_5_read_req && ~CRITICAL_PORTS[5];
        burst_begin[5]   = arb_5_burst_begin; 
        burst_count[5]   = arb_5_burst_count; 
        waitrequest[5]   = arb_5_waitrequest;   

        red_write_req[6] = arb_6_write_req && CRITICAL_PORTS[6]; 
        red_read_req[6]  = arb_6_read_req && CRITICAL_PORTS[6];
        blk_write_req[6] = arb_6_write_req && ~CRITICAL_PORTS[6]; 
        blk_read_req[6]  = arb_6_read_req && ~CRITICAL_PORTS[6];
        burst_begin[6]   = arb_6_burst_begin; 
        burst_count[6]   = arb_6_burst_count; 
        waitrequest[6]   = arb_6_waitrequest;   

        red_write_req[7] = arb_7_write_req && CRITICAL_PORTS[7]; 
        red_read_req[7]  = arb_7_read_req && CRITICAL_PORTS[7];
        blk_write_req[7] = arb_7_write_req && ~CRITICAL_PORTS[7]; 
        blk_read_req[7]  = arb_7_read_req && ~CRITICAL_PORTS[7];
        burst_begin[7]   = arb_7_burst_begin; 
        burst_count[7]   = arb_7_burst_count; 
        waitrequest[7]   = arb_7_waitrequest;           
        
        red_write_req[8] = arb_8_write_req && CRITICAL_PORTS[8]; 
        red_read_req[8]  = arb_8_read_req && CRITICAL_PORTS[8];
        blk_write_req[8] = arb_8_write_req && ~CRITICAL_PORTS[8]; 
        blk_read_req[8]  = arb_8_read_req && ~CRITICAL_PORTS[8];
        burst_begin[8]   = arb_8_burst_begin; 
        burst_count[8]   = arb_8_burst_count; 
        waitrequest[8]   = arb_8_waitrequest;
        
        red_write_req[9] = arb_9_write_req && CRITICAL_PORTS[9]; 
        red_read_req[9]  = arb_9_read_req && CRITICAL_PORTS[9];
        blk_write_req[9] = arb_9_write_req && ~CRITICAL_PORTS[9]; 
        blk_read_req[9]  = arb_9_read_req && ~CRITICAL_PORTS[9];
        burst_begin[9]   = arb_9_burst_begin; 
        burst_count[9]   = arb_9_burst_count; 
        waitrequest[9]   = arb_9_waitrequest;
        
        red_write_req[10] = arb_10_write_req && CRITICAL_PORTS[10]; 
        red_read_req[10]  = arb_10_read_req && CRITICAL_PORTS[10];
        blk_write_req[10] = arb_10_write_req && ~CRITICAL_PORTS[10]; 
        blk_read_req[10]  = arb_10_read_req && ~CRITICAL_PORTS[10];
        burst_begin[10]   = arb_10_burst_begin; 
        burst_count[10]   = arb_10_burst_count; 
        waitrequest[10]   = arb_10_waitrequest;
        
        red_write_req[11] = arb_11_write_req && CRITICAL_PORTS[11]; 
        red_read_req[11]  = arb_11_read_req && CRITICAL_PORTS[11];
        blk_write_req[11] = arb_11_write_req && ~CRITICAL_PORTS[11]; 
        blk_read_req[11]  = arb_11_read_req && ~CRITICAL_PORTS[11];
        burst_begin[11]   = arb_11_burst_begin; 
        burst_count[11]   = arb_11_burst_count; 
        waitrequest[11]   = arb_11_waitrequest;
        
        red_write_req[12] = arb_12_write_req && CRITICAL_PORTS[12]; 
        red_read_req[12]  = arb_12_read_req && CRITICAL_PORTS[12];
        blk_write_req[12] = arb_12_write_req && ~CRITICAL_PORTS[12]; 
        blk_read_req[12]  = arb_12_read_req && ~CRITICAL_PORTS[12];
        burst_begin[12]   = arb_12_burst_begin; 
        burst_count[12]   = arb_12_burst_count; 
        waitrequest[12]   = arb_12_waitrequest;
        
        red_write_req[13] = arb_13_write_req && CRITICAL_PORTS[13]; 
        red_read_req[13]  = arb_13_read_req && CRITICAL_PORTS[13];
        blk_write_req[13] = arb_13_write_req && ~CRITICAL_PORTS[13]; 
        blk_read_req[13]  = arb_13_read_req && ~CRITICAL_PORTS[13];
        burst_begin[13]   = arb_13_burst_begin; 
        burst_count[13]   = arb_13_burst_count; 
        waitrequest[13]   = arb_13_waitrequest; 

        red_write_req[14] = arb_14_write_req && CRITICAL_PORTS[14]; 
        red_read_req[14]  = arb_14_read_req && CRITICAL_PORTS[14];
        blk_write_req[14] = arb_14_write_req && ~CRITICAL_PORTS[14]; 
        blk_read_req[14]  = arb_14_read_req && ~CRITICAL_PORTS[14];
        burst_begin[14]   = arb_14_burst_begin; 
        burst_count[14]   = arb_14_burst_count; 
        waitrequest[14]   = arb_14_waitrequest; 

        red_write_req[15] = arb_15_write_req && CRITICAL_PORTS[15]; 
        red_read_req[15]  = arb_15_read_req && CRITICAL_PORTS[15];
        blk_write_req[15] = arb_15_write_req && ~CRITICAL_PORTS[15]; 
        blk_read_req[15]  = arb_15_read_req && ~CRITICAL_PORTS[15];
        burst_begin[15]   = arb_15_burst_begin; 
        burst_count[15]   = arb_15_burst_count; 
        waitrequest[15]   = arb_15_waitrequest;         
    end

    //--------------------------------------------------------------------------
    // the Arbiter fsm
    //--------------------------------------------------------------------------
    localparam INIT        = 'h0;
    localparam IDLE        = 'h1;
    localparam RED_WRS     = 'h4;
    localparam RED_RDS     = 'h5;
    localparam BLK_WRS     = 'h8;
    localparam BLK_RDS     = 'h9;

    //--------------------------------------------------------------------------
    // Select between RED writes
    //--------------------------------------------------------------------------
    task pick_next_red_wr;
    begin
        no_writes_try_reads <= 1'b0;
        no_reads_try_writes <= 1'b0;
        new_port_granted <= 1'b0;        
        arb_grant <= 'h0;
        arb_granted_wr <= 1'b0;
        if (wr_bw_available[0] && red_write_req[0] && !last_beat_wr[0] && CRITICAL_PORTS[0]) begin 
            arb_grant[0] <= 1'b1;
            current_grant_burstcount <= burst_count[0];
            
            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
            
            $display($time, "     Red WR, picked %0d", 0);
        end
        else if (wr_bw_available[1] && red_write_req[1] && !last_beat_wr[1] && CRITICAL_PORTS[1]) begin
            arb_grant[1] <= 1'b1;
            current_grant_burstcount <= burst_count[1];
            
            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;            
            arb_state <= RED_WRS;
            
            $display($time, "     Red WR, picked %0d", 1);
        end
        else if (wr_bw_available[2] && red_write_req[2] && !last_beat_wr[2] && CRITICAL_PORTS[2]) begin
            arb_grant[2] <= 1'b1;
            current_grant_burstcount <= burst_count[2];
            
            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
            
            $display($time, "     Red WR, picked %0d", 2);
        end
        else if (wr_bw_available[3] && red_write_req[3] && !last_beat_wr[3] && CRITICAL_PORTS[3]) begin
            arb_grant[3] <= 1'b1;
            current_grant_burstcount <= burst_count[3];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 3);
        end
        else if (wr_bw_available[4] && red_write_req[4] && !last_beat_wr[4] && CRITICAL_PORTS[4]) begin
            arb_grant[4] <= 1'b1;
            current_grant_burstcount <= burst_count[4];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 4);
        end
        else if (wr_bw_available[5] && red_write_req[5] && !last_beat_wr[5] && CRITICAL_PORTS[5]) begin
            arb_grant[5] <= 1'b1;
            current_grant_burstcount <= burst_count[5];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 5);
        end
        else if (wr_bw_available[6] && red_write_req[6] && !last_beat_wr[6] && CRITICAL_PORTS[6]) begin
            arb_grant[6] <= 1'b1;
            current_grant_burstcount <= burst_count[6];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 6);
        end
        else if (wr_bw_available[7] && red_write_req[7] && !last_beat_wr[7] && CRITICAL_PORTS[7]) begin
            arb_grant[7] <= 1'b1;
            current_grant_burstcount <= burst_count[7];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 7);
        end        
        else if (wr_bw_available[8] && red_write_req[8] && !last_beat_wr[8] && CRITICAL_PORTS[8]) begin
            arb_grant[8] <= 1'b1;
            current_grant_burstcount <= burst_count[8];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 8);
        end       
        else if (wr_bw_available[9] && red_write_req[9] && !last_beat_wr[9] && CRITICAL_PORTS[9]) begin
            arb_grant[9] <= 1'b1;
            current_grant_burstcount <= burst_count[9];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 9);
        end  
        else if (wr_bw_available[10] && red_write_req[10] && !last_beat_wr[10] && CRITICAL_PORTS[10]) begin
            arb_grant[10] <= 1'b1;
            current_grant_burstcount <= burst_count[10];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 10);
        end
        else if (wr_bw_available[11] && red_write_req[11] && !last_beat_wr[11] && CRITICAL_PORTS[11]) begin
            arb_grant[11] <= 1'b1;
            current_grant_burstcount <= burst_count[11];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 11);
        end  
        else if (wr_bw_available[12] && red_write_req[12] && !last_beat_wr[12] && CRITICAL_PORTS[12]) begin
            arb_grant[12] <= 1'b1;
            current_grant_burstcount <= burst_count[12];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 12);
        end  
        else if (wr_bw_available[13] && red_write_req[13] && !last_beat_wr[13] && CRITICAL_PORTS[13]) begin
            arb_grant[13] <= 1'b1;
            current_grant_burstcount <= burst_count[13];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 13);
        end  
        else if (wr_bw_available[14] && red_write_req[14] && !last_beat_wr[14] && CRITICAL_PORTS[14]) begin
            arb_grant[14] <= 1'b1;
            current_grant_burstcount <= burst_count[14];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 14);
        end  
        else if (wr_bw_available[15] && red_write_req[15] && !last_beat_wr[15] && CRITICAL_PORTS[15]) begin
            arb_grant[15] <= 1'b1;
            current_grant_burstcount <= burst_count[15];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_WRS;
           
            $display($time, "     Red WR, picked %0d", 15);
        end          
        else begin
            arb_granted_wr <= 1'b0;
            arb_grant <= 0;
            
            arb_state <= IDLE;
            no_writes_try_reads <= 1'b1;
            $display($time, "     Red WR, picked NONE");
        end
    end        
    endtask
    
    //--------------------------------------------------------------------------
    // Select between BLACK writes
    //--------------------------------------------------------------------------
    task pick_next_black_wr;
    begin
        no_writes_try_reads <= 1'b0;
        no_reads_try_writes <= 1'b0;
        new_port_granted <= 1'b0;        
        arb_grant <= 'h0;
        arb_granted_wr <= 1'b0;
        if (wr_bw_available[0] && blk_write_req[0] && !last_beat_wr[0] && ~CRITICAL_PORTS[0]) begin 
            arb_grant[0] <= 1'b1;
            current_grant_burstcount <= burst_count[0];
            
            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
            
            $display($time, "     Black WR, picked %0d", 0);
        end
        else if (wr_bw_available[1] && blk_write_req[1] && !last_beat_wr[1] && ~CRITICAL_PORTS[1]) begin
            arb_grant[1] <= 1'b1;
            current_grant_burstcount <= burst_count[1];
            
            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;            
            arb_state <= BLK_WRS;
            
            $display($time, "     Black WR, picked %0d", 1);
        end
        else if (wr_bw_available[2] && blk_write_req[2] && !last_beat_wr[2] && ~CRITICAL_PORTS[2]) begin
            arb_grant[2] <= 1'b1;
            current_grant_burstcount <= burst_count[2];
            
            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
            
            $display($time, "     Black WR, picked %0d", 2);
        end
        else if (wr_bw_available[3] && blk_write_req[3] && !last_beat_wr[3] && ~CRITICAL_PORTS[3]) begin
            arb_grant[3] <= 1'b1;
            current_grant_burstcount <= burst_count[3];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 3);
        end
        else if (wr_bw_available[4] && blk_write_req[4] && !last_beat_wr[4] && ~CRITICAL_PORTS[4]) begin
            arb_grant[4] <= 1'b1;
            current_grant_burstcount <= burst_count[4];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 4);
        end
        else if (wr_bw_available[5] && blk_write_req[5] && !last_beat_wr[5] && ~CRITICAL_PORTS[5]) begin
            arb_grant[5] <= 1'b1;
            current_grant_burstcount <= burst_count[5];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 5);
        end
        else if (wr_bw_available[6] && blk_write_req[6] && !last_beat_wr[6] && ~CRITICAL_PORTS[6]) begin
            arb_grant[6] <= 1'b1;
            current_grant_burstcount <= burst_count[6];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 6);
        end
        else if (wr_bw_available[7] && blk_write_req[7] && !last_beat_wr[7] && ~CRITICAL_PORTS[7]) begin
            arb_grant[7] <= 1'b1;
            current_grant_burstcount <= burst_count[7];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 7);
        end  
        else if (wr_bw_available[8] && blk_write_req[8] && !last_beat_wr[8] && ~CRITICAL_PORTS[8]) begin
            arb_grant[8] <= 1'b1;
            current_grant_burstcount <= burst_count[8];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 8);
        end         
        else if (wr_bw_available[9] && blk_write_req[9] && !last_beat_wr[9] && ~CRITICAL_PORTS[9]) begin
            arb_grant[9] <= 1'b1;
            current_grant_burstcount <= burst_count[9];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 9);
        end 
        else if (wr_bw_available[10] && blk_write_req[10] && !last_beat_wr[10] && ~CRITICAL_PORTS[10]) begin
            arb_grant[10] <= 1'b1;
            current_grant_burstcount <= burst_count[10];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 10);
        end 
        else if (wr_bw_available[11] && blk_write_req[11] && !last_beat_wr[11] && ~CRITICAL_PORTS[11]) begin
            arb_grant[11] <= 1'b1;
            current_grant_burstcount <= burst_count[11];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 11);
        end 
        else if (wr_bw_available[12] && blk_write_req[12] && !last_beat_wr[12] && ~CRITICAL_PORTS[12]) begin
            arb_grant[12] <= 1'b1;
            current_grant_burstcount <= burst_count[12];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 12);
        end 
        else if (wr_bw_available[13] && blk_write_req[13] && !last_beat_wr[13] && ~CRITICAL_PORTS[13]) begin
            arb_grant[13] <= 1'b1;
            current_grant_burstcount <= burst_count[13];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 13);
        end 
        else if (wr_bw_available[14] && blk_write_req[14] && !last_beat_wr[14] && ~CRITICAL_PORTS[14]) begin
            arb_grant[14] <= 1'b1;
            current_grant_burstcount <= burst_count[14];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 14);
        end 
        else if (wr_bw_available[15] && blk_write_req[15] && !last_beat_wr[15] && ~CRITICAL_PORTS[15]) begin
            arb_grant[15] <= 1'b1;
            current_grant_burstcount <= burst_count[15];                            

            arb_granted_wr <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_WRS;
           
            $display($time, "     Black WR, picked %0d", 15);
        end         
        else begin
            arb_granted_wr <= 1'b0;
            arb_grant <= 0;
            
            arb_state <= IDLE;
            no_writes_try_reads <= 1'b1;
            $display($time, "     Black WR, picked NONE");
        end
    end        
    endtask    
    
    //--------------------------------------------------------------------------
    // Select between RED reads
    //--------------------------------------------------------------------------
    task pick_next_red_rd;
        begin
        no_reads_try_writes <= 1'b0;
        no_writes_try_reads <= 1'b0;
        new_port_granted <= 1'b0;
        arb_granted_rd <= 1'b0;        
        arb_grant <= 'h0;
        if (rd_bw_available[0] && red_read_req[0] && !last_beat_rd[0] && CRITICAL_PORTS[0]) begin 
            arb_grant[0] <= 1'b1;
            
            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
            
            $display($time, "     Red RD, picked %0d", 0);
        end
        else if (rd_bw_available[1] && red_read_req[1] && !last_beat_rd[1] && CRITICAL_PORTS[1]) begin
            arb_grant[1] <= 1'b1;
            
            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;            
            arb_state <= RED_RDS;
            
            $display($time, "    Red RD, picked %0d", 1);
        end
        else if (rd_bw_available[2] && red_read_req[2] && !last_beat_rd[2] && CRITICAL_PORTS[2]) begin
            arb_grant[2] <= 1'b1;
            
            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
            
            $display($time, "    Red RD, picked %0d", 2);
        end
        else if (rd_bw_available[3] && red_read_req[3] && !last_beat_rd[3] && CRITICAL_PORTS[3]) begin
            arb_grant[3] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 3);
        end
        else if (rd_bw_available[4] && red_read_req[4] && !last_beat_rd[4] && CRITICAL_PORTS[4]) begin
            arb_grant[4] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 4);
        end
        else if (rd_bw_available[5] && red_read_req[5] && !last_beat_rd[5] && CRITICAL_PORTS[5]) begin
            arb_grant[5] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 5);
        end
        else if (rd_bw_available[6] && red_read_req[6] && !last_beat_rd[6] && CRITICAL_PORTS[6]) begin
            arb_grant[6] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 6);
        end
        else if (rd_bw_available[7] && red_read_req[7] && !last_beat_rd[7] && CRITICAL_PORTS[7]) begin
            arb_grant[7] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 7);
        end       
        else if (rd_bw_available[8] && red_read_req[8] && !last_beat_rd[8] && CRITICAL_PORTS[8]) begin
            arb_grant[8] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 8);
        end
        else if (rd_bw_available[9] && red_read_req[9] && !last_beat_rd[9] && CRITICAL_PORTS[9]) begin
            arb_grant[9] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 9);
        end
        else if (rd_bw_available[10] && red_read_req[10] && !last_beat_rd[10] && CRITICAL_PORTS[10]) begin
            arb_grant[10] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 10);
        end
        else if (rd_bw_available[11] && red_read_req[11] && !last_beat_rd[11] && CRITICAL_PORTS[11]) begin
            arb_grant[11] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 11);
        end
        else if (rd_bw_available[12] && red_read_req[12] && !last_beat_rd[12] && CRITICAL_PORTS[12]) begin
            arb_grant[12] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 12);
        end
        else if (rd_bw_available[13] && red_read_req[13] && !last_beat_rd[13] && CRITICAL_PORTS[13]) begin
            arb_grant[13] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 13);
        end
        else if (rd_bw_available[14] && red_read_req[14] && !last_beat_rd[14] && CRITICAL_PORTS[14]) begin
            arb_grant[14] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 14);
        end
        else if (rd_bw_available[15] && red_read_req[15] && !last_beat_rd[15] && CRITICAL_PORTS[15]) begin
            arb_grant[15] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= RED_RDS;
           
            $display($time, "   Red RD, picked %0d", 15);
        end
        else begin
            arb_granted_rd <= 1'b0;
            arb_grant <= 0;
            arb_state <= IDLE;
            
            no_reads_try_writes <= 1'b1;
            $display($time, "    Red RD, picked NONE");
        end
    end        
    endtask        
    
    //--------------------------------------------------------------------------
    // Select between BLACK reads
    //--------------------------------------------------------------------------
    task pick_next_black_rd;
        begin
        no_reads_try_writes <= 1'b0;
        no_writes_try_reads <= 1'b0;
        new_port_granted <= 1'b0;
        arb_granted_rd <= 1'b0;        
        arb_grant <= 'h0;
        if (rd_bw_available[0] && blk_read_req[0] && !last_beat_rd[0] && ~CRITICAL_PORTS[0]) begin 
            arb_grant[0] <= 1'b1;
            
            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
            
            $display($time, "     Black RD, picked %0d", 0);
        end
        else if (rd_bw_available[1] && blk_read_req[1] && !last_beat_rd[1] && ~CRITICAL_PORTS[1]) begin
            arb_grant[1] <= 1'b1;
            
            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;            
            arb_state <= BLK_RDS;
            
            $display($time, "    Black RD, picked %0d", 1);
        end
        else if (rd_bw_available[2] && blk_read_req[2] && !last_beat_rd[2] && ~CRITICAL_PORTS[2]) begin
            arb_grant[2] <= 1'b1;
            
            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
            
            $display($time, "    Black RD, picked %0d", 2);
        end
        else if (rd_bw_available[3] && blk_read_req[3] && !last_beat_rd[3] && ~CRITICAL_PORTS[3]) begin
            arb_grant[3] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 3);
        end
        else if (rd_bw_available[4] && blk_read_req[4] && !last_beat_rd[4] && ~CRITICAL_PORTS[4]) begin
            arb_grant[4] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 4);
        end
        else if (rd_bw_available[5] && blk_read_req[5] && !last_beat_rd[5] && ~CRITICAL_PORTS[5]) begin
            arb_grant[5] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 5);
        end
        else if (rd_bw_available[6] && blk_read_req[6] && !last_beat_rd[6] && ~CRITICAL_PORTS[6]) begin
            arb_grant[6] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 6);
        end
        else if (rd_bw_available[7] && blk_read_req[7] && !last_beat_rd[7] && ~CRITICAL_PORTS[7]) begin
            arb_grant[7] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 7);
        end  
        else if (rd_bw_available[8] && blk_read_req[8] && !last_beat_rd[8] && ~CRITICAL_PORTS[8]) begin
            arb_grant[8] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 8);
        end  
        else if (rd_bw_available[9] && blk_read_req[9] && !last_beat_rd[9] && ~CRITICAL_PORTS[9]) begin
            arb_grant[9] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 9);
        end
        else if (rd_bw_available[10] && blk_read_req[10] && !last_beat_rd[10] && ~CRITICAL_PORTS[10]) begin
            arb_grant[10] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 10);
        end
        else if (rd_bw_available[11] && blk_read_req[11] && !last_beat_rd[11] && ~CRITICAL_PORTS[11]) begin
            arb_grant[11] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 11);
        end
        else if (rd_bw_available[12] && blk_read_req[12] && !last_beat_rd[12] && ~CRITICAL_PORTS[12]) begin
            arb_grant[12] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 12);
        end
        else if (rd_bw_available[13] && blk_read_req[13] && !last_beat_rd[13] && ~CRITICAL_PORTS[13]) begin
            arb_grant[13] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 13);
        end
        else if (rd_bw_available[14] && blk_read_req[14] && !last_beat_rd[14] && ~CRITICAL_PORTS[14]) begin
            arb_grant[14] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 14);
        end
        else if (rd_bw_available[15] && blk_read_req[15] && !last_beat_rd[15] && ~CRITICAL_PORTS[15]) begin
            arb_grant[15] <= 1'b1;

            arb_granted_rd <= 1'b1;
            new_port_granted <= 1'b1;
            arb_state <= BLK_RDS;
           
            $display($time, "   Black RD, picked %0d", 15);
        end
        else begin
            arb_granted_rd <= 1'b0;
            arb_grant <= 0;
            arb_state <= IDLE;
            
            no_reads_try_writes <= 1'b1;
            $display($time, "    Black RD, picked NONE");
        end
    end        
    endtask    
    
    

    // FSM to control the flow
    always @(posedge clk, negedge reset_n)
    begin : ARB_FSM
        if (!reset_n)
            begin
                arb_state <= INIT;
                arb_state_r <= INIT;
                new_port_granted <= 1'b0;
                no_writes_try_reads <= 1'b0;
                no_reads_try_writes <= 1'b0;
                for (i = 0; i < SLAVE_COUNT; i = i + 1) arb_grant[i] <= 0;
            end
        else begin
            
            if (~mst_waitrequest && current_grant_burstcount > 0) current_grant_burstcount <= current_grant_burstcount - 1'b1;
            arb_state_r <= arb_state;
            
            case (arb_state)
                INIT :  // reset state
                    begin 
                        arb_grant <= 1'b0;
                        new_port_granted <= 1'b0;
                        arb_granted_rd <= 1'b0;
                        arb_granted_wr <= 1'b0;
                        arb_state <= IDLE;
                    end
                IDLE :
                    begin 
                        new_port_granted <= 1'b0;
                        
                        if (|red_wr_req_allowed && ~no_writes_try_reads) begin 
                            pick_next_red_wr;
                        end
                        else if ( ~mst_waitrequest && |red_rd_req_allowed && ~no_reads_try_writes) begin
                            pick_next_red_rd;
                        end
                        else if (|blk_write_req && ~no_writes_try_reads) begin 
                            pick_next_black_wr;
                        end
                        else if (~mst_waitrequest && |blk_read_req && ~no_reads_try_writes) begin
                            pick_next_black_rd;
                        end
                        else begin 
                            no_reads_try_writes <= 1'b0;
                            no_writes_try_reads <= 1'b0;
                            arb_grant <= 0;
                            arb_state <= IDLE;
                        end
                    end

                RED_WRS : // 'h4
                    begin 
                        new_port_granted <= 1'b0;
                        if (current_grant_burstcount <= 1 && ~mst_waitrequest) begin 
                            if (|red_write_req ) begin 
                                pick_next_red_wr;
                            end
                            else begin 
                                arb_grant <= 0;                                
                                arb_state <= RED_RDS;
                            end
                        end
                    end

                RED_RDS : // 'h5
                    begin 
                        new_port_granted <= 1'b0;
                        if (~mst_waitrequest) begin
                            if (|red_read_req ) begin 
                                pick_next_red_rd;
                            end
                            else begin 
                                arb_grant <= 1'b0;
                                arb_granted_rd <= 1'b0;
                                arb_granted_wr <= 1'b0;
                                arb_state <= IDLE;
                            end
                        end
                    end

                BLK_WRS : // 'h8
                    begin 
                        new_port_granted <= 1'b0;
                        
                        if (current_grant_burstcount <= 1 && ~mst_waitrequest) begin 
                            if (|red_read_req || |red_write_req) begin  // check that none of the red ports have outstanding requests 
                                arb_grant <= 1'b0;
                                arb_granted_rd <= 1'b0;
                                arb_granted_wr <= 1'b0;
                                arb_state <= IDLE;
                            end
                            else if (|blk_write_req ) begin 
                                pick_next_black_wr;
                            end
                            else begin 
                                arb_grant <= 1'b0;
                                arb_granted_rd <= 1'b0;
                                arb_granted_wr <= 1'b0;
                                arb_state <= IDLE;
                            end
                        end
                    end                    

                    
                BLK_RDS : // 'h9
                    begin 
                        new_port_granted <= 1'b0;
                        if (~mst_waitrequest) begin
                            if (|red_read_req || |red_write_req) begin  // check that none of the red ports have outstanding requests 
                                arb_grant <= 1'b0;
                                arb_granted_rd <= 1'b0;
                                arb_granted_wr <= 1'b0;
                                arb_state <= IDLE;
                            end
                            else if (|blk_read_req ) begin 
                                pick_next_black_rd;
                            end
                            else begin 
                                arb_grant <= 1'b0;
                                arb_granted_rd <= 1'b0;
                                arb_granted_wr <= 1'b0;
                                arb_state <= IDLE;
                            end
                        end
                    end                    
                    
                    
                default :
                    begin
                        arb_grant <= 0;
                        arb_granted_rd <= 1'b0;
                        arb_granted_wr <= 1'b0;
                        arb_state <= IDLE;
                    end
             endcase
        end
    end                


    always @(*) begin 
	    for (i = 0; i < SLAVE_COUNT; i = i+1) begin
	        red_wr_req_allowed[i] <= wr_bw_available[i] && red_write_req[i];
	        red_rd_req_allowed[i] <= rd_bw_available[i] && red_read_req[i];
	    end // for loop
    end
    
    always @(*) begin 
	    for (i = 0; i < SLAVE_COUNT; i = i+1) begin
	        wr_bw_available[i] <= (wr_data_in_window[i] == 0) && !granted_wr_in_this_cycle[i];
	    end // for loop
	
	    for (i = 0; i < SLAVE_COUNT; i = i+1) begin
		    rd_bw_available[i] <= (rd_data_in_window[i] == 0) && !granted_rd_in_this_cycle[i];
	    end // for loop
    end
    
    always @(*) begin 
        for (i = 0; i < SLAVE_COUNT; i = i + 1) begin
            last_beat_wr[i]  <= current_grant_burstcount === 1 && waitrequest[i] == 0 && arb_grant[i]; 
            last_beat_rd[i]  <= (red_read_req[i] || blk_read_req[i]) && waitrequest[i] == 0 && arb_grant[i]; 
        end // for loop
    end
    

   
    // track write data usage over time
    always @(posedge clk, negedge reset_n) begin 
        if (!reset_n) begin
            for (i = 0; i < SLAVE_COUNT; i = i + 1) wr_data_in_window[i] <= 0;
        end
        else begin
            
            for (i = 0; i < SLAVE_COUNT; i = i + 1) begin
                if (new_port_granted && (red_write_req[i] || blk_write_req[i]) && arb_grant[i]) begin
                    wr_data_in_window[i] <= wr_data_in_window[i] + window_data_limit[i] + burst_count[i] - (~waitrequest[i] && (red_write_req[i] || blk_write_req[i]));
                end
                else begin
                    if (wr_data_in_window[i] > 0) wr_data_in_window[i] <= wr_data_in_window[i] - 1'b1;
                end
            end // for loop
        end
    end

    // track read data usage over time
    always @(posedge clk, negedge reset_n) begin 
        if (!reset_n) begin
            for (i = 0; i < SLAVE_COUNT; i = i + 1) rd_data_in_window[i] <= 0;
        end
        else begin
            
            for (i = 0; i < SLAVE_COUNT; i = i + 1) begin
                if (~mst_waitrequest && burst_begin[i] && (red_read_req[i] || blk_read_req[i]) && arb_grant[i]) begin
                    rd_data_in_window[i] <= rd_data_in_window[i] - 1 + window_data_limit[i] + burst_count[i];
                end
                else begin
                    if (rd_data_in_window[i] > 0) rd_data_in_window[i] <= rd_data_in_window[i] - 1'b1;
                end
            end // for loop
        end
    end

   
   
   // who's had a turn in this loop
   always @(posedge clk, negedge reset_n) begin 
       if (!reset_n) begin
           for (i = 0; i < SLAVE_COUNT; i = i + 1) granted_rd_in_this_cycle[i] <= 0;
           for (i = 0; i < SLAVE_COUNT; i = i + 1) granted_wr_in_this_cycle[i] <= 0;
       end
       else begin
                
           if (|arb_grant) begin
                for (i = 0; i < SLAVE_COUNT; i = i + 1) begin
                    if (arb_grant[i] && (red_read_req[i] || blk_read_req[i]))  granted_rd_in_this_cycle[i] <= 1'b1;
                    if (arb_grant[i] && (red_write_req[i] || blk_write_req[i])) granted_wr_in_this_cycle[i] <= 1'b1; 
                end // for loop
           end
           else begin // no grants
               
               // reset granted checks if starting writes or there are no writes waiting (ie reads left)
               if ((arb_state == IDLE )) begin 
                   for (i = 0; i < SLAVE_COUNT; i = i + 1) begin
                       granted_rd_in_this_cycle[i] <= 1'b0;
                   end // for loop
               end

               if ((arb_state == IDLE)) begin 
                   for (i = 0; i < SLAVE_COUNT; i = i + 1) begin
                       granted_wr_in_this_cycle[i] <= 1'b0;
                   end // for loop
               end
           end
           
                
       end
   end


endmodule
