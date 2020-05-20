//---------------------------------------------------------------------------------------
// uart to internal bus top module 
//
//---------------------------------------------------------------------------------------
`default_nettype none
module uart2bus_top_for_wishbone 
(
	// global signals 
	clock, reset,
	// uart serial signals 
	ser_in, ser_out,
	// internal bus to register file 
	int_address, int_wr_data, int_write,
	int_rd_data, int_read, 
	int_req, int_gnt,
		ack,
	is_status_op, 
	is_info_op, 
	is_status_name_op,
	is_ctrl_name_op,
	error_count,
    main_sm,
    command_count,
    tx_sm,
    NUM_SECONDARY_UARTS,
    ADDRESS_OF_THIS_UART,
    IS_SECONDARY_UART,
	enable_watchdog,
	reset_watchdog,
	ignore_crc_value_for_debugging
);
//---------------------------------------------------------------------------------------
// modules inputs and outputs 
parameter       AW = 16; //address width
parameter       DATA_WIDTH_IN_BYTES = 1;
parameter       DESC_WIDTH_IN_BYTES = 1;
parameter       DESC_WIDTH = 8*DESC_WIDTH_IN_BYTES;
parameter		ACTUAL_DATA_WIDTH_IN_BYTES = (DESC_WIDTH_IN_BYTES > DATA_WIDTH_IN_BYTES) ?  DESC_WIDTH_IN_BYTES : DATA_WIDTH_IN_BYTES;	// data bus width parameter 
parameter		DW = 8*ACTUAL_DATA_WIDTH_IN_BYTES;			// data bus width parameter 
parameter       [0:0] USE_LEGACY_UART_PARSER= 0;
parameter       [0:0] COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0;

// baud rate configuration, see baud_gen.v for more details.
// baud rate generator parameters for 115200 baud on 50MHz clock 
parameter D_BAUD_FREQ			= 12'h240;
parameter D_BAUD_LIMIT		    = 16'h3AC9;

// baud rate configuration, see baud_gen.v for more details.
// baud rate generator parameters for 115200 baud on 40MHz clock 
// D_BAUD_FREQ			12'h90
// D_BAUD_LIMIT		16'h0ba5


// baud rate configuration, see baud_gen.v for more details.
// baud rate generator parameters for 9600 baud on 50MHz clock 
// D_BAUD_FREQ			12'd48
// D_BAUD_LIMIT		16'd15577


// baud rate generator parameters for 115200 baud on 44MHz clock 
// D_BAUD_FREQ			12'd23
// D_BAUD_LIMIT		16'd527
// baud rate generator parameters for 9600 baud on 66MHz clock 
// D_BAUD_FREQ		12'h10
// D_BAUD_LIMIT		16'h1ACB


input 			clock;			// global clock input 
input 			reset;			// global reset input 
input			ser_in;			// serial data input 
output			ser_out;		// serial data output 
output	[AW-1:0]	int_address;	// address bus to register file 
output	[DW-1:0]	int_wr_data;	// write data to register file 
output			int_write;		// write control to register file 
output			int_read;		// read control to register file 
input	[DW-1:0]	int_rd_data;	// data read from register file 
output			int_req;		// bus access request signal 
input			int_gnt;		// bus access grant signal 
input           ack;
output [31:0]    main_sm;
output [31:0]    tx_sm;
output [31:0]    command_count;
output is_status_op;
output is_info_op;  
output is_status_name_op;
output is_ctrl_name_op;
input wire [7:0] NUM_SECONDARY_UARTS;
input wire [7:0] ADDRESS_OF_THIS_UART;
input wire       IS_SECONDARY_UART;
 
output enable_watchdog;
output reset_watchdog;
output [31:0] error_count;
input ignore_crc_value_for_debugging;
// internal wires 
wire	[7:0]	tx_data;		// data byte to transmit 
wire			new_tx_data;	// asserted to indicate that there is a new data byte for transmission 
wire 			tx_busy;		// signs that transmitter is busy 
wire	[7:0]	rx_data;		// data byte received 
wire 			new_rx_data;	// signs that a new byte was received 
wire	[11:0]	baud_freq;
wire	[15:0]	baud_limit;
wire			baud_clk;

//---------------------------------------------------------------------------------------
// module implementation 
// uart top module instance 
uart_top
uart_inst
(
	.clock(clock), .reset(reset),
	.ser_in(ser_in), .ser_out(ser_out),
	.rx_data(rx_data), .new_rx_data(new_rx_data), 
	.tx_data(tx_data), .new_tx_data(new_tx_data), .tx_busy(tx_busy), 
	.baud_freq(baud_freq), .baud_limit(baud_limit),
	.baud_clk(baud_clk) 
);

// assign baud rate default values 
assign baud_freq  = D_BAUD_FREQ;
assign baud_limit = D_BAUD_LIMIT;

generate
				if (USE_LEGACY_UART_PARSER)
				begin
// uart parser instance 
uart_parser_for_wishbone #(
.AW(AW),
.DATA_WIDTH_IN_BYTES(ACTUAL_DATA_WIDTH_IN_BYTES)
)
uart_parser1
(
	.clock(clock), .reset(reset),
	.rx_data(rx_data), .new_rx_data(new_rx_data), 
	.tx_data(tx_data), .new_tx_data(new_tx_data), .tx_busy(tx_busy), 
	.int_address(int_address), .int_wr_data(int_wr_data), .int_write(int_write),
	.int_rd_data(int_rd_data), .int_read(int_read), 
	.int_req(int_req), .int_gnt(int_gnt),
	.ack(ack),
	.is_status_op(is_status_op), 
	.is_info_op  (is_info_op), 
    .is_status_name_op  (is_status_name_op),
    .is_ctrl_name_op    (is_ctrl_name_op)	,
    .main_sm(main_sm),
	.tx_sm(tx_sm),
//	.error_count(error_count),
    .command_count(command_count),
	.NUM_SECONDARY_UARTS   (NUM_SECONDARY_UARTS  ),
    .ADDRESS_OF_THIS_UART  (ADDRESS_OF_THIS_UART ),
    .IS_SECONDARY_UART     (IS_SECONDARY_UART    ),
	.enable_watchdog(enable_watchdog),
	.reset_watchdog(reset_watchdog)	
);
end else
		begin
	                      // uart parser instance 
							uart_parser_w_crc
							 #(
							.AW(AW),
							.DATA_WIDTH_IN_BYTES(ACTUAL_DATA_WIDTH_IN_BYTES),
							.COMPILE_CRC_ERROR_CHECKING_IN_PARSER(COMPILE_CRC_ERROR_CHECKING_IN_PARSER)
							) uart_parser1
							(
							   .ignore_crc_value_for_debugging(ignore_crc_value_for_debugging),
							   .use_crc_error_checking_in_parser(COMPILE_CRC_ERROR_CHECKING_IN_PARSER),
								.clock(clock), .reset(reset),
								.rx_data(rx_data), .new_rx_data(new_rx_data), 
								.tx_data(tx_data), .new_tx_data(new_tx_data), .tx_busy(tx_busy), 
								.int_address(int_address), .int_wr_data(int_wr_data), .int_write(int_write),
								.int_rd_data(int_rd_data), .int_read(int_read), 
								.int_req(int_req), .int_gnt(int_gnt),
								.is_status_op(is_status_op), 
								.is_info_op  (is_info_op), 
								 .is_status_name_op  (is_status_name_op),
								 .is_ctrl_name_op    (is_ctrl_name_op)	,
								 .main_sm(main_sm),
								.tx_sm(tx_sm),
								.error_count(error_count),
                                .use_ack(1'b1),
                                 .ack(ack),
								 .command_count(command_count),
								.NUM_SECONDARY_UARTS   (NUM_SECONDARY_UARTS  ),
								 .ADDRESS_OF_THIS_UART  (ADDRESS_OF_THIS_UART ),
								 .IS_SECONDARY_UART     (IS_SECONDARY_UART    ),
								.enable_watchdog(enable_watchdog),
								.reset_watchdog(reset_watchdog)	
							);
     end

endgenerate
endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
`default_nettype wire
