module find_first_free_buffer
#(
  parameter numbuffers = 8
)
(
 input clk,
 input  [numbuffers-1:0] buffer_is_free,
 output logic [numbuffers-1:0] free_buffer_decision,
 output a_free_buffer_exists,
 output logic [numbuffers-1:0] possible_classification_candidate[numbuffers-1:0]
);
     
	   assign possible_classification_candidate[0] = buffer_is_free[0];
       
	   integer possible_classification_sum = 0;
	   integer inner_count;
	   always @*
	   begin
	           integer estimator_count2;
	           for (estimator_count2 = 1; estimator_count2 < numbuffers; estimator_count2++)
			   begin
			        //now set up an interesting way to codify the decision result
					possible_classification_sum = 0;
					for (inner_count = 0; inner_count < estimator_count2; inner_count++)
					begin
      					possible_classification_sum = possible_classification_sum +  possible_classification_candidate[inner_count][numbuffers-1:0];
				    end
							
					possible_classification_candidate[estimator_count2] = (buffer_is_free[estimator_count2] && (possible_classification_sum == 0)) ? (estimator_count2+1) : 0;
					
			   end
	   end
	   
	   
	   
		integer free_buffer_decision_count;
				
		always @ (posedge clk)
		begin
			  free_buffer_decision_count = 0;  
			    for (integer estimator_count3 = 0; estimator_count3 < numbuffers; estimator_count3++)
				   free_buffer_decision_count = free_buffer_decision_count + possible_classification_candidate[estimator_count3];
					  
				 free_buffer_decision <= (free_buffer_decision_count == 0) ? free_buffer_decision_count : (free_buffer_decision_count-1);	 
		end
		
		always @(posedge clk)
		begin
		     a_free_buffer_exists <= |buffer_is_free;		
		end

endmodule