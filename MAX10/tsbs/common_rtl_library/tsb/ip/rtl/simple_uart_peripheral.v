module simple_uart_peripheral
(
	// global signals 
	clock, reset,
	// uart serial signals 
	ser_in, ser_out,
	// transmit and receive internal interface signals 
	rx_data, new_rx_data, 
	tx_data, new_tx_data, tx_busy,
	baud_clk 
);
//---------------------------------------------------------------------------------------
// modules inputs and outputs 
input 			clock;			// global clock input 
input 			reset;			// global reset input 
input			ser_in;			// serial data input 
output			ser_out;		// serial data output 
input	[7:0]	tx_data;		// data byte to transmit 
input			new_tx_data;	// asserted to indicate that there is a new data byte for transmission 
output 			tx_busy;		// signs that transmitter is busy 
output	[7:0]	rx_data;		// data byte received 
output 			new_rx_data;	// signs that a new byte was received 
output			baud_clk;

parameter CLOCK_SPEED_IN_HZ = 50000000;
parameter UART_BAUD_RATE_IN_HZ = 115200;
  

function automatic int log2 (input int n);
					if (n <=1) return 1; // abort function
					log2 = 0;
					while (n > 1) begin
					n = n/2;
					log2++;
					end
					endfunction

function automatic int gcd (input int a, input int b);
						if (a == 0)
						begin
						   return b;
						end
						
						while (!(b == 0))
						begin
							if (a > b)
							begin
							   a = a - b;
							end else
							begin
							   b = b - a;
							end
						end
						return a;
					endfunction


function int calculate_baud_freq_param (input int clk_osc_freq_hz, input int baud_freq_hz);
 return (16*baud_freq_hz/(gcd(clk_osc_freq_hz, 16*baud_freq_hz)));
endfunction

function int calculate_baud_limit_param (input int clk_osc_freq_hz, input int baud_freq_hz, input int baud_freq_param);
  return ((clk_osc_freq_hz / gcd(clk_osc_freq_hz, 16*baud_freq_hz)) - baud_freq_param);
endfunction


// baud rate configuration, see baud_gen.v for more details.
// baud rate generator parameters for 115200 baud on 50MHz clock 
//parameter D_BAUD_FREQ			= 12'h240,
// parameter D_BAUD_LIMIT		= 16'h3AC9 
						
	
parameter D_BAUD_FREQ			= calculate_baud_freq_param(CLOCK_SPEED_IN_HZ,UART_BAUD_RATE_IN_HZ);
parameter D_BAUD_LIMIT		    = calculate_baud_limit_param(CLOCK_SPEED_IN_HZ,UART_BAUD_RATE_IN_HZ,D_BAUD_FREQ);

wire actual_new_tx_data;

edge_detector tx_data_edge_detector //get one puse of tx_data
(
 .insignal (new_tx_data), 
 .outsignal(actual_new_tx_data), 
 .clk      (clock)
);
 
uart_top
the_uart
(
	// global signals 
	.clock(clock), 
	.reset(reset),
	// uart serial signals 
	.ser_in(ser_in), 
	.ser_out(ser_out),
	// transmit and receive internal interface signals 
	.rx_data(rx_data), 
	.new_rx_data(new_rx_data), 
	.tx_data(tx_data), 
	.new_tx_data(actual_new_tx_data), 
	.tx_busy(tx_busy), 
	// baud rate configuration register - see baud_gen.v for details 
	.baud_freq(D_BAUD_FREQ), 
	.baud_limit(D_BAUD_LIMIT), 
	.baud_clk(baud_clk) 
);
endmodule
