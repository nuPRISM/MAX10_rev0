`default_nettype none
module control_8b10b_simple_tx
#( 
 parameter numchannels=2,
 parameter out_data_bits_per_channel = 8,
 parameter control_chars_width = 8
)

(
			
			input clk_fsm,
			input sending_clk_sync,
			//XCVR FIFO
			input [out_data_bits_per_channel-1:0] data_fifo_xcvr[numchannels],
			input fifo_empty_xcvr,
			output fifo_read_xcvr,
			
			
			//UART FIFO
			input [control_chars_width-1:0]data_fifo_uart[numchannels],
			input fifo_empty_uart[numchannels],
			output fifo_read_uart[numchannels],
			output fifo_read_uart_raw,
			
			
			//Data Output
			output reg [7:0]data_8b10[numchannels]=8'd0,
			output reg is_control_char,
			output reg is_padding_char[numchannels],
			output enable_data_out,
			output busy,
			input [7:0] padding_char[numchannels],
			output raw_is_control_char,
			output raw_is_padding_char[numchannels],
			output reg [15:0]state,
			output reset_control_and_padding_char

			//debug outputs
			
			
);
								  
localparam IDLE					   = 16'b000000_0000;
localparam READ_FIFO_SET_XCVR	   = 16'b100110_0010;
localparam READ_FIFO_XCVR		   = 16'b000010_0011;
localparam READ_FIFO_SET_UART	   = 16'b001011_0110;
localparam READ_FIFO_UART		   = 16'b000011_0111;
localparam pre_clock_data_out	   = 16'b000010_1000;
localparam pre_clock_control_out   = 16'b000011_1001;
localparam clock_data_out		   = 16'b010010_1000;
localparam clock_control_out	   = 16'b010011_1001;




assign raw_is_control_char=state[4];
assign busy=state[5];
assign fifo_read_xcvr=state[6];
assign fifo_read_uart_raw=state[7];
assign enable_data_out=state[8];
assign reset_control_and_padding_char = state[9];		
		 
always@(posedge clk_fsm)
begin
	case(state)
	IDLE				: if(sending_clk_sync==1'b1)
						  begin
						  	if(fifo_empty_xcvr==1'b0)
							 begin
								state<=READ_FIFO_SET_XCVR;
							 end		
							 else
							 begin
								state<=READ_FIFO_SET_UART;
							 end 
						  end		
						  
					 
	READ_FIFO_SET_XCVR:begin
								state<=READ_FIFO_XCVR;
	                   end	
	READ_FIFO_XCVR		:begin
								state<=clock_data_out;//state<=pre_clock_data_out;
						 end
						 
    pre_clock_data_out : state <= clock_data_out;
    clock_data_out : state <= IDLE;
						

	READ_FIFO_SET_UART:begin
							state<=READ_FIFO_UART;
	                   end	
	READ_FIFO_UART	  :begin
							state<=clock_control_out;	//state<=pre_clock_control_out;	
					   end	

    pre_clock_control_out : state <= clock_control_out;
    clock_control_out : state <= IDLE;
						   
	endcase
	
	
end

//FSMD
always@(posedge clk_fsm)	 
begin
    if (reset_control_and_padding_char)
	begin
	      is_control_char <= 0;
	end else
	begin
			if (fifo_read_uart_raw)
			begin
				is_control_char <= raw_is_control_char;
			end	
	end
end

generate
         genvar current_channel;
		 for (current_channel = 0; current_channel < numchannels; current_channel = current_channel + 1)
		 begin : per_channel_assignments	
		        assign fifo_read_uart[current_channel] = fifo_read_uart_raw & (!fifo_empty_uart[current_channel]);
				assign raw_is_padding_char[current_channel] = fifo_empty_uart[current_channel];
				
				always@(posedge clk_fsm)	 
				begin
				     if (reset_control_and_padding_char)
					 begin
						  is_padding_char[current_channel] <= 0;
					 end else 
					 begin
						if (fifo_read_uart_raw)
						begin
							is_padding_char[current_channel] <= raw_is_control_char & raw_is_padding_char[current_channel];
						end	
					 end
				end	
				
				always@(posedge clk_fsm)	 
				begin
					if (enable_data_out)
					begin
						data_8b10[current_channel]  <= is_control_char ? (is_padding_char[current_channel] ? padding_char[current_channel] : data_fifo_uart[current_channel]) : data_fifo_xcvr[current_channel];
					end	
				end	
		end
endgenerate

endmodule
`default_nettype wire