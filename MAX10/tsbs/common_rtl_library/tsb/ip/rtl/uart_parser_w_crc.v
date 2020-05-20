`default_nettype none
module uart_parser_w_crc
(
	// global signals 
	clock, reset,
	// transmit and receive internal interface signals from uart interface 
	rx_data, new_rx_data, 
	tx_data, new_tx_data, tx_busy, 
	// internal bus to register file 
	int_address, int_wr_data, int_write,
	int_rd_data, int_read, 
	int_req, int_gnt,
	is_status_op, 
	is_info_op, 
	is_ctrl_name_op, 
	is_status_name_op, 
    main_sm,
    command_count,
    error_count,
    tx_sm,
    NUM_SECONDARY_UARTS,
    ADDRESS_OF_THIS_UART,
    IS_SECONDARY_UART,
	enable_watchdog,
	reset_watchdog,
	crc_enable,
	actual_crc_enable,
    crc_enable_conditional,
    calculated_crc,
    received_crc,
    crc_reset,
	state,
	finish,
	valid_read_type_command_char_encountered,
	valid_write_type_command_char_encountered,
	valid_eol_type_command_char_encountered,
	valid_uart_addr_command_char_encountered,
	valid_whitespace_command_char_encountered,
	use_crc_error_checking_in_parser,
	shift_in_crc_nibble,
	ignore_crc_value_for_debugging,
	use_ack,
	ack
);
//---------------------------------------------------------------------------------------
// parameters 
parameter		AW = 8;			// address bus width parameter 
parameter		UART_ADDRESS_BITS = 8;			// address bus width parameter 
parameter       DATA_WIDTH_IN_BYTES = 4;
localparam   	DW = 8*DATA_WIDTH_IN_BYTES;			// data bus width parameter 
parameter [0:0] COMPILE_CRC_ERROR_CHECKING_IN_PARSER = 0;
parameter       READ_AND_WRITE_WAIT_CYCLES  = 4;
parameter       WAIT_COUNTER_WIDTH = 8;


// modules inputs and outputs 
input 			clock;			// global clock input 
input 			reset;			// global reset input 
output	[7:0]	tx_data;		// data byte to transmit 
output			new_tx_data;	// asserted to indicate that there is a new data byte for
								// transmission 
input 			tx_busy;		// signs that transmitter is busy 
input	[7:0]	rx_data;		// data byte received 
input 			new_rx_data;	// signs that a new byte was received 
output	[AW-1:0] int_address;	// address bus to register file 
output	[DW-1:0] int_wr_data;	// write data to register file 
output			 int_write;		// write control to register file 
output			 int_read;		// read control to register file 
input	[DW-1:0]	int_rd_data;	// data read from register file 
output			int_req;		// bus access request signal 
input			int_gnt;		// bus access grant signal 
input           ignore_crc_value_for_debugging;
input  use_ack;
input  ack;



output [31:0]    tx_sm;
output [31:0]    command_count;
output [31:0]    error_count;
output is_status_op; 
output is_info_op;
output is_ctrl_name_op;
output is_status_name_op;
output enable_watchdog;
output reset_watchdog;
output logic crc_enable;
output logic actual_crc_enable;
output logic crc_reset;
output logic crc_enable_conditional;
output logic [15:0] calculated_crc;
output logic [15:0] received_crc;
output logic [31:0] main_sm;
output logic shift_in_crc_nibble;
output finish;

input wire [7:0] NUM_SECONDARY_UARTS;
input wire [7:0] ADDRESS_OF_THIS_UART;
input wire       IS_SECONDARY_UART;
input use_crc_error_checking_in_parser;
 
import ascii_package::*;


reg is_read_op = 0; 
reg is_status_op = 0; 
reg is_info_op = 0;
reg is_ctrl_name_op = 0;
reg is_status_name_op = 0;

logic is_status_op_raw; 
logic is_info_op_raw;
logic is_ctrl_name_op_raw;
logic is_status_name_op_raw;


logic	[7:0] tx_data;
logic	[AW-1:0] int_address;
logic	[DW-1:0] int_wr_data;
logic int_write;
logic int_read;
logic tx_sm_start;
logic tx_response_finished;

logic reset_data_param;
logic reset_addr_param;
logic shift_in_address_nibble;
logic shift_in_data_nibble;
logic capture_read_data;
logic reset_uart_addr_param;
logic shift_in_uart_address_nibble;    
logic enable_command_parameter_capture;
logic inc_error_count;    
logic inc_command_count;    
	
logic wait_counter_finished;
logic wait_counter_ready;
logic start_wait_counter;

logic [WAIT_COUNTER_WIDTH-1:0] wait_cycles;

output logic valid_read_type_command_char_encountered;
output logic valid_write_type_command_char_encountered;
output logic valid_eol_type_command_char_encountered;
output logic valid_uart_addr_command_char_encountered;
output logic valid_whitespace_command_char_encountered;

assign valid_read_type_command_char_encountered =   ((rx_data == CHAR_s_LO) | (rx_data == CHAR_S_UP) | 
													 (rx_data == CHAR_i_LO) | (rx_data == CHAR_I_UP) | 
													 (rx_data == CHAR_r_LO) | (rx_data == CHAR_R_UP) | 
													 (rx_data == CHAR_s_LO) | (rx_data == CHAR_S_UP) | 
													 (rx_data == CHAR_n_LO) | (rx_data == CHAR_N_UP) | 
													 (rx_data == CHAR_m_LO) | (rx_data == CHAR_M_UP));
						 
						 
assign valid_write_type_command_char_encountered =  ((rx_data == CHAR_w_LO) | (rx_data == CHAR_W_UP));

assign  valid_eol_type_command_char_encountered = ((rx_data == CHAR_CR) | (rx_data == CHAR_LF));

assign valid_uart_addr_command_char_encountered = ((rx_data == CHAR_u_LO) | (rx_data == CHAR_U_UP));

assign valid_whitespace_command_char_encountered = ((rx_data == CHAR_SPACE) | (rx_data == CHAR_TAB));


assign is_status_op_raw       = ((rx_data == CHAR_s_LO) | (rx_data == CHAR_S_UP));
assign is_info_op_raw         = ((rx_data == CHAR_i_LO) | (rx_data == CHAR_I_UP));
assign is_ctrl_name_op_raw    = ((rx_data == CHAR_n_LO) | (rx_data == CHAR_N_UP));
assign is_status_name_op_raw  = ((rx_data == CHAR_m_LO) | (rx_data == CHAR_M_UP));
				

parameter idle                                         =           32'b0000_0000_0000_0000_0000_0000_0000_0000;
parameter check_first_char                             =           32'b0000_1000_0100_0110_1110_0000_0000_0001;
parameter primary_uart_check_first_char                =           32'b0000_1100_0100_0110_0110_1000_0000_0010;
parameter parse_uart_address                           =           32'b0000_1000_0100_0111_0110_0000_0000_0011; 
parameter parse_uart_addr_shift_in_uart_address_nibble =           32'b0000_1000_1100_0110_0110_0000_0000_0100;
parameter parse_uart_addr_wait_for_next_nibble         =           32'b0000_1000_0100_0111_0110_0000_0000_0101;
parameter check_if_uart_address_matches                =           32'b0000_1000_0100_0110_0110_0000_0000_0110;
parameter addressed_uart_incr_command_count            =           32'b0000_1100_0100_0110_0110_0000_0000_0111;
parameter addressed_uart_check_first_char              =           32'b0000_1000_0100_0111_0110_1000_0000_1000;
parameter read_op_start_read_operation                 =           32'b0000_1000_0100_0110_0110_0000_0000_1001;
parameter read_op_wait_for_address                     =           32'b0000_1000_0100_0111_0110_0000_0000_1010;
parameter read_op_shift_in_address_nibble              =           32'b0000_1000_0100_1110_0110_0000_0000_1011;
parameter read_op_wait_for_next_nibble                 =           32'b0000_1000_0100_0111_0110_0000_0000_1100;
parameter read_op_process_valid_read_command           =           32'b0000_1000_0100_0110_0110_0000_0000_1101;
parameter read_op_assert_read_signals                  =           32'b0000_1000_0100_0110_0110_0100_0000_1110;
parameter read_op_start_read_wait_counter              =           32'b0000_1010_0100_0110_0110_0100_0000_1111;
parameter read_op_wait_read_wait_counter               =           32'b0000_1000_0100_0110_0110_0100_0000_0000;
parameter read_op_command_wrapup                       =           32'b0000_1000_0100_0110_0111_0000_0001_0001;
parameter write_op_start_write_operation               =           32'b0000_1000_0100_0110_0110_0000_0001_0010;
parameter write_op_wait_for_data                       =           32'b0000_1000_0100_0111_0110_0000_0001_0011;
parameter write_op_shift_in_data_nibble                =           32'b0000_1000_0101_0110_0110_0000_0001_0100;
parameter write_op_wait_for_address                    =           32'b0000_1000_0100_0111_0110_0000_0001_0101;
parameter write_op_shift_in_address_nibble             =           32'b0000_1000_0100_1110_0110_0000_0001_0110;
parameter write_op_wait_for_next_data_nibble           =           32'b0000_1000_0100_0111_0110_0000_0001_0111;
parameter write_op_wait_for_address_nibble             =           32'b0000_1000_0100_0111_0110_0000_0001_1000;
parameter write_op_process_valid_write_command         =           32'b0000_1000_0100_0110_0110_0000_0001_1001;
parameter write_op_assert_write_signals                =           32'b0000_1000_0100_0110_0110_0010_0001_1010;
parameter write_op_start_write_wait_counter            =           32'b0000_1010_0100_0110_0110_0010_0001_1011;
parameter write_op_wait_write_wait_counter             =           32'b0000_1000_0100_0110_0110_0010_0001_1100;
parameter write_op_command_wrapup                      =           32'b0000_1000_0100_0110_0110_0000_0001_1101;
parameter write_op_tx_response_start                   =           32'b0000_1000_0110_0110_0110_0000_0001_1110;
parameter write_op_tx_response_wait                    =           32'b0000_1000_0100_0110_0110_0000_0001_1111;
parameter read_op_tx_response_start                    =           32'b0000_1000_0110_0110_0110_0000_0001_0000;
parameter read_op_tx_response_wait                     =           32'b0000_1000_0100_0110_0110_0000_0001_0001;
parameter record_command_error                         =           32'b0000_1001_0100_0110_0110_0000_0010_0010;
parameter wait_for_eol                                 =           32'b0000_1000_0100_0110_0110_0000_0010_0011;
parameter crc_process_wait_for_crc                     =           32'b0000_1000_0100_0110_0110_0000_0010_0100;
parameter crc_process_shift_in_crc_nibble              =           32'b0001_1000_0100_0110_0110_0000_0010_0101;
parameter crc_process_wait_for_next_crc_nibble         =           32'b0000_1000_0100_0110_0110_0000_0010_0110;
parameter check_crc_to_see_if_valid_command            =           32'b0000_1000_0100_0110_0110_0000_0010_0111;
parameter record_command_error_without_waiting_for_eol =           32'b0000_1001_0100_0110_0110_0000_0010_1001;
parameter finished                                     =           32'b0000_0000_0000_0000_0000_0001_0010_1000;

output reg [31:0] state = idle;			// main state machine 
assign main_sm = state;

assign    finish                           = state[8] ;
assign    int_write                        = state[9] ;
assign    int_read                         = state[10];
assign    enable_command_parameter_capture = state[11];
assign    capture_read_data                = state[12];
assign    enable_watchdog                  = state[13];
assign    reset_watchdog                   = !state[14];
assign    crc_enable                       = state[15];
assign    crc_enable_conditional           = state[16];
assign    reset_data_param                 = !state[17];
assign    reset_addr_param                 = !state[18];
assign    shift_in_address_nibble          = state[19];
assign    shift_in_data_nibble             = state[20];
assign    tx_sm_start                      = state[21];
assign    reset_uart_addr_param            = !state[22];
assign    shift_in_uart_address_nibble     = state[23];
assign    inc_error_count                  = state[24];
assign    start_wait_counter               = state[25];
assign    inc_command_count                = state[26];
assign    crc_reset                        = !state[27];
assign    shift_in_crc_nibble              = state[28];

always_ff @ (posedge clock)
begin
     if (enable_command_parameter_capture)
	 begin
	       is_read_op                <= valid_read_type_command_char_encountered;
		   is_status_op              <= is_status_op_raw      ;
		   is_info_op                <= is_info_op_raw        ;
		   is_ctrl_name_op           <= is_ctrl_name_op_raw   ;
		   is_status_name_op         <= is_status_name_op_raw ;
	 end 
end

// internal wires and registers 
logic data_in_hex_range;		// indicates that the received data is in the range of hex number 
logic [DW-1:0] data_param;		// operation data parameter 
logic [AW-1:0] addr_param;		// operation address parameter 
logic [UART_ADDRESS_BITS-1:0] uart_addr_param;		// operation address parameter 
logic [3:0] data_nibble;		// data nibble from received character 
logic [DW-1:0] read_data_s;		// sampled read data 
logic [31:0] command_count;
logic [31:0] error_count;
    

// indicates that the received data is in the range of hex number 
always_comb
begin 
	if (((rx_data >= CHAR_0   ) && (rx_data <= CHAR_9   )) || 
	    ((rx_data >= CHAR_A_UP) && (rx_data <= CHAR_F_UP)) || 
	    ((rx_data >= CHAR_a_LO) && (rx_data <= CHAR_f_LO)))
		data_in_hex_range = 1'b1;
	else 
		data_in_hex_range = 1'b0;
end 

assign wait_cycles = READ_AND_WRITE_WAIT_CYCLES;

programmable_wait_synchronous
#(
   .width(WAIT_COUNTER_WIDTH)
) 
wait_cycle_counter 
( 
 .clk(clock),
 .reset,
 .start(start_wait_counter),
 .wait_cycles,
 .ready(wait_counter_ready),
 .finish(wait_counter_finished)
 );

uart_parser_tx_sm
#(
.DATA_WIDTH_IN_BYTES(DATA_WIDTH_IN_BYTES),
.COMPILE_CRC_ERROR_CHECKING_IN_PARSER(COMPILE_CRC_ERROR_CHECKING_IN_PARSER)
)
uart_parser_tx_sm_inst 
(
	// global signals 
	.clock, 
	.reset,
	.tx_data, 
	.new_tx_data, 
	.tx_busy, 
	.was_read_op(is_read_op),
	.start(tx_sm_start),
	.finish(tx_response_finished),
	.state(tx_sm),
    .crc_enable(),
    .calculated_crc(),
	.data_to_transmit(read_data_s),
	.use_crc_error_checking_in_parser
);


always @ (posedge clock)
begin 
	if (reset)
	begin
		state <= idle;
	end
	else 
	begin 
		case (state)
		     idle: if (new_rx_data)
			       begin
				         if ((!valid_whitespace_command_char_encountered) && (!valid_eol_type_command_char_encountered))
						 begin
				              state <= check_first_char;				   
						 end
				   end
			check_first_char:  if (valid_uart_addr_command_char_encountered)
							    begin
									        state <= parse_uart_address;
							    end else
								begin
            								if (!IS_SECONDARY_UART)	
											begin
												   state <= primary_uart_check_first_char;
											end	else
											begin
												state <= record_command_error;
											 end 
							    end
																
								
          	primary_uart_check_first_char : if (valid_read_type_command_char_encountered) 
                                            begin
                                                  state <= read_op_start_read_operation;
                                            end else 
											begin
                                                 if (valid_write_type_command_char_encountered)
												 begin
												      state <= write_op_start_write_operation;											 
												 end else
												 begin
													        state <= record_command_error;
												 end
											end	

        parse_uart_address : if (new_rx_data)
			                 begin								   
									    if (valid_whitespace_command_char_encountered)
										begin
											state <=  parse_uart_address;
										end else
										begin
												if (data_in_hex_range)
												begin
													state <= parse_uart_addr_shift_in_uart_address_nibble;
												end else
												begin
													state <= record_command_error;
												end
										end
							  end			
							  
							  
							  
			 parse_uart_addr_shift_in_uart_address_nibble : state <= parse_uart_addr_wait_for_next_nibble;

              parse_uart_addr_wait_for_next_nibble : if (new_rx_data)
													 begin
														if (valid_whitespace_command_char_encountered)
														begin
															state <=  check_if_uart_address_matches;
														end else 
														begin 
																if (data_in_hex_range)
																begin
																	state <= parse_uart_addr_shift_in_uart_address_nibble;
																end else
																begin
																	state <= record_command_error;
																end
														end
													 end
											 
			check_if_uart_address_matches : if (((!IS_SECONDARY_UART) && (uart_addr_param == 0))  || 
			                                    (IS_SECONDARY_UART &&  (uart_addr_param == ADDRESS_OF_THIS_UART)))
											begin
												  state <= addressed_uart_incr_command_count;				
											end else 
											begin
											      state <= wait_for_eol;
											end
		    
			addressed_uart_incr_command_count : state <= addressed_uart_check_first_char;	
			addressed_uart_check_first_char : if (new_rx_data)
											  begin
														  if (valid_whitespace_command_char_encountered)
														  begin
																state <=  addressed_uart_check_first_char;
														  end else 
														  begin
																  if (valid_read_type_command_char_encountered) 
																  begin
																	  state <= read_op_start_read_operation;
																  end else 
																  begin
																		  if (valid_write_type_command_char_encountered)
																		 begin
																			  state <= write_op_start_write_operation;											 
																		 end else
																		 begin
																			   state <= record_command_error;														  
																		 end
																 end	
														end
											end
			read_op_start_read_operation :  state <= read_op_wait_for_address; //here record type of read operation
		
				
		    read_op_wait_for_address:       if (new_rx_data)
											begin
													if (valid_whitespace_command_char_encountered)
													begin
														state <=  read_op_wait_for_address;
													end else 
													begin 
															if (data_in_hex_range)
															begin
																state <= read_op_shift_in_address_nibble;																
															end else
															begin
																state <= record_command_error;
															end
													end
											end
										
              read_op_shift_in_address_nibble : state <= read_op_wait_for_next_nibble;

              read_op_wait_for_next_nibble : if (new_rx_data)
			                                 begin
												if (valid_eol_type_command_char_encountered)
												begin
												    if (use_crc_error_checking_in_parser)
													begin
													     state <= record_command_error_without_waiting_for_eol;
													end else
													begin
												     	state <=  read_op_process_valid_read_command;
													end
												end else 
												begin 
														if (data_in_hex_range)
														begin
															state <= read_op_shift_in_address_nibble;
														end else
														begin
														    if (valid_whitespace_command_char_encountered && use_crc_error_checking_in_parser)
															begin
																state <=  crc_process_wait_for_crc;
															end else
															begin
															    state <= record_command_error;
															end
														end
												end
										     end
											 
			 crc_process_wait_for_crc :      if (new_rx_data)
											begin
													if (valid_whitespace_command_char_encountered)
													begin
														state <=  crc_process_wait_for_crc;
													end else 
													begin 
															if (data_in_hex_range)
															begin
																state <= crc_process_shift_in_crc_nibble;																
															end else
															begin
																state <= record_command_error;
															end
													end
											end
										
              crc_process_shift_in_crc_nibble : state <= crc_process_wait_for_next_crc_nibble;

              crc_process_wait_for_next_crc_nibble : if (new_rx_data)
													 begin
														if (valid_eol_type_command_char_encountered)
														begin
																state <= check_crc_to_see_if_valid_command;															
														end else 
														begin 
																if (data_in_hex_range)
																begin
																	state <= crc_process_shift_in_crc_nibble;
																end else
																begin
																	state <= record_command_error;
																end
														end
													 end
						
                check_crc_to_see_if_valid_command  : 	if ((calculated_crc == received_crc) || ignore_crc_value_for_debugging)
                                                        begin
                                                            if (is_read_op)
															begin
															      state <= read_op_process_valid_read_command;
															end else
															begin
															      state <= write_op_process_valid_write_command;
															end
                                                        end else
														begin
															state <= record_command_error_without_waiting_for_eol;
														end														
											 
				read_op_process_valid_read_command : state <= read_op_assert_read_signals;
																 
				
            read_op_assert_read_signals        : if (!use_ack) 
																 begin 
																        state <= read_op_start_read_wait_counter;
				                                     end else
																 begin
																		state <= read_op_wait_read_wait_counter;
																 end
				read_op_start_read_wait_counter    : state <= read_op_wait_read_wait_counter;
				
				
				read_op_wait_read_wait_counter    : if (((!use_ack) & wait_counter_finished) || (use_ack & ack))
				                                    begin
													                state <= read_op_command_wrapup;
													         end
				
			    read_op_command_wrapup : state <= read_op_tx_response_start;
				
				read_op_tx_response_start : state <= read_op_tx_response_wait;
				
				read_op_tx_response_wait  : if (tx_response_finished)
				                            begin
											      state <= finished;
											end 
			  
			    write_op_start_write_operation : state <= write_op_wait_for_data;
			  	write_op_wait_for_data :  if (new_rx_data)
											begin
													if (valid_whitespace_command_char_encountered)
													begin
														state <=  write_op_wait_for_data;
													end else 
													begin 
															if (data_in_hex_range)
															begin
																state <= write_op_shift_in_data_nibble;
															end else
															begin
																state <= record_command_error;
															end
													end
											end
										
              write_op_shift_in_data_nibble : state <= write_op_wait_for_next_data_nibble;

              write_op_wait_for_next_data_nibble : if (new_rx_data)
			                                       begin
													   if (valid_eol_type_command_char_encountered)
													   begin
															state <=  record_command_error_without_waiting_for_eol;
													   end else 
													   begin 
															if (valid_whitespace_command_char_encountered)
															begin
																state <=  write_op_wait_for_address;
															end else
															begin
																	if (data_in_hex_range)
																	begin
																		state <= write_op_shift_in_data_nibble;
																	end else
																	begin
																		state <= record_command_error;
																	end
															end
													   end
										         end
			  
			  
			  
			  write_op_wait_for_address:    if (new_rx_data)
											begin
													if (valid_whitespace_command_char_encountered)
													begin
														state <=  write_op_wait_for_address;
													end else 
													begin 
															if (data_in_hex_range)
															begin
																state <= write_op_shift_in_address_nibble;
															end else
															begin
																state <= record_command_error;
															end
													end
											end
										
              write_op_shift_in_address_nibble : state <= write_op_wait_for_address_nibble;

              write_op_wait_for_address_nibble : if (new_rx_data)
												   begin
														if (valid_eol_type_command_char_encountered)
														begin
															 if (use_crc_error_checking_in_parser)
															 begin
															     state <= record_command_error_without_waiting_for_eol;
															 end else
															 begin
																state <=  write_op_process_valid_write_command;
															 end
														end else 
														begin 
																if (data_in_hex_range)
																begin
																	state <= write_op_shift_in_address_nibble;
																end else
																begin
																	 if (valid_whitespace_command_char_encountered && use_crc_error_checking_in_parser)
																	 begin
																	 	state <=  crc_process_wait_for_crc;
																	 end else
																	 begin
																		state <= record_command_error;
																	 end
																end
														end
												   end
													 
				write_op_process_valid_write_command : state <= write_op_assert_write_signals;
				
                write_op_assert_write_signals        :  if (!use_ack) 
					                                         begin 
																		        state <= write_op_start_write_wait_counter;
																		  end else
																		  begin
																		        state <= write_op_wait_write_wait_counter;
																		  end
				
				write_op_start_write_wait_counter     : state <= write_op_wait_write_wait_counter;
				
				
				write_op_wait_write_wait_counter    : if (((!use_ack) & wait_counter_finished) || (use_ack & ack))
				                                      begin
													                state <= write_op_command_wrapup;
													           end
				
			    write_op_command_wrapup : state <= write_op_tx_response_start;
				
				write_op_tx_response_start : state <= write_op_tx_response_wait;
				
				write_op_tx_response_wait : if (tx_response_finished)
				                            begin
											      state <= finished;
											end 
											
				record_command_error: state <= wait_for_eol;
				
				record_command_error_without_waiting_for_eol : state <= finished;
				
				wait_for_eol : if (new_rx_data)
							   begin
								   if (valid_eol_type_command_char_encountered)
								   begin
										state <= finished;
								   end
							   end
												   
			    finished : state <= idle;
			  		  
			endcase
		end
end

// operation data parameter 
always_ff @ (posedge clock)
begin 
	if (reset)
		command_count <= 0;
	else if (inc_command_count) 
		command_count <= command_count + 1;
end 
	

// operation data parameter 
always_ff @ (posedge clock)
begin 
	if (reset)
		error_count <= 0;
	else if (inc_error_count) 
		error_count <= error_count + 1;
end 

// operation data parameter 
always_ff @ (posedge clock)
begin 
	if (reset_data_param)
		data_param <= 0;
	else if (shift_in_data_nibble) 
		data_param <= {data_param, data_nibble};
end 

assign int_wr_data = data_param;

// operation address parameter 
always_ff @ (posedge clock)
begin 
	if (reset_addr_param)
		addr_param <= 0;
	else if (shift_in_address_nibble) 
		addr_param <= {addr_param, data_nibble};
		
end 

assign int_address = addr_param;


// uart address parameter 
always_ff @ (posedge clock)
begin 
	if (reset_uart_addr_param)
		uart_addr_param <= 0;
	else if (shift_in_uart_address_nibble) 
		uart_addr_param <= {uart_addr_param, data_nibble};
		
end 

always_ff @ (posedge clock)
begin 
	if (crc_reset)
		received_crc <= 0;
	else if (shift_in_crc_nibble) 
		received_crc <= {received_crc, data_nibble};
		
end 

always @ (posedge clock)
begin
	if (reset) begin 
		read_data_s <= 8'h0;
	end 
	else 
	begin 
     	if (capture_read_data)
		begin
			  read_data_s <= int_rd_data;
		end
	end 
end 


// character to nibble conversion 
always @*
begin 
	case (rx_data) 
		CHAR_0:				data_nibble = 4'h0;
		CHAR_1:				data_nibble = 4'h1;
		CHAR_2:				data_nibble = 4'h2;
		CHAR_3:				data_nibble = 4'h3;
		CHAR_4:				data_nibble = 4'h4;
		CHAR_5:				data_nibble = 4'h5;
		CHAR_6:				data_nibble = 4'h6;
		CHAR_7:				data_nibble = 4'h7;
		CHAR_8:				data_nibble = 4'h8;
		CHAR_9:				data_nibble = 4'h9;
		CHAR_A_UP, CHAR_a_LO:	data_nibble = 4'ha;
		CHAR_B_UP, CHAR_b_LO:	data_nibble = 4'hb;
		CHAR_C_UP, CHAR_c_LO:	data_nibble = 4'hc;
		CHAR_D_UP, CHAR_d_LO:	data_nibble = 4'hd;
		CHAR_E_UP, CHAR_e_LO:	data_nibble = 4'he;
		CHAR_F_UP, CHAR_f_LO:	data_nibble = 4'hf;
		default:				data_nibble = 4'hf;
	endcase 
end 



assign actual_crc_enable = (!valid_eol_type_command_char_encountered) & ((crc_enable_conditional & new_rx_data) || crc_enable); //glitchy but should be OK since used as enable on same clock domain

parallel_crc_ccitt
#(
.USE_SYNC_RESET(1)
) 
calculate_crc(
.clk     (clock),
.reset   (crc_reset),
.enable  (actual_crc_enable),
.init    (1'b0), 
.data_in (rx_data), 
.crc_out (calculated_crc)
);

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
`default_nettype wire