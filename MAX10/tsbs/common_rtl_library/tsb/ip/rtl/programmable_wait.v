
module programmable_wait
               ( //Inputs
				 SM_CLK,
				 RESET_N,
				 START,
				 AMOUNT,
				//Outputs
				 FINISH
			    );
				 
parameter width = 24;

input			START;
input[width-1:0]		AMOUNT;
input			RESET_N;
input			SM_CLK;

output			FINISH;

wire			SM_CLK;
wire			RESET_N;
wire			START;
wire[width-1:0]		AMOUNT;

wire			FINISH;
reg[5:0]		state = 0;		 /// ______ count
reg[width-1:0]		counter;	///_/_
parameter	idle	                 =	6'b000_000;
parameter	reset_counter_now	     =	6'b001_001;
parameter	wait_counter_reset	     =	6'b000_010;
parameter	count_now	             =	6'b010_011; 
parameter	finished	             =	6'b100_100;

wire	reset_counter	=	state[3];
wire	cnt_en	        =	state[4];
assign	FINISH	        =	state[5];

always @(posedge SM_CLK	or negedge RESET_N)
		if(~RESET_N)
			begin
				state	<=	idle;
			end
		else
			begin
				case (state)
					idle	:	begin
									if(START)
										begin
											state	<=	reset_counter_now;
											
										end
									else
										state	<=	idle;
								end
					reset_counter_now	:	state	<=	wait_counter_reset;
					wait_counter_reset	:	state	<=	count_now;
					count_now	:	    if(counter >= AMOUNT)
										state	<=	finished;
									else
										state	<=	count_now;
								
					finished	:	state	<=	idle;
					default;
				endcase
			end

				
			
always	@(posedge SM_CLK or posedge reset_counter)
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
			

endmodule
				 