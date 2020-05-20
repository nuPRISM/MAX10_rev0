`ifndef  UART_REGFILE_INTERFACE_DEFS_V
`define  UART_REGFILE_INTERFACE_DEFS_V
interface uart_regfile_interface;
				parameter  [15:0] DATA_NUMBYTES        =   4;
				parameter  [15:0] DATA_WIDTH           =   8*DATA_NUMBYTES;
				parameter  [15:0] DESC_NUMBYTES        =  16;
				parameter  [15:0] DESC_WIDTH           =   8*DESC_NUMBYTES;
				parameter  [15:0] NUM_OF_CONTROL_REGS  =  32;
				parameter  [15:0] NUM_OF_STATUS_REGS   =  32;
				parameter  [15:0]            INIT_ALL_CONTROL_REGS_TO_DEFAULT  =  0;
 			    parameter  [DATA_WIDTH-1:0]  CONTROL_REGS_DEFAULT_VAL   =  0;
				parameter  [7:0]             USE_AUTO_RESET                         = 1'b1;
                parameter                   CLOCK_SPEED_IN_HZ = 50000000;
                parameter                   UART_BAUD_RATE_IN_HZ = 115200;
				parameter  [7:0]                 ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0;
				parameter  [7:0]                 ENABLE_STATUS_WISHBONE_INTERFACE = 1'b0;
                parameter   [7:0]                DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS = 1'b0;
				parameter [0:0] UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK = 0;
								parameter [0:0] USE_LEGACY_UART_PARSER = 0;

				//clk
				wire clk;
				wire data_clk;
				
				//reset
				wire reset;
				
				
				//Control Registers
				wire [DATA_WIDTH-1:0] control_regs_default_vals[NUM_OF_CONTROL_REGS-1:0];
				wire [DATA_WIDTH-1:0] control                  [NUM_OF_CONTROL_REGS-1:0];
				wire [DATA_WIDTH-1:0] control_regs_bitwidth    [NUM_OF_CONTROL_REGS-1:0];				
				wire [DESC_WIDTH-1:0] control_desc             [NUM_OF_CONTROL_REGS-1:0];				
				wire                  control_short_to_default [NUM_OF_CONTROL_REGS-1:0];
                wire                  control_omit_desc        [NUM_OF_CONTROL_REGS-1:0];
				
				//Status Registers
				wire [DATA_WIDTH-1:0] status                   [NUM_OF_STATUS_REGS-1:0];
				wire [DESC_WIDTH-1:0] status_desc              [NUM_OF_STATUS_REGS-1:0];
				wire                  status_omit              [NUM_OF_STATUS_REGS-1:0];
                wire                  status_omit_desc         [NUM_OF_STATUS_REGS-1:0];
				
				 //User TYPE
				  wire  [7:0]                           user_type;
				  wire   [127:0] display_name;
				  
				 //Adressing
				 wire [7:0] num_secondary_uarts ;
				 wire [7:0] address_of_this_uart;
				 wire       is_secondary_uart   ;
				 
				 //Watchdog
				 wire [31:0] watchdog_limit            ;
				 wire [7:0]  watchdog_reset_pulse_width;				     
				 wire enable_watchdog;
				 wire reset_watchdog;					  					  
				 wire watchdog_reset_pulse; 
				 wire [31:0] current_watchdog_count;
				 wire [15:0] watchdog_event_count;
				 
				 //UART
				 wire  uart_active_high_async_reset;
				 wire  rxd;
				 wire  txd;
				
				wire ignore_crc_value_for_debugging;
				//Transaction Error Monitoring
				wire rd_error;
				wire async_reset;
				wire wr_error;
				wire transaction_error;								
				
				//State Machine Monitoring
				wire [31:0] main_sm;
				wire [31:0] tx_sm;
				wire [31:0] command_count;
				
endinterface

interface uart_wishbone_bridge_interface;
				parameter  [15:0] DATA_NUMBYTES        =   4;
				parameter  [15:0] DATA_WIDTH           =   8*DATA_NUMBYTES;
				parameter  [15:0] DESC_NUMBYTES        =  16;
				parameter  [15:0] DESC_WIDTH           =   8*DESC_NUMBYTES;
				parameter  [15:0] NUM_OF_CONTROL_REGS  =  32;
				
				//clk
				wire clk;
				
				//reset
				wire reset;
				
				
				//Control Registers
				wire [DESC_WIDTH-1:0] control_desc             [NUM_OF_CONTROL_REGS-1:0];				
				wire                  control_omit_desc        [NUM_OF_CONTROL_REGS-1:0];
				
				
				//User TYPE
				wire  [7:0]      user_type;
				wire  [127:0] display_name;
				  
				 //Adressing
				 wire [7:0] num_secondary_uarts ;
				 wire [7:0] address_of_this_uart;
				 wire       is_secondary_uart   ;
				 
				 //Watchdog
				 wire [31:0] watchdog_limit            ;
				 wire [7:0]  watchdog_reset_pulse_width;				     
				 wire enable_watchdog;
				 wire reset_watchdog;					  					  
				 wire watchdog_reset_pulse; 
				 wire [31:0] current_watchdog_count;
				 wire [15:0] watchdog_event_count;
				 
				 //UART
				 wire  uart_active_high_async_reset;
				 wire  rxd;
				 wire  txd;
				
				//Transaction Error Monitoring
				wire rd_error;
				wire async_reset;
				wire wr_error;
				wire transaction_error;								
				
				//State Machine Monitoring
				wire [3:0] main_sm;
				wire [2:0] tx_sm;
				wire [31:0] command_count;
				
endinterface

`endif