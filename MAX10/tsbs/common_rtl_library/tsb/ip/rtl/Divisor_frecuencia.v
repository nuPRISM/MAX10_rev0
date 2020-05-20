`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:06:24 02/10/2009 
// Design Name: 
// Module Name:    Divisor_frecuencia 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Divisor_frecuencia
	#(parameter Bits_counter = 32)
	 (	input  CLOCK,
		output TIMER_OUT,
		input  [Bits_counter-1:0] Comparator,
		output reg [Bits_counter-1:0] Timer1
		);

   reg RESULT;
	
   always @(posedge CLOCK)
	begin
		
		if (Timer1 >= Comparator)
			begin
			     RESULT <= !RESULT;
			     Timer1 <= 0;
			end		
			
		else
		   begin
			     Timer1 <= Timer1+1; 
				  RESULT <= RESULT;
		   end
	end	
	assign TIMER_OUT = RESULT; 

endmodule
