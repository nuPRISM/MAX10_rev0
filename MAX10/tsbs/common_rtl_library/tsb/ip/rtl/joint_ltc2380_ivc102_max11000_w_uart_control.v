`default_nettype none

`ifndef JOINT_LTC2380_IVC102_MAX11000_W_UART_CONTROL_KEEP
`define JOINT_LTC2380_IVC102_MAX11000_W_UART_CONTROL_KEEP (* keep = 1, preserve = 1 *)
`endif

module joint_ltc2380_ivc102_max11000_w_uart_control
#(
parameter device_family = "Cylcone III", 
parameter num_adcs = 2,
parameter counter_numbits = 32,
parameter adc_numbits = 24,
parameter max11000_adc_numbits = 24,
parameter max11000_actual_adc_numbits = 16,
parameter current_FMC = 1,
parameter NUM_UNIFIED_DATA_BITS = 128,

//UART definitions
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 1000000,
parameter FSM_CLOCK_FREQ = 100000000,
parameter DEFAULT_RELAY_SETTINGS = 5'b11100,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_102mx11"},
//parameter UART_REGFILE_TYPE = uart_regfile_types::JOINT_LTC2380_IVC102_MAX11000_UART_REGFILE,
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
parameter DEFAULT_ZC_Ignore_Threshold = 1000,
parameter [7:0] num_adc_averager_shift_bits = 4,
parameter [7:0] DEFAULT_AVERAGER_SHIFT = 8,
parameter [7:0] averager_clk_count_num_bits   = (2**num_adc_averager_shift_bits)+1,
parameter [averager_clk_count_num_bits-1:0] DEFAULT_AVERAGER_M = 32'h7F,
parameter [31:0] DEFAULT_SCALING_ADC0  = 32'h3f800000, //1.0
parameter [31:0] DEFAULT_SCALING_POSITION0  = 32'h3f800000, //1.0
parameter [31:0] DEFAULT_SCALING_POSITION1  = 32'h3f800000, //1.0
parameter [31:0] DEFAULT_OFFSET_ADC0   = 0,
parameter [31:0] DEFAULT_SCALING_ADC1  = 32'h3f800000, //1.0
parameter [31:0] DEFAULT_OFFSET_ADC1   = 0,
parameter [31:0] NUM_BITS_MAX11100_COUNTER   = 16,
parameter [31:0] MAX11100_SCK_PULSE_WITH_IN_CLOCKS_DEFAULT   = 16,
parameter DEFAULT_ADC_OVERFLOW_THRESHOLD  = {1'b0,{(adc_numbits-10){1'b1}},1'b0,8'b0},
parameter DEFAULT_ADC_UNDERFLOW_THRESHOLD = {1'b1,{(adc_numbits-2){1'b0}},1'b1},
parameter DEFAULT_EXT_TRIGGER_EMULATOR_OSC_DIV = 32'h10000,
parameter [0:0]    DISABLE_ERROR_MONITORING = 1'b0,
parameter synchronizer_depth = 3,
parameter DEFAULT_INVERT_EXTERNAL_TRIGGER = 2'b10,
parameter ENABLE_KEEPS = 0
)
(
			//system clk
			input   clk_sm,
			output  adc_clk,
			output  [adc_numbits-1:0] adc_data[num_adcs],
			output  [max11000_adc_numbits-1:0] max11000_adc_data[num_adcs],
			output logic [num_adcs-1:0] averaged_adc_clk,
            output logic [adc_numbits-1:0] averaged_adc[num_adcs],
            output logic sel_ttl_to_optical_out,
            output logic sel_ttl_to_ttl_out,

			output [NUM_UNIFIED_DATA_BITS-1:0] unified_data,

			output unified_valid,
			output unified_clk,
			input  logic external_trigger,
			input  logic optical_external_trigger,
			input  logic gate_a,
			input  logic gate_b_or_test_pulse,
			output logic optical_external_trigger_copy_out,
			output logic external_trigger_copy_out,
            output logic gate_copy_out,
			 ltc2380_interface ltc2380_interface_pins,
			 ltc2380_interface max11000_interface_pins,
             output  logic drive_cal_test, select_internal_cal_test, drive_rly_cnt, cal_test,rly_cnt,
			 input logic over_temp,
			 input zero_cross,
			 output ldo_en,
			 input pwr_good,
			 input reset_registers_to_default_values,
			 input ignore_crc_value_for_debugging,
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
logic max_11000_finish;
logic [counter_numbits-1:0]  integration_time;
logic [counter_numbits-1:0]  pre_integration_reset_wait_time;
logic [31:0]  trigger_freq_div;
logic [counter_numbits-1:0]  reset_time;
logic [counter_numbits-1:0]  hold_time;

reg   [counter_numbits-1:0]   adc_conversion_counter = 0;
reg   [counter_numbits-1:0]   max_11000_adc_conversion_counter = 0;

logic [counter_numbits-1:0]  aux_counter;
logic signed [adc_numbits -1:0] read_data[num_adcs];
logic signed [max11000_adc_numbits -1:0] max11000_read_data[num_adcs];
logic signed [max11000_adc_numbits -1:0] max11000_read_data_raw[num_adcs];
logic signed [adc_numbits -1:0] pre_integration_read_data[num_adcs];
logic signed [adc_numbits -1:0] pre_integration_read_data_raw[num_adcs];
logic signed [adc_numbits -1:0] corrected_adc_data[num_adcs];
logic signed [adc_numbits -1:0] raw_corrected_adc_data[num_adcs];
logic signed                    raw_corrected_overflow_carry[num_adcs];
logic signed                    corrected_overflow_carry[num_adcs];
logic signed                    adc_overflow[num_adcs];
logic signed                    adc_underflow[num_adcs];
logic signed                    adc_overflow_raw [num_adcs];
logic signed                    adc_underflow_raw[num_adcs];
logic signed [adc_numbits -1:0] adc_overflow_threshold;
logic signed [adc_numbits -1:0] adc_underflow_threshold;
logic signed [adc_numbits -1:0] synced_averaged_adc[num_adcs];
logic signed [adc_numbits -1:0] captured_averaged_adc[num_adcs];
logic [15:0] read_max11000_state;
logic [15:0] state;
logic [15:0] zc_ignore_threshold;
logic [15:0] read_ltc2380_state;
logic in_the_middle_of_acquiring;
logic do_reset_before_integration;
logic keep_reset_active_after_integration;
logic [1:0] sel_data_type_to_output;
logic only_capture_when_at_least_one_gate_is_active;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic raw_cal_test;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic generated_cal_test;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic enable_generated_cal_test;

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic external_trigger_pulse;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic delayed_external_trigger_pulse;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic optical_delayed_external_trigger_pulse;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic delayed_zero_cross_external_trigger_pulse;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic enable_external_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic emulate_external_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic enable_optical_external_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic emulate_optical_external_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic emulate_zero_cross_external_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic enable_zero_cross_external_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic auto_start;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic auto_start_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic start_from_regfile;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic enable_auto_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic tie_s1_to_0;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic s1_from_integrate_and_hold;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic s2_from_integrate_and_hold;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic s1_from_register_file;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic s2_from_register_file;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic select_s1_from_register_file;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic select_s2_from_register_file;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic zero_cross_synced;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic zero_cross_rising_edge;

logic [31:0] num_cycles_delay_before_trigger;
logic [31:0] optical_num_cycles_delay_before_trigger;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0] calculated_delay_for_zero_cross_external_trigger;
logic [31:0] time_between_measurements;
logic [31:0] running_time_between_measurements;
logic [31:0] zero_cross_time_between_measurements;
logic [31:0] zc_correction;
logic [31:0] zero_cross_running_time_between_measurements;
logic [31:0] time_between_conv;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] running_time_between_conv;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] generated_cal_test_running_time_between_conv_threshold;
logic [7:0] num_sck_clocks;
logic select_gate_b_copy_out;
logic enable_gate_a;
logic enable_gate_b;
logic gate_a_synced, gate_b_synced;
logic [NUM_UNIFIED_DATA_BITS-1:0] captured_unified_data;
logic ldo_en_n;
assign ldo_en = !ldo_en_n;
			
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_gate_a
(
  .indata (gate_a),
   .outdata(gate_a_synced),
   .clk    (clk)

);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_gate_b
(
  .indata (gate_b_or_test_pulse),
   .outdata(gate_b_synced),
   .clk    (clk)

);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_zero_cross
(
  .indata (zero_cross),
   .outdata(zero_cross_synced),
   .clk    (clk)

);

assign clk = clk_sm;
assign optical_external_trigger_copy_out = optical_external_trigger;
assign external_trigger_copy_out = external_trigger;
assign gate_copy_out = select_gate_b_copy_out ? gate_b_or_test_pulse : gate_a;

integrate_and_hold_ivc102_rev2
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

logic [NUM_BITS_MAX11100_COUNTER-1:0] max11100_pulse_width_in_clocks;

read_max11100
#(
.num_adcs(num_adcs),
.numbits_spi(max11000_adc_numbits),
.numbits_counter(NUM_BITS_MAX11100_COUNTER)
)
read_max11000_inst
(
.start,
.enable,
.reset,
.clk,
.finish(max_11000_finish),
.pulse_width_in_clocks(max11100_pulse_width_in_clocks),
.state(read_max11000_state),
.read_data(max11000_read_data_raw),
.spi_clk (max11000_interface_pins.spi_clk ),
.spi_csn (max11000_interface_pins.spi_csn ),
.spi_miso(max11000_interface_pins.spi_miso),
.num_sck_clocks
);

logic actual_acq_finish;
logic conv_rising_edge;

non_sync_edge_detector
detect_new_start
(
 .insignal(finish), 
 .outsignal(actual_acq_finish), 
 .clk(clk)
);

non_sync_edge_detector
detect_new_conv
(
 .insignal(ltc2380_interface_pins.conv), 
 .outsignal(conv_rising_edge), 
 .clk(clk)
);

non_sync_edge_detector
detect_new_zero_cross
(
 .insignal(zero_cross_synced), 
 .outsignal(zero_cross_rising_edge), 
 .clk(clk)
);

				

always @(posedge clk)
begin
     if (actual_acq_finish)
	 begin
	         running_time_between_measurements <= 0;
	         time_between_measurements <= running_time_between_measurements;
	 end else
	 begin
			 running_time_between_measurements <= running_time_between_measurements + 1;
 			 time_between_measurements <= time_between_measurements;
	 end
end


always @(posedge clk)
begin
     if ((zero_cross_rising_edge) && (zero_cross_running_time_between_measurements > {16'b0,zc_ignore_threshold}))
	 begin
	        zero_cross_running_time_between_measurements <= 0;
	        zero_cross_time_between_measurements <= zero_cross_running_time_between_measurements;			 
	 end else
	 begin
			 zero_cross_running_time_between_measurements <= zero_cross_running_time_between_measurements + 1;
 			 zero_cross_time_between_measurements <= zero_cross_time_between_measurements;
	 end
end

reg [1:0] num_convs_seen = 0;


always @(posedge clk)
begin
      if (actual_acq_finish)
	  begin
	       num_convs_seen <= 0;
	  end else
	  begin
	         if (num_convs_seen == 0)
			 begin
	             if (conv_rising_edge)
			     begin
			          num_convs_seen <= 1;
				 end else
				 begin
				      num_convs_seen <= 0;
				 end
			 end else
			 begin
			        if (num_convs_seen == 1)
					begin
					     if (conv_rising_edge)
						 begin
							  num_convs_seen <= 2;			 
						end else 
						begin
						      num_convs_seen <= 1;
						end					
					end	else
                    begin
                         num_convs_seen <= num_convs_seen;
                    end					
			 end
	  end
end

always @(posedge clk)
begin
     if (actual_acq_finish)
	 begin
	         time_between_conv <= running_time_between_conv;
	 end else
	 begin
	       	 time_between_conv <= time_between_conv;			
	 end
end


always @(posedge clk)
begin
     if (actual_acq_finish)
	 begin
	         running_time_between_conv <= 0;
	 end else
	 begin
	        if (num_convs_seen == 0)
		    begin
			          running_time_between_conv <= running_time_between_conv;
			end else
            begin			
					if (num_convs_seen == 1)
					begin
						 running_time_between_conv <= running_time_between_conv + 1;
    				end else
					begin
					 /* num_convs_seen >= 2 */					
					      running_time_between_conv <= running_time_between_conv;
					end
			end
	 end
end

always_ff @(posedge clk) 
begin
      cal_test <= raw_cal_test || generated_cal_test;
end

always_ff @(posedge clk) 
begin
      if (enable_generated_cal_test)
	  begin
	        if (num_convs_seen == 1) 
			begin
			      if (running_time_between_conv >  generated_cal_test_running_time_between_conv_threshold)
				  begin
	                    generated_cal_test <= 1;
				  end else
				  begin
				        generated_cal_test <= 0;
				  end
	        end  else 
			begin
				   generated_cal_test <= 0;	  
			end
	  end else 
	  begin
	       generated_cal_test <= 0;	  
	  end
end



always @(posedge clk)
begin    

	if (max_11000_finish) 
	begin
	    max11000_read_data <=               max11000_read_data_raw;
	end
	
end 


always @(posedge clk)
begin    
   if (reset)
	begin
	      max_11000_adc_conversion_counter <= 0;
	end else 
   begin
			if (max_11000_finish) 
			begin
	      	 max_11000_adc_conversion_counter <= max_11000_adc_conversion_counter + 1;
			end
	end
end 

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

assign ltc2380_interface_pins.s1 = select_s1_from_register_file ? s1_from_register_file : s1_from_integrate_and_hold;
assign ltc2380_interface_pins.s2 = select_s2_from_register_file ? s2_from_register_file : s2_from_integrate_and_hold;

assign adc_clk = in_the_middle_of_acquiring;

Divisor_frecuencia
#(.Bits_counter(32))
Generate_auto_start
 (	
  .CLOCK(clk),
  .TIMER_OUT(auto_start_trigger),
  .Comparator(trigger_freq_div)
 );


edge_detect 
edge_detect_auto_start_trigger
(
.in_signal(auto_start_trigger), 
.clk(clk), 
.edge_detect(auto_start)
);

logic ext_trigger_emulator_osc_start;
logic ext_trigger_emulator_osc;
logic enable_ext_trigger_emulator_osc;
logic [31:0] ext_trigger_emulator_osc_div;

Divisor_frecuencia
#(.Bits_counter(32))
Generate_ext_trigger_emulator_osc
 (	
  .CLOCK(clk),
  .TIMER_OUT(ext_trigger_emulator_osc),
  .Comparator(ext_trigger_emulator_osc_div)
 );


edge_detect 
edge_detect_ext_trigger_emulator_osc
(
.in_signal(ext_trigger_emulator_osc), 
.clk(clk), 
.edge_detect(ext_trigger_emulator_osc_start)
);
				
generate_delayed_trigger 
#(
.numbits_counter (32)
)
delay_external_trigger 
(
.trigger_pulse_async_in(((external_trigger_synced | emulate_external_trigger) & enable_external_trigger)),
.trigger_pulse_sync_out(delayed_external_trigger_pulse),
.clk(clk),
.delay(num_cycles_delay_before_trigger)
);
	
				
generate_delayed_trigger 
#(
.numbits_counter (32)
)
delay_optical_external_trigger 
(
.trigger_pulse_async_in(((optical_external_trigger_synced | emulate_optical_external_trigger) & enable_optical_external_trigger)),
.trigger_pulse_sync_out(optical_delayed_external_trigger_pulse),
.clk(clk),
.delay(optical_num_cycles_delay_before_trigger)
);


				
generate_delayed_trigger 
#(
.numbits_counter (32)
)
delay_zero_cross_external_trigger 
(
.trigger_pulse_async_in((zero_cross_rising_edge | emulate_zero_cross_external_trigger) & enable_zero_cross_external_trigger),
.trigger_pulse_sync_out(delayed_zero_cross_external_trigger_pulse),
.clk(clk),
.delay(calculated_delay_for_zero_cross_external_trigger)
);
	
always_ff @(posedge clk)
begin
	 if (zero_cross_rising_edge)
	 begin
		  calculated_delay_for_zero_cross_external_trigger <= (zero_cross_time_between_measurements < (integration_time >> 1)) ? 0 : (zero_cross_time_between_measurements - zc_correction - (integration_time >> 1));
	 end
end

			
doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_start_to_ivc102_read
(
  .indata ((!in_the_middle_of_acquiring) && ((auto_start && enable_auto_trigger) || start_from_regfile || delayed_external_trigger_pulse || optical_delayed_external_trigger_pulse || delayed_zero_cross_external_trigger_pulse || (ext_trigger_emulator_osc_start & enable_ext_trigger_emulator_osc))),
  .outdata(start),
  .clk    (clk)
);

logic external_trigger_synced;
logic invert_external_trigger;
logic external_trigger_synced_raw;
logic invert_optical_external_trigger;
logic optical_external_trigger_synced;
logic optical_external_trigger_synced_raw;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_external_trigger
(
  .indata (external_trigger),
   .outdata(external_trigger_synced_raw),
   .clk    (clk)
);

assign external_trigger_synced  = invert_external_trigger ^ external_trigger_synced_raw;

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_optical_external_trigger
(
  .indata (optical_external_trigger),
   .outdata(optical_external_trigger_synced_raw),
   .clk    (clk)
);

assign optical_external_trigger_synced = invert_optical_external_trigger ^ optical_external_trigger_synced_raw;
logic [num_adc_averager_shift_bits-1:0] adc_averager_shift;
logic [averager_clk_count_num_bits-1:0] adc_averager_M;
logic [31:0] adc_averager_data_count[num_adcs];

logic capture_average_adc_raw;
logic capture_average_adc_now;

edge_detect 
edge_detect_capture_average_adc_now
(
.in_signal(capture_average_adc_raw), 
.clk(clk), 
.edge_detect(capture_average_adc_now)
);
			


genvar current_adc;
generate
for (current_adc = 0; current_adc < num_adcs; current_adc++)
begin : set_adc_data_to_waveform_display
     	
        assign	pre_integration_read_data[current_adc] = pre_integration_read_data_raw[current_adc];
		
		
		always_ff @(posedge adc_clk)
		begin
		     max11000_adc_data[current_adc] <= max11000_read_data[current_adc];
		end
		
	    assign  {raw_corrected_overflow_carry[current_adc],raw_corrected_adc_data[current_adc]} =  {read_data[current_adc][adc_numbits-1],read_data[current_adc]} - {pre_integration_read_data[current_adc][adc_numbits-1],pre_integration_read_data[current_adc]};

		always_ff @(posedge adc_clk)
		begin
		       {corrected_overflow_carry[current_adc],corrected_adc_data[current_adc]} <= {raw_corrected_overflow_carry[current_adc],raw_corrected_adc_data[current_adc]};
			   adc_overflow_raw[current_adc]  <= (read_data[current_adc] >  adc_overflow_threshold)  ||  (pre_integration_read_data[current_adc] > adc_overflow_threshold) || (raw_corrected_overflow_carry[current_adc] != raw_corrected_adc_data[current_adc][adc_numbits-1]);
			   adc_underflow_raw[current_adc]  <= (read_data[current_adc] <  adc_underflow_threshold)  ||  (pre_integration_read_data[current_adc] < adc_underflow_threshold) || (raw_corrected_overflow_carry[current_adc] != raw_corrected_adc_data[current_adc][adc_numbits-1]);					  
		end		
		
			
		always_ff @(posedge adc_clk)
		begin
		      case (sel_data_type_to_output)
			  2'b00: begin 
			               adc_underflow[current_adc] <=  adc_underflow_raw[current_adc];  
			               adc_overflow[current_adc] <=  adc_overflow_raw[current_adc];  
			               adc_data[current_adc] <= corrected_adc_data[current_adc];                                          
					 end
			  2'b01: begin 
			               adc_underflow[current_adc] <=  (read_data[current_adc] <  adc_underflow_threshold);                                
			               adc_overflow [current_adc] <=  (read_data[current_adc] >  adc_overflow_threshold);                                
						   adc_data[current_adc] <= read_data[current_adc];                                                   
					 end
			  2'b10: begin 
			                 adc_underflow[current_adc] <=  (pre_integration_read_data[current_adc] < adc_underflow_threshold); 
							 adc_overflow [current_adc] <=  (pre_integration_read_data[current_adc] > adc_overflow_threshold);
							 adc_data[current_adc] <= pre_integration_read_data[current_adc];                                   
					 end
			  2'b11: begin 
			                  adc_underflow[current_adc] <=  adc_underflow_raw[current_adc]; 
							  adc_data[current_adc] <= corrected_adc_data[current_adc] - corrected_adc_data[1-current_adc];      
					 end
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
		  				.accumulator_outdata()
		  );
		  
		  always @(posedge averaged_adc_clk[current_adc])
		  begin
		        adc_averager_data_count[current_adc] <=  adc_averager_data_count[current_adc]  + 1;
		  end
		  
		  
			my_multibit_clock_crosser_optimized_for_altera
			#(
			  .DATA_WIDTH(adc_numbits) 
			)
			mcp_synch_averaged_adc
			(
			   .in_clk(averaged_adc_clk[current_adc]),
			   .in_valid(1'b1),
			   .in_data(averaged_adc[current_adc]),
			   .out_clk(clk),
			   .out_valid(),
			   .out_data(synced_averaged_adc[current_adc])
			 );
			 			 
			always_ff @(posedge clk)
			begin
				 if (capture_average_adc_now) 
				 begin
					   captured_averaged_adc[current_adc] <= synced_averaged_adc[current_adc];
				 end
			end
			 
			 
end
endgenerate



assign unified_clk = adc_clk;

logic unified_valid_wire;
assign unified_valid_wire = only_capture_when_at_least_one_gate_is_active ? ((enable_gate_b & gate_b_synced) || (enable_gate_a & gate_a_synced)) :  1'b1;

logic [NUM_UNIFIED_DATA_BITS-1:0] unified_data_comb;
assign unified_data_comb = {(adc_overflow[1]|adc_underflow[1]),(adc_overflow[0]|adc_underflow[0]),gate_b_synced,gate_a_synced,enable_gate_b,enable_gate_a,time_between_conv[28:0],time_between_measurements[28:0],max11000_adc_data[1][max11000_actual_adc_numbits-1 -: 16],max11000_adc_data[0][max11000_actual_adc_numbits-1 -: 16],adc_data[1][adc_numbits-1 -: 16],adc_data[0][adc_numbits-1 -: 16]};

always_ff @(posedge unified_clk)
begin
     unified_valid <= unified_valid_wire;
     unified_data <= unified_data_comb;
end 


logic capture_unified_data_now_raw;
logic capture_unified_data_now;

edge_detect 
edge_detect_capture_unified_data_now
(
.in_signal(capture_unified_data_now_raw), 
.clk(clk), 
.edge_detect(capture_unified_data_now)
);


always_ff @(posedge clk)
begin
     if (capture_unified_data_now) 
	 begin
           captured_unified_data <= unified_data;
	 end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 32;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 35;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			localparam  UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                        = 0;
			localparam  STATUS_AND_CONTROL_DISABLE_ERROR_MONITORING                    = DISABLE_ERROR_MONITORING;
			localparam  COMPILE_CRC_ERROR_CHECKING_IN_PARSER   = 1'b1;
			
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
			assign uart_regfile_interface_pins.clk                    = clk;
			assign uart_regfile_interface_pins.data_clk               = clk;
			assign uart_regfile_interface_pins.reset                  = reset_registers_to_default_values;
			assign uart_regfile_interface_pins.user_type              = UART_REGFILE_TYPE;	
			assign uart_regfile_interface_pins.ignore_crc_value_for_debugging = ignore_crc_value_for_debugging;
			
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
			 .UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK      (UART_CLOCK_IS_DIFFERENT_FROM_DATA_CLOCK                       ),
          .DISABLE_ERROR_MONITORING                     (STATUS_AND_CONTROL_DISABLE_ERROR_MONITORING),
			 .COMPILE_CRC_ERROR_CHECKING_IN_PARSER         (COMPILE_CRC_ERROR_CHECKING_IN_PARSER)
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
    assign {    tie_s1_to_0,    
	            start_from_regfile,
	            do_reset_before_integration,
				keep_reset_active_after_integration,
				reset,
				enable}                      
				= uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 16;		
	  
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
    assign {enable_ext_trigger_emulator_osc,emulate_zero_cross_external_trigger,enable_zero_cross_external_trigger, emulate_optical_external_trigger,enable_optical_external_trigger,trigger_mode_setting[1],trigger_mode_setting[0],emulate_external_trigger,enable_external_trigger,enable_auto_trigger}   = uart_regfile_interface_pins.control[4];
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
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[16]  =  MAX11100_SCK_PULSE_WITH_IN_CLOCKS_DEFAULT;
     assign uart_regfile_interface_pins.control_desc[16]               = "max111_wait_clks";
     assign  max11100_pulse_width_in_clocks   = uart_regfile_interface_pins.control[16];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[16]      = NUM_BITS_MAX11100_COUNTER;	
	 				
	 assign uart_regfile_interface_pins.control_regs_default_vals[17]  =  DEFAULT_RELAY_SETTINGS;
     assign uart_regfile_interface_pins.control_desc[17]               = "relay_ctrl";
     assign  {enable_generated_cal_test,select_internal_cal_test,drive_cal_test, drive_rly_cnt, raw_cal_test,rly_cnt}   = uart_regfile_interface_pins.control[17];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[17]      = 16;		 			
		
	 assign uart_regfile_interface_pins.control_regs_default_vals[18]  =  0;
     assign uart_regfile_interface_pins.control_desc[18]               = "trigger_delay";
     assign num_cycles_delay_before_trigger   = uart_regfile_interface_pins.control[18];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[18]      = 32;		 
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[19]  =  0;
     assign uart_regfile_interface_pins.control_desc[19]               = "gate_ctrl";
     assign {ldo_en_n,sel_ttl_to_optical_out,sel_ttl_to_ttl_out,only_capture_when_at_least_one_gate_is_active,select_gate_b_copy_out,enable_gate_a,enable_gate_b}   = uart_regfile_interface_pins.control[19];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[19]      = 16;		 	
	 	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[20]  =  0;
     assign uart_regfile_interface_pins.control_desc[20]               = "opt_trig_delay";
     assign optical_num_cycles_delay_before_trigger   = uart_regfile_interface_pins.control[20];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[20]      = 32;		 	

	 assign uart_regfile_interface_pins.control_regs_default_vals[21]  =  0;
     assign uart_regfile_interface_pins.control_desc[21]               = "zc_correction";
     assign zc_correction   = uart_regfile_interface_pins.control[21];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[21]      = 32;	
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[22]  =  DEFAULT_ZC_Ignore_Threshold;
     assign uart_regfile_interface_pins.control_desc[22]               = "zc_correction";
     assign zc_ignore_threshold   = uart_regfile_interface_pins.control[22];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[22]      = 16;	
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[23]  =  24;
     assign uart_regfile_interface_pins.control_desc[23]               = "num_sck_clocks";
     assign num_sck_clocks   = uart_regfile_interface_pins.control[23];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[23]      = 8;	
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[24]  =  0;
     assign uart_regfile_interface_pins.control_desc[24]               = "capt_udata_now";
     assign {capture_average_adc_raw,capture_unified_data_now_raw}   = uart_regfile_interface_pins.control[24];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[24]      = 2;	
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[25]  =  0;
     assign uart_regfile_interface_pins.control_desc[25]               = "gen_cal_test_thr";
     assign generated_cal_test_running_time_between_conv_threshold   = uart_regfile_interface_pins.control[25];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[25]      = 32;	

	 assign uart_regfile_interface_pins.control_regs_default_vals[26]  =  DEFAULT_ADC_OVERFLOW_THRESHOLD; 
     assign uart_regfile_interface_pins.control_desc[26]               = "adc_oflow_thr";
     assign adc_overflow_threshold   = uart_regfile_interface_pins.control[26];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[26]      = adc_numbits;	
	  
	 assign uart_regfile_interface_pins.control_regs_default_vals[27]  =  DEFAULT_ADC_UNDERFLOW_THRESHOLD;
     assign uart_regfile_interface_pins.control_desc[27]               = "adc_uflow_thr";
     assign adc_underflow_threshold  = uart_regfile_interface_pins.control[27];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[27]      = adc_numbits;	
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[28]  =  DEFAULT_EXT_TRIGGER_EMULATOR_OSC_DIV;
     assign uart_regfile_interface_pins.control_desc[28]               = "ext_trig_div";
     assign ext_trigger_emulator_osc_div  = uart_regfile_interface_pins.control[28];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[28]      = 32;

	assign uart_regfile_interface_pins.control_regs_default_vals[29]  =  DEFAULT_SCALING_POSITION0;
    assign uart_regfile_interface_pins.control_desc[29]               = "scaling_pos0";
    assign uart_regfile_interface_pins.control_regs_bitwidth[29]      = 32;		

	assign uart_regfile_interface_pins.control_regs_default_vals[30]  =  DEFAULT_SCALING_POSITION1;
    assign uart_regfile_interface_pins.control_desc[30]               = "scaling_pos1";
    assign uart_regfile_interface_pins.control_regs_bitwidth[30]      = 32;		
	 
	 assign uart_regfile_interface_pins.control_regs_default_vals[31]  =  DEFAULT_INVERT_EXTERNAL_TRIGGER;
     assign uart_regfile_interface_pins.control_desc[31]               = "inv_ext_trig";
     assign {invert_optical_external_trigger,invert_external_trigger}  = uart_regfile_interface_pins.control[31];
	 assign uart_regfile_interface_pins.control_regs_bitwidth[31]      = 2;
	 
	 assign uart_regfile_interface_pins.status[0]         = adc_data[0];	
	 assign uart_regfile_interface_pins.status_desc[0]    ="adc_data0";	

	    
	 assign uart_regfile_interface_pins.status[1]         = adc_data[1];	
	 assign uart_regfile_interface_pins.status_desc[1]    ="adc_data0";	

	assign uart_regfile_interface_pins.status[2]         = state;
	assign uart_regfile_interface_pins.status_desc[2]    ="fsm_state";	
	
	assign uart_regfile_interface_pins.status[3]         = {optical_external_trigger_synced,external_trigger_synced,gate_b_synced,gate_a_synced,pwr_good,ltc2380_interface_pins.busy,in_the_middle_of_acquiring,ltc2380_interface_pins.s1,ltc2380_interface_pins.s2,ltc2380_interface_pins.conv};
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
	
	assign uart_regfile_interface_pins.status[18]         = max11000_read_data[0];	
	assign uart_regfile_interface_pins.status_desc[18]    = "max11000_data0";
	
	assign uart_regfile_interface_pins.status[19]         = max11000_read_data[1];		
	assign uart_regfile_interface_pins.status_desc[19]    = "max11000_data1";	
		
    assign uart_regfile_interface_pins.status[20]         = {
															max11000_interface_pins.spi_clk, 
															max11000_interface_pins.spi_csn, 
															max11000_interface_pins.spi_miso[1],
															max11000_interface_pins.spi_miso[0]	
														  };
	assign uart_regfile_interface_pins.status_desc[20]    ="max11000_status";	
	
	assign uart_regfile_interface_pins.status[21]         = read_max11000_state;
	assign uart_regfile_interface_pins.status_desc[21]    ="max11000_state";	

	assign uart_regfile_interface_pins.status[22]         = max_11000_adc_conversion_counter;
	assign uart_regfile_interface_pins.status_desc[22]    ="max11000_cnt";	

	assign uart_regfile_interface_pins.status[23]         = over_temp;
	assign uart_regfile_interface_pins.status_desc[23]    ="over_temp";	
		
	assign uart_regfile_interface_pins.status[24]         = time_between_measurements[31:0];
	assign uart_regfile_interface_pins.status_desc[24]    ="time_bet_meas";		
		
	assign uart_regfile_interface_pins.status[25]         = zero_cross_time_between_measurements[31:0];
	assign uart_regfile_interface_pins.status_desc[25]    ="zero_cross_time";	
	
	assign uart_regfile_interface_pins.status[26]         = time_between_conv[31:0];
	assign uart_regfile_interface_pins.status_desc[26]    ="time_bet_conv";		
		/*
	assign uart_regfile_interface_pins.status[27]         = zero_cross_running_time_between_measurements[31:0];
	assign uart_regfile_interface_pins.status_desc[27]    ="run_zero_cross";	
			*/	
    assign uart_regfile_interface_pins.status[28]         = calculated_delay_for_zero_cross_external_trigger[31:0];
	assign uart_regfile_interface_pins.status_desc[28]    ="calc_zero_cross";	
	
			
	assign uart_regfile_interface_pins.status[29]         = captured_unified_data[127:96];
	assign uart_regfile_interface_pins.status_desc[29]    ="udata_127_96";	
	
	assign uart_regfile_interface_pins.status[30]         = captured_unified_data[95:64];
	assign uart_regfile_interface_pins.status_desc[30]    ="udata_95_64";		
		
	assign uart_regfile_interface_pins.status[31]         = captured_unified_data[63:32];
	assign uart_regfile_interface_pins.status_desc[31]    ="udata_63_32";	
				
    assign uart_regfile_interface_pins.status[32]         = captured_unified_data[31:0];
	assign uart_regfile_interface_pins.status_desc[32]    ="udata_31_0";	
		
	assign uart_regfile_interface_pins.status[33]         = captured_averaged_adc[0];
	assign uart_regfile_interface_pins.status_desc[33]    ="capt_avg_adc0";	
				
    assign uart_regfile_interface_pins.status[34]         = captured_averaged_adc[1];
	assign uart_regfile_interface_pins.status_desc[34]    ="capt_avg_adc1";	
			
endmodule
`default_nettype wire

