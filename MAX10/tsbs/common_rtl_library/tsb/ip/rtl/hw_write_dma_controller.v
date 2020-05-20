	
	`default_nettype none
	
	module hw_write_dma_controller #(
	
	parameter idle              = 16'b0000_0000_0000_0000,
	parameter initiate_transfer = 16'b0000_0000_0001_0001,
	parameter wait_for_done     = 16'b0000_0000_0000_0010,
	parameter assert_finish     = 16'b0000_0000_0010_0011
	
    )	
	(
	 output  wire         hw_triggered_dma_write_master_control_fixed_location,          
	 output  wire [31:0]  hw_triggered_dma_write_master_control_write_base,              
	 output  wire [31:0]  hw_triggered_dma_write_master_control_write_length,            
	 output  wire         hw_triggered_dma_write_master_control_go,                      
	 input   wire         hw_triggered_dma_write_master_control_done,                    
	 output  wire         hw_triggered_dma_write_master_user_write_buffer,               
	 output  wire [127:0] hw_triggered_dma_write_master_user_buffer_input_data,          
	 input   wire         hw_triggered_dma_write_master_user_buffer_full,                
		
	input  wire         user_dma_write_master_control_fixed_location,      
	input  wire [31:0]  user_dma_write_master_control_write_base,          
	input  wire [31:0]  user_dma_write_master_control_write_length,        
		
	input  wire         user_dma_write_master_user_write_buffer,          
	input  wire [127:0] user_dma_write_master_user_buffer_input_data,     
	output wire         user_dma_write_master_user_buffer_full,           
		
		
    input	           async_start,
	output logic       finish,
 	output reg [15:0] state = idle,
	input wire reset_n,
    input wire clk				
	); 
			
	assign hw_triggered_dma_write_master_control_fixed_location = user_dma_write_master_control_fixed_location;  
	assign hw_triggered_dma_write_master_control_write_base     = user_dma_write_master_control_write_base;  
	assign hw_triggered_dma_write_master_control_write_length   = user_dma_write_master_control_write_length;
	
	assign hw_triggered_dma_read_master_user_read_buffer        = user_read_master_user_read_buffer;
	assign user_read_master_user_buffer_output_data             = hw_triggered_dma_read_master_user_buffer_output_data;  
	assign user_read_master_user_data_available                 = hw_triggered_dma_read_master_user_data_available;
	
	
	assign hw_triggered_dma_read_master_control_go = state[4];
	assign finish                                  = state[5];
	
	wire sync_start;
	
    async_trap_and_reset_gen_1_pulse_robust\
    #(.synchronizer_depth(synchronizer_depth))
    make_start_signal
    (
    .async_sig(!async_start), 
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