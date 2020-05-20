// Listing 13.6
module pong_animation_simulator
#(
parameter numbits_per_rgb_component = 8,
  parameter HD = 640,// horizontal display area
   parameter HF = 48 , // h. front (left) border
   parameter HB = 16 , // h. back (right) border
   parameter HR = 96 , // h. retrace
   parameter VD = 480, // vertical display area
   parameter VF = 10,  // v. front (top) border
   parameter VB = 33,  // v. back (bottom) border
   parameter VR = 2   // v. retrace
)
   (
    input wire clk, reset,
    input wire [1:0] btn,
    output wire hsync, vsync,
    output wire [2:0] rgb,
	output [15:0] monochrome,
	output reg [numbits_per_rgb_component*3-1:0] stream_data,
	output reg stream_valid,
	output pixel_tick,
	output reg pixel_clk_1x = 0,
    output video_on,
	output reg sop,
    output reg eop,
    output logic [numbits_per_rgb_component-1:0] r_bus_1x,
	output logic [numbits_per_rgb_component-1:0] g_bus_1x,
	output logic [numbits_per_rgb_component-1:0] b_bus_1x,		
	output logic [numbits_per_rgb_component-1:0] video_de_1x,	
    output reg   hsync_1x, vsync_1x,
	output reg  [15:0] monochrome_1x
   );

   wire [15:0] R_16_bit,  G_16_bit,  B_16_bit;
   
   // constant declaration
   // VGA 640-by-480 sync parameters
 

   // signal declaration
   wire [15:0] pixel_x, pixel_y;
   reg [2:0] rgb_reg;
   wire [2:0] rgb_next;

   // body
   // instantiate vga sync circuit
   vga_sync
   #(
   .HD(HD),
   .HF(HF),
   .HB(HB),
   .HR(HR),
   .VD(VD),
   .VF(VF),
   .VB(VB),
   .VR(VR)  
   )
   vsync_unit
      (.clk(clk), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(pixel_tick),
       .pixel_x(pixel_x), .pixel_y(pixel_y));

   // instantiate graphic generator
   pong_graph_animate
   #(
   .MAX_X(HD),
   .MAX_Y(VD)
   )
   pong_graph_an_unit
      (.clk(clk), .reset(reset), .btn(btn),
       .video_on(video_on), .pix_x(pixel_x),
       .pix_y(pixel_y), .graph_rgb(rgb_next));

   // rgb buffer
   always @(posedge clk)
      if (pixel_tick)
         rgb_reg <= rgb_next;
   // output
   assign rgb = rgb_reg;
   
   always @(negedge clk)
   begin
        pixel_clk_1x <= pixel_tick;
   end

	assign   monochrome = (R_16_bit>>2)+(R_16_bit>>5)+(G_16_bit>>1)+(G_16_bit>>4)+(B_16_bit>>4)+(B_16_bit>>5);
	
	assign R_16_bit =  {16{rgb[2]}};
	assign G_16_bit =  {16{rgb[1]}};
	assign B_16_bit =  {16{rgb[0]}};
	
	
	
   always @(posedge clk)
   begin
        sop <= (pixel_x == 0) && (pixel_y == 0);
        eop <= (pixel_x == HD-1) && (pixel_y == VD-1);
        stream_valid <= video_on & pixel_tick;
        stream_data[numbits_per_rgb_component-1:0] <= {numbits_per_rgb_component{rgb[0]}};
        stream_data[2*numbits_per_rgb_component-1:numbits_per_rgb_component] <= {numbits_per_rgb_component{rgb[1]}};
        stream_data[3*numbits_per_rgb_component-1 -:numbits_per_rgb_component] <= {numbits_per_rgb_component{rgb[2]}};
   end
   
   always @(posedge pixel_clk_1x)
   begin
         r_bus_1x    <= {(numbits_per_rgb_component-1){rgb[2]}};
         g_bus_1x    <= {(numbits_per_rgb_component-1){rgb[1]}};
         b_bus_1x    <= {(numbits_per_rgb_component-1){rgb[0]}};
		 video_de_1x <= video_on;
		 hsync_1x    <= hsync;
		 vsync_1x    <= vsync;
		 monochrome_1x <= monochrome[$size(monochrome)-1 -: numbits_per_rgb_component];
   end
   
endmodule
