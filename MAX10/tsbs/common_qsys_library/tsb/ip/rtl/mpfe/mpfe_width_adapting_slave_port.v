`timescale 1ns/1ps

module mpfe_width_adapting_slave_port #(
    parameter 
        SLV_ADDR_WIDTH          = 8,
        DATA_WIDTH              = 32, // ingored, fixed width for now
        BCOUNT_WIDTH            = 3   // no burst support yet
    )
    (
    
        input  wire                       clk,
        input  wire                       reset_n,
        
        input  wire                       slv_write_req,
        input  wire                       slv_read_req,
        input  wire                       slv_burst_begin,// no burst support yet
        input  wire [BCOUNT_WIDTH-1 : 0] slv_burst_count,// no burst support yet         
        input  wire [SLV_ADDR_WIDTH+3-1 : 0] slv_addr,
        input  wire [          32-1 : 0]  slv_wdata,
        input  wire [           4-1 : 0]  slv_byteenable,
        output wire                       slv_waitrequest,
        output wire                       slv_rdata_valid,
        output reg  [          32-1 : 0]  slv_rdata,
        
        output wire                       arb_write_req,
        output wire                       arb_read_req,
        output wire                       arb_burst_begin,// no burst support yet
        output wire [BCOUNT_WIDTH-1 : 0]  arb_burst_count,// no burst support yet        
        output wire [SLV_ADDR_WIDTH  -1 : 0]  arb_addr,
        output wire [         256-1 : 0]  arb_wdata,
        output wire [          32-1 : 0]  arb_byteenable,
        input  wire                       arb_waitrequest,
        input  wire                       arb_rdata_valid,
        input  wire [         256-1 : 0]  arb_rdata
    );

    localparam P_SLAVE_ADDR_WIDTH  = SLV_ADDR_WIDTH+3;
    localparam P_MASTER_ADDR_WIDTH = SLV_ADDR_WIDTH;
    
    localparam P_STATE_WIDTH            = 2;
    localparam P_STATE_IDLE             = 2'd0;
    localparam P_STATE_FILLING_WRITE    = 2'd1;
    localparam P_STATE_WRITEBACK        = 2'd2;
    localparam P_STATE_POSTING_READ     = 2'd3;
    
    reg [P_STATE_WIDTH-1:0] current_state;
    reg [P_STATE_WIDTH-1:0] next_state;
    
    wire                    read_response_pending;
    
    reg  [ 31:0]            wr_byteenables;
    reg  [255:0]            wr_data;
    reg  [  7:0]            dirty;
    
    reg  [ 31:0]            next_wr_byteenables;
    reg  [255:0]            next_wr_data;
    reg  [  7:0]            next_dirty;
    reg  [  7:0]            next_dirty_r;
    
    wire                    address_in_sequence;
    reg  [2:0]              read_post_count;
    wire [2:0]              exp_read_address_offset;
    reg  [2:0]              read_resp_count;
    reg  [2:0]              read_resp_offset;
    wire [2:0]              read_resp_idx;
    reg  [255:0]            read_data_buffer;
    reg  [P_SLAVE_ADDR_WIDTH-1:0] slv_addr_r;
    
    wire [P_SLAVE_ADDR_WIDTH-3-1:0] read_address;
    reg  [P_SLAVE_ADDR_WIDTH-3-1:0] read_address_r;
    
    
    localparam READ_RESP_WIDTH    = 2;
    localparam READ_RESP_IDLE     = 2'd0;
    localparam READ_RESP_ISSUE    = 2'd1;
    localparam READ_RESP_WAIT     = 2'd2;
    localparam READ_RESP_RESPOND  = 2'd3;
    
    reg [READ_RESP_WIDTH-1:0] current_read_resp_state;
    reg [READ_RESP_WIDTH-1:0] next_read_resp_state;
    
    wire address_line_match = (slv_addr[P_SLAVE_ADDR_WIDTH-1:3] == slv_addr_r[P_SLAVE_ADDR_WIDTH-1:3]);
    wire stop_write = ((!address_line_match) || (&next_dirty_r));
    
    always @(posedge clk or negedge reset_n)
    begin
       if(!reset_n)
          next_dirty_r <= 0;
       else
          next_dirty_r <= next_dirty;
    end
    
    
    always @(posedge clk or negedge reset_n)
    begin
       if(!reset_n)
          current_state <= P_STATE_IDLE;
       else
          current_state <= next_state;
    end
    
    always @*
    begin
       casez(current_state)
          P_STATE_IDLE:
          begin
             if(slv_write_req && (current_read_resp_state != READ_RESP_ISSUE))
                next_state = P_STATE_FILLING_WRITE;
             else if(slv_read_req & !read_response_pending)
                next_state = P_STATE_POSTING_READ;
             else
                next_state = P_STATE_IDLE;
          end
    
          P_STATE_FILLING_WRITE:
          begin
             if(!slv_write_req)
                next_state = P_STATE_WRITEBACK;
             else if(stop_write)
                next_state = P_STATE_WRITEBACK;
             else
                next_state = P_STATE_FILLING_WRITE;
          end
    
          P_STATE_WRITEBACK:
          begin
             if(arb_waitrequest)
                next_state = P_STATE_WRITEBACK;
             else
                next_state = P_STATE_IDLE;
          end
    
          P_STATE_POSTING_READ:
          begin
             if(slv_read_req && address_in_sequence && (read_post_count != 3'b0))
                next_state = P_STATE_POSTING_READ;
             else
                next_state = P_STATE_IDLE;
          end
       endcase
    end
    
    /*assign slv_waitrequest = (slv_read_req  && (current_state != P_STATE_POSTING_READ) && !((current_state == P_STATE_IDLE) && !read_response_pending)) ||
                                  (slv_write_req && (current_state != P_STATE_FILLING_WRITE) && (current_state != P_STATE_IDLE));*/
    /*assign slv_waitrequest = (slv_read_req  && (next_state != P_STATE_POSTING_READ)) ||
                                  (slv_write_req && (current_state != P_STATE_FILLING_WRITE) && (current_state != P_STATE_IDLE));*/
    /*assign slv_waitrequest = (slv_read_req  && (next_state != P_STATE_POSTING_READ)) ||
                                  (slv_write_req && (current_state != P_STATE_FILLING_WRITE) && (next_state != P_STATE_FILLING_WRITE));*/
    assign slv_waitrequest = ((slv_read_req  && (next_state != P_STATE_POSTING_READ)) ||
                                  (slv_write_req && ((next_state != P_STATE_FILLING_WRITE) || stop_write)));
    
    
    assign arb_addr         = (current_state == P_STATE_WRITEBACK) ? {slv_addr_r[P_SLAVE_ADDR_WIDTH-1:3]} :
                                  {read_address};
                                  
    assign arb_burst_count  = 'h1;                                  
    assign arb_burst_begin  = 0;                                  
    assign arb_write_req    = (current_state == P_STATE_WRITEBACK);
    assign arb_read_req     = (current_read_resp_state == READ_RESP_ISSUE);
    assign arb_byteenable   = (current_state == P_STATE_WRITEBACK) ? wr_byteenables : 32'hffff;
    assign arb_wdata        = wr_data;
    assign read_address     = (current_read_resp_state == READ_RESP_IDLE) ? slv_addr[P_SLAVE_ADDR_WIDTH-1:3] : read_address_r;
    
    always @*
    begin : NEXT_STORAGE
       reg [31:0] temp;
       next_wr_byteenables = wr_byteenables;
       next_wr_data        = wr_data;
       next_dirty          = dirty;
    
       next_wr_byteenables[slv_addr[2:0]*4 +: 4] = next_wr_byteenables[slv_addr[2:0]*4 +: 4] | slv_byteenable;
       temp = next_wr_data[slv_addr[2:0]*32 +: 32];
    
       temp[ 7: 0] = slv_byteenable[0] ? slv_wdata[ 7: 0] : temp[ 7: 0];
       temp[15: 8] = slv_byteenable[1] ? slv_wdata[15: 8] : temp[15: 8];
       temp[23:16] = slv_byteenable[2] ? slv_wdata[23:16] : temp[23:16];
       temp[31:24] = slv_byteenable[3] ? slv_wdata[31:24] : temp[31:24];
    
    
       next_wr_data[slv_addr[2:0]*32 +: 32] = temp;
       next_dirty[slv_addr[2:0]] = 1'b1;
    end
    
    
    always @(posedge clk or negedge reset_n)
    begin
       if(!reset_n)
       begin
          wr_byteenables <= 32'b0;
          wr_data        <= 256'b0;
          dirty          <= 8'b0;
       end
       else
       begin
          if(slv_write_req && !slv_waitrequest)
          begin
             wr_byteenables <= next_wr_byteenables;
             wr_data        <= next_wr_data;
             dirty          <= next_dirty;
          end
          else if(next_state != P_STATE_WRITEBACK)
          begin
             wr_byteenables <= 32'b0;
             dirty          <= 8'b0;
          end
       end
    end
    
    
    always @(posedge clk or negedge reset_n)
    begin
       if(!reset_n)
       begin
          read_post_count  <= 3'b0;
          read_resp_count  <= 3'b0;
          slv_addr_r <= {P_SLAVE_ADDR_WIDTH{1'b0}};
          read_resp_offset <= 3'b0;
          read_data_buffer <= 256'b0;
          read_address_r   <= {P_SLAVE_ADDR_WIDTH-3{1'b0}};
       end
       else
       begin
          if(current_state == P_STATE_IDLE && (slv_read_req || slv_write_req)) // can only sample Avalon bus when there's a valid transaction
             slv_addr_r <= slv_addr;
    
          if(next_state == P_STATE_POSTING_READ)
          begin
             if(!read_response_pending)
                read_post_count <= 3'b1;
             else
                read_post_count <= read_post_count + 1'b1;
          end
          else if(!read_response_pending)
             read_post_count <= 3'b0;
    
          if(!read_response_pending)
          begin
             read_resp_count <= 3'b0;
             read_resp_offset <= slv_addr[2:0];
          end
          else if(slv_rdata_valid)
          begin
             read_resp_count <= read_resp_count + 1'b1;
          end
    
          if(arb_rdata_valid)
             read_data_buffer <= arb_rdata;
    
          if(current_read_resp_state == READ_RESP_IDLE)
             read_address_r <= slv_addr[P_SLAVE_ADDR_WIDTH-1:3];
       end
    end
    
    assign exp_read_address_offset = slv_addr_r[2:0] + read_post_count;
    assign address_in_sequence = (slv_addr == {slv_addr_r[P_SLAVE_ADDR_WIDTH-1:3], exp_read_address_offset});
    
    
    always @(posedge clk or negedge reset_n)
    begin
       if(!reset_n)
          current_read_resp_state <= READ_RESP_IDLE;
       else
          current_read_resp_state <= next_read_resp_state;
    end
    
    always @*
    begin
       casez(current_read_resp_state)
          READ_RESP_IDLE:
          begin
             if(next_state == P_STATE_POSTING_READ)
                next_read_resp_state = READ_RESP_ISSUE;
             else
                next_read_resp_state = READ_RESP_IDLE;
          end
    
          READ_RESP_ISSUE:
          begin
             if(arb_waitrequest)
                next_read_resp_state = READ_RESP_ISSUE;
             else if(arb_rdata_valid)
                next_read_resp_state = READ_RESP_RESPOND;
             else
                next_read_resp_state = READ_RESP_WAIT;
          end
    
          READ_RESP_WAIT:
          begin
             if(arb_rdata_valid)
                next_read_resp_state = READ_RESP_RESPOND;
             else
                next_read_resp_state = READ_RESP_WAIT;
          end
    
          READ_RESP_RESPOND:
          begin
             if(read_post_count == read_resp_count)
                next_read_resp_state = READ_RESP_IDLE;
             else
                next_read_resp_state = READ_RESP_RESPOND;
          end
       endcase
    end
    
    assign read_response_pending = (current_read_resp_state != READ_RESP_IDLE);
    assign slv_rdata_valid = (next_read_resp_state == READ_RESP_RESPOND);
    assign read_resp_idx = read_resp_offset + read_resp_count;
    
    always @*
    begin
       if(arb_rdata_valid)
          slv_rdata = arb_rdata[32*read_resp_offset +: 32];
       else
          slv_rdata = read_data_buffer[32*read_resp_idx +: 32];
    end

endmodule
