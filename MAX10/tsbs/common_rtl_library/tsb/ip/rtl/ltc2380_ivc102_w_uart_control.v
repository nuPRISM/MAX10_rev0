`default_nettype none
module ltc2380_ivc102_w_uart_control
#(
parameter device_family = "Cylcone III", 
parameter num_adcs = 2,
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
parameter [127:0] uart_name = {prefix_uart_name,"_ltc2390"},
parameter UART_REGFILE_TYPE = uart_regfile_types::LTC2380_IVC102_REGFILE,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID = 1,
parameter DEFAULT_TRIGGER_FREQUENCY_DIV_WORD = 249999,
parameter DEFAULT_ADC_ACQ_ENABLE = 1,
parameter DEFAULT_INTERGRATION_TIME_COUNT = 200,
parameter DEFAULT_RESET_TIME_COUNT = 450,
parameter DEFAULT_TRIGGER_SETTINGS = 1,
parameter DEFAULT_PRE_INTEGRATION_RESET_TIME_COUNT = 350,
parameter DEFAULT_HOLD_TIME_COUNT = 200,
parameter DEFAULT_DATA_TYPE_TO_SEND_TO_OUTPUT = 0,
parameter DEFAULT_FULL_SCALE_RANGE_PA = 1000000,
parameter [7:0] num_adc_averager_shift_bits = 4,
parameter [7:0] DEFAULT_AVERAGER_SHIFT = 8,
parameter [7:0] averager_clk_count_num_bits   = (2**num_adc_averager_shift_bits)+1,
parameter [averager_clk_count_num_bits-1:0] DEFAULT_AVERAGER_M = 32'h7F,
parameter [31:0] DEFAULT_SCALING_ADC0  = 32'h3f800000, //1.0
parameter [31:0] DEFAULT_OFFSET_ADC0   = 0,
parameter [31:0] DEFAULT_SCALING_ADC1  = 32'h3f800000, //1.0
parameter [31:0] DEFAULT_OFFSET_ADC1   = 0,
parameter synchronizer_depth = 3
)
(
			//system clk
			input   clk_sm,
			output  adc_clk,
			output  [adc_numbits-1:0] adc_data[num_adcs],
			output logic [num_adcs-1:0] averaged_adc_clk,
         output logic [adc_numbits-1:0] averaged_adc[num_adcs],
			
			input logic external_trigger,
			 ltc2380_interface ltc2380_interface_pins,
			
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
logic signed [adc_numbits -1:0] read_data[num_adcs];
logic signed [adc_numbits -1:0] pre_integration_read_data[num_adcs];
logic signed [adc_numbits -1:0] pre_integration_read_data_raw[num_adcs];
logic signed [adc_numbits -1:0] corrected_adc_data[num_adcs];

logic [15:0] state;
logic [15:0] read_ltc2380_state;
logic in_the_middle_of_acquiring;
logic do_reset_before_integration;
logic keep_reset_active_after_integration;
logic [1:0] sel_data_type_to_output;

(* keep = 1, preserve = 1 *) logic external_trigger_pulse;
(* keep = 1, preserve = 1 *) logic enable_external_trigger;
(* keep = 1, preserve = 1 *) logic emulate_external_trigger;
(* keep = 1, preserve = 1 *) logic auto_start;
(* keep = 1, preserve = 1 *) logic auto_start_trigger;
(* keep = 1, preserve = 1 *) logic start_from_regfile;
(* keep = 1, preserve = 1 *) logic enable_auto_trigger;
(* keep = 1, preserve = 1 *) logic tie_s1_to_0;
(* keep = 1, preserve = 1 *) logic s1_from_integrate_and_hold;
(* keep = 1, preserve = 1 *) logic s2_from_integrate_and_hold;
(* keep = 1, preserve = 1 *) logic s1_from_register_file;
(* keep = 1, preserve = 1 *) logic s2_from_register_file;
(* keep = 1, preserve = 1 *) logic select_s1_from_register_file;
(* keep = 1, preserve = 1 *) logic select_s2_from_register_file;



assign clk = clk_sm;

integrate_and_hold_ivc102
#(
.N(counter_numbits)
)
integrate_and_hold_ivc102_inst
(
.clk,
.start,
.enable,
.finish(finish),
.reset,
.tie_s1_to_0(tie_s1_to_0),
.busy(ltc2380_interface_pins.busy),
.s1(s1_from_integrate_and_hold),
.s2(s2_from_integrate_and_hold),
.integration_time,
.reset_time,
.hold_time,
.aux_counter,
.read_data,
.pre_integration_read_data(pre_integration_read_data_raw),
.read_data_raw(),
.state,
.read_ltc2380_state,
.spi_clk(ltc2380_interface_pins.spi_clk),
.spi_csn(ltc2380_interface_pins.spi_csn),
.spi_miso(ltc2380_interface_pins.spi_miso),
.conv(ltc2380_interface_pins.conv),
.in_the_middle_of_acquiring,
.do_reset_before_integration,
.keep_reset_active_after_integration,
.pre_integration_reset_wait_time
);

assign ltc2380_interface_pins.s1 = select_s1_from_register_file ? s1_from_register_file : s1_from_integrate_and_hold;
assign ltc2380_interface_pins.s2 = select_s2_from_register_file ? s2_from_register_file : s2_from_integrate_and_hold;

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
			end
	  end
end 


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


logic [num_adc_averager_shift_bits-1:0] adc_averager_shift;
logic [averager_clk_count_num_bits-1:0] adc_averager_M;
logic [31:0] adc_averager_data_count[num_adcs];

genvar current_adc;
generate
for (current_adc = 0; current_adc < num_adcs; current_adc++)
begin : set_adc_data_to_waveform_display
      always_ff @(posedge adc_clk)
		begin
		     pre_integration_read_data[current_adc] <= pre_integration_read_data_raw[current_adc];
		end
		
		
		always_ff @(posedge adc_clk)
		begin
		       corrected_adc_data[current_adc] <=  read_data[current_adc] - pre_integration_read_data[current_adc];
		end		
		always_ff @(posedge adc_clk)
		begin
		      case (sel_data_type_to_output)
			  2'b00: adc_data[current_adc] <= corrected_adc_data[current_adc];
			  2'b01: adc_data[current_adc] <= read_data[current_adc];
			  2'b10: adc_data[current_adc] <= pre_integration_read_data[current_adc];
			  2'b11: adc_data[current_adc] <= corrected_adc_data[current_adc] - corrected_adc_data[1-current_adc];
			  endcase
		end		
		
		
		 simple_averager
 	     #(
		     .shift_num_bits       (num_adc_averager_shift_bits),
		     .num_data_bits        (adc_numbits)
		  )
          simple_averager_inst
		  (				
		  				.DECIMATOR_SHIFT    (adc_averager_shift),
		  				.DECIMATOR_M        (adc_averager_M    ),
		  				.inclk              (adc_clk),
		  				.indata             (adc_data[current_adc]),
		  				.reset_n            (1'b1),
		  				.outclk             (averaged_adc_clk[current_adc]),
		  				.average_outdata    (averaged_adc[current_adc]),
		  				.accumulator_outdata(),
		  );
		  
		  always @(posedge averaged_adc_clk[current_adc])
		  begin
		        adc_averager_data_count[current_adc] <=  adc_averager_data_count[current_adc]  + 1;
		  end
end
endgenerate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 18;			
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
    assign {tie_s1_to_0,    
	         start_from_regfile,
	         do_reset_before_integration,
				keep_reset_active_after_integration,
				reset,
				enable}                      
				= uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 6;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_INTERGRATION_TIME_COUNT;
    assign uart_regfile_interface_pins.control_desc[2]               = "integration_time";
    assign integration_time                                          = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = counter_numbits;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  DEFAULT_RESET_TIME_COUNT;
    assign uart_regfile_interface_pins.control_desc[3]               = "reset_time";
    assign reset_time                                          = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = counter_numbits;		
	
	 logic [1:0] trigger_mode_setting;
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  DEFAULT_TRIGGER_SETTINGS;
    assign uart_regfile_interface_pins.control_desc[4]               = "trigger";
    assign {trigger_mode_setting,emulate_external_trigger,enable_external_trigger,enable_auto_trigger}   = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = 16;		


	
	assign uart_regfile_interface_pins.control_regs_default_vals[5]  =  DEFAULT_PRE_INTEGRATION_RESET_TIME_COUNT;
    assign uart_regfile_interface_pins.control_desc[5]               = "reset_wait_time";
    assign pre_integration_reset_wait_time                           = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = counter_numbits;		
	 
    assign uart_regfile_interface_pins.control_regs_default_vals[6]  =  DEFAULT_HOLD_TIME_COUNT;
    assign uart_regfile_interface_pins.control_desc[6]               = "hold_time";
    assign hold_time                                                 = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6]      = counter_numbits;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[7]  =  DEFAULT_DATA_TYPE_TO_SEND_TO_OUTPUT;
    assign uart_regfile_interface_pins.control_desc[7]               = "sel_dat_type_out";
    assign sel_data_type_to_output                                   = uart_regfile_interface_pins.control[7];
    assign uart_regfile_interface_pins.control_regs_bitwidth[7]      = 2;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[8]  =  DEFAULT_AVERAGER_M;
    assign uart_regfile_interface_pins.control_desc[8]               = "averager_M";
    assign adc_averager_M                                            = uart_regfile_interface_pins.control[8];
    assign uart_regfile_interface_pins.control_regs_bitwidth[8]      = averager_clk_count_num_bits;

		assign uart_regfile_interface_pins.control_regs_default_vals[9]  =  DEFAULT_AVERAGER_SHIFT;
    assign uart_regfile_interface_pins.control_desc[9]                   = "averager_shift";
    assign adc_averager_shift                                            = uart_regfile_interface_pins.control[9];
    assign uart_regfile_interface_pins.control_regs_bitwidth[9]          =  num_adc_averager_shift_bits;

 	assign uart_regfile_interface_pins.control_regs_default_vals[10]  =  DEFAULT_FULL_SCALE_RANGE_PA;
    assign uart_regfile_interface_pins.control_desc[10]               = "full_scale_pa";
    assign uart_regfile_interface_pins.control_regs_bitwidth[10]      = 32;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[11]  =  DEFAULT_SCALING_ADC0;
    assign uart_regfile_interface_pins.control_desc[11]               = "scaling_adc0";
    assign uart_regfile_interface_pins.control_regs_bitwidth[11]      = 32;		

	assign uart_regfile_interface_pins.control_regs_default_vals[12]  =  DEFAULT_OFFSET_ADC0;
    assign uart_regfile_interface_pins.control_desc[12]               = "offset_adc0";
    assign uart_regfile_interface_pins.control_regs_bitwidth[12]      = 32;		

	assign uart_regfile_interface_pins.control_regs_default_vals[13]  =  DEFAULT_SCALING_ADC1;
    assign uart_regfile_interface_pins.control_desc[13]               = "scaling_adc1";
    assign uart_regfile_interface_pins.control_regs_bitwidth[13]      = 32;		

	assign uart_regfile_interface_pins.control_regs_default_vals[14]  =  DEFAULT_OFFSET_ADC1;
    assign uart_regfile_interface_pins.control_desc[14]               = "offset_adc1";
    assign uart_regfile_interface_pins.control_regs_bitwidth[14]      = 32;	
	
	 assign uart_regfile_interface_pins.control_regs_default_vals[15]  =  0;
    assign uart_regfile_interface_pins.control_desc[15]               = "direct_s_ctrl";
    assign {select_s2_from_register_file,select_s1_from_register_file,s2_from_register_file,s1_from_register_file}   = uart_regfile_interface_pins.control[15];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[15]      = 4;	
	 	

	assign uart_regfile_interface_pins.status[0]         = adc_data[0];	
	assign uart_regfile_interface_pins.status_desc[0]    ="adc_data0";	

	    
	assign uart_regfile_interface_pins.status[1]         = adc_data[1];	
	assign uart_regfile_interface_pins.status_desc[1]    ="adc_data0";	

	assign uart_regfile_interface_pins.status[2]         = state;
	assign uart_regfile_interface_pins.status_desc[2]    ="fsm_state";	
	
	assign uart_regfile_interface_pins.status[3]         = {ltc2380_interface_pins.busy,in_the_middle_of_acquiring,ltc2380_interface_pins.s1,ltc2380_interface_pins.s2,ltc2380_interface_pins.conv};
	assign uart_regfile_interface_pins.status_desc[3]    ="ctrl_sig_status";	
	
	assign uart_regfile_interface_pins.status[4]     = adc_conversion_counter;
	assign uart_regfile_interface_pins.status_desc[4]    ="adc_conv_cnt";	
	
	assign uart_regfile_interface_pins.status[5]     = aux_counter;
	assign uart_regfile_interface_pins.status_desc[5]    ="aux_counter";	
	
	assign uart_regfile_interface_pins.status[6]     = read_ltc2380_state;
	assign uart_regfile_interface_pins.status_desc[6]    ="ltc2380_state";
	
    assign uart_regfile_interface_pins.status[7]     =   {read_data[1][adc_numbits-1 -: 16],read_data[0][adc_numbits-1 -: 16]};
	assign uart_regfile_interface_pins.status_desc[7]    ="adcs_data";	
	
    assign uart_regfile_interface_pins.status[8]     =   {read_data[0][adc_numbits-1 -: 16],pre_integration_read_data[0][adc_numbits-1 -: 16]};
	assign uart_regfile_interface_pins.status_desc[8]    ="adc_data_comp_0";	
	
	assign uart_regfile_interface_pins.status[9]     =   {read_data[1][adc_numbits-1 -: 16],pre_integration_read_data[1][adc_numbits-1 -: 16]};
	assign uart_regfile_interface_pins.status_desc[9]    ="adc_data_comp_1";	
	
    assign uart_regfile_interface_pins.status[10]     = pre_integration_read_data[0];	
	assign uart_regfile_interface_pins.status_desc[10]    ="pre_int_data0";	
	    
	assign uart_regfile_interface_pins.status[11]         = pre_integration_read_data[1];	
	assign uart_regfile_interface_pins.status_desc[11]    ="pre_int_data1";	

	assign uart_regfile_interface_pins.status[12]         = read_data[0];	
	assign uart_regfile_interface_pins.status_desc[12]    ="post_int_data0";	
	    
	assign uart_regfile_interface_pins.status[13]         = read_data[1];	
	assign uart_regfile_interface_pins.status_desc[13]    ="post_int_data1";	

	assign uart_regfile_interface_pins.status[14]         = averaged_adc[0];	
	assign uart_regfile_interface_pins.status_desc[14]    ="averaged_adc0";	
	assign uart_regfile_interface_pins.status[15]         = averaged_adc[1];	
	assign uart_regfile_interface_pins.status_desc[15]    ="averaged_adc1";	

	assign uart_regfile_interface_pins.status[16]         = adc_averager_data_count[0];	
	assign uart_regfile_interface_pins.status_desc[16]    = "averager_count0";	
	assign uart_regfile_interface_pins.status[17]         = adc_averager_data_count[1];		
	assign uart_regfile_interface_pins.status_desc[17]    = "averager_count1";	
endmodule
`default_nettype wire

