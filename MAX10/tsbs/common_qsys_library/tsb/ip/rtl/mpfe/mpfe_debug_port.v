
`timescale 1ns / 1ns

module mpfe_debug_port #( 
    parameter
        SLAVE_COUNT     = 16,
        SLV_ADDR_WIDTH  = 8,
        BCOUNT_WIDTH    = 3
    )
    (
        input wire                     clk,
        input wire                     reset_n,
        
        input wire                     mst_waitrequest,
        input wire                     mst_write_req,
        input wire                     rdata_valid_out,
        

        input wire [BCOUNT_WIDTH -1 : 0]   arb_0_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_1_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_2_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_3_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_4_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_5_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_6_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_7_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_8_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_9_burst_count ,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_10_burst_count,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_11_burst_count,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_12_burst_count,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_13_burst_count,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_14_burst_count,
        input wire [BCOUNT_WIDTH -1 : 0]   arb_15_burst_count,

        input wire                     new_port_granted,
        input wire [SLAVE_COUNT-1:0]   arb_req,
        input wire [SLAVE_COUNT-1:0]   arb_grant,
        input wire                     arb_granted_wr,
        input wire                     arb_granted_rd,
        
        // Debug slave port 
        input wire                     dbg_write_req,
        input wire                     dbg_read_req,
        input wire [7:0]               dbg_addr,
        input wire [31:0]              dbg_wdata,
        output reg                     dbg_rdata_valid,
        output reg [31:0]              dbg_rdata        
                
    );
    
    localparam MASTER_ADDR_OFFSET  =  'h0;
    localparam SLAVE_0_ADDR_OFFSET = 'h10;
    localparam SLAVE_1_ADDR_OFFSET = 'h18;
    localparam SLAVE_2_ADDR_OFFSET = 'h20;
    localparam SLAVE_3_ADDR_OFFSET = 'h28;
    localparam SLAVE_4_ADDR_OFFSET = 'h30;
    localparam SLAVE_5_ADDR_OFFSET = 'h38;
    localparam SLAVE_6_ADDR_OFFSET = 'h40;
    localparam SLAVE_7_ADDR_OFFSET = 'h48;
    localparam SLAVE_8_ADDR_OFFSET = 'h50;
    localparam SLAVE_9_ADDR_OFFSET = 'h58;
    localparam SLAVE_10_ADDR_OFFSET = 'h60;
    localparam SLAVE_11_ADDR_OFFSET = 'h68;
    localparam SLAVE_12_ADDR_OFFSET = 'h70;
    localparam SLAVE_13_ADDR_OFFSET = 'h78;
    localparam SLAVE_14_ADDR_OFFSET = 'h80;
    localparam SLAVE_15_ADDR_OFFSET = 'h88;
    
    localparam GNT_COUNT = 'h0;
    localparam WR_COUNT = 'h1;
    localparam RD_COUNT = 'h2;
    localparam WORST_WAIT = 'h3;
    localparam TOTAL_WAIT = 'h4;
    
    localparam CLEAR_COUNTERS    = 'h0;
    localparam MASTER_WAIT_COUNT = 'h1;
    localparam MASTER_WR_COUNT   = 'h2;
    localparam MASTER_RD_COUNT   = 'h3;
    
    
    reg [BCOUNT_WIDTH-1:0] arb_burst_count[SLAVE_COUNT-1:0] ; 

    // per slave counter
    //-----------------------------------------------------------------------
    // grant/data beats counters
    reg [31:0] grant_count[SLAVE_COUNT-1:0] ; // how many grants 
    reg [31:0] wr_data_count[SLAVE_COUNT-1:0] ;  // how much data
    reg [31:0] rd_data_count[SLAVE_COUNT-1:0] ;  // how much data
    // request-to-grant counters
    reg [9:0]  worst_case_latency[SLAVE_COUNT-1:0]; 
    reg [9:0]  current_latency[SLAVE_COUNT-1:0]; // not exposed
    reg [31:0] total_wait[SLAVE_COUNT-1:0]; 
    //-----------------------------------------------------------------------
    
    // per master counters
    //-----------------------------------------------------------------------
    reg [31:0] master_wait_states;
    reg [31:0] master_wr_count;
    reg [31:0] master_rd_count;
    //-----------------------------------------------------------------------

    reg         int_write_req;
    reg         int_read_req;
    reg [7:0]   int_addr; // hard-coded to only 8 bits
    reg [31:0]  int_wdata;
    reg         clear_counters;
     

    
    //--------------------------------------------------------------------------
    //   Debug slave port Avalon interface
    //--------------------------------------------------------------------------
    
    // register all inputs
    always @ (posedge clk or negedge reset_n)
    begin
        if (!reset_n) begin
            int_write_req <= 0;
            int_read_req  <= 0;
            int_addr      <= 0;
            int_wdata     <= 0;
        end
        else begin
            int_addr  <= dbg_addr [7 : 0]; // we only need the bottom 8 bits
            int_wdata[0] <= dbg_wdata[0];
            int_write_req <= dbg_write_req;
            int_read_req  <= dbg_read_req;
        end
    end

    //--------------------------------------------------------------------------
    // Write Interface - only one bit can be written to
    always @ (posedge clk or negedge reset_n)
    begin
        if (!reset_n) begin
            clear_counters <= 0;
        end
        else begin
            if (int_write_req && int_addr == (MASTER_ADDR_OFFSET+CLEAR_COUNTERS) && int_wdata[0] == 1'b1)
                clear_counters <= 1'b1;
            else
                clear_counters <= 1'b0;
        end
    end
    
    //--------------------------------------------------------------------------
    // Read Interface
    
    always @ (posedge clk or negedge reset_n)
    begin
        if (!reset_n) begin
            dbg_rdata       <= 0;
            dbg_rdata_valid <= 0;
        end
        else begin
            if (int_read_req)
            begin
                if (int_addr == 8'h00)                                   dbg_rdata <= 0; // nothing readable here...

                // master stats
                else if (int_addr == MASTER_ADDR_OFFSET + MASTER_WAIT_COUNT )  dbg_rdata <= master_wait_states;  
                else if (int_addr == MASTER_ADDR_OFFSET + MASTER_WR_COUNT   )  dbg_rdata <= master_wr_count;  
                else if (int_addr == MASTER_ADDR_OFFSET + MASTER_RD_COUNT   )  dbg_rdata <= master_rd_count;  

                // slave 0 stats
                else if (int_addr == SLAVE_0_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[0];  
                else if (int_addr == SLAVE_0_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[0];  
                else if (int_addr == SLAVE_0_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[0];  
                else if (int_addr == SLAVE_0_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[0];  
                else if (int_addr == SLAVE_0_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[0];  
                // slave 1 stats                    
                else if (int_addr == SLAVE_1_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[1];  
                else if (int_addr == SLAVE_1_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[1];  
                else if (int_addr == SLAVE_1_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[1];  
                else if (int_addr == SLAVE_1_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[1];  
                else if (int_addr == SLAVE_1_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[1];  
                // slave 2 stats
                else if (int_addr == SLAVE_2_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[2];  
                else if (int_addr == SLAVE_2_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[2];  
                else if (int_addr == SLAVE_2_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[2];  
                else if (int_addr == SLAVE_2_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[2];  
                else if (int_addr == SLAVE_2_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[2];  
                // slave 3 stats
                else if (int_addr == SLAVE_3_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[3];  
                else if (int_addr == SLAVE_3_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[3];  
                else if (int_addr == SLAVE_3_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[3];  
                else if (int_addr == SLAVE_3_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[3];  
                else if (int_addr == SLAVE_3_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[3];  
                // slave 4 stats
                else if (int_addr == SLAVE_4_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[4];  
                else if (int_addr == SLAVE_4_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[4];  
                else if (int_addr == SLAVE_4_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[4];  
                else if (int_addr == SLAVE_4_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[4];  
                else if (int_addr == SLAVE_4_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[4];  
                 // slave 5 stats
                else if (int_addr == SLAVE_5_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[5];  
                else if (int_addr == SLAVE_5_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[5];  
                else if (int_addr == SLAVE_5_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[5];  
                else if (int_addr == SLAVE_5_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[5];  
                else if (int_addr == SLAVE_5_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[5];  
                 // slave 6 stats
                else if (int_addr == SLAVE_6_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[6];  
                else if (int_addr == SLAVE_6_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[6];  
                else if (int_addr == SLAVE_6_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[6];  
                else if (int_addr == SLAVE_6_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[6];  
                else if (int_addr == SLAVE_6_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[6];  
                 // slave 7 stats
                else if (int_addr == SLAVE_7_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[7];  
                else if (int_addr == SLAVE_7_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[7];  
                else if (int_addr == SLAVE_7_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[7];  
                else if (int_addr == SLAVE_7_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[7];  
                else if (int_addr == SLAVE_7_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[7];  
                 // slave 8 stats
                else if (int_addr == SLAVE_8_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[8];  
                else if (int_addr == SLAVE_8_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[8];  
                else if (int_addr == SLAVE_8_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[8];  
                else if (int_addr == SLAVE_8_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[8];  
                else if (int_addr == SLAVE_8_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[8];  
                 // slave 9 stats
                else if (int_addr == SLAVE_9_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[9];  
                else if (int_addr == SLAVE_9_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[9];  
                else if (int_addr == SLAVE_9_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[9];  
                else if (int_addr == SLAVE_9_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[9];  
                else if (int_addr == SLAVE_9_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[9];  
                 // slave 10 stats
                else if (int_addr == SLAVE_10_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[10];  
                else if (int_addr == SLAVE_10_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[10];  
                else if (int_addr == SLAVE_10_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[10];  
                else if (int_addr == SLAVE_10_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[10];  
                else if (int_addr == SLAVE_10_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[10];  
                 // slave 11 stats
                else if (int_addr == SLAVE_11_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[11];  
                else if (int_addr == SLAVE_11_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[11];  
                else if (int_addr == SLAVE_11_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[11];  
                else if (int_addr == SLAVE_11_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[11];  
                else if (int_addr == SLAVE_11_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[11];  
                // slave 12 stats
                else if (int_addr == SLAVE_12_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[12];  
                else if (int_addr == SLAVE_12_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[12];  
                else if (int_addr == SLAVE_12_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[12];  
                else if (int_addr == SLAVE_12_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[12];  
                else if (int_addr == SLAVE_12_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[12];  
                 // slave 13 stats
                else if (int_addr == SLAVE_13_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[13];  
                else if (int_addr == SLAVE_13_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[13];  
                else if (int_addr == SLAVE_13_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[13];  
                else if (int_addr == SLAVE_13_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[13];  
                else if (int_addr == SLAVE_13_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[13];  
                 // slave 14 stats
                else if (int_addr == SLAVE_14_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[14];  
                else if (int_addr == SLAVE_14_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[14];  
                else if (int_addr == SLAVE_14_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[14];  
                else if (int_addr == SLAVE_14_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[14];  
                else if (int_addr == SLAVE_14_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[14];  
                 // slave 15 stats
                else if (int_addr == SLAVE_15_ADDR_OFFSET + GNT_COUNT  )  dbg_rdata <= grant_count[15];  
                else if (int_addr == SLAVE_15_ADDR_OFFSET + WR_COUNT   )  dbg_rdata <= wr_data_count[15];  
                else if (int_addr == SLAVE_15_ADDR_OFFSET + RD_COUNT   )  dbg_rdata <= rd_data_count[15];  
                else if (int_addr == SLAVE_15_ADDR_OFFSET + WORST_WAIT )  dbg_rdata <= worst_case_latency[15];  
                else if (int_addr == SLAVE_15_ADDR_OFFSET + TOTAL_WAIT )  dbg_rdata <= total_wait[15];  
                 
                else dbg_rdata <= 0;
            end
            
            if (int_read_req)
                dbg_rdata_valid <= 1'b1;
            else
                dbg_rdata_valid <= 1'b0;
        end
    end

    
    
    // count data beats 
    generate 
        genvar s;
        
        for (s = 0; s < SLAVE_COUNT; s=s+1) 
            begin : grant_counters
                always @(posedge clk, negedge reset_n) begin 
                    if (!reset_n) begin
                        grant_count[s] <= 0;
                        wr_data_count[s]  <= 0;
                        rd_data_count[s]  <= 0;
                    end
                    else begin
                        if (clear_counters)
                        begin
                            grant_count[s] <= 0; 
                            wr_data_count[s]  <= 0;
                            rd_data_count[s]  <= 0;
                        end 
                        else if (arb_grant[s] && new_port_granted) 
                        begin
                            grant_count[s] <= grant_count[s] + 1; 
                            if (arb_granted_wr) wr_data_count[s]  <= wr_data_count[s] + arb_burst_count[s];
                            if (arb_granted_rd) rd_data_count[s]  <= rd_data_count[s] + arb_burst_count[s];
                        end
                    end
                end
            end // for loop
    endgenerate

    // record worst case latency from request to grant as well as total waits
    generate 
        genvar t;
        
        for (t = 0; t < SLAVE_COUNT; t=t+1) 
            begin : latency_counter
                always @(posedge clk, negedge reset_n) begin 
                    if (!reset_n) begin
                        worst_case_latency[t] <= 0;
                        current_latency[t] <= 0;
                        total_wait[t] <= 0;
                    end
                    else begin
                        if (clear_counters) begin
                            worst_case_latency[t] <= 0;
                            current_latency[t] <= 0;
                            total_wait[t] <= 0;
                        end else begin
                            if (arb_req[t] && ~arb_grant[t]) begin // if the port is requesting, increment the counter. Don't time actual grants as these can be derived from wr_ and rd_data_counts
                                current_latency[t] <= current_latency[t] + 1;
                                total_wait[t] <= total_wait[t] + 1;
                            end
                            else if (~arb_req[t] && ~arb_grant[t]) begin // if the request has been granted, compare against the worst latency
                                if (current_latency[t] > worst_case_latency[t]) worst_case_latency[t] <= current_latency[t];
                                current_latency[t] <= 0;
                            end
                        end
                    end
                end
            end // for loop
    endgenerate    
    
    // record master stats
        
        always @(posedge clk, negedge reset_n) begin 
            if (!reset_n) begin
                master_wait_states <= 0;
                master_rd_count <= 0;
                master_wr_count <= 0;
            end
            else begin
                if (clear_counters) begin
                    master_wait_states <= 0;
                    master_rd_count <= 0;
                    master_wr_count <= 0;
                end else begin
                    if (mst_waitrequest)                    master_wait_states <= master_wait_states + 1'b1;
                    if (~mst_waitrequest && mst_write_req)   master_wr_count <= master_wr_count + 1'b1;
                    if (rdata_valid_out)                    master_rd_count <= master_rd_count + 1'b1;
                end
            end
        end
    
    
    // pack into an array
    always @(*) begin
        arb_burst_count[0] =  arb_0_burst_count;
        arb_burst_count[1] =  arb_1_burst_count;
        arb_burst_count[2] =  arb_2_burst_count;
        arb_burst_count[3] =  arb_3_burst_count;
        arb_burst_count[4] =  arb_4_burst_count;
        arb_burst_count[5] =  arb_5_burst_count;
        arb_burst_count[6] =  arb_6_burst_count;
        arb_burst_count[7] =  arb_7_burst_count;
        arb_burst_count[8] =  arb_8_burst_count;
        arb_burst_count[9] =  arb_9_burst_count;
        arb_burst_count[10] = arb_10_burst_count;
        arb_burst_count[11] = arb_11_burst_count;
        arb_burst_count[12] = arb_12_burst_count;
        arb_burst_count[13] = arb_13_burst_count;
        arb_burst_count[14] = arb_14_burst_count;
        arb_burst_count[15] = arb_15_burst_count;
    end

endmodule
