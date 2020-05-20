
module data_chooser_according_to_frame_position 
#(
parameter numbits_dataout = 40
)
(
 data_reg_contents,
 selection_value,
 selected_data_reg_contents,
 clk
);


	function automatic int log2 (input int n);
						int original_n;
						original_n = n;
						if (n <=1) return 1; // abort function
						log2 = 0;
						while (n > 1) begin
						    n = n/2;
						    log2++;
						end
						
						if (2**log2 != original_n)
						begin
						     log2 = log2 + 1;
						end
						
						endfunction
						
 input        [(2*numbits_dataout)-1:0] data_reg_contents;
 input        [log2(numbits_dataout)-1:0]  selection_value;
 output logic [numbits_dataout-1:0] selected_data_reg_contents;
 input clk;			
						
  (* keep = 1 *) logic [numbits_dataout-1:0]  raw_selected_data_reg_contents_keeper;
  always @(posedge clk)
  begin
      raw_selected_data_reg_contents_keeper   <= data_reg_contents[numbits_dataout-1+selection_value -: numbits_dataout];
  end
  
  assign selected_data_reg_contents = raw_selected_data_reg_contents_keeper;
endmodule
