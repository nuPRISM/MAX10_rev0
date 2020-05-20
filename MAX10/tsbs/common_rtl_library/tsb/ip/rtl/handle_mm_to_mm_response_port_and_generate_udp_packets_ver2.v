// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
`default_nettype none
module handle_mm_to_mm_response_port_and_generate_udp_packets_ver2
#(
	
	parameter DATAWIDTH = 32,
	parameter BYTEENABLEWIDTH = DATAWIDTH/8,
	parameter ADDRESSWIDTH = 32,
	parameter WAIT_CYCLE_COUNTER_WIDTH = 8,
	parameter WORD_COUNTER_WIDTH = 8,
	parameter NUM_SMARTBUF_BITS = 8,
	parameter SMARTBUF_LENGTH_IN_BYTES = 1440,
    parameter synchronizer_depth = 3,
	
    parameter [7:0] NUM_PREAMBLE_WORDS = 14,
    parameter [7:0] NUM_USER_PREAMBLE_WORDS = 6,
    parameter  MAX_NUM_WORDS_TO_WRITE = (NUM_PREAMBLE_WORDS > 4) ? NUM_PREAMBLE_WORDS : 4,
	parameter idle                                     = 12'b0000_0000_0000,
	parameter prepare_preamble_words                   = 12'b0000_0010_0001,
	parameter discard_empty_transactions               = 12'b0000_1000_0010,
	parameter latch_preamble_words                     = 12'b0000_0100_0011,	
	parameter start_write_preamble                     = 12'b0001_0000_0100,
	parameter wait_write_preamble                      = 12'b0000_0000_0101,
	parameter start_assembly_and_write_descriptor      = 12'b0011_0000_1000,
	parameter wait_for_assembly_and_write_descriptor   = 12'b0010_0000_1001,	
	parameter pulse_ready                              = 12'b0000_1000_1010,
	parameter assert_finish                            = 12'b0000_0001_1011
)

 (
	input clk,
	input reset_n,
	input enable,
	input enable_msgdma_write,
	input [63:0] timestamp_in,
	input timestamp_clk,
	output logic finish,	
	input retransmit_now,
	input [31:0] smartbuf_retransmit_address,
	input [31:0] smartbuf_retransmit_length,
	
    input wire [255:0] src_response_data,  
    input wire src_response_valid,
    output logic src_response_ready,
	input  logic [31:0]  user_preamble_words[NUM_USER_PREAMBLE_WORDS-1:0],
	input  logic [31:0]  descriptor_space_address,
	input  logic [WAIT_CYCLE_COUNTER_WIDTH-1:0] wait_cycles,
	//input  invert_bit_order_of_preamble_words,

	// master inputs and outputs
	output logic [ADDRESSWIDTH-1:0] master_address,
	output logic master_write,
	output logic master_read,
	output logic [BYTEENABLEWIDTH-1:0] master_byteenable,
	input  logic [DATAWIDTH-1:0] master_readdata,
	output logic [DATAWIDTH-1:0] master_writedata,
	input  master_waitrequest,
	input logic [31:0] aux_user_control_word,
	//debug outputs
	output reg [15:0] state = idle,
	
	output logic [15:0] avalon_mm_master_state,
	output logic [15:0] assemble_packet_state,
	output logic avalon_mm_master_start,
	output logic start_packet_and_descriptor_assembly,
	output logic avalon_mm_master_finish,	
	output logic start_packet_and_descriptor_finish,	
	output logic inc_packet_counter,	
	output logic latch_preamble_now,	
	output logic reset_current_word_counter,
	output reg [7:0] current_word_counter = 0,
	output logic inc_current_word_counter,	
	output logic latch_current_word_to_write,	
	output logic actual_reset_current_word_counter_n,
    output logic [31:0] raw_current_word_to_write,	
    output logic [31:0] current_word_to_write,	    
    output logic select_descriptor_data,	
	output logic [31:0] assembled_descriptor_data[3:0],	
	output logic [31:0]  preamble_words     [NUM_PREAMBLE_WORDS-1:0],
	output logic [31:0]  data_start_address,
	output logic [31:0]  data_source_address,
	output logic [15:0]  data_length,
	output logic [63:0]  packet_counter,
	output logic [WORD_COUNTER_WIDTH-1:0] num_words_to_write,

    output logic is_write,
    output logic [31:0] control_word,
    output logic [31:0] actual_start_address,
    output logic [31:0] address_to_word_writer,
    
	output logic [DATAWIDTH-1:0] user_write_data,
	output logic [DATAWIDTH-1:0] user_read_data,
	output logic [ADDRESSWIDTH-1:0] user_address,
	output logic [BYTEENABLEWIDTH-1:0] user_byteenable,
	output logic [31:0] words_to_write[MAX_NUM_WORDS_TO_WRITE-1:0],
	
	output logic regular_start,
	output logic [1:0] TDM_finish,
	output logic actual_sm_start,
	output logic current_operation_is_retransmit,
	output logic reset_regular_start,
	output logic [15:0] TDM_state,
	output logic [1:0] TDM_start_status,
	output logic retransmission_in_progress
);

import msgdma_constants::*;

logic [63:0] sync_timestamp;
wire sync_enable;

assign finish                               = state[4];
assign inc_packet_counter                   = state[5];
assign latch_preamble_now                   = state[6];
assign src_response_ready                   = state[7];
assign start_packet_and_descriptor_assembly = state[8];
assign select_descriptor_data               = state[9];


assign  data_source_address =  src_response_data[31:0];
assign  data_start_address  =  src_response_data[63:32];
assign  data_length         =  src_response_data[79:64];

my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(64),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth) 
)
mcp_synch_timestamp
(
   .in_clk(timestamp_clk),
   .in_valid(1'b1),
   .in_data(timestamp_in),
   .out_clk(clk),
   .out_valid(),
   .out_data(sync_timestamp)
 );

//mcp_blk 
//#(
//.width(64)
//)
//mcp_synch_timestamp
// (
///* output  logic */                 .aready  (), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain (timestamp_in),
///* input  logic */                  .asend   (1'b1/*trig_ts_ADC_out_min[n]*/),
///* input  logic */                  .aclk    (timestamp_clk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   (sync_timestamp),
///* output  logic */                 .bvalid  (), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (clk),
///* input  logic */                  .brst_n  (1'b1)
//);

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_enable_signal
(
.indata(enable),
.outdata(sync_enable),
.clk(clk)
);

always @(posedge clk)
begin
      if (reset_regular_start)
	  begin
	        regular_start <= 0;
	  end else
	  begin
	        regular_start <=  (src_response_valid & sync_enable);	  
	  end
end


assign retransmission_in_progress = TDM_start_status[0];

assign reset_regular_start = TDM_finish[1];

TDM_access_to_one_state_machine
#(
  .numbits_state_machine_parameters(1),
  .numclients(2),
  .actual_numclients(2),
  .log2numclients(1),
  .state_machine_received_data_width(1)
  ) 
TDM_Access_Control(
 .output_parameters(current_operation_is_retransmit),
 .start_target_state_machine(actual_sm_start),
 .target_state_machine_finished(finish), 
 .sm_clk(clk), 
 .start({regular_start,retransmit_now}),
 .finish(TDM_finish), 
 .input_parameters({1'b0,1'b1}),
 .received_data(), 
 .reset(1'b1), 
 .enable(1'b1),
 .in_received_data(),
 .state(TDM_state),
 .start_status(TDM_start_status)
 );	 
	 

assign actual_start_address = data_start_address-NUM_PREAMBLE_WORDS*4;

always @(posedge clk or negedge reset_n)
begin
      if (!reset_n)
	  begin
	       packet_counter <= 0;		   
	  end else 
	  begin 
	        if (inc_packet_counter)
			begin
	              packet_counter <= packet_counter + 1;
	        end
	  end
end

parameter DEFAULT_CONTROL_WORD = ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GO_MASK | ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MASK | ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_SOP_MASK ;
assign control_word = aux_user_control_word | DEFAULT_CONTROL_WORD; 


integer j;
always @(posedge clk)
begin
       preamble_words[0]  <= 32'h80000000 + (data_length >> 2) + NUM_PREAMBLE_WORDS;
       preamble_words[1]  <= data_source_address;
       preamble_words[2]  <= actual_start_address; 
	                         
       preamble_words[3]  <= packet_counter[63:32];
       preamble_words[4]  <= packet_counter[31:0];
       preamble_words[5]  <= sync_timestamp[63:32];
	   preamble_words[6]  <= sync_timestamp[31:0];
        
       preamble_words[7]  <= data_length+NUM_PREAMBLE_WORDS*4;
      // preamble_words[8]  <= user_preamble_words[0];
      // preamble_words[9]  <= user_preamble_words[1];
      // preamble_words[10] <= user_preamble_words[2];
      // preamble_words[11] <= user_preamble_words[3];
	  // preamble_words[12] <= user_preamble_words[4];
	  // preamble_words[13] <= user_preamble_words[5];
	  
	  for (j = NUM_PREAMBLE_WORDS-NUM_USER_PREAMBLE_WORDS; j <  NUM_PREAMBLE_WORDS; j = j+1)
	  begin
	         preamble_words[j] <= user_preamble_words[j-(NUM_PREAMBLE_WORDS-NUM_USER_PREAMBLE_WORDS)];			 	  
	  end
	                                             
	   assembled_descriptor_data[3] <= control_word;                           //control word
	   assembled_descriptor_data[2] <= current_operation_is_retransmit ? smartbuf_retransmit_length : data_length+NUM_PREAMBLE_WORDS*4;                           //length 
	   assembled_descriptor_data[1] <= 32'b0;                           //write address
	   assembled_descriptor_data[0] <= current_operation_is_retransmit ? smartbuf_retransmit_address : actual_start_address;                           //read address
end	                              

genvar i;
generate 
         for (i = 0; i < NUM_PREAMBLE_WORDS; i = i + 1)
		 begin : assign_words_to_write
		        if (i < 4)
				begin
                         assign words_to_write[i] = select_descriptor_data ?  assembled_descriptor_data[i] : preamble_words[i];
				end else begin
				         assign words_to_write[i] = preamble_words[i];
				end
		 end				 
endgenerate

assign num_words_to_write     = select_descriptor_data ? 4 : NUM_PREAMBLE_WORDS;
assign address_to_word_writer = select_descriptor_data ? descriptor_space_address : actual_start_address;



always_ff @ (posedge clk or negedge reset_n)
   begin
        if (!reset_n)
		begin
		     state <= idle;
		end else
		begin
  				case (state)
					idle: begin
								 if (actual_sm_start)
								 begin 
								        state <= current_operation_is_retransmit ?  start_assembly_and_write_descriptor : prepare_preamble_words;
								 end
						   end
					prepare_preamble_words :  if (data_length == 0)
                                              begin					
											        state <=  discard_empty_transactions;
                                              end else
                                              begin											  
											         state <= latch_preamble_words;
											  end
											  
					discard_empty_transactions : state <= assert_finish;   
					latch_preamble_words :  state <=	start_write_preamble;   
                    start_write_preamble		: state <= wait_write_preamble;	
                    wait_write_preamble 		:  if (start_packet_and_descriptor_finish) 
												   begin
												        if (enable_msgdma_write)
														begin
													          state <= start_assembly_and_write_descriptor;
														end else
														begin
														      state <= pulse_ready;
														end
												   end
												   
					start_assembly_and_write_descriptor: state <= wait_for_assembly_and_write_descriptor;
					wait_for_assembly_and_write_descriptor    :  if (start_packet_and_descriptor_finish) 
					                                             begin
																      state <= pulse_ready;
																 end
					pulse_ready    :  state <= assert_finish;
					
					assert_finish  : state <= idle;			   
					endcase
		end
end
   
   
write_a_series_of_32bit_words_to_avalon_mm 
#(
.DATAWIDTH(DATAWIDTH),
.BYTEENABLEWIDTH(BYTEENABLEWIDTH),
.ADDRESSWIDTH(ADDRESSWIDTH),
.MAX_NUM_WORDS_TO_WRITE(MAX_NUM_WORDS_TO_WRITE),
.WAIT_CYCLE_COUNTER_WIDTH(WAIT_CYCLE_COUNTER_WIDTH),
.WORD_COUNTER_WIDTH(WORD_COUNTER_WIDTH)
) 
write_a_series_of_32bit_words_to_avalon_mm_inst
(
// port map - connection between master ports and signals/registers   
	.actual_reset_current_word_counter_n(actual_reset_current_word_counter_n),
	.avalon_mm_master_finish(avalon_mm_master_finish),
	.avalon_mm_master_start(avalon_mm_master_start),
	.avalon_mm_master_state(avalon_mm_master_state),
	.clk(clk),
	.current_word_to_write(current_word_to_write),
	.num_words_to_write(num_words_to_write),
	.data_start_address(address_to_word_writer),
	.finish(start_packet_and_descriptor_finish),
	.inc_current_word_counter(inc_current_word_counter),
	.is_write(is_write),
	.latch_current_word_to_write(latch_current_word_to_write),
	.master_address(master_address),
	.master_byteenable(master_byteenable),
	.master_read(master_read),
	.master_readdata(master_readdata),
	.master_waitrequest(master_waitrequest),
	.master_write(master_write),
	.master_writedata(master_writedata),
	.current_word_counter(current_word_counter),
	.words_to_write(words_to_write),
	.raw_current_word_to_write(raw_current_word_to_write),
	.reset_n(reset_n),
	.reset_current_word_counter(reset_current_word_counter),
	.start(start_packet_and_descriptor_assembly),
	.state(assemble_packet_state),
	.user_address(user_address),
	.user_byteenable(user_byteenable),
	.user_read_data (user_read_data),
	.user_write_data(user_write_data),
	.wait_cycles (wait_cycles)
);

endmodule
`default_nettype wire
