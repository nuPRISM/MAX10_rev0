`include "log2_function.v"

module Parallel_LFSR
#(
parameter LFSR_LENGTH = 3,
parameter OUTPUT_WIDTH = 10,
parameter log2_LFSR_LENGTH = log2(LFSR_LENGTH),
parameter log2_OUTPUT_WIDTH = log2(OUTPUT_WIDTH),
parameter bits_counter_width = log2_OUTPUT_WIDTH + log2_LFSR_LENGTH+2,
parameter interim_reg_width = OUTPUT_WIDTH+2*LFSR_LENGTH-OUTPUT_WIDTH%LFSR_LENGTH,
parameter num_LFSR_lengths_in_interim_reg = interim_reg_width/LFSR_LENGTH,
parameter num_output_widths_in_interim_reg = (interim_reg_width-(interim_reg_width%OUTPUT_WIDTH))/OUTPUT_WIDTH,
//parameter LFSR_Transition_Matrix = 9'b011111101,
parameter lfsr_init_val = 1
)
(
  input wire [LFSR_LENGTH*LFSR_LENGTH-1:0] LFSR_Transition_Matrix,
  input sm_clk,
  input start,
  output finish,
  output reg  [OUTPUT_WIDTH-1 : 0] output_parallel_LFSR_bits = 0,
  output reg  [interim_reg_width-1:0] interim_reg = 0,
  input reset,
  output wire inc_lfsr_counter, inc_output_counter, dec_num_bits_ready, num_bits_ready_clk, output_clk,shift_output_reg_clk,
  output reg [bits_counter_width-1:0] residue_number=0,
  output reg  [num_LFSR_lengths_in_interim_reg:0] lfsr_width_counter=0,
  output wire [interim_reg_width-1:0] next_interim_reg_val[0:(LFSR_LENGTH-1)],
  output reg  [LFSR_LENGTH-1:0] lfsr=lfsr_init_val,
  output  wire [LFSR_LENGTH-1:0] next_lfsr_val,
  output  wire lfsr_clk,
  output  reg  [bits_counter_width-1:0] num_bits_ready=0,
  output wire [interim_reg_width-1:0] next_output_val,
  output wire clear_lfsr_width_counter

);

integer n;
generate
        genvar i;
		for (i=0; i<LFSR_LENGTH; i++)
		begin : gen_next_lfsr_val
		     assign next_lfsr_val[i] = ^(LFSR_Transition_Matrix[((i+1)*LFSR_LENGTH-1) -: LFSR_LENGTH] & lfsr);
		end
endgenerate


generate
        genvar j,m;
		for (m=0; m < LFSR_LENGTH; m++)
		begin : gen_next_interim_val	
		   for (j=0; j<num_LFSR_lengths_in_interim_reg; j++)
			begin :gen_next_interim_val1
			     if (m !=0)  
				 begin
				       if (j != num_LFSR_lengths_in_interim_reg-1)
						begin
		                     assign next_interim_reg_val[m][((j+1)*LFSR_LENGTH+m-1) -: LFSR_LENGTH] = (lfsr_width_counter==j) ? lfsr :interim_reg[((j+1)*LFSR_LENGTH+m-1) -: LFSR_LENGTH];
							 assign next_interim_reg_val[m][m-1:0] = interim_reg[m-1:0];			 
						end
			     end else
				 begin
				        assign next_interim_reg_val[m][((j+1)*LFSR_LENGTH-1) -: LFSR_LENGTH] = (lfsr_width_counter==j) ? lfsr :interim_reg[((j+1)*LFSR_LENGTH-1) -: LFSR_LENGTH];
				 end
			end	 				 
		end
endgenerate

				

always @(posedge lfsr_clk or negedge reset)
begin
     if (!reset)
	 begin
	     lfsr <= lfsr_init_val;
		 interim_reg <= 0;
     end
	 else if (shift_output_reg_clk)
		begin
		        lfsr <= (lfsr == 0) ? lfsr_init_val :  lfsr;
		        for(n=2*LFSR_LENGTH-(OUTPUT_WIDTH%LFSR_LENGTH)-1;n>=0;n--) 
					interim_reg[n]<=interim_reg[n+OUTPUT_WIDTH];
					
		end
	 else
	  begin
         lfsr <= (lfsr == 0) ? lfsr_init_val : next_lfsr_val;
		 interim_reg <=next_interim_reg_val[residue_number];
	  end
end


always @(posedge inc_lfsr_counter or negedge reset)
begin
    if (!reset)
      lfsr_width_counter <= 0;
  else
  begin
      if (clear_lfsr_width_counter)             //(lfsr_width_counter >= num_LFSR_lengths_in_interim_reg-1)
         lfsr_width_counter <= 0;
      else
          lfsr_width_counter <= lfsr_width_counter + 1;
   end
end

always @(posedge output_clk)
begin
    	output_parallel_LFSR_bits<=interim_reg[OUTPUT_WIDTH-1 -:OUTPUT_WIDTH];	
					
end


always @(posedge num_bits_ready_clk or negedge reset)
begin
    if (!reset)
	begin
	     num_bits_ready <= 0;
		 residue_number <= 0;
    end
    else if (dec_num_bits_ready)
	begin
		num_bits_ready <= num_bits_ready - OUTPUT_WIDTH;
		residue_number <= num_bits_ready - OUTPUT_WIDTH;			
    end
	else //increment num of bits ready
	begin
	     num_bits_ready <= num_bits_ready + LFSR_LENGTH;
		 residue_number <= residue_number;
	end
end	

parameter idle 							    = 16'b0000_0000_0000_0000;
parameter check_situation 				    = 16'b0001_0000_0000_0000;
parameter get_next_LFSR_value 			 = 16'b0010_0000_0000_0011;
parameter inc_lfsr_count_state          = 16'b0011_0000_0000_1000;
parameter set_output_values 			    = 16'b0100_0000_0010_0100;
parameter pre_shift_output_register     = 16'b0101_0000_1011_0010;
parameter shift_output_register         = 16'b0111_0000_1011_0011;
parameter pre_clr_lfsr_width_counter    = 16'b1000_0001_0000_0000;
parameter clr_lfsr_width_counter        = 16'b1001_0001_0000_1000;
parameter finished 						    = 16'b1010_0000_0100_0000;

reg [15:0] state = idle;

assign lfsr_clk           = state[0];
assign num_bits_ready_clk = state[1];
assign output_clk         = state[2];
assign inc_lfsr_counter   = state[3];
assign inc_output_counter = state[4];
assign dec_num_bits_ready = state[5];
assign finish             = state[6];
assign shift_output_reg_clk   = state[7];
assign clear_lfsr_width_counter = state[8];

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
							/*else if (num_bits_ready>interim_reg_width-LFSR_LENGTH)
								state<=finished;*/
							else
							   state <= get_next_LFSR_value;
		  get_next_LFSR_value: state <= inc_lfsr_count_state;
		  inc_lfsr_count_state : state <= check_situation;
		  set_output_values : state<=pre_shift_output_register;
		  pre_shift_output_register : state <=shift_output_register;
		  shift_output_register : state <=pre_clr_lfsr_width_counter; //get_next_LFSR_value;
		  pre_clr_lfsr_width_counter : state <= clr_lfsr_width_counter;
          clr_lfsr_width_counter : state <= finished;
		  finished : state <= idle;
		  endcase
	 end
end

		  
endmodule
