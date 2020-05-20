
`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module uart_controlled_multi_nios_dacs
#(
parameter  [7:0] ENABLE_CONTROL_WISHBONE_INTERFACE = 1'b0,
parameter  [7:0] ENABLE_STATUS_WISHBONE_INTERFACE  = 1'b0,
parameter Synchronize_Capture_Both_GP_FIFOs_DEFAULT = 1,
parameter [0:0] COMPILE_TEST_SIGNAL_DDS = 0,
parameter [7:0] TEST_SIGNAL_DDS_NUM_PHASE_BITS = 24,
parameter TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD = {5'b0,1'b1,{(TEST_SIGNAL_DDS_NUM_PHASE_BITS-10){1'b0}},1'b1},
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
parameter UART_REGFILE_TYPE = uart_regfile_types::NIOS_MULTI_DAC_STANDALONE_REGFILE,
parameter [0:0]    IGNORE_TIMING_TO_READ_LD = 1'b0,
parameter [0:0] USE_GENERIC_ATTRIBUTE_FOR_READ_LD = 1'b0,
parameter GENERIC_ATTRIBUTE_FOR_READ_LD = "ERROR",
parameter change_format_default = 0,
parameter [0:0]  WISHBONE_INTERFACE_IS_PART_OF_BRIDGE = 1'b0,
parameter [31:0] WISHBONE_CONTROL_BASE_ADDRESS        = 0,
parameter [31:0] WISHBONE_STATUS_BASE_ADDRESS         = 0,
parameter [7:0] STATUS_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] CONTROL_WISHBONE_NUM_ADDRESS_BITS = 8,
parameter [7:0] NUM_OF_NIOS_DACS = 2,
parameter [0:0] ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION  = 0,
parameter [0:0] USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS = 1,
parameter [0:0] SUPPORT_INPUT_DESCRIPTIONS = 1,
parameter synchronizer_depth = 3
)
(
	input  CLKIN,
	input  RESET_FOR_CLKIN,
	
	multi_dac_interface nios_dac_pins,
	multi_data_acq_fifo_interface data_acq_fifo_interface,
	
	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	
    wishbone_interface status_wishbone_interface_pins,
    wishbone_interface control_wishbone_interface_pins,
	
    output logic [in_data_bits-1:0]  test_selected_data[NUM_OF_NIOS_DACS]
	
);
parameter ZERO_IN_ASCII = 48;

/*
integer ctrl_reg_cnt = 0;
function integer get_next_control_reg () 
   ctrl_reg_cnt++;
   return ctrl_reg_cnt;
endfunction
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Macro definitions  
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`define current_subrange(chan) ((chan)*out_data_bits+ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS-1):((chan)*out_data_bits)
`define current_ctrl_reg_num(x,y) ((((x)*5+1))+(y))
`define current_status_reg_num(x,y) (((x)*2+4) + (y))
`define current_desc_reg_num(x,y) ((`current_status_reg_num(NUM_OF_NIOS_DACS,0)+((x)*4)+(y)))

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	//     Wire and register definitions
	//
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////

	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire Synchronize_Capture_Both_GP_FIFOs;
	
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [in_data_bits-1:0] data_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] in_port_to_the_GP_FIFO_Flags[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  rdempty_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  rdfull_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  wrclk_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  wrempty_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  wrfull_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  wrreq_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
   	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  DAC_data_valid[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [NUM_OF_NIOS_DACS-1:0] out_port_from_the_GP_FIFO_Control[7:0];
	
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] q_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
     (* keep = 1, preserve = 1, altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) wire rdclk_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire rdreq_to_the_GP_FIFO[NUM_OF_NIOS_DACS];
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [num_words_bits-1:0] wrusedw_from_the_GP_FIFO[NUM_OF_NIOS_DACS];
	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain[NUM_OF_NIOS_DACS];
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only[NUM_OF_NIOS_DACS];	
	(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO_write_domain[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire change_DAC_format[NUM_OF_NIOS_DACS];
			
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits-1:0]  DAC_MUXED_OUT_raw[NUM_OF_NIOS_DACS]; 
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits:0]    DAC_MUXED_OUT_raw2[NUM_OF_NIOS_DACS]; 
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits:0]    DAC_MUXED_OUT[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [in_data_bits:0]    registered_selected_data[NUM_OF_NIOS_DACS]; 
	
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic       select_test_dds[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [1:0] select_test_dds_signal[NUM_OF_NIOS_DACS];
	    
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [TEST_SIGNAL_DDS_NUM_PHASE_BITS-1:0]	test_dds_phi_inc_i[NUM_OF_NIOS_DACS];
    (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic output_test_signal_as_unsigned[NUM_OF_NIOS_DACS];
	
	
	genvar current_subword;
	genvar current_nios_dac;
	generate
	
			if (COMPILE_TEST_SIGNAL_DDS)
			begin : generate_test_dds_signal
							 parallel_dds_test_signal_generation
							 #(
								.use_explicit_blockram(USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS),
								.TEST_SIGNAL_DDS_NUM_PHASE_BITS(TEST_SIGNAL_DDS_NUM_PHASE_BITS),
								.ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION(ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION),
								.NUM_NET_OUTPUT_BITS_PER_CHANNEL(ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS),
								.NUM_GROSS_OUTPUT_BITS_PER_CHANNEL(out_data_bits),
								.NUM_PARALLEL_CHANNELS_PER_TEST_CHANNEL(num_dac_channels),
								.TOTAL_OUTPUT_BITS(in_data_bits),
								.NUM_TEST_CHANNELS(NUM_OF_NIOS_DACS)
							  )
							  parallel_dds_test_signal_generation_inst 
							  (
								.clk(nios_dac_pins.selected_clk_to_dac),
								.generated_parallel_test_signal(test_selected_data),
								.dds_phase_word(test_dds_phi_inc_i),
								.select_test_signal(select_test_dds_signal),
								.output_unsigned_signal(output_test_signal_as_unsigned)
							  );
						
						  for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
						  begin : per_nios_dac								  
										  always @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
										  begin												
												   registered_selected_data[current_nios_dac] <= select_test_dds[current_nios_dac] ? {1'b1,test_selected_data[current_nios_dac]} :
        												                                        {nios_dac_pins.valid_to_dac[current_nios_dac],nios_dac_pins.selected_channel_to_dac[current_nios_dac]};
										  end						
						  end
			end else
			begin
			     for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
				 begin : per_nios_dac								  
									  always_ff @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
									  begin												
											   registered_selected_data[current_nios_dac] <= {nios_dac_pins.valid_to_dac[current_nios_dac],nios_dac_pins.selected_channel_to_dac[current_nios_dac]};
									  end						
				 end
			end	
	endgenerate


	//====================================================================================
   //
   //   Now connect GP FIFOs to DACs
   //
   //====================================================================================
       
    	generate
 		                 for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
						  begin : per_nios_dac	
							    /////////////////////////////////////////////////////////////////////////////////////////////////////////////
								//
								//      Clock crossing between control and fifo
								//
								/////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
								doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
								sync_out_Synchronize_Capture_Both_GP_FIFOs_to_FIFOs
								(
								.indata(Synchronize_Capture_Both_GP_FIFOs),
								.outdata(synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO_write_domain[current_nios_dac]),
								.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
								);
								                             								
								doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
								sync_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain
								(
								.indata(&out_port_from_the_GP_FIFO_Control[0][NUM_OF_NIOS_DACS-1:0]),
								.outdata(synced_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain[current_nios_dac]),
								.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
								);
								
								doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
								sync_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only
								(
								.indata(out_port_from_the_GP_FIFO_Control[0][current_nios_dac]),
								.outdata(synced_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only[current_nios_dac]),
								.clk(wrclk_to_the_GP_FIFO[current_nios_dac])
								);
										
								assign wrreq_to_the_GP_FIFO[current_nios_dac] = synced_Synchronize_Capture_Both_GP_FIFOs_to_FIFO_write_domain[current_nios_dac] ? (synced_out_port_from_the_All_GP_FIFO_Control_0_to_FIFO_write_domain[current_nios_dac] & DAC_data_valid[current_nios_dac] ): (DAC_data_valid[current_nios_dac] & synced_out_port_from_GP_FIFO_Control_0_to_this_FIFO_only[current_nios_dac]);
						        
								/////////////////////////////////////////////////////////////////////////////////////////////////////////////
								//
								//     FIFO Connection to interface
								//
								/////////////////////////////////////////////////////////////////////////////////////////////////////////////
							
								assign data_acq_fifo_interface.data [current_nios_dac]    =  data_to_the_GP_FIFO [current_nios_dac];
			                    assign data_acq_fifo_interface.rdclk[current_nios_dac]    =  rdclk_to_the_GP_FIFO[current_nios_dac];
			                    assign data_acq_fifo_interface.rdreq[current_nios_dac]    =  rdreq_to_the_GP_FIFO[current_nios_dac];
			                    assign data_acq_fifo_interface.wrclk[current_nios_dac]    =  wrclk_to_the_GP_FIFO[current_nios_dac];
			                    assign data_acq_fifo_interface.wrreq[current_nios_dac]    =  wrreq_to_the_GP_FIFO[current_nios_dac];
			                    assign q_from_the_GP_FIFO      [current_nios_dac]         =  data_acq_fifo_interface.q       [current_nios_dac];
			                    assign rdempty_from_the_GP_FIFO[current_nios_dac]         =  data_acq_fifo_interface.rdempty [current_nios_dac];
			                    assign rdfull_from_the_GP_FIFO [current_nios_dac]         =  data_acq_fifo_interface.rdfull  [current_nios_dac];
			                    assign wrempty_from_the_GP_FIFO[current_nios_dac]         =  data_acq_fifo_interface.wrempty [current_nios_dac];
			                    assign wrfull_from_the_GP_FIFO [current_nios_dac]         =  data_acq_fifo_interface.wrfull  [current_nios_dac];
			                    assign wrusedw_from_the_GP_FIFO[current_nios_dac]         =  data_acq_fifo_interface.wrusedw [current_nios_dac];

								assign rdreq_to_the_GP_FIFO[current_nios_dac] = out_port_from_the_GP_FIFO_Control[1][current_nios_dac];
								assign rdclk_to_the_GP_FIFO[current_nios_dac] = out_port_from_the_GP_FIFO_Control[4][current_nios_dac];
													  
						  
	                            assign in_port_to_the_GP_FIFO_Flags[current_nios_dac] = {
	                                                 3'b0,rdempty_from_the_GP_FIFO[current_nios_dac], 
	                                                 3'b0,rdfull_from_the_GP_FIFO[current_nios_dac], 
													 3'b0,wrempty_from_the_GP_FIFO[current_nios_dac], 
													 3'b0,wrfull_from_the_GP_FIFO[current_nios_dac], 
													 {{(16-num_words_bits){1'b0}},
													 wrusedw_from_the_GP_FIFO[current_nios_dac]}
													};
						  
						        assign data_to_the_GP_FIFO[current_nios_dac] = DAC_MUXED_OUT[current_nios_dac][in_data_bits-1:0];
	                            assign wrclk_to_the_GP_FIFO[current_nios_dac] = nios_dac_pins.selected_clk_to_dac[current_nios_dac];
	                            assign DAC_data_valid[current_nios_dac] = DAC_MUXED_OUT[current_nios_dac][in_data_bits];
						  
										for (current_subword = 0; current_subword < num_dac_channels; current_subword++)
										begin : change_to_signed_or_unsigned
												controlled_unsigned_to_signed_or_vice_versa
												#(
												.width(ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS)
												)
												change_encoding_dac
												(
												.in(registered_selected_data[current_nios_dac][`current_subrange(current_subword)]),
												.out(DAC_MUXED_OUT_raw[current_nios_dac][`current_subrange(current_subword)]),
												.change_format(change_DAC_format[current_nios_dac])
												);
										 end
										
										 always @(posedge nios_dac_pins.selected_clk_to_dac[current_nios_dac])
										 begin												
										       DAC_MUXED_OUT_raw2[current_nios_dac] <= {registered_selected_data[current_nios_dac][in_data_bits],DAC_MUXED_OUT_raw[current_nios_dac]};
										       DAC_MUXED_OUT[current_nios_dac] <=  DAC_MUXED_OUT_raw2[current_nios_dac];
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
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 1+NUM_OF_NIOS_DACS*5;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = SUPPORT_INPUT_DESCRIPTIONS ? (4+NUM_OF_NIOS_DACS*6) : (4+NUM_OF_NIOS_DACS*2);			
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
			
	assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  Synchronize_Capture_Both_GP_FIFOs_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[0]               = "Sync_FIFO_Capt";
    assign Synchronize_Capture_Both_GP_FIFOs                         = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 1;		
	 
	 generate	 
			  for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
			  begin : per_dac_ctrl_regs
							wire [7:0] char1 = ((current_nios_dac/10)+ZERO_IN_ASCII);
							wire [7:0] char2 = ((current_nios_dac % 10)+ZERO_IN_ASCII);

							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_nios_dac,0)]  =  DEFAULT_CHANNEL_TO_DAC0;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_nios_dac,0)]               = {"SelChanToDAC",char1,char2};
							assign nios_dac_pins.select_channel_to_dac[current_nios_dac]     = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_nios_dac,0)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_nios_dac,0)]      = 16;		
							  
							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_nios_dac,1)]  =  change_format_default;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_nios_dac,1)]               = {"ChangeDACFMT",char1,char2};
							assign change_DAC_format[current_nios_dac]                       = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_nios_dac,1)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_nios_dac,1)]      = 1;		
													  
							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_nios_dac,2)]  =  0;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_nios_dac,2)]               = {"FIFOctrl",char1,char2};						
							assign {out_port_from_the_GP_FIFO_Control[7][current_nios_dac],
									out_port_from_the_GP_FIFO_Control[6][current_nios_dac],
									out_port_from_the_GP_FIFO_Control[5][current_nios_dac],
									out_port_from_the_GP_FIFO_Control[4][current_nios_dac],
									out_port_from_the_GP_FIFO_Control[3][current_nios_dac],
									out_port_from_the_GP_FIFO_Control[2][current_nios_dac],
									out_port_from_the_GP_FIFO_Control[1][current_nios_dac],
									out_port_from_the_GP_FIFO_Control[0][current_nios_dac]}   = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_nios_dac,2)];								
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_nios_dac,2)]       = 8;		
							 
							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_nios_dac,3)]  =  TEST_SIGNAL_DDS_DEFAULT_PHASE_WORD;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_nios_dac,3)]               = {"DacTestDdsPhi",char1,char2};
							assign test_dds_phi_inc_i[current_nios_dac]                     = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_nios_dac,3)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_nios_dac,3)]      = TEST_SIGNAL_DDS_NUM_PHASE_BITS;		
							
							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_nios_dac,4)]  =  0;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_nios_dac,4)]               = {"TestSignalCtl",char1,char2};
							assign {output_test_signal_as_unsigned[current_nios_dac],select_test_dds_signal[current_nios_dac][1:0],  select_test_dds[current_nios_dac]}  = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_nios_dac,4)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_nios_dac,4)]      = 4;				
			end 
    endgenerate
		
		
	assign uart_regfile_interface_pins.status[0] = {nios_dac_pins.get_num_selection_bits(),in_data_bits};
	assign uart_regfile_interface_pins.status_desc[0]    ="in_data_bits";
	
    assign uart_regfile_interface_pins.status[1] = {nios_dac_pins.get_actual_num_selections(),out_data_bits};
	assign uart_regfile_interface_pins.status_desc[1]    ="out_data_bits";
	
    assign uart_regfile_interface_pins.status[2] = {ACTUAL_BITWIDTH_OF_SIGNALS_TO_NIOS_DACS,num_words_bits};
	assign uart_regfile_interface_pins.status_desc[2]    ="num_words_bits";
	 
    assign uart_regfile_interface_pins.status[3] = {COMPILE_TEST_SIGNAL_DDS,
	                                                ALLOW_SINE_COSINE_TEST_SIGNAL_GENERATION,
	                                                USE_EXPLICIT_BLOCKRAM_FOR_TEST_SIGNAL_DDS,
													NUM_OF_NIOS_DACS,
	                                                TEST_SIGNAL_DDS_NUM_PHASE_BITS};
	assign uart_regfile_interface_pins.status_desc[3]    ="TestDDSParams";
	
	generate
			  for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
			  begin : per_dac_status_regs
			        wire [7:0] char1 = ((current_nios_dac/10)+ZERO_IN_ASCII);
					wire [7:0] char2 = ((current_nios_dac % 10)+ZERO_IN_ASCII);
			  
			        
	                assign uart_regfile_interface_pins.status[`current_status_reg_num(current_nios_dac,0)] = in_port_to_the_GP_FIFO_Flags[current_nios_dac];
	                assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_nios_dac,0)]    = {"fifoFlags",char1,char2};
					
	              	assign uart_regfile_interface_pins.status[`current_status_reg_num(current_nios_dac,1)] = q_from_the_GP_FIFO[current_nios_dac];
	                assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_nios_dac,1)]    ={"fifoq",char1,char2};
		     end
	endgenerate

	generate
			 if (SUPPORT_INPUT_DESCRIPTIONS)
			 begin
			      for (current_nios_dac = 0; current_nios_dac < NUM_OF_NIOS_DACS; current_nios_dac++)
			      begin : per_dac_desc_status_regs
				         wire [7:0] char1 = ((current_nios_dac/10)+ZERO_IN_ASCII);
					     wire [7:0] char2 = ((current_nios_dac % 10)+ZERO_IN_ASCII);
					
						 assign uart_regfile_interface_pins.status[`current_desc_reg_num(current_nios_dac,0)] = nios_dac_pins.dac_descriptions[current_nios_dac][nios_dac_pins.select_channel_to_dac[current_nios_dac]][127 -: 32];
						 assign uart_regfile_interface_pins.status_desc[`current_desc_reg_num(current_nios_dac,0)]    ={"Chn",char1,char2,"Dsc_127_96"};
						 
						 assign uart_regfile_interface_pins.status[`current_desc_reg_num(current_nios_dac,1)] = nios_dac_pins.dac_descriptions[current_nios_dac][nios_dac_pins.select_channel_to_dac[current_nios_dac]][95 -: 32];
						 assign uart_regfile_interface_pins.status_desc[`current_desc_reg_num(current_nios_dac,1)]    ={"Chn",char1,char2,"Dsc_95_64"};
						 
						 assign uart_regfile_interface_pins.status[`current_desc_reg_num(current_nios_dac,2)] = nios_dac_pins.dac_descriptions[current_nios_dac][nios_dac_pins.select_channel_to_dac[current_nios_dac]][63 -: 32];
						 assign uart_regfile_interface_pins.status_desc[`current_desc_reg_num(current_nios_dac,2)]    ={"Chn",char1,char2,"Dsc_63_32"};
						 
						 assign uart_regfile_interface_pins.status[`current_desc_reg_num(current_nios_dac,3)] = nios_dac_pins.dac_descriptions[current_nios_dac][nios_dac_pins.select_channel_to_dac[current_nios_dac]][31 -: 32];
						 assign uart_regfile_interface_pins.status_desc[`current_desc_reg_num(current_nios_dac,3)]    ={"Chn",char1,char2,"Dsc_31_0"};
				 end
			 end
	 endgenerate

 endmodule
 `default_nettype wire
 