
module programmable_wait_synchronous
               ( //Inputs
				 clk,
				 reset,
				 start,
				 wait_cycles,
				//Outputs
				 ready,
				 finish
			    );
				 
parameter width = 24;

input			start;
input[width-1:0]		wait_cycles;
input			reset;
input			clk;

output logic ready;
output			finish;

wire			clk;
wire			reset;
wire			start;
wire [width-1:0]		wait_cycles;

wire			finish;
reg [width-1:0]		counter = 0;	

parameter	idle	                   =	6'b0000_00;
parameter	count_now	             =	6'b0111_01; 
parameter	finished	                =	6'b1001_10;
reg[5:0]    state = idle;		 

wire	reset_counter	=	!state[3];
wire	cnt_en	        =	state[4];
assign	finish	        =	state[5];
assign ready = !state[2];

always @(posedge clk)
		if(reset)
			begin
				state	<=	idle;
			end
		else
			begin
				case (state)
					idle	:	begin
									if(start)
									begin
									    if (wait_cycles >= 2)
										begin
											state	<=	count_now;											
										end else
										begin
										    state <= finished;
										end
									end
									else
										state	<=	idle;
								end
					count_now	:	if (counter >= (wait_cycles-2))
										state	<=	finished;
									else
										state	<=	count_now;							
					finished	:	state	<=	idle;
					default;
				endcase
			end

				
			
always	@(posedge clk)
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
				 