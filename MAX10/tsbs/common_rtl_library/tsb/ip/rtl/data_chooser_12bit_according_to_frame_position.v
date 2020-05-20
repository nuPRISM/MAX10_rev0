
module data_chooser_12bit_according_to_frame_position 
(
 input      [23:0] data_reg_contents,
 input      [3:0]  selection_value,
 output logic [11:0] selected_data_reg_contents,
 input clk
);

  (* keep = 1 *) logic [11:0]  raw_selected_data_reg_contents_keeper;
  always @(posedge clk)
  begin
      raw_selected_data_reg_contents_keeper   <= data_reg_contents[11+selection_value -: 12];
  end
  
  assign selected_data_reg_contents = raw_selected_data_reg_contents_keeper;
endmodule
