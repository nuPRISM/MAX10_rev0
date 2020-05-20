module parallel_multiple_parallel_output_lfsrs_w_sm
#(
parameter [7:0] counter_bits = 8,
parameter [31:0] NUM_LFSRS = 3,
parameter [31:0] MAX_LFSR_WIDTH = 9,
parameter [31:0] NUM_OUTPUT_BITS = 10,
parameter bit [31:0] LFSR_WIDTHS[NUM_LFSRS] = '{3, 7, 9},
parameter bit [MAX_LFSR_WIDTH-1:0] FEEDBACK_TAPS[NUM_LFSRS] =  '{3'b010, 7'b0100000, 9'b000010000},
parameter bit [MAX_LFSR_WIDTH-1:0] INITIAL_LFSR_VALS[NUM_LFSRS] = '{NUM_LFSRS{1'b1}}
)
(
output  logic   [MAX_LFSR_WIDTH-1:0]  in_vector[NUM_LFSRS],
output  logic   [NUM_OUTPUT_BITS-1:0] out_data[NUM_LFSRS],
input do_not_transpose_output_data,
input clk,
input reset,
input start,
input [counter_bits-1:0] wait_count,
output logic finish,

//debugging
output logic in_vector_clock_enable,
output logic out_data_clock_enable,
output reg  [counter_bits-1:0] counter = 0,
output logic  reset_counter,
output logic  cnt_en,
output reg [15:0] state = 0

);

multiple_parallel_output_lfsrs_with_clk_enable
#(
.NUM_LFSRS                   (NUM_LFSRS                   ),
.MAX_LFSR_WIDTH              (MAX_LFSR_WIDTH              ),
.NUM_OUTPUT_BITS             (NUM_OUTPUT_BITS             ),
.LFSR_WIDTHS                 (LFSR_WIDTHS                 ),
.FEEDBACK_TAPS               (FEEDBACK_TAPS               ),
.INITIAL_LFSR_VALS           (INITIAL_LFSR_VALS           )
)
multiple_parallel_output_lfsrs_with_clk_enable_inst
(
.*
);

    	                             ////876543210_987654_3210  
	 parameter idle                         = 16'b000_0000_0000;
	 parameter assert_in_vec_clk_en         = 16'b000_0001_0001;
	 parameter wait_for_lfsr_tpd            = 16'b000_1000_0010;
 	 parameter assert_out_vec_clk_en  	    = 16'b000_0010_0011;
	 parameter finished                     = 16'b001_0100_0100;
	 	 
	
	 assign in_vector_clock_enable = state[4];
	 assign out_data_clock_enable = state[5];
	 assign reset_counter = state[6];
	 assign cnt_en = state[7];
	 assign finish = state[8];
	 
	 
	 
	 always @(posedge clk)
	 begin
			  if (reset)
			  begin
					state <= idle;
			  end else
			  begin
					case (state) 
					idle :  if (start)
					        begin
              					state <= assert_in_vec_clk_en;
						    end
							
				    assert_in_vec_clk_en:  state <= wait_for_lfsr_tpd;
					wait_for_lfsr_tpd : if (counter >= wait_count) 
					                    begin
					                       state <= assert_out_vec_clk_en;
										end
										
					assert_out_vec_clk_en: state <= finished;
					finished : state <= idle;
					endcase
			  end
	end
	
	
always	@(posedge clk)
begin
		if(reset_counter)
		begin
			counter	<=	0;
		end
		else
		begin 
			if (cnt_en)
			begin
				 counter	<=	counter	+ 1;	
			end
		end
end
			

endmodule
