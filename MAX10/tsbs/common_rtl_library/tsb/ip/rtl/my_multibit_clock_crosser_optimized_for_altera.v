`timescale 1ns / 1ns
module my_multibit_clock_crosser_optimized_for_altera
#(
  parameter  DATA_WIDTH     = 8,
  parameter  FORWARD_SYNC_DEPTH  = 2,
  parameter  BACKWARD_SYNC_DEPTH = 2,
  parameter  USE_OUTPUT_PIPELINE = 1
)
(
   in_clk,
   in_valid,
   in_data,
   out_clk,
   out_valid,
   out_data
 );

  localparam  SYMBOLS_PER_BEAT    = 1;
  localparam  BITS_PER_SYMBOL = DATA_WIDTH;

  input                   in_clk;
  wire                   in_ready;
  input                   in_valid;
  input  [DATA_WIDTH-1:0] in_data;

  input                   out_clk;
  output reg                  out_valid;
  output reg [DATA_WIDTH-1:0] out_data;

  // Data is guaranteed valid by control signal clock crossing.  Cut data
  // buffer false path.
  (* altera_attribute = {"-name SUPPRESS_DA_RULE_INTERNAL \"D101,D102\" ; -name SDC_STATEMENT \"set_false_path -from [get_registers *my_avalon_st_clock_crosser:*|in_data_buffer*] -to [get_registers *my_avalon_st_clock_crosser:*|out_data_buffer*]\""} *) reg [DATA_WIDTH-1:0] in_data_buffer;
  reg    [DATA_WIDTH-1:0] out_data_buffer;

  reg                     in_data_toggle;
  wire                    in_data_toggle_returned;
  wire                    out_data_toggle;
  reg                     out_data_toggle_flopped;

  wire                    take_in_data;
  wire                    out_data_taken;

  wire                    out_valid_internal;
  wire                    out_ready_internal;
  
    reg  [DATA_WIDTH-1:0] actual_in_data;
    reg  actual_in_valid;
    wire [DATA_WIDTH-1:0] raw_out_data;
    wire                  raw_out_valid;
	
	always @(posedge in_clk)
	begin
	      if (in_ready)
		  begin
		       actual_in_data <= in_data;
		       actual_in_valid <= in_valid;
		  end	
	end
  
  
  	always @(posedge out_clk)
	begin
	      if (raw_out_valid)
		  begin
		       out_data <= raw_out_data;
		       out_valid <= raw_out_valid;
		  end	
	end
	
my_avalon_st_clock_crosser
#(
 .SYMBOLS_PER_BEAT    (SYMBOLS_PER_BEAT   ),
 .BITS_PER_SYMBOL     (BITS_PER_SYMBOL    ),
 .FORWARD_SYNC_DEPTH  (FORWARD_SYNC_DEPTH ),
 .BACKWARD_SYNC_DEPTH (BACKWARD_SYNC_DEPTH),
 .USE_OUTPUT_PIPELINE (USE_OUTPUT_PIPELINE)
)
my_avalon_st_clock_crosser_inst(
                                 .in_clk   (in_clk   ),
                                 .in_reset (1'b0 ),
                                 .in_ready (in_ready ),
                                 .in_valid (actual_in_valid),
                                 .in_data  (actual_in_data ),
                                 .out_clk  (out_clk  ),
                                 .out_reset(1'b0),
                                 .out_ready(1'b1),
                                 .out_valid(raw_out_valid),
                                 .out_data (raw_out_data )
                                );

endmodule
