//  alignment_pad_inserter
//  
//  This component simply inserts two pad bytes at the beginning of an
//  Avalon ST packet.  This is useful for preparing packets for transmission
//  thru the Altera TSE MAC when it is configured to have two pad bytes at the
//  beginning of each Avalon ST packet that it consumes.
//  

module alignment_pad_inserter
(
    // clock interface
    input           csi_clock_clk,
    input           csi_clock_reset,
    
    // source interface
    output              aso_src0_valid,
    input               aso_src0_ready,
    output  reg [31:0]  aso_src0_data,
    output  reg [1:0]   aso_src0_empty,
    output  reg         aso_src0_startofpacket,
    output  reg         aso_src0_endofpacket,
    
    // sink interface
    input           asi_snk0_valid,
    output          asi_snk0_ready,
    input   [31:0]  asi_snk0_data,
    input   [1:0]   asi_snk0_empty,
    input           asi_snk0_startofpacket,
    input           asi_snk0_endofpacket
);

localparam INITIAL          = 3'd0;
localparam AT_SOP           = 3'd1;
localparam PAD_INSERTED     = 3'd2;
localparam AT_EOP           = 3'd3;
localparam AT_EOP_PLUS_1    = 3'd4;

reg     [2:0]   state;

wire            pipe_src0_ready;
wire            pipe_src0_valid;
wire    [31:0]  pipe_src0_data;
wire            pipe_src0_startofpacket;
wire            pipe_src0_endofpacket;
wire    [1:0]   pipe_src0_empty;
reg     [35:0]  in_payload;
wire    [35:0]  out_payload;

reg     [31:0]  sink_data_0;
reg     [31:0]  sink_data_1;
reg     [1:0]   sink_empty_0;
reg     [1:0]   sink_empty_1;
reg             sink_sop_0;
reg             sink_sop_1;
reg             sink_eop_0;
reg             sink_eop_1;

wire            sink_cycle;
wire            source_cycle;
wire            interlock_cycle;

//
// misc assignments
//
assign sink_cycle = asi_snk0_valid & asi_snk0_ready;

assign source_cycle = pipe_src0_valid & pipe_src0_ready;

assign interlock_cycle = pipe_src0_ready & asi_snk0_valid;

//
// input pipeline
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset) begin
    if(csi_clock_reset) begin
        sink_data_0     <= 0;
        sink_data_1     <= 0;
        sink_empty_0    <= 0;
        sink_empty_1    <= 0;
        sink_sop_0      <= 0;
        sink_sop_1      <= 0;
        sink_eop_0      <= 0;
        sink_eop_1      <= 0;
    end else begin
        if((sink_cycle)) begin
            sink_data_0     <= asi_snk0_data;
            sink_empty_0    <= asi_snk0_empty;
            sink_sop_0      <= asi_snk0_startofpacket;
            sink_eop_0      <= asi_snk0_endofpacket;
            
            sink_data_1     <= sink_data_0;
            sink_empty_1    <= sink_empty_0;
            sink_sop_1      <= sink_sop_0;
            sink_eop_1      <= sink_eop_0;
        end else if((source_cycle) && (state == AT_EOP)) begin
            sink_data_1     <= sink_data_0;
            sink_empty_1    <= sink_empty_0;
            sink_sop_1      <= sink_sop_0;
            sink_eop_1      <= sink_eop_0;
        end
    end
end

//
// combinatorial control for Avalon ST interfaces
//
assign asi_snk0_ready   =   ((state == INITIAL)) ? (1'b1) :
                            ((state == AT_SOP) && (interlock_cycle)) ? (1'b1) :
                            ((state == PAD_INSERTED) && (interlock_cycle)) ? (1'b1) :
                            ((state == AT_EOP) && (interlock_cycle)) ? (1'b1) :
                            ((state == AT_EOP_PLUS_1) && (interlock_cycle) && (!sink_sop_0)) ? (1'b1) :
                            (1'b0);

assign pipe_src0_valid  =   ((state == AT_SOP) && (interlock_cycle)) ? (1'b1) :
                            ((state == PAD_INSERTED) && (interlock_cycle)) ? (1'b1) :
                            ((state == AT_EOP)) ? (1'b1) :
                            ((state == AT_EOP_PLUS_1)) ? (1'b1) :
                            (1'b0);

assign pipe_src0_data   =   (state == AT_SOP) ? ({{16{1'b0}}, sink_data_0[31:16]}) :
                            ({sink_data_1[15:0], sink_data_0[31:16]});

assign pipe_src0_startofpacket  =   (state == AT_SOP) ? (1'b1) : (1'b0);

assign pipe_src0_endofpacket    =   ((state == AT_EOP) && (sink_empty_0 >= 2'h2)) ? (1'b1) :
                                    ((state == AT_EOP_PLUS_1)) ? (1'b1) :
                                    (1'b0);

assign pipe_src0_empty  =   ((state == AT_EOP)          && (sink_empty_0 == 2'h2)) ? (2'h0) :
                            ((state == AT_EOP)          && (sink_empty_0 == 2'h3)) ? (2'h1) :
                            ((state == AT_EOP_PLUS_1)   && (sink_empty_1 == 2'h0)) ? (2'h2) :
                            ((state == AT_EOP_PLUS_1)   && (sink_empty_1 == 2'h1)) ? (2'h3) :
                            (2'h0);

//
// synchronous state machine for Avalon ST interface sequencing
//
always @ (posedge csi_clock_clk or posedge csi_clock_reset)
begin
    if(csi_clock_reset) begin
        state   <= INITIAL;
    end else begin
        case(state)
            INITIAL: begin
                if((sink_cycle) && (asi_snk0_startofpacket)) begin
                    state <= AT_SOP;
                end
            end
            AT_SOP: begin
                if(interlock_cycle) begin
                    state <= PAD_INSERTED;
                end
            end
            PAD_INSERTED: begin
                if((interlock_cycle) && (asi_snk0_endofpacket)) begin
                    state <= AT_EOP;
                end
            end
            AT_EOP: begin
                if((source_cycle)) begin
                    if((sink_empty_0 >= 2'h2)) begin
                        state <= ((interlock_cycle) && (asi_snk0_startofpacket)) ? (AT_SOP) : (INITIAL);
                    end else begin
                        state <= AT_EOP_PLUS_1;
                    end
                end
            end
            AT_EOP_PLUS_1: begin
                if((source_cycle)) begin
                    state <= ((sink_sop_0) || ((interlock_cycle) && (asi_snk0_startofpacket))) ? (AT_SOP) : (INITIAL);
                end
            end
            default: state  <= INITIAL; 
        endcase
    end
end

//
// output pipeline
//
alignment_pad_inserter_1stage_pipeline #( .PAYLOAD_WIDTH( 36 ) ) outpipe (
    .clk            (csi_clock_clk ),
    .reset_n        (~csi_clock_reset),
    .in_ready       (pipe_src0_ready),
    .in_valid       (pipe_src0_valid), 
    .in_payload     (in_payload),
    .out_ready      (aso_src0_ready), 
    .out_valid      (aso_src0_valid), 
    .out_payload    (out_payload)
);

//
// output mapping
//
always @* begin
    in_payload <= {pipe_src0_data, pipe_src0_startofpacket, pipe_src0_endofpacket, pipe_src0_empty};
    {aso_src0_data, aso_src0_startofpacket, aso_src0_endofpacket, aso_src0_empty} <= out_payload;
end

endmodule

//  --------------------------------------------------------------------------------
// | single buffered pipeline stage
//  --------------------------------------------------------------------------------
module alignment_pad_inserter_1stage_pipeline  
#( parameter PAYLOAD_WIDTH = 8 )
 ( input                          clk,
   input                          reset_n, 
   output reg                     in_ready,
   input                          in_valid,   
   input      [PAYLOAD_WIDTH-1:0] in_payload,
   input                          out_ready,   
   output reg                     out_valid,
   output reg [PAYLOAD_WIDTH-1:0] out_payload      
 );
      
   always @* begin
     in_ready <= out_ready || ~out_valid;
   end
   
   always @ (negedge reset_n, posedge clk) begin
      if (!reset_n) begin
         out_valid <= 0;
         out_payload <= 0;
      end else begin
         if (in_valid) begin
           out_valid <= 1;
         end else if (out_ready) begin
           out_valid <= 0;
         end
         
         if(in_valid && in_ready) begin
            out_payload <= in_payload;
         end
      end
   end

endmodule
