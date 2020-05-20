
`default_nettype none
`include "interface_defs.v"

module triggered_packetizer
#(
parameter ENABLE_KEEPS = 0,
parameter synchronizer_depth = 3,
parameter NUM_BITS_DECIMATION_COUNTER = 16,
parameter [7:0] PACKET_WORD_COUNTER_WIDTH = 32,
parameter USE_BIGGER_EQUAL_TEST_AS_EXTRA_SAFETY_FOR_PACKET_WORD_COUNT = 1'b0,
parameter support_supersample_frames = 0
)
(
	multiple_synced_st_streaming_interfaces avst_out,
    multiple_synced_st_streaming_interfaces avst_in,
	input logic clk,
	input logic [NUM_BITS_DECIMATION_COUNTER-1:0] decimation_ratio,
	input logic enable_packet_streaming_to_memory,
    input logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_word_counter_limit,		
    input logic sop_state_machine_reset,	
	output logic HW_Trigger_Has_Happened,
	input  logic hw_trigger_reset,
	input  logic auto_hw_trigger_reset_enable,
	output logic hw_trigger_with_sop_interrupt,
	output logic hw_trigger_with_eop_interrupt,
	output logic eop_interrupt,
	output logic sop_interrupt,
	output logic [PACKET_WORD_COUNTER_WIDTH-1:0] packet_word_counter,    
    output logic [PACKET_WORD_COUNTER_WIDTH-1:0] last_packet_word_count,
	output logic packet_in_progress,
    input  logic actual_hw_trigger,
    output logic [7:0] state	
);

(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic synced_sop_state_machine_reset;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic synced_enable_packet_streaming_to_memory;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic synced_enable_packet_streaming_to_memory_raw;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic reset_packet_word_counter;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic increase_packet_word_counter;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic allow_avst_out_valid;    
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic reset_hw_trigger_for_external_memory;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic reset_hw_trigger_for_external_memory_raw;   
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic actual_hw_trigger_synced_to_write_clk;  
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic actual_hw_trigger_reset;     
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic actual_hw_trigger_reset_raw;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic actual_hw_trigger_reset_raw2;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic synced_auto_hw_trigger_reset_enable;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic hw_trigger_received;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic wrreq_enable;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic wrreq_enable_raw;
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic allow_hw_trigger_for_external_memory_raw;  
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic allow_hw_trigger_for_external_memory;  
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic allow_hw_trigger_for_external_memory_edge_detect;  
(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic is_waiting_for_start_of_superframe;  

generate 
if (support_supersample_frames)
begin
       mod_m_counter_var_m_w_en
	     #(
			.N(NUM_BITS_DECIMATION_COUNTER) // number of bits in counter              
		     )
		     decimate_write_request_counter
		    (
			.M(decimation_ratio),
			.clk(clk), 
			.enable(avst_in.valid),
			.reset(is_waiting_for_start_of_superframe && (!((!avst_in.superframe_start_n) && avst_in.valid))/*1'b0*/),
			.max_tick(wrreq_enable_raw),
			.q()
    	);
 
    	 assign wrreq_enable = is_waiting_for_start_of_superframe ? 1'b1 : wrreq_enable_raw; //sync decimation to superframe start
 	 end else
  	begin
					mod_m_counter_var_m_w_en
					 #(
						.N(NUM_BITS_DECIMATION_COUNTER) // number of bits in counter              
					 )
					 decimate_write_request_counter
					 (
						.M(decimation_ratio),
						.clk(clk), 
						.enable(avst_in.valid),
						.reset(1'b0),
						.max_tick(wrreq_enable),
						.q()
					 );
		end
endgenerate

 multiple_synced_st_streaming_interfaces 
#(
.num_channels        (avst_out.get_num_channels()       ),
.num_data_bits       (avst_out.get_num_data_bits()      ),
.num_bits_per_symbol (avst_out.get_num_bits_per_symbol()),
.num_error_bits      (avst_out.get_num_error_bits()     )
)
avst_out_raw();
						
parameter idle              = 8'b0000_0000;
parameter wait_for_sop      = 8'b0111_0001;
parameter wait_for_eop      = 8'b0001_0010;


doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_sop_state_machine_reset
(
.indata(sop_state_machine_reset),
.outdata(synced_sop_state_machine_reset),
.clk(clk)
);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_enable_packet_streaming_to_memory
(
.indata(enable_packet_streaming_to_memory || HW_Trigger_Has_Happened),
.outdata(synced_enable_packet_streaming_to_memory_raw),
.clk(clk)
);

edge_detect_and_hold
edge_detect_and_hold_enable_packet_streaming_to_memory(
/*input */   .in_signal(synced_enable_packet_streaming_to_memory_raw), 
/*input */   .reset(avst_out_raw.sop || synced_sop_state_machine_reset), 
/* output */ .edge_received(synced_enable_packet_streaming_to_memory), 
/*input */   .clk(clk));



assign reset_packet_word_counter                                     = !state[4];
assign increase_packet_word_counter                                  = avst_out_raw.valid & state[4];
assign allow_avst_out_valid                                          = state[4];
assign packet_in_progress                                            = state[4];
assign reset_hw_trigger_for_external_memory_raw                      = state[5];
assign allow_hw_trigger_for_external_memory_raw                      = !state[4];
assign is_waiting_for_start_of_superframe                            = state[6];

always_ff @(posedge clk)
begin
	  if (reset_packet_word_counter)
	  begin 
		   packet_word_counter <= 0;
	  end else
	  begin		
		  if (increase_packet_word_counter)
		  begin														  
				packet_word_counter <= packet_word_counter + 1;
		  end
	  end
end

												
always_ff @(posedge clk)
begin
	  if (synced_sop_state_machine_reset)
	  begin
			state <= idle;
	  end else
	  begin
		  
			case (state)
			idle : if (synced_enable_packet_streaming_to_memory)
				   begin
						 state <= wait_for_sop;
				   end
				   
			wait_for_sop : if (avst_out_raw.valid)
						   begin
								state <= wait_for_eop;
						   end
						   
			wait_for_eop : if (USE_BIGGER_EQUAL_TEST_AS_EXTRA_SAFETY_FOR_PACKET_WORD_COUNT)
								begin 
									 if ((packet_word_counter >= packet_word_counter_limit) && avst_out_raw.valid)
									  begin
											state <= idle;																
									  end					
							   end else
								begin
									 if ((packet_word_counter == packet_word_counter_limit) && avst_out_raw.valid)
									  begin
												state <= idle;																
									  end																											
								end
			endcase										
	  end
end


always_ff @(posedge clk)
begin
	   if (avst_out_raw.eop)
	   begin
			 last_packet_word_count <= packet_word_counter;
	   end															   
end

generate
		if (support_supersample_frames)
		begin
					assign avst_out_raw.valid  = ((!is_waiting_for_start_of_superframe) && allow_avst_out_valid & avst_in.valid & wrreq_enable)  ||  (avst_in.valid && wrreq_enable && is_waiting_for_start_of_superframe && (!avst_in.superframe_start_n));			
					assign avst_out_raw.sop   = ((packet_word_counter == 0) && (state  == wait_for_sop) &&  avst_out_raw.valid && (!avst_in.superframe_start_n));
		end else
		begin
					assign avst_out_raw.valid  = allow_avst_out_valid & avst_in.valid & wrreq_enable;
					assign avst_out_raw.sop   = ((packet_word_counter == 0) && (state  == wait_for_sop) &&  avst_out_raw.valid);
		end
endgenerate

assign avst_out_raw.clk   = clk;																						
assign avst_out_raw.eop   = ((packet_word_counter == packet_word_counter_limit) && (state  == wait_for_eop) &&  avst_out_raw.valid);

assign avst_out.clk =  avst_out_raw.clk;

genvar i;
generate
          for (i = 0; i < avst_out.get_num_channels(); i++)
		  begin : set_avst_out_data
		         always_ff @(posedge clk)
               begin
		                avst_out.data[i] <= avst_in.data[i];
					end
		  end
endgenerate

 always_ff @(posedge clk)
 begin
		avst_out.valid <= avst_out_raw.valid;		
		avst_out.sop   <= avst_out_raw.sop; 
		avst_out.eop   <= avst_out_raw.eop; 
		hw_trigger_with_eop_interrupt <= avst_out_raw.eop & HW_Trigger_Has_Happened; 
		hw_trigger_with_sop_interrupt <= avst_out_raw.sop & HW_Trigger_Has_Happened; 
 end						

 assign eop_interrupt = avst_out.eop;
 assign sop_interrupt = avst_out.sop;
									
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Trigger Handling
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

									
 assign actual_hw_trigger_reset_raw = hw_trigger_reset | (auto_hw_trigger_reset_enable & reset_hw_trigger_for_external_memory);
 
 doublesync_no_reset #(
 .synchronizer_depth(2)
 )
 sync_actual_hw_trigger_reset
 (
 .indata(actual_hw_trigger_reset_raw),
 .outdata(actual_hw_trigger_reset_raw2),
 .clk(clk)
 );
 
 doublesync_no_reset #(
 .synchronizer_depth(synchronizer_depth)
 )
 sync_auto_hw_trigger_reset_enable
 (
 .indata(auto_hw_trigger_reset_enable),
 .outdata(synced_auto_hw_trigger_reset_enable),
 .clk(clk)
 );
 
 
/////////////////////////////////////////////////////////////////////
//
// Adding register below causes problems, therefore disabled. Do not enable
// Reset here is to avoid spurious triggers caused by rising edge of allow_hw_trigger_for_external_memory
// Adding in a register messes with this reset mechanism
// No danger of glitch due to signal timing with combinational only path so it's OK
//
//////////////////////////////////////////////////////////////////// 
//generate
//		if (ADD_IN_EXTRA_REG_FOR_HW_TRIGGER_RESET_DEBUG)
//		begin
//			 always @(posedge clk)
//			 begin
//				   actual_hw_trigger_reset <= actual_hw_trigger_reset_raw2  | (synced_auto_hw_trigger_reset_enable & allow_hw_trigger_for_external_memory_edge_detect);
//			 end
//		end else
//		begin
			assign actual_hw_trigger_reset = actual_hw_trigger_reset_raw2  | (synced_auto_hw_trigger_reset_enable & allow_hw_trigger_for_external_memory_edge_detect);
//		end
//endgenerate
 
 
 doublesync_no_reset #(
 .synchronizer_depth(synchronizer_depth)
 )
 sync_reset_hw_trigger_for_external_memory  //synchronizer just for delay to avoid timing errors in Quartus
 (
 .indata(reset_hw_trigger_for_external_memory_raw),
 .outdata(reset_hw_trigger_for_external_memory),
 .clk(clk)
 );
 
 doublesync_no_reset #(
 .synchronizer_depth(synchronizer_depth)
 )
 sync_allow_hw_trigger_for_external_memory   //synchronizer just for delay to avoid timing errors in Quartus
 (
 .indata(allow_hw_trigger_for_external_memory_raw),
 .outdata(allow_hw_trigger_for_external_memory),
 .clk(clk)
 );		

edge_detect
generate_allow_hw_trigger_for_external_memory_edge_detect
(
.in_signal(allow_hw_trigger_for_external_memory), 
.edge_detect(allow_hw_trigger_for_external_memory_edge_detect), 
.clk(clk)
);

 
 async_trap_and_reset_gen_1_pulse_robust 
 async_trap_actual_hw_trigger
 (
 .async_sig(actual_hw_trigger & allow_hw_trigger_for_external_memory), 
 .outclk(clk), 
 .out_sync_sig(actual_hw_trigger_synced_to_write_clk), 
 .auto_reset(1'b0), 
 .reset(!actual_hw_trigger_reset)
 );
 
 async_event_request_handler   	
 async_event_request_handler_inst
 (
	/*input  */ .driver_clk(clk),
	/*input  */ .event_request_from_driver(actual_hw_trigger_synced_to_write_clk),
	/*output */ .event_request_to_event_buffer_synced_to_driver_clk(hw_trigger_received),
	/*output */ .reset_event_request_from_event_buffer_synced_to_driver_clk(),
	
	/*input  */ .event_buffer_clk(clk),
	/*output */ .event_request_to_event_buffer(HW_Trigger_Has_Happened),
	/*input  */ .reset_event_request_from_event_buffer(actual_hw_trigger_reset)
 );											  
										  
									  
										  
										  
 endmodule
 `default_nettype wire
 