
`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module uart_controlled_test_signal_generation
#(
parameter  [7:0] ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0,
parameter  [7:0] ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b0,
parameter Synchronize_Capture_Both_GP_FIFOs_DEFAULT = 1,
parameter [0:0] COMPILE_TEST_SIGNAL_DDS = 0,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
parameter [15:0] in_data_bits   = 16,
parameter [15:0] out_data_bits  = 16,
parameter num_dac_channels = in_data_bits/out_data_bits,
parameter num_locations_in_fifo = 16384,
parameter [15:0] num_words_bits = $clog2(num_locations_in_fifo),
parameter DEFAULT_CHANNEL_TO_DAC0 = 0,
parameter DEFAULT_CHANNEL_TO_DAC1 = 0,
parameter [15:0] ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS = out_data_bits,
parameter ENABLE_KEEPS = 0,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_NiosDAC"},
parameter UART_REGFILE_TYPE = uart_regfile_types::NIOS_DACS_STANDALONE_REGFILE,
parameter [0:0]    IGNORE_TIMING_TO_READ_LD = 1'b0,
parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0,
parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR",
parameter change_format_default = 0,
parameter [0:0]  WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0,
parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS        = 0,
parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS         = 0,
parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter NUM_OF_NIOS_DACS = 2,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION = 0
)
(
	input  CLKIN,
	input  RESET_FOR_CLKIN,
	
	dual_dac_interface nios_dac_pins,
	data_acq_fifo_interface fifo_0_interface,
	data_acq_fifo_interface fifo_1_interface,
	
	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	
    wishbone_interface status_wishbone_interface_pins,
    wishbone_interface control_wishbone_interface_pins,
	
    output logic [in_data_bits:0]  test_selected_data[NUM_OF_NIOS_DACS]

	
);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Wire and register definitions
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`define current_subrange(chan) chan*out_data_bits+ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS-1:chan*out_data_bits



		/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     GP FIFO 0
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire Synchronize_Capture_Both_GP_FIFOs;
	
	
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [in_data_bits-1:0] data_to_the_GP_FIFO_0;
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [31:0] in_port_to_the_GP_FIFO_0_Flags;
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  rdempty_from_the_GP_FIFO_0;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  rdfull_from_the_GP_FIFO_0;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrclk_to_the_GP_FIFO_0;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrempty_from_the_GP_FIFO_0;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrfull_from_the_GP_FIFO_0;
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrreq_to_the_GP_FIFO_0;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  DAC0_data_valid;
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [7:0] out_port_from_the_GP_FIFO_0_Control;
	
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [31:0] q_from_the_GP_FIFO_0;
     (* keep = 1, preserve = 1, altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) wire rdclk_to_the_GP_FIFO_0;
	
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire rdreq_to_the_GP_FIFO_0;
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  [num_words_bits-1:0] wrusedw_from_the_GP_FIFO_0;

	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     GP FIFO 1
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [in_data_bits-1:0] data_to_the_GP_FIFO_1;
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [31:0] in_port_to_the_GP_FIFO_1_Flags;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  rdempty_from_the_GP_FIFO_1;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  rdfull_from_the_GP_FIFO_1;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrclk_to_the_GP_FIFO_1;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrempty_from_the_GP_FIFO_1;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrfull_from_the_GP_FIFO_1;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  wrreq_to_the_GP_FIFO_1;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  DAC1_data_valid;
   	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [7:0] out_port_from_the_GP_FIFO_1_Control;
	
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [31:0] q_from_the_GP_FIFO_1;
    (* keep = 1, preserve = 1, altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) wire rdclk_to_the_GP_FIFO_1;
	
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire rdreq_to_the_GP_FIFO_1;
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire  [num_words_bits-1:0] wrusedw_from_the_GP_FIFO_1;
	
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     Misc signals
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire synced_out_port_from_the_GP_FIFO_0_Control_0_to_FIFO0_write_domain;
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire synced_out_port_from_the_GP_FIFO_1_Control_0_to_FIFO0_write_domain;
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire synced_out_port_from_the_GP_FIFO_0_Control_0_to_FIFO1_write_domain;
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire synced_out_port_from_the_GP_FIFO_1_Control_0_to_FIFO1_write_domain;
	
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO0_write_domain;
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO1_write_domain;
	
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire DAC_CLK_MUXED_OUT0;
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire DAC_CLK_MUXED_OUT1;	
   
    `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER wire [1:0] change_DAC_format;

				
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic    [in_data_bits-1:0]  DAC_MUXED_OUT1_raw; 
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic    [in_data_bits-1:0]  DAC_MUXED_OUT0_raw; 				
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic    [in_data_bits:0]    registered_selected_data[NUM_OF_NIOS_DACS]; 
		`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [in_data_bits:0]  comb_selected_data[NUM_OF_NIOS_DACS]; 

	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [in_data_bits:0]  DAC_MUXED_OUT1_raw2; 
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [in_data_bits:0]  DAC_MUXED_OUT0_raw2; 
	`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [in_data_bits:0]  DAC_MUXED_OUT1,DAC_MUXED_OUT0;
	
		`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER	logic      select_test_dds[NUM_OF_NIOS_DACS];
		`UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [1:0] select_phase_accum_test_signal[NUM_OF_NIOS_DACS];

   wire nios_dac_clk[2];
	 
	assign nios_dac_clk[1] = nios_dac_pins.selected_clk_to_DAC1;
	assign nios_dac_clk[0] = nios_dac_pins.selected_clk_to_DAC0;
	
	always@(*)
	begin
			  comb_selected_data[0] = {nios_dac_pins.valid_to_DAC0,nios_dac_pins.selected_channel_to_DAC0};
	   	  comb_selected_data[1] = {nios_dac_pins.valid_to_DAC1,nios_dac_pins.selected_channel_to_DAC1};
	end

  `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0]	test_dds_phi_inc_i[NUM_OF_NIOS_DACS];
  `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS-1:0] test_dds_triangular_waveform_out[NUM_OF_NIOS_DACS][num_dac_channels];
  `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS-1:0] sine_waveform_out[NUM_OF_NIOS_DACS][num_dac_channels];
  `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS-1:0] cosine_waveform_out[NUM_OF_NIOS_DACS][num_dac_channels];
  `UART_CONTROLLED_NIOS_DAC_DEBUG_KEEPER logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0]  test_dds_phase_accumulator[NUM_OF_NIOS_DACS][num_dac_channels];
	
	
	
	
	genvar current_dds_test_channel;
	genvar current_nios_dac;
	generate
	
			if (COMPILE_TEST_SIGNAL_DDS)
			begin : generate_test_dds_signal
			
						  for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
						  begin : per_nios_dac		
						  
										multiple_parallel_advanced_dds
										#(
										.num_phase_bits (TEST_SIGNAL_DDS_NUM_PHASE_BITS), 
										.num_output_bits (ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS),
										.num_parallel_oscillators(num_dac_channels)
										)
										multiple_parallel_advanced_dds_inst
										(
										.clk(nios_dac_clk[current_nios_dac]),
										.reset_n(1'b1),
										.clken(1'b1),
										.phi_inc_i(test_dds_phi_inc_i[current_nios_dac]),
										.triangular_waveform_out(test_dds_triangular_waveform_out[current_nios_dac]),
										.cosine_waveform_out(cosine_waveform_out[current_nios_dac]),
										.sine_waveform_out(sine_waveform_out[current_nios_dac]),
										.phase_accumulator(test_dds_phase_accumulator[current_nios_dac])
										);
										
										for (current_dds_test_channel = 0; current_dds_test_channel < num_dac_channels; current_dds_test_channel++)
										begin : make_selected_test_dds_registered_signals
													  always @(posedge nios_dac_clk[current_nios_dac])
													  begin																										 
															   case (select_phase_accum_test_signal[current_nios_dac])
                                                               2'b00:  test_selected_data[current_nios_dac][`current_subrange(current_dds_test_channel)]    <=  test_dds_triangular_waveform_out[current_nios_dac][current_dds_test_channel];
                                                               2'b01:  test_selected_data[current_nios_dac][`current_subrange(current_dds_test_channel)]    <=  test_dds_phase_accumulator[current_nios_dac][current_dds_test_channel][TEST_SIGNAL_DDS_NUM_PHASE_BITS-1 -:ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS] ; 
                                                               2'b10:  test_selected_data[current_nios_dac][`current_subrange(current_dds_test_channel)]    <=  ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION ? sine_waveform_out[current_nios_dac][current_dds_test_channel] : 0;  
                                                               2'b11:  test_selected_data[current_nios_dac][`current_subrange(current_dds_test_channel)]    <=  ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION ? cosine_waveform_out[current_nios_dac][current_dds_test_channel] : 0;  
															   endcase																							
													  end											  											  
										  end
										  
										  always @(posedge nios_dac_clk[current_nios_dac])
										  begin
												test_selected_data[current_nios_dac][in_data_bits] <= 1'b1; //valid bit
										  end
						
						end
			end else
			
	endgenerate

	
	
   					  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 16;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = ENABLE_CONTROL_WISHBONE_INTERFACE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = ENABLE_STATUS_WISHBONE_INTERFACE ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 1;
			
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
			assign uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = CLKIN;
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
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS),
			 .USE_GENERIC_ATTRIBUTE_FOR_READ_LD(USE_GENERIC_ATTRIBUTE_FOR_READ_LD),
             .GENERIC_ATTRIBUTE_FOR_READ_LD(GENERIC_ATTRIBUTE_FOR_READ_LD),
			 .STATUS_WISHBONE_NUM_ADDRESS_BITS(STATUS_WISHBONE_NUM_ADDRESS_BITS),
             .CONTROL_WISHBONE_NUM_ADDRESS_BITS(CONTROL_WISHBONE_NUM_ADDRESS_BITS),
			 .WISHBONE_INTERFACE_IS_PART_OF_BRIDGE  (WISHBONE_INTERFACE_IS_PART_OF_BRIDGE ),
             .WISHBONE_CONTROL_BASE_ADDRESS        	(WISHBONE_CONTROL_BASE_ADDRESS        ),	 
             .WISHBONE_STATUS_BASE_ADDRESS         	(WISHBONE_STATUS_BASE_ADDRESS         )	 
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
	
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  DEFAULT_CHANNEL_TO_DAC0;
    assign uart_regfile_interface_pins.control_desc[1]               = "SelChanToDAC0";
    assign nios_dac_pins.select_channel_to_DAC0                      = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 16;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  DEFAULT_CHANNEL_TO_DAC1;
    assign uart_regfile_interface_pins.control_desc[2]               = "SelChanToDAC1";
    assign nios_dac_pins.select_channel_to_DAC1                    = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 16;		
	 

    assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  change_format_default;
    assign uart_regfile_interface_pins.control_desc[3]               = "Change_DAC_FMT";
    assign change_DAC_format                                         = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = 2;		
	  
	assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  Synchronize_Capture_Both_GP_FIFOs_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[4]               = "Sync_FIFO_Capt";
    assign Synchronize_Capture_Both_GP_FIFOs                     = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = 1;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[5]  =  0;
    assign uart_regfile_interface_pins.control_desc[5]               = "FIFOctrl0";
    assign out_port_from_the_GP_FIFO_0_Control                     = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = 8;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[6]  =  0;
    assign uart_regfile_interface_pins.control_desc[6]               = "FIFOctrl1";
    assign out_port_from_the_GP_FIFO_1_Control                     = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6]      = 8;		
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[7]  =  0;
    assign uart_regfile_interface_pins.control_desc[7]               = "DAC0_TESTDDS_PHI";
    assign test_dds_phi_inc_i[0]                     = uart_regfile_interface_pins.control[7];
    assign uart_regfile_interface_pins.control_regs_bitwidth[7]      = TEST_SIGNAL_DDS_NUM_PHASE_BITS;		
	
	 assign uart_regfile_interface_pins.control_regs_default_vals[8]  =  0;
    assign uart_regfile_interface_pins.control_desc[8]               = "DAC1_TESTDDS_PHI";
    assign test_dds_phi_inc_i[1]                     = uart_regfile_interface_pins.control[8];
    assign uart_regfile_interface_pins.control_regs_bitwidth[8]      = TEST_SIGNAL_DDS_NUM_PHASE_BITS;				
	
	 assign uart_regfile_interface_pins.control_regs_default_vals[9]  =  0;
    assign uart_regfile_interface_pins.control_desc[9]               = "test_signal_ctl0";
    assign {select_phase_accum_test_signal[0],  select_test_dds[0]}        = uart_regfile_interface_pins.control[9];
    assign uart_regfile_interface_pins.control_regs_bitwidth[9]      = 3;				
	
	 assign uart_regfile_interface_pins.control_regs_default_vals[10]  =  0;
    assign uart_regfile_interface_pins.control_desc[10]               = "test_signal_ctl1";
    assign {select_phase_accum_test_signal[1],  select_test_dds[1]}        = uart_regfile_interface_pins.control[10];
    assign uart_regfile_interface_pins.control_regs_bitwidth[10]      = 3;	
	 
	assign uart_regfile_interface_pins.status[0] = 32'h12345678;
	assign uart_regfile_interface_pins.status_desc[0]    ="StatusAlive";	
	
    assign uart_regfile_interface_pins.status[1] = {in_data_bits};
	assign uart_regfile_interface_pins.status_desc[1]    ="in_data_bits";
	
    assign uart_regfile_interface_pins.status[2] = {out_data_bits};
	assign uart_regfile_interface_pins.status_desc[2]    ="out_data_bits";
	
    assign uart_regfile_interface_pins.status[7] = {ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS};
	assign uart_regfile_interface_pins.status_desc[7]    ="num_words_bits";
		
    assign uart_regfile_interface_pins.status[8] = test_dds_triangular_waveform_out[0][0];
	assign uart_regfile_interface_pins.status_desc[8]    ="test_triang_0_0";
		
    assign uart_regfile_interface_pins.status[9] = test_dds_phase_accumulator[0][0];
	assign uart_regfile_interface_pins.status_desc[9]    ="test_phase_0_0";
	
	assign uart_regfile_interface_pins.status[10] = sine_waveform_out[0][0];
	assign uart_regfile_interface_pins.status_desc[10]    ="test_sine_0_0";
		
    assign uart_regfile_interface_pins.status[11] = cosine_waveform_out[0][0];
    assign uart_regfile_interface_pins.status_desc[11]    ="test_cosine_0_0";

	
 endmodule
 