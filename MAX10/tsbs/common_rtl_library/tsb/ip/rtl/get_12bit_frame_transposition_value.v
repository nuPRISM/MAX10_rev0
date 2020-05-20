
module get_12bit_frame_transposition_value
(
 input [11:0] frame_reg_contents,
 output reg [3:0] transposition_value,
 output reg is_valid
);

always @*
begin
   case (frame_reg_contents)
   12'b111111000000 : begin is_valid = 1'b1; transposition_value =  4'd0;  end
   12'b111110000001 : begin is_valid = 1'b1; transposition_value =  4'd1;  end
   12'b111100000011 : begin is_valid = 1'b1; transposition_value =  4'd2;  end
   12'b111000000111 : begin is_valid = 1'b1; transposition_value =  4'd3;  end
   12'b110000001111 : begin is_valid = 1'b1; transposition_value =  4'd4;  end
   12'b100000011111 : begin is_valid = 1'b1; transposition_value =  4'd5;  end
   12'b000000111111 : begin is_valid = 1'b1; transposition_value =  4'd6;  end
   12'b000001111110 : begin is_valid = 1'b1; transposition_value =  4'd7;  end
   12'b000011111100 : begin is_valid = 1'b1; transposition_value =  4'd8;  end
   12'b000111111000 : begin is_valid = 1'b1; transposition_value =  4'd9;  end
   12'b001111110000 : begin is_valid = 1'b1; transposition_value = 4'd10;  end
   12'b011111100000 : begin is_valid = 1'b1; transposition_value = 4'd11;  end
   default: begin transposition_value = 4'h0; is_valid = 1'b0; end
   endcase
end


endmodule
