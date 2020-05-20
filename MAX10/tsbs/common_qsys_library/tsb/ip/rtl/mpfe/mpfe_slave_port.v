
`timescale 1ns / 1ns

module mpfe_slave_port #( 
    parameter
        SLV_ADDR_WIDTH          = 8,
        DATA_WIDTH              = 32,
        BCOUNT_WIDTH            = 3
        
    )
    (
        input wire                        clk,
        input wire                        reset_n,
        
        // Avalon interface 
        input wire                        slv_write_req,
        input wire                        slv_read_req,
        input wire                        slv_burst_begin,
        input wire [BCOUNT_WIDTH-1 : 0]   slv_burst_count,
        input wire [SLV_ADDR_WIDTH - 1 : 0]   slv_addr,
        input wire [DATA_WIDTH - 1 : 0]   slv_wdata,
        input wire [DATA_WIDTH/8-1 : 0]   slv_byteenable,
        output reg                        slv_waitrequest,
        output reg                        slv_rdata_valid,
        output reg  [DATA_WIDTH - 1 : 0]  slv_rdata,
        
        output reg                        arb_write_req,
        output reg                        arb_read_req,
        output reg                        arb_burst_begin,
        output reg [BCOUNT_WIDTH - 1 : 0] arb_burst_count,
        output reg [SLV_ADDR_WIDTH - 1 : 0]   arb_addr,
        output reg [DATA_WIDTH - 1 : 0]   arb_wdata,
        output reg [DATA_WIDTH/8-1 : 0]   arb_byteenable,    
        input wire                        arb_waitrequest,
        input wire                        arb_rdata_valid,
        input wire [DATA_WIDTH - 1 : 0]   arb_rdata
    );

    
    reg held_burstbegin;
    
    always @(posedge clk, negedge reset_n) begin 
        if (!reset_n) begin
            held_burstbegin <= 'b0;
        end
        else begin
            // hold burstbegin if waitrequest is asserted...
            if (slv_waitrequest && slv_burst_begin && (slv_write_req || slv_read_req))
                held_burstbegin <= 1'b1;
            else if (~slv_waitrequest && (slv_write_req || slv_read_req))
                held_burstbegin <= 1'b0;
        end
    end
    
    always @(*)
    begin
        arb_write_req   = slv_write_req   ;
        arb_read_req    = slv_read_req    ;
        arb_addr        = slv_addr        ;
        arb_burst_count = slv_burst_count ;
        arb_wdata       = slv_wdata       ;
        arb_byteenable  = slv_byteenable  ;
        arb_burst_begin = slv_burst_begin || held_burstbegin;
        
        slv_waitrequest = arb_waitrequest; 
        slv_rdata_valid = arb_rdata_valid;
        slv_rdata       = arb_rdata;
    end
    
    
    


endmodule
