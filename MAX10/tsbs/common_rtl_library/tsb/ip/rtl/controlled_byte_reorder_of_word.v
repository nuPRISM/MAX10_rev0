module controlled_byte_reorder_of_word
(
input [31:0] inword,
output [31:0] outword,
input reorder
);

assign outword = reorder ? {inword[7:0],inword[15:8],inword[23:16],inword[31:24]} : inword;

endmodule
