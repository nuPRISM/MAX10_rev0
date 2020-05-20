
module simple_altddio 
#(
parameter USE_ARRIA10 = 1
)
(	
	input datain_h,
	input datain_l,
	input clk,
	output dataout
);
			generate
					if (USE_ARRIA10) 
					begin
					//note datain_h and datain_l swap which is intentional, given migration guidelines for Arria 10 GPIO core
									arria10_altddio_1bit arria10_altddio_1bit_inst (
										.dataout  (dataout),  //  pad_out.export
										.ck       (clk),       //       ck.export
										.datain_h (datain_l), // datain_h.fragment
										.datain_l (datain_h)  // datain_l.fragment
									);
					end else
					begin
								altddio_out	altddio_out_component (
												.outclock (clk),
												.datain_h (datain_h),
												.aclr (1'b0),
												.datain_l (datain_l),
												.dataout (dataout),
												.aset (1'b0),
												.oe (1'b1),
												.outclocken (1'b1));
									defparam
										altddio_out_component.extend_oe_disable = "UNUSED",
										altddio_out_component.intended_device_family = "Arria 10",
										altddio_out_component.lpm_type = "altddio_out",
										altddio_out_component.oe_reg = "UNUSED",
										altddio_out_component.width = 1;
					end	
			endgenerate	
endmodule		