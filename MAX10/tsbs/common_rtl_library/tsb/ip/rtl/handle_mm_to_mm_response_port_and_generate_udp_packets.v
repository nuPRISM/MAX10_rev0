// synthesis VERILOG_INPUT_VERSION SYSTEMVERILOG_2005
`default_nettype none
module handle_mm_to_mm_response_port_and_generate_udp_packets
#(
	
	parameter DATAWIDTH = 128,
	parameter BYTEENABLEWIDTH = DATAWIDTH/8,
	parameter ADDRESSWIDTH = 32,
	parameter WAIT_CYCLE_COUNTER_WIDTH = 8,

    parameter [7:0] NUM_PREAMBLE_WORDS = 14,
    parameter [7:0] NUM_USER_PREAMBLE_WORDS = 6,
	parameter synchronizer_depth = 3,
    
	parameter idle                                     = 12'b0000_0000_0000,
	parameter prepare_preamble_words                   = 12'b0000_0010_0001,
	parameter discard_empty_transactions               = 12'b0000_1000_1000,
	parameter latch_preamble_words                     = 12'b0000_0100_0010,
	parameter start_assembly_and_write_descriptor      = 12'b0001_0000_0011,
	parameter wait_for_assembly_and_write_descriptor   = 12'b0000_0000_0100,
	parameter pulse_ready                              = 12'b0000_1000_0101,
	parameter assert_finish                            = 12'b0000_0001_0110
)

 (
	input clk,
	input reset_n,
	input enable,
	input enable_msgdma_write,
	input [63:0] timestamp_in,
	input timestamp_clk,
	output logic finish,	
	
    input wire [255:0] src_response_data,  
    input wire src_response_valid,
    output logic src_response_ready,
	input  logic [31:0]  user_preamble_words[NUM_USER_PREAMBLE_WORDS-1:0],
	input  logic [31:0]  descriptor_space_address,
	input  logic [WAIT_CYCLE_COUNTER_WIDTH-1:0] wait_cycles,

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
	output logic reset_preamble_counter,
	output reg [7:0] preamble_counter = 0,
	output logic inc_preamble_counter,	
	output logic latch_current_preamble_word,	
	output logic actual_reset_preamble_counter_n,
    output logic [31:0] raw_current_preamble_word,	
    output logic [31:0] current_preamble_word,	    
    output logic select_descriptor_data,	
	output logic [127:0] assembled_descriptor_data,
	output logic [31:0]  preamble_words     [NUM_PREAMBLE_WORDS-1:0],
	output logic [31:0]  data_start_address,
	output logic [31:0]  data_source_address,
	output logic [15:0]  data_length,
	output logic [63:0]  packet_counter,
	 
    output logic is_write,
    output logic [31:0] control_word,
    output logic [31:0] actual_start_address,
    
	output logic [DATAWIDTH-1:0] user_write_data,
	output logic [DATAWIDTH-1:0] user_read_data,
	output logic [ADDRESSWIDTH-1:0] user_address,
	output logic [BYTEENABLEWIDTH-1:0] user_byteenable
	
	
);

import msgdma_constants::*;

logic [63:0] sync_timestamp;
wire sync_enable;

assign finish                               = state[4];
assign inc_packet_counter                   = state[5];
assign latch_preamble_now                   = state[6];
assign src_response_ready                   = state[7];
assign start_packet_and_descriptor_assembly = state[8];


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

parameter DEFAULT_CONTROL_WORD = ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_EOP_MASK | ALTERA_MSGDMA_DESCRIPTOR_CONTROL_GENERATE_SOP_MASK;
assign control_word = aux_user_control_word | DEFAULT_CONTROL_WORD; 


always @(posedge clk)
begin
       preamble_words[0]  <= 32'h80000000 + (data_length >> 2) + NUM_PREAMBLE_WORDS;
       preamble_words[1]  <= data_source_address;
       preamble_words[2]  <= actual_start_address; 
	                         
       preamble_words[3]  <= packet_counter[63:32];
       preamble_words[4]  <= packet_counter[31:0];
       preamble_words[5]  <= sync_timestamp[63:32];
	   preamble_words[6]  <= sync_timestamp[31:0];
        
       preamble_words[7]  <= 0; //reserved
       preamble_words[8]  <= user_preamble_words[0];
       preamble_words[9]  <= user_preamble_words[1];
       preamble_words[10] <= user_preamble_words[2];
       preamble_words[11] <= user_preamble_words[3];
	   preamble_words[12] <= user_preamble_words[4];
	   preamble_words[13] <= user_preamble_words[5];
	                                             
	   assembled_descriptor_data <= {            
	                                 control_word,                           //control word
	                                 data_length+NUM_PREAMBLE_WORDS*4,       //length
	                                 32'b0,                                  //write address
	                                 actual_start_address //read address
	                                };
end

doublesync_no_reset #(.synchronizer_depth(synchronizer_depth))
sync_enable_signal
(
.indata(enable),
.outdata(sync_enable),
.clk(clk)
);

always_ff @ (posedge clk or negedge reset_n)
   begin
        if (!reset_n)
		begin
		     state <= idle;
		end else
		begin
  				case (state)
					idle: begin
								 if (src_response_valid & sync_enable) 
								 begin 
								        state <= prepare_preamble_words;
								 end
						   end
					prepare_preamble_words :  if (data_length == 0)
                                              begin					
											        state <=  discard_empty_transactions;
                                              end else
                                              begin											  
											         state <= latch_preamble_words;
											  end
					discard_empty_transactions : state <= 	assert_finish;   
					latch_preamble_words :  state <= 	start_assembly_and_write_descriptor;   
											
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
   
   
assemble_msgdma_udp_packet_preamble_and_write_descriptor 
#(
.DATAWIDTH(DATAWIDTH),
.BYTEENABLEWIDTH(BYTEENABLEWIDTH),
.ADDRESSWIDTH(ADDRESSWIDTH),
.NUM_PREAMBLE_WORDS(NUM_PREAMBLE_WORDS),
.WAIT_CYCLE_COUNTER_WIDTH(WAIT_CYCLE_COUNTER_WIDTH)
) 
assemble_msgdma_udp_packet_preamble_and_write_descriptor_inst
(
// port map - connection between master ports and signals/registers   
	.actual_reset_preamble_counter_n(actual_reset_preamble_counter_n),
	.assembled_descriptor_data(assembled_descriptor_data),
	.avalon_mm_master_finish(avalon_mm_master_finish),
	.avalon_mm_master_start(avalon_mm_master_start),
	.avalon_mm_master_state(avalon_mm_master_state),
	.clk(clk),
	.current_preamble_word(current_preamble_word),
	.data_start_address(data_start_address),
	.descriptor_space_address(descriptor_space_address),
	.finish(start_packet_and_descriptor_finish),
	.inc_preamble_counter(inc_preamble_counter),
	.is_write(is_write),
	.latch_current_preamble_word(latch_current_preamble_word),
	.master_address(master_address),
	.master_byteenable(master_byteenable),
	.master_read(master_read),
	.master_readdata(master_readdata),
	.master_waitrequest(master_waitrequest),
	.master_write(master_write),
	.master_writedata(master_writedata),
	.preamble_counter(preamble_counter),
	.preamble_words(preamble_words),
	.raw_current_preamble_word(raw_current_preamble_word),
	.reset_n(reset_n),
	.reset_preamble_counter(reset_preamble_counter),
	.select_descriptor_data(select_descriptor_data),
	.start(start_packet_and_descriptor_assembly),
	.state(assemble_packet_state),
	.user_address(user_address),
	.user_byteenable(user_byteenable),
	.user_read_data (user_read_data),
	.user_write_data(user_write_data),
	.wait_cycles (wait_cycles),
	.enable_msgdma_write(enable_msgdma_write)

);

endmodule
`default_nettype wire
