`default_nettype none
`include "interface_defs.v"
`include "carrier_board_interface_defs.v"
`include "uart_regfile_interface_defs.v"

module four_udp_streamer_sources_w_uart_support
#(
parameter current_FMC = 1,
parameter REGFILE_DEFAULT_BAUD_RATE = 2000000,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter ENABLE_KEEPS = 0,
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS=1'b0,
parameter [32:0]  prefix_uart_name = "undef",
parameter [127:0] uart_name = {prefix_uart_name,"_UDPTop"},
parameter NUM_UDP_STREAMERS = 4,
parameter TOP_UART_REGFILE_TYPE = uart_regfile_types::TOP_UDP_STREAMER_CTRL_REGFILE,
parameter USE_FIXED_CLOCK_FOR_UDP_STREAMER = 4'b0011,
parameter REAL_DATA_REORDER_DEFAULT = 4'b1111,
parameter SELECT_REAL_DATA_DEFAULT = 4'b0011,
parameter TEST_DATA_REORDER_DEFAULT = 4'b0000,
parameter COMPILE_UDP_TEST_SOURCES = 4'b1111,
parameter [3:0] test_packet_source = 4'b1111
)
(
 interface avalon_st_to_udp_streamer_0,
 interface avalon_st_to_udp_streamer_1,
 interface avalon_st_to_udp_streamer_2,
 interface avalon_st_to_udp_streamer_3, 
 interface real_avalon_st_to_udp_streamer_0,
 interface real_avalon_st_to_udp_streamer_1,
 interface real_avalon_st_to_udp_streamer_2,
 interface real_avalon_st_to_udp_streamer_3,
 input udp_clk,
 input packet_word_clk_base_clk,
 input uart_clk,
 input uart_rx,
 output uart_tx,
  input             TOP_UART_IS_SECONDARY_UART, 
 input [7:0]        TOP_ADDRESS_OF_THIS_UART,   
 input [7:0]        TOP_UART_NUM_OF_SECONDARY_UARTS,
 output logic [7:0] NUM_OF_UARTS_HERE
);

import uart_regfile_types::*;

uart_struct uart_pins; 
(* keep = 1, preserve = 1 *) wire [3:0] udp_test_uart_txd;	
(* keep = 1, preserve = 1 *) wire  udp_top_txd;	
wire 	[NUM_UDP_STREAMERS-1:0] select_real_data;
wire 	[NUM_UDP_STREAMERS-1:0] real_data_reorder;
wire 	[NUM_UDP_STREAMERS-1:0] test_data_reorder;
wire [NUM_UDP_STREAMERS-1:0]	block_unselected_data_to_mux;
wire [NUM_UDP_STREAMERS-1:0]	reorder_avalon_st_word;
wire [NUM_UDP_STREAMERS-1:0]	override_word_reorder;
wire [NUM_UDP_STREAMERS-1:0]	manual_word_reorder;

logic [NUM_UDP_STREAMERS-1:0] actual_udp_clk;
generate
         genvar reorder_index;
		 for (reorder_index = 0; reorder_index < NUM_UDP_STREAMERS; reorder_index++)
		 begin : set_reorder_wires
		    assign  reorder_avalon_st_word[reorder_index] = override_word_reorder[reorder_index] ? manual_word_reorder[reorder_index] : (select_real_data[reorder_index] ? real_data_reorder[reorder_index]: test_data_reorder[reorder_index] ); 		 
			
		 end
		    if (USE_FIXED_CLOCK_FOR_UDP_STREAMER[0])
			begin
			      assign actual_udp_clk[0] = udp_clk;
			end else
			begin
			      assign actual_udp_clk[0] = avalon_st_to_udp_streamer_0.clk;
			end  
			
			if (USE_FIXED_CLOCK_FOR_UDP_STREAMER[1])
			begin
			      assign actual_udp_clk[1] = udp_clk;
			end else
			begin
			      assign actual_udp_clk[1] = avalon_st_to_udp_streamer_1.clk;
			end	
			
			if (USE_FIXED_CLOCK_FOR_UDP_STREAMER[2])
			begin
			      assign actual_udp_clk[2] = udp_clk;
			end else
			begin
			      assign actual_udp_clk[2] = avalon_st_to_udp_streamer_2.clk;
			end
		 
		 	if (USE_FIXED_CLOCK_FOR_UDP_STREAMER[3])
			begin
			      assign actual_udp_clk[3] = udp_clk;
			end else
			begin
			      assign actual_udp_clk[3] = avalon_st_to_udp_streamer_3.clk;
			end
		 
endgenerate

avalon_st_32_bit_packet_interface test_avalon_st_to_udp_streamer_0();
avalon_st_32_bit_packet_interface test_avalon_st_to_udp_streamer_1();
avalon_st_32_bit_packet_interface test_avalon_st_to_udp_streamer_2();
avalon_st_32_bit_packet_interface test_avalon_st_to_udp_streamer_3();

avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_0();
avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_1();
avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_2();
avalon_st_32_bit_packet_interface raw_avalon_st_to_udp_streamer_3();
assign test_avalon_st_to_udp_streamer_0.clk = actual_udp_clk[0];
assign test_avalon_st_to_udp_streamer_1.clk = actual_udp_clk[1];
assign test_avalon_st_to_udp_streamer_2.clk = actual_udp_clk[2];
assign test_avalon_st_to_udp_streamer_3.clk = actual_udp_clk[3];

assign uart_tx = uart_pins.tx;

assign uart_pins.rx = uart_rx;
assign uart_pins.tx = &udp_test_uart_txd & udp_top_txd;

logic [7:0] local_num_uarts_here[4];

assign NUM_OF_UARTS_HERE = 1 + local_num_uarts_here[0] + local_num_uarts_here[1] + local_num_uarts_here[2] + local_num_uarts_here[3];

generate
         if (COMPILE_UDP_TEST_SOURCES[0])
		 begin
udp_test_packet_source_w_uart
#(
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS (OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  (OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.UART_CLOCK_SPEED_IN_HZ (UART_CLOCK_SPEED_IN_HZ),
.REGFILE_DEFAULT_BAUD_RATE      (REGFILE_DEFAULT_BAUD_RATE),
				.prefix_uart_name      ({prefix_uart_name,"udp0"}),
				.test_packet_source(test_packet_source[0])
)
udp0_test_packet_source_w_uart_inst
(
   .udp_clk(actual_udp_clk[0]),
   .UART_CLKIN(uart_clk),
   .RESET_FOR_UART_CLKIN(1'b0),
   .uart_tx(udp_test_uart_txd[0]),
   .uart_rx(uart_pins.rx),
   .avalon_st_to_udp_streamer(test_avalon_st_to_udp_streamer_0),
 
   .UART_IS_SECONDARY_UART   (1),
   .UART_NUM_SECONDARY_UARTS (0),
   .UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART+1),
   .NUM_OF_UARTS_HERE        (local_num_uarts_here[0]),
   .*
);
		end else
		begin
		     assign local_num_uarts_here[0] = 0;
			  assign udp_test_uart_txd[0] = 1'b1;
		end
endgenerate

 
generate
         if (COMPILE_UDP_TEST_SOURCES[1])
		 begin
udp_test_packet_source_w_uart
#(
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS (OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  (OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.UART_CLOCK_SPEED_IN_HZ (UART_CLOCK_SPEED_IN_HZ),
.REGFILE_DEFAULT_BAUD_RATE      (REGFILE_DEFAULT_BAUD_RATE),
				.prefix_uart_name      ({prefix_uart_name,"udp1"}),
				.test_packet_source(test_packet_source[1])
)
udp1_test_packet_source_w_uart_inst
(
   .udp_clk(actual_udp_clk[1]),
   .UART_CLKIN(uart_clk),
   .RESET_FOR_UART_CLKIN(1'b0),
   .uart_tx(udp_test_uart_txd[1]),
   .uart_rx(uart_pins.rx),

   .avalon_st_to_udp_streamer(test_avalon_st_to_udp_streamer_1),
   .UART_IS_SECONDARY_UART   (1      ),
   .UART_NUM_SECONDARY_UARTS (0),
   .UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART+1+local_num_uarts_here[0]),
   .NUM_OF_UARTS_HERE        (local_num_uarts_here[1]         ),
   .*
);
		end else
		begin
		       assign local_num_uarts_here[1] = 0;
			    assign udp_test_uart_txd[1] = 1'b1;
		end
endgenerate

 

generate
         if (COMPILE_UDP_TEST_SOURCES[2])
		 begin
udp_test_packet_source_w_uart
#(
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS (OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  (OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.UART_CLOCK_SPEED_IN_HZ (UART_CLOCK_SPEED_IN_HZ),
.REGFILE_DEFAULT_BAUD_RATE      (REGFILE_DEFAULT_BAUD_RATE),
				.prefix_uart_name      ({prefix_uart_name,"udp2"}),
				.test_packet_source(test_packet_source[2])
)
udp2_test_packet_source_w_uart_inst
(
   .udp_clk(actual_udp_clk[2]),
   .UART_CLKIN(uart_clk),
   .RESET_FOR_UART_CLKIN(1'b0),
   .uart_tx(udp_test_uart_txd[2]),
   .uart_rx(uart_pins.rx),

   .avalon_st_to_udp_streamer(test_avalon_st_to_udp_streamer_2),
   .UART_IS_SECONDARY_UART   (1      ),
   .UART_NUM_SECONDARY_UARTS (0),
   .UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART+1+local_num_uarts_here[0]+local_num_uarts_here[1]),
   .NUM_OF_UARTS_HERE        (local_num_uarts_here[2]         ),
   .*
);
		end else
		begin
		      assign local_num_uarts_here[2] = 0;
			   assign udp_test_uart_txd[2] = 1'b1;
		end
endgenerate
 
generate
         if (COMPILE_UDP_TEST_SOURCES[3])
		 begin
udp_test_packet_source_w_uart
#(
.ENABLE_KEEPS(ENABLE_KEEPS),
.OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS (OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS),
.OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  (OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS),
.UART_CLOCK_SPEED_IN_HZ (UART_CLOCK_SPEED_IN_HZ),
.REGFILE_DEFAULT_BAUD_RATE      (REGFILE_DEFAULT_BAUD_RATE),
				.prefix_uart_name      ({prefix_uart_name,"udp3"}),
				.test_packet_source(test_packet_source[3])
)
udp3_test_packet_source_w_uart_inst
(
   .udp_clk(actual_udp_clk[3]),
   .UART_CLKIN(uart_clk),
   .RESET_FOR_UART_CLKIN(1'b0),
   .uart_tx(udp_test_uart_txd[3]),
   .uart_rx(uart_pins.rx),

   .avalon_st_to_udp_streamer(test_avalon_st_to_udp_streamer_3),
   .UART_IS_SECONDARY_UART   (1),
   .UART_NUM_SECONDARY_UARTS (0),
   .UART_ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART+1+local_num_uarts_here[0]+local_num_uarts_here[1]+local_num_uarts_here[2]),
   .NUM_OF_UARTS_HERE        (local_num_uarts_here[3]         ),
   .*
);
	end else
	begin
		      assign local_num_uarts_here[3] = 0;
			   assign udp_test_uart_txd[3] = 1'b1;
	end
endgenerate


choose_between_two_avalon_st_interfaces
#(
  .connect_clocks(0)
)
choose_between_emulated_and_real_data_packets_0
(
  .avalon_st_interface_in0(test_avalon_st_to_udp_streamer_0),
  .avalon_st_interface_in1(real_avalon_st_to_udp_streamer_0),
  .avalon_st_interface_out(raw_avalon_st_to_udp_streamer_0),
  .sel(select_real_data[0]),
  .block_unconnected_interface(block_unselected_data_to_mux[0])
);
					 
choose_between_two_avalon_st_interfaces
#(
  .connect_clocks(0)
)
choose_between_emulated_and_real_data_packets_1
(
  .avalon_st_interface_in0(test_avalon_st_to_udp_streamer_1),
  .avalon_st_interface_in1(real_avalon_st_to_udp_streamer_1),
  .avalon_st_interface_out(raw_avalon_st_to_udp_streamer_1),
  .sel(select_real_data[1]),
  .block_unconnected_interface(block_unselected_data_to_mux[1])
);
					 
					 
choose_between_two_avalon_st_interfaces
#(
  .connect_clocks(0)
)
choose_between_emulated_and_real_data_packets_2
(
  .avalon_st_interface_in0(test_avalon_st_to_udp_streamer_2),
  .avalon_st_interface_in1(real_avalon_st_to_udp_streamer_2),
  .avalon_st_interface_out(raw_avalon_st_to_udp_streamer_2),
  .sel(select_real_data[2]),
  .block_unconnected_interface(block_unselected_data_to_mux[2])
);
					 
					 
choose_between_two_avalon_st_interfaces
#(
  .connect_clocks(0)
)
choose_between_emulated_and_real_data_packets_3
(
  .avalon_st_interface_in0(test_avalon_st_to_udp_streamer_3),
  .avalon_st_interface_in1(real_avalon_st_to_udp_streamer_3),
  .avalon_st_interface_out(raw_avalon_st_to_udp_streamer_3),
  .sel(select_real_data[3]),
  .block_unconnected_interface(block_unselected_data_to_mux[3])
);	

reorder_avalon_st_32bit_interface
#(
.use_clk_from_avalon_st_interface_in(0),
.connect_clocks(1)
)
reorder_udp_0_data_word
(
.avalon_st_interface_in (raw_avalon_st_to_udp_streamer_0),
.avalon_st_interface_out(avalon_st_to_udp_streamer_0),
.reorder(reorder_avalon_st_word[0])
);

reorder_avalon_st_32bit_interface
#(
.use_clk_from_avalon_st_interface_in(0),
.connect_clocks(1)
)
reorder_udp_1_data_word
(
.avalon_st_interface_in (raw_avalon_st_to_udp_streamer_1),
.avalon_st_interface_out(avalon_st_to_udp_streamer_1),
.reorder(reorder_avalon_st_word[1])
);

reorder_avalon_st_32bit_interface
#(
.use_clk_from_avalon_st_interface_in(0),
.connect_clocks(1)
)
reorder_udp_2_data_word
(
.avalon_st_interface_in (raw_avalon_st_to_udp_streamer_2),
.avalon_st_interface_out(avalon_st_to_udp_streamer_2),
.reorder(reorder_avalon_st_word[2])
);

reorder_avalon_st_32bit_interface
#(
.use_clk_from_avalon_st_interface_in(0),
.connect_clocks(1)
)
reorder_udp_3_data_word
(
.avalon_st_interface_in (raw_avalon_st_to_udp_streamer_3),
.avalon_st_interface_out(avalon_st_to_udp_streamer_3),
.reorder(reorder_avalon_st_word[3])
);



//===========================================================================
// Top Level UDP Streaming UART Control
//===========================================================================						
					
	
			
parameter local_regfile_data_numbytes        =   4;
parameter local_regfile_data_width           =   8*local_regfile_data_numbytes;
parameter local_regfile_desc_numbytes        =  16;
parameter local_regfile_desc_width           =   8*local_regfile_desc_numbytes;
parameter num_of_local_regfile_control_regs  =  8;
parameter num_of_local_regfile_status_regs   =  16;

wire [local_regfile_data_width-1:0] local_regfile_control_regs_default_vals[num_of_local_regfile_control_regs-1:0];
wire [local_regfile_data_width-1:0] local_regfile_control_regs             [num_of_local_regfile_control_regs-1:0];
wire [local_regfile_data_width-1:0] local_regfile_control_regs_bitwidth    [num_of_local_regfile_control_regs-1:0];
wire [local_regfile_data_width-1:0] local_regfile_control_status           [num_of_local_regfile_status_regs -1:0];
wire [local_regfile_desc_width-1:0] local_regfile_control_desc             [num_of_local_regfile_control_regs-1:0];
wire [local_regfile_desc_width-1:0] local_regfile_status_desc              [num_of_local_regfile_status_regs -1:0];

wire local_regfile_control_rd_error;
wire local_regfile_control_async_reset = 1'b0;
wire local_regfile_control_wr_error;
wire local_regfile_control_transaction_error;


wire [3:0] local_regfile_main_sm;
wire [2:0] local_regfile_tx_sm;
wire [7:0] local_regfile_command_count;


assign local_regfile_control_regs_default_vals[0] = SELECT_REAL_DATA_DEFAULT;
assign local_regfile_control_desc[0] = "SelRealData";
assign select_real_data = local_regfile_control_regs[0];
assign local_regfile_control_regs_bitwidth[0] = NUM_UDP_STREAMERS;		
 	
assign local_regfile_control_regs_default_vals[1] = 0;
assign local_regfile_control_desc[1] = "BlkUnselData";
assign block_unselected_data_to_mux = local_regfile_control_regs[1];
assign local_regfile_control_regs_bitwidth[1] = NUM_UDP_STREAMERS;		
   	
assign local_regfile_control_regs_default_vals[2] = 0;
assign local_regfile_control_desc[2] = "OvrrdeWrdReorder";
assign override_word_reorder = local_regfile_control_regs[2];
assign local_regfile_control_regs_bitwidth[2] = NUM_UDP_STREAMERS;		
 
assign local_regfile_control_regs_default_vals[3] = 0;
assign local_regfile_control_desc[3] = "ManWordReorder";
assign manual_word_reorder = local_regfile_control_regs[3];
assign local_regfile_control_regs_bitwidth[3] = NUM_UDP_STREAMERS;		
  
  
assign local_regfile_control_regs_default_vals[4] = REAL_DATA_REORDER_DEFAULT;
assign local_regfile_control_desc[4] = "RealDataReorder";
assign real_data_reorder = local_regfile_control_regs[4];
assign local_regfile_control_regs_bitwidth[4] = NUM_UDP_STREAMERS;		
  
  
  assign local_regfile_control_regs_default_vals[5] = TEST_DATA_REORDER_DEFAULT;
assign local_regfile_control_desc[5] = "testDataReorder";
assign test_data_reorder = local_regfile_control_regs[5];
assign local_regfile_control_regs_bitwidth[5] = NUM_UDP_STREAMERS;		
  
 
assign local_regfile_control_status[0] = avalon_st_to_udp_streamer_0.data;		            
assign local_regfile_status_desc[0] = "AvStOutData0";
 
assign local_regfile_control_status[1] = avalon_st_to_udp_streamer_1.data;		            
assign local_regfile_status_desc[1] = "AvStOutData1";
 
assign local_regfile_control_status[2] = avalon_st_to_udp_streamer_2.data;		            
assign local_regfile_status_desc[2] = "AvStOutData2";
 
assign local_regfile_control_status[3] = avalon_st_to_udp_streamer_3.data;		            
assign local_regfile_status_desc[3] = "AvStOutData3";
 
assign local_regfile_control_status[4] = {
	avalon_st_to_udp_streamer_0.empty, 
	avalon_st_to_udp_streamer_0.error,
	avalon_st_to_udp_streamer_0.eop,
	avalon_st_to_udp_streamer_0.sop, 
	avalon_st_to_udp_streamer_0.valid,
	avalon_st_to_udp_streamer_0.ready
	};         
assign local_regfile_status_desc[4] = "AvStOutCtrl0";

	assign local_regfile_control_status[5] = {
	avalon_st_to_udp_streamer_1.empty, 
	avalon_st_to_udp_streamer_1.error,
	avalon_st_to_udp_streamer_1.eop,
	avalon_st_to_udp_streamer_1.sop, 
	avalon_st_to_udp_streamer_1.valid,
	avalon_st_to_udp_streamer_1.ready
	};         
assign local_regfile_status_desc[5] = "AvStOutCtrl1";

	assign local_regfile_control_status[6] = {
	avalon_st_to_udp_streamer_2.empty, 
	avalon_st_to_udp_streamer_2.error,
	avalon_st_to_udp_streamer_2.eop,
	avalon_st_to_udp_streamer_2.sop, 
	avalon_st_to_udp_streamer_2.valid,
	avalon_st_to_udp_streamer_2.ready
	};         
assign local_regfile_status_desc[6] = "AvStOutCtrl2";

assign local_regfile_control_status[7] = {
	avalon_st_to_udp_streamer_3.empty, 
	avalon_st_to_udp_streamer_3.error,
	avalon_st_to_udp_streamer_3.eop,
	avalon_st_to_udp_streamer_3.sop, 
	avalon_st_to_udp_streamer_3.valid,
	avalon_st_to_udp_streamer_3.ready
	};         
assign local_regfile_status_desc[7] = "AvStOutCtrl0";

assign local_regfile_control_status[8] = real_avalon_st_to_udp_streamer_0.data;		            
assign local_regfile_status_desc[8] = "RealAvStOutData0";
 
assign local_regfile_control_status[9] = real_avalon_st_to_udp_streamer_1.data;		            
assign local_regfile_status_desc[9] = "RealAvStOutData1";
 
assign local_regfile_control_status[10] = real_avalon_st_to_udp_streamer_2.data;		            
assign local_regfile_status_desc[10] = "RealAvStOutData2";
 
assign local_regfile_control_status[11] = real_avalon_st_to_udp_streamer_3.data;		            
assign local_regfile_status_desc[11] = "RealAvStOutData3";
 
assign local_regfile_control_status[12] = {
	real_avalon_st_to_udp_streamer_0.empty, 
	real_avalon_st_to_udp_streamer_0.error,
	real_avalon_st_to_udp_streamer_0.eop,
	real_avalon_st_to_udp_streamer_0.sop, 
	real_avalon_st_to_udp_streamer_0.valid,
	real_avalon_st_to_udp_streamer_0.ready
	};         
assign local_regfile_status_desc[12] = "RealAvStOutCtrl0";

	assign local_regfile_control_status[13] = {
	real_avalon_st_to_udp_streamer_1.empty, 
	real_avalon_st_to_udp_streamer_1.error,
	real_avalon_st_to_udp_streamer_1.eop,
	real_avalon_st_to_udp_streamer_1.sop, 
	real_avalon_st_to_udp_streamer_1.valid,
	real_avalon_st_to_udp_streamer_1.ready
	};         
assign local_regfile_status_desc[13] = "RealAvStOutCtrl1";

	assign local_regfile_control_status[14] = {
	real_avalon_st_to_udp_streamer_2.empty, 
	real_avalon_st_to_udp_streamer_2.error,
	real_avalon_st_to_udp_streamer_2.eop,
	real_avalon_st_to_udp_streamer_2.sop, 
	real_avalon_st_to_udp_streamer_2.valid,
	real_avalon_st_to_udp_streamer_2.ready
	};         
assign local_regfile_status_desc[14] = "RealAvStOutCtrl2";

assign local_regfile_control_status[15] = {
	real_avalon_st_to_udp_streamer_3.empty, 
	real_avalon_st_to_udp_streamer_3.error,
	real_avalon_st_to_udp_streamer_3.eop,
	real_avalon_st_to_udp_streamer_3.sop, 
	real_avalon_st_to_udp_streamer_3.valid,
	real_avalon_st_to_udp_streamer_3.ready
	};         
assign local_regfile_status_desc[15] = "RealAvStOutCtrl3";

	
	
uart_controlled_register_file_ver3
#( 
  .NUM_OF_CONTROL_REGS(num_of_local_regfile_control_regs),
  .NUM_OF_STATUS_REGS(num_of_local_regfile_status_regs),
  .DATA_WIDTH_IN_BYTES  (local_regfile_data_numbytes),
  .DESC_WIDTH_IN_BYTES  (local_regfile_desc_numbytes),
  .INIT_ALL_CONTROL_REGS_TO_DEFAULT (1'b0),  
  .CONTROL_REGS_DEFAULT_VAL         (0),
  .CLOCK_SPEED_IN_HZ(UART_CLOCK_SPEED_IN_HZ),
  .UART_BAUD_RATE_IN_HZ(REGFILE_DEFAULT_BAUD_RATE)
)
local_uart_register_file
(	
 .DISPLAY_NAME(uart_name),
 .CLK(uart_clk),
 .REG_ACTIVE_HIGH_ASYNC_RESET(local_regfile_control_async_reset),
 .CONTROL(local_regfile_control_regs),
 .CONTROL_DESC(local_regfile_control_desc),
 .CONTROL_BITWIDTH(local_regfile_control_regs_bitwidth),
 .STATUS(local_regfile_control_status),
 .STATUS_DESC (local_regfile_status_desc),
 .CONTROL_INIT_VAL(local_regfile_control_regs_default_vals),
 .TRANSACTION_ERROR(local_regfile_control_transaction_error),
 .WR_ERROR(local_regfile_control_wr_error),
 .RD_ERROR(local_regfile_control_rd_error),
 .USER_TYPE(TOP_UART_REGFILE_TYPE),
 .NUM_SECONDARY_UARTS(TOP_UART_NUM_OF_SECONDARY_UARTS), 
 .ADDRESS_OF_THIS_UART(TOP_ADDRESS_OF_THIS_UART),
 .IS_SECONDARY_UART(TOP_UART_IS_SECONDARY_UART),
 
 //UART
 .uart_active_high_async_reset(1'b0),
 .rxd(uart_pins.rx),
 .txd(udp_top_txd),
 
 //UART DEBUG
 .main_sm               (local_regfile_main_sm),
 .tx_sm                 (local_regfile_tx_sm),
 .command_count         (local_regfile_command_count)
  
);

  
 endmodule
 `default_nettype wire