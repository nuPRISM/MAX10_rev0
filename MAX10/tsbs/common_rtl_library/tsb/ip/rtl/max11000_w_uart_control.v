`default_nettype none
module max11000_w_uart_control
#(
parameter device_family = "Cylcone III", 
parameter num_adcs = 1,
parameter counter_numbits = 32,
parameter adc_numbits = 24,
parameter current_FMC = 1,

//UART definitions
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter FSM_CLOCK_FREQ = 50000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_max11000"},
parameter UART_REGFILE_TYPE = uart_regfile_types::MAX11000_UART_REGFILE,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID = 1,
parameter DEFAULT_TRIGGER_FREQUENCY_DIV_WORD = 249999,
parameter DEFAULT_ADC_ACQ_ENABLE = 1,
parameter DEFAULT_INTERGRATION_TIME_COUNT = 500,
parameter DEFAULT_RESET_TIME_COUNT = 500,
parameter DEFAULT_TRIGGER_SETTINGS = 1,
parameter DEFAULT_PRE_INTEGRATION_RESET_TIME_COUNT = 500,
parameter DEFAULT_HOLD_TIME_COUNT = 500,
parameter synchronizer_depth = 3
)
(
			//system clk
			input   clk_50M,
			output  adc_clk,
			output  [adc_numbits-1:0] adc_data[num_adcs],
			
			input logic external_trigger,
			 ltc2380_interface max11000_interface_pins,
			
			input  UART_REGFILE_CLK,
			input  RESET_FOR_UART_REGFILE_CLK,
			
			output uart_tx,
			input  uart_rx,
			
			input wire       UART_IS_SECONDARY_UART,
			input wire [7:0] UART_NUM_SECONDARY_UARTS,
			input wire [7:0] UART_ADDRESS_OF_THIS_UART,
			output     [7:0] NUM_UARTS_HERE		
);

assign NUM_UARTS_HERE = 1;

logic clk         ;
logic start       ;
logic enable      ;
logic reset       ;
logic finish;
logic [counter_numbits-1:0]  integration_time;
logic [counter_numbits-1:0]  pre_integration_reset_wait_time;
logic [31:0]  trigger_freq_div;
logic [counter_numbits-1:0]  reset_time;
logic [counter_numbits-1:0]  hold_time;

reg   [counter_numbits-1:0]   adc_conversion_counter = 0;
logic [counter_numbits-1:0]  aux_counter;
logic [adc_numbits -1:0] read_data[num_adcs];
logic [adc_numbits -1:0] read_data_raw[num_adcs];
logic [15:0] state;
logic [15:0] read_max11000_state;
logic in_the_middle_of_acquiring;
logic do_reset_before_integration;
logic keep_reset_active_after_integration;

(* keep = 1, preserve = 1 *) logic external_trigger_pulse;
(* keep = 1, preserve = 1 *) logic enable_external_trigger;
(* keep = 1, preserve = 1 *) logic emulate_external_trigger;
(* keep = 1, preserve = 1 *) logic auto_start;
(* keep = 1, preserve = 1 *) logic auto_start_trigger;
(* keep = 1, preserve = 1 *) logic start_from_regfile;
(* keep = 1, preserve = 1 *) logic enable_auto_trigger;

Divisor_frecuencia
#(.Bits_counter(32))
Generate_adc_state_machine_clock
 (	
  .CLOCK(clk_50M),
  .TIMER_OUT(clk),
  .Comparator(20)
 );

//assign clk = clk_50M;

read_ltc2380
#(
.num_adcs(1'b1),
.numbits_spi(adc_numbits),
.numbits_counter(8)
)
read_max11000_inst
(
.start,
.enable,
.reset,
.clk,
.finish,
.conv(),
.busy(1'b0),
.state(read_max11000_state),
.read_data(read_data_raw),
.spi_clk (max11000_interface_pins.spi_clk),
.spi_csn (max11000_interface_pins.spi_csn),
.spi_miso(max11000_interface_pins.spi_miso)
);

always @(posedge clk)
begin
      if (reset)
	  begin
	       adc_conversion_counter <= 0;
	  end else
	  begin	  
	        if (finish) 
			begin
			      adc_conversion_counter <= adc_conversion_counter + 1;
				  read_data <= read_data_raw;
			end
	  end
end 

assign in_the_middle_of_acquiring = !max11000_interface_pins.spi_csn;
assign adc_clk = in_the_middle_of_acquiring;


Divisor_frecuencia
#(.Bits_counter(32))
Generate_auto_start
 (	
  .CLOCK(clk),
  .TIMER_OUT(auto_start_trigger),
  .Comparator(trigger_freq_div)
 );

 /*
async_trap_and_reset_gen_1_pulse_robust 
async_trap_reset_auto_start_trigger
(
.async_sig(auto_start_trigger), 
.outclk(clk), 
.out_sync_sig(auto_start), 
.auto_reset(1'b1), 
.reset(1'b1)
);
*/

edge_detect 
edge_detect_auto_start_trigger
(
.in_signal(auto_start_trigger), 
.clk(clk), 
.edge_detect(auto_start)
);


async_trap_and_reset_gen_1_pulse_robust
#(.synchronizer_depth(synchronizer_depth)) 
async_trap_reset_external_trigger
(
.async_sig(((external_trigger | emulate_external_trigger) & enable_external_trigger)), 
.outclk(clk), 
.out_sync_sig(external_trigger_pulse), 
.auto_reset(1'b1), 
.reset(1'b1)
);
		
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_start_to_ivc102_read
(
  .indata ((auto_start && enable_auto_trigger) || start_from_regfile || external_trigger_pulse),
   .outdata(start),
   .clk    (clk)

);

		
always_ff @(posedge adc_clk)
begin
      adc_data <= read_data;
end		

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 3;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 4;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			localparam  UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                        = 1;
			
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
			.DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  ),
			.UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK      (UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                        )				
			)
			uart_regfile_interface_pins();

	        assign uart_regfile_interface_pins.display_name         = uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk                    = UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.data_clk               = clk;
			assign uart_regfile_interface_pins.reset                  = 1'b0;
			assign uart_regfile_interface_pins.user_type              = UART_REGFILE_TYPE;	
			
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
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS ),
			 .UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK      (UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                       )
			)		
			control_and_status_regfile
			(
			  .uart_regfile_interface_pins(uart_regfile_interface_pins        ),
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
				
	assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  DEFAULT_TRIGGER_FREQUENCY_DIV_WORD;
    assign uart_regfile_interface_pins.control_desc[0]               = "trigger_freq_div";
    assign trigger_freq_div                                          = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  DEFAULT_ADC_ACQ_ENABLE;
    assign uart_regfile_interface_pins.control_desc[1]               = "reset_enable_cfg";
    assign {    start_from_regfile,
	            do_reset_before_integration,
				keep_reset_active_after_integration,
				reset,
				enable}                      
				= uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 5;			  
 
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_TRIGGER_SETTINGS;
    assign uart_regfile_interface_pins.control_desc[2]               = "trigger";
    assign {emulate_external_trigger,enable_external_trigger,enable_auto_trigger}   = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 16;		


	assign uart_regfile_interface_pins.status[0]         = read_data[0];	
	assign uart_regfile_interface_pins.status_desc[0]    ="adc_data0";	

	assign uart_regfile_interface_pins.status[1]         = {max11000_interface_pins.busy,in_the_middle_of_acquiring,max11000_interface_pins.s1,max11000_interface_pins.s2,max11000_interface_pins.conv};
	assign uart_regfile_interface_pins.status_desc[1]    ="ctrl_sig_status";	
	
	assign uart_regfile_interface_pins.status[2]     = adc_conversion_counter;
	assign uart_regfile_interface_pins.status_desc[2]    ="adc_conv_cnt";	

	assign uart_regfile_interface_pins.status[3]     = read_max11000_state;
	assign uart_regfile_interface_pins.status_desc[3]    ="max11000_state";	

endmodule
`default_nettype wire

