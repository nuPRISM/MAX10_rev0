
// Latency: 100
// Gap: 8
// module_name_is:dft_32_fixedp_16_bit_top
module dft_32_fixedp_16_bit_top(clk, reset, next, next_out,
   X0, Y0,
   X1, Y1,
   X2, Y2,
   X3, Y3,
   X4, Y4,
   X5, Y5,
   X6, Y6,
   X7, Y7);

   output next_out;
   input clk, reset, next;

   input [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   wire [15:0] t0_0;
   wire [15:0] t0_1;
   wire [15:0] t0_2;
   wire [15:0] t0_3;
   wire [15:0] t0_4;
   wire [15:0] t0_5;
   wire [15:0] t0_6;
   wire [15:0] t0_7;
   wire next_0;
   wire [15:0] t1_0;
   wire [15:0] t1_1;
   wire [15:0] t1_2;
   wire [15:0] t1_3;
   wire [15:0] t1_4;
   wire [15:0] t1_5;
   wire [15:0] t1_6;
   wire [15:0] t1_7;
   wire next_1;
   wire [15:0] t2_0;
   wire [15:0] t2_1;
   wire [15:0] t2_2;
   wire [15:0] t2_3;
   wire [15:0] t2_4;
   wire [15:0] t2_5;
   wire [15:0] t2_6;
   wire [15:0] t2_7;
   wire next_2;
   wire [15:0] t3_0;
   wire [15:0] t3_1;
   wire [15:0] t3_2;
   wire [15:0] t3_3;
   wire [15:0] t3_4;
   wire [15:0] t3_5;
   wire [15:0] t3_6;
   wire [15:0] t3_7;
   wire next_3;
   wire [15:0] t4_0;
   wire [15:0] t4_1;
   wire [15:0] t4_2;
   wire [15:0] t4_3;
   wire [15:0] t4_4;
   wire [15:0] t4_5;
   wire [15:0] t4_6;
   wire [15:0] t4_7;
   wire next_4;
   wire [15:0] t5_0;
   wire [15:0] t5_1;
   wire [15:0] t5_2;
   wire [15:0] t5_3;
   wire [15:0] t5_4;
   wire [15:0] t5_5;
   wire [15:0] t5_6;
   wire [15:0] t5_7;
   wire next_5;
   wire [15:0] t6_0;
   wire [15:0] t6_1;
   wire [15:0] t6_2;
   wire [15:0] t6_3;
   wire [15:0] t6_4;
   wire [15:0] t6_5;
   wire [15:0] t6_6;
   wire [15:0] t6_7;
   wire next_6;
   wire [15:0] t7_0;
   wire [15:0] t7_1;
   wire [15:0] t7_2;
   wire [15:0] t7_3;
   wire [15:0] t7_4;
   wire [15:0] t7_5;
   wire [15:0] t7_6;
   wire [15:0] t7_7;
   wire next_7;
   wire [15:0] t8_0;
   wire [15:0] t8_1;
   wire [15:0] t8_2;
   wire [15:0] t8_3;
   wire [15:0] t8_4;
   wire [15:0] t8_5;
   wire [15:0] t8_6;
   wire [15:0] t8_7;
   wire next_8;
   wire [15:0] t9_0;
   wire [15:0] t9_1;
   wire [15:0] t9_2;
   wire [15:0] t9_3;
   wire [15:0] t9_4;
   wire [15:0] t9_5;
   wire [15:0] t9_6;
   wire [15:0] t9_7;
   wire next_9;
   assign t0_0 = X0;
   assign Y0 = t9_0;
   assign t0_1 = X1;
   assign Y1 = t9_1;
   assign t0_2 = X2;
   assign Y2 = t9_2;
   assign t0_3 = X3;
   assign Y3 = t9_3;
   assign t0_4 = X4;
   assign Y4 = t9_4;
   assign t0_5 = X5;
   assign Y5 = t9_5;
   assign t0_6 = X6;
   assign Y6 = t9_6;
   assign t0_7 = X7;
   assign Y7 = t9_7;
   assign next_0 = next;
   assign next_out = next_9;

// latency=21, gap=8
   rc43864 stage0(.clk(clk), .reset(reset), .next(next_0), .next_out(next_1),
    .X0(t0_0), .Y0(t1_0),
    .X1(t0_1), .Y1(t1_1),
    .X2(t0_2), .Y2(t1_2),
    .X3(t0_3), .Y3(t1_3),
    .X4(t0_4), .Y4(t1_4),
    .X5(t0_5), .Y5(t1_5),
    .X6(t0_6), .Y6(t1_6),
    .X7(t0_7), .Y7(t1_7));


// latency=3, gap=8
   codeBlock43866 stage1(.clk(clk), .reset(reset), .next_in(next_1), .next_out(next_2),
       .X0_in(t1_0), .Y0(t2_0),
       .X1_in(t1_1), .Y1(t2_1),
       .X2_in(t1_2), .Y2(t2_2),
       .X3_in(t1_3), .Y3(t2_3),
       .X4_in(t1_4), .Y4(t2_4),
       .X5_in(t1_5), .Y5(t2_5),
       .X6_in(t1_6), .Y6(t2_6),
       .X7_in(t1_7), .Y7(t2_7));


// latency=13, gap=8
   rc44080 stage2(.clk(clk), .reset(reset), .next(next_2), .next_out(next_3),
    .X0(t2_0), .Y0(t3_0),
    .X1(t2_1), .Y1(t3_1),
    .X2(t2_2), .Y2(t3_2),
    .X3(t2_3), .Y3(t3_3),
    .X4(t2_4), .Y4(t3_4),
    .X5(t2_5), .Y5(t3_5),
    .X6(t2_6), .Y6(t3_6),
    .X7(t2_7), .Y7(t3_7));


// latency=8, gap=8
   DirSum_44453 stage3(.next(next_3), .clk(clk), .reset(reset), .next_out(next_4),
       .X0(t3_0), .Y0(t4_0),
       .X1(t3_1), .Y1(t4_1),
       .X2(t3_2), .Y2(t4_2),
       .X3(t3_3), .Y3(t4_3),
       .X4(t3_4), .Y4(t4_4),
       .X5(t3_5), .Y5(t4_5),
       .X6(t3_6), .Y6(t4_6),
       .X7(t3_7), .Y7(t4_7));


// latency=3, gap=8
   codeBlock44456 stage4(.clk(clk), .reset(reset), .next_in(next_4), .next_out(next_5),
       .X0_in(t4_0), .Y0(t5_0),
       .X1_in(t4_1), .Y1(t5_1),
       .X2_in(t4_2), .Y2(t5_2),
       .X3_in(t4_3), .Y3(t5_3),
       .X4_in(t4_4), .Y4(t5_4),
       .X5_in(t4_5), .Y5(t5_5),
       .X6_in(t4_6), .Y6(t5_6),
       .X7_in(t4_7), .Y7(t5_7));


// latency=21, gap=8
   rc44670 stage5(.clk(clk), .reset(reset), .next(next_5), .next_out(next_6),
    .X0(t5_0), .Y0(t6_0),
    .X1(t5_1), .Y1(t6_1),
    .X2(t5_2), .Y2(t6_2),
    .X3(t5_3), .Y3(t6_3),
    .X4(t5_4), .Y4(t6_4),
    .X5(t5_5), .Y5(t6_5),
    .X6(t5_6), .Y6(t6_6),
    .X7(t5_7), .Y7(t6_7));


// latency=8, gap=8
   DirSum_45074 stage6(.next(next_6), .clk(clk), .reset(reset), .next_out(next_7),
       .X0(t6_0), .Y0(t7_0),
       .X1(t6_1), .Y1(t7_1),
       .X2(t6_2), .Y2(t7_2),
       .X3(t6_3), .Y3(t7_3),
       .X4(t6_4), .Y4(t7_4),
       .X5(t6_5), .Y5(t7_5),
       .X6(t6_6), .Y6(t7_6),
       .X7(t6_7), .Y7(t7_7));


// latency=2, gap=8
   codeBlock45076 stage7(.clk(clk), .reset(reset), .next_in(next_7), .next_out(next_8),
       .X0_in(t7_0), .Y0(t8_0),
       .X1_in(t7_1), .Y1(t8_1),
       .X2_in(t7_2), .Y2(t8_2),
       .X3_in(t7_3), .Y3(t8_3),
       .X4_in(t7_4), .Y4(t8_4),
       .X5_in(t7_5), .Y5(t8_5),
       .X6_in(t7_6), .Y6(t8_6),
       .X7_in(t7_7), .Y7(t8_7));


// latency=21, gap=8
   rc45234 stage8(.clk(clk), .reset(reset), .next(next_8), .next_out(next_9),
    .X0(t8_0), .Y0(t9_0),
    .X1(t8_1), .Y1(t9_1),
    .X2(t8_2), .Y2(t9_2),
    .X3(t8_3), .Y3(t9_3),
    .X4(t8_4), .Y4(t9_4),
    .X5(t8_5), .Y5(t9_5),
    .X6(t8_6), .Y6(t9_6),
    .X7(t8_7), .Y7(t9_7));


endmodule

// Latency: 21
// Gap: 8
module rc43864(clk, reset, next, next_out,
   X0, Y0,
   X1, Y1,
   X2, Y2,
   X3, Y3,
   X4, Y4,
   X5, Y5,
   X6, Y6,
   X7, Y7);

   output next_out;
   input clk, reset, next;

   input [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   wire [31:0] t0;
   wire [31:0] s0;
   assign t0 = {X0, X1};
   wire [31:0] t1;
   wire [31:0] s1;
   assign t1 = {X2, X3};
   wire [31:0] t2;
   wire [31:0] s2;
   assign t2 = {X4, X5};
   wire [31:0] t3;
   wire [31:0] s3;
   assign t3 = {X6, X7};
   assign Y0 = s0[31:16];
   assign Y1 = s0[15:0];
   assign Y2 = s1[31:16];
   assign Y3 = s1[15:0];
   assign Y4 = s2[31:16];
   assign Y5 = s2[15:0];
   assign Y6 = s3[31:16];
   assign Y7 = s3[15:0];

   perm43862 instPerm45951(.x0(t0), .y0(s0),
    .x1(t1), .y1(s1),
    .x2(t2), .y2(s2),
    .x3(t3), .y3(s3),
   .clk(clk), .next(next), .next_out(next_out), .reset(reset)
);



endmodule

module swNet43862(itr, clk, ct
,       x0, y0
,       x1, y1
,       x2, y2
,       x3, y3
);

    parameter width = 32;

    input [2:0] ct;
    input clk;
    input [0:0] itr;
    input [width-1:0] x0;
    output reg [width-1:0] y0;
    input [width-1:0] x1;
    output reg [width-1:0] y1;
    input [width-1:0] x2;
    output reg [width-1:0] y2;
    input [width-1:0] x3;
    output reg [width-1:0] y3;
    wire [width-1:0] t0_0, t0_1, t0_2, t0_3;
    wire [width-1:0] t1_0, t1_1, t1_2, t1_3;
    wire [width-1:0] t2_0, t2_1, t2_2, t2_3;
    reg [width-1:0] t3_0, t3_1, t3_2, t3_3;
    wire [width-1:0] t4_0, t4_1, t4_2, t4_3;
    reg [width-1:0] t5_0, t5_1, t5_2, t5_3;

    reg [3:0] control;

    always @(posedge clk) begin
      case(ct)
        3'd0: control <= 4'b1111;
        3'd1: control <= 4'b1111;
        3'd2: control <= 4'b0011;
        3'd3: control <= 4'b0011;
        3'd4: control <= 4'b1100;
        3'd5: control <= 4'b1100;
        3'd6: control <= 4'b0000;
        3'd7: control <= 4'b0000;
      endcase
   end

// synthesis attribute rom_style of control is "distributed"
   reg [3:0] control0;
   reg [3:0] control1;
    always @(posedge clk) begin
       control0 <= control;
        control1 <= control0;
    end
    assign t0_0 = x0;
    assign t0_1 = x2;
    assign t0_2 = x1;
    assign t0_3 = x3;
     assign t1_0 = t0_0;
     assign t1_1 = t0_1;
     assign t1_2 = t0_2;
     assign t1_3 = t0_3;
    assign t2_0 = t1_0;
    assign t2_1 = t1_2;
    assign t2_2 = t1_1;
    assign t2_3 = t1_3;
   always @(posedge clk) begin
         t3_0 <= (control0[3] == 0) ? t2_0 : t2_1;
         t3_1 <= (control0[3] == 0) ? t2_1 : t2_0;
         t3_2 <= (control0[2] == 0) ? t2_2 : t2_3;
         t3_3 <= (control0[2] == 0) ? t2_3 : t2_2;
   end
    assign t4_0 = t3_0;
    assign t4_1 = t3_2;
    assign t4_2 = t3_1;
    assign t4_3 = t3_3;
   always @(posedge clk) begin
         t5_0 <= (control1[1] == 0) ? t4_0 : t4_1;
         t5_1 <= (control1[1] == 0) ? t4_1 : t4_0;
         t5_2 <= (control1[0] == 0) ? t4_2 : t4_3;
         t5_3 <= (control1[0] == 0) ? t4_3 : t4_2;
   end
    always @(posedge clk) begin
        y0 <= t5_0;
        y1 <= t5_2;
        y2 <= t5_1;
        y3 <= t5_3;
    end
endmodule

// Latency: 21
// Gap: 8
module perm43862(clk, next, reset, next_out,
   x0, y0,
   x1, y1,
   x2, y2,
   x3, y3);
   parameter width = 32;

   parameter depth = 8;

   parameter addrbits = 3;

   parameter muxbits = 2;

   input [width-1:0]  x0;
   output [width-1:0]  y0;
   wire [width-1:0]  t0;
   wire [width-1:0]  s0;
   input [width-1:0]  x1;
   output [width-1:0]  y1;
   wire [width-1:0]  t1;
   wire [width-1:0]  s1;
   input [width-1:0]  x2;
   output [width-1:0]  y2;
   wire [width-1:0]  t2;
   wire [width-1:0]  s2;
   input [width-1:0]  x3;
   output [width-1:0]  y3;
   wire [width-1:0]  t3;
   wire [width-1:0]  s3;
   input next, reset, clk;
   output next_out;
   reg [addrbits-1:0] s1rdloc, s2rdloc;

    reg [addrbits-1:0] s1wr0;
   reg [addrbits-1:0] s1rd0, s2wr0, s2rd0;
   reg [addrbits-1:0] s1rd1, s2wr1, s2rd1;
   reg [addrbits-1:0] s1rd2, s2wr2, s2rd2;
   reg [addrbits-1:0] s1rd3, s2wr3, s2rd3;
   reg s1wr_en, state1, state2, state3;
   wire 	      next2, next3, next4;
   reg 		      inFlip0, outFlip0_z, outFlip1;
   wire 	      inFlip1, outFlip0;

   wire [0:0] tm0;
   assign tm0 = 0;

shiftRegFIFO #(4, 1) shiftFIFO_45956(.X(outFlip0), .Y(inFlip1), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_45957(.X(outFlip0_z), .Y(outFlip0), .clk(clk));
//   shiftRegFIFO #(2, 1) inFlip1Reg(outFlip0, inFlip1, clk);
//   shiftRegFIFO #(1, 1) outFlip0Reg(outFlip0_z, outFlip0, clk);
   
   memMod_dist #(depth*2, width, addrbits+1) s1mem0(x0, t0, {inFlip0, s1wr0}, {outFlip0, s1rd0}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem1(x1, t1, {inFlip0, s1wr0}, {outFlip0, s1rd1}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem2(x2, t2, {inFlip0, s1wr0}, {outFlip0, s1rd2}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem3(x3, t3, {inFlip0, s1wr0}, {outFlip0, s1rd3}, s1wr_en, clk);

shiftRegFIFO #(7, 1) shiftFIFO_45966(.X(next), .Y(next2), .clk(clk));
shiftRegFIFO #(5, 1) shiftFIFO_45967(.X(next2), .Y(next3), .clk(clk));
shiftRegFIFO #(8, 1) shiftFIFO_45968(.X(next3), .Y(next4), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_45969(.X(next4), .Y(next_out), .clk(clk));
shiftRegFIFO #(7, 1) shiftFIFO_45972(.X(tm0), .Y(tm0_d), .clk(clk));
shiftRegFIFO #(4, 1) shiftFIFO_45975(.X(tm0_d), .Y(tm0_dd), .clk(clk));
   
   wire [addrbits-1:0] 	      muxCycle, writeCycle;
assign muxCycle = s1rdloc;
shiftRegFIFO #(4, 3) shiftFIFO_45980(.X(muxCycle), .Y(writeCycle), .clk(clk));
        
   wire 		      readInt, s2wr_en;   
   assign 		      readInt = (state2 == 1);

   shiftRegFIFO #(5, 1) writeIntReg(readInt, s2wr_en, clk);

   memMod_dist #(depth*2, width, addrbits+1) s2mem0(s0, y0, {inFlip1, s2wr0}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem1(s1, y1, {inFlip1, s2wr1}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem2(s2, y2, {inFlip1, s2wr2}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem3(s3, y3, {inFlip1, s2wr3}, {outFlip1, s2rdloc}, s2wr_en, clk);
   always @(posedge clk) begin
      if (reset == 1) begin
	 state1 <= 0;
	 inFlip0 <= 0;	 
	 s1wr0 <= 0;
      end
      else if (next == 1) begin
	 s1wr0 <= 0;
	 state1 <= 1;
	 s1wr_en <= 1;
	 inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
      end
      else begin
	 case(state1)
	   0: begin
	      s1wr0 <= 0;
	      state1 <= 0;
	      s1wr_en <= 0;
	      inFlip0 <= inFlip0;	      
	   end
	   1: begin
	      s1wr0 <= (s1wr0 == depth-1) ? 0 : s1wr0 + 1;
	      state1 <= 1;
         s1wr_en <= 1;
	      inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
	   end
	 endcase
      end      
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	       state2 <= 0;
	       outFlip0_z <= 0;	 
      end
      else if (next2 == 1) begin
	       s1rdloc <= 0;
	       state2 <= 1;
	       outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
      end
      else begin
	 case(state2)
	   0: begin
	      s1rdloc <= 0;
	      state2 <= 0;
	      outFlip0_z <= outFlip0_z;	 
	   end
	   1: begin
	      s1rdloc <= (s1rdloc == depth-1) ? 0 : s1rdloc + 1;
         state2 <= 1;
	      outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
	   end	     
	 endcase
      end
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	 state3 <= 0;
	 outFlip1 <= 0;	 
      end
      else if (next4 == 1) begin
	 s2rdloc <= 0;
	 state3 <= 1;
	 outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;	      
      end
      else begin
	 case(state3)
	   0: begin
	      s2rdloc <= 0;
	      state3 <= 0;
	      outFlip1 <= outFlip1;
	   end
	   1: begin
	      s2rdloc <= (s2rdloc == depth-1) ? 0 : s2rdloc + 1;
         state3 <= 1;
	      outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;
	   end	     
	 endcase
      end
   end
   always @(posedge clk) begin
      case({tm0_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd0 <= 6;
	     {1'd0,  3'd1}: s1rd0 <= 7;
	     {1'd0,  3'd2}: s1rd0 <= 4;
	     {1'd0,  3'd3}: s1rd0 <= 5;
	     {1'd0,  3'd4}: s1rd0 <= 2;
	     {1'd0,  3'd5}: s1rd0 <= 3;
	     {1'd0,  3'd6}: s1rd0 <= 0;
	     {1'd0,  3'd7}: s1rd0 <= 1;
      endcase      
   end

// synthesis attribute rom_style of s1rd0 is "distributed"
   always @(posedge clk) begin
      case({tm0_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd1 <= 4;
	     {1'd0,  3'd1}: s1rd1 <= 5;
	     {1'd0,  3'd2}: s1rd1 <= 6;
	     {1'd0,  3'd3}: s1rd1 <= 7;
	     {1'd0,  3'd4}: s1rd1 <= 0;
	     {1'd0,  3'd5}: s1rd1 <= 1;
	     {1'd0,  3'd6}: s1rd1 <= 2;
	     {1'd0,  3'd7}: s1rd1 <= 3;
      endcase      
   end

// synthesis attribute rom_style of s1rd1 is "distributed"
   always @(posedge clk) begin
      case({tm0_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd2 <= 2;
	     {1'd0,  3'd1}: s1rd2 <= 3;
	     {1'd0,  3'd2}: s1rd2 <= 0;
	     {1'd0,  3'd3}: s1rd2 <= 1;
	     {1'd0,  3'd4}: s1rd2 <= 6;
	     {1'd0,  3'd5}: s1rd2 <= 7;
	     {1'd0,  3'd6}: s1rd2 <= 4;
	     {1'd0,  3'd7}: s1rd2 <= 5;
      endcase      
   end

// synthesis attribute rom_style of s1rd2 is "distributed"
   always @(posedge clk) begin
      case({tm0_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd3 <= 0;
	     {1'd0,  3'd1}: s1rd3 <= 1;
	     {1'd0,  3'd2}: s1rd3 <= 2;
	     {1'd0,  3'd3}: s1rd3 <= 3;
	     {1'd0,  3'd4}: s1rd3 <= 4;
	     {1'd0,  3'd5}: s1rd3 <= 5;
	     {1'd0,  3'd6}: s1rd3 <= 6;
	     {1'd0,  3'd7}: s1rd3 <= 7;
      endcase      
   end

// synthesis attribute rom_style of s1rd3 is "distributed"
    swNet43862 sw(tm0_d, clk, muxCycle, t0, s0, t1, s1, t2, s2, t3, s3);

   always @(posedge clk) begin
      case({tm0_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr0 <= 5;
	      {1'd0, 3'd1}: s2wr0 <= 7;
	      {1'd0, 3'd2}: s2wr0 <= 1;
	      {1'd0, 3'd3}: s2wr0 <= 3;
	      {1'd0, 3'd4}: s2wr0 <= 4;
	      {1'd0, 3'd5}: s2wr0 <= 6;
	      {1'd0, 3'd6}: s2wr0 <= 0;
	      {1'd0, 3'd7}: s2wr0 <= 2;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr0 is "distributed"
   always @(posedge clk) begin
      case({tm0_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr1 <= 1;
	      {1'd0, 3'd1}: s2wr1 <= 3;
	      {1'd0, 3'd2}: s2wr1 <= 5;
	      {1'd0, 3'd3}: s2wr1 <= 7;
	      {1'd0, 3'd4}: s2wr1 <= 0;
	      {1'd0, 3'd5}: s2wr1 <= 2;
	      {1'd0, 3'd6}: s2wr1 <= 4;
	      {1'd0, 3'd7}: s2wr1 <= 6;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr1 is "distributed"
   always @(posedge clk) begin
      case({tm0_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr2 <= 4;
	      {1'd0, 3'd1}: s2wr2 <= 6;
	      {1'd0, 3'd2}: s2wr2 <= 0;
	      {1'd0, 3'd3}: s2wr2 <= 2;
	      {1'd0, 3'd4}: s2wr2 <= 5;
	      {1'd0, 3'd5}: s2wr2 <= 7;
	      {1'd0, 3'd6}: s2wr2 <= 1;
	      {1'd0, 3'd7}: s2wr2 <= 3;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr2 is "distributed"
   always @(posedge clk) begin
      case({tm0_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr3 <= 0;
	      {1'd0, 3'd1}: s2wr3 <= 2;
	      {1'd0, 3'd2}: s2wr3 <= 4;
	      {1'd0, 3'd3}: s2wr3 <= 6;
	      {1'd0, 3'd4}: s2wr3 <= 1;
	      {1'd0, 3'd5}: s2wr3 <= 3;
	      {1'd0, 3'd6}: s2wr3 <= 5;
	      {1'd0, 3'd7}: s2wr3 <= 7;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr3 is "distributed"
endmodule




module memMod(in, out, inAddr, outAddr, writeSel, clk);
   
   parameter depth=1024, width=16, logDepth=10;
   
   input [width-1:0]    in;
   input [logDepth-1:0] inAddr, outAddr;
   input 	        writeSel, clk;
   output [width-1:0] 	out;
   reg [width-1:0] 	out;
   
   // synthesis attribute ram_style of mem is block

   reg [width-1:0] 	mem[depth-1:0]; 
   
   always @(posedge clk) begin
      out <= mem[outAddr];
      
      if (writeSel)
        mem[inAddr] <= in;
   end
endmodule 



module memMod_dist(in, out, inAddr, outAddr, writeSel, clk);
   
   parameter depth=1024, width=16, logDepth=10;
   
   input [width-1:0]    in;
   input [logDepth-1:0] inAddr, outAddr;
   input 	        writeSel, clk;
   output [width-1:0] 	out;
   reg [width-1:0] 	out;
   
   // synthesis attribute ram_style of mem is distributed

   reg [width-1:0] 	mem[depth-1:0]; 
   
   always @(posedge clk) begin
      out <= mem[outAddr];
      
      if (writeSel)
        mem[inAddr] <= in;
   end
endmodule 

module shiftRegFIFO(X, Y, clk);
   parameter depth=1, width=1;

   output [width-1:0] Y;
   input  [width-1:0] X;
   input              clk;

   reg [width-1:0]    mem [depth-1:0];
   integer            index;

   assign Y = mem[depth-1];

   always @ (posedge clk) begin
      for(index=1;index<depth;index=index+1) begin
         mem[index] <= mem[index-1];
      end
      mem[0]<=X;
   end
endmodule

// Latency: 3
// Gap: 1
module codeBlock43866(clk, reset, next_in, next_out,
   X0_in, Y0,
   X1_in, Y1,
   X2_in, Y2,
   X3_in, Y3,
   X4_in, Y4,
   X5_in, Y5,
   X6_in, Y6,
   X7_in, Y7);

   output next_out;
   input clk, reset, next_in;

   reg next;

   input [15:0] X0_in,
      X1_in,
      X2_in,
      X3_in,
      X4_in,
      X5_in,
      X6_in,
      X7_in;

   reg   [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   shiftRegFIFO #(2, 1) shiftFIFO_45983(.X(next), .Y(next_out), .clk(clk));


   wire signed [15:0] a257;
   wire signed [15:0] a258;
   wire signed [15:0] a259;
   wire signed [15:0] a260;
   wire signed [15:0] a265;
   wire signed [15:0] a266;
   wire signed [15:0] a267;
   wire signed [15:0] a268;
   wire signed [15:0] t297;
   wire signed [15:0] t298;
   wire signed [15:0] t299;
   wire signed [15:0] t300;
   wire signed [15:0] t301;
   wire signed [15:0] t302;
   wire signed [15:0] t303;
   wire signed [15:0] t304;
   wire signed [15:0] t305;
   wire signed [15:0] t306;
   wire signed [15:0] t307;
   wire signed [15:0] t308;
   wire signed [15:0] Y0;
   wire signed [15:0] Y1;
   wire signed [15:0] Y4;
   wire signed [15:0] Y5;
   wire signed [15:0] t309;
   wire signed [15:0] t310;
   wire signed [15:0] t311;
   wire signed [15:0] t312;
   wire signed [15:0] Y2;
   wire signed [15:0] Y3;
   wire signed [15:0] Y6;
   wire signed [15:0] Y7;


   assign a257 = X0;
   assign a258 = X4;
   assign a259 = X1;
   assign a260 = X5;
   assign a265 = X2;
   assign a266 = X6;
   assign a267 = X3;
   assign a268 = X7;
   assign Y0 = t305;
   assign Y1 = t306;
   assign Y4 = t307;
   assign Y5 = t308;
   assign Y2 = t309;
   assign Y3 = t310;
   assign Y6 = t311;
   assign Y7 = t312;

    addfxp #(16, 1) add43878(.a(a257), .b(a258), .clk(clk), .q(t297));    // 0
    addfxp #(16, 1) add43893(.a(a259), .b(a260), .clk(clk), .q(t298));    // 0
    subfxp #(16, 1) sub43908(.a(a257), .b(a258), .clk(clk), .q(t299));    // 0
    subfxp #(16, 1) sub43923(.a(a259), .b(a260), .clk(clk), .q(t300));    // 0
    addfxp #(16, 1) add43938(.a(a265), .b(a266), .clk(clk), .q(t301));    // 0
    addfxp #(16, 1) add43953(.a(a267), .b(a268), .clk(clk), .q(t302));    // 0
    subfxp #(16, 1) sub43968(.a(a265), .b(a266), .clk(clk), .q(t303));    // 0
    subfxp #(16, 1) sub43983(.a(a267), .b(a268), .clk(clk), .q(t304));    // 0
    addfxp #(16, 1) add43990(.a(t297), .b(t301), .clk(clk), .q(t305));    // 1
    addfxp #(16, 1) add43997(.a(t298), .b(t302), .clk(clk), .q(t306));    // 1
    subfxp #(16, 1) sub44004(.a(t297), .b(t301), .clk(clk), .q(t307));    // 1
    subfxp #(16, 1) sub44011(.a(t298), .b(t302), .clk(clk), .q(t308));    // 1
    addfxp #(16, 1) add44034(.a(t299), .b(t304), .clk(clk), .q(t309));    // 1
    subfxp #(16, 1) sub44041(.a(t300), .b(t303), .clk(clk), .q(t310));    // 1
    subfxp #(16, 1) sub44048(.a(t299), .b(t304), .clk(clk), .q(t311));    // 1
    addfxp #(16, 1) add44055(.a(t300), .b(t303), .clk(clk), .q(t312));    // 1


   always @(posedge clk) begin
      if (reset == 1) begin
      end
      else begin
         X0 <= X0_in;
         X1 <= X1_in;
         X2 <= X2_in;
         X3 <= X3_in;
         X4 <= X4_in;
         X5 <= X5_in;
         X6 <= X6_in;
         X7 <= X7_in;
         next <= next_in;
      end
   end
endmodule

// Latency: 13
// Gap: 4
module rc44080(clk, reset, next, next_out,
   X0, Y0,
   X1, Y1,
   X2, Y2,
   X3, Y3,
   X4, Y4,
   X5, Y5,
   X6, Y6,
   X7, Y7);

   output next_out;
   input clk, reset, next;

   input [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   wire [31:0] t0;
   wire [31:0] s0;
   assign t0 = {X0, X1};
   wire [31:0] t1;
   wire [31:0] s1;
   assign t1 = {X2, X3};
   wire [31:0] t2;
   wire [31:0] s2;
   assign t2 = {X4, X5};
   wire [31:0] t3;
   wire [31:0] s3;
   assign t3 = {X6, X7};
   assign Y0 = s0[31:16];
   assign Y1 = s0[15:0];
   assign Y2 = s1[31:16];
   assign Y3 = s1[15:0];
   assign Y4 = s2[31:16];
   assign Y5 = s2[15:0];
   assign Y6 = s3[31:16];
   assign Y7 = s3[15:0];

   perm44078 instPerm45984(.x0(t0), .y0(s0),
    .x1(t1), .y1(s1),
    .x2(t2), .y2(s2),
    .x3(t3), .y3(s3),
   .clk(clk), .next(next), .next_out(next_out), .reset(reset)
);



endmodule

module swNet44078(itr, clk, ct
,       x0, y0
,       x1, y1
,       x2, y2
,       x3, y3
);

    parameter width = 32;

    input [1:0] ct;
    input clk;
    input [0:0] itr;
    input [width-1:0] x0;
    output reg [width-1:0] y0;
    input [width-1:0] x1;
    output reg [width-1:0] y1;
    input [width-1:0] x2;
    output reg [width-1:0] y2;
    input [width-1:0] x3;
    output reg [width-1:0] y3;
    wire [width-1:0] t0_0, t0_1, t0_2, t0_3;
    wire [width-1:0] t1_0, t1_1, t1_2, t1_3;
    wire [width-1:0] t2_0, t2_1, t2_2, t2_3;
    reg [width-1:0] t3_0, t3_1, t3_2, t3_3;
    wire [width-1:0] t4_0, t4_1, t4_2, t4_3;
    reg [width-1:0] t5_0, t5_1, t5_2, t5_3;

    reg [3:0] control;

    always @(posedge clk) begin
      case(ct)
        2'd0: control <= 4'b1111;
        2'd1: control <= 4'b0011;
        2'd2: control <= 4'b1100;
        2'd3: control <= 4'b0000;
      endcase
   end

// synthesis attribute rom_style of control is "distributed"
   reg [3:0] control0;
   reg [3:0] control1;
    always @(posedge clk) begin
       control0 <= control;
        control1 <= control0;
    end
    assign t0_0 = x0;
    assign t0_1 = x2;
    assign t0_2 = x1;
    assign t0_3 = x3;
     assign t1_0 = t0_0;
     assign t1_1 = t0_1;
     assign t1_2 = t0_2;
     assign t1_3 = t0_3;
    assign t2_0 = t1_0;
    assign t2_1 = t1_2;
    assign t2_2 = t1_1;
    assign t2_3 = t1_3;
   always @(posedge clk) begin
         t3_0 <= (control0[3] == 0) ? t2_0 : t2_1;
         t3_1 <= (control0[3] == 0) ? t2_1 : t2_0;
         t3_2 <= (control0[2] == 0) ? t2_2 : t2_3;
         t3_3 <= (control0[2] == 0) ? t2_3 : t2_2;
   end
    assign t4_0 = t3_0;
    assign t4_1 = t3_2;
    assign t4_2 = t3_1;
    assign t4_3 = t3_3;
   always @(posedge clk) begin
         t5_0 <= (control1[1] == 0) ? t4_0 : t4_1;
         t5_1 <= (control1[1] == 0) ? t4_1 : t4_0;
         t5_2 <= (control1[0] == 0) ? t4_2 : t4_3;
         t5_3 <= (control1[0] == 0) ? t4_3 : t4_2;
   end
    always @(posedge clk) begin
        y0 <= t5_0;
        y1 <= t5_2;
        y2 <= t5_1;
        y3 <= t5_3;
    end
endmodule

// Latency: 13
// Gap: 4
module perm44078(clk, next, reset, next_out,
   x0, y0,
   x1, y1,
   x2, y2,
   x3, y3);
   parameter width = 32;

   parameter depth = 4;

   parameter addrbits = 2;

   parameter muxbits = 2;

   input [width-1:0]  x0;
   output [width-1:0]  y0;
   wire [width-1:0]  t0;
   wire [width-1:0]  s0;
   input [width-1:0]  x1;
   output [width-1:0]  y1;
   wire [width-1:0]  t1;
   wire [width-1:0]  s1;
   input [width-1:0]  x2;
   output [width-1:0]  y2;
   wire [width-1:0]  t2;
   wire [width-1:0]  s2;
   input [width-1:0]  x3;
   output [width-1:0]  y3;
   wire [width-1:0]  t3;
   wire [width-1:0]  s3;
   input next, reset, clk;
   output next_out;
   reg [addrbits-1:0] s1rdloc, s2rdloc;

    reg [addrbits-1:0] s1wr0;
   reg [addrbits-1:0] s1rd0, s2wr0, s2rd0;
   reg [addrbits-1:0] s1rd1, s2wr1, s2rd1;
   reg [addrbits-1:0] s1rd2, s2wr2, s2rd2;
   reg [addrbits-1:0] s1rd3, s2wr3, s2rd3;
   reg s1wr_en, state1, state2, state3;
   wire 	      next2, next3, next4;
   reg 		      inFlip0, outFlip0_z, outFlip1;
   wire 	      inFlip1, outFlip0;

   wire [0:0] tm1;
   assign tm1 = 0;

shiftRegFIFO #(4, 1) shiftFIFO_45989(.X(outFlip0), .Y(inFlip1), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_45990(.X(outFlip0_z), .Y(outFlip0), .clk(clk));
//   shiftRegFIFO #(2, 1) inFlip1Reg(outFlip0, inFlip1, clk);
//   shiftRegFIFO #(1, 1) outFlip0Reg(outFlip0_z, outFlip0, clk);
   
   memMod_dist #(depth*2, width, addrbits+1) s1mem0(x0, t0, {inFlip0, s1wr0}, {outFlip0, s1rd0}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem1(x1, t1, {inFlip0, s1wr0}, {outFlip0, s1rd1}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem2(x2, t2, {inFlip0, s1wr0}, {outFlip0, s1rd2}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem3(x3, t3, {inFlip0, s1wr0}, {outFlip0, s1rd3}, s1wr_en, clk);

shiftRegFIFO #(3, 1) shiftFIFO_45999(.X(next), .Y(next2), .clk(clk));
shiftRegFIFO #(5, 1) shiftFIFO_46000(.X(next2), .Y(next3), .clk(clk));
shiftRegFIFO #(4, 1) shiftFIFO_46001(.X(next3), .Y(next4), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_46002(.X(next4), .Y(next_out), .clk(clk));
shiftRegFIFO #(3, 1) shiftFIFO_46005(.X(tm1), .Y(tm1_d), .clk(clk));
shiftRegFIFO #(4, 1) shiftFIFO_46008(.X(tm1_d), .Y(tm1_dd), .clk(clk));
   
   wire [addrbits-1:0] 	      muxCycle, writeCycle;
assign muxCycle = s1rdloc;
shiftRegFIFO #(4, 2) shiftFIFO_46013(.X(muxCycle), .Y(writeCycle), .clk(clk));
        
   wire 		      readInt, s2wr_en;   
   assign 		      readInt = (state2 == 1);

   shiftRegFIFO #(5, 1) writeIntReg(readInt, s2wr_en, clk);

   memMod_dist #(depth*2, width, addrbits+1) s2mem0(s0, y0, {inFlip1, s2wr0}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem1(s1, y1, {inFlip1, s2wr1}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem2(s2, y2, {inFlip1, s2wr2}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem3(s3, y3, {inFlip1, s2wr3}, {outFlip1, s2rdloc}, s2wr_en, clk);
   always @(posedge clk) begin
      if (reset == 1) begin
	 state1 <= 0;
	 inFlip0 <= 0;	 
	 s1wr0 <= 0;
      end
      else if (next == 1) begin
	 s1wr0 <= 0;
	 state1 <= 1;
	 s1wr_en <= 1;
	 inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
      end
      else begin
	 case(state1)
	   0: begin
	      s1wr0 <= 0;
	      state1 <= 0;
	      s1wr_en <= 0;
	      inFlip0 <= inFlip0;	      
	   end
	   1: begin
	      s1wr0 <= (s1wr0 == depth-1) ? 0 : s1wr0 + 1;
	      state1 <= 1;
         s1wr_en <= 1;
	      inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
	   end
	 endcase
      end      
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	       state2 <= 0;
	       outFlip0_z <= 0;	 
      end
      else if (next2 == 1) begin
	       s1rdloc <= 0;
	       state2 <= 1;
	       outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
      end
      else begin
	 case(state2)
	   0: begin
	      s1rdloc <= 0;
	      state2 <= 0;
	      outFlip0_z <= outFlip0_z;	 
	   end
	   1: begin
	      s1rdloc <= (s1rdloc == depth-1) ? 0 : s1rdloc + 1;
         state2 <= 1;
	      outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
	   end	     
	 endcase
      end
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	 state3 <= 0;
	 outFlip1 <= 0;	 
      end
      else if (next4 == 1) begin
	 s2rdloc <= 0;
	 state3 <= 1;
	 outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;	      
      end
      else begin
	 case(state3)
	   0: begin
	      s2rdloc <= 0;
	      state3 <= 0;
	      outFlip1 <= outFlip1;
	   end
	   1: begin
	      s2rdloc <= (s2rdloc == depth-1) ? 0 : s2rdloc + 1;
         state3 <= 1;
	      outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;
	   end	     
	 endcase
      end
   end
   always @(posedge clk) begin
      case({tm1_d, s1rdloc})
	     {1'd0,  2'd0}: s1rd0 <= 3;
	     {1'd0,  2'd1}: s1rd0 <= 2;
	     {1'd0,  2'd2}: s1rd0 <= 1;
	     {1'd0,  2'd3}: s1rd0 <= 0;
      endcase      
   end

// synthesis attribute rom_style of s1rd0 is "distributed"
   always @(posedge clk) begin
      case({tm1_d, s1rdloc})
	     {1'd0,  2'd0}: s1rd1 <= 2;
	     {1'd0,  2'd1}: s1rd1 <= 3;
	     {1'd0,  2'd2}: s1rd1 <= 0;
	     {1'd0,  2'd3}: s1rd1 <= 1;
      endcase      
   end

// synthesis attribute rom_style of s1rd1 is "distributed"
   always @(posedge clk) begin
      case({tm1_d, s1rdloc})
	     {1'd0,  2'd0}: s1rd2 <= 1;
	     {1'd0,  2'd1}: s1rd2 <= 0;
	     {1'd0,  2'd2}: s1rd2 <= 3;
	     {1'd0,  2'd3}: s1rd2 <= 2;
      endcase      
   end

// synthesis attribute rom_style of s1rd2 is "distributed"
   always @(posedge clk) begin
      case({tm1_d, s1rdloc})
	     {1'd0,  2'd0}: s1rd3 <= 0;
	     {1'd0,  2'd1}: s1rd3 <= 1;
	     {1'd0,  2'd2}: s1rd3 <= 2;
	     {1'd0,  2'd3}: s1rd3 <= 3;
      endcase      
   end

// synthesis attribute rom_style of s1rd3 is "distributed"
    swNet44078 sw(tm1_d, clk, muxCycle, t0, s0, t1, s1, t2, s2, t3, s3);

   always @(posedge clk) begin
      case({tm1_dd, writeCycle})
	      {1'd0, 2'd0}: s2wr0 <= 3;
	      {1'd0, 2'd1}: s2wr0 <= 2;
	      {1'd0, 2'd2}: s2wr0 <= 1;
	      {1'd0, 2'd3}: s2wr0 <= 0;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr0 is "distributed"
   always @(posedge clk) begin
      case({tm1_dd, writeCycle})
	      {1'd0, 2'd0}: s2wr1 <= 2;
	      {1'd0, 2'd1}: s2wr1 <= 3;
	      {1'd0, 2'd2}: s2wr1 <= 0;
	      {1'd0, 2'd3}: s2wr1 <= 1;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr1 is "distributed"
   always @(posedge clk) begin
      case({tm1_dd, writeCycle})
	      {1'd0, 2'd0}: s2wr2 <= 1;
	      {1'd0, 2'd1}: s2wr2 <= 0;
	      {1'd0, 2'd2}: s2wr2 <= 3;
	      {1'd0, 2'd3}: s2wr2 <= 2;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr2 is "distributed"
   always @(posedge clk) begin
      case({tm1_dd, writeCycle})
	      {1'd0, 2'd0}: s2wr3 <= 0;
	      {1'd0, 2'd1}: s2wr3 <= 1;
	      {1'd0, 2'd2}: s2wr3 <= 2;
	      {1'd0, 2'd3}: s2wr3 <= 3;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr3 is "distributed"
endmodule


// Latency: 8
// Gap: 4
module DirSum_44453(clk, reset, next, next_out,
      X0, Y0,
      X1, Y1,
      X2, Y2,
      X3, Y3,
      X4, Y4,
      X5, Y5,
      X6, Y6,
      X7, Y7);

   output next_out;
   input clk, reset, next;

   reg [1:0] i2;

   input [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   always @(posedge clk) begin
      if (reset == 1) begin
         i2 <= 0;
      end
      else begin
         if (next == 1)
            i2 <= 0;
         else if (i2 == 3)
            i2 <= 0;
         else
            i2 <= i2 + 1;
      end
   end

   codeBlock44083 codeBlockIsnt46014(.clk(clk), .reset(reset), .next_in(next), .next_out(next_out),
.i2_in(i2),
       .X0_in(X0), .Y0(Y0),
       .X1_in(X1), .Y1(Y1),
       .X2_in(X2), .Y2(Y2),
       .X3_in(X3), .Y3(Y3),
       .X4_in(X4), .Y4(Y4),
       .X5_in(X5), .Y5(Y5),
       .X6_in(X6), .Y6(Y6),
       .X7_in(X7), .Y7(Y7));

endmodule

module D12_44415(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [1:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h4000;
      1: out3 <= 16'h3b21;
      2: out3 <= 16'h2d41;
      3: out3 <= 16'h187e;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D13_44421(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [1:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h4000;
      1: out3 <= 16'h2d41;
      2: out3 <= 16'h0;
      3: out3 <= 16'hd2bf;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D14_44427(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [1:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h4000;
      1: out3 <= 16'h187e;
      2: out3 <= 16'hd2bf;
      3: out3 <= 16'hc4df;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D16_44439(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [1:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h0;
      1: out3 <= 16'he782;
      2: out3 <= 16'hd2bf;
      3: out3 <= 16'hc4df;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D17_44445(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [1:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h0;
      1: out3 <= 16'hd2bf;
      2: out3 <= 16'hc000;
      3: out3 <= 16'hd2bf;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D18_44451(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [1:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h0;
      1: out3 <= 16'hc4df;
      2: out3 <= 16'hd2bf;
      3: out3 <= 16'h187e;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



// Latency: 8
// Gap: 1
module codeBlock44083(clk, reset, next_in, next_out,
   i2_in,
   X0_in, Y0,
   X1_in, Y1,
   X2_in, Y2,
   X3_in, Y3,
   X4_in, Y4,
   X5_in, Y5,
   X6_in, Y6,
   X7_in, Y7);

   output next_out;
   input clk, reset, next_in;

   reg next;
   input [1:0] i2_in;
   reg [1:0] i2;

   input [15:0] X0_in,
      X1_in,
      X2_in,
      X3_in,
      X4_in,
      X5_in,
      X6_in,
      X7_in;

   reg   [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   shiftRegFIFO #(7, 1) shiftFIFO_46017(.X(next), .Y(next_out), .clk(clk));


   wire signed [15:0] a225;
   wire signed [15:0] a202;
   wire signed [15:0] a228;
   wire signed [15:0] a206;
   wire signed [15:0] a229;
   wire signed [15:0] a230;
   wire signed [15:0] a233;
   wire signed [15:0] a234;
   wire signed [15:0] a237;
   wire signed [15:0] a238;
   reg signed [15:0] tm94;
   reg signed [15:0] tm98;
   reg signed [15:0] tm110;
   reg signed [15:0] tm114;
   reg signed [15:0] tm126;
   reg signed [15:0] tm130;
   reg signed [15:0] tm142;
   reg signed [15:0] tm149;
   reg signed [15:0] tm95;
   reg signed [15:0] tm99;
   reg signed [15:0] tm111;
   reg signed [15:0] tm115;
   reg signed [15:0] tm127;
   reg signed [15:0] tm131;
   reg signed [15:0] tm143;
   reg signed [15:0] tm150;
   wire signed [15:0] tm4;
   wire signed [15:0] a207;
   wire signed [15:0] tm5;
   wire signed [15:0] a209;
   wire signed [15:0] tm6;
   wire signed [15:0] a213;
   wire signed [15:0] tm7;
   wire signed [15:0] a215;
   wire signed [15:0] tm8;
   wire signed [15:0] a219;
   wire signed [15:0] tm9;
   wire signed [15:0] a221;
   reg signed [15:0] tm96;
   reg signed [15:0] tm100;
   reg signed [15:0] tm112;
   reg signed [15:0] tm116;
   reg signed [15:0] tm128;
   reg signed [15:0] tm132;
   reg signed [15:0] tm144;
   reg signed [15:0] tm151;
   reg signed [15:0] tm24;
   reg signed [15:0] tm25;
   reg signed [15:0] tm28;
   reg signed [15:0] tm29;
   reg signed [15:0] tm32;
   reg signed [15:0] tm33;
   reg signed [15:0] tm97;
   reg signed [15:0] tm101;
   reg signed [15:0] tm113;
   reg signed [15:0] tm117;
   reg signed [15:0] tm129;
   reg signed [15:0] tm133;
   reg signed [15:0] tm145;
   reg signed [15:0] tm152;
   reg signed [15:0] tm146;
   reg signed [15:0] tm153;
   wire signed [15:0] a208;
   wire signed [15:0] a210;
   wire signed [15:0] a211;
   wire signed [15:0] a212;
   wire signed [15:0] a214;
   wire signed [15:0] a216;
   wire signed [15:0] a217;
   wire signed [15:0] a218;
   wire signed [15:0] a220;
   wire signed [15:0] a222;
   wire signed [15:0] a223;
   wire signed [15:0] a224;
   reg signed [15:0] tm147;
   reg signed [15:0] tm154;
   wire signed [15:0] Y0;
   wire signed [15:0] Y1;
   wire signed [15:0] Y2;
   wire signed [15:0] Y3;
   wire signed [15:0] Y4;
   wire signed [15:0] Y5;
   wire signed [15:0] Y6;
   wire signed [15:0] Y7;
   reg signed [15:0] tm148;
   reg signed [15:0] tm155;


   assign a225 = X0;
   assign a202 = a225;
   assign a228 = X1;
   assign a206 = a228;
   assign a229 = X2;
   assign a230 = X3;
   assign a233 = X4;
   assign a234 = X5;
   assign a237 = X6;
   assign a238 = X7;
   assign a207 = tm4;
   assign a209 = tm5;
   assign a213 = tm6;
   assign a215 = tm7;
   assign a219 = tm8;
   assign a221 = tm9;
   assign Y0 = tm148;
   assign Y1 = tm155;

   D12_44415 instD12inst0_44415(.addr(i2[1:0]), .out(tm4), .clk(clk));

   D13_44421 instD13inst0_44421(.addr(i2[1:0]), .out(tm6), .clk(clk));

   D14_44427 instD14inst0_44427(.addr(i2[1:0]), .out(tm8), .clk(clk));

   D16_44439 instD16inst0_44439(.addr(i2[1:0]), .out(tm5), .clk(clk));

   D17_44445 instD17inst0_44445(.addr(i2[1:0]), .out(tm7), .clk(clk));

   D18_44451 instD18inst0_44451(.addr(i2[1:0]), .out(tm9), .clk(clk));

    multfix #(16, 2) m44182(.a(tm24), .b(tm97), .clk(clk), .q_sc(a208), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44204(.a(tm25), .b(tm101), .clk(clk), .q_sc(a210), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44222(.a(tm25), .b(tm97), .clk(clk), .q_sc(a211), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44233(.a(tm24), .b(tm101), .clk(clk), .q_sc(a212), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44262(.a(tm28), .b(tm113), .clk(clk), .q_sc(a214), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44284(.a(tm29), .b(tm117), .clk(clk), .q_sc(a216), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44302(.a(tm29), .b(tm113), .clk(clk), .q_sc(a217), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44313(.a(tm28), .b(tm117), .clk(clk), .q_sc(a218), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44342(.a(tm32), .b(tm129), .clk(clk), .q_sc(a220), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44364(.a(tm33), .b(tm133), .clk(clk), .q_sc(a222), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44382(.a(tm33), .b(tm129), .clk(clk), .q_sc(a223), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44393(.a(tm32), .b(tm133), .clk(clk), .q_sc(a224), .q_unsc(), .rst(reset));
    subfxp #(16, 1) sub44211(.a(a208), .b(a210), .clk(clk), .q(Y2));    // 6
    addfxp #(16, 1) add44240(.a(a211), .b(a212), .clk(clk), .q(Y3));    // 6
    subfxp #(16, 1) sub44291(.a(a214), .b(a216), .clk(clk), .q(Y4));    // 6
    addfxp #(16, 1) add44320(.a(a217), .b(a218), .clk(clk), .q(Y5));    // 6
    subfxp #(16, 1) sub44371(.a(a220), .b(a222), .clk(clk), .q(Y6));    // 6
    addfxp #(16, 1) add44400(.a(a223), .b(a224), .clk(clk), .q(Y7));    // 6


   always @(posedge clk) begin
      if (reset == 1) begin
         tm24 <= 0;
         tm97 <= 0;
         tm25 <= 0;
         tm101 <= 0;
         tm25 <= 0;
         tm97 <= 0;
         tm24 <= 0;
         tm101 <= 0;
         tm28 <= 0;
         tm113 <= 0;
         tm29 <= 0;
         tm117 <= 0;
         tm29 <= 0;
         tm113 <= 0;
         tm28 <= 0;
         tm117 <= 0;
         tm32 <= 0;
         tm129 <= 0;
         tm33 <= 0;
         tm133 <= 0;
         tm33 <= 0;
         tm129 <= 0;
         tm32 <= 0;
         tm133 <= 0;
      end
      else begin
         i2 <= i2_in;
         X0 <= X0_in;
         X1 <= X1_in;
         X2 <= X2_in;
         X3 <= X3_in;
         X4 <= X4_in;
         X5 <= X5_in;
         X6 <= X6_in;
         X7 <= X7_in;
         next <= next_in;
         tm94 <= a229;
         tm98 <= a230;
         tm110 <= a233;
         tm114 <= a234;
         tm126 <= a237;
         tm130 <= a238;
         tm142 <= a202;
         tm149 <= a206;
         tm95 <= tm94;
         tm99 <= tm98;
         tm111 <= tm110;
         tm115 <= tm114;
         tm127 <= tm126;
         tm131 <= tm130;
         tm143 <= tm142;
         tm150 <= tm149;
         tm96 <= tm95;
         tm100 <= tm99;
         tm112 <= tm111;
         tm116 <= tm115;
         tm128 <= tm127;
         tm132 <= tm131;
         tm144 <= tm143;
         tm151 <= tm150;
         tm24 <= a207;
         tm25 <= a209;
         tm28 <= a213;
         tm29 <= a215;
         tm32 <= a219;
         tm33 <= a221;
         tm97 <= tm96;
         tm101 <= tm100;
         tm113 <= tm112;
         tm117 <= tm116;
         tm129 <= tm128;
         tm133 <= tm132;
         tm145 <= tm144;
         tm152 <= tm151;
         tm146 <= tm145;
         tm153 <= tm152;
         tm147 <= tm146;
         tm154 <= tm153;
         tm148 <= tm147;
         tm155 <= tm154;
      end
   end
endmodule

// Latency: 3
// Gap: 1
module codeBlock44456(clk, reset, next_in, next_out,
   X0_in, Y0,
   X1_in, Y1,
   X2_in, Y2,
   X3_in, Y3,
   X4_in, Y4,
   X5_in, Y5,
   X6_in, Y6,
   X7_in, Y7);

   output next_out;
   input clk, reset, next_in;

   reg next;

   input [15:0] X0_in,
      X1_in,
      X2_in,
      X3_in,
      X4_in,
      X5_in,
      X6_in,
      X7_in;

   reg   [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   shiftRegFIFO #(2, 1) shiftFIFO_46020(.X(next), .Y(next_out), .clk(clk));


   wire signed [15:0] a137;
   wire signed [15:0] a138;
   wire signed [15:0] a139;
   wire signed [15:0] a140;
   wire signed [15:0] a145;
   wire signed [15:0] a146;
   wire signed [15:0] a147;
   wire signed [15:0] a148;
   wire signed [15:0] t169;
   wire signed [15:0] t170;
   wire signed [15:0] t171;
   wire signed [15:0] t172;
   wire signed [15:0] t173;
   wire signed [15:0] t174;
   wire signed [15:0] t175;
   wire signed [15:0] t176;
   wire signed [15:0] t177;
   wire signed [15:0] t178;
   wire signed [15:0] t179;
   wire signed [15:0] t180;
   wire signed [15:0] Y0;
   wire signed [15:0] Y1;
   wire signed [15:0] Y4;
   wire signed [15:0] Y5;
   wire signed [15:0] t181;
   wire signed [15:0] t182;
   wire signed [15:0] t183;
   wire signed [15:0] t184;
   wire signed [15:0] Y2;
   wire signed [15:0] Y3;
   wire signed [15:0] Y6;
   wire signed [15:0] Y7;


   assign a137 = X0;
   assign a138 = X4;
   assign a139 = X1;
   assign a140 = X5;
   assign a145 = X2;
   assign a146 = X6;
   assign a147 = X3;
   assign a148 = X7;
   assign Y0 = t177;
   assign Y1 = t178;
   assign Y4 = t179;
   assign Y5 = t180;
   assign Y2 = t181;
   assign Y3 = t182;
   assign Y6 = t183;
   assign Y7 = t184;

    addfxp #(16, 1) add44468(.a(a137), .b(a138), .clk(clk), .q(t169));    // 0
    addfxp #(16, 1) add44483(.a(a139), .b(a140), .clk(clk), .q(t170));    // 0
    subfxp #(16, 1) sub44498(.a(a137), .b(a138), .clk(clk), .q(t171));    // 0
    subfxp #(16, 1) sub44513(.a(a139), .b(a140), .clk(clk), .q(t172));    // 0
    addfxp #(16, 1) add44528(.a(a145), .b(a146), .clk(clk), .q(t173));    // 0
    addfxp #(16, 1) add44543(.a(a147), .b(a148), .clk(clk), .q(t174));    // 0
    subfxp #(16, 1) sub44558(.a(a145), .b(a146), .clk(clk), .q(t175));    // 0
    subfxp #(16, 1) sub44573(.a(a147), .b(a148), .clk(clk), .q(t176));    // 0
    addfxp #(16, 1) add44580(.a(t169), .b(t173), .clk(clk), .q(t177));    // 1
    addfxp #(16, 1) add44587(.a(t170), .b(t174), .clk(clk), .q(t178));    // 1
    subfxp #(16, 1) sub44594(.a(t169), .b(t173), .clk(clk), .q(t179));    // 1
    subfxp #(16, 1) sub44601(.a(t170), .b(t174), .clk(clk), .q(t180));    // 1
    addfxp #(16, 1) add44624(.a(t171), .b(t176), .clk(clk), .q(t181));    // 1
    subfxp #(16, 1) sub44631(.a(t172), .b(t175), .clk(clk), .q(t182));    // 1
    subfxp #(16, 1) sub44638(.a(t171), .b(t176), .clk(clk), .q(t183));    // 1
    addfxp #(16, 1) add44645(.a(t172), .b(t175), .clk(clk), .q(t184));    // 1


   always @(posedge clk) begin
      if (reset == 1) begin
      end
      else begin
         X0 <= X0_in;
         X1 <= X1_in;
         X2 <= X2_in;
         X3 <= X3_in;
         X4 <= X4_in;
         X5 <= X5_in;
         X6 <= X6_in;
         X7 <= X7_in;
         next <= next_in;
      end
   end
endmodule

// Latency: 21
// Gap: 8
module rc44670(clk, reset, next, next_out,
   X0, Y0,
   X1, Y1,
   X2, Y2,
   X3, Y3,
   X4, Y4,
   X5, Y5,
   X6, Y6,
   X7, Y7);

   output next_out;
   input clk, reset, next;

   input [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   wire [31:0] t0;
   wire [31:0] s0;
   assign t0 = {X0, X1};
   wire [31:0] t1;
   wire [31:0] s1;
   assign t1 = {X2, X3};
   wire [31:0] t2;
   wire [31:0] s2;
   assign t2 = {X4, X5};
   wire [31:0] t3;
   wire [31:0] s3;
   assign t3 = {X6, X7};
   assign Y0 = s0[31:16];
   assign Y1 = s0[15:0];
   assign Y2 = s1[31:16];
   assign Y3 = s1[15:0];
   assign Y4 = s2[31:16];
   assign Y5 = s2[15:0];
   assign Y6 = s3[31:16];
   assign Y7 = s3[15:0];

   perm44668 instPerm46021(.x0(t0), .y0(s0),
    .x1(t1), .y1(s1),
    .x2(t2), .y2(s2),
    .x3(t3), .y3(s3),
   .clk(clk), .next(next), .next_out(next_out), .reset(reset)
);



endmodule

module swNet44668(itr, clk, ct
,       x0, y0
,       x1, y1
,       x2, y2
,       x3, y3
);

    parameter width = 32;

    input [2:0] ct;
    input clk;
    input [0:0] itr;
    input [width-1:0] x0;
    output reg [width-1:0] y0;
    input [width-1:0] x1;
    output reg [width-1:0] y1;
    input [width-1:0] x2;
    output reg [width-1:0] y2;
    input [width-1:0] x3;
    output reg [width-1:0] y3;
    wire [width-1:0] t0_0, t0_1, t0_2, t0_3;
    wire [width-1:0] t1_0, t1_1, t1_2, t1_3;
    wire [width-1:0] t2_0, t2_1, t2_2, t2_3;
    reg [width-1:0] t3_0, t3_1, t3_2, t3_3;
    wire [width-1:0] t4_0, t4_1, t4_2, t4_3;
    reg [width-1:0] t5_0, t5_1, t5_2, t5_3;

    reg [3:0] control;

    always @(posedge clk) begin
      case(ct)
        3'd0: control <= 4'b1111;
        3'd1: control <= 4'b1111;
        3'd2: control <= 4'b0011;
        3'd3: control <= 4'b0011;
        3'd4: control <= 4'b1100;
        3'd5: control <= 4'b1100;
        3'd6: control <= 4'b0000;
        3'd7: control <= 4'b0000;
      endcase
   end

// synthesis attribute rom_style of control is "distributed"
   reg [3:0] control0;
   reg [3:0] control1;
    always @(posedge clk) begin
       control0 <= control;
        control1 <= control0;
    end
    assign t0_0 = x0;
    assign t0_1 = x2;
    assign t0_2 = x1;
    assign t0_3 = x3;
     assign t1_0 = t0_0;
     assign t1_1 = t0_1;
     assign t1_2 = t0_2;
     assign t1_3 = t0_3;
    assign t2_0 = t1_0;
    assign t2_1 = t1_2;
    assign t2_2 = t1_1;
    assign t2_3 = t1_3;
   always @(posedge clk) begin
         t3_0 <= (control0[3] == 0) ? t2_0 : t2_1;
         t3_1 <= (control0[3] == 0) ? t2_1 : t2_0;
         t3_2 <= (control0[2] == 0) ? t2_2 : t2_3;
         t3_3 <= (control0[2] == 0) ? t2_3 : t2_2;
   end
    assign t4_0 = t3_0;
    assign t4_1 = t3_2;
    assign t4_2 = t3_1;
    assign t4_3 = t3_3;
   always @(posedge clk) begin
         t5_0 <= (control1[1] == 0) ? t4_0 : t4_1;
         t5_1 <= (control1[1] == 0) ? t4_1 : t4_0;
         t5_2 <= (control1[0] == 0) ? t4_2 : t4_3;
         t5_3 <= (control1[0] == 0) ? t4_3 : t4_2;
   end
    always @(posedge clk) begin
        y0 <= t5_0;
        y1 <= t5_2;
        y2 <= t5_1;
        y3 <= t5_3;
    end
endmodule

// Latency: 21
// Gap: 8
module perm44668(clk, next, reset, next_out,
   x0, y0,
   x1, y1,
   x2, y2,
   x3, y3);
   parameter width = 32;

   parameter depth = 8;

   parameter addrbits = 3;

   parameter muxbits = 2;

   input [width-1:0]  x0;
   output [width-1:0]  y0;
   wire [width-1:0]  t0;
   wire [width-1:0]  s0;
   input [width-1:0]  x1;
   output [width-1:0]  y1;
   wire [width-1:0]  t1;
   wire [width-1:0]  s1;
   input [width-1:0]  x2;
   output [width-1:0]  y2;
   wire [width-1:0]  t2;
   wire [width-1:0]  s2;
   input [width-1:0]  x3;
   output [width-1:0]  y3;
   wire [width-1:0]  t3;
   wire [width-1:0]  s3;
   input next, reset, clk;
   output next_out;
   reg [addrbits-1:0] s1rdloc, s2rdloc;

    reg [addrbits-1:0] s1wr0;
   reg [addrbits-1:0] s1rd0, s2wr0, s2rd0;
   reg [addrbits-1:0] s1rd1, s2wr1, s2rd1;
   reg [addrbits-1:0] s1rd2, s2wr2, s2rd2;
   reg [addrbits-1:0] s1rd3, s2wr3, s2rd3;
   reg s1wr_en, state1, state2, state3;
   wire 	      next2, next3, next4;
   reg 		      inFlip0, outFlip0_z, outFlip1;
   wire 	      inFlip1, outFlip0;

   wire [0:0] tm10;
   assign tm10 = 0;

shiftRegFIFO #(4, 1) shiftFIFO_46026(.X(outFlip0), .Y(inFlip1), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_46027(.X(outFlip0_z), .Y(outFlip0), .clk(clk));
//   shiftRegFIFO #(2, 1) inFlip1Reg(outFlip0, inFlip1, clk);
//   shiftRegFIFO #(1, 1) outFlip0Reg(outFlip0_z, outFlip0, clk);
   
   memMod_dist #(depth*2, width, addrbits+1) s1mem0(x0, t0, {inFlip0, s1wr0}, {outFlip0, s1rd0}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem1(x1, t1, {inFlip0, s1wr0}, {outFlip0, s1rd1}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem2(x2, t2, {inFlip0, s1wr0}, {outFlip0, s1rd2}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem3(x3, t3, {inFlip0, s1wr0}, {outFlip0, s1rd3}, s1wr_en, clk);

shiftRegFIFO #(7, 1) shiftFIFO_46036(.X(next), .Y(next2), .clk(clk));
shiftRegFIFO #(5, 1) shiftFIFO_46037(.X(next2), .Y(next3), .clk(clk));
shiftRegFIFO #(8, 1) shiftFIFO_46038(.X(next3), .Y(next4), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_46039(.X(next4), .Y(next_out), .clk(clk));
shiftRegFIFO #(7, 1) shiftFIFO_46042(.X(tm10), .Y(tm10_d), .clk(clk));
shiftRegFIFO #(4, 1) shiftFIFO_46045(.X(tm10_d), .Y(tm10_dd), .clk(clk));
   
   wire [addrbits-1:0] 	      muxCycle, writeCycle;
assign muxCycle = s1rdloc;
shiftRegFIFO #(4, 3) shiftFIFO_46050(.X(muxCycle), .Y(writeCycle), .clk(clk));
        
   wire 		      readInt, s2wr_en;   
   assign 		      readInt = (state2 == 1);

   shiftRegFIFO #(5, 1) writeIntReg(readInt, s2wr_en, clk);

   memMod_dist #(depth*2, width, addrbits+1) s2mem0(s0, y0, {inFlip1, s2wr0}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem1(s1, y1, {inFlip1, s2wr1}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem2(s2, y2, {inFlip1, s2wr2}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem3(s3, y3, {inFlip1, s2wr3}, {outFlip1, s2rdloc}, s2wr_en, clk);
   always @(posedge clk) begin
      if (reset == 1) begin
	 state1 <= 0;
	 inFlip0 <= 0;	 
	 s1wr0 <= 0;
      end
      else if (next == 1) begin
	 s1wr0 <= 0;
	 state1 <= 1;
	 s1wr_en <= 1;
	 inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
      end
      else begin
	 case(state1)
	   0: begin
	      s1wr0 <= 0;
	      state1 <= 0;
	      s1wr_en <= 0;
	      inFlip0 <= inFlip0;	      
	   end
	   1: begin
	      s1wr0 <= (s1wr0 == depth-1) ? 0 : s1wr0 + 1;
	      state1 <= 1;
         s1wr_en <= 1;
	      inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
	   end
	 endcase
      end      
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	       state2 <= 0;
	       outFlip0_z <= 0;	 
      end
      else if (next2 == 1) begin
	       s1rdloc <= 0;
	       state2 <= 1;
	       outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
      end
      else begin
	 case(state2)
	   0: begin
	      s1rdloc <= 0;
	      state2 <= 0;
	      outFlip0_z <= outFlip0_z;	 
	   end
	   1: begin
	      s1rdloc <= (s1rdloc == depth-1) ? 0 : s1rdloc + 1;
         state2 <= 1;
	      outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
	   end	     
	 endcase
      end
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	 state3 <= 0;
	 outFlip1 <= 0;	 
      end
      else if (next4 == 1) begin
	 s2rdloc <= 0;
	 state3 <= 1;
	 outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;	      
      end
      else begin
	 case(state3)
	   0: begin
	      s2rdloc <= 0;
	      state3 <= 0;
	      outFlip1 <= outFlip1;
	   end
	   1: begin
	      s2rdloc <= (s2rdloc == depth-1) ? 0 : s2rdloc + 1;
         state3 <= 1;
	      outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;
	   end	     
	 endcase
      end
   end
   always @(posedge clk) begin
      case({tm10_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd0 <= 5;
	     {1'd0,  3'd1}: s1rd0 <= 7;
	     {1'd0,  3'd2}: s1rd0 <= 1;
	     {1'd0,  3'd3}: s1rd0 <= 3;
	     {1'd0,  3'd4}: s1rd0 <= 4;
	     {1'd0,  3'd5}: s1rd0 <= 6;
	     {1'd0,  3'd6}: s1rd0 <= 0;
	     {1'd0,  3'd7}: s1rd0 <= 2;
      endcase      
   end

// synthesis attribute rom_style of s1rd0 is "distributed"
   always @(posedge clk) begin
      case({tm10_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd1 <= 1;
	     {1'd0,  3'd1}: s1rd1 <= 3;
	     {1'd0,  3'd2}: s1rd1 <= 5;
	     {1'd0,  3'd3}: s1rd1 <= 7;
	     {1'd0,  3'd4}: s1rd1 <= 0;
	     {1'd0,  3'd5}: s1rd1 <= 2;
	     {1'd0,  3'd6}: s1rd1 <= 4;
	     {1'd0,  3'd7}: s1rd1 <= 6;
      endcase      
   end

// synthesis attribute rom_style of s1rd1 is "distributed"
   always @(posedge clk) begin
      case({tm10_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd2 <= 4;
	     {1'd0,  3'd1}: s1rd2 <= 6;
	     {1'd0,  3'd2}: s1rd2 <= 0;
	     {1'd0,  3'd3}: s1rd2 <= 2;
	     {1'd0,  3'd4}: s1rd2 <= 5;
	     {1'd0,  3'd5}: s1rd2 <= 7;
	     {1'd0,  3'd6}: s1rd2 <= 1;
	     {1'd0,  3'd7}: s1rd2 <= 3;
      endcase      
   end

// synthesis attribute rom_style of s1rd2 is "distributed"
   always @(posedge clk) begin
      case({tm10_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd3 <= 0;
	     {1'd0,  3'd1}: s1rd3 <= 2;
	     {1'd0,  3'd2}: s1rd3 <= 4;
	     {1'd0,  3'd3}: s1rd3 <= 6;
	     {1'd0,  3'd4}: s1rd3 <= 1;
	     {1'd0,  3'd5}: s1rd3 <= 3;
	     {1'd0,  3'd6}: s1rd3 <= 5;
	     {1'd0,  3'd7}: s1rd3 <= 7;
      endcase      
   end

// synthesis attribute rom_style of s1rd3 is "distributed"
    swNet44668 sw(tm10_d, clk, muxCycle, t0, s0, t1, s1, t2, s2, t3, s3);

   always @(posedge clk) begin
      case({tm10_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr0 <= 6;
	      {1'd0, 3'd1}: s2wr0 <= 7;
	      {1'd0, 3'd2}: s2wr0 <= 4;
	      {1'd0, 3'd3}: s2wr0 <= 5;
	      {1'd0, 3'd4}: s2wr0 <= 2;
	      {1'd0, 3'd5}: s2wr0 <= 3;
	      {1'd0, 3'd6}: s2wr0 <= 0;
	      {1'd0, 3'd7}: s2wr0 <= 1;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr0 is "distributed"
   always @(posedge clk) begin
      case({tm10_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr1 <= 4;
	      {1'd0, 3'd1}: s2wr1 <= 5;
	      {1'd0, 3'd2}: s2wr1 <= 6;
	      {1'd0, 3'd3}: s2wr1 <= 7;
	      {1'd0, 3'd4}: s2wr1 <= 0;
	      {1'd0, 3'd5}: s2wr1 <= 1;
	      {1'd0, 3'd6}: s2wr1 <= 2;
	      {1'd0, 3'd7}: s2wr1 <= 3;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr1 is "distributed"
   always @(posedge clk) begin
      case({tm10_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr2 <= 2;
	      {1'd0, 3'd1}: s2wr2 <= 3;
	      {1'd0, 3'd2}: s2wr2 <= 0;
	      {1'd0, 3'd3}: s2wr2 <= 1;
	      {1'd0, 3'd4}: s2wr2 <= 6;
	      {1'd0, 3'd5}: s2wr2 <= 7;
	      {1'd0, 3'd6}: s2wr2 <= 4;
	      {1'd0, 3'd7}: s2wr2 <= 5;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr2 is "distributed"
   always @(posedge clk) begin
      case({tm10_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr3 <= 0;
	      {1'd0, 3'd1}: s2wr3 <= 1;
	      {1'd0, 3'd2}: s2wr3 <= 2;
	      {1'd0, 3'd3}: s2wr3 <= 3;
	      {1'd0, 3'd4}: s2wr3 <= 4;
	      {1'd0, 3'd5}: s2wr3 <= 5;
	      {1'd0, 3'd6}: s2wr3 <= 6;
	      {1'd0, 3'd7}: s2wr3 <= 7;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr3 is "distributed"
endmodule


// Latency: 8
// Gap: 8
module DirSum_45074(clk, reset, next, next_out,
      X0, Y0,
      X1, Y1,
      X2, Y2,
      X3, Y3,
      X4, Y4,
      X5, Y5,
      X6, Y6,
      X7, Y7);

   output next_out;
   input clk, reset, next;

   reg [2:0] i1;

   input [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   always @(posedge clk) begin
      if (reset == 1) begin
         i1 <= 0;
      end
      else begin
         if (next == 1)
            i1 <= 0;
         else if (i1 == 7)
            i1 <= 0;
         else
            i1 <= i1 + 1;
      end
   end

   codeBlock44672 codeBlockIsnt46051(.clk(clk), .reset(reset), .next_in(next), .next_out(next_out),
.i1_in(i1),
       .X0_in(X0), .Y0(Y0),
       .X1_in(X1), .Y1(Y1),
       .X2_in(X2), .Y2(Y2),
       .X3_in(X3), .Y3(Y3),
       .X4_in(X4), .Y4(Y4),
       .X5_in(X5), .Y5(Y5),
       .X6_in(X6), .Y6(Y6),
       .X7_in(X7), .Y7(Y7));

endmodule

module D2_45012(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [2:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h4000;
      1: out3 <= 16'h3b21;
      2: out3 <= 16'h2d41;
      3: out3 <= 16'h187e;
      4: out3 <= 16'h0;
      5: out3 <= 16'he782;
      6: out3 <= 16'hd2bf;
      7: out3 <= 16'hc4df;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D4_45032(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [2:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h3ec5;
      1: out3 <= 16'h3537;
      2: out3 <= 16'h238e;
      3: out3 <= 16'hc7c;
      4: out3 <= 16'hf384;
      5: out3 <= 16'hdc72;
      6: out3 <= 16'hcac9;
      7: out3 <= 16'hc13b;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D6_45052(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [2:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'h0;
      1: out3 <= 16'he782;
      2: out3 <= 16'hd2bf;
      3: out3 <= 16'hc4df;
      4: out3 <= 16'hc000;
      5: out3 <= 16'hc4df;
      6: out3 <= 16'hd2bf;
      7: out3 <= 16'he782;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



module D8_45072(addr, out, clk);
   input clk;
   output [15:0] out;
   reg [15:0] out, out2, out3;
   input [2:0] addr;

   always @(posedge clk) begin
      out2 <= out3;
      out <= out2;
   case(addr)
      0: out3 <= 16'hf384;
      1: out3 <= 16'hdc72;
      2: out3 <= 16'hcac9;
      3: out3 <= 16'hc13b;
      4: out3 <= 16'hc13b;
      5: out3 <= 16'hcac9;
      6: out3 <= 16'hdc72;
      7: out3 <= 16'hf384;
      default: out3 <= 0;
   endcase
   end
// synthesis attribute rom_style of out3 is "distributed"
endmodule



// Latency: 8
// Gap: 1
module codeBlock44672(clk, reset, next_in, next_out,
   i1_in,
   X0_in, Y0,
   X1_in, Y1,
   X2_in, Y2,
   X3_in, Y3,
   X4_in, Y4,
   X5_in, Y5,
   X6_in, Y6,
   X7_in, Y7);

   output next_out;
   input clk, reset, next_in;

   reg next;
   input [2:0] i1_in;
   reg [2:0] i1;

   input [15:0] X0_in,
      X1_in,
      X2_in,
      X3_in,
      X4_in,
      X5_in,
      X6_in,
      X7_in;

   reg   [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   shiftRegFIFO #(7, 1) shiftFIFO_46054(.X(next), .Y(next_out), .clk(clk));


   wire signed [15:0] a105;
   wire signed [15:0] a82;
   wire signed [15:0] a108;
   wire signed [15:0] a86;
   wire signed [15:0] a109;
   wire signed [15:0] a110;
   wire signed [15:0] a113;
   wire signed [15:0] a94;
   wire signed [15:0] a116;
   wire signed [15:0] a98;
   wire signed [15:0] a117;
   wire signed [15:0] a118;
   reg signed [15:0] tm156;
   reg signed [15:0] tm160;
   reg signed [15:0] tm172;
   reg signed [15:0] tm176;
   reg signed [15:0] tm188;
   reg signed [15:0] tm195;
   reg signed [15:0] tm202;
   reg signed [15:0] tm209;
   reg signed [15:0] tm157;
   reg signed [15:0] tm161;
   reg signed [15:0] tm173;
   reg signed [15:0] tm177;
   reg signed [15:0] tm189;
   reg signed [15:0] tm196;
   reg signed [15:0] tm203;
   reg signed [15:0] tm210;
   wire signed [15:0] tm13;
   wire signed [15:0] a87;
   wire signed [15:0] tm14;
   wire signed [15:0] a89;
   wire signed [15:0] tm17;
   wire signed [15:0] a99;
   wire signed [15:0] tm18;
   wire signed [15:0] a101;
   reg signed [15:0] tm158;
   reg signed [15:0] tm162;
   reg signed [15:0] tm174;
   reg signed [15:0] tm178;
   reg signed [15:0] tm190;
   reg signed [15:0] tm197;
   reg signed [15:0] tm204;
   reg signed [15:0] tm211;
   reg signed [15:0] tm40;
   reg signed [15:0] tm41;
   reg signed [15:0] tm48;
   reg signed [15:0] tm49;
   reg signed [15:0] tm159;
   reg signed [15:0] tm163;
   reg signed [15:0] tm175;
   reg signed [15:0] tm179;
   reg signed [15:0] tm191;
   reg signed [15:0] tm198;
   reg signed [15:0] tm205;
   reg signed [15:0] tm212;
   reg signed [15:0] tm192;
   reg signed [15:0] tm199;
   reg signed [15:0] tm206;
   reg signed [15:0] tm213;
   wire signed [15:0] a88;
   wire signed [15:0] a90;
   wire signed [15:0] a91;
   wire signed [15:0] a92;
   wire signed [15:0] a100;
   wire signed [15:0] a102;
   wire signed [15:0] a103;
   wire signed [15:0] a104;
   reg signed [15:0] tm193;
   reg signed [15:0] tm200;
   reg signed [15:0] tm207;
   reg signed [15:0] tm214;
   wire signed [15:0] Y0;
   wire signed [15:0] Y1;
   wire signed [15:0] Y2;
   wire signed [15:0] Y3;
   wire signed [15:0] Y4;
   wire signed [15:0] Y5;
   wire signed [15:0] Y6;
   wire signed [15:0] Y7;
   reg signed [15:0] tm194;
   reg signed [15:0] tm201;
   reg signed [15:0] tm208;
   reg signed [15:0] tm215;


   assign a105 = X0;
   assign a82 = a105;
   assign a108 = X1;
   assign a86 = a108;
   assign a109 = X2;
   assign a110 = X3;
   assign a113 = X4;
   assign a94 = a113;
   assign a116 = X5;
   assign a98 = a116;
   assign a117 = X6;
   assign a118 = X7;
   assign a87 = tm13;
   assign a89 = tm14;
   assign a99 = tm17;
   assign a101 = tm18;
   assign Y0 = tm194;
   assign Y1 = tm201;
   assign Y4 = tm208;
   assign Y5 = tm215;

   D2_45012 instD2inst0_45012(.addr(i1[2:0]), .out(tm13), .clk(clk));

   D4_45032 instD4inst0_45032(.addr(i1[2:0]), .out(tm17), .clk(clk));

   D6_45052 instD6inst0_45052(.addr(i1[2:0]), .out(tm14), .clk(clk));

   D8_45072 instD8inst0_45072(.addr(i1[2:0]), .out(tm18), .clk(clk));

    multfix #(16, 2) m44771(.a(tm40), .b(tm159), .clk(clk), .q_sc(a88), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44793(.a(tm41), .b(tm163), .clk(clk), .q_sc(a90), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44811(.a(tm41), .b(tm159), .clk(clk), .q_sc(a91), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44822(.a(tm40), .b(tm163), .clk(clk), .q_sc(a92), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44931(.a(tm48), .b(tm175), .clk(clk), .q_sc(a100), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44953(.a(tm49), .b(tm179), .clk(clk), .q_sc(a102), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44971(.a(tm49), .b(tm175), .clk(clk), .q_sc(a103), .q_unsc(), .rst(reset));
    multfix #(16, 2) m44982(.a(tm48), .b(tm179), .clk(clk), .q_sc(a104), .q_unsc(), .rst(reset));
    subfxp #(16, 1) sub44800(.a(a88), .b(a90), .clk(clk), .q(Y2));    // 6
    addfxp #(16, 1) add44829(.a(a91), .b(a92), .clk(clk), .q(Y3));    // 6
    subfxp #(16, 1) sub44960(.a(a100), .b(a102), .clk(clk), .q(Y6));    // 6
    addfxp #(16, 1) add44989(.a(a103), .b(a104), .clk(clk), .q(Y7));    // 6


   always @(posedge clk) begin
      if (reset == 1) begin
         tm40 <= 0;
         tm159 <= 0;
         tm41 <= 0;
         tm163 <= 0;
         tm41 <= 0;
         tm159 <= 0;
         tm40 <= 0;
         tm163 <= 0;
         tm48 <= 0;
         tm175 <= 0;
         tm49 <= 0;
         tm179 <= 0;
         tm49 <= 0;
         tm175 <= 0;
         tm48 <= 0;
         tm179 <= 0;
      end
      else begin
         i1 <= i1_in;
         X0 <= X0_in;
         X1 <= X1_in;
         X2 <= X2_in;
         X3 <= X3_in;
         X4 <= X4_in;
         X5 <= X5_in;
         X6 <= X6_in;
         X7 <= X7_in;
         next <= next_in;
         tm156 <= a109;
         tm160 <= a110;
         tm172 <= a117;
         tm176 <= a118;
         tm188 <= a82;
         tm195 <= a86;
         tm202 <= a94;
         tm209 <= a98;
         tm157 <= tm156;
         tm161 <= tm160;
         tm173 <= tm172;
         tm177 <= tm176;
         tm189 <= tm188;
         tm196 <= tm195;
         tm203 <= tm202;
         tm210 <= tm209;
         tm158 <= tm157;
         tm162 <= tm161;
         tm174 <= tm173;
         tm178 <= tm177;
         tm190 <= tm189;
         tm197 <= tm196;
         tm204 <= tm203;
         tm211 <= tm210;
         tm40 <= a87;
         tm41 <= a89;
         tm48 <= a99;
         tm49 <= a101;
         tm159 <= tm158;
         tm163 <= tm162;
         tm175 <= tm174;
         tm179 <= tm178;
         tm191 <= tm190;
         tm198 <= tm197;
         tm205 <= tm204;
         tm212 <= tm211;
         tm192 <= tm191;
         tm199 <= tm198;
         tm206 <= tm205;
         tm213 <= tm212;
         tm193 <= tm192;
         tm200 <= tm199;
         tm207 <= tm206;
         tm214 <= tm213;
         tm194 <= tm193;
         tm201 <= tm200;
         tm208 <= tm207;
         tm215 <= tm214;
      end
   end
endmodule

// Latency: 2
// Gap: 1
module codeBlock45076(clk, reset, next_in, next_out,
   X0_in, Y0,
   X1_in, Y1,
   X2_in, Y2,
   X3_in, Y3,
   X4_in, Y4,
   X5_in, Y5,
   X6_in, Y6,
   X7_in, Y7);

   output next_out;
   input clk, reset, next_in;

   reg next;

   input [15:0] X0_in,
      X1_in,
      X2_in,
      X3_in,
      X4_in,
      X5_in,
      X6_in,
      X7_in;

   reg   [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   shiftRegFIFO #(1, 1) shiftFIFO_46057(.X(next), .Y(next_out), .clk(clk));


   wire signed [15:0] a17;
   wire signed [15:0] a18;
   wire signed [15:0] a19;
   wire signed [15:0] a20;
   wire signed [15:0] a25;
   wire signed [15:0] a26;
   wire signed [15:0] a27;
   wire signed [15:0] a28;
   wire signed [15:0] t49;
   wire signed [15:0] t50;
   wire signed [15:0] t51;
   wire signed [15:0] t52;
   wire signed [15:0] Y0;
   wire signed [15:0] Y1;
   wire signed [15:0] Y2;
   wire signed [15:0] Y3;
   wire signed [15:0] t53;
   wire signed [15:0] t54;
   wire signed [15:0] t55;
   wire signed [15:0] t56;
   wire signed [15:0] Y4;
   wire signed [15:0] Y5;
   wire signed [15:0] Y6;
   wire signed [15:0] Y7;


   assign a17 = X0;
   assign a18 = X2;
   assign a19 = X1;
   assign a20 = X3;
   assign a25 = X4;
   assign a26 = X6;
   assign a27 = X5;
   assign a28 = X7;
   assign Y0 = t49;
   assign Y1 = t50;
   assign Y2 = t51;
   assign Y3 = t52;
   assign Y4 = t53;
   assign Y5 = t54;
   assign Y6 = t55;
   assign Y7 = t56;

    addfxp #(16, 1) add45088(.a(a17), .b(a18), .clk(clk), .q(t49));    // 0
    addfxp #(16, 1) add45103(.a(a19), .b(a20), .clk(clk), .q(t50));    // 0
    subfxp #(16, 1) sub45118(.a(a17), .b(a18), .clk(clk), .q(t51));    // 0
    subfxp #(16, 1) sub45133(.a(a19), .b(a20), .clk(clk), .q(t52));    // 0
    addfxp #(16, 1) add45164(.a(a25), .b(a26), .clk(clk), .q(t53));    // 0
    addfxp #(16, 1) add45179(.a(a27), .b(a28), .clk(clk), .q(t54));    // 0
    subfxp #(16, 1) sub45194(.a(a25), .b(a26), .clk(clk), .q(t55));    // 0
    subfxp #(16, 1) sub45209(.a(a27), .b(a28), .clk(clk), .q(t56));    // 0


   always @(posedge clk) begin
      if (reset == 1) begin
      end
      else begin
         X0 <= X0_in;
         X1 <= X1_in;
         X2 <= X2_in;
         X3 <= X3_in;
         X4 <= X4_in;
         X5 <= X5_in;
         X6 <= X6_in;
         X7 <= X7_in;
         next <= next_in;
      end
   end
endmodule

// Latency: 21
// Gap: 8
module rc45234(clk, reset, next, next_out,
   X0, Y0,
   X1, Y1,
   X2, Y2,
   X3, Y3,
   X4, Y4,
   X5, Y5,
   X6, Y6,
   X7, Y7);

   output next_out;
   input clk, reset, next;

   input [15:0] X0,
      X1,
      X2,
      X3,
      X4,
      X5,
      X6,
      X7;

   output [15:0] Y0,
      Y1,
      Y2,
      Y3,
      Y4,
      Y5,
      Y6,
      Y7;

   wire [31:0] t0;
   wire [31:0] s0;
   assign t0 = {X0, X1};
   wire [31:0] t1;
   wire [31:0] s1;
   assign t1 = {X2, X3};
   wire [31:0] t2;
   wire [31:0] s2;
   assign t2 = {X4, X5};
   wire [31:0] t3;
   wire [31:0] s3;
   assign t3 = {X6, X7};
   assign Y0 = s0[31:16];
   assign Y1 = s0[15:0];
   assign Y2 = s1[31:16];
   assign Y3 = s1[15:0];
   assign Y4 = s2[31:16];
   assign Y5 = s2[15:0];
   assign Y6 = s3[31:16];
   assign Y7 = s3[15:0];

   perm45232 instPerm46058(.x0(t0), .y0(s0),
    .x1(t1), .y1(s1),
    .x2(t2), .y2(s2),
    .x3(t3), .y3(s3),
   .clk(clk), .next(next), .next_out(next_out), .reset(reset)
);



endmodule

module swNet45232(itr, clk, ct
,       x0, y0
,       x1, y1
,       x2, y2
,       x3, y3
);

    parameter width = 32;

    input [2:0] ct;
    input clk;
    input [0:0] itr;
    input [width-1:0] x0;
    output reg [width-1:0] y0;
    input [width-1:0] x1;
    output reg [width-1:0] y1;
    input [width-1:0] x2;
    output reg [width-1:0] y2;
    input [width-1:0] x3;
    output reg [width-1:0] y3;
    wire [width-1:0] t0_0, t0_1, t0_2, t0_3;
    wire [width-1:0] t1_0, t1_1, t1_2, t1_3;
    wire [width-1:0] t2_0, t2_1, t2_2, t2_3;
    reg [width-1:0] t3_0, t3_1, t3_2, t3_3;
    wire [width-1:0] t4_0, t4_1, t4_2, t4_3;
    reg [width-1:0] t5_0, t5_1, t5_2, t5_3;

    reg [1:0] control;

    always @(posedge clk) begin
      case(ct)
        3'd0: control <= 2'b10;
        3'd1: control <= 2'b10;
        3'd2: control <= 2'b10;
        3'd3: control <= 2'b10;
        3'd4: control <= 2'b01;
        3'd5: control <= 2'b01;
        3'd6: control <= 2'b01;
        3'd7: control <= 2'b01;
      endcase
   end

// synthesis attribute rom_style of control is "distributed"
   reg [1:0] control0;
   reg [1:0] control1;
    always @(posedge clk) begin
       control0 <= control;
        control1 <= control0;
    end
    assign t0_0 = x0;
    assign t0_1 = x2;
    assign t0_2 = x1;
    assign t0_3 = x3;
     assign t1_0 = t0_0;
     assign t1_1 = t0_1;
     assign t1_2 = t0_3;
     assign t1_3 = t0_2;
    assign t2_0 = t1_0;
    assign t2_1 = t1_2;
    assign t2_2 = t1_1;
    assign t2_3 = t1_3;
   always @(posedge clk) begin
         t3_0 <= t2_0;
         t3_1 <= t2_1;
         t3_2 <= t2_3;
         t3_3 <= t2_2;
   end
    assign t4_0 = t3_0;
    assign t4_1 = t3_2;
    assign t4_2 = t3_1;
    assign t4_3 = t3_3;
   always @(posedge clk) begin
         t5_0 <= (control1[1] == 0) ? t4_0 : t4_1;
         t5_1 <= (control1[1] == 0) ? t4_1 : t4_0;
         t5_2 <= (control1[0] == 0) ? t4_2 : t4_3;
         t5_3 <= (control1[0] == 0) ? t4_3 : t4_2;
   end
    always @(posedge clk) begin
        y0 <= t5_0;
        y1 <= t5_2;
        y2 <= t5_1;
        y3 <= t5_3;
    end
endmodule

// Latency: 21
// Gap: 8
module perm45232(clk, next, reset, next_out,
   x0, y0,
   x1, y1,
   x2, y2,
   x3, y3);
   parameter width = 32;

   parameter depth = 8;

   parameter addrbits = 3;

   parameter muxbits = 2;

   input [width-1:0]  x0;
   output [width-1:0]  y0;
   wire [width-1:0]  t0;
   wire [width-1:0]  s0;
   input [width-1:0]  x1;
   output [width-1:0]  y1;
   wire [width-1:0]  t1;
   wire [width-1:0]  s1;
   input [width-1:0]  x2;
   output [width-1:0]  y2;
   wire [width-1:0]  t2;
   wire [width-1:0]  s2;
   input [width-1:0]  x3;
   output [width-1:0]  y3;
   wire [width-1:0]  t3;
   wire [width-1:0]  s3;
   input next, reset, clk;
   output next_out;
   reg [addrbits-1:0] s1rdloc, s2rdloc;

    reg [addrbits-1:0] s1wr0;
   reg [addrbits-1:0] s1rd0, s2wr0, s2rd0;
   reg [addrbits-1:0] s1rd1, s2wr1, s2rd1;
   reg [addrbits-1:0] s1rd2, s2wr2, s2rd2;
   reg [addrbits-1:0] s1rd3, s2wr3, s2rd3;
   reg s1wr_en, state1, state2, state3;
   wire 	      next2, next3, next4;
   reg 		      inFlip0, outFlip0_z, outFlip1;
   wire 	      inFlip1, outFlip0;

   wire [0:0] tm19;
   assign tm19 = 0;

shiftRegFIFO #(4, 1) shiftFIFO_46063(.X(outFlip0), .Y(inFlip1), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_46064(.X(outFlip0_z), .Y(outFlip0), .clk(clk));
//   shiftRegFIFO #(2, 1) inFlip1Reg(outFlip0, inFlip1, clk);
//   shiftRegFIFO #(1, 1) outFlip0Reg(outFlip0_z, outFlip0, clk);
   
   memMod_dist #(depth*2, width, addrbits+1) s1mem0(x0, t0, {inFlip0, s1wr0}, {outFlip0, s1rd0}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem1(x1, t1, {inFlip0, s1wr0}, {outFlip0, s1rd1}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem2(x2, t2, {inFlip0, s1wr0}, {outFlip0, s1rd2}, s1wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s1mem3(x3, t3, {inFlip0, s1wr0}, {outFlip0, s1rd3}, s1wr_en, clk);

shiftRegFIFO #(7, 1) shiftFIFO_46073(.X(next), .Y(next2), .clk(clk));
shiftRegFIFO #(5, 1) shiftFIFO_46074(.X(next2), .Y(next3), .clk(clk));
shiftRegFIFO #(8, 1) shiftFIFO_46075(.X(next3), .Y(next4), .clk(clk));
shiftRegFIFO #(1, 1) shiftFIFO_46076(.X(next4), .Y(next_out), .clk(clk));
shiftRegFIFO #(7, 1) shiftFIFO_46079(.X(tm19), .Y(tm19_d), .clk(clk));
shiftRegFIFO #(4, 1) shiftFIFO_46082(.X(tm19_d), .Y(tm19_dd), .clk(clk));
   
   wire [addrbits-1:0] 	      muxCycle, writeCycle;
assign muxCycle = s1rdloc;
shiftRegFIFO #(4, 3) shiftFIFO_46087(.X(muxCycle), .Y(writeCycle), .clk(clk));
        
   wire 		      readInt, s2wr_en;   
   assign 		      readInt = (state2 == 1);

   shiftRegFIFO #(5, 1) writeIntReg(readInt, s2wr_en, clk);

   memMod_dist #(depth*2, width, addrbits+1) s2mem0(s0, y0, {inFlip1, s2wr0}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem1(s1, y1, {inFlip1, s2wr1}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem2(s2, y2, {inFlip1, s2wr2}, {outFlip1, s2rdloc}, s2wr_en, clk);
   memMod_dist #(depth*2, width, addrbits+1) s2mem3(s3, y3, {inFlip1, s2wr3}, {outFlip1, s2rdloc}, s2wr_en, clk);
   always @(posedge clk) begin
      if (reset == 1) begin
	 state1 <= 0;
	 inFlip0 <= 0;	 
	 s1wr0 <= 0;
      end
      else if (next == 1) begin
	 s1wr0 <= 0;
	 state1 <= 1;
	 s1wr_en <= 1;
	 inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
      end
      else begin
	 case(state1)
	   0: begin
	      s1wr0 <= 0;
	      state1 <= 0;
	      s1wr_en <= 0;
	      inFlip0 <= inFlip0;	      
	   end
	   1: begin
	      s1wr0 <= (s1wr0 == depth-1) ? 0 : s1wr0 + 1;
	      state1 <= 1;
         s1wr_en <= 1;
	      inFlip0 <= (s1wr0 == depth-1) ? ~inFlip0 : inFlip0;
	   end
	 endcase
      end      
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	       state2 <= 0;
	       outFlip0_z <= 0;	 
      end
      else if (next2 == 1) begin
	       s1rdloc <= 0;
	       state2 <= 1;
	       outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
      end
      else begin
	 case(state2)
	   0: begin
	      s1rdloc <= 0;
	      state2 <= 0;
	      outFlip0_z <= outFlip0_z;	 
	   end
	   1: begin
	      s1rdloc <= (s1rdloc == depth-1) ? 0 : s1rdloc + 1;
         state2 <= 1;
	      outFlip0_z <= (s1rdloc == depth-1) ? ~outFlip0_z : outFlip0_z;
	   end	     
	 endcase
      end
   end
   
   always @(posedge clk) begin
      if (reset == 1) begin
	 state3 <= 0;
	 outFlip1 <= 0;	 
      end
      else if (next4 == 1) begin
	 s2rdloc <= 0;
	 state3 <= 1;
	 outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;	      
      end
      else begin
	 case(state3)
	   0: begin
	      s2rdloc <= 0;
	      state3 <= 0;
	      outFlip1 <= outFlip1;
	   end
	   1: begin
	      s2rdloc <= (s2rdloc == depth-1) ? 0 : s2rdloc + 1;
         state3 <= 1;
	      outFlip1 <= (s2rdloc == depth-1) ? ~outFlip1 : outFlip1;
	   end	     
	 endcase
      end
   end
   always @(posedge clk) begin
      case({tm19_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd0 <= 1;
	     {1'd0,  3'd1}: s1rd0 <= 3;
	     {1'd0,  3'd2}: s1rd0 <= 5;
	     {1'd0,  3'd3}: s1rd0 <= 7;
	     {1'd0,  3'd4}: s1rd0 <= 0;
	     {1'd0,  3'd5}: s1rd0 <= 2;
	     {1'd0,  3'd6}: s1rd0 <= 4;
	     {1'd0,  3'd7}: s1rd0 <= 6;
      endcase      
   end

// synthesis attribute rom_style of s1rd0 is "distributed"
   always @(posedge clk) begin
      case({tm19_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd1 <= 0;
	     {1'd0,  3'd1}: s1rd1 <= 2;
	     {1'd0,  3'd2}: s1rd1 <= 4;
	     {1'd0,  3'd3}: s1rd1 <= 6;
	     {1'd0,  3'd4}: s1rd1 <= 1;
	     {1'd0,  3'd5}: s1rd1 <= 3;
	     {1'd0,  3'd6}: s1rd1 <= 5;
	     {1'd0,  3'd7}: s1rd1 <= 7;
      endcase      
   end

// synthesis attribute rom_style of s1rd1 is "distributed"
   always @(posedge clk) begin
      case({tm19_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd2 <= 1;
	     {1'd0,  3'd1}: s1rd2 <= 3;
	     {1'd0,  3'd2}: s1rd2 <= 5;
	     {1'd0,  3'd3}: s1rd2 <= 7;
	     {1'd0,  3'd4}: s1rd2 <= 0;
	     {1'd0,  3'd5}: s1rd2 <= 2;
	     {1'd0,  3'd6}: s1rd2 <= 4;
	     {1'd0,  3'd7}: s1rd2 <= 6;
      endcase      
   end

// synthesis attribute rom_style of s1rd2 is "distributed"
   always @(posedge clk) begin
      case({tm19_d, s1rdloc})
	     {1'd0,  3'd0}: s1rd3 <= 0;
	     {1'd0,  3'd1}: s1rd3 <= 2;
	     {1'd0,  3'd2}: s1rd3 <= 4;
	     {1'd0,  3'd3}: s1rd3 <= 6;
	     {1'd0,  3'd4}: s1rd3 <= 1;
	     {1'd0,  3'd5}: s1rd3 <= 3;
	     {1'd0,  3'd6}: s1rd3 <= 5;
	     {1'd0,  3'd7}: s1rd3 <= 7;
      endcase      
   end

// synthesis attribute rom_style of s1rd3 is "distributed"
    swNet45232 sw(tm19_d, clk, muxCycle, t0, s0, t1, s1, t2, s2, t3, s3);

   always @(posedge clk) begin
      case({tm19_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr0 <= 4;
	      {1'd0, 3'd1}: s2wr0 <= 5;
	      {1'd0, 3'd2}: s2wr0 <= 6;
	      {1'd0, 3'd3}: s2wr0 <= 7;
	      {1'd0, 3'd4}: s2wr0 <= 0;
	      {1'd0, 3'd5}: s2wr0 <= 1;
	      {1'd0, 3'd6}: s2wr0 <= 2;
	      {1'd0, 3'd7}: s2wr0 <= 3;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr0 is "distributed"
   always @(posedge clk) begin
      case({tm19_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr1 <= 4;
	      {1'd0, 3'd1}: s2wr1 <= 5;
	      {1'd0, 3'd2}: s2wr1 <= 6;
	      {1'd0, 3'd3}: s2wr1 <= 7;
	      {1'd0, 3'd4}: s2wr1 <= 0;
	      {1'd0, 3'd5}: s2wr1 <= 1;
	      {1'd0, 3'd6}: s2wr1 <= 2;
	      {1'd0, 3'd7}: s2wr1 <= 3;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr1 is "distributed"
   always @(posedge clk) begin
      case({tm19_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr2 <= 0;
	      {1'd0, 3'd1}: s2wr2 <= 1;
	      {1'd0, 3'd2}: s2wr2 <= 2;
	      {1'd0, 3'd3}: s2wr2 <= 3;
	      {1'd0, 3'd4}: s2wr2 <= 4;
	      {1'd0, 3'd5}: s2wr2 <= 5;
	      {1'd0, 3'd6}: s2wr2 <= 6;
	      {1'd0, 3'd7}: s2wr2 <= 7;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr2 is "distributed"
   always @(posedge clk) begin
      case({tm19_dd, writeCycle})
	      {1'd0, 3'd0}: s2wr3 <= 0;
	      {1'd0, 3'd1}: s2wr3 <= 1;
	      {1'd0, 3'd2}: s2wr3 <= 2;
	      {1'd0, 3'd3}: s2wr3 <= 3;
	      {1'd0, 3'd4}: s2wr3 <= 4;
	      {1'd0, 3'd5}: s2wr3 <= 5;
	      {1'd0, 3'd6}: s2wr3 <= 6;
	      {1'd0, 3'd7}: s2wr3 <= 7;
      endcase // case(writeCycle)
   end // always @ (posedge clk)

// synthesis attribute rom_style of s2wr3 is "distributed"
endmodule



						module multfix(clk, rst, a, b, q_sc, q_unsc);
						   parameter WIDTH=35, CYCLES=6;

						   input signed [WIDTH-1:0]    a,b;
						   output [WIDTH-1:0]          q_sc;
						   output [WIDTH-1:0]              q_unsc;

						   input                       clk, rst;
						   
						   reg signed [2*WIDTH-1:0]    q[CYCLES-1:0];
						   wire signed [2*WIDTH-1:0]   res;   
						   integer                     i;

						   assign                      res = q[CYCLES-1];   
						   
						   assign                      q_unsc = res[WIDTH-1:0];
						   assign                      q_sc = {res[2*WIDTH-1], res[2*WIDTH-4:WIDTH-2]};
						      
						   always @(posedge clk) begin
						      q[0] <= a * b;
						      for (i = 1; i < CYCLES; i=i+1) begin
						         q[i] <= q[i-1];
						      end
						   end
						                  
						endmodule 
module addfxp(a, b, q, clk);

   parameter width = 16, cycles=1;
   
   input signed [width-1:0]  a, b;
   input                     clk;   
   output signed [width-1:0] q;
   reg signed [width-1:0]    res[cycles-1:0];

   assign                    q = res[cycles-1];
   
   integer                   i;   
   
   always @(posedge clk) begin
     res[0] <= a+b;
      for (i=1; i < cycles; i = i+1)
        res[i] <= res[i-1];
      
   end
   
endmodule

module subfxp(a, b, q, clk);

   parameter width = 16, cycles=1;
   
   input signed [width-1:0]  a, b;
   input                     clk;   
   output signed [width-1:0] q;
   reg signed [width-1:0]    res[cycles-1:0];

   assign                    q = res[cycles-1];
   
   integer                   i;   
   
   always @(posedge clk) begin
     res[0] <= a-b;
      for (i=1; i < cycles; i = i+1)
        res[i] <= res[i-1];
      
   end
  
endmodule