//
//  ethernet_packet_multiplexer
//
//  This component multiplexes 5 Avalon ST sink interfaces out one Avalon ST
//  source interface.  Once a pending channel is selected to transmit its data,
//  the mux allows the entire packet from that channel to transmit out the
//  source interface.  There is no arbitration applied to the multiplexing
//  schedule, it follows a simple round robin schedule of pending channels.
//
module ethernet_packet_multiplexer (    
    
      // Interface: clk
      input              csi_clock_clk,
      input              csi_clock_reset_n,
      // Interface: in0
      input              asi_in0_valid,
      output reg         asi_in0_ready,
      input      [31: 0] asi_in0_data,
      input              asi_in0_startofpacket,
      input              asi_in0_endofpacket,
      input      [ 1: 0] asi_in0_empty,
      // Interface: in1
      input              asi_in1_valid,
      output reg         asi_in1_ready,
      input      [31: 0] asi_in1_data,
      input              asi_in1_startofpacket,
      input              asi_in1_endofpacket,
      input      [ 1: 0] asi_in1_empty,
      // Interface: in2
      input              asi_in2_valid,
      output reg         asi_in2_ready,
      input      [31: 0] asi_in2_data,
      input              asi_in2_startofpacket,
      input              asi_in2_endofpacket,
      input      [ 1: 0] asi_in2_empty,
      // Interface: in3
      input              asi_in3_valid,
      output reg         asi_in3_ready,
      input      [31: 0] asi_in3_data,
      input              asi_in3_startofpacket,
      input              asi_in3_endofpacket,
      input      [ 1: 0] asi_in3_empty,
      // Interface: in4
      input              asi_in4_valid,
      output reg         asi_in4_ready,
      input      [31: 0] asi_in4_data,
      input              asi_in4_startofpacket,
      input              asi_in4_endofpacket,
      input      [ 1: 0] asi_in4_empty,
      // Interface: out
      output reg         aso_out_valid,
      input              aso_out_ready,
      output reg [31: 0] aso_out_data,
      output reg         aso_out_startofpacket,
      output reg         aso_out_endofpacket,
      output reg [ 1: 0] aso_out_empty
);

   // ---------------------------------------------------------------------
   //| Signal Declarations
   // ---------------------------------------------------------------------
   reg  [35: 0] asi_in0_payload;
   reg  [35: 0] asi_in1_payload;
   reg  [35: 0] asi_in2_payload;
   reg  [35: 0] asi_in3_payload;
   reg  [35: 0] asi_in4_payload;

   reg  [ 2: 0] decision = 0;      
   reg  [ 2: 0] select = 0;
   reg          selected_endofpacket = 0;
   reg          selected_startofpacket = 0;
   reg          selected_valid;
   wire         selected_ready;
   reg  [35: 0] selected_payload;
   reg  [ 1: 0] counter;

   reg          in_a_packet;
   wire         out_valid_wire;
   
   wire [35: 0] out_payload;

   // ---------------------------------------------------------------------
   //| Input Mapping
   // ---------------------------------------------------------------------
   always @* begin
     asi_in0_payload <= {asi_in0_data,asi_in0_startofpacket,asi_in0_endofpacket,asi_in0_empty};
     asi_in1_payload <= {asi_in1_data,asi_in1_startofpacket,asi_in1_endofpacket,asi_in1_empty};
     asi_in2_payload <= {asi_in2_data,asi_in2_startofpacket,asi_in2_endofpacket,asi_in2_empty};
     asi_in3_payload <= {asi_in3_data,asi_in3_startofpacket,asi_in3_endofpacket,asi_in3_empty};
     asi_in4_payload <= {asi_in4_data,asi_in4_startofpacket,asi_in4_endofpacket,asi_in4_empty};
   end
   
   // ---------------------------------------------------------------------
   //| Scheduling Algorithm
   // ---------------------------------------------------------------------
   always @* begin
         
      decision <= 0;
      case(select) 
         0 : begin
            if (asi_in0_valid) decision <= 0;
            if (asi_in4_valid) decision <= 4;
            if (asi_in3_valid) decision <= 3;
            if (asi_in2_valid) decision <= 2;
            if (asi_in1_valid) decision <= 1;
         end  
         1 : begin
            if (asi_in1_valid) decision <= 1;
            if (asi_in0_valid) decision <= 0;
            if (asi_in4_valid) decision <= 4;
            if (asi_in3_valid) decision <= 3;
            if (asi_in2_valid) decision <= 2;
         end  
         2 : begin
            if (asi_in2_valid) decision <= 2;
            if (asi_in1_valid) decision <= 1;
            if (asi_in0_valid) decision <= 0;
            if (asi_in4_valid) decision <= 4;
            if (asi_in3_valid) decision <= 3;
         end  
         3 : begin
            if (asi_in3_valid) decision <= 3;
            if (asi_in2_valid) decision <= 2;
            if (asi_in1_valid) decision <= 1;
            if (asi_in0_valid) decision <= 0;
            if (asi_in4_valid) decision <= 4;
         end  
         4 : begin
            if (asi_in4_valid) decision <= 4;
            if (asi_in3_valid) decision <= 3;
            if (asi_in2_valid) decision <= 2;
            if (asi_in1_valid) decision <= 1;
            if (asi_in0_valid) decision <= 0;
         end  
         default : begin // Same as '0', should never get used.
            if (asi_in0_valid) decision <= 0;
            if (asi_in4_valid) decision <= 4;
            if (asi_in3_valid) decision <= 3;
            if (asi_in2_valid) decision <= 2;
            if (asi_in1_valid) decision <= 1;
         end  
      endcase   
   end

   // ---------------------------------------------------------------------
   //| Capture Decision
   // ---------------------------------------------------------------------
   always @ (negedge csi_clock_reset_n, posedge csi_clock_clk) begin
      if (!csi_clock_reset_n) begin
         select <= 0;
         in_a_packet <= 0;
      end else begin
         if (
                ((selected_valid == 0) && (in_a_packet == 0)) || 
                ((selected_valid == 1) && (selected_ready == 1) && (selected_endofpacket))
            ) begin
            select <= decision;
            in_a_packet <= 0;
         end
         else if ((selected_valid == 1) && (selected_ready == 1) && (selected_startofpacket)) begin
            in_a_packet <= 1;
         end
      end
   end

   // ---------------------------------------------------------------------
   //| Mux
   // ---------------------------------------------------------------------
   always @* begin
      case(select) 
         0 : begin
            selected_payload <= asi_in0_payload;         
            selected_valid   <= asi_in0_valid;
            selected_endofpacket <= asi_in0_endofpacket;
            selected_startofpacket <= asi_in0_startofpacket;
         end  
         1 : begin
            selected_payload <= asi_in1_payload;         
            selected_valid   <= asi_in1_valid;
            selected_endofpacket <= asi_in1_endofpacket;
            selected_startofpacket <= asi_in1_startofpacket;
         end  
         2 : begin
            selected_payload <= asi_in2_payload;         
            selected_valid   <= asi_in2_valid;
            selected_endofpacket <= asi_in2_endofpacket;
            selected_startofpacket <= asi_in2_startofpacket;
         end  
         3 : begin
            selected_payload <= asi_in3_payload;         
            selected_valid   <= asi_in3_valid;
            selected_endofpacket <= asi_in3_endofpacket;
            selected_startofpacket <= asi_in3_startofpacket;
         end  
         4 : begin
            selected_payload <= asi_in4_payload;         
            selected_valid   <= asi_in4_valid;
            selected_endofpacket <= asi_in4_endofpacket;
            selected_startofpacket <= asi_in4_startofpacket;
         end  
         default : begin
            selected_payload <= asi_in0_payload;         
            selected_valid <= asi_in0_valid;
            selected_endofpacket <= asi_in0_endofpacket;
            selected_startofpacket <= asi_in0_startofpacket;
         end
      endcase

   end

   // ---------------------------------------------------------------------
   //| Back Pressure
   // ---------------------------------------------------------------------
   always @* begin
      asi_in0_ready <= ~asi_in0_valid   ;
      asi_in1_ready <= ~asi_in1_valid   ;
      asi_in2_ready <= ~asi_in2_valid   ;
      asi_in3_ready <= ~asi_in3_valid   ;
      asi_in4_ready <= ~asi_in4_valid   ;
      case(select) 
         0 : asi_in0_ready <= selected_ready;
         1 : asi_in1_ready <= selected_ready;
         2 : asi_in2_ready <= selected_ready;
         3 : asi_in3_ready <= selected_ready;
         4 : asi_in4_ready <= selected_ready;
         default : asi_in0_ready <= selected_ready;
      endcase
   end

   // ---------------------------------------------------------------------
   //| output Pipeline
   // ---------------------------------------------------------------------
   ethernet_packet_multiplexer_1stage_pipeline #( .PAYLOAD_WIDTH( 36 ) ) outpipe (
        .clk            (csi_clock_clk ),
        .reset_n        (csi_clock_reset_n),
        .in_ready       (selected_ready),
        .in_valid       (selected_valid), 
        .in_payload     (selected_payload),
        .out_ready      (aso_out_ready), 
        .out_valid      (out_valid_wire), 
        .out_payload    (out_payload)
    );
   
   // ---------------------------------------------------------------------
   //| Output Mapping
   // ---------------------------------------------------------------------
   always @* begin
     aso_out_valid   <= out_valid_wire;
     {aso_out_data,aso_out_startofpacket,aso_out_endofpacket,aso_out_empty} <= out_payload;
   end


endmodule

//  --------------------------------------------------------------------------------
// | single buffered pipeline stage
//  --------------------------------------------------------------------------------
module ethernet_packet_multiplexer_1stage_pipeline  
#( parameter PAYLOAD_WIDTH = 8 )
 ( input                          clk,
   input                          reset_n, 
   output reg                     in_ready,
   input                          in_valid,   
   input      [PAYLOAD_WIDTH-1:0] in_payload,
   input                          out_ready,   
   output reg                     out_valid,
   output reg [PAYLOAD_WIDTH-1:0] out_payload      
 );
      
   always @* begin
     in_ready <= out_ready || ~out_valid;
   end
   
   always @ (negedge reset_n, posedge clk) begin
      if (!reset_n) begin
         out_valid <= 0;
         out_payload <= 0;
      end else begin
         if (in_valid) begin
           out_valid <= 1;
         end else if (out_ready) begin
           out_valid <= 0;
         end
         
         if(in_valid && in_ready) begin
            out_payload <= in_payload;
         end
      end
   end

endmodule

