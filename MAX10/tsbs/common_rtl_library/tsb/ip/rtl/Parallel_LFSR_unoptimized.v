module Parallel_LFSR_unoptimized
#(
parameter LFSR_LENGTH = 3,
parameter OUTPUT_WIDTH = 10,
parameter log2_LFSR_LENGTH = 2,
parameter log2_OUTPUT_WIDTH = 4,
parameter bits_counter_width = log2_OUTPUT_WIDTH + log2_LFSR_LENGTH+2,
/*
    In general,  length(interm_reg)= num_LFSR_lengths_in_interim_reg*LFSR_LENGTH  = OUTPUT_WIDTH*num_output_widths_in_interim_eg,
    if there are common factors an effort should be made to shorten the length of that register
*/
parameter num_LFSR_lengths_in_interim_reg = OUTPUT_WIDTH,
parameter num_output_widths_in_interim_reg = LFSR_LENGTH,
parameter interim_reg_width = num_LFSR_lengths_in_interim_reg*LFSR_LENGTH,
parameter lfsr_init_val = 1
)
(
  input wire [LFSR_LENGTH*LFSR_LENGTH-1:0] LFSR_Transition_Matrix,
  input sm_clk,
  input start,
  output finish,
  output reg  [OUTPUT_WIDTH-1 : 0] output_parallel_LFSR_bits = 0,
  output reg  [interim_reg_width-1:0] interim_reg = 0,
  input reset
);

reg  [LFSR_LENGTH-1:0] lfsr=lfsr_init_val;
wire [LFSR_LENGTH-1:0] next_lfsr_val;
wire lfsr_clk;
reg  [bits_counter_width-1:0] num_bits_ready=0;
reg  [num_output_widths_in_interim_reg:0] output_width_counter=0;
reg  [num_LFSR_lengths_in_interim_reg:0] lfsr_width_counter=0;
wire inc_lfsr_counter, inc_output_counter, dec_num_bits_ready, num_bits_ready_clk, output_clk;
wire [interim_reg_width-1:0] next_interim_reg_val;

generate
        genvar i;
		for (i=0; i<LFSR_LENGTH; i++)
		begin : gen_next_lfsr_val
		     assign next_lfsr_val[i] = ^(LFSR_Transition_Matrix[((i+1)*LFSR_LENGTH-1) -: LFSR_LENGTH] & lfsr);
		end
endgenerate


generate
        genvar j;
		for (j=0; j<num_LFSR_lengths_in_interim_reg; j++)
		begin : gen_next_interim_val
		     assign next_interim_reg_val[((j+1)*LFSR_LENGTH-1) -: LFSR_LENGTH] =  (lfsr_width_counter == j) ? lfsr : interim_reg[((j+1)*LFSR_LENGTH-1) -: LFSR_LENGTH];
		end
endgenerate

always @(posedge lfsr_clk or negedge reset)
begin
     if (!reset)
	 begin
	     lfsr <= lfsr_init_val;
		 interim_reg <= 0;
     end
	 else
	 begin
         lfsr <= next_lfsr_val;
		 interim_reg <= next_interim_reg_val;
	 end
end

always @(posedge inc_output_counter or negedge reset)
begin
    if (!reset)
      output_width_counter <= 0;
  else
  begin
      if (output_width_counter >= num_output_widths_in_interim_reg-1)
         output_width_counter <= 0;
      else
          output_width_counter <= output_width_counter + 1;
   end
end


always @(posedge inc_lfsr_counter or negedge reset)
begin
    if (!reset)
      lfsr_width_counter <= 0;
  else
  begin
      if (lfsr_width_counter >= num_LFSR_lengths_in_interim_reg-1)
         lfsr_width_counter <= 0;
      else
          lfsr_width_counter <= lfsr_width_counter + 1;
   end
end

always @(posedge output_clk)
begin
     output_parallel_LFSR_bits <= interim_reg[((output_width_counter+1)*OUTPUT_WIDTH-1) -: OUTPUT_WIDTH];
end

always @(posedge num_bits_ready_clk or negedge reset)
begin
    if (!reset)
	     num_bits_ready <= 0;
    else if (dec_num_bits_ready)
	     num_bits_ready <= num_bits_ready - OUTPUT_WIDTH;
	else //increment num of bits ready
	     num_bits_ready <= num_bits_ready + LFSR_LENGTH;
end	

parameter idle 							= 15'b0000_000000000000;
parameter check_situation 				= 15'b0001_000000000000;
parameter get_next_LFSR_value 			= 15'b0010_000000000011;
parameter inc_lfsr_count_state          = 15'b0011_000000001000;
parameter set_output_values 			= 15'b0100_000000100100;
parameter inc_output_count_state        = 15'b0101_000000110010;
parameter finished 						= 15'b0110_000001000000;

reg [15:0] state = idle;

assign lfsr_clk           = state[0];
assign num_bits_ready_clk = state[1];
assign output_clk         = state[2];
assign inc_lfsr_counter   = state[3];
assign inc_output_counter = state[4];
assign dec_num_bits_ready = state[5];
assign finish             = state[6];

always @(posedge sm_clk or negedge reset)
begin
     if (!reset)
	 begin
	      state <= idle;
	 end
	 else 
	 begin
	      case (state)
		  idle : if (start)
		           state <= check_situation;
				 else
				   state <= idle;
		  check_situation : if (num_bits_ready >= OUTPUT_WIDTH)
		                       state <= set_output_values;
							else
							   state <= get_next_LFSR_value;
		  get_next_LFSR_value: state <= inc_lfsr_count_state;
		  inc_lfsr_count_state : state <= check_situation;
		  set_output_values : state <= inc_output_count_state;
		  inc_output_count_state : state <= finished;
		  finished : state <= idle;
		  endcase
	 end
end


endmodule
