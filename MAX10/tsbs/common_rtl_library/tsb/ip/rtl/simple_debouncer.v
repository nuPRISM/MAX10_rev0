
module simple_debouncer 
(clock, 
noisy, 
clean
);
   parameter DELAY = 500000;   // .01 sec with a 50MHz clock
   `include "log2_function.v";
   reg [log2(DELAY)-1:0] count;
   
   input clock, noisy;
   output clean;

   reg delay_noisy1=0, delay_noisy2=0;
   always @(posedge clock)
   begin
        delay_noisy1 <= noisy;
	    delay_noisy2 <= delay_noisy1;		
   end
   
   reg new_val=0, clean=0;

   always @(posedge clock)
     if (delay_noisy2 != new_val) begin 
			 new_val <= delay_noisy2; 
			 count <= 0; 
	 end
     else  if (count >= DELAY) clean <= new_val;
     else count <= count+1;
      
endmodule // debounce