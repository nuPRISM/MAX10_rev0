module sr_latch_via_sync_edge_detect(input set, input reset, output reg q, input clk);


reg Qs=0, Qr=0;

reg prev_set, prev_reset;

always @(posedge clk)
begin
      prev_set <= set;
		prev_reset <= reset;
end
logic edge_detect_set;
logic edge_detect_reset;
assign edge_detect_set = !prev_set & set;
assign edge_detect_reset = !prev_reset & reset;

always @(posedge clk)
begin 
		if (edge_detect_set)
		begin
				Qs <= ~Qr;
		end
end

always @(posedge clk)
begin 
		if (edge_detect_reset) 
		begin
			  Qr <= Qs;
		end
end

always @(posedge clk)
begin
     q <= Qr ^ Qs;
end

endmodule
