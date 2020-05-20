`ifndef STANDALONE_OPENCORES_SPI_W_UART_CONTROL_V
`define STANDALONE_OPENCORES_SPI_W_UART_CONTROL_V

`default_nettype none
`include "interface_defs.v"
//`include "carrier_board_interface_defs.v"
`include "keep_defines.v"
import uart_regfile_types::*;

module standalone_opencores_spi_w_uart_control
#(
parameter ENABLE_KEEPS                             = 0,
parameter GENERATE_SPI_TEST_CLOCK_SIGNALS          = 1'b1;
parameter OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS = 1'b0,
parameter OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS  = 1'b0,
parameter UART_CLOCK_SPEED_IN_HZ = 50000000,
parameter REGFILE_BAUD_RATE = 2000000,
parameter AUX1_DEFULT_VAL = 0,
parameter AUX2_DEFULT_VAL = 0,
parameter [63:0]  prefix_uart_name = "undef",
parameter [127:0] diagnostic_uart_name = {prefix_uart_name,"_SPIDiag"},
parameter [127:0] opencores_spi_uart_name = {prefix_uart_name,"_SPI"},
parameter MAIN_UART_REGFILE_TYPE = uart_regfile_types::OPENCORES_SPI_UART_REGFILE,
parameter DIAGNOSTIC_UART_REGFILE_TYPE = uart_regfile_types::OPENCORES_SPI_DIAGNOSTIC_UART_REGFILE
)
(
	input  CLKIN_50MHz,
	input  RESET_FOR_CLKIN_50MHz,
	output diagnostic_uart_tx,
	input  diagnostic_uart_rx,
	output opencores_spi_uart_tx,
	input  opencores_spi_uart_rx,
	generic_spi_interface spi_pins,

    input wire       DIAGNOSTIC_UART_IS_SECONDARY_UART,
    input wire [7:0] DIAGNOSTIC_UART_NUM_SECONDARY_UARTS,
    input wire [7:0] DIAGNOSTIC_UART_ADDRESS_OF_THIS_UART,    
	input wire       OPENCORES_SPI_UART_IS_SECONDARY_UART,
    input wire [7:0] OPENCORES_SPI_UART_NUM_SECONDARY_UARTS,
    input wire [7:0] OPENCORES_SPI_UART_ADDRESS_OF_THIS_UART,
	output wire [7:0] NUM_OF_UARTS_HERE

);

assign NUM_OF_UARTS_HERE = 2;

			
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_clk_i;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_rst_i;	 
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire     [4:0]                 opencores_spi_debug_wb_adr_i;	 
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [32-1:0]                 opencores_spi_debug_wb_dat_i;	 
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [32-1:0]                 opencores_spi_debug_wb_dat_o;	 
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire     [3:0]                 opencores_spi_debug_wb_sel_i;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_we_i ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_stb_i;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_cyc_i;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_err_o;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_ack_o;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_wb_int_o;  
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire     [31:0]                opencores_spi_debug_divider ;  
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire     [31:0]                opencores_spi_debug_ctrl    ;  
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire                           opencores_spi_debug_go    ;  
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire     [31:0]                opencores_spi_debug_ss      ;  
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire     [31:0]                opencores_spi_debug_wb_dat  ;  
        (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]    debug_tag_word_in;
        (* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic [31:0]    debug_tag_word_out; 
		
		
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire        opencores_spi_control_spi_miso_pad_i;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire        opencores_spi_control_spi_mosi_pad_o;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire        opencores_spi_control_spi_sclk_pad_o;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [7:0] opencores_spi_control_spi_ss_pad_o;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire        opencores_spi_control_aux_sdio_oe_n;

		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [0:0] opencores_spi_control_s_oe_n;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire        actual_adc_mosi;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire [31:0] opencores_spi_control_status;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  actual_opencores_spi_control_s_oe_n;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  actual_opencores_spi_control_sdata_out;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sdi_override_val   ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sdo_override_val    ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sclk_override_val  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sdio_en_override_val  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sdi_override   ;		
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [7:0] opencores_spi_control_csn_override_val  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_csn_override   ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sdo_override    ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sclk_override  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_control_sdio_en_override  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  [15:0] opencores_spi_control_override_ctrl  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_spi_manual_reset  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_actual_sdi  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_actual_sdo  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_actual_sclk  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_actual_csn  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_actual_active  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) wire  opencores_actual_sdio_oe_n  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  opencores_spi_test_signal_csn   ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  opencores_spi_test_signal_sdo   ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  opencores_spi_test_signal_sclk  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *) logic  this_spi_interface_is_currently_active  ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [7:0] tx_bit_pos;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [7:0] rx_bit_pos;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [7:0] cnt       ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] aux_in       ;
		(* keep = ENABLE_KEEPS, preserve = ENABLE_KEEPS *)  logic [31:0] aux_out       ;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   SPI connections
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

 wire  [15:0] opencores_spi_test_signal_divisor_csn   ;
 wire  [15:0] opencores_spi_test_signal_divisor_sdo   ;
 wire  [15:0] opencores_spi_test_signal_divisor_sclk  ;
 wire  [2:0] spi_test_sig_en;
 wire   sclk_test_sig_en;
 wire   sdo_test_sig_en;
 wire   csn_test_sig_en;
 assign sclk_test_sig_en = spi_test_sig_en[0];
 assign sdo_test_sig_en  =   spi_test_sig_en[1];
 assign csn_test_sig_en  =  spi_test_sig_en[2];
 reg [31:0] total_ops_counter = 0;
 
generate
	  if (GENERATE_SPI_TEST_CLOCK_SIGNALS)
	  begin
					Divisor_frecuencia
					#(.Bits_counter(16))
					Generate_opencores_spi_test_signal_csn
					 (	
					  .CLOCK(CLKIN_50MHz),
					  .TIMER_OUT(opencores_spi_test_signal_csn),
					  .Comparator(opencores_spi_test_signal_divisor_csn)
					 );
					  
					Divisor_frecuencia
					#(.Bits_counter(16))
					Generate_opencores_spi_test_signal_sdo
					 (	
					  .CLOCK(CLKIN_50MHz),
					  .TIMER_OUT(opencores_spi_test_signal_sdo),
					  .Comparator(opencores_spi_test_signal_divisor_sdo)
					 );
					  
					Divisor_frecuencia
					#(.Bits_counter(16))
					Generate_opencores_spi_test_signal_sclk
					 (	
					  .CLOCK(CLKIN_50MHz),
					  .TIMER_OUT(opencores_spi_test_signal_sclk),
					  .Comparator(opencores_spi_test_signal_divisor_sclk)
					 );
	 end else
	 begin
		   always @(posedge CLKIN_50MHz)
		   begin
				opencores_spi_test_signal_sclk <= ~opencores_spi_test_signal_sclk;
				opencores_spi_test_signal_sdo <=  ~opencores_spi_test_signal_sdo;
				opencores_spi_test_signal_csn <=  ~opencores_spi_test_signal_csn;				
		   end
	 end
endgenerate
 
 
 
  assign { 
          opencores_spi_control_csn_override_val           ,
          opencores_spi_control_csn_override     ,
          opencores_spi_control_sdi_override_val     ,
          opencores_spi_control_sdo_override_val     ,
          opencores_spi_control_sclk_override_val    ,
          opencores_spi_control_sdio_en_override_val ,
          opencores_spi_control_sdi_override         ,
          opencores_spi_control_sdo_override         ,
          opencores_spi_control_sclk_override        ,
          opencores_spi_control_sdio_en_override     
  } = opencores_spi_control_override_ctrl;
  
assign opencores_spi_control_status    = 
                            {
                             spi_pins.spi_sdi,
                             spi_pins.spi_sdo,
                             spi_pins.spi_clk,
                             spi_pins.spi_sdio_oe_n,
							 actual_opencores_spi_control_s_oe_n,
							 actual_adc_mosi,
							 opencores_spi_control_spi_sclk_pad_o,
							 opencores_spi_control_spi_mosi_pad_o,
							 opencores_spi_control_spi_miso_pad_i,
							 spi_pins.spi_csn,
							 opencores_spi_control_spi_ss_pad_o[7:0]
		                    };
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SPI interface assignments
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign spi_pins.spi_clk           = opencores_spi_control_sclk_override ? (sclk_test_sig_en ? opencores_spi_test_signal_sclk : opencores_spi_control_sclk_override_val) : opencores_spi_control_spi_sclk_pad_o;
assign spi_pins.spi_csn           = opencores_spi_control_csn_override ? (csn_test_sig_en ? {8{opencores_spi_test_signal_csn}} : opencores_spi_control_csn_override_val) : opencores_spi_control_spi_ss_pad_o;

assign spi_pins.spi_sdio_oe_n                    = opencores_spi_control_sdio_en_override ? opencores_spi_control_sdio_en_override_val : opencores_spi_control_aux_sdio_oe_n;
assign spi_pins.spi_sdio_oe                    = !spi_pins.spi_sdio_oe_n;
assign spi_pins.spi_sdo                        = opencores_spi_control_sdo_override ? (sdo_test_sig_en ? opencores_spi_test_signal_sdo : opencores_spi_control_sdo_override_val) : opencores_spi_control_spi_mosi_pad_o;
assign opencores_spi_control_spi_miso_pad_i    = opencores_spi_control_sdi_override  ? opencores_spi_control_sdi_override_val : spi_pins.spi_sdi;	  

assign spi_pins.spi_reset = opencores_spi_manual_reset;
assign spi_pins.this_spi_interface_is_currently_active = this_spi_interface_is_currently_active;
assign spi_pins.tx_bit_pos = tx_bit_pos;
assign spi_pins.rx_bit_pos = rx_bit_pos;
assign spi_pins.cnt        = cnt       ;
assign spi_pins.aux_out        = aux_out       ;
assign spi_pins.debug_tag        = debug_tag_word_out       ;
assign spi_pins.debug_tag_in        = debug_tag_word_in       ;
assign spi_pins.base_high_speed_clk        = CLKIN_50MHz       ;
assign aux_in = spi_pins.aux_in       ;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Debug/status main signals
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


  assign opencores_actual_sdio_oe_n   = spi_pins.spi_sdio_oe_n;
  assign opencores_actual_sdi   = opencores_spi_control_spi_miso_pad_i;
  assign opencores_actual_sdo   = spi_pins.spi_sdo;
  assign opencores_actual_sclk  = spi_pins.spi_clk;
  assign opencores_actual_csn   = spi_pins.spi_csn;
  assign opencores_actual_active = spi_pins.this_spi_interface_is_currently_active;
	  
assign opencores_spi_debug_go = opencores_spi_debug_ctrl[8];
wire opencores_spi_debug_go_edge;

edge_detector go_edge_detector
		(
		 .insignal (opencores_spi_debug_go), 
		 .outsignal(opencores_spi_debug_go_edge), 
		 .clk      (CLKIN_50MHz)
		);


always @(posedge CLKIN_50MHz)
begin
      if (opencores_spi_debug_go_edge)
	  begin
	          total_ops_counter <= total_ops_counter+1;
	  end
end	  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   Diagnostic UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
			localparam  STATUS_AND_CONTROL_REGFILE_DATA_NUMBYTES                       = 4;
            localparam  STATUS_AND_CONTROL_REGFILE_DESC_NUMBYTES                       = 16;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS                 = 5;
			localparam  STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS                  = 15;			
            localparam  STATUS_AND_CONTROL_REGFILE_INIT_ALL_CONTROL_REGS_TO_DEFAULT    = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_CONTROL_REGS_DEFAULT_VAL            = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_USE_AUTO_RESET                      = 1;
			localparam  STATUS_AND_CONTROL_REGFILE_CLOCK_SPEED_IN_HZ                   = UART_CLOCK_SPEED_IN_HZ;
			localparam  STATUS_AND_CONTROL_REGFILE_UART_BAUD_RATE_IN_HZ                = REGFILE_BAUD_RATE;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_CONTROL_WISHBONE_INTERFACE   = 0;
			localparam  STATUS_AND_CONTROL_REGFILE_ENABLE_STATUS_WISHBONE_INTERFACE    = 0;
			localparam  STATUS_AND_CONTROL_DISABLE_AUTO_CROPPING_OF_CONTROL_REGISTERS  = 1;
			
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

	        assign uart_regfile_interface_pins.display_name         = diagnostic_uart_name;
			assign uart_regfile_interface_pins.num_secondary_uarts  = DIAGNOSTIC_UART_NUM_SECONDARY_UARTS;
			assign uart_regfile_interface_pins.is_secondary_uart    = DIAGNOSTIC_UART_IS_SECONDARY_UART;
			assign uart_regfile_interface_pins.address_of_this_uart = DIAGNOSTIC_UART_ADDRESS_OF_THIS_UART;
			assign uart_regfile_interface_pins.rxd = diagnostic_uart_rx;
			assign diagnostic_uart_tx = uart_regfile_interface_pins.txd;
			assign uart_regfile_interface_pins.clk       = CLKIN_50MHz;
			assign uart_regfile_interface_pins.reset     = 1'b0;
			assign uart_regfile_interface_pins.user_type = DIAGNOSTIC_UART_REGFILE_TYPE;	
			
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
			diagnostic_control_and_status_regfile
			(
			  .uart_regfile_interface_pins(uart_regfile_interface_pins)		
			);
			
			genvar sreg_count;
			genvar creg_count;
			
			generate
					for ( sreg_count=0; sreg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_STATUS_REGS; sreg_count++)
					begin : clear_status_descs
						  assign uart_regfile_interface_pins.status_omit_desc[sreg_count] = OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS;
					end
					
						
					for (creg_count=0; creg_count < STATUS_AND_CONTROL_REGFILE_NUM_OF_CONTROL_REGS; creg_count++)
					begin : clear_control_descs
						  assign uart_regfile_interface_pins.control_omit_desc[creg_count] = OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS;
					end
			endgenerate
			
    assign uart_regfile_interface_pins.control_regs_default_vals[0]  =  0;
    assign uart_regfile_interface_pins.control_desc[0]               = "spi_override";
    assign opencores_spi_control_override_ctrl                           = uart_regfile_interface_pins.control[0];
    assign uart_regfile_interface_pins.control_regs_bitwidth[0]      = 16;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[1]  =  8;
    assign uart_regfile_interface_pins.control_desc[1]               = "test_div_csn";
    assign opencores_spi_test_signal_divisor_csn                     = uart_regfile_interface_pins.control[1];
    assign uart_regfile_interface_pins.control_regs_bitwidth[1]      = 16;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[2]  =  16;
    assign uart_regfile_interface_pins.control_desc[2]               = "test_div_sdo";
    assign opencores_spi_test_signal_divisor_sdo                     = uart_regfile_interface_pins.control[2];
    assign uart_regfile_interface_pins.control_regs_bitwidth[2]      = 16;		
	 
	assign uart_regfile_interface_pins.control_regs_default_vals[3]  =  32;
    assign uart_regfile_interface_pins.control_desc[3]               = "test_div_sclk";
    assign opencores_spi_test_signal_divisor_sclk                     = uart_regfile_interface_pins.control[3];
    assign uart_regfile_interface_pins.control_regs_bitwidth[3]      = 16;		
	 
		
    assign uart_regfile_interface_pins.control_regs_default_vals[4]  =  0;
    assign uart_regfile_interface_pins.control_desc[4]               = "spi_test_sig_en";
    assign spi_test_sig_en                                           = uart_regfile_interface_pins.control[4];
    assign uart_regfile_interface_pins.control_regs_bitwidth[4]      = 16;		
	 
	 
	
	assign uart_regfile_interface_pins.status[0] = 32'h12345678;
	assign uart_regfile_interface_pins.status_desc[0]    ="StatusAlive";	
	
	assign uart_regfile_interface_pins.status[1] = opencores_spi_debug_wb_dat;
	assign uart_regfile_interface_pins.status_desc[1]    ="debug_wb_dat";
	
	assign uart_regfile_interface_pins.status[2] = opencores_spi_debug_wb_dat_i;
	assign uart_regfile_interface_pins.status_desc[2]    ="debug_wb_dat_i";
	
	assign uart_regfile_interface_pins.status[3] = opencores_spi_debug_wb_dat_o;
	assign uart_regfile_interface_pins.status_desc[3]    ="debug_wb_dat_o";
		
    assign uart_regfile_interface_pins.status[4] = opencores_spi_debug_wb_adr_i;
	assign uart_regfile_interface_pins.status_desc[4]    ="debug_wb_adr_i";
	
    assign uart_regfile_interface_pins.status[5] = opencores_spi_debug_divider;
	assign uart_regfile_interface_pins.status_desc[5]    ="debug_divider";
	
    assign uart_regfile_interface_pins.status[6] = opencores_spi_debug_ctrl;
	assign uart_regfile_interface_pins.status_desc[6]    ="debug_ctrl";
	
    assign uart_regfile_interface_pins.status[7] = opencores_spi_debug_ss;
	assign uart_regfile_interface_pins.status_desc[7]    ="debug_ss";
	
	assign uart_regfile_interface_pins.status[8] = {
	                                                opencores_spi_debug_wb_we_i ,
	                                                opencores_spi_debug_wb_stb_i,
	                                                opencores_spi_debug_wb_cyc_i,
	                                                opencores_spi_debug_wb_err_o,
	                                                opencores_spi_debug_wb_ack_o,
	                                                opencores_spi_debug_wb_int_o,
	                                                opencores_spi_debug_wb_rst_i
											       };

	assign uart_regfile_interface_pins.status_desc[8]="debug_spi_wb";
	
		
	assign uart_regfile_interface_pins.status[9] = {
	                                               opencores_actual_sdio_oe_n,
	                                               opencores_actual_active,
	                                               opencores_actual_sdi  ,
	                                               opencores_actual_sdo  ,
	                                               opencores_actual_sclk ,
	                                               opencores_actual_csn  
	                                              };

	assign uart_regfile_interface_pins.status_desc[9]="actual_spi_sigs"; //these signals are connected here so that they are not minimized; we will actually look at them through signal tap
	
	assign uart_regfile_interface_pins.status[10] = opencores_spi_manual_reset;
	assign uart_regfile_interface_pins.status_desc[10]="spi_mnl_rst";
	
    assign uart_regfile_interface_pins.status[11] = {OMIT_DIAGNOSTIC_CONTROL_REG_DESCRIPTIONS, 
													 OMIT_DIAGNOSTIC_STATUS_REG_DESCRIPTIONS,
													 (ENABLE_KEEPS ? 1'b1 : 1'b0),                             
													 GENERATE_SPI_TEST_CLOCK_SIGNALS};
													 
	assign uart_regfile_interface_pins.status_desc[11]="module_params";
	
    assign uart_regfile_interface_pins.status[12] = total_ops_counter;													
	assign uart_regfile_interface_pins.status_desc[12]="total_ops";
	
	          
	    assign uart_regfile_interface_pins.status[13] = debug_tag_word_out;													
	assign uart_regfile_interface_pins.status_desc[13]="debug_tag_word_out";
		          
	 assign uart_regfile_interface_pins.status[14] = {tx_bit_pos,
		                                                rx_bit_pos,
		                                                cnt};       
		
	assign uart_regfile_interface_pins.status_desc[14]="tx_rx_cnt_cnt";
	
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//   Main UART definitions
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	
parameter opencores_spi_local_regfile_address_numbits         =  16;
parameter opencores_spi_local_regfile_data_numbytes           =  4;
parameter opencores_spi_local_regfile_desc_numbytes           =  16;
parameter opencores_spi_num_of_local_regfile_control_regs     =  32'h2c; //number of words in the address space

	
uart_wishbone_bridge_interface 	
#(                                                                                                     
  .DATA_NUMBYTES                                (opencores_spi_local_regfile_data_numbytes                       ),
  .DESC_NUMBYTES                                (opencores_spi_local_regfile_desc_numbytes                       ),
  .NUM_OF_CONTROL_REGS                          (opencores_spi_num_of_local_regfile_control_regs               ) //taken from QSYS address space
)
opencores_spi_uart_interface_pins();

wire auto_reset;

generate_one_shot_pulse 
#(.num_clks_to_wait(1))  
generate_auto_reset
(
.clk(CLKIN_50MHz), 
.oneshot_pulse(auto_reset)
);


assign opencores_spi_uart_interface_pins.display_name         = opencores_spi_uart_name;
assign opencores_spi_uart_interface_pins.clk                  = CLKIN_50MHz;
assign opencores_spi_uart_interface_pins.async_reset          = 1'b0;
assign opencores_spi_uart_interface_pins.user_type            = MAIN_UART_REGFILE_TYPE;
assign opencores_spi_uart_interface_pins.num_secondary_uarts  = OPENCORES_SPI_UART_NUM_SECONDARY_UARTS ; 
assign opencores_spi_uart_interface_pins.address_of_this_uart = OPENCORES_SPI_UART_ADDRESS_OF_THIS_UART;
assign opencores_spi_uart_interface_pins.is_secondary_uart    = OPENCORES_SPI_UART_IS_SECONDARY_UART   ;
assign opencores_spi_uart_interface_pins.rxd                  = opencores_spi_uart_rx;
assign opencores_spi_uart_tx                                  = opencores_spi_uart_interface_pins.txd;

	   avalon_mm_simple_bridge_interface 
		#(
			.num_address_bits(32),
			.num_data_bits(32)
		)
		opencores_spi_avalon_mm_control_interface_pins();

		uart_controlled_avalon_mm_master_no_pipeline_w_interfaces
		#(
			.NUM_OF_CONTROL_REGS   (opencores_spi_num_of_local_regfile_control_regs),
			.DATA_NUMBYTES         (opencores_spi_local_regfile_data_numbytes      ),
			.DESC_NUMBYTES         (opencores_spi_local_regfile_desc_numbytes      ),
			.ADDRESS_WIDTH_IN_BITS (opencores_spi_local_regfile_address_numbits    ),		  
			.CLOCK_SPEED_IN_HZ(50000000),
            .UART_BAUD_RATE_IN_HZ(REGFILE_BAUD_RATE),
			.USE_AUTO_RESET(1'b1),
			.DISABLE_ERROR_MONITORING(1'b1)				
		)
		uart_control_of_opencores_spi_standalone
		(
		 .uart_regfile_interface_pins(opencores_spi_uart_interface_pins),
		 .avalon_mm_slave_interface_pins(opencores_spi_avalon_mm_control_interface_pins)
		);
			
	  
	
	 opencores_spi_standalone 
	 opencores_spi_standalone_inst (
        .clk_clk                            (CLKIN_50MHz),                            //                            clk.clk
        .opencores_spi_debug_wb_clk_i       (opencores_spi_debug_wb_clk_i ),       //            opencores_spi_debug.wb_clk_i
        .opencores_spi_debug_wb_rst_i       (opencores_spi_debug_wb_rst_i ),       //                               .wb_rst_i
        .opencores_spi_debug_wb_adr_i       (opencores_spi_debug_wb_adr_i ),       //                               .wb_adr_i
        .opencores_spi_debug_wb_dat_i       (opencores_spi_debug_wb_dat_i ),       //                               .wb_dat_i
        .opencores_spi_debug_wb_dat_o       (opencores_spi_debug_wb_dat_o ),       //                               .wb_dat_o
        .opencores_spi_debug_wb_sel_i       (opencores_spi_debug_wb_sel_i ),       //                               .wb_sel_i
        .opencores_spi_debug_wb_we_i        (opencores_spi_debug_wb_we_i  ),        //                               .wb_we_i
        .opencores_spi_debug_wb_stb_i       (opencores_spi_debug_wb_stb_i ),       //                               .wb_stb_i
        .opencores_spi_debug_wb_cyc_i       (opencores_spi_debug_wb_cyc_i ),       //                               .wb_cyc_i
        .opencores_spi_debug_wb_ack_o       (opencores_spi_debug_wb_ack_o ),       //                               .wb_ack_o
        .opencores_spi_debug_wb_err_o       (opencores_spi_debug_wb_err_o ),       //                               .wb_err_o
        .opencores_spi_debug_wb_int_o       (opencores_spi_debug_wb_int_o ),       //                               .wb_int_o
        .opencores_spi_debug_divider        (opencores_spi_debug_divider  ),        //                               .divider
        .opencores_spi_debug_ctrl           (opencores_spi_debug_ctrl     ),           //                               .ctrl
        .opencores_spi_debug_ss             (opencores_spi_debug_ss       ),             //                               .ss
        .opencores_spi_debug_wb_dat         (opencores_spi_debug_wb_dat   ),         //                               .wb_dat
        .opencores_spi_sdio_helper_export   (opencores_spi_control_aux_sdio_oe_n ),   //      opencores_spi_sdio_helper.export
        .reset_reset_n                      (!RESET_FOR_CLKIN_50MHz  & !auto_reset),                      //                          reset.reset_n
        .opencores_spi_miso_pad_i           (opencores_spi_control_spi_miso_pad_i),               //                  opencores_spi.miso_pad_i
        .opencores_spi_mosi_pad_o           (opencores_spi_control_spi_mosi_pad_o),               //                               .mosi_pad_o
        .opencores_spi_sclk_pad_o           (opencores_spi_control_spi_sclk_pad_o),               //                               .sclk_pad_o
        .opencores_spi_ss_pad_o             (opencores_spi_control_spi_ss_pad_o  ),               //                               .ss_pad_o
        .opencores_spi_wb_err_o             (                               ),               //                               .wb_err_o
        .opencores_spi_wb_cyc_i             ( 1'b1                          ),               //                               .wb_cyc_i
        .avalon_mm_slave_address            ({opencores_spi_avalon_mm_control_interface_pins.address,2'b00} /*shift up address by 2 */         ),        //                avalon_mm_slave.address
        .avalon_mm_slave_read               ( opencores_spi_avalon_mm_control_interface_pins.read                                              ),        //                               .read
        .avalon_mm_slave_readdata           ( opencores_spi_avalon_mm_control_interface_pins.readdata                                          ),        //                               .readdata
        .avalon_mm_slave_write              ( opencores_spi_avalon_mm_control_interface_pins.write                                             ),        //                               .write
        .avalon_mm_slave_writedata          ( opencores_spi_avalon_mm_control_interface_pins.writedata                                         ),        //                               .writedata
        .avalon_mm_slave_waitrequest        ( opencores_spi_avalon_mm_control_interface_pins.waitrequest                                       ),        //                               .waitrequest
	    .opencores_spi_manual_reset_out_export (opencores_spi_manual_reset),  // opencores_spi_manual_reset_out.export
        .opencores_spi_interrupt_sender_irq (),  // opencores_spi_interrupt_sender.irq
		.opencores_spi_currently_active_export (this_spi_interface_is_currently_active),  // opencores_spi_currently_active.export
		  .opencores_spi_debug_tag_word_in       (debug_tag_word_in),       //                               .tag_word_in
        .opencores_spi_debug_tag_word_out      (debug_tag_word_out),      //                               .tag_word_out
        .opencores_spi_debug_tag_word_export   (debug_tag_word_in),   //   opencores_spi_debug_tag_word.export
	    .opencores_spi_tx_bit_pos              (tx_bit_pos),                //                               .tx_bit_pos 
        .opencores_spi_rx_bit_pos              (rx_bit_pos),                //                               .rx_bit_pos
        .opencores_spi_cnt                     (cnt       ),               //                               .cnt
		.opencores_spi_aux_control_out_export  (aux_out),  //  opencores_spi_aux_control_out.export
        .opencores_spi_aux_control_in_export   (aux_in)    //   opencores_spi_aux_control_in.export
  
		
   
		
		
    );


	
endmodule
`default_nettype wire
`endif
