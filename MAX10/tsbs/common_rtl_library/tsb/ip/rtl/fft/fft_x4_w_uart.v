
`default_nettype none
`include "interface_defs.v"
`include "global_project_defines.v"
`include "utility_defines.v"
`include "fft_support_pkg.v"
`include "interface_defs.v"
`include "uart_regfile_types.v"

import fft_support_pkg::*;
import uart_regfile_types::*;

module fft_x4_w_uart
#(
parameter [0:0] COMPILE_TEST_SIGNALS = 1,
parameter [0:0] COMPILE_STREAM_SPECIFIC_STATUS_REGS = 1,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter transaction_counter_width = 32,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_fftx4"},
parameter UART_REGFILE_TYPE = uart_regfile_types::FFT_X4_UART_REGFILE,
parameter synchronizer_depth = 3,
parameter pipeline_match_delay_val,
parameter delay_val_for_sop_eop_valid,
parameter DEFAULT_PIPELINE_MATCH_DELAY_VAL    = 7,
parameter DEFAULT_DELAY_VAL_FOR_SOP_EOP_VALID = 32,
parameter NUM_STREAMS = 4,
parameter num_samples_in_parallel = 4,
parameter dds_num_phase_bits  = 24, 
parameter dds_num_output_bits = 16,
parameter fft_output_bits_per_component = 16,
parameter fft_input_bits_per_component = 14,
parameter fft_input_bit_padded_length_per_component = 16,
parameter num_output_bits_per_fixed_point_output = 16,
parameter FFT_LENGTH = 4096,
parameter FFTPTSIN_DEFAULT = FFT_LENGTH/num_samples_in_parallel,
parameter LOG2_FFT_LENGTH = $clog2(FFT_LENGTH),
parameter FFT_CTRL_DEFAULT = 2,
parameter [0:0] ASSIGN_AVST_OUTDATA_CLK = 1'b1,
parameter [3:0] input_bits_to_shift_left_for_bypass = 2,
parameter ENABLE_KEEPS = 0
)
(

	multiple_synced_st_streaming_interfaces avst_indata,
	multiple_2d_synced_st_streaming_interfaces jesd_adc_2d_avst_stream_to_external_memory,
	input reset,
	input clk,
 
    input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,

	output uart_tx,
	input  uart_rx,
	
    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output logic    [7:0] NUM_UARTS_HERE,
	output logic [15:0] connected_uart_primary,
	output logic [15:0] connected_uart_secondary
	
);
   
  
   	
function automatic logic [dds_num_phase_bits-1:0] get_initial_dds_value(integer channel, integer log2_N);
     return ((2**dds_num_phase_bits) - channel*(2**(dds_num_phase_bits-log2_N)));					 
endfunction

   
assign NUM_UARTS_HERE = 1;

logic fft_ready_override;
logic fft_ready_override_value;  
logic raw_fft_ready_override;
logic raw_fft_ready_override_value;
logic [31:0] sample_since_reset_count[num_samples_in_parallel];
logic [31:0] synced_sample_since_reset_count[num_samples_in_parallel];
logic [dds_num_phase_bits-1:0] phi_inc_i[num_samples_in_parallel];
//logic [dds_num_phase_bits-1:0] phi_inc_i_raw[num_samples_in_parallel];
logic [$clog2(pipeline_match_delay_val)-1:0] pipeline_delay;
logic [$clog2(delay_val_for_sop_eop_valid)-1:0] ctrl_delay;


logic synced_reset;
logic local_reset;
logic [10:0] fftpts_in;
logic [0:0] inverse;
logic bypass_fft;
logic synced_bypass_fft;
logic invert_bypass_imag;
logic synced_invert_bypass_imag;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))  //syncing is mainly for timing analysis, don't care about metastability
sync_reset_signal
(
.indata(local_reset | reset),
.outdata(synced_reset),
.clk(clk)
);
								
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))  //syncing is mainly for timing analysis, don't care about metastability
sync_bypass_fft
(
.indata(bypass_fft),
.outdata(synced_bypass_fft),
.clk(clk)
);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))  //syncing is mainly for timing analysis, don't care about metastability
sync_invert_bypass_imag
(
.indata(invert_bypass_imag),
.outdata(synced_invert_bypass_imag),
.clk(clk)
);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))  //syncing is mainly for timing analysis, don't care about metastability
sync_fft_ready_override
(
.indata(raw_fft_ready_override),
.outdata(fft_ready_override),
.clk(clk)
);	

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))  //syncing is mainly for timing analysis, don't care about metastability
sync_ffft_ready_override_value
(
.indata(raw_fft_ready_override_value),
.outdata(fft_ready_override_value),
.clk(clk)
);	

genvar i;
genvar j;
generate
         for (i = 0; i < NUM_STREAMS; i++)
		 begin  : per_stream_fft
		 	        multiple_synced_st_streaming_interfaces 
					#(
					.num_channels       (jesd_adc_2d_avst_stream_to_external_memory.get_num_channels()), 
                    .num_data_bits      (jesd_adc_2d_avst_stream_to_external_memory.get_num_data_bits()),
                    .num_bits_per_symbol(jesd_adc_2d_avst_stream_to_external_memory.get_num_bits_per_symbol())					
					)
					avst_outdata();
					
					fft_via_dit_x4 
					#(
					.pipeline_match_delay_val              (pipeline_match_delay_val              ),
					.delay_val_for_sop_eop_valid           (delay_val_for_sop_eop_valid           ),
					.numchannels                           (num_samples_in_parallel                           ),
					.dds_num_phase_bits                    (dds_num_phase_bits                    ), 
					.dds_num_output_bits                   (dds_num_output_bits                   ),
					.fft_output_bits_per_component         (fft_output_bits_per_component         ),
					.fft_input_bits_per_component          (fft_input_bits_per_component          ),
					.fft_input_bit_padded_length_per_component(fft_input_bit_padded_length_per_component),
					.num_output_bits_per_fixed_point_output(num_output_bits_per_fixed_point_output),
                    .stream_index (i),
					.input_bits_to_shift_left_for_bypass(input_bits_to_shift_left_for_bypass),
					.ENABLE_KEEPS(ENABLE_KEEPS)
					)
					fft_via_dit_x4_inst
					(
					.sample_since_reset_count(),
					.phi_inc_i,
					.avst_indata,
					.fft_complex_avst_outdata(avst_outdata),
					.fftpts_in,
					.inverse,
					.pipeline_delay,
					.ctrl_delay,
					.fft_ready_override,
                    .fft_ready_override_value,
					.select_float_bypass(synced_bypass_fft),
					.invert_bypass_imag(synced_invert_bypass_imag),
					.reset(synced_reset),
					.clk
					); 
			
				  for (j = 0; j < jesd_adc_2d_avst_stream_to_external_memory.get_num_channels(); j++)
				  begin : assign_2d_data
						assign jesd_adc_2d_avst_stream_to_external_memory.data[i][j]  = avst_outdata.data[j];   
				  end
				  
			   assign jesd_adc_2d_avst_stream_to_external_memory.valid[i] = avst_outdata.valid;			   
			   assign jesd_adc_2d_avst_stream_to_external_memory.eop  [i] = avst_outdata.eop  ;
			   assign jesd_adc_2d_avst_stream_to_external_memory.sop  [i] = avst_outdata.sop  ;
			   assign jesd_adc_2d_avst_stream_to_external_memory.error[i] = avst_outdata.error;
		end
endgenerate

generate
		if (ASSIGN_AVST_OUTDATA_CLK)
		begin
				assign jesd_adc_2d_avst_stream_to_external_memory.clk = clk;
		end
endgenerate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			        
			`define num_stream_specific_control_regs    (3)
			`define num_stream_specific_status_regs     (3)
			`define first_stream_specific_control_reg   (3)
			`define first_stream_specific_status_reg    (0)
			localparam ZERO_IN_ASCII = 48;
			
	        `define current_ctrl_reg_num(x,y) ((((x)*`num_stream_specific_control_regs+`first_stream_specific_control_reg))+(y))
		 	`define current_status_reg_num(x,y) (((x)*`num_stream_specific_status_regs+`first_stream_specific_status_reg) + (y))
					
					

		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = COMPILE_TEST_SIGNALS ? `current_ctrl_reg_num(num_samples_in_parallel-1,`num_stream_specific_control_regs-1) + 1 : `first_stream_specific_control_reg;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = COMPILE_STREAM_SPECIFIC_STATUS_REGS ?  `current_status_reg_num( num_samples_in_parallel-1, `num_stream_specific_status_regs - 1) + 1 : `first_stream_specific_status_reg;					
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
			assign uart_tx = uart_regfile_interface_pins.txd;
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
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS )
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

	assign uart_regfile_interface_pins.control_regs_default_vals[0]  = FFTPTSIN_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[0]               = "fftpts_in";
	assign fftpts_in  	                                 = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		

	assign uart_regfile_interface_pins.control_regs_default_vals[1]  = FFT_CTRL_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[1]               = "fft_ctrl";
	assign {invert_bypass_imag,raw_fft_ready_override,raw_fft_ready_override_value,local_reset,bypass_fft,inverse}  	                             = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 32;		
	
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  = 0;
    assign uart_regfile_interface_pins.control_desc[2]               = "connected_uart";
	assign {connected_uart_primary[15:0],connected_uart_secondary[15:0]} = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 32;		
	
	
	genvar current_data_stream;

		generate
	     			for (current_data_stream = 0; current_data_stream < num_samples_in_parallel; current_data_stream++)
					begin : make_per_channel_control_regs
							wire [7:0] stream_char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
							wire [7:0] stream_char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
						
							wire [39:0] index_string = {stream_char1,stream_char2};
							assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,0)]  = get_initial_dds_value(current_data_stream, LOG2_FFT_LENGTH);
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,0)]               = {"dds_phi_",index_string};
							assign phi_inc_i[current_data_stream]                                                          = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,0)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,0)]      = dds_num_phase_bits;																				
							
						    assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,1)]  = DEFAULT_PIPELINE_MATCH_DELAY_VAL;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,1)]               = {"pipe_delay",index_string};
							assign pipeline_delay[current_data_stream]                                                          = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,1)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,1)]      = $clog2(pipeline_match_delay_val);																				
				
					
						    assign uart_regfile_interface_pins.control_regs_default_vals[`current_ctrl_reg_num(current_data_stream,2)]  = DEFAULT_DELAY_VAL_FOR_SOP_EOP_VALID;
							assign uart_regfile_interface_pins.control_desc[`current_ctrl_reg_num(current_data_stream,2)]               = {"ctrl_delay",index_string};
							assign ctrl_delay[current_data_stream]                                                          = uart_regfile_interface_pins.control[`current_ctrl_reg_num(current_data_stream,2)];
							assign uart_regfile_interface_pins.control_regs_bitwidth[`current_ctrl_reg_num(current_data_stream,2)]      = $clog2(delay_val_for_sop_eop_valid);																				
				
					
				       /*
							my_multibit_clock_crosser_optimized_for_altera
							#(
							  .DATA_WIDTH(dds_num_phase_bits) 
							)
							mcp_parallel_data_test
							(
							   .in_clk(UART_REGFILE_CLK),
							   .in_valid(1'b1),
							   .in_data(phi_inc_i_raw[current_data_stream]),
							   .out_clk(clk),
							   .out_valid(),
							   .out_data(phi_inc_i[current_data_stream])
							 );	
                           */
			       end
	endgenerate
	
	
	generate
					if (COMPILE_STREAM_SPECIFIC_STATUS_REGS)
					begin
							for (current_data_stream = 0; current_data_stream < num_samples_in_parallel; current_data_stream++)
							begin : make_test_status_registers
							
							/*
									my_multibit_clock_crosser_optimized_for_altera
									#(
									  .DATA_WIDTH(32) 
									)
									mcp_sample_since_reset_count
									(
									   .in_clk(clk),
									   .in_valid(1'b1),
									   .in_data(sample_since_reset_count[current_data_stream]),
									   .out_clk(UART_REGFILE_CLK),
									   .out_valid(),
									   .out_data(synced_sample_since_reset_count[current_data_stream])
									 );	
									
							
									wire [7:0] char1 = ((current_data_stream/10)+ZERO_IN_ASCII);
									wire [7:0] char2 = ((current_data_stream % 10)+ZERO_IN_ASCII);
									
									//assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,0)] =	{synced_avst_in.valid,synced_avst_in.data[current_data_stream]};
									//assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,0)] =  {"avstinandvalid",char1,char2};
									
									//assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,1)] =	{synced_avst_out.valid,synced_avst_out.data[current_data_stream]};
									//assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,1)] =  {"avstoutandvalid",char1,char2};
									
									assign uart_regfile_interface_pins.status[`current_status_reg_num(current_data_stream,2)] =	{synced_sample_since_reset_count[current_data_stream]};
									assign uart_regfile_interface_pins.status_desc[`current_status_reg_num(current_data_stream,2)] =  {"sample_num",char1,char2};
									*/
							end
					end
	endgenerate
	
 endmodule

`default_nettype wire
