`timescale 1ns / 1ps

module TDM_access_to_one_state_machine(
 output_parameters,
 start_target_state_machine,
 target_state_machine_finished, 
 sm_clk, 
 start, 
 finish,
 input_parameters,
 received_data,
 reset, 
 enable, 
 in_received_data,
 state,
 start_status);
    
	 parameter numbits_state_machine_parameters = 32;
	 parameter numclients = 4;
	 parameter actual_numclients = 4;
	 parameter log2numclients = 2;
	 parameter state_machine_received_data_width = 8;
	 
	 output reg [(numbits_state_machine_parameters-1):0] output_parameters;
    input [(actual_numclients*numbits_state_machine_parameters-1):0] input_parameters;
	 output  [(state_machine_received_data_width*actual_numclients-1):0] received_data;
	 input [actual_numclients-1:0] start;
	 output [actual_numclients-1:0] finish;
	 output [actual_numclients-1:0] start_status;
	     
	 output start_target_state_machine;	 
	 input target_state_machine_finished;
    input sm_clk;
    input reset;
	 
	 input enable;
	 
	 input [state_machine_received_data_width-1:0] in_received_data; 

    wire [actual_numclients-1:0] reset_SPI_start;
	 wire [actual_numclients-1:0] SPI_start; 
    reg [log2numclients:0] current_processed_input_code; //note 1 bit extra to avoid overflow
    wire [(numbits_state_machine_parameters-1):0] output_parameters_next;
    wire output_parameters_clock;
	 				 
  
	  parameterized_mux #(
	  .width(numbits_state_machine_parameters),
	  .number_of_inputs(actual_numclients),
	  .number_of_select_lines(log2numclients)
  	  )
	  output_parameters_mux(
	  .outdata(output_parameters_next), 
	  .sel(current_processed_input_code[log2numclients-1:0]), 
	  .indata(input_parameters));
     
	  always @(posedge sm_clk)
	  begin
	       if (output_parameters_clock)
			 begin
	             output_parameters <= output_parameters_next;
			 end
	  end
	  
	 wire reset_SPI_start_now; 
	 wire give_finish_back_to_client_now;
	 reg [state_machine_received_data_width-1:0] received_data_reg[actual_numclients-1:0];
	 assign start_status = SPI_start;

	genvar index;
   generate
       for (index=0; index < actual_numclients; index=index+1) 
       begin : gen
		       async_trap_and_reset sync_SPI_start(
				 .async_sig(start[index]), 
				 .outclk(sm_clk), 
				 .out_sync_sig(SPI_start[index]),
				 .auto_reset(1'h0), 
				 .reset(~reset_SPI_start[index]));	
              
				  widereg #(.width(state_machine_received_data_width))
				  recv_data_reg(.indata(in_received_data),
				  .outdata(received_data[((index+1)*state_machine_received_data_width-1)-:state_machine_received_data_width]), 
				  .inclk(finish[index]));
				  
              assign reset_SPI_start[index] = reset_SPI_start_now && (current_processed_input_code == index);				 
				  assign finish[index] = give_finish_back_to_client_now && (current_processed_input_code == index);
				 
       end
   endgenerate
	
 
    	                             ////876543210_987654_3210  
	 parameter idle                         = 16'b0000000_0000;
	 parameter reset_input_counter          = 16'b0100000_0001;
	 parameter wait_reset_input_counter     = 16'b0000000_0010;
 	 parameter check_start  			       = 16'b0000000_0011;
	 parameter clock_output_parameters      = 16'b1000000_0100;
	 parameter wait_output_parameters       = 16'b0000000_1100;
	 parameter start_read  				       = 16'b0000010_0101;
	 parameter wait_read                    = 16'b0000000_0110;
	 parameter reset_start_capture          = 16'b0000100_0111;
	 parameter finish_read                  = 16'b0001000_1000;
	 parameter wait_finish_read             = 16'b0000000_1001;
	 parameter inc_input_counter            = 16'b0010000_1010;
	 parameter wait_for_input_counter       = 16'b0000000_1011;
		 
    output reg [15:0] state = idle;
	
	 assign start_target_state_machine = state[5];
	 assign reset_SPI_start_now = state[6];
	 assign give_finish_back_to_client_now = state[7];
	 wire inc_input_counter_now = state[8];
	 wire reset_input_counter_now = state[9];
	 
	 assign output_parameters_clock = state[10];
		 
	 
	 
	 always @(posedge sm_clk or negedge reset)
	 begin
	  if (!reset)
	  begin
	  		state <= idle;
	  end else
	  begin
	  		case (state) 
			idle : 	state <= reset_input_counter;
			
         reset_input_counter : state <= wait_reset_input_counter;		
         wait_reset_input_counter :  state <= check_start;
			check_start : if (SPI_start[current_processed_input_code[log2numclients-1:0]] & enable)
									state <= clock_output_parameters;
								else
									state <= inc_input_counter;
			clock_output_parameters :  state <= wait_output_parameters;
			wait_output_parameters :  state <= start_read;
			start_read:	state <= wait_read;
			wait_read : if (target_state_machine_finished)
									state <= reset_start_capture;
							  else
							      state <= wait_read;
			reset_start_capture	: state <= finish_read;		
			finish_read : state <= wait_finish_read;
		    wait_finish_read : state <= inc_input_counter;
			inc_input_counter : state <= wait_for_input_counter;
			wait_for_input_counter : if (current_processed_input_code == actual_numclients) 
			                                     state <= reset_input_counter;
											 else
											     state <= check_start;
			default: state <= idle;

			endcase
	  end
	end
	
		
	wire [log2numclients:0] current_processed_input_code_next;
	
	assign current_processed_input_code_next = 
	reset_input_counter_now ? 0 : 
	inc_input_counter_now ? current_processed_input_code + 1 :
   current_processed_input_code;
	
	always @ (posedge sm_clk)
	begin
				current_processed_input_code <= current_processed_input_code_next;
	end


endmodule
