module SR_latch(input set, input reset, output q);

reg Qs=0, Qr=0;
always @(posedge set) Qs <= ~Qr;
always @(posedge reset) Qr <= Qs;
assign q = Qr ^ Qs;

endmodule
