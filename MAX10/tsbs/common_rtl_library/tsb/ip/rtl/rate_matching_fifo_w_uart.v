
`default_nettype none
`include "interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module rate_matching_fifo_w_uart
#(
parameter [15:0] data_width            = 128,
parameter [15:0] num_locations_in_fifo   = 256,
parameter [7:0] num_words_bits          = $clog2(num_locations_in_fifo),
parameter [7:0] event_counter_width = 32,
parameter [7:0] word_counter_width = 32,
parameter OMIT_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_STATUS_REG_DESCRIPTIONS = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"RateMtch"},
parameter UART_REGFILE_TYPE = uart_regfile_types::RATE_MATCH_FIFO_REGFILE,
parameter START_WRITING_THRESHOLD_DEFAULT = num_locations_in_fifo*1/4,
parameter STOP_WRITING_THRESHOLD_DEFAULT = num_locations_in_fifo*3/4,
parameter START_READING_THRESHOLD_DEFAULT = num_locations_in_fifo*6/10,
parameter STOP_READING_THRESHOLD_DEFAULT = num_locations_in_fifo*2/10,
parameter [0:0] ASSUME_ALL_INPUT_DATA_IS_VALID = 1,
parameter device_family = "Arria V",
parameter synchronizer_depth = 3
//parameter START_WRITING_THRESHOLD_DEFAULT = num_locations_in_fifo/2-2,
//parameter STOP_WRITING_THRESHOLD_DEFAULT = num_locations_in_fifo/2+2,
//parameter START_READING_THRESHOLD_DEFAULT = num_locations_in_fifo/2+2,
//parameter STOP_READING_THRESHOLD_DEFAULT = num_locations_in_fifo/2-2
)
(

    input  UART_REGFILE_CLK,
	input  RESET_FOR_UART_REGFILE_CLK,
	
	output uart_tx,
	input  uart_rx,
	
	input [data_width-1:0] indata,
	input indata_valid,
	output [data_width-1:0] outdata,
	output outdata_valid,
	input indata_clk,
	input outdata_clk,
	input external_fifo_reset,

    input wire       UART_IS_SECONDARY_UART,
    input wire [7:0] UART_NUM_SECONDARY_UARTS,
    input wire [7:0] UART_ADDRESS_OF_THIS_UART,
	output [7:0] NUM_UARTS_HERE
);

logic main_uart_tx;

assign NUM_UARTS_HERE = 1;

assign uart_tx = main_uart_tx;

logic local_async_fifo_reset;
logic async_fifo_reset;

assign async_fifo_reset  = local_async_fifo_reset | external_fifo_reset;
logic async_fifo_reset_sync_to_wr_clk;
logic async_fifo_reset_sync_to_rd_clk;
logic [num_words_bits-1:0] stop_writing_threshold ;
logic [num_words_bits-1:0] stop_reading_threshold ;
logic [num_words_bits-1:0] start_writing_threshold;
logic [num_words_bits-1:0] start_reading_threshold;
logic [num_words_bits-1:0] stop_writing_threshold_raw;
logic [num_words_bits-1:0] stop_reading_threshold_raw;
logic [num_words_bits-1:0] start_writing_threshold_raw;
logic [num_words_bits-1:0] start_reading_threshold_raw;
logic [num_words_bits-1:0] wrusedw_in_uart_clk_domain, rdusedw_in_uart_clk_domain;
logic actual_indata_valid;

reg [event_counter_width-1:0] num_stopped_read_cycles = 0;
reg [event_counter_width-1:0] num_stopped_write_cycles = 0;
reg [event_counter_width-1:0] num_read_stop_events = 0;
reg [event_counter_width-1:0] num_write_stop_events = 0;
reg [word_counter_width-1:0]  input_word_counter = 0;
reg [word_counter_width-1:0]  output_word_counter = 0;
reg [word_counter_width-1:0]  total_input_word_counter = 0;
reg [word_counter_width-1:0]  total_output_word_counter = 0;

localparam CTRL_SIG_WIDTH = 5;

logic [CTRL_SIG_WIDTH-1:0] rd_ctrl_uart_domain,wr_ctrl_uart_domain;


logic  start_reading_now;
logic  stop_reading_now;
logic  start_writing_now;
logic  stop_writing_now;

reg we_are_writing_now = 0;
reg we_are_reading_now = 0;

logic reset_counters, reset_counters_rd, reset_counters_wr;
logic we_are_not_reading;
logic we_are_not_writing;

assign we_are_not_reading = !we_are_reading_now;
assign we_are_not_writing = !we_are_writing_now;
assign actual_indata_valid = ASSUME_ALL_INPUT_DATA_IS_VALID ? 1'b1 : indata_valid;

data_acq_fifo_interface 
#(
.in_data_bits            (data_width           ),
.out_data_bits           (data_width          ),
.num_locations_in_fifo   (num_locations_in_fifo  ),
.num_words_bits          (num_words_bits         )
)
fifo_interface_pins();


assign fifo_interface_pins.data  = indata;
assign outdata = fifo_interface_pins.q ;

always @(posedge outdata_clk)
begin
     outdata_valid <= we_are_reading_now;
end

assign fifo_interface_pins.wrclk = indata_clk;
assign fifo_interface_pins.rdclk = outdata_clk;

fifo_with_level_indicators 
#(
.data_width(data_width),
.num_locations(num_locations_in_fifo),
.device_family(device_family)
)
rate_match_fifo_inst
(

	.data   (fifo_interface_pins.data   ),
	.rdclk  (fifo_interface_pins.rdclk  ),
	.rdreq  (fifo_interface_pins.rdreq  ),
	.wrclk  (fifo_interface_pins.wrclk  ),
	.wrreq  (fifo_interface_pins.wrreq  ),
	.q      (fifo_interface_pins.q      ),
	.rdempty(fifo_interface_pins.rdempty),
	.rdfull (fifo_interface_pins.rdfull ),
	.rdusedw(fifo_interface_pins.rdusedw),
	.wrempty(fifo_interface_pins.wrempty),
	.wrfull (fifo_interface_pins.wrfull ),
	.wrusedw(fifo_interface_pins.wrusedw),
	.stop_writing_threshold ,
	.stop_reading_threshold ,
	.start_writing_threshold,
	.start_reading_threshold,
	.start_reading_now,
	.stop_reading_now,
	.start_writing_now,
	.stop_writing_now,
	.async_reset(async_fifo_reset)

);

logic write_stop_event, read_stop_event;


edge_detector 
write_now_falling_edge_detector
(
.insignal (!we_are_writing_now), 
.outsignal(write_stop_event), 
 .clk      (fifo_interface_pins.wrclk)
);

edge_detector 
read_now_falling_edge_detector
(
.insignal (!we_are_reading_now), 
.outsignal(read_stop_event), 
 .clk      (fifo_interface_pins.rdclk)
);

always_ff @(posedge fifo_interface_pins.wrclk)
begin
     if (async_fifo_reset_sync_to_wr_clk)
	  begin 
	       we_are_writing_now <= 0;
	  end else
	  begin
		if (we_are_writing_now) 
		begin
			if (stop_writing_now) 
			begin
				 we_are_writing_now <= 0;
			end
		end else 
		begin
			  if (start_writing_now) 
			  begin
				  we_are_writing_now <= 1;
			  end
		end
	 end
end

assign fifo_interface_pins.wrreq = we_are_writing_now && actual_indata_valid;

always_ff @(posedge fifo_interface_pins.rdclk)
begin
      if (async_fifo_reset_sync_to_rd_clk)
	  begin 
	       we_are_reading_now <= 0;
	  end else
	  begin
		if (we_are_reading_now) 
		begin
			if (stop_reading_now) 
			begin
				 we_are_reading_now <= 0;
			end
		end else 
		begin
			  if (start_reading_now) 
			  begin
				  we_are_reading_now <= 1;
			  end
		end
     end
end

assign fifo_interface_pins.rdreq = we_are_reading_now;

always_ff @(posedge fifo_interface_pins.rdclk)
begin
      if (reset_counters_rd) 
	  begin
	         output_word_counter <= 0;  
	         total_output_word_counter <= 0;  
	  end else
	  begin
	  	    total_output_word_counter <= total_output_word_counter + 1;
			
	        if (outdata_valid)
			begin
	              output_word_counter <= output_word_counter + 1;		
			end
	  end     
end

always_ff @(posedge fifo_interface_pins.rdclk)
begin
     if (reset_counters_rd)
	 begin
          num_stopped_read_cycles <= 0;
		  num_read_stop_events <=0; 
	 end else
	 begin
	      if (we_are_not_reading)
		  begin
	           num_stopped_read_cycles <= num_stopped_read_cycles + 1;
		  end
		  
		  if (read_stop_event)
		  begin
		         num_read_stop_events <= num_read_stop_events + 1;
		  end
	 end
end	 

always_ff @(posedge fifo_interface_pins.wrclk)
begin
      if (reset_counters_wr) 
	  begin
	    input_word_counter <= 0;
	    total_input_word_counter <= 0;
	  end else
	  begin
       	    total_input_word_counter <= total_input_word_counter + 1;

	        if (actual_indata_valid)
			begin
	              input_word_counter <= input_word_counter + 1;		
			end
	  end     
end

always_ff @(posedge fifo_interface_pins.wrclk)
begin
     if (reset_counters_wr)
	 begin
          num_stopped_write_cycles <= 0;
		  num_write_stop_events <=0; 
	 end else
	 begin
	      if (we_are_not_writing)
		  begin
	           num_stopped_write_cycles <= num_stopped_write_cycles + 1;
		  end
		  
		  if (write_stop_event)
		  begin
		         num_write_stop_events <= num_write_stop_events + 1;
		  end
	 end
end	 

logic mcp_synch_write_thresholds_aready, mcp_synch_write_thresholds_bvalid, 
      mcp_synch_read_thresholds_aready,  mcp_synch_read_thresholds_bvalid, 
	  mcp_synch_rdusedw_aready, mcp_synch_rdusedw_bvalid, 
	  mcp_synch_wrusedw_aready, mcp_synch_wrusedw_bvalid,
	  mcp_synch_rd_ctrl_aready, mcp_synch_rd_ctrl_bvalid,
	  mcp_synch_wr_ctrl_aready, mcp_synch_wr_ctrl_bvalid;
	  
my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(2*num_words_bits+2),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_write_thresholds
(
   .in_clk(UART_REGFILE_CLK),
   .in_valid(1'b1),
   .in_data({async_fifo_reset,reset_counters,start_writing_threshold_raw,stop_writing_threshold_raw}),
   .out_clk(fifo_interface_pins.wrclk),
   .out_valid(mcp_synch_write_thresholds_bvalid),
   .out_data({async_fifo_reset_sync_to_wr_clk, reset_counters_wr,start_writing_threshold,stop_writing_threshold})
 );	  

//mcp_blk 
//#(
//.width(2*num_words_bits+2)
//) 
//mcp_synch_write_thresholds
//(
///* output  logic */                 .aready  (mcp_synch_write_thresholds_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({async_fifo_reset,reset_counters,start_writing_threshold_raw,stop_writing_threshold_raw}),
///* input  logic */                  .asend   (1'b1 /*trig_ts_ADC_energy_long[n][0] | trig_ts_ADC_energy_short[n][0]*/),
///* input  logic */                  .aclk    (UART_REGFILE_CLK),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({async_fifo_reset_sync_to_wr_clk, reset_counters_wr,start_writing_threshold,stop_writing_threshold}),
///* output  logic */                 .bvalid  (mcp_synch_write_thresholds_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (fifo_interface_pins.wrclk),
///* input  logic */                  .brst_n  (1'b1)
//);
my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(2*num_words_bits+2),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_read_thresholds
(
   .in_clk(UART_REGFILE_CLK),
   .in_valid(1'b1),
   .in_data({async_fifo_reset,reset_counters,start_reading_threshold_raw,stop_reading_threshold_raw}),
   .out_clk(fifo_interface_pins.rdclk),
   .out_valid(mcp_synch_read_thresholds_bvalid),
   .out_data({async_fifo_reset_sync_to_rd_clk,reset_counters_rd,start_reading_threshold,stop_reading_threshold})
 );	  


//mcp_blk 
//#(
//.width(2*num_words_bits+2)
//) 
//mcp_synch_read_thresholds
//(
///* output  logic */                 .aready  (mcp_synch_read_thresholds_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({async_fifo_reset,reset_counters,start_reading_threshold_raw,stop_reading_threshold_raw}),
///* input  logic */                  .asend   (1'b1 ),
///* input  logic */                  .aclk    (UART_REGFILE_CLK),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   ({async_fifo_reset_sync_to_rd_clk,reset_counters_rd,start_reading_threshold,stop_reading_threshold}),
///* output  logic */                 .bvalid  (mcp_synch_read_thresholds_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (fifo_interface_pins.rdclk),
///* input  logic */                  .brst_n  (1'b1)
//);
	
	
my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(num_words_bits),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_rdusedw
(
   .in_clk(fifo_interface_pins.rdclk),
   .in_valid(1'b1),
   .in_data(fifo_interface_pins.rdusedw),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_synch_rdusedw_bvalid),
   .out_data(rdusedw_in_uart_clk_domain)
 );	  

 
//mcp_blk 
//#(
//.width(num_words_bits)
//) 
//mcp_synch_rdusedw
//(
///* output  logic */                 .aready  (mcp_synch_rdusedw_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain (fifo_interface_pins.rdusedw),
///* input  logic */                  .asend   (1'b1 ),
///* input  logic */                  .aclk    (fifo_interface_pins.rdclk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   (rdusedw_in_uart_clk_domain),
///* output  logic */                 .bvalid  (mcp_synch_rdusedw_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1)
//);	

my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(num_words_bits),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth) 
)
mcp_synch_wrusedw
(
   .in_clk(fifo_interface_pins.wrclk),
   .in_valid(1'b1),
   .in_data(fifo_interface_pins.wrusedw),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_synch_wrusedw_bvalid),
   .out_data(wrusedw_in_uart_clk_domain)
 );	  



//mcp_blk 
//#(
//.width(num_words_bits)
//) 
//mcp_synch_wrusedw
//(
///* output  logic */                 .aready  (mcp_synch_wrusedw_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain (fifo_interface_pins.wrusedw),
///* input  logic */                  .asend   (1'b1),
///* input  logic */                  .aclk    (fifo_interface_pins.wrclk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   (wrusedw_in_uart_clk_domain),
///* output  logic */                 .bvalid  (mcp_synch_wrusedw_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1)
//);


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(CTRL_SIG_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_rd_ctrl
(
   .in_clk(fifo_interface_pins.rdclk),
   .in_valid(1'b1),
   .in_data({fifo_interface_pins.rdfull,fifo_interface_pins.rdempty,stop_reading_now,start_reading_now,we_are_reading_now}),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_synch_rd_ctrl_bvalid),
   .out_data(rd_ctrl_uart_domain)
 );	  

//mcp_blk 
//#(
//.width(CTRL_SIG_WIDTH)
//) 
//mcp_synch_rd_ctrl
//(
///* output  logic */                 .aready  (mcp_synch_rd_ctrl_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({fifo_interface_pins.rdfull,fifo_interface_pins.rdempty,stop_reading_now,start_reading_now,we_are_reading_now}),
///* input  logic */                  .asend   (1'b1 ),
///* input  logic */                  .aclk    (fifo_interface_pins.rdclk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   (rd_ctrl_uart_domain),
///* output  logic */                 .bvalid  (mcp_synch_rd_ctrl_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1)
//);	


my_multibit_clock_crosser_optimized_for_altera
#(
  .DATA_WIDTH(CTRL_SIG_WIDTH),
  .FORWARD_SYNC_DEPTH(synchronizer_depth),
  .BACKWARD_SYNC_DEPTH(synchronizer_depth)  
)
mcp_synch_wr_ctrl
(
   .in_clk(fifo_interface_pins.wrclk),
   .in_valid(1'b1),
   .in_data({fifo_interface_pins.wrfull,fifo_interface_pins.wrempty,stop_writing_now,start_writing_now,we_are_writing_now}),
   .out_clk(UART_REGFILE_CLK),
   .out_valid(mcp_synch_wr_ctrl_bvalid),
   .out_data(wr_ctrl_uart_domain)
 );	
 
//mcp_blk 
//#(
//.width(CTRL_SIG_WIDTH)
//) 
//mcp_synch_wr_ctrl
//(
///* output  logic */                 .aready  (mcp_synch_wr_ctrl_aready), // ready to receive next data
///* input  logic [(width-1):0] */    .adatain ({fifo_interface_pins.wrfull,fifo_interface_pins.wrempty,stop_writing_now,start_writing_now,we_are_writing_now}),
///* input  logic */                  .asend   (1'b1 ),
///* input  logic */                  .aclk    (fifo_interface_pins.wrclk),
///* input  logic */                  .arst_n  (1'b1),
///* output  logic  [(width-1):0]  */ .bdata   (wr_ctrl_uart_domain),
///* output  logic */                 .bvalid  (mcp_synch_wr_ctrl_bvalid), // bdata valid (ready)
///* input  logic */                  .bload   (1'b1),
///* input  logic */                  .bclk    (UART_REGFILE_CLK),
///* input  logic */                  .brst_n  (1'b1)
//);	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 8;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 14;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0 ;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 0;
			
			/* dummy wishbone interface definitions */		
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			status_wishbone_interface_pins();
						
			wishbone_interface 
			#(
			   .num_address_bits(32), 
			   .num_data_bits(32)
			)
			control_wishbone_interface_pins();
			
			
			
			uart_regfile_interface 
			#(                                                                                                     
			.DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       ),
			.DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       ),
			.NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 ),
			.NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  ),
			.INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    ),
			.CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            ),
			.USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      ),
			.CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   ),
			.UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                ),
			.ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   ),
			.ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    ),
			.DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  )
				
			)
			uart_regfile_interface_pins();

	        assign uart_regfile_interface_pins.display_name         = uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = uart_rx;
			assign main_uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = UART_REGFILE_CLK;
			assign uart_regfile_interface_pins.reset     = 1'b0;
			assign uart_regfile_interface_pins.user_type = UART_REGFILE_TYPE;	
			
			uart_controlled_register_file_w_interfaces
			#(
			 .DATA_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                      ),
			 .DESC_NUMBYTES                                (STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                      ),
			 .NUM_OF_CONTROL_REGS                          (STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                ),
			 .NUM_OF_STATUS_REGS                           (STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                 ),
			 .INIT_ALL_CONTROL_REGS_TO_DEFAULT             (STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT   ),
			 .CONTROL_REGS_DEFAULT_VAL                     (STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL           ),
			 .USE_AUTO_RESET                               (STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                     ),
			 .CLOCK_SPEED_IN_HZ                            (STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                  ),
			 .UART_BAUD_RATE_IN_HZ                         (STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ               ),
			 .ENABLE_CONTROL_WISHBONE_INTERFACE            (STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE  ),
			 .ENABLE_STATUS_WISHBONE_INTERFACE             (STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE   ),
 			 .DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS   (STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS)
			)		
			control_and_status_regfile
			(
			  .uart_regfile_interface_pins(uart_regfile_interface_pins),
			  .status_wishbone_interface_pins (status_wishbone_interface_pins ), 
			  .control_wishbone_interface_pins(control_wishbone_interface_pins)			  
			);
			
	
			genvar sreg_count;
			genvar creg_count;
			
			generate
					for ( sreg_count=0; sreg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS; sreg_count++)
					begin : clear_status_descs
						  assign uart_regfile_interface_pins.status_omit_desc[sreg_count] = OMIT_STATUS_REG_DESCRIPTIONS;
					end
					
						
					for (creg_count=0; creg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS; creg_count++)
					begin : clear_control_descs
						  assign uart_regfile_interface_pins.control_omit_desc[creg_count] = OMIT_CONTROL_REG_DESCRIPTIONS;
					end
			endgenerate
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  32'h12345678;
    assign uart_regfile_interface_pins.control_desc[0]               = "ctrlAlive";
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 32;		
	
    assign uart_regfile_interface_pins.control_regs_default_vals[1]  = START_WRITING_THRESHOLD_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[1]               = "Start_Write_Thr";   
	assign start_writing_threshold_raw                               = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = num_words_bits;		
		
    assign uart_regfile_interface_pins.control_regs_default_vals[2]  = STOP_WRITING_THRESHOLD_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[2]               = "Stop_Write_Thr";   
	assign stop_writing_threshold_raw                                = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = num_words_bits;		
  
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  = START_READING_THRESHOLD_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[3]               = "Start_Read_Thr";   
	assign start_reading_threshold_raw                               = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = num_words_bits;		
		
    assign uart_regfile_interface_pins.control_regs_default_vals[4]  = STOP_READING_THRESHOLD_DEFAULT;
    assign uart_regfile_interface_pins.control_desc[4]               = "Stop_Read_Thr";   
	assign stop_reading_threshold_raw                                = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = num_words_bits;		
  
    assign uart_regfile_interface_pins.control_regs_default_vals[5]  = 0;
    assign uart_regfile_interface_pins.control_desc[5]               = "Reset_Counters";   
	assign reset_counters                                = uart_regfile_interface_pins.control[5];
    assign uart_regfile_interface_pins.control_regs_bitwidth[5]      = 1;		    
	
	assign uart_regfile_interface_pins.control_regs_default_vals[6]  = 0;
    assign uart_regfile_interface_pins.control_desc[6]               = "Reset_Fifo";   
	assign local_async_fifo_reset                                = uart_regfile_interface_pins.control[6];
    assign uart_regfile_interface_pins.control_regs_bitwidth[6]      = 1;		
  
	assign uart_regfile_interface_pins.status[0] = {ASSUME_ALL_INPUT_DATA_IS_VALID, num_words_bits,  event_counter_width, word_counter_width};
	assign uart_regfile_interface_pins.status_desc[0]    ="module_params";	        
                                                                                     
	assign uart_regfile_interface_pins.status[1] = wrusedw_in_uart_clk_domain;
	assign uart_regfile_interface_pins.status_desc[1]    ="wrusedw";
	
	assign uart_regfile_interface_pins.status[2] = rdusedw_in_uart_clk_domain;
	assign uart_regfile_interface_pins.status_desc[2]    ="rdusedw";
	
	assign uart_regfile_interface_pins.status[3] = wr_ctrl_uart_domain;
	assign uart_regfile_interface_pins.status_desc[3]    ="wr_ctrl";
	
	assign uart_regfile_interface_pins.status[4] = rd_ctrl_uart_domain;
	assign uart_regfile_interface_pins.status_desc[4]    ="rd_ctrl";
		
	assign uart_regfile_interface_pins.status[5] = num_stopped_write_cycles;
	assign uart_regfile_interface_pins.status_desc[5]    ="WrStopCounter";
			
	assign uart_regfile_interface_pins.status[6] = num_stopped_read_cycles;
	assign uart_regfile_interface_pins.status_desc[6]    ="RdStopCounter";		
	
	assign uart_regfile_interface_pins.status[7] = num_write_stop_events;
	assign uart_regfile_interface_pins.status_desc[7]    ="WrStopEvents";
			
	assign uart_regfile_interface_pins.status[8] = num_read_stop_events;
	assign uart_regfile_interface_pins.status_desc[8]    ="RdStopEvents";
	
	assign uart_regfile_interface_pins.status[9] = input_word_counter;
	assign uart_regfile_interface_pins.status_desc[9]    ="valInWordCnt";
	
	assign uart_regfile_interface_pins.status[10] = output_word_counter;
	assign uart_regfile_interface_pins.status_desc[10]    ="valOutWordCnt";
	
		assign uart_regfile_interface_pins.status[11] = total_input_word_counter;
	assign uart_regfile_interface_pins.status_desc[11]    ="totInWordCnt";
	
	assign uart_regfile_interface_pins.status[12] = total_output_word_counter;
	assign uart_regfile_interface_pins.status_desc[12]    ="totOutWordCnt";
				
	assign uart_regfile_interface_pins.status[13] = { 
	                                                  mcp_synch_write_thresholds_aready, mcp_synch_write_thresholds_bvalid, 
													  mcp_synch_read_thresholds_aready,  mcp_synch_read_thresholds_bvalid, 
													  mcp_synch_rdusedw_aready, mcp_synch_rdusedw_bvalid, 
													  mcp_synch_wrusedw_aready, mcp_synch_wrusedw_bvalid,
													  mcp_synch_rd_ctrl_aready, mcp_synch_rd_ctrl_bvalid,
													  mcp_synch_wr_ctrl_aready, mcp_synch_wr_ctrl_bvalid
													 };
													 
	assign uart_regfile_interface_pins.status_desc[13]    ="mcp_blk_status";
			
 endmodule
 
`default_nettype wire