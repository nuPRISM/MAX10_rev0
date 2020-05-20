module dummy_spi_slave_tester 
#(
  parameter N_BITS=32,
    parameter CLOG2_N_BITS_PLUS_1=$clog2(N_BITS)+1

)(
	 input        clkin,   // clock input
	 input        rst_n,    // reset_in N
	 input  	   cs ,   // spi cs
 	 input   sclk,  // spi clock input
	 input        mosi ,    // spi slave input
	 output reg [N_BITS-1:0]      data=0   ,      //data output 
	 output reg [CLOG2_N_BITS_PLUS_1-1:0]      n_bits_data=0  ,      //N bits received in transaction 
	 output logic        valid=0   ,      //valid data output
	 input 	 cpol,//this should be set to 0
	 input 	 cpha,
	 output  reg [5:0] state = 0,
	 output finish
);
  
//CPOL = 0 sclk has to be pull down before CS is down
//CPHA = 1 means that the data has to be taken on the first edge of the sclk
		 // in the case of CPOL =0 it has to be taken at the rising edge
		 // in case CPOL = 1 it has to be taken on the falling edge
//CPHA =0  means that the data has to be taken on the second edge of sclk
		 // in case of CPOL =0, it is taken at the falling edge
		 // in case CPOL = 1, it has to be taken on the rising edge.

					 //valid___ensclk____state
localparam WAIT_4_CS	=6'b0________0_________0000;
localparam COUNT_SCLK	=6'b0________1_________0100;
localparam FINISH		=6'b1________0_________1000;

wire en_sclk=state[4];
assign finish=state[5];
wire sclk_signal_sync;
wire mosi_sync;
wire cs_sync;
wire sclk_signal = cpha ? ~sclk: sclk;


reg [CLOG2_N_BITS_PLUS_1-1:0] received_bits=6'd0;

reg [N_BITS-1:0]data_in_before_locked='d0;
logic sclk_signal_sync_edge;

always@(posedge clkin)
begin
    
	if(!rst_n)//On reset N
	begin
		data_in_before_locked[N_BITS-1:0]<='d0;
		data[N_BITS-1:0]<='d0;
	end
	else
	begin		
				if(finish)
				begin
					data_in_before_locked[N_BITS-1:0]<='d0;
					data[N_BITS-1:0]<=data_in_before_locked[N_BITS-1:0];					
				end else
                begin
				    if (sclk_signal_sync_edge)
		            begin
                         data_in_before_locked[N_BITS-1:0]<={data_in_before_locked[N_BITS-2:0],mosi_sync};
                         data[N_BITS-1:0] <= data[N_BITS-1:0];
					end
                end 		
	end
end

always @(posedge clkin)
begin
      valid <= finish;
end

always@(posedge clkin)
begin
	if(!rst_n)//On reset N
	begin
		received_bits<='d0;
		n_bits_data<='d0;
	end
	else
	begin
				if(finish)
				begin
					received_bits<='d0;
					n_bits_data<=received_bits;
				end else
                begin
				      if (sclk_signal_sync_edge)
		              begin
				           received_bits<=received_bits+1'b1;
				           n_bits_data<=received_bits;                
					  end
                end
	end
end


always@(posedge clkin)
begin
	if(!rst_n)//On reset N
	begin
		state<=WAIT_4_CS;
	end
	else
	begin
		case(state)
		WAIT_4_CS	:begin 
						state<=WAIT_4_CS;
					    if(cs_sync==1'b0)
						begin
							state<=COUNT_SCLK;
						end
					 end
		COUNT_SCLK	:begin 
						state<=COUNT_SCLK;
						if(cs_sync==1'b1)
						begin
							state<=FINISH;
						end
					 end
		FINISH		:begin 
						state<=WAIT_4_CS;	
					 end
		default:	begin
					  state<=WAIT_4_CS;
					end
		endcase
	end
end

doublesync_no_reset 
#(.CUT_TIMING_TO_INPUT(1))
cs_syncro
(
	.indata(cs) ,	// input  indata_sig
	.outdata(cs_sync) ,	// output  outdata_sig
	.clk(clkin) 	// input  clk_sig
	
);

doublesync_no_reset 
#(.CUT_TIMING_TO_INPUT(1))
sclk_syncro
(
	.indata(sclk_signal) ,	// input  indata_sig
	.outdata(sclk_signal_sync) ,	// output  outdata_sig
	.clk(clkin) 	// input  clk_sig
	
);

doublesync_no_reset 
#(.CUT_TIMING_TO_INPUT(1))
miso_syncro
(
	.indata(mosi) ,	// input  indata_sig
	.outdata(mosi_sync) ,	// output  outdata_sig
	.clk(clkin) 	// input  clk_sig
	
);

non_sync_edge_detector
make_sclk_signal_sync_edge
(
.insignal (sclk_signal_sync), 
.outsignal(sclk_signal_sync_edge), 
.clk      (clkin)
);




endmodule