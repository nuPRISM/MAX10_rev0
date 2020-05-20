
module data_chooser_14bit_according_to_frame_position 
(
 input        [27:0] data_reg_contents,
 input        [3:0]  selection_value,
 output logic [13:0] selected_data_reg_contents,
 input clk
);

  (* keep = 1 *) logic [13:0]  raw_selected_data_reg_contents_keeper;
  always @(posedge clk)
  begin
      raw_selected_data_reg_contents_keeper   <= data_reg_contents[13+selection_value -: 14];
  end
  
  assign selected_data_reg_contents = raw_selected_data_reg_contents_keeper;
endmodule
