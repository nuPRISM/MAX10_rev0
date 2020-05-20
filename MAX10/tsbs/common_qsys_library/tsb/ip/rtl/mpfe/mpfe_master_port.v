
`timescale 1ns / 1ns

module mpfe_master_port #( 
    parameter
        SLV_ADDR_WIDTH          = 8,
        MST_ADDR_WIDTH          = 8,
        DATA_WIDTH              = 32,
        BCOUNT_WIDTH            = 3
        
    )
    (
        input wire                      clk,
        input wire                      reset_n,
        
        // Avalon interface from the arbiter
        input wire                          res_write_req,
        input wire                          res_read_req,
        input wire                          res_burst_begin,
        input wire [SLV_ADDR_WIDTH - 1 : 0] res_addr,
        input wire [DATA_WIDTH - 1 : 0]     res_wdata,
        input wire [DATA_WIDTH/8-1 : 0]     res_byteenable,
        input wire [BCOUNT_WIDTH-1 : 0]     res_burst_count,
        output wire                         res_waitrequest,
        output wire                         res_rdata_valid,
        output wire[DATA_WIDTH - 1 : 0]     res_rdata,        
        
        // Avalon interface to the shared slave
        output reg                          mst_write_req,
        output reg                          mst_read_req,
        output reg                          mst_burst_begin,
        output reg [BCOUNT_WIDTH - 1 : 0]   mst_burst_count,
        output reg [MST_ADDR_WIDTH - 1 : 0] mst_addr,
        output reg [DATA_WIDTH - 1 : 0]     mst_wdata,
        output reg [DATA_WIDTH/8-1 : 0]     mst_byteenable,    
        input wire                          mst_waitrequest,
        input wire                          mst_rdata_valid,
        input wire [DATA_WIDTH - 1 : 0]     mst_rdata        
    );

    reg [BCOUNT_WIDTH -1 : 0] wdata_burstcount;
    
    // assign res_waitrequest = mst_waitrequest || int_waitrequest;
    assign res_waitrequest = mst_waitrequest;
    assign res_rdata_valid = mst_rdata_valid;
    assign res_rdata = mst_rdata;
    
    
    localparam INIT        = 'h0;
    localparam IDLE        = 'h1;
    localparam WR_REQ      = 'h4;
    localparam RD_REQ      = 'h5;
    localparam GRANT       = 'hf;

    reg [3:0] state;    
    
    // FSM to control the flow
   always @(posedge clk, negedge reset_n)
   begin : FSM
       if (!reset_n)
            begin
                state <= INIT;
                mst_write_req      <= 0 ;
                mst_read_req       <= 0 ;
                mst_burst_begin    <= 0 ;
                mst_burst_count    <= 0 ;
                mst_addr           <= 0 ;
                mst_wdata          <= 0 ;
                mst_byteenable     <= 0 ;                
                
                wdata_burstcount <= 0;
                // int_waitrequest <= 1'b0; 
            end
       else begin
            case (state)
                INIT :  // reset state
                    begin 
                      state <= IDLE;
                    end
                IDLE :
                    begin
                        if ((res_read_req || res_write_req) && ~mst_waitrequest) 
                        begin
                            mst_write_req  <= res_write_req;
                            mst_read_req   <= res_read_req;
                            mst_addr       <= {res_addr,{MST_ADDR_WIDTH-SLV_ADDR_WIDTH{1'b0}}};
                            mst_wdata      <= res_wdata;
                            mst_byteenable <= res_byteenable;
                            mst_burst_count <= res_burst_count;
                            mst_burst_begin <= 1'b1; //res_burst_begin;

                            wdata_burstcount <= res_burst_count;
                            
                            if (res_read_req)
                                state <= RD_REQ;
                            else
                                state <= WR_REQ;
                        end
                    end
                RD_REQ : // single cycle if waitrequest isn't asserted
                    begin
                        mst_burst_begin <= 1'b0;

                        if (mst_waitrequest == 1'b0) begin
                            
                            // another command is ready
                            if (res_read_req || res_write_req) begin
                                mst_write_req  <= res_write_req;
                                mst_read_req   <= res_read_req;
                                mst_addr       <= {res_addr,{MST_ADDR_WIDTH-SLV_ADDR_WIDTH{1'b0}}};
                                mst_wdata      <= res_wdata;
                                mst_byteenable <= res_byteenable;
                                mst_burst_count <= res_burst_count;
                                mst_burst_begin <= 1'b1;
                                
                                wdata_burstcount <= res_burst_count;
                                
                                if (res_read_req)
                                    state <= RD_REQ;
                                else
                                    state <= WR_REQ;
                            end
                            else begin
                            
                                mst_write_req  <=  1'b0;
                                mst_read_req   <=  1'b0;
                                mst_addr       <=  0;
                                mst_wdata      <=  0;
                                mst_byteenable <=  0;
                                mst_burst_count <= 0;        
                                mst_burst_begin <= 0;        
                                
                                wdata_burstcount <= 0;
                                
                                state <= IDLE;
                            end 
                        end
                    end
                            
                WR_REQ : // stay here for enough cycles to transfer all the beats of wdata if waitrequest isn't asserted
                    begin           
                        mst_burst_begin <= 1'b0;
                        
                        if (mst_waitrequest == 1'b0) begin
                            // another command is ready
                            if (res_read_req || (res_write_req && wdata_burstcount == 1)) begin
                                mst_write_req  <= res_write_req;
                                mst_read_req   <= res_read_req;
                                mst_addr       <= {res_addr,{MST_ADDR_WIDTH-SLV_ADDR_WIDTH{1'b0}}};
                                mst_wdata      <= res_wdata;
                                mst_byteenable <= res_byteenable;
                                mst_burst_count <= res_burst_count;
                                mst_burst_begin <= 1'b1;

                                wdata_burstcount <= res_burst_count;
                                
                                if (res_read_req)
                                    state <= RD_REQ;
                                else
                                    state <= WR_REQ;
                            end
                            else if (wdata_burstcount > 1) begin
                                // stay here
                                mst_wdata      <= res_wdata;
                                mst_byteenable <= res_byteenable;

                                wdata_burstcount <= wdata_burstcount - 1'b1;                                
                            end    
                            else begin
                            
                                mst_write_req  <=  1'b0;
                                mst_read_req   <=  1'b0;
                                mst_addr       <=  0;
                                mst_wdata      <=  0;
                                mst_byteenable <=  0;
                                mst_burst_count <= 0;                               
                                mst_burst_begin <= 0;                               
                                state <= IDLE;
                            end       
                        end
                    end

                GRANT :
                    begin
                           state           <= IDLE;
                    end
                default : state <= IDLE;
            endcase
       end
   end

endmodule
