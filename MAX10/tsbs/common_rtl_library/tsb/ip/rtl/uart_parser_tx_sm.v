`default_nettype none
module uart_parser_tx_sm 
(
	// global signals 
	clock, reset,
	tx_data, new_tx_data, tx_busy, 
	was_read_op,
	start,
	finish,
	state,
    crc_enable,
    crc_reset,
    calculated_crc,
	data_to_transmit,
	use_crc_error_checking_in_parser,
	tx_nib_counter, 
	crc_nib_counter,
	inc_crc_nibble_counter,
	crc_nibble,
	tx_nibble,
	crc_char
);
//---------------------------------------------------------------------------------------
// parameters 
parameter       DATA_WIDTH_IN_BYTES = 4;
parameter       COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0;
localparam		DW = 8*DATA_WIDTH_IN_BYTES;			// data bus width parameter 
localparam      CRC_NUM_BYTES = 2;

// modules inputs and outputs 
input 			clock;			// global clock input 
input 			reset;			// global reset input 
input 			was_read_op;			// global reset input 
output	[7:0]	tx_data;		// data byte to transmit 
output			new_tx_data;	// asserted to indicate that there is a new data byte for
								// transmission 
input 			tx_busy;		// signs that transmitter is busy 
input start;
output finish;
input [DW-1:0] data_to_transmit;		// sampled read data 

input use_crc_error_checking_in_parser;
output logic crc_enable;
output logic crc_reset;
output logic [15:0] calculated_crc;
output reg [7:0] tx_nib_counter = 0;
output reg [2:0] crc_nib_counter = 0;
output logic inc_crc_nibble_counter;
output reg [3:0] tx_nibble;		// nibble value for transmission 
output reg [3:0] crc_nibble;
output [7:0] crc_char;

logic [1:0] sel_data;
logic inc_nibble_counter;
logic reset_nibble_counter;
logic reset_crc_nibble_counter;
import ascii_package::*;

// registered outputs
reg	[7:0] tx_data;
reg new_tx_data;

// internal constants 
// define characters used by the parser 


localparam idle                                     =           16'b0000_0000_0000_0000;
localparam start_calculate_crc                      =           16'b0100_1000_0100_0001;
localparam wait_calculate_crc                       =           16'b1111_1100_0100_0010;
localparam send_crc_nibble                          =           16'b0111_1010_0100_0011;
localparam wait_crc_nibble                          =           16'b0111_1000_0100_0100;
localparam inc_crc_nibble_count                     =           16'b0111_1000_1100_0101;
localparam prepare_to_send_data                     =           16'b0100_0000_0100_0110;
localparam send_nibble                              =           16'b0100_1010_0100_0111;
localparam wait_nibble                              =           16'b0100_1000_0100_1000;
localparam inc_nibble_counter_state                 =           16'b0100_1100_0100_1001;
localparam send_cr                                  =           16'b0101_1010_0100_1010;
localparam wait_send_cr                             =           16'b0101_1000_0100_1011;
localparam send_lf                                  =           16'b0110_1010_0100_1100;
localparam wait_send_lf                             =           16'b0110_1000_0100_1101;
localparam finished                                 =           16'b0000_0001_0000_1110;

output reg [15:0] state = idle;			// main state machine 

assign    reset_crc_nibble_counter         = !state[6];
assign    inc_crc_nibble_counter           = state[7];
assign    finish                           = state[8] ;
assign    new_tx_data                      = state[9] ;
assign    inc_nibble_counter               = state[10] ;
assign    reset_nibble_counter             = !state[11];
assign    sel_data[1:0]                    = state[13:12];
assign    crc_reset                        = !state[14];
assign    crc_enable                       = state[15];


reg [7:0] tx_char;			// transmit byte from nibble to character conversion 
reg s_tx_busy;				// sampled tx_busy for falling edge detection 
logic tx_end_p;				// transmission end pulse 

always_ff @(posedge clock)
begin 
	if (reset)
	begin
		state <= idle;
	end
	else 
	begin 
		case (state)
		     idle: if (start)
			       begin
				         if (use_crc_error_checking_in_parser) 
						 begin
						         state <= start_calculate_crc;
						 end else
								 begin
								 if (was_read_op)
								 begin
									  state <= send_nibble;				   
								 end else
								 begin
									  state <= send_cr;
								 end
						 end
				   end
				   
			   start_calculate_crc  : if (!was_read_op)
			                          begin
									       state <= send_crc_nibble;
									  end else
									  begin
									        state <= wait_calculate_crc;
									  end
									 
									
			   wait_calculate_crc : if (tx_nib_counter >= ((DATA_WIDTH_IN_BYTES*2)-1)) 
									begin
										  state <= send_crc_nibble;
									end			
									
			   send_crc_nibble  : state <= wait_crc_nibble;		   
			   wait_crc_nibble  : if (tx_end_p)
								  begin
									   if (crc_nib_counter >= ((CRC_NUM_BYTES*2)-1)) 
									   begin
											 state <= prepare_to_send_data;
									   end else
									   begin
											state <= inc_crc_nibble_count;
									   end
								  end						   
			   inc_crc_nibble_count  : state <= send_crc_nibble;
			   
			   prepare_to_send_data  :   if (was_read_op)
										 begin
											  state <= send_nibble;				   
										 end else
										 begin
											  state <= send_cr;
										 end        							   				   
				   
			   send_nibble: state <= wait_nibble;
			   
			   wait_nibble : if (tx_end_p)
                             begin
							       if (tx_nib_counter >= ((DATA_WIDTH_IN_BYTES*2)-1)) 
								   begin
								         state <= send_cr;
								   end else
								   begin
								        state <= inc_nibble_counter_state;
								   end
							 end
							 
			   inc_nibble_counter_state : state <= send_nibble;

			   send_cr: state <= wait_send_cr;
			   wait_send_cr:  if (tx_end_p)
                             begin 
							        state <= send_lf;
							 end
							 
			    send_lf: state <= wait_send_lf;
			    wait_send_lf:  if (tx_end_p)
                             begin 
							        state <= finished;
							 end
							 			 
			    finished : state <= idle;
			  		  
			endcase
		end
end

assign tx_nibble = data_to_transmit[(((DATA_WIDTH_IN_BYTES*2)-tx_nib_counter)<<2)-1 -: 4];
assign crc_nibble = calculated_crc[(((CRC_NUM_BYTES*2)-crc_nib_counter)<<2)-1 -: 4];

always_comb
begin
     case (sel_data)
	      2'b00: tx_data = tx_char;
          2'b01: tx_data = CHAR_CR;
          2'b10: tx_data = CHAR_LF;
          2'b11: tx_data = crc_char;
	 endcase
 end

 always_ff @(posedge clock)
begin 
	if (reset_nibble_counter)
	begin
		tx_nib_counter <= 1'b0;		
	end else 
	begin
		if (inc_nibble_counter)
		begin
			tx_nib_counter <= tx_nib_counter + 1;
		end
	end
end 

always_ff @(posedge clock)
begin 
	if (reset_crc_nibble_counter)
	begin
		crc_nib_counter <= 1'b0;		
	end else 
	begin
		if (inc_crc_nibble_counter)
		begin
			crc_nib_counter <= crc_nib_counter + 1;
		end
	end
end 

// sampled tx_busy 
always_ff @(posedge clock)
begin 
	if (reset)
		s_tx_busy <= 1'b0;
	else 
		s_tx_busy <= tx_busy;
end 
// tx end pulse 
assign tx_end_p = ~tx_busy & s_tx_busy;

// nibble to character conversion 
always_comb
begin 
	case (tx_nibble)
		4'h0:	 tx_char = CHAR_0;
		4'h1:	 tx_char = CHAR_1;
		4'h2:	 tx_char = CHAR_2;
		4'h3:	 tx_char = CHAR_3;
		4'h4:	 tx_char = CHAR_4;
		4'h5:	 tx_char = CHAR_5;
		4'h6:	 tx_char = CHAR_6;
		4'h7:	 tx_char = CHAR_7;
		4'h8:	 tx_char = CHAR_8;
		4'h9:	 tx_char = CHAR_9;
		4'ha:	 tx_char = CHAR_A_UP;
		4'hb:	 tx_char = CHAR_B_UP;
		4'hc:	 tx_char = CHAR_C_UP;
		4'hd:	 tx_char = CHAR_D_UP;
		4'he:	 tx_char = CHAR_E_UP;
		default: tx_char = CHAR_F_UP;
	endcase 
end 

// nibble to character conversion 
always_comb
begin 
	case (crc_nibble)
		4'h0:	 crc_char = CHAR_0;
		4'h1:	 crc_char = CHAR_1;
		4'h2:	 crc_char = CHAR_2;
		4'h3:	 crc_char = CHAR_3;
		4'h4:	 crc_char = CHAR_4;
		4'h5:	 crc_char = CHAR_5;
		4'h6:	 crc_char = CHAR_6;
		4'h7:	 crc_char = CHAR_7;
		4'h8:	 crc_char = CHAR_8;
		4'h9:	 crc_char = CHAR_9;
		4'ha:	 crc_char = CHAR_A_UP;
		4'hb:	 crc_char = CHAR_B_UP;
		4'hc:	 crc_char = CHAR_C_UP;
		4'hd:	 crc_char = CHAR_D_UP;
		4'he:	 crc_char = CHAR_E_UP;
		default: crc_char = CHAR_F_UP;
	endcase 
end 

parallel_crc_ccitt
#(
.USE_SYNC_RESET(1)
) 
calculate_tx_crc(
.clk     (clock),
.reset   (crc_reset),
.enable  (crc_enable),
.init    (1'b0), 
.data_in (tx_char), 
.crc_out (calculated_crc)
);



endmodule
`default_nettype wire