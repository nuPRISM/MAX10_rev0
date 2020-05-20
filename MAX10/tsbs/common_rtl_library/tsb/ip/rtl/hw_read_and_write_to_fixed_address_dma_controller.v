`default_nettype none
module hw_read_and_write_to_fixed_address_dma_controller #(
	parameter DATAWIDTH = 32,
	parameter BYTEENABLEWIDTH = DATAWIDTH/8,
	parameter ADDRESSWIDTH = 32
)
	(
	    output  logic         hw_triggered_dma_read_master_control_fixed_location,               //                  hw_triggered_dma_read_master_control.fixed_location
		output  logic [ADDRESSWIDTH-1:0]   hw_triggered_dma_read_master_control_read_base,                    //                                                      .read_base
		output  logic [ADDRESSWIDTH-1:0]   hw_triggered_dma_read_master_control_read_length,                  //                                                      .read_length
		output  logic         hw_triggered_dma_read_master_control_go,                           //                                                      .go
		input   logic         hw_triggered_dma_read_master_control_done,                         //                                                      .done
		input   logic         hw_triggered_dma_read_master_control_early_done,                   //                                                      .early_done
		output  logic         hw_triggered_dma_read_master_user_read_buffer,                     //                     hw_triggered_dma_read_master_user.read_buffer
		input   logic  [DATAWIDTH-1:0]  hw_triggered_dma_read_master_user_buffer_output_data,              //                                                      .buffer_output_data
		input   logic         hw_triggered_dma_read_master_user_data_available,
		
		input  logic [ADDRESSWIDTH-1:0]   user_logic_read_master_control_read_base,  
		input  logic [ADDRESSWIDTH-1:0]   user_logic_read_master_control_read_length,
		input  logic         user_logic_read_master_control_fixed_location,
		input  wire [ADDRESSWIDTH-1:0] user_logic_the_fixed_address_to_write_to,		

	  	
		// master inputs and outputs
	    input       master_waitrequest,
	    output wire [ADDRESSWIDTH-1:0] master_address,
	    output wire master_write,
	    output wire [BYTEENABLEWIDTH-1:0] master_byteenable,
	    output wire [DATAWIDTH-1:0] master_writedata,
	    

			
        input	           async_start,
		output logic       finish, 	    
		input wire reset_n,
        input wire clk,
        
        //debug ports
        output wire [15:0] read_dma_state
        				
	); 
	
	logic         user_read_master_user_read_buffer;         
    logic [DATAWIDTH-1:0]  user_read_master_user_buffer_output_data;
	logic         user_read_master_user_data_available;
	
	hw_read_dma_controller #(
	.DATAWIDTH(DATAWIDTH),
	.ADDRESSWIDTH(ADDRESSWIDTH)
	)
	hw_read_dma_controller_inst
	(
	  .*,
	  .state(read_dma_state)		
	);
	
	assign master_address    = user_logic_the_fixed_address_to_write_to;
    assign master_byteenable = -1; // all ones, always performing word size accesses
	assign master_write      = user_read_master_user_data_available;
	assign master_writedata  = user_read_master_user_buffer_output_data;
	assign user_read_master_user_read_buffer = ((!master_waitrequest) & user_read_master_user_data_available);
	
endmodule
`default_nettype wire
