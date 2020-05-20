`default_nettype none
module FSMD_XCVR_CHAR_CONTROL_AND_8b10

#( 
 parameter device_family = "Cylcone III",
 parameter num_data_output_fifo_locations = 16,
 parameter input_to_output_bitwidth_ratio = 4,
 parameter out_data_bits_per_channel = 8,
 parameter control_chars_width = 8,
 parameter control_char_fifo_depth = 64
) (
			
			input [7:0] padding_char,

			//FIFO side from the ~7 Mhz
			input wrclk_fifo_xcvr,
			input wrreq_fifo_xcvr,
			input [31:0]data_fifo_xcvr,
			output full_fifo_xcvr,
			
			input wrclk_fifo_character_queue,
			input wrreq_fifo_character_queue,
			input [7:0]data_fifo_character_queue,
			output full_fifo_character_queue,
			
			//system clk
			input x6_clk,//
			input x1_clk,
			output [9:0]tbi_encoder,
			output busy,
			output enable_data_out,
			
			//debug output
			output wire fifo_read_xcvr_sig,
			output wire fifo_empty_xcvr_sig,
			output wire [7:0]data_fifo_xcvr_sig,
			output wire [7:0]data_fifo_character_queue_out,
			output wire fifo_read_character_queue_sig,
			output wire fifo_empty_character_queue_sig,
			output wire is_control_char,
			output wire is_padding_char,
			output wire [7:0] from_FSM2_8b10,
			output reg  [7:0] actual_uncoded_8b10b_out,
			output reg actual_is_padding_char,
			output reg actual_is_control_char			
);



wire sync_x1_clk;
async_trap_and_reset x1_clk_2_6x_clk_sync
(
	.async_sig(x1_clk) ,	// input  async_sig_sig
	.outclk(x6_clk) ,	// input  outclk_sig
	.out_sync_sig(sync_x1_clk) ,	// output  out_sync_sig_sig
	.auto_reset(1'b1) ,	// input  auto_reset_sig
	.reset(1'b1) 	// input  reset_sig
);

parameterized_daq_fifo
#(
.device_family(device_family),
.num_output_locations(num_data_output_fifo_locations),
.input_to_output_ratio(input_to_output_bitwidth_ratio),
.num_output_bits(out_data_bits_per_channel),
.use_better_metastability_performance(0)
)
data_fifo
 (
.data       (  data_fifo_xcvr ),
.rdclk      ( x6_clk ),
.rdreq      ( fifo_read_xcvr_sig ),
.wrclk      ( wrclk_fifo_xcvr ),
.wrreq      ( wrreq_fifo_xcvr ),
.q          ( data_fifo_xcvr_sig ),
.rdempty    ( fifo_empty_xcvr_sig ),
.rdfull     ( ),
.wrempty    ( ),
.wrfull     ( full_fifo_xcvr ),
.wrusedw    ( )
);	

/*
fifo_XCVR	Fifo_XCVR_inst (

	.data ( data_fifo_xcvr[31:0]),
	.wrclk ( wrclk_fifo_xcvr ),
	.wrreq ( wrreq_fifo_xcvr ),
	.wrfull ( full_fifo_xcvr),
	
	//read side
	.rdclk ( x6_clk ),
	.rdreq ( fifo_read_xcvr_sig ),
	.q ( data_fifo_xcvr_sig[7:0] ),
	.rdempty ( fifo_empty_xcvr_sig )

	);
*/

parameterized_daq_fifo
#(
.device_family(device_family),
.num_output_locations(control_char_fifo_depth),
.input_to_output_ratio(1),
.num_output_bits(control_chars_width),
.use_better_metastability_performance(0)
)
character_control_queue
 (
.data       ( data_fifo_character_queue ),
.rdclk      ( x6_clk ),
.rdreq      ( fifo_read_character_queue_sig ),
.wrclk      ( wrclk_fifo_character_queue ),
.wrreq      ( wrreq_fifo_character_queue ),
.q          ( data_fifo_character_queue_out ),
.rdempty    ( fifo_empty_character_queue_sig ),
.rdfull     ( ),
.wrempty    ( ),
.wrfull     ( full_fifo_character_queue ),
.wrusedw    ( )
);	
/*
UART_Fifo	character_control_ (
	
		//Read side
	.q ( data_fifo_character_queue_out[7:0] ),// 8 bits
	.rdclk (  x6_clk),
	.rdreq ( fifo_read_character_queue_sig ),	
	.rdempty (  fifo_empty_character_queue_sig),
	
	//Write side
	.wrclk ( wrclk_fifo_character_queue ),
	.wrreq ( wrreq_fifo_character_queue ),
	.data ( data_fifo_character_queue[7:0] ),//8 bits
	.wrempty (  ),
	.wrfull (  full_fifo_character_queue),
	.wrusedw (  )
	); 	
*/

FSMD_Gather_scatter FSM_Gather_scatter_inst
(
	.clk_fsm(x6_clk) ,	// input  clk__sig
	.sending_clk_sync(sync_x1_clk),
	//XCVR FIFO SIDE
	.data_fifo_xcvr(data_fifo_xcvr_sig[7:0]) ,	// input [7:0] data_fifo_xcvr_sig
	.fifo_empty_xcvr(fifo_empty_xcvr_sig) ,	// input  fifo_empty_xcvr_sig
	.fifo_read_xcvr(fifo_read_xcvr_sig) ,	// output  fifo_read_xcvr_sig
	
	//CHARACTER CONTROL FIFO SIDE
	.data_fifo_uart(data_fifo_character_queue_out[7:0]) ,	// input [7:0] data_fifo_uart_sig
	.fifo_empty_uart(fifo_empty_character_queue_sig) ,	// input  fifo_empty_uart_sig
	.fifo_read_uart(fifo_read_character_queue_sig) ,	// output  fifo_read_uart_sig
    .padding_char(padding_char),
    .is_padding_char (is_padding_char),
	//TO 8b10Encoder
	.data_8b10(from_FSM2_8b10[7:0]) ,	// output [8:0] to_8b10_sig
	.is_control_char(is_control_char) ,	// output  is_control_char_sig
	.enable_data_out(enable_data_out) ,	// output  valid_data_sig
	.busy(busy) 	// output  busy_sig
);

always @(posedge x1_clk)
begin
     actual_uncoded_8b10b_out <= from_FSM2_8b10;
     actual_is_control_char   <= is_control_char;
     actual_is_padding_char   <= is_padding_char;
end

encoder_8b10b encoder_8b10b_inst
(
	.reset(1'b0) ,	// input  reset_sig
	.SBYTECLK(x1_clk) ,	// normal clock
	.K(actual_is_control_char) ,	// input  K_sig
	.ebi(actual_uncoded_8b10b_out) ,	// input [7:0] ebi_sig
	.tbi(tbi_encoder[9:0]) ,	// output [9:0] tbi_sig
	.disparity() 	// output  disparity_sig
); 

	
	
endmodule
`default_nettype wire