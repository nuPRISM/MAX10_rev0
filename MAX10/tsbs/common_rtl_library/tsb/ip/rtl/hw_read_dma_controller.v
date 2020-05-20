	
	`default_nettype none
	
	module hw_read_dma_controller #(
	parameter DATAWIDTH = 128,
	parameter ADDRESSWIDTH = 32,
	parameter synchronizer_depth = 3,

	parameter idle              = 16'b0000_0000_0000_0000,
	parameter initiate_transfer = 16'b0000_0000_0001_0001,
	parameter wait_for_done     = 16'b0000_0000_0000_0010,
	parameter assert_finish     = 16'b0000_0000_0010_0011
	
    )	
	(
	    output  logic         hw_triggered_dma_read_master_control_fixed_location,               //                  hw_triggered_dma_read_master_control.fixed_location
		output  logic [ADDRESSWIDTH-1:0] hw_triggered_dma_read_master_control_read_base,                    //                                                      .read_base
		output  logic [ADDRESSWIDTH-1:0] hw_triggered_dma_read_master_control_read_length,                  //                                                      .read_length
		output  logic         hw_triggered_dma_read_master_control_go,                           //                                                      .go
		input   logic         hw_triggered_dma_read_master_control_done,                         //                                                      .done
		input   logic         hw_triggered_dma_read_master_control_early_done,                   //                                                      .early_done
		output  logic         hw_triggered_dma_read_master_user_read_buffer,                     //                     hw_triggered_dma_read_master_user.read_buffer
		input   logic [DATAWIDTH-1:0] hw_triggered_dma_read_master_user_buffer_output_data,              //                                                      .buffer_output_data
		input   logic         hw_triggered_dma_read_master_user_data_available,
		
		input logic [ADDRESSWIDTH-1:0] user_logic_read_master_control_read_base,  
		input logic [ADDRESSWIDTH-1:0] user_logic_read_master_control_read_length,
		input logic         user_logic_read_master_control_fixed_location,
		
		input  logic         user_read_master_user_read_buffer,         
		output   logic [DATAWIDTH-1:0] user_read_master_user_buffer_output_data,  
		output   logic         user_read_master_user_data_available,
		
		
        input	           async_start,
		output logic       finish,
 	    output reg [15:0] state = idle,
		input wire reset_n,
        input wire clk				
	); 
			
	assign hw_triggered_dma_read_master_control_fixed_location =  user_logic_read_master_control_fixed_location;
	assign hw_triggered_dma_read_master_control_read_base      =   user_logic_read_master_control_read_base  ;
	assign hw_triggered_dma_read_master_control_read_length    =   user_logic_read_master_control_read_length;
	
	assign hw_triggered_dma_read_master_user_read_buffer = user_read_master_user_read_buffer;
	assign user_read_master_user_buffer_output_data      = hw_triggered_dma_read_master_user_buffer_output_data;  
	assign user_read_master_user_data_available          = hw_triggered_dma_read_master_user_data_available;
	
	
	assign hw_triggered_dma_read_master_control_go = state[4];
	assign finish                                  = state[5];
	
	wire sync_start;
	
    async_trap_and_reset_gen_1_pulse_robust 
    #(.synchronizer_depth(synchronizer_depth))
    make_start_signal
    (
    .async_sig(async_start), 
    .outclk(clk), 
    .out_sync_sig(sync_start), 
    .auto_reset(1'b1), 
    .reset(1'b1)
    );
	
   always_ff @ (posedge clk or negedge reset_n)
   begin
        if (!reset_n)
		begin
		     state <= idle;
		end else
		begin
  				case (state)
					idle: begin
								 if (sync_start) 
								 begin
									   state <=  initiate_transfer;					 
								 end
						   end
						   
					initiate_transfer: state <= wait_for_done;
					wait_for_done    : if (hw_triggered_dma_read_master_control_done)
									   begin
											 state <= assert_finish;
									   end
					assert_finish  : state <= idle;			   
					endcase
		end
   end
	
	
endmodule
	
`default_nettype wire