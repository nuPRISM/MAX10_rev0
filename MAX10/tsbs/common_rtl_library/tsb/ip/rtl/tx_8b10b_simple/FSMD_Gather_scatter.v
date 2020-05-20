`default_nettype none
module FSMD_Gather_scatter(
			
			input clk_fsm,
			input sending_clk_sync,
			//XCVR FIFO
			input [7:0]data_fifo_xcvr,
			input fifo_empty_xcvr,
			output fifo_read_xcvr,
			
			
			//UART FIFO
			input [7:0]data_fifo_uart,
			input fifo_empty_uart,
			output fifo_read_uart,
			
			
			//Data Output
			output reg [7:0]data_8b10=8'd0,
			output reg is_control_char,
			output reg is_padding_char,
			output enable_data_out,
			output busy,
			input [7:0] padding_char,
			output raw_is_control_char,
			output raw_is_padding_char
			
			//debug outputs
			
			
);
								  
localparam IDLE					   = 16'b000000_0000;
localparam PRIO_CHOOSER			   = 16'b000010_0001;
localparam READ_FIFO_SET_XCVR	   = 16'b000110_0010;
localparam READ_FIFO_XCVR		   = 16'b000010_0011;
localparam READ_FIFO_SET_UART	   = 16'b001010_0110;
localparam READ_FIFO_UART		   = 16'b000011_0111;
localparam pre_clock_data_out	   = 16'b000010_1000;
localparam pre_clock_control_out   = 16'b000011_1001;
localparam pre_clock_padding_out   = 16'b100011_1010;
localparam clock_data_out		   = 16'b010010_1000;
localparam clock_control_out	   = 16'b010011_1001;
localparam clock_padding_out	   = 16'b110011_1010;


reg [15:0]state=IDLE;


assign raw_is_control_char=state[4];
assign busy=state[5];
assign fifo_read_xcvr=state[6];
assign fifo_read_uart=state[7];
assign enable_data_out=state[8];
assign raw_is_padding_char=state[9];
		
always@(posedge clk_fsm)
begin
	case(state)
	IDLE				: if(sending_clk_sync==1'b1)
						  begin
						  	state<=PRIO_CHOOSER;
						  end		
						  
	PRIO_CHOOSER		:begin
							 if(fifo_empty_xcvr==1'b0)
							 begin
								state<=READ_FIFO_SET_XCVR;
							 end		
							 else if(fifo_empty_uart==1'b0)
							 begin
								state<=READ_FIFO_SET_UART;
							 end else
							 state <= pre_clock_padding_out;
						 end
						 
    pre_clock_padding_out : state <= clock_padding_out;
    clock_padding_out : state <= IDLE;
	
	READ_FIFO_SET_XCVR:begin
								state<=READ_FIFO_XCVR;
	                   end	
	READ_FIFO_XCVR		:begin
								state<=pre_clock_data_out;
						 end
						 
    pre_clock_data_out : state <= clock_data_out;
    clock_data_out : state <= IDLE;
						

	READ_FIFO_SET_UART:begin
							state<=READ_FIFO_UART;
	                   end	
	READ_FIFO_UART	  :begin
								state<=pre_clock_control_out;	
					   end	

    pre_clock_control_out : state <= clock_control_out;
    clock_control_out : state <= IDLE;
						   
	endcase
	
	
end

//FSMD
always@(posedge clk_fsm)	 
begin
    if (enable_data_out)
    begin
	    data_8b10[7:0]  <= raw_is_padding_char ? padding_char : (raw_is_control_char? data_fifo_uart[7:0] : data_fifo_xcvr[7:0]);
	    is_control_char <= raw_is_control_char;
	    is_padding_char <= raw_is_padding_char;
	end	
end
	   


endmodule
`default_nettype wire