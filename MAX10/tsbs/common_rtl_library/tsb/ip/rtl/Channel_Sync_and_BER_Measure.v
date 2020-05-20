`timescale 1ns / 1ps
`default_nettype none

module Channel_Sync_and_BER_Measure	
#(
        parameter NUM_ADC_CHANNELS_PER_FMC = 24,
        parameter ADC_BITWIDTH             = 12,
		parameter NUM_OF_BITS_IN_CLOCK_DIVIDER_COUNTER = 16,
		parameter BERC_STATE_MACHINE_CLOCK_SPEED_IN_HZ = 100000000,
		parameter UART_BAUD_RATE_IN_HZ = 115200,
		//========================================================================
		//
		// BERC Parameters
		//
		//
		
	
		parameter input_lvds_adc_width = ADC_BITWIDTH;
		parameter num_of_lvds_adc_frames_in_one_BERC_frame = 6;
		parameter Parallel_BERC_input_width = input_lvds_adc_width*num_of_lvds_adc_frames_in_one_BERC_frame; 
		parameter log2_Parallel_BERC_input_width = Parallel_BERC_input_width; //overestimate

		parameter default_offset_of_BERC_error_measurment = 0;
		parameter Compile_BERC_Dual_Corr = 0;
        parameter Parallel_BERC_number_of_inwidths_in_corr_length = 2,
        
		parameter [15:0] BERC_corr_reg_length = Parallel_BERC_number_of_inwidths_in_corr_length*Parallel_BERC_input_width,
		parameter BERC_corr_count_bits = 8,
		parameter BERC_bit_count_reg_width = 48, 
		parameter BERC_error_counter_width = 48,
		parameter [47:0] BERC_bits_to_count_default = 48'd10000, 
		parameter [47:0] BERC_initial_throwaway_limit_default = BERC_bits_to_count_default/8;
		parameter [31:0] BERC_Gone_Into_Lock_Threshold_default = (Parallel_BERC_number_of_inwidths_in_corr_length-1)*Parallel_BERC_input_width*14/16,
		parameter [31:0] BERC_Gone_Out_of_Lock_Threshold_default = (Parallel_BERC_number_of_inwidths_in_corr_length-1)*Parallel_BERC_input_width*11/16,
		
		parameter [7:0] Frame_Delay_to_Aux_Corr = 0,
		parameter [7:0] Frame_Delay_to_Aux_Corr_Delay_Resolution = 8,
		parameter [7:0] aux_corr_log2_num_of_extract_taps = 4,
		parameter DEFAULT_TRANSPOSE_INPUT_SEQUENCE = 0,
		parameter DEFAULT_TRANSPOSE_REFSEQ = 0,
		parameter Data_BERC_DEFAULT_CHANNEL = 0,
		parameter Frame_BERC_DEFAULT_CHANNEL = 21,
		parameter USE_MINIMALIST_REGFILES             = 0,
		parameter USE_MINIMALIST_REGFILE_DESCRIPTIONS = 0,
		
			//////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		//    Dual Port RAM Parameters
		//
		//////////////////////////////////////////////////////////////////////////////////////////////////////
		
		
		// PATGEN RAM params
		parameter [31:0] DUAL_PORT_PATTERN_RAM_ADDR_WIDTH = 11,
      parameter [31:0] DUAL_PORT_PATTERN_RAM_DATA_WIDTH = 32,
		
		
		//Input Signal Acq FIFO params
	    parameter [15:0] Input_DATA_CAPTURE_FIFO_WIDTH = 32,
	    parameter [15:0] Input_DATA_CAPTURE_FIFO_NUMBITS_ADDR_COUNT = 13,
		
		//Input Signal Acq FIFO params
	    parameter [15:0] Output_DATA_CAPTURE_FIFO_WIDTH = 16,
	    parameter [15:0] Output_DATA_CAPTURE_FIFO_NUMBITS_ADDR_COUNT = 12,
		
		//Input Signal Acq FIFO params
	    parameter [15:0] Corr_DATA_CAPTURE_FIFO_WIDTH = 16,
	    parameter [15:0] Corr_DATA_CAPTURE_FIFO_NUMBITS_ADDR_COUNT = 12,
		
		
	    //GP FIFO FIFO params	
	    parameter [15:0] GP_FIFO_CAPTURE_FIFO_WIDTH              = 16,
	    parameter [15:0] GP_FIFO_CAPTURE_FIFO_NUMBITS_ADDR_COUNT = 12,	
		
		parameter Frame_BERC_Base_Pattern_DEFAULT = 12'hFC0,
		parameter Data_BERC_Base_Pattern_DEFAULT = 12'hF20	
)
(
		////////////////////	Clock Input	 	////////////////////	 
		uart_state_machine_clock,						//	50 MHz
		


        data_to_the_Input_Signal_Capture_FIFO,     
		data_to_the_Output_Signal_Capture_FIFO,      
		wrclk_to_the_Input_Signal_Capture_FIFO,      
		wrclk_to_the_Output_Signal_Capture_FIFO,
        //////////////////////////////////////////////////////////////////////////////////////////////////////
        //
        //    Dual Port RAM Interface
        //
        //////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
        ///////////// PATGEN RAM  ////////////////////
        
        addr_to_patgen_ram,
        patgen_ram_data,
        patgen_ram_clock,
        
        addr_to_BERC_patgen_ram,
        BERC_patgen_ram_data,
        BERC_patgen_ram_clock,
		
		berc_state_machine_clk,
			
		
		input_frame_lvds_adc_data,
		deframed_adc_data,
		recovered_adc_clk,
		BERC_regfile_rxd,
		BERC_regfile_txd,
		Misc_Ctrl_rxd,
		Misc_Ctrl_txd,
		request_adc_realign,
		BERC2_regfile_rxd,
		BERC2_regfile_txd,
		choose_alternate_deframing_method,
		chosen_frame_channel_index,
		frame_offset_select,
		card_name,
		FIRST_UART_NUM_SECONDARY_UARTS,
		FIRST_UART_ADDRESS_OF_THIS_UART,
		FIRST_UART_IS_SECONDARY_UART 
);


import uart_regfile_types::*;

`define zero_pad(width,signal)  {{((width)-$size(signal)){1'b0}},(signal)}
//`include "MPSK_receiver_basedef.v"
//`include "character_constant_defs.v"

	function automatic int log2 (input int n);
						if (n <=1) return 1; // abort function
						log2 = 0;
						while (n > 1) begin
						n = n/2;
						log2++;
						end
						endfunction
						
						
 //===========================================================================
// PORT declarations
//===========================================================================


  input                                       choose_alternate_deframing_method;
 output [$clog2(NUM_ADC_CHANNELS_PER_FMC)-1:0] chosen_frame_channel_index;
 output [$clog2(ADC_BITWIDTH)-1:0]             frame_offset_select;
 
 input [31:0] card_name;
wire [input_lvds_adc_width-1:0] Data_base_pattern_to_output_for_atrophied_generation;
wire [input_lvds_adc_width-1:0] Frame_base_pattern_to_output_for_atrophied_generation;
(* keep = 1, preserve = 1 *) wire [Parallel_BERC_input_width-1:0] Data_pattern_to_output_for_atrophied_generation;
(* keep = 1, preserve = 1 *) wire [Parallel_BERC_input_width-1:0] Frame_pattern_to_output_for_atrophied_generation;
 assign Data_pattern_to_output_for_atrophied_generation = {num_of_lvds_adc_frames_in_one_BERC_frame{Data_base_pattern_to_output_for_atrophied_generation}};
 assign Frame_pattern_to_output_for_atrophied_generation = {num_of_lvds_adc_frames_in_one_BERC_frame{Frame_base_pattern_to_output_for_atrophied_generation}};

input wire [input_lvds_adc_width-1:0]      input_frame_lvds_adc_data[NUM_ADC_CHANNELS_PER_FMC-1:0];
input wire [input_lvds_adc_width-1:0]      deframed_adc_data[NUM_ADC_CHANNELS_PER_FMC-1:0];
input wire recovered_adc_clk;
input wire BERC_regfile_rxd;
output wire BERC_regfile_txd;
input  wire BERC2_regfile_rxd;
output wire BERC2_regfile_txd;
input wire Misc_Ctrl_rxd;
output wire Misc_Ctrl_txd;
input wire [7:0] FIRST_UART_NUM_SECONDARY_UARTS;
input wire [7:0] FIRST_UART_ADDRESS_OF_THIS_UART;
input wire       FIRST_UART_IS_SECONDARY_UART;
output request_adc_realign;
wire request_adc_realign_raw;
////////////////////////	Clock Input	 	////////////////////////
input			uart_state_machine_clock;				//	50 MHz
                 //////////////////////////////////////////////////////////////////////////////////////////////////////
					//
					//    Dual Port RAM Interface
					//
					//////////////////////////////////////////////////////////////////////////////////////////////////////
					
	
	                ///////////// PATGEN RAM  ////////////////////
					
					output [DUAL_PORT_PATTERN_RAM_ADDR_WIDTH-1:0] addr_to_patgen_ram;
					input  [DUAL_PORT_PATTERN_RAM_DATA_WIDTH-1:0] patgen_ram_data;
					output patgen_ram_clock;
					
					///////////// BERC PATGEN RAM  ////////////////////
					output [DUAL_PORT_PATTERN_RAM_ADDR_WIDTH-1:0] addr_to_BERC_patgen_ram;
					input  [DUAL_PORT_PATTERN_RAM_DATA_WIDTH-1:0] BERC_patgen_ram_data;
					output BERC_patgen_ram_clock;
				

                    ///////////// Signal Acqusition FIFOS ///////////////
					output [Input_DATA_CAPTURE_FIFO_WIDTH-1:0] data_to_the_Input_Signal_Capture_FIFO;      
					output [Output_DATA_CAPTURE_FIFO_WIDTH-1:0] data_to_the_Output_Signal_Capture_FIFO;      
					output wrclk_to_the_Input_Signal_Capture_FIFO;      
					output wrclk_to_the_Output_Signal_Capture_FIFO;     


///////////////////////////////////////////////////////////////////
//=============================================================================
// DAC declarations
//=============================================================================
    	


input wire berc_state_machine_clk;

///////////////////////////////////////////////////////////////////
//=============================================================================
// REG/WIRE declarations
//=============================================================================



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  TX Bit Pattern Generation
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

wire [DUAL_PORT_PATTERN_RAM_ADDR_WIDTH-1:0] patgen_ram_addr_min, 
                                            patgen_ram_addr_max;
wire patgen_ram_serial_data_out;
wire [31:0] patgen_ram_current_bit_count;
wire patgen_ram_reverse_bit_shift_order;
	

//======================================================================================
//
//      BER Detection Circuit
//
//

	
	
(* keep = 1, preserve = 1 *) wire BERC_ref_data_clk;
   
(* keep = 1, preserve = 1 *)  wire BERC_patgen_ram_reverse_partial_order;
(* keep = 1, preserve = 1 *)  wire BERC_patgen_ram_reverse_output_bit_order;
(* keep = 1, preserve = 1 *)  wire [31:0] BERC_patgen_ram_current_partial_count, BERC_patgen_ram_current_partial_index;
(* keep = 1, preserve = 1 *)  wire [Parallel_BERC_input_width-1:0] BERC_patgen_ram_data_out_to_BERC;

wire [13:0] external_dac_data0;
wire external_dac_clk0;

wire [13:0] external_dac_data1;
wire external_dac_clk1;

///////////////////////////////////////////////////////////////////
//=============================================================================
// REG/WIRE declarations
//=============================================================================


        wire BERC2_request_input_bit_slip;
			 wire [Input_DATA_CAPTURE_FIFO_WIDTH-1:0] BERC2_data_to_the_Input_Signal_Capture_FIFO;      
			 wire [Output_DATA_CAPTURE_FIFO_WIDTH-1:0] BERC2_data_to_the_Output_Signal_Capture_FIFO;      
		wire BERC2_wrclk_to_the_Output_Signal_Capture_FIFO;


			
			parameter misc_ctrl_desc_numbytes        = 16;
	    	parameter misc_ctrl_desc_width           = 8*misc_ctrl_desc_numbytes;
			parameter misc_ctrl_data_numbytes        = 4;
			parameter misc_ctrl_data_width           = 8*misc_ctrl_data_numbytes;
			parameter num_of_misc_ctrl_control_regs  =  9;
			parameter num_of_misc_ctrl_status_regs   =  8;
			
			wire [misc_ctrl_data_width-1:0] misc_ctrl_control_regs_default_vals[num_of_misc_ctrl_control_regs-1:0];
			wire [misc_ctrl_data_width-1:0] misc_ctrl_control_regs[num_of_misc_ctrl_control_regs-1:0];
			wire [misc_ctrl_data_width-1:0] misc_ctrl_control_status[num_of_misc_ctrl_status_regs-1:0];
			wire [misc_ctrl_desc_width-1:0] misc_ctrl_control_desc[num_of_misc_ctrl_control_regs-1:0];
			wire [misc_ctrl_desc_width-1:0] misc_ctrl_status_desc [num_of_misc_ctrl_status_regs-1:0];
		
    		wire misc_ctrl_control_rd_error;
	    	wire misc_ctrl_control_async_reset = 1'b0;
			wire misc_ctrl_control_wr_error;
			wire misc_ctrl_control_transaction_error;
			    				
			wire [3:0] misc_ctrl_main_sm;
			wire [2:0] misc_ctrl_tx_sm;
			wire [7:0] misc_ctrl_command_count;
						
			assign misc_ctrl_control_status[0] = 32'h48356735;
			
			assign   misc_ctrl_control_status[1] =  BERC2_request_input_bit_slip                ;
			assign   misc_ctrl_control_status[2] =  BERC2_data_to_the_Input_Signal_Capture_FIFO ;
			assign   misc_ctrl_control_status[3] =  BERC2_data_to_the_Output_Signal_Capture_FIFO;   
			assign   misc_ctrl_control_status[4] =  BERC2_wrclk_to_the_Output_Signal_Capture_FIFO;
					
	         assign misc_ctrl_control_desc[4] = "PatternCtrl";
	         assign misc_ctrl_control_regs_default_vals[4] =  0;
	         
             assign BERC_patgen_ram_reverse_partial_order =  misc_ctrl_control_regs[4][12];
             assign BERC_patgen_ram_reverse_output_bit_order =  misc_ctrl_control_regs[4][16];
	          
	         assign misc_ctrl_control_desc[5] = "PatgenMin";
	         assign misc_ctrl_control_regs_default_vals[5] =  0;
             assign patgen_ram_addr_min =  misc_ctrl_control_regs[5];
	         	 
	         assign misc_ctrl_control_desc[6] = "PatgenMax";
	         assign misc_ctrl_control_regs_default_vals[6] =  0;
             assign patgen_ram_addr_max =  misc_ctrl_control_regs[6];
      
	         assign Data_base_pattern_to_output_for_atrophied_generation = misc_ctrl_control_regs[7];
             assign misc_ctrl_control_desc[7] = "DataBasePattern";
             assign misc_ctrl_control_regs_default_vals[7]  =  Data_BERC_Base_Pattern_DEFAULT;
     
	         assign Frame_base_pattern_to_output_for_atrophied_generation = misc_ctrl_control_regs[8];
             assign misc_ctrl_control_desc[8] = "FrmBasePattern";
             assign misc_ctrl_control_regs_default_vals[8]  =  Frame_BERC_Base_Pattern_DEFAULT;
     
	
		     uart_controlled_register_file_ver3
		     #( 
		       .NUM_OF_CONTROL_REGS(num_of_misc_ctrl_control_regs),
		       .NUM_OF_STATUS_REGS(num_of_misc_ctrl_status_regs),
			   .DESC_WIDTH_IN_BYTES  (misc_ctrl_desc_numbytes),
			   .DATA_WIDTH_IN_BYTES  (misc_ctrl_data_numbytes),
		       .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
		       .CONTROL_REGS_DEFAULT_VAL         (0),
		       .CLOCK_SPEED_IN_HZ(BERC_STATE_MACHINE_CLOCK_SPEED_IN_HZ),
                .UART_BAUD_RATE_IN_HZ(UART_BAUD_RATE_IN_HZ)
		     )
		     misc_ctrl_uart_register_file
		     (	
 	          .DISPLAY_NAME({card_name,"MscBERCStrtx"}),
		      .CLK(berc_state_machine_clk),
		      .REG_ACTIVE_HIGH_ASYNC_RESET(misc_ctrl_control_async_reset),
		      .CONTROL          (misc_ctrl_control_regs),
 	  		  .CONTROL_DESC     (misc_ctrl_control_desc),
		      .STATUS           (misc_ctrl_control_status),
		      .CONTROL_INIT_VAL (misc_ctrl_control_regs_default_vals),
		      .TRANSACTION_ERROR(misc_ctrl_control_transaction_error),
		      .WR_ERROR(misc_ctrl_control_wr_error),
		      .RD_ERROR(misc_ctrl_control_rd_error),
			  .USER_TYPE(uart_regfile_types::GENERIC_UART_REGFILE),
		      .NUM_SECONDARY_UARTS (FIRST_UART_NUM_SECONDARY_UARTS ),
              .ADDRESS_OF_THIS_UART(FIRST_UART_ADDRESS_OF_THIS_UART),
              .IS_SECONDARY_UART   (FIRST_UART_IS_SECONDARY_UART   ),	
		      //UART
		      .uart_active_high_async_reset(1'b0),
		      .rxd(Misc_Ctrl_rxd),
		      .txd(Misc_Ctrl_txd),
		      
		      //UART DEBUG
		      .main_sm               (misc_ctrl_main_sm),
		      .tx_sm                 (misc_ctrl_tx_sm),
		      .command_count         (misc_ctrl_command_count)
		       
		     );
			
			

//======================================================================================
//
//      BER Detection Circuits
//
//


get_new_value_from_ram_and_shift_out_multibit
 #( 
 .addr_width(DUAL_PORT_PATTERN_RAM_ADDR_WIDTH), 
 .data_width(DUAL_PORT_PATTERN_RAM_DATA_WIDTH),
 .log2_datawidth(log2(DUAL_PORT_PATTERN_RAM_DATA_WIDTH)),
 .outwidth(Parallel_BERC_input_width)
 )
get_new_value_from_ram_and_shift_out_multibit_inst
 (
 .addr_out(addr_to_BERC_patgen_ram),
 .addr_min(patgen_ram_addr_min),
 .addr_max(patgen_ram_addr_max),
 .out_clk_to_ram(BERC_patgen_ram_clock),
 .in_clk(BERC_ref_data_clk),
 .current_partial_count(BERC_patgen_ram_current_partial_count),
 .current_partial_index(BERC_patgen_ram_current_partial_index),
 .data_from_ram(BERC_patgen_ram_data),
 .data_out(BERC_patgen_ram_data_out_to_BERC),
 .reset_n(1'b1),
 .reverse_partial_order(BERC_patgen_ram_reverse_partial_order),
.reverse_output_bit_order(BERC_patgen_ram_reverse_output_bit_order)
  );
	
	
	
BERC_with_uart_regfile
#(
.BERC_bits_to_count_default(BERC_bits_to_count_default), 
.frame_width(input_lvds_adc_width),
.Parallel_BERC_input_width(Parallel_BERC_input_width),
.number_of_inwidths_in_corr_length(Parallel_BERC_number_of_inwidths_in_corr_length),
.corr_count_bits(BERC_corr_count_bits),
.bit_count_reg_width(BERC_bit_count_reg_width),
.CLOCK_SPEED_IN_HZ(BERC_STATE_MACHINE_CLOCK_SPEED_IN_HZ),
.UART_BAUD_RATE_IN_HZ(UART_BAUD_RATE_IN_HZ),
.Output_DATA_CAPTURE_FIFO_WIDTH(Output_DATA_CAPTURE_FIFO_WIDTH),
.Num_of_input_channels(NUM_ADC_CHANNELS_PER_FMC),
.Default_Channel      (Frame_BERC_DEFAULT_CHANNEL),
.transpose_refseq_default                            (DEFAULT_TRANSPOSE_REFSEQ),
.transpose_inseq_default                             (DEFAULT_TRANSPOSE_INPUT_SEQUENCE),
.try_align_default                                   (1),
.ref_data_source_default                             (0),
.frame_wait_between_aligns_default                   (15)		      
)
BERC1_with_uart_regfile_inst
( 
.DISPLAY_NAME ({card_name,"_Frm_Sync"}),
 .sm_clk(berc_state_machine_clk),
 .frame_in_clk(recovered_adc_clk),
 //.frame_in_data(input_frame_lvds_adc_data),
 .frame_in_data(deframed_adc_data),
 .request_adc_realign(request_adc_realign_raw),
 .data_to_the_Output_Signal_Capture_FIFO(data_to_the_Output_Signal_Capture_FIFO),
 .wrclk_to_the_Output_Signal_Capture_FIFO(wrclk_to_the_Output_Signal_Capture_FIFO),
 .external_ref_sequence_from_pattern_RAM    (BERC_patgen_ram_data_out_to_BERC    ),
 .pattern_to_output_for_atrophied_generation(Frame_pattern_to_output_for_atrophied_generation),
 .info_only_base_frame_pattern_to_output_for_atrophied_generation(Frame_base_pattern_to_output_for_atrophied_generation),
 .frame_select_offset(frame_offset_select),
 .chosen_frame_channel_index(chosen_frame_channel_index),
 .disable_realign_adc_request(choose_alternate_deframing_method),
 .rxd(BERC_regfile_rxd),
 .txd(BERC_regfile_txd),
 .NUM_SECONDARY_UARTS(0),
 .ADDRESS_OF_THIS_UART(FIRST_UART_ADDRESS_OF_THIS_UART+1),
 .IS_SECONDARY_UART(1)
 
);
	
BERC_with_uart_regfile
#(
.BERC_bits_to_count_default(BERC_bits_to_count_default), 
.frame_width(input_lvds_adc_width),
.Parallel_BERC_input_width(Parallel_BERC_input_width),
.number_of_inwidths_in_corr_length(Parallel_BERC_number_of_inwidths_in_corr_length),
.corr_count_bits(BERC_corr_count_bits),
.bit_count_reg_width(BERC_bit_count_reg_width),
.CLOCK_SPEED_IN_HZ(BERC_STATE_MACHINE_CLOCK_SPEED_IN_HZ),
.UART_BAUD_RATE_IN_HZ(UART_BAUD_RATE_IN_HZ),
.Output_DATA_CAPTURE_FIFO_WIDTH(Output_DATA_CAPTURE_FIFO_WIDTH),
.Num_of_input_channels(NUM_ADC_CHANNELS_PER_FMC),
.Default_Channel      (Data_BERC_DEFAULT_CHANNEL),
.transpose_refseq_default                            (DEFAULT_TRANSPOSE_REFSEQ),
.transpose_inseq_default                             (DEFAULT_TRANSPOSE_INPUT_SEQUENCE),
.try_align_default                                   (0),
.ref_data_source_default                             (0),
.frame_wait_between_aligns_default                   (15)
)
BERC2_with_uart_regfile_inst
( 
.DISPLAY_NAME ({card_name,"_Data_Meas"}),
 .sm_clk(berc_state_machine_clk),
 .frame_in_clk(recovered_adc_clk),
 .frame_in_data(deframed_adc_data),
 .request_adc_realign(BERC2_request_input_bit_slip),
 .data_to_the_Output_Signal_Capture_FIFO(BERC2_data_to_the_Output_Signal_Capture_FIFO),
 .wrclk_to_the_Output_Signal_Capture_FIFO(BERC2_wrclk_to_the_Output_Signal_Capture_FIFO),
 .external_ref_sequence_from_pattern_RAM    (BERC_patgen_ram_data_out_to_BERC    ),
 .pattern_to_output_for_atrophied_generation(Data_pattern_to_output_for_atrophied_generation),
 .info_only_base_frame_pattern_to_output_for_atrophied_generation(Data_base_pattern_to_output_for_atrophied_generation),
 .disable_realign_adc_request(0),
 .rxd(BERC2_regfile_rxd),
 .txd(BERC2_regfile_txd),
 .NUM_SECONDARY_UARTS(0),
 .ADDRESS_OF_THIS_UART(FIRST_UART_ADDRESS_OF_THIS_UART+2),
 .IS_SECONDARY_UART(1)	 
);
	

endmodule
`default_nettype wire
