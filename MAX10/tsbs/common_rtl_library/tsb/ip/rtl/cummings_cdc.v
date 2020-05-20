
// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
`default_nettype none
// sync signal to different clock domain
module sync2 (
output reg q = 0,
input logic d, clk, rst_n);
reg q1 = 0; // 1st stage ff output
always_ff @(posedge clk or negedge rst_n)
if (!rst_n) {q,q1} <= '0;
else {q,q1} <= {q1,d};
endmodule

// Pulse Generator
module plsgen (
output logic pulse, 
output reg q = 0,
input logic d,
input logic clk, rst_n);
always_ff @(posedge clk or negedge rst_n)
if (!rst_n) q <= '0;
else q <= d;
assign pulse = q ^ d;
endmodule

module asend_fsm (
output logic aready, // ready to send next data
input logic asend, // send adata
input logic aack, // acknowledge receipt of adata
input logic aclk, arst_n);
parameter READY = 0;
parameter BUSY = 1;

reg state = READY;
logic next;

always_ff @(posedge aclk or negedge arst_n)
if (!arst_n) state <= READY;
else state <= next;
always_comb begin
case (state)
READY: if (asend) next = BUSY;
else next = READY;
BUSY : if (aack) next = READY;
else next = BUSY;
endcase
end
assign aready = !state;
endmodule

module back_fsm (
output logic bvalid, // data valid / ready to load
input logic bload, // load data / send acknowledge
input logic b_en, // enable receipt of adata
input logic bclk, brst_n);

parameter WAIT = 0;
parameter READY = 1;

reg state = WAIT;
logic next;

always_ff @(posedge bclk or negedge brst_n)
if (!brst_n) state <= WAIT;
else state <= next;
always_comb begin
case (state)
READY: if (bload) next = WAIT;
else next = READY;
WAIT : if (b_en) next = READY;
else next = WAIT;
endcase
end
assign bvalid = state;
endmodule

module bmcp_recv #(parameter width = 8) (
output logic [(width-1):0] bdata,
output logic bvalid, // bdata valid
output reg b_ack = 0, // acknowledge signal
input logic [(width-1):0] adata, // unsynchronized adata
input logic bload, // load data and acknowledge receipt
input logic bq2_en, // synchornized enable input
input logic bclk, brst_n);
logic b_en; // enable pulse from pulse generator
// Pulse Generator
wire bload_data;

plsgen pg1 (.pulse(b_en), .q(), .d(bq2_en),
.clk(bclk), .rst_n(brst_n), .*);
// data ready/acknowledge FSM
back_fsm fsm (.*);
// load next data word
assign bload_data = bvalid & bload;
// toggle-flop controlled by bload_data
always_ff @(posedge bclk or negedge brst_n)
if ( !brst_n) b_ack <= '0;
else if (bload_data) b_ack <= ~b_ack;
always_ff @(posedge bclk or negedge brst_n)
if ( !brst_n) bdata <= '0;
else if (bload_data) bdata <= adata;
endmodule

module amcp_send #(parameter width = 8) (
output logic [(width-1):0] adata,
output reg a_en = 0,
output logic aready,
input logic [(width-1):0] adatain,
input logic asend,
input logic aq2_ack,
input logic aclk, arst_n);
logic aack; // acknowledge pulse from pulse generator
// Pulse Generator
wire anxt_data;
plsgen pg1 (.pulse(aack), .q(), .d(aq2_ack),
.clk(aclk), .rst_n(arst_n));
// data ready/acknowledge FSM
asend_fsm fsm (.*);
// send next data word
assign anxt_data = aready & asend;
// toggle-flop controlled by anxt_data
always_ff @(posedge aclk or negedge arst_n)
if ( !arst_n) a_en <= 0;
else if (anxt_data) a_en <= ~a_en;
always_ff @(posedge aclk or negedge arst_n)
if ( !arst_n) adata <= 0;
else if (anxt_data) adata <= adatain;
endmodule

module mcp_blk #(
parameter width = 8,
parameter generate_auto_reset = 1,
parameter generate_edge_reset = 0,
parameter auto_reset_delay = 3
) (
output logic aready, // ready to receive next data
input logic [(width-1):0] adatain,
input logic asend,
input logic aclk, arst_n,
output logic [(width-1):0] bdata,
output logic bvalid, // bdata valid (ready)
input logic bload,
input logic bclk, brst_n,
input a_reset_edge,
input b_reset_edge
);
logic [(width-1):0] adata; // internal data bus
logic b_ack; // acknowledge enable signal
logic a_en; // control enable signal
logic bq2_en; // control - sync output
logic aq2_ack; // feedback - sync output
logic actual_arst_n;
logic actual_brst_n;
logic actual_a_reset_edge;
logic actual_b_reset_edge;
logic a_auto_reset;
logic b_auto_reset;

generate
			if (generate_edge_reset)
			begin
						async_trap_and_reset
						make_a_reset_signal
						 (
						 .async_sig(a_reset_edge), 
						 .outclk(!aclk), 
						 .out_sync_sig(actual_a_reset_edge), 
						 .auto_reset(1'b1), 
						 .reset(1'b1)
						);
						async_trap_and_reset 
						make_b_reset_signal
						 (
						 .async_sig(b_reset_edge), 
						 .outclk(!bclk), 
						 .out_sync_sig(actual_b_reset_edge), 
						 .auto_reset(1'b1), 
						 .reset(1'b1)
						);
			end else
			begin
			      assign actual_a_reset_edge = 0;
			      assign actual_b_reset_edge = 0;			
			end
endgenerate

generate
		if (generate_auto_reset)
		begin
				generate_one_shot_pulse 
				#(
				.num_clks_to_wait(auto_reset_delay)
				)  
				generate_a_auto_reset
				(
				.clk(!aclk), 
				.oneshot_pulse(a_auto_reset)
				);
				
				generate_one_shot_pulse 
				#(
				.num_clks_to_wait(auto_reset_delay)
				)  
				generate_b_auto_reset
				(
				.clk(!bclk), 
				.oneshot_pulse(b_auto_reset)
				);
		 end else
		 begin
		       assign a_auto_reset = 0;
               assign b_auto_reset = 0;			   
		 end
endgenerate
		 
assign actual_arst_n = !((!arst_n) || actual_a_reset_edge || a_auto_reset);
assign actual_brst_n = !((!brst_n) || actual_b_reset_edge || b_auto_reset);

sync2 async (.q(aq2_ack), .d(b_ack), .clk(aclk), .rst_n(actual_arst_n));
sync2 bsync (.q(bq2_en), .d(a_en), .clk(bclk), .rst_n(actual_brst_n));
amcp_send #(.width(width)) 
alogic (
.*,
.arst_n(actual_arst_n)
);
bmcp_recv #(.width(width)) 
blogic (
.*,
.brst_n(actual_brst_n)
);


endmodule
`default_nettype wire