module Serial_Markov_Sequence_Generator_w_reset
#(
  parameter LFSR_LENGTH = 3,
  parameter [LFSR_LENGTH-1:0] lfsr_init_val = 1
)
(
  input  wire [LFSR_LENGTH*LFSR_LENGTH-1:0] LFSR_Transition_Matrix,
  input  wire clk,
  output reg  [LFSR_LENGTH-1:0] lfsr=lfsr_init_val,
  input  wire reset,
  output reg serial_output = 0,
  input wire reverse_serial_output
);

wire [LFSR_LENGTH-1:0] next_lfsr_val;

generate
        genvar i;
		for (i=0; i<LFSR_LENGTH; i++)
		begin : gen_next_lfsr_val
		     assign next_lfsr_val[i] = ^(LFSR_Transition_Matrix[((i+1)*LFSR_LENGTH-1) -: LFSR_LENGTH] & lfsr);
		end
endgenerate

always @(posedge clk)
begin    
         if (reset)
         begin
                lfsr <= lfsr_init_val;
         end else
         begin
                lfsr <= (lfsr == 0) ? {{(LFSR_LENGTH-1){1'b0}},1'b1} : next_lfsr_val;
         end
end

always @(posedge clk)
begin
     serial_output <= reverse_serial_output ? lfsr[LFSR_LENGTH-1] : lfsr[0];
end

endmodule
