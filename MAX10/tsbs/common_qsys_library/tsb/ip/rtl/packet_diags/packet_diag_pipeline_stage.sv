// (C) 2001-2015 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $File: //acds/rel/14.1/ip/avalon_st/altera_avalon_st_pipeline_stage/altera_avalon_st_pipeline_stage.sv $
// $Revision: #1 $
// $Date: 2014/10/06 $
// $Author: swbranch $
//------------------------------------------------------------------------------

`timescale 1ns / 1ns
`default_nettype none
module packet_diag_pipeline_stage #(
    parameter 
      SYMBOLS_PER_BEAT = 1,
      BITS_PER_SYMBOL = 8,
      USE_PACKETS = 1,
      USE_EMPTY = 0,
      PIPELINE_READY = 1,
      ENABLE_PACKET_STATISTICS = 1,
      // Optional ST signal widths.  Value "0" means no such port.
      CHANNEL_WIDTH = 0,
      ERROR_WIDTH = 0,

      // Derived parameters
      DATA_WIDTH = SYMBOLS_PER_BEAT * BITS_PER_SYMBOL,
      PACKET_WIDTH = 2,
      EMPTY_WIDTH = 0,
	  NUM_ADDRESS_BITS = 6,
	  NUM_AVMM_REGISTERS = 2**NUM_ADDRESS_BITS,
	  NUM_OF_COUNTER_BITS = 24,
	  NUM_COMPARED_PACKETS = 8,
	  DEFAULT_VALID_PACKET_LENGTH = 1024,
	  synchronizer_depth = 2
  )
  (
    input clk,
    input reset,

    output in_ready,
    input in_valid,
    input [DATA_WIDTH - 1 : 0] in_data,
    input [(CHANNEL_WIDTH ? (CHANNEL_WIDTH - 1) : 0) : 0] in_channel,
    input [(ERROR_WIDTH ? (ERROR_WIDTH - 1) : 0) : 0] in_error,
    input in_startofpacket,
    input in_endofpacket,
    input [(EMPTY_WIDTH ? (EMPTY_WIDTH - 1) : 0) : 0] in_empty,

    input out_ready,
    output out_valid,
    output [DATA_WIDTH - 1 : 0] out_data,
    output [(CHANNEL_WIDTH ? (CHANNEL_WIDTH - 1) : 0) : 0] out_channel,
    output [(ERROR_WIDTH ? (ERROR_WIDTH - 1) : 0) : 0] out_error,
    output out_startofpacket,
    output out_endofpacket,
    output [(EMPTY_WIDTH ? (EMPTY_WIDTH - 1) : 0) : 0] out_empty,
	
	output                                                    snoop_in_ready,
    output                                                    snoop_in_valid,
    output [DATA_WIDTH - 1 : 0]                               snoop_in_data,
    output [(CHANNEL_WIDTH ? (CHANNEL_WIDTH - 1) : 0) : 0]    snoop_in_channel,
    output [(ERROR_WIDTH ? (ERROR_WIDTH - 1) : 0) : 0]        snoop_in_error,
    output                                                    snoop_in_startofpacket,
    output                                                    snoop_in_endofpacket,
    output [(EMPTY_WIDTH ? (EMPTY_WIDTH - 1) : 0) : 0]        snoop_in_empty,

    output                                                   snoop_out_ready,
    output                                                   snoop_out_valid,
    output [DATA_WIDTH - 1 : 0]                              snoop_out_data,
    output [(CHANNEL_WIDTH ? (CHANNEL_WIDTH - 1) : 0) : 0]   snoop_out_channel,
    output [(ERROR_WIDTH ? (ERROR_WIDTH - 1) : 0) : 0]       snoop_out_error,
    output                                                   snoop_out_startofpacket,
    output                                                   snoop_out_endofpacket,
    output [(EMPTY_WIDTH ? (EMPTY_WIDTH - 1) : 0) : 0]       snoop_out_empty,
	
	
	
	
	
	
	
	input			[ NUM_ADDRESS_BITS-1: 0]	address,
	input			[ 3: 0]	byteenable,
	input						read,
	input						write,
	input			[31: 0]	writedata,
	output     reg	[31: 0]	readdata,
	input avalon_mm_clk,
    input avalon_mm_reset,
    output logic [NUM_OF_COUNTER_BITS-1:0] sop_2_eop_reg,
    output logic [NUM_OF_COUNTER_BITS-1:0] sop_2_sop_reg,
    output logic [NUM_OF_COUNTER_BITS-1:0] valid_data_counter,
    output logic [NUM_OF_COUNTER_BITS-1:0] valid_data_counter_capture,
    output logic [NUM_OF_COUNTER_BITS-1:0] sop_2_eop_reg_capture,
    output logic [NUM_OF_COUNTER_BITS-1:0] sop_2_sop_reg_capture,
    output logic [NUM_OF_COUNTER_BITS-1:0] num_of_packets,
	output logic [NUM_OF_COUNTER_BITS-1:0] num_delays_due_to_ready_capture,          
	output logic [NUM_OF_COUNTER_BITS-1:0] num_delays_due_to_valid_capture,          
	output logic [NUM_OF_COUNTER_BITS-1:0] num_delays_due_to_ready_and_valid_capture,
	output logic currently_in_frame,
    output logic [31:0] control_reg,
    output logic [31:0] synced_control_reg,
    output logic reset_statistics_counters,
    output logic force_in_ready,
    output logic in_ready_raw,
    output logic one_pulse_reset,
	output logic [NUM_COMPARED_PACKETS-1:0] found_valid_packet,
	output logic [NUM_COMPARED_PACKETS-1:0] found_valid_packet_pulse,
	output logic packet_length_error,
	output logic [NUM_OF_COUNTER_BITS-1:0] packet_length_at_error,
	output logic [NUM_OF_COUNTER_BITS-1:0] num_packet_errors,
	output logic [NUM_OF_COUNTER_BITS-1:0] packet_num_at_error,
	output logic [NUM_OF_COUNTER_BITS-1:0] num_delays_due_to_ready,          
	output logic [NUM_OF_COUNTER_BITS-1:0] num_delays_due_to_valid,          
	output logic [NUM_OF_COUNTER_BITS-1:0] num_delays_due_to_ready_and_valid,
	output logic [NUM_OF_COUNTER_BITS-1:0] s2s_ready_count,                  
	output logic [NUM_OF_COUNTER_BITS-1:0] s2s_valid_count,                 
	output logic [NUM_OF_COUNTER_BITS-1:0] s2s_ready_and_valid_count,        
	output logic [NUM_OF_COUNTER_BITS-1:0] s2s_not_ready_and_not_valid_count,
    output logic [NUM_OF_COUNTER_BITS-1:0] s2s_ready_count_capture,                  
	output logic [NUM_OF_COUNTER_BITS-1:0] s2s_valid_count_capture,                 
	output logic [NUM_OF_COUNTER_BITS-1:0] s2s_ready_and_valid_count_capture,        
	output logic [NUM_OF_COUNTER_BITS-1:0] s2s_not_ready_and_not_valid_count_capture
	
	
	
	
);

localparam  PACKET_DIAG_CONTROL_REG                                    = 0 ;
localparam	PACKET_DIAG_STATUS_REG                                     = 1 ;
localparam	PACKET_DIAG_NUM_OF_PACKETS                                 = 2 ;
localparam	PACKET_DIAG_SOP_2_EOP_CAPTURE_REG                          = 3 ;
localparam	PACKET_DIAG_SOP_2_SOP_CAPTURE_REG                          = 4 ;
localparam	PACKET_DIAG_SOP_2_EOP_REG                                  = 5 ;
localparam	PACKET_DIAG_SOP_2_SOP_REG                                  = 6 ;
localparam	PACKET_DIAG_VALID_COUNTER_REG                              = 7 ;
localparam	PACKET_DIAG_VALID_COUNTER_CAPTURE_REG                      = 8 ;
localparam	PACKET_DIAG_IN_PACKET_CONTROL                              = 9 ;
localparam	PACKET_DIAG_IN_PACKET_DATA                                 = 10;
localparam	PACKET_DIAG_OUT_PACKET_CONTROL                             = 12;
localparam	PACKET_DIAG_OUT_PACKET_DATA                                = 13;
localparam	PACKET_DIAG_FOUND_VALID_PACKET                             = 11;
localparam	PACKET_DIAG_PACKET_LENGTH_AT_ERROR                         = 14;
localparam	PACKET_DIAG_NUM_PACKET_ERRORS                              = 15;
localparam	PACKET_DIAG_PACKET_NUM_AT_ERROR                            = 16;
localparam	PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY                 = 17;
localparam	PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_VALID                 = 18;
localparam	PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY_AND_VALID       = 19;
localparam	PACKET_DIAG_S2S_READY_COUNT                                = 20;
localparam	PACKET_DIAG_S2S_VALID_COUNT                                = 21;
localparam	PACKET_DIAG_S2S_READY_AND_VALID_COUNT                      = 22;
localparam	PACKET_DIAG_S2S_NOT_READY_AND_NOT_VALID_COUNT              = 23;
localparam	PACKET_DIAG_END_OF_DATA_CAPTURE_REGISTERS                  = 24;
localparam	PACKET_DIAG_COMPARED_PACKET_LENGTH_START                   = 48;


assign  snoop_in_ready         =      in_ready           ;
assign  snoop_in_valid         =      in_valid           ;
assign  snoop_in_data          =      in_data            ;
assign  snoop_in_channel       =      in_channel         ;
assign  snoop_in_error         =      in_error           ;
assign  snoop_in_startofpacket =      in_startofpacket   ;
assign  snoop_in_endofpacket   =      in_endofpacket     ;
assign  snoop_in_empty         =      in_empty           ;
                                                    
assign  snoop_out_ready         =     out_ready           ;
assign  snoop_out_valid         =     out_valid           ;
assign  snoop_out_data          =     out_data            ;
assign  snoop_out_channel       =     out_channel         ;
assign  snoop_out_error         =     out_error           ;
assign  snoop_out_startofpacket =     out_startofpacket   ;
assign  snoop_out_endofpacket   =     out_endofpacket     ;
assign  snoop_out_empty         =     out_empty           ;

reg	[31: 0]	    readdata_raw [NUM_AVMM_REGISTERS];
reg	[31: 0]	    readdata_raw2[NUM_AVMM_REGISTERS];
reg	[31 : 0]	compared_packet_length[NUM_COMPARED_PACKETS];
reg	[NUM_OF_COUNTER_BITS-1:0]	synced_compared_packet_length[NUM_COMPARED_PACKETS];

assign in_ready = in_ready_raw || force_in_ready;

  localparam 
    PAYLOAD_WIDTH = 
      DATA_WIDTH +
      PACKET_WIDTH +
      CHANNEL_WIDTH +
      EMPTY_WIDTH +
      ERROR_WIDTH;

  wire [PAYLOAD_WIDTH - 1: 0] in_payload;
  wire [PAYLOAD_WIDTH - 1: 0] out_payload;

  // Assign in_data and other optional in_* interface signals to in_payload.
  assign in_payload[DATA_WIDTH - 1 : 0] = in_data;
  generate
    // optional packet inputs
    if (PACKET_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH - 1 : 
        DATA_WIDTH
      ] = {in_startofpacket, in_endofpacket};
    end
    // optional channel input
    if (CHANNEL_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH
      ] = in_channel;
    end
    // optional empty input
    if (EMPTY_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH
      ] = in_empty;
    end
    // optional error input
    if (ERROR_WIDTH) begin
      assign in_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH + ERROR_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH
      ] = in_error;
    end
  endgenerate

  packet_diag_pipeline_base #(
    .SYMBOLS_PER_BEAT (PAYLOAD_WIDTH),
    .BITS_PER_SYMBOL (1),
    .PIPELINE_READY (PIPELINE_READY)
  ) core (
    .clk (clk),
    .reset (reset),
    .in_ready (in_ready_raw),
    .in_valid (in_valid),
    .in_data (in_payload),
    .out_ready (out_ready),
    .out_valid (out_valid),
    .out_data (out_payload)
  );

  // Assign out_data and other optional out_* interface signals from out_payload.
  assign out_data = out_payload[DATA_WIDTH - 1 : 0];
  generate
    // optional packet outputs
    if (PACKET_WIDTH) begin
      assign {out_startofpacket, out_endofpacket} = 
        out_payload[DATA_WIDTH + PACKET_WIDTH - 1 : DATA_WIDTH];
    end else begin
      // Avoid a "has no driver" warning.
      assign {out_startofpacket, out_endofpacket} = 2'b0;
    end

    // optional channel output
    if (CHANNEL_WIDTH) begin
      assign out_channel = out_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH
      ];
    end else begin
      // Avoid a "has no driver" warning.
      assign out_channel = 1'b0;
    end
    // optional empty output
    if (EMPTY_WIDTH) begin
      assign out_empty = out_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH
      ];
    end else begin
      // Avoid a "has no driver" warning.
      assign out_empty = 1'b0;
    end
    // optional error output
    if (ERROR_WIDTH) begin
      assign out_error = out_payload[
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH + ERROR_WIDTH - 1 : 
        DATA_WIDTH + PACKET_WIDTH + CHANNEL_WIDTH + EMPTY_WIDTH
      ];
    end else begin
      // Avoid a "has no driver" warning.
      assign out_error = 1'b0;
    end
  endgenerate

assign reset_statistics_counters = reset || one_pulse_reset|| synced_control_reg[0];
assign force_in_ready = synced_control_reg[1];
   
edge_detect 
generate_one_pulse_reset
(
.in_signal(synced_control_reg[2]), 
.clk(clk), 
.edge_detect(one_pulse_reset)
);

genvar i, j;
generate 
         if (ENABLE_PACKET_STATISTICS)
		 begin
					always_ff @(posedge clk)
					begin
						if (reset_statistics_counters)
						begin
							   sop_2_eop_reg <= 0;
							   sop_2_sop_reg <= 0; 
							   sop_2_eop_reg_capture <= 0;
							   sop_2_sop_reg_capture <= 0;
							   currently_in_frame <= 0;
							   num_of_packets <= 0;
							   num_delays_due_to_ready   <= 0;
							   num_delays_due_to_valid   <= 0;
							   num_delays_due_to_ready_and_valid   <= 0;
							   num_delays_due_to_ready_capture <= 0;          
							   num_delays_due_to_valid_capture <= 0;
							   num_delays_due_to_ready_and_valid_capture <= 0;
							   s2s_ready_count                            <= 0; 
							   s2s_valid_count                            <= 0;
							   s2s_ready_and_valid_count                  <= 0;
							   s2s_not_ready_and_not_valid_count          <= 0;
							   s2s_ready_count_capture                    <= 0;
							   s2s_valid_count_capture                    <= 0;
							   s2s_ready_and_valid_count_capture          <= 0;
							   s2s_not_ready_and_not_valid_count_capture  <= 0;
						end else
						begin
							if ((!currently_in_frame) && (in_startofpacket & in_valid & in_ready))
							begin
								   sop_2_eop_reg <= 1;
								   sop_2_sop_reg <= 1; 
								   sop_2_eop_reg_capture <=  sop_2_eop_reg;
								   sop_2_sop_reg_capture <=  sop_2_sop_reg;
								   currently_in_frame <= 1;
								   num_of_packets <= num_of_packets + 1; //assured that no double counting becuase after this clock currently_in_frame = 1;
								   num_delays_due_to_ready   <= 0;
								   num_delays_due_to_valid   <= 0;
								   num_delays_due_to_ready_and_valid   <= 0;
								   num_delays_due_to_ready_capture           <= num_delays_due_to_ready;          
								   num_delays_due_to_valid_capture           <= num_delays_due_to_valid;
								   num_delays_due_to_ready_and_valid_capture <= num_delays_due_to_ready_and_valid;
								   s2s_ready_count                            <= 0;
								   s2s_valid_count                            <= 0;			   
								   s2s_ready_and_valid_count                  <= 1;			   
								   s2s_not_ready_and_not_valid_count          <= 0;			   
								   s2s_ready_count_capture                    <= s2s_ready_count                  ;			   
								   s2s_valid_count_capture                    <= s2s_valid_count                  ;			   
								   s2s_ready_and_valid_count_capture          <= s2s_ready_and_valid_count        ;			   
								   s2s_not_ready_and_not_valid_count_capture  <= s2s_not_ready_and_not_valid_count;
							end else
							begin
								   if (currently_in_frame && (in_endofpacket & in_valid & in_ready))
								   begin
										currently_in_frame <= 0;
										sop_2_eop_reg <= sop_2_eop_reg + 1;
										sop_2_sop_reg <= sop_2_sop_reg + 1; 
										sop_2_eop_reg_capture <=  sop_2_eop_reg_capture;
										sop_2_sop_reg_capture <=  sop_2_sop_reg_capture;
										num_of_packets <= num_of_packets; 		
										num_delays_due_to_ready_capture           <= num_delays_due_to_ready_capture            ;
										num_delays_due_to_valid_capture           <= num_delays_due_to_valid_capture            ;
										num_delays_due_to_ready_and_valid_capture <= num_delays_due_to_ready_and_valid_capture	;	
										num_delays_due_to_ready_and_valid <= num_delays_due_to_ready_and_valid  ;
										num_delays_due_to_valid           <= num_delays_due_to_valid            ;
										num_delays_due_to_ready           <= num_delays_due_to_ready           	;				
										s2s_ready_count                            <= s2s_ready_count                  ;
										s2s_valid_count                            <= s2s_valid_count                  ;			   
										s2s_ready_and_valid_count                  <= s2s_ready_and_valid_count + 1    ;			   
										s2s_not_ready_and_not_valid_count          <= s2s_not_ready_and_not_valid_count;			   
										s2s_ready_count_capture                    <= s2s_ready_count_capture                  ;	
										s2s_valid_count_capture                    <= s2s_valid_count_capture                  ;	
										s2s_ready_and_valid_count_capture          <= s2s_ready_and_valid_count_capture        ;	
										s2s_not_ready_and_not_valid_count_capture  <= s2s_not_ready_and_not_valid_count_capture;
								   end else
								   begin			        
										currently_in_frame <= currently_in_frame;
										sop_2_eop_reg <= sop_2_eop_reg + currently_in_frame;
										sop_2_sop_reg <= sop_2_sop_reg + 1;		   
										sop_2_eop_reg_capture <=  sop_2_eop_reg_capture;
										sop_2_sop_reg_capture <=  sop_2_sop_reg_capture;
										s2s_ready_count_capture                    <= s2s_ready_count_capture                  ;	
										s2s_valid_count_capture                    <= s2s_valid_count_capture                  ;	
										s2s_ready_and_valid_count_capture          <= s2s_ready_and_valid_count_capture        ;	
										s2s_not_ready_and_not_valid_count_capture  <= s2s_not_ready_and_not_valid_count_capture;
										
										
										num_of_packets <= num_of_packets; 	
										num_delays_due_to_ready_capture           <= num_delays_due_to_ready_capture            ;
										num_delays_due_to_valid_capture           <= num_delays_due_to_valid_capture            ;
										num_delays_due_to_ready_and_valid_capture <= num_delays_due_to_ready_and_valid_capture	;						
										
												
										num_delays_due_to_ready_and_valid <= num_delays_due_to_ready_and_valid + (currently_in_frame & (!in_valid) & (!in_ready));
										num_delays_due_to_valid           <= num_delays_due_to_valid +  (currently_in_frame & (!in_valid) & (in_ready));
										num_delays_due_to_ready           <= num_delays_due_to_ready +   (currently_in_frame & (in_valid) & (!in_ready));
													
										s2s_not_ready_and_not_valid_count <= s2s_not_ready_and_not_valid_count + ((!in_valid) & (!in_ready));
										s2s_ready_count                   <= s2s_ready_count + ((!in_valid) & (in_ready));
										s2s_valid_count                   <= s2s_valid_count + ((in_valid) & (!in_ready));
										s2s_ready_and_valid_count         <= s2s_ready_and_valid_count + ((in_valid) & (in_ready));				
								   end
							end
						end
					end
						
					always_ff @(posedge clk)
					begin	
						if (reset_statistics_counters)
						begin
							   valid_data_counter <= 0;
							   valid_data_counter_capture <= 0;		   
						end else
						begin
							if ((!currently_in_frame) && (in_startofpacket & in_valid & in_ready))
							begin
								   valid_data_counter <= 1;
								   valid_data_counter_capture <=  valid_data_counter_capture; //note moved capture to endofpacket
							end else
							begin
								   if (currently_in_frame && (in_ready & in_valid))
								   begin
										valid_data_counter <= valid_data_counter + 1;
										
										if (in_endofpacket)
										begin
											  valid_data_counter_capture <= valid_data_counter + 1;
										end else
										begin
											  valid_data_counter_capture <=  valid_data_counter_capture;
										end
								   end
							end
						end
					end
						
					   
					// Output Registers
					always_comb
					begin
						 readdata_raw [PACKET_DIAG_CONTROL_REG                              ]  =  synced_control_reg;
						 readdata_raw [PACKET_DIAG_STATUS_REG                               ]  =  {ENABLE_PACKET_STATISTICS[0],one_pulse_reset, in_ready_raw, force_in_ready,currently_in_frame};
						 readdata_raw [PACKET_DIAG_NUM_OF_PACKETS                           ]  =  num_of_packets;
						 readdata_raw [PACKET_DIAG_SOP_2_EOP_CAPTURE_REG                    ]  =  sop_2_eop_reg_capture;
						 readdata_raw [PACKET_DIAG_SOP_2_SOP_CAPTURE_REG                    ]  =  sop_2_sop_reg_capture;
						 readdata_raw [PACKET_DIAG_SOP_2_EOP_REG                            ]  =  sop_2_eop_reg;
						 readdata_raw [PACKET_DIAG_SOP_2_SOP_REG                            ]  =  sop_2_sop_reg;
						 readdata_raw [PACKET_DIAG_VALID_COUNTER_REG                        ]  =  valid_data_counter;
						 readdata_raw [PACKET_DIAG_VALID_COUNTER_CAPTURE_REG                ]  =  valid_data_counter_capture;
						 readdata_raw [PACKET_DIAG_IN_PACKET_CONTROL                        ]  =  {in_endofpacket,in_startofpacket,in_ready,in_valid};
						 readdata_raw [PACKET_DIAG_IN_PACKET_DATA                           ] =  in_data;
						 readdata_raw [PACKET_DIAG_OUT_PACKET_CONTROL                       ] =  {out_endofpacket,out_startofpacket,out_ready,out_valid};
						 readdata_raw [PACKET_DIAG_OUT_PACKET_DATA                          ] =  out_data;
						 readdata_raw [PACKET_DIAG_FOUND_VALID_PACKET                       ] =  found_valid_packet;
						 readdata_raw [PACKET_DIAG_PACKET_LENGTH_AT_ERROR                   ] =  packet_length_at_error;
						 readdata_raw [PACKET_DIAG_NUM_PACKET_ERRORS                        ] =  num_packet_errors;
						 readdata_raw [PACKET_DIAG_PACKET_NUM_AT_ERROR                      ] =  packet_num_at_error;
						 readdata_raw [PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY           ]  =  num_delays_due_to_ready_capture           ;
						 readdata_raw [PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_VALID           ]  = num_delays_due_to_valid_capture            ;
						 readdata_raw [PACKET_DIAG_PACKET_NUM_DELAYS_DUE_TO_READY_AND_VALID ]  = num_delays_due_to_ready_and_valid_capture  ;	 
						 readdata_raw [PACKET_DIAG_S2S_READY_COUNT                          ] = s2s_ready_count_capture;                  
						 readdata_raw [PACKET_DIAG_S2S_VALID_COUNT                          ] = s2s_valid_count_capture;                 
						 readdata_raw [PACKET_DIAG_S2S_READY_AND_VALID_COUNT                ] = s2s_ready_and_valid_count_capture;
						 readdata_raw [PACKET_DIAG_S2S_NOT_READY_AND_NOT_VALID_COUNT        ] = s2s_not_ready_and_not_valid_count_capture;
					end


					for (i = 0; i < PACKET_DIAG_END_OF_DATA_CAPTURE_REGISTERS; i = i + 1) 
					begin : sync_readdata_raw_block
							my_multibit_clock_crosser_optimized_for_altera
							#(
							  .DATA_WIDTH(32),
							  .FORWARD_SYNC_DEPTH(synchronizer_depth),
							  .BACKWARD_SYNC_DEPTH(synchronizer_depth)   
							)
							sync_readdata_raw_to_avalon_mm_clk
							(
							   .in_clk(clk),
							   .in_valid(1'b1),
							   .in_data(readdata_raw[i]),
							   .out_clk(avalon_mm_clk),
							   .out_valid(),
							   .out_data(readdata_raw2[i])
							 );	  
					end
					
					for (j = PACKET_DIAG_COMPARED_PACKET_LENGTH_START; j < PACKET_DIAG_COMPARED_PACKET_LENGTH_START + NUM_COMPARED_PACKETS; j = j + 1) 
					begin : assign_compared_packet_to_avalon_mm_read
							assign readdata_raw2[j] = compared_packet_length[j-PACKET_DIAG_COMPARED_PACKET_LENGTH_START];
					end
		end
		assign readdata_raw2[NUM_AVMM_REGISTERS-1] = NUM_COMPARED_PACKETS;
endgenerate

 
// Output Registers
always_ff @(posedge avalon_mm_clk)
begin
	if (avalon_mm_reset)
	begin
		readdata <= 32'h00000000;
    end else
    begin
	      if (read)
		  begin
	            readdata <= readdata_raw2[address];
		  end		 
   end
end

 
// Internal Registers
always_ff @(posedge avalon_mm_clk)
begin
	if (avalon_mm_reset)
	begin
        control_reg <= 0;
	end
	else 
	begin
		  if (write)
          begin		
               if (address == 0)
			   begin
					if (byteenable[0])
						control_reg[ 7: 0] <= writedata[ 7: 0];
					if (byteenable[1])
						control_reg[15: 8] <= writedata[15: 8];
					if (byteenable[2])
						control_reg[23:16] <= writedata[23:16];
				    if (byteenable[3])
						control_reg[31:24] <= writedata[31:24];
			  end 				
		  end
	end
end

genvar compared_packet;
generate
         if (ENABLE_PACKET_STATISTICS)
		 begin
				   for (compared_packet = 0; compared_packet < NUM_COMPARED_PACKETS; compared_packet = compared_packet + 1)
				   begin : make_compared_packet_length_regs
							initial
							begin
								compared_packet_length[compared_packet] = DEFAULT_VALID_PACKET_LENGTH;
							end
					
							always_ff @(posedge avalon_mm_clk)
							begin
								if (avalon_mm_reset)
								begin
									compared_packet_length[compared_packet] <= DEFAULT_VALID_PACKET_LENGTH;
								end
								else 
								begin
									  if (write)
									  begin		
										   if (address == (PACKET_DIAG_COMPARED_PACKET_LENGTH_START+compared_packet))
										   begin
												if (byteenable[0])
													compared_packet_length[compared_packet][ 7: 0] <= writedata[ 7: 0];
												if (byteenable[1])
													compared_packet_length[compared_packet][15: 8] <= writedata[15: 8];
												if (byteenable[2])
													compared_packet_length[compared_packet][23:16] <= writedata[23:16];
												if (byteenable[3])
													compared_packet_length[compared_packet][31:24] <= writedata[31:24];
										  end 				
									  end
								end
							end
							
							
							my_multibit_clock_crosser_optimized_for_altera
							#(
							  .DATA_WIDTH(NUM_OF_COUNTER_BITS),        //note only passing relevant bits out of 32 total bits of compared_packet_length
							  .FORWARD_SYNC_DEPTH(synchronizer_depth),
							  .BACKWARD_SYNC_DEPTH(synchronizer_depth)    
							)
							sync_compared_packet_length_to_clk
							(
							   .in_clk(avalon_mm_clk),
							   .in_valid(1'b1),
							   .in_data(compared_packet_length[compared_packet]),
							   .out_clk(clk),
							   .out_valid(),
							   .out_data(synced_compared_packet_length[compared_packet])
							 );	 
								 
							always_ff @(posedge clk)
							begin
								  if (reset_statistics_counters)
								  begin
									   found_valid_packet[compared_packet] <= 0;
								  end else
								  begin
									   found_valid_packet[compared_packet] <=  ((num_of_packets > 0) &&  (valid_data_counter_capture == synced_compared_packet_length[compared_packet]));
								  end
							end	
							
							edge_detect 
							generate_found_valid_packet_pulse
							(
							.in_signal(found_valid_packet[compared_packet]), 
							.clk(clk), 
							.edge_detect(found_valid_packet_pulse[compared_packet])
							);											
							
				   end
		 end
endgenerate


logic packet_length_error_raw;
logic packet_error_sample_instant;
logic packet_error_sample_instant_pulse;

generate
			if (ENABLE_PACKET_STATISTICS)
			begin
					doublesync_no_reset //just for delay purposes
					delay_packet_error_sample_instant (
										.indata(currently_in_frame & in_ready & in_valid & in_endofpacket),
										.outdata (packet_error_sample_instant),
										.clk    (clk)
					);  

					edge_detect 
					generate_packet_length_error
					(
					.in_signal(packet_error_sample_instant), 
					.clk(clk), 
					.edge_detect(packet_error_sample_instant_pulse)
					);		

					always_ff @(posedge clk)
					begin
						 if (packet_error_sample_instant_pulse)
						 begin
							  packet_length_error <= (num_of_packets > 0) && (found_valid_packet == 0);	 
						 end else 
						 begin
							  packet_length_error <= 0;
						 end
					end
						

					always_ff @(posedge clk)
					begin
						  if (reset_statistics_counters)
						  begin
							   packet_length_at_error <= 0;
							   num_packet_errors <= 0;
							   packet_num_at_error <= 0;
						  end else
						  begin
								if (packet_length_error)
								begin
									  packet_length_at_error <= valid_data_counter_capture;
									  packet_num_at_error <= num_of_packets;
									  num_packet_errors <= num_packet_errors + 1;
								end							   
						  end
					end	
			end
endgenerate


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH($bits(control_reg)),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)   
)
sync_control_reg_to_clk
(
   .in_clk(avalon_mm_clk),
   .in_valid(1'b1),
   .in_data(control_reg),
   .out_clk(clk),
   .out_valid(),
   .out_data(synced_control_reg)
 );	   
  
endmodule
`default_nettype wire

