`default_nettype none
`include "interface_defs.v"
`include "uart_regfile_interface_defs.v"
import uart_regfile_types::*;
`ifndef ADC_LVDS_RX_OF_ONE_CHIP_MODULE_NAME
`define ADC_LVDS_RX_OF_ONE_CHIP_MODULE_NAME adc_lvds_rx_for_one_chip
`endif
`ifndef ADC_LVDS_RX_OF_ONE_CHIP_SLOW_MODE_MODULE_NAME
`define ADC_LVDS_RX_OF_ONE_CHIP_SLOW_MODE_MODULE_NAME adc_lvds_rx_for_one_chip_slow
`endif
`ifndef ADC_LVDS_RECEIVE_SUPPORT_ENCAPSULATOR_MODULE_NAME
`define ADC_LVDS_RECEIVE_SUPPORT_ENCAPSULATOR_MODULE_NAME adc_lvds_receive_support_encapsulator
`endif

module `ADC_LVDS_RECEIVE_SUPPORT_ENCAPSULATOR_MODULE_NAME
#(
parameter 
  current_FMC = 0, //dummy parameters
  NUMBITS_ADC_BITS = 14,
  FULL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS = 16,
  REGFILE_BAUD_RATE = 2000000,
  UART_CLOCK_SPEED_IN_HZ = 50000000,
  DDS_Phase_Word_Number_of_Bits = 32,
  DDS_Phase_Word_DEFAULT = {5'b0,1'b1,{(DDS_Phase_Word_Number_of_Bits-10){1'b0}},1'b1},
  SIGN_EXTEND_DDS_TEST_SIGNALS = 0,
  NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  = 1'b0,
  NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS = 32'hEAAEAA, 
  NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS  = 32'hEAAEAA,
  NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
  NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS= 8,
  TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
  TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
  OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
  OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
  ACTUAL_NIOS_DACS_CONTROL_SPAN = 32'h2000,
  BASE_PATTERN_TO_OUTPUT_FOR_ATROPHIED_GENERATION_DEFAULT = 32'h2867,
  NUM_ADC_CHANNELS = 2,
  DEFAULT_PARALLELIZER_TRANSPOSE_CTRL  = 0,
  DEFAULT_FRAME_LOCK_MASK              = {{(NUMBITS_ADC_BITS){1'b1}},{(NUMBITS_ADC_BITS){1'b0}}},
  DEFAULT_REFRAMER_TRANSPOSE_CTRL      = 0,
  DEFAULT_LOCK_WAIT                    = 50,
  DEFAULT_ENABLE_LOCK_SCAN             = 1,
  DEFAULT_FRAME_TO_DATA_OFFSET         = 0,
  HW_TRIGGER_CTRL_DEFAULT = 32'h18,

  SIMULATED_HALF_FRAME_IN_DEFAULT = {4{{(NUMBITS_ADC_BITS/2){1'b1}},{(NUMBITS_ADC_BITS/2){1'b0}}}},
  SIMULATED_HALF_DATA_IN_DEFAULT  = {
                                      {{(NUMBITS_ADC_BITS/2-2){1'b0}},2'b11}, 
									  {{(NUMBITS_ADC_BITS/2-2){1'b0}},2'b10}, 
									  {{(NUMBITS_ADC_BITS/2-2){1'b0}},2'b01}, 
									  {{(NUMBITS_ADC_BITS/2-2){1'b0}},2'b00}  
								    },
  parameter [0:0] SIMULATE_LVDS_INPUTS_ONLY = 0,
  parameter        ACTIVITY_MONITOR_NUMBITS = 32,
  parameter [0:0]  ALLOW_2X_TO_LOOK_AT_ALL_CHANNELS = 1,
  parameter [0:0]  ALLOW_REFRAMER_TO_LOOK_AT_ALL_CHANNELS = 1,
  parameter [7:0]  NUM_ADCS_LOGICAL_CHIPS = 2,
  parameter        BERC_SM_CLK_CLOCK_SPEED = 50000000,
  parameter        NUM_OF_LVDS_ADC_FRAMES_IN_ONE_BERC_FRAME = 6,
  parameter [0:0]  USE_SLOW_ADC_CLK_FOR_TESTING = 0, 
  parameter [127:0] TOP_LEVEL_DISPLAY_NAME = "adclvdsrx",
  parameter COMPILE_BER_METER = 0,
  parameter COMPILE_DACS = 1,
  parameter ENABLE_KEEPS_ON_DACS = 0,
  parameter DACS_CHANGE_FORMAT_DEFAULT = 0,
  parameter COMPILE_TEST_SIGNAL_DDS  = 1,                 
  parameter ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION = 1,
  parameter DEFINE_WISHBONE_INTERFACES_FOR_DACS_IF_DISABLED = 1,
  parameter GENERATE_FRAME_CLOCK_ON_NEGEDGE = 1,
  parameter LOCK_WAIT_COUNTER_BITS = 9,
  parameter CHANNEL_TO_LOOK_AT_FOR_DEBUGGING = 0,
  parameter NIOS_DAC_FIFO_IS_DUMMY = 0,
  parameter [0:0] GENERATE_DDS_TEST_SIGNALS = 1,
  parameter       NIOS_DAC_NUM_OUTPUT_SAMPLES_IN_FIFO                = 16384,
  parameter [0:0] NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
  parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1

)
(
 wishbone_interface external_nios_dacs_status_wishbone_interface_pins0,
 wishbone_interface external_nios_dacs_control_wishbone_interface_pins0, 
 wishbone_interface external_nios_dacs_status_wishbone_interface_pins1,
 wishbone_interface external_nios_dacs_control_wishbone_interface_pins1, 
 output logic[NUM_ADCS_LOGICAL_CHIPS-1:0] alt_lvds_locked,
 input [NUM_ADCS_LOGICAL_CHIPS*NUM_ADC_CHANNELS-1:0] lvds_rx_in,
 input [NUM_ADCS_LOGICAL_CHIPS-1:0] lvds_fco_in,
 input [NUM_ADCS_LOGICAL_CHIPS-1:0] lvds_dco_in,
 output logic adc_recovered_data_frame_clk[NUM_ADCS_LOGICAL_CHIPS],
 output logic [NUMBITS_ADC_BITS-1:0] adc_recovered_data[NUM_ADCS_LOGICAL_CHIPS][NUM_ADC_CHANNELS],
  input  async_hw_trigger ,
  output actual_hw_trigger,
 input uart_clk,
 input uart_rx,
 output uart_tx,
 input simulation_half_frame_clk,
 input BERC_sm_clk,
 input       TOP_UART_IS_SECONDARY_UART, 
 input [7:0] TOP_ADDRESS_OF_THIS_UART,   
 input [7:0] TOP_UART_NUM_OF_SECONDARY_UARTS,
 output logic [7:0] NUM_OF_UARTS_HERE
);
logic [7:0] num_uarts_here[4];
assign NUM_OF_UARTS_HERE =  1+num_uarts_here[0] + num_uarts_here[1] + num_uarts_here[2]  + num_uarts_here[3];

import basedef::*;

import uart_regfile_types::*;


uart_struct uart_pins; 
wire primary_local_txd;
wire [NUM_ADCS_LOGICAL_CHIPS-1:0] adc32_reframing_local_txd;
	
assign uart_tx = primary_local_txd & (&adc32_reframing_local_txd);

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  Start Regfile 0 Support
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
logic half_frame_clk[NUM_ADCS_LOGICAL_CHIPS];  
logic [NUMBITS_ADC_BITS/2-1:0] half_frame_data_in[NUM_ADCS_LOGICAL_CHIPS][NUM_ADC_CHANNELS];
logic [NUMBITS_ADC_BITS/2-1:0] half_frame_frame_in[NUM_ADCS_LOGICAL_CHIPS];
logic [(NUM_ADC_CHANNELS+1)*(NUMBITS_ADC_BITS/2)-1 : 0] adc32_altlvds_rx_out[NUM_ADCS_LOGICAL_CHIPS] ;
logic [NUMBITS_ADC_BITS/2-1:0] simulated_half_frame_data_in[4];
logic [NUMBITS_ADC_BITS/2-1:0] actual_simulated_half_frame_data_in[NUM_ADCS_LOGICAL_CHIPS][NUM_ADC_CHANNELS];
logic [NUMBITS_ADC_BITS/2-1:0] simulated_half_frame_frame_in[4];
logic [NUMBITS_ADC_BITS/2-1:0] actual_simulated_half_frame_frame_in[NUM_ADCS_LOGICAL_CHIPS];
reg [1:0] [NUM_ADCS_LOGICAL_CHIPS-1:0] current_half_frame_sel;
logic sel_simulate_frame,sel_simulated_data;
logic sel_const_sim_data_word, sel_const_sim_frame_word;
logic [NUM_ADCS_LOGICAL_CHIPS-1:0] parallel_adc_data_valid; 
logic [NUMBITS_ADC_BITS-1:0] base_pattern_to_output_for_atrophied_generation;
logic [NUM_ADCS_LOGICAL_CHIPS-1:0]  mcp_synch_to_data_clk_aready;
logic [NUM_ADCS_LOGICAL_CHIPS-1:0]  mcp_synch_to_data_clk_bvalid;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//  Emulation/Debug signal generation
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////

/***********************/
logic  [7:0] reframer_is_locked;	



extern module `ADC_LVDS_RX_OF_ONE_CHIP_MODULE_NAME 
(
 rx_in,
 rx_inclock,
 rx_locked,
 rx_out,
 rx_outclock
);

extern module `ADC_LVDS_RX_OF_ONE_CHIP_SLOW_MODE_MODULE_NAME 
(
 rx_in,
 rx_inclock,
 rx_locked,
 rx_out,
 rx_outclock
);

//===========================================================================
// For GP UART Regfile 0
//===========================================================================						
							
	
			
    parameter local_regfile_data_numbytes        =   4;
    parameter local_regfile_data_width           =   8*local_regfile_data_numbytes;
    parameter local_regfile_desc_numbytes        =  16;
    parameter local_regfile_desc_width           =   8*local_regfile_desc_numbytes;
    parameter num_of_local_regfile_control_regs  =  6;
    parameter num_of_local_regfile_status_regs   =  4;
	
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_default_vals[num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_regs_bitwidth    [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_data_width-1:0] local_regfile_control_status           [num_of_local_regfile_status_regs -1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_control_desc             [num_of_local_regfile_control_regs-1:0];
    wire [local_regfile_desc_width-1:0] local_regfile_status_desc              [num_of_local_regfile_status_regs -1:0];
	
    wire local_regfile_control_rd_error;
	wire local_regfile_control_async_reset = 1'b0;
	wire local_regfile_control_wr_error;
	wire local_regfile_control_transaction_error;
	
	
	wire [3:0] local_regfile_main_sm;
	wire [2:0] local_regfile_tx_sm;
	wire [7:0] local_regfile_command_count;
	
	 assign local_regfile_control_regs_default_vals[0]  = 0; 
     assign local_regfile_control_desc[0] = "SelConstDataSim";
     assign sel_const_sim_data_word = local_regfile_control_regs[0];
     assign local_regfile_control_regs_bitwidth[0] =1;
	 
	  assign local_regfile_control_regs_default_vals[1]  = 0; 
     assign local_regfile_control_desc[1] = "SelConstFrameSim";
     assign sel_const_sim_frame_word = local_regfile_control_regs[1];
     assign local_regfile_control_regs_bitwidth[1] = 1;
	
	 assign local_regfile_control_regs_default_vals[2]  = BASE_PATTERN_TO_OUTPUT_FOR_ATROPHIED_GENERATION_DEFAULT; 
     assign local_regfile_control_desc[2] = "base_pat_adc_chk";
     assign base_pattern_to_output_for_atrophied_generation = local_regfile_control_regs[2];
     assign local_regfile_control_regs_bitwidth[2] = NUMBITS_ADC_BITS;	

	 assign local_regfile_control_regs_default_vals[3]  = SIMULATED_HALF_FRAME_IN_DEFAULT; 
     assign local_regfile_control_desc[3] = "sim_frm_in";
     assign {simulated_half_frame_frame_in[3],simulated_half_frame_frame_in[2],simulated_half_frame_frame_in[1],simulated_half_frame_frame_in[0]} = local_regfile_control_regs[3];
     assign local_regfile_control_regs_bitwidth[3] = 32;			
	 
	 assign local_regfile_control_regs_default_vals[4]  = SIMULATED_HALF_DATA_IN_DEFAULT; 
     assign local_regfile_control_desc[4] = "sim_dat_in";
     assign {simulated_half_frame_data_in[3],simulated_half_frame_data_in[2],simulated_half_frame_data_in[1],simulated_half_frame_data_in[0]} = local_regfile_control_regs[4];
     assign local_regfile_control_regs_bitwidth[4] = 32;			

	 assign local_regfile_control_regs_default_vals[5]  = 0; 
     assign local_regfile_control_desc[5] = "sel_sim";
     assign {sel_simulate_frame,sel_simulated_data} = local_regfile_control_regs[5];
     assign local_regfile_control_regs_bitwidth[5] = 32;
	
	assign local_regfile_control_status[0] = {SIMULATE_LVDS_INPUTS_ONLY,NUM_ADCS_LOGICAL_CHIPS,reframer_is_locked};
    assign local_regfile_status_desc[0] = "reframerLocked";
	
	assign local_regfile_control_status[1] = current_half_frame_sel;
    assign local_regfile_status_desc[1] = "currHlfFrmSel";
	 /*
	 generate
			if (NUM_ADCS_LOGICAL_CHIPS >= 2)
			begin
					assign local_regfile_control_status[2] = current_half_frame_sel[1];
					 assign local_regfile_status_desc[2] = "currHlfFrmSel1";	
			end
	 endgenerate
	 */
	assign local_regfile_control_status[2] = alt_lvds_locked;
    assign local_regfile_status_desc[2] = "alt_lvds_locked";
		
	assign local_regfile_control_status[3] = {mcp_synch_to_data_clk_aready,
	                                          mcp_synch_to_data_clk_bvalid};
											  
    assign local_regfile_status_desc[3] = "mcp_blk_status";
	
		uart_controlled_register_file_ver3
		#( 
		  .NUM_OF_CONTROL_REGS(num_of_local_regfile_control_regs),
		  .NUM_OF_STATUS_REGS(num_of_local_regfile_status_regs),
		  .DATA_WIDTH_IN_BYTES  (local_regfile_data_numbytes),
          .DESC_WIDTH_IN_BYTES  (local_regfile_desc_numbytes),
		  .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
		  .CONTROL_REGS_DEFAULT_VAL         (0),
		  .CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
          .UART_BAUD_RATE_IN_HZ(REGFILE_BAUD_RATE)
		)
		local_uart_register_file
		(	
		 .DISPLAY_NAME(TOP_LEVEL_DISPLAY_NAME),
		 .CLK(uart_clk),
		 .REG_ACTIVE_HIGH_ASYNC_RESET(local_regfile_control_async_reset),
		 .CONTROL(local_regfile_control_regs),
		 .CONTROL_DESC(local_regfile_control_desc),
		 .CONTROL_BITWIDTH(local_regfile_control_regs_bitwidth),
		 .STATUS(local_regfile_control_status),
		 .STATUS_DESC (local_regfile_status_desc),
		 .CONTROL_INIT_VAL(local_regfile_control_regs_default_vals),
		 .TRANSACTION_ERROR(local_regfile_control_transaction_error),
		 .WR_ERROR(local_regfile_control_wr_error),
		 .RD_ERROR(local_regfile_control_rd_error),
		 .USER_TYPE(uart_regfile_types::AVSOC_JESD_ENCAPSULATOR_TOP_CTRL_REGFILE),
		 .NUM_SECONDARY_UARTS (TOP_UART_NUM_OF_SECONDARY_UARTS),
         .ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART   ),
         .IS_SECONDARY_UART   (TOP_UART_IS_SECONDARY_UART ),
		 
		
		 //UART
		 .uart_active_high_async_reset(1'b0),
		 .rxd(uart_rx),
		 .txd(primary_local_txd),
		 
		 //UART DEBUG
		 .main_sm               (local_regfile_main_sm),
		 .tx_sm                 (local_regfile_tx_sm),
		 .command_count         (local_regfile_command_count)
		  
		);
		
		
genvar i,j;
generate			 
		for (j = 0; j < NUM_ADCS_LOGICAL_CHIPS; j++)
				begin: make_per_logic_adc_simulation_signals	  		 
					for (i = 0; i < NUM_ADC_CHANNELS; i++)
					begin : assign_half_frame_data_in
						  always @(posedge half_frame_clk[j])
						  begin
							   actual_simulated_half_frame_data_in[j][i]  <= sel_const_sim_data_word ? simulated_half_frame_data_in[0] : simulated_half_frame_data_in[current_half_frame_sel[j]];						   
						  end 	
					end	
					
					always @(posedge half_frame_clk[j])
					begin
						  current_half_frame_sel[j] <= current_half_frame_sel[j] + 1;					
					end

					always @(posedge half_frame_clk[j])
					begin
						 actual_simulated_half_frame_frame_in[j] <= sel_const_sim_frame_word ? simulated_half_frame_frame_in[0] : simulated_half_frame_frame_in[current_half_frame_sel[j]];
					end
		end
		
		
		if (SIMULATE_LVDS_INPUTS_ONLY)
		begin
			  	for (j = 0; j < NUM_ADCS_LOGICAL_CHIPS; j++)
				begin: make_per_logic_adc_simulation_only_signals	 
						assign half_frame_clk[j] = simulation_half_frame_clk;
						for (i = 0; i < NUM_ADC_CHANNELS; i++)
						begin : assign_half_frame_data_in
						   assign half_frame_data_in[j][i]  = actual_simulated_half_frame_data_in[j][i]; 
					    end
						assign  half_frame_frame_in[j] = actual_simulated_half_frame_frame_in[j] ; 	


						    wire alt_lvds_locked_enable;
							generate_one_shot_pulse 
							#(.num_clks_to_wait(1))  
							generate_alt_lvds_locked_enable
							(
							.clk(half_frame_clk[j]), 
							.oneshot_pulse(alt_lvds_locked_enable)
							);				

                            always @(posedge half_frame_clk[j])
							begin
							     if (alt_lvds_locked_enable)
								 begin
									alt_lvds_locked[j] <= 1;
								 end
							end						   
													 
			   end
		end else
		begin
		        for (j = 0; j < NUM_ADCS_LOGICAL_CHIPS; j++)
				begin: make_adc_lvds_connections
				    if (USE_SLOW_ADC_CLK_FOR_TESTING)
							begin
									`ADC_LVDS_RX_OF_ONE_CHIP_SLOW_MODE_MODULE_NAME 
									adc32_fmc_rx_inst(
									.rx_in      ( {lvds_fco_in[j],lvds_rx_in[(j+1)*NUM_ADC_CHANNELS-1 -: NUM_ADC_CHANNELS]}),
									.rx_inclock (lvds_dco_in[j]),
									.rx_out     (adc32_altlvds_rx_out[j]),
									.rx_locked     (alt_lvds_locked[j]),
									.rx_outclock(half_frame_clk[j])
									);
							end else
							begin
									`ADC_LVDS_RX_OF_ONE_CHIP_MODULE_NAME 
									adc32_fmc_rx_inst(
									.rx_in      ( {lvds_fco_in[j],lvds_rx_in[(j+1)*NUM_ADC_CHANNELS-1 -: NUM_ADC_CHANNELS]}),
									.rx_inclock (lvds_dco_in[j]),
									.rx_out     (adc32_altlvds_rx_out[j]),
									.rx_locked     (alt_lvds_locked[j]),
									.rx_outclock(half_frame_clk[j])
									);
							end					
					for (i = 0; i < NUM_ADC_CHANNELS; i++)
					begin : assign_half_frame_data_in
						  always @(posedge half_frame_clk[j])
						  begin
							   half_frame_data_in[j][i]  <= sel_simulated_data ? actual_simulated_half_frame_data_in[j][i] : adc32_altlvds_rx_out[j][(i+1)*(NUMBITS_ADC_BITS/2)-1 -: (NUMBITS_ADC_BITS/2)]; 
						  end 	
					end
					always @(posedge half_frame_clk[j])
					begin
						 half_frame_frame_in[j]  <= sel_simulate_frame ? actual_simulated_half_frame_frame_in[j] : adc32_altlvds_rx_out[j][(NUM_ADC_CHANNELS+1)*(NUMBITS_ADC_BITS/2)-1 -: (NUMBITS_ADC_BITS/2)]; 
					end 	
				end
		end
			 
		for (j = 0; j < NUM_ADCS_LOGICAL_CHIPS; j++)
        begin : make_lvds_to_full_sync_modules		
		       logic [7:0] address_of_top_uart;
		       if (j == 0)
			   begin
			       assign address_of_top_uart = 1;
			   end
			   else 
			   begin
			       assign address_of_top_uart = 1 + j*num_uarts_here[0];				   
			   end
			   
			   localparam LOCAL_NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS   = NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS + j*ACTUAL_NIOS_DACS_CONTROL_SPAN ;
 	           localparam LOCAL_NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS    = NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS  + j*ACTUAL_NIOS_DACS_CONTROL_SPAN  ;

			
			   
			   
			   
			   localparam [7:0] adc_char = j+48; //convert to ascii;		 
			   wire [7:0] local_num_uarts_here[2];
			   
			   assign num_uarts_here[j] = local_num_uarts_here[0];
			   
			   wishbone_interface 
				#(
				   .num_address_bits(32), 
				   .num_data_bits(32)
				)
				local_nios_dacs_status_wishbone_interface_pins(),
				local_nios_dacs_control_wishbone_interface_pins();
				
				case (j)
				0 :    begin : j_is_0
				                concat_wishbone_interfaces
								#(
								.use_clk_from_wishbone_interface_in(1),
								.connect_clocks(1)
								)
								concat_status_wishbone_interfaces_inst
								(
								.wishbone_interface_in (external_nios_dacs_status_wishbone_interface_pins0),
								.wishbone_interface_out(local_nios_dacs_status_wishbone_interface_pins)
								);
								
								 concat_wishbone_interfaces
								#(
								.use_clk_from_wishbone_interface_in(1),
								.connect_clocks(1)
								)
								concat_control_wishbone_interfaces_inst
								(
								.wishbone_interface_in (external_nios_dacs_control_wishbone_interface_pins0),
								.wishbone_interface_out(local_nios_dacs_control_wishbone_interface_pins)
								);
						end
						
				1 :    begin :j_is_1
				                concat_wishbone_interfaces
								#(
								.use_clk_from_wishbone_interface_in(1),
								.connect_clocks(1)
								)
								concat_status_wishbone_interfaces_inst
								(
								.wishbone_interface_in (external_nios_dacs_status_wishbone_interface_pins1),
								.wishbone_interface_out(local_nios_dacs_status_wishbone_interface_pins)
								);
								
								 concat_wishbone_interfaces
								#(
								.use_clk_from_wishbone_interface_in(1),
								.connect_clocks(1)
								)
								concat_control_wishbone_interfaces_inst
								(
								.wishbone_interface_in (external_nios_dacs_control_wishbone_interface_pins1),
								.wishbone_interface_out(local_nios_dacs_control_wishbone_interface_pins)
								);
						  end
						  default: begin
						           end
					endcase
				
				multi_channel_generic_half_frame_to_full_sync
				#(
				.COMPILE_BER_METER(COMPILE_BER_METER),
				.OMIT_CONTROL_REG_DESCRIPTIONS                   (OMIT_CONTROL_REG_DESCRIPTIONS),
				.OMIT_STATUS_REG_DESCRIPTIONS                    (OMIT_STATUS_REG_DESCRIPTIONS),
				.UART_CLOCK_SPEED_IN_HZ                          (UART_CLOCK_SPEED_IN_HZ),
				.BERC_SM_CLK_CLOCK_SPEED                         (BERC_SM_CLK_CLOCK_SPEED),
				.REGFILE_DEFAULT_BAUD_RATE                       (REGFILE_BAUD_RATE),
				.uart_parellelizer_2x_prefix                     ({"rxlvds_",adc_char}),
				.uart_reframer_prefix                            ({"rxlvds_",adc_char}),
				.uart_dac_prefix                                 ({"rxlvds_",adc_char}),
				.uart_berc_prefix                                ({"rxlvds_",adc_char}),
				.LOCK_WAIT_COUNTER_BITS                          (LOCK_WAIT_COUNTER_BITS),
				.NUMBITS_DATAIN_FULL_WIDTH                       (NUMBITS_ADC_BITS),
				.NUM_DATA_CHANNELS                               (NUM_ADC_CHANNELS),
				.GENERATE_FRAME_CLOCK_ON_NEGEDGE                 (GENERATE_FRAME_CLOCK_ON_NEGEDGE),
				.CHANNEL_TO_LOOK_AT_FOR_DEBUGGING                (CHANNEL_TO_LOOK_AT_FOR_DEBUGGING),
				.DEFAULT_PARALLELIZER_TRANSPOSE_CTRL             (DEFAULT_PARALLELIZER_TRANSPOSE_CTRL),
				.DEFAULT_SIMULATED_FULL_FRAME_DATA               (SIMULATED_HALF_FRAME_IN_DEFAULT),
				.DEFAULT_SIMULATED_HALF_FRAME_DATA               (SIMULATED_HALF_DATA_IN_DEFAULT),
				.DEFAULT_FRAME_LOCK_MASK                         ({{(NUMBITS_ADC_BITS/2){1'b1}},{(NUMBITS_ADC_BITS/2){1'b0}}}),
				.DEFAULT_REFRAMER_TRANSPOSE_CTRL                 (DEFAULT_REFRAMER_TRANSPOSE_CTRL),
				.DEFAULT_LOCK_WAIT                               (DEFAULT_LOCK_WAIT),
				.DEFAULT_ENABLE_LOCK_SCAN                        (DEFAULT_ENABLE_LOCK_SCAN),
				.DEFAULT_FRAME_TO_DATA_OFFSET                    (DEFAULT_FRAME_TO_DATA_OFFSET),
				.COMPILE_DACS                                    (COMPILE_DACS),
				.NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  (NIOS_DACS_WISHBONE_INTERFACE_IS_PART_OF_BRIDGE),
				.NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS         (LOCAL_NIOS_DACS_WISHBONE_CONTROL_BASE_ADDRESS       ),
				.NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS          (LOCAL_NIOS_DACS_WISHBONE_STATUS_BASE_ADDRESS        ),
				.NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS      (NIOS_DACS_STATUS_WISHBONE_NUM_ADDRESS_BITS    ),
				.NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS     (NIOS_DACS_CONTROL_WISHBONE_NUM_ADDRESS_BITS   ),
				.ENABLE_KEEPS_ON_DACS                            (ENABLE_KEEPS_ON_DACS),
				.ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS         (NUMBITS_ADC_BITS),
				.DACS_CHANGE_FORMAT_DEFAULT                      (DACS_CHANGE_FORMAT_DEFAULT                      ),
				.GENERATE_DDS_TEST_SIGNALS                       (GENERATE_DDS_TEST_SIGNALS),
				.COMPILE_TEST_SIGNAL_DDS                         (COMPILE_TEST_SIGNAL_DDS                         ),                 
				.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION        (ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION        ),
				.DEFINE_WISHBONE_INTERFACES_FOR_DACS_IF_DISABLED (DEFINE_WISHBONE_INTERFACES_FOR_DACS_IF_DISABLED ),
				.ACTIVITY_MONITOR_NUMBITS                        (ACTIVITY_MONITOR_NUMBITS),
				.ALLOW_2X_TO_LOOK_AT_ALL_CHANNELS                (ALLOW_2X_TO_LOOK_AT_ALL_CHANNELS),
				.ALLOW_REFRAMER_TO_LOOK_AT_ALL_CHANNELS          (ALLOW_REFRAMER_TO_LOOK_AT_ALL_CHANNELS),
				.NUM_OF_LVDS_ADC_FRAMES_IN_ONE_BERC_FRAME        (NUM_OF_LVDS_ADC_FRAMES_IN_ONE_BERC_FRAME),
				.NIOS_DAC_NUM_OUTPUT_SAMPLES_IN_FIFO               (NIOS_DAC_NUM_OUTPUT_SAMPLES_IN_FIFO               ),
				.NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS(NIOS_DAC_USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
				.NIOS_DAC_FIFO_IS_DUMMY                            (NIOS_DAC_FIFO_IS_DUMMY                            ),
				.HW_TRIGGER_CTRL_DEFAULT                           (HW_TRIGGER_CTRL_DEFAULT),
				.SUPPORT_INPUT_DESCRIPTIONS                        (SUPPORT_INPUT_DESCRIPTIONS)
				)
				multi_channel_generic_half_frame_to_full_sync_inst
				(
				.half_frame_data_in(half_frame_data_in[j]),
				.half_frame_frame_in(half_frame_frame_in[j]),
				.half_frame_clk(half_frame_clk[j]),
				.half_frame_clk_valid(alt_lvds_locked[j]),
				.frame_clk_valid(alt_lvds_locked[j]),
				.frame_clk(adc_recovered_data_frame_clk[j]),
				.data_out (adc_recovered_data[j]),
				.reframer_is_locked(reframer_is_locked[j]),
				.UART_REGFILE_CLK(uart_clk),
				.RESET_FOR_UART_REGFILE_CLK(1'b0),
					
				.uart_rx(uart_rx),
				.uart_tx(adc32_reframing_local_txd[j]), 

				.TOP_UART_IS_SECONDARY_UART       (1),    
				.TOP_UART_NUM_SECONDARY_UARTS     (0),  
				.TOP_UART_ADDRESS_OF_THIS_UART    (address_of_top_uart),
				.NUM_UARTS_HERE                   (local_num_uarts_here[0]),
				.BERC_sm_clk(BERC_sm_clk),
				.base_pattern_to_output_for_atrophied_generation(base_pattern_to_output_for_atrophied_generation),
				.external_nios_dacs_status_wishbone_interface_pins (local_nios_dacs_status_wishbone_interface_pins ),
				.external_nios_dacs_control_wishbone_interface_pins(local_nios_dacs_control_wishbone_interface_pins),
				.async_hw_trigger, 
				.actual_hw_trigger
				);	
				
       end
endgenerate
endmodule
`default_nettype wire