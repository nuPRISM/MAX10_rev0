
`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module monitor_slite_parity
#(
parameter USE_EVEN_PARITY_DEFAULT = 0,
parameter num_samples_per_frame = 8,
parameter num_bits_per_sample = 16,
parameter parity_width = 2*num_samples_per_frame,
parameter num_bits_in_data_frame = num_samples_per_frame*num_bits_per_sample,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"SLErrMon"},
parameter UART_REGFILE_TYPE = uart_regfile_types::SLITE_ERROR_MONITOR_REGFILE,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID = 1,
parameter synchronizer_depth = 3
)
(

    input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
	
	input data_clk,
    input [num_bits_in_data_frame-1:0] data_frame_in,
	input indata_valid,

	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
    output     [7:0] NUM_UARTS_HERE,
	
	output logic [parity_width-1:0] received_parity_out           ,
    output logic [parity_width-1:0] calculated_parity_out         ,
    output logic [parity_width-1:0] calculated_parity_difference  ,

	output logic [parity_width-1:0] synced_to_uart_domain_received_parity_out           ,
    output logic [parity_width-1:0] synced_to_uart_domain_calculated_parity_out         ,
    output logic [parity_width-1:0] synced_to_uart_domain_calculated_parity_difference  
	
);

logic main_uart_tx, error_monitor_txd;

assign uart_tx = error_monitor_txd  & main_uart_tx;

logic [parity_width-1:0] received_parity_out_raw           ;
logic [parity_width-1:0] calculated_parity_out_raw         ;
logic [parity_width-1:0] calculated_parity_difference_raw  ;
logic [parity_width-1:0] inject_error_bus_raw;
logic [parity_width-1:0] inject_error_bus;
logic use_even_parity_raw;
logic use_even_parity;
logic delayed_indata_valid;

logic [7:0] NUM_UARTS_IN_BEDROCK_MONITOR;
assign NUM_UARTS_HERE = NUM_UARTS_IN_BEDROCK_MONITOR+1;

logic mcp_synch_error_signal_bus_aready, mcp_synch_error_signal_bus_bvalid, mcp_synch_to_data_clk_aready, mcp_synch_to_data_clk_bvalid;

my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(3*parity_width),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_error_signal_bus
(
   .in_clk(data_clk),
   .in_valid(1'b1),
   .in_data({received_parity_out,calculated_parity_out,calculated_parity_difference}),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_synch_error_signal_bus_bvalid),
   .out_data({synced_to_uart_domain_received_parity_out,synced_to_uart_domain_calculated_parity_out,synced_to_uart_domain_calculated_parity_difference})
 );



//mcp_blk 
//#(
//.width(3*parity_width)
//) 
//mcp_synch_error_signal_bus
//(
///* output  logic */                 .aready  (mcp_synch_error_signal_bus_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({received_parity_out,calculated_parity_out,calculated_parity_difference}),
///* input  logic */                  .asend   (1'b1 /*trig_ts_ADC_energy_long[n][0] | trig_ts_ADC_energy_short[n][0]*/),
///* input  logic */                  .aclk    (data_clk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({synced_to_uart_domain_received_parity_out,synced_to_uart_domain_calculated_parity_out,synced_to_uart_domain_calculated_parity_difference}),
///* output  logic */                 .bvalid  (mcp_synch_error_signal_bus_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1)
//);


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(parity_width+1),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth) 
)
mcp_synch_to_data_clk
(
   .in_clk(UART_REGFILE_CLK),
   .in_valid(1'b1),
   .in_data({use_even_parity_raw,inject_error_bus_raw}),
   .out_clk(data_clk),
   .out_valid(mcp_synch_to_data_clk_bvalid),
   .out_data({use_even_parity,inject_error_bus})
 );


//mcp_blk 
//#(
//.width(parity_width+1)
//) 
//mcp_synch_to_data_clk
//(
///* output  logic */                 .aready  (mcp_synch_to_data_clk_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({use_even_parity_raw,inject_error_bus_raw}),
///* input  logic */                  .asend   (1'b1 /*trig_ts_ADC_energy_long[n][0] | trig_ts_ADC_energy_short[n][0]*/),
///* input  logic */                  .aclk    (UART_REGFILE_CLK),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({use_even_parity,inject_error_bus}),
///* output  logic */                 .bvalid  (mcp_synch_to_data_clk_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (data_clk),
///* input  logic */                  .brst_n  (1'b1)
//);


extract_and_compare_parity_bits_from_frame
#(
.num_samples_per_frame(num_samples_per_frame),
.num_bits_per_sample(num_bits_per_sample)
)
rx_in_extract_and_compare_parity_bits_from_frame_inst
(
.data_frame_in(data_frame_in),
.data_frame_out(),
.received_parity_out         (received_parity_out_raw         ),
.calculated_parity_out       (calculated_parity_out_raw       ),
.calculated_parity_difference(calculated_parity_difference_raw),
.use_even_parity(use_even_parity),
.parity_error()
);


always_ff @(posedge data_clk)
begin
      received_parity_out             <= received_parity_out_raw           ;
      calculated_parity_out           <= calculated_parity_out_raw         ;
      calculated_parity_difference    <= calculated_parity_difference_raw | inject_error_bus;
	  delayed_indata_valid            <= indata_valid ;	 
end

monitor_errors_lt_and_st_w_uart
#(
.NUM_ERROR_CHANNELS(parity_width),
.DEFAULT_MONITORED_CHANNELS({parity_width{1'b1}}),
.OMIT_CONTROL_REG_DESCRIPTIONS(OMIT_CONTROL_REG_DESCRIPTIONS),
.OMIT_STATUS_REG_DESCRIPTIONS(OMIT_STATUS_REG_DESCRIPTIONS),
.UART_CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
.REGFILE_BAUD_RATE(REGFILE_BAUD_RATE),
.prefix_uart_name(prefix_uart_name),
.ASSUME_ALL_INPUT_DATA_IS_VALID(ASSUME_ALL_INPUT_DATA_IS_VALID)
)
monitor_errors_lt_and_st_w_uart_inst
(
	.UART_REGFILE_CLK,
	.RESET_FOR_UART_REGFILE_CLK,
	
	.data_clk,
	.error_signal_bus(calculated_parity_difference),
	.indata_valid(delayed_indata_valid),

	.uart_tx(error_monitor_txd),
	.uart_rx(uart_rx),
	
    .UART_IS_SECONDARY_UART(1),
    .UART_NUM_SECONDARY_UARTS(0),
    .UART_ADDRESS_OF_THIS_UART(UART_ADDRESS_OF_THIS_UART+1),
	.NUM_UARTS_HERE(NUM_UARTS_IN_BEDROCK_MONITOR)

	
);

							  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 3;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 5;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0 ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			
			/* dummy wishbone interface definitions */		
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			status_wishbone_interface_pins();
						
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			control_wishbone_interface_pins();
			
			
			
			uart_regfile_interface 
			#(                                                                                                     
			.DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       ),
			.DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       ),
			.NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 ),
			.NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  ),
			.INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    ),
			.CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            ),
			.USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      ),
			.CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   ),
			.UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                ),
			.ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   ),
			.ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    ),
			.DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  )
				
			)
			uart_regfile_interface_pins();

	        assign uart_regfile_interface_pins.display_name         = uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign main_uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.reset     = 1'b0;
			assign uart_regfile_interface_pins.user_type = UART_REGFILE_TYPE;	
			
			uart_controlled_register_file_w_interfaces
			#(
			 .DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                      ),
			 .DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                      ),
			 .NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                ),
			 .NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                 ),
			 .INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT   ),
			 .CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL           ),
			 .USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                     ),
			 .CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                  ),
			 .UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ               ),
			 .ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE  ),
			 .ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE   ),
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS)
			)		
			control_and_status_regfile
			(
			  .uart_regfile_interface_pins(uart_regfile_interface_pins),
			  .status_wishbone_interface_pins (status_wishbone_interface_pins ), 
			  .control_wishbone_interface_pins(control_wishbone_interface_pins)			  
			);
			
	
			genvar sreg_count;
			genvar creg_count;
			
			generate
					for ( sreg_count=0; sreg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS; sreg_count++)
					begin : clear_status_descs
						  assign uart_regfile_interface_pins.status_omit_desc[sreg_count] = OMIT_STATUS_REG_DESCRIPTIONS;
					end
					
						
					for (creg_count=0; creg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS; creg_count++)
					begin : clear_control_descs
						  assign uart_regfile_interface_pins.control_omit_desc[creg_count] = OMIT_CONTROL_REG_DESCRIPTIONS;
					end
			endgenerate
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  32'h12345678;
    assign uart_regfile_interface_pins.control_desc[0]               = "ctrlAlive";
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		

    assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  0;
    assign uart_regfile_interface_pins.control_desc[1]               = "InjectDiffErrors";
    assign inject_error_bus_raw     = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = parity_width;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  USE_EVEN_PARITY_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[2]               = "UseEvenParity";
    assign use_even_parity_raw     = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 1;	
	
	assign uart_regfile_interface_pins.status[0] = 32'h12345678;
	assign uart_regfile_interface_pins.status_desc[0]    ="StatusAlive";	

	assign uart_regfile_interface_pins.status[1] = synced_to_uart_domain_received_parity_out;
	assign uart_regfile_interface_pins.status_desc[1]    ="RecvdParituy";
	
	assign uart_regfile_interface_pins.status[2] = synced_to_uart_domain_calculated_parity_out;
	assign uart_regfile_interface_pins.status_desc[2]    ="CalcParity";
	
	assign uart_regfile_interface_pins.status[3] = synced_to_uart_domain_calculated_parity_difference;
	assign uart_regfile_interface_pins.status_desc[3]    ="ParityDifference";	
	
	assign uart_regfile_interface_pins.status[4] = {mcp_synch_error_signal_bus_aready, mcp_synch_error_signal_bus_bvalid, mcp_synch_to_data_clk_aready, mcp_synch_to_data_clk_bvalid};
	assign uart_regfile_interface_pins.status_desc[4]    ="mcp_blk_status";
			
 endmodule
 
`default_nettype wire