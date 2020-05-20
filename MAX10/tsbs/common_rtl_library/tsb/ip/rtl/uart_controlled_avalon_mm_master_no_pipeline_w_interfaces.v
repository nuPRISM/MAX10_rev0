
`include "interface_defs.v"
`include "uart_regfile_interface_defs.v"

module uart_controlled_avalon_mm_master_no_pipeline_w_interfaces
#(
	parameter  [15:0] DATA_NUMBYTES        =   4,
    parameter  [15:0] DESC_NUMBYTES        =  16,
    parameter  [15:0] NUM_OF_CONTROL_REGS  =  32,
    parameter  [15:0] ADDRESS_WIDTH_IN_BITS =  16,
    parameter   [7:0]    USE_AUTO_RESET           = 1'b1,
    parameter            CLOCK_SPEED_IN_HZ     = 50000000,
    parameter            UART_BAUD_RATE_IN_HZ   = 115200,
    parameter   [0:0]    DISABLE_ERROR_MONITORING = 1'b1
)
(
 uart_wishbone_bridge_interface uart_regfile_interface_pins,
 interface avalon_mm_slave_interface_pins
);

wishbone_interface #(
                     .num_address_bits(ADDRESS_WIDTH_IN_BITS), 
                     .num_data_bits(DATA_NUMBYTES*8)
					)
                    wishbone_master_interface_pins();

uart_controlled_wishbone_master_w_interfaces
#(
 .DATA_NUMBYTES              ( DATA_NUMBYTES                    ),
 .DESC_NUMBYTES              ( DESC_NUMBYTES                    ),
 .NUM_OF_CONTROL_REGS              ( NUM_OF_CONTROL_REGS              ),
 .ADDRESS_WIDTH_IN_BITS            (ADDRESS_WIDTH_IN_BITS),		  
 .USE_AUTO_RESET                   ( USE_AUTO_RESET                   ),
 .CLOCK_SPEED_IN_HZ                ( CLOCK_SPEED_IN_HZ                ),
 .UART_BAUD_RATE_IN_HZ             ( UART_BAUD_RATE_IN_HZ             ),
 .DISABLE_ERROR_MONITORING         (DISABLE_ERROR_MONITORING          ) 
 )
uart_regfile_internal
(	
 .uart_regfile_interface_pins(uart_regfile_interface_pins),
 .wishbone_master_interface_pins(wishbone_master_interface_pins)
);

convert_wishbone_master_to_avalon_mm_interface_w_clk_for_qsys_no_pipeline
convert_wishbone_master_to_avalon_mm_interface_inst
(
 .wishbone_master_interface_pins(wishbone_master_interface_pins),
 .avalon_mm_slave_interface_pins(avalon_mm_slave_interface_pins) 
);
 
endmodule
