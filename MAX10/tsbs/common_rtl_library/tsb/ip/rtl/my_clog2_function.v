
	function automatic int my_clog2 (input int n);
						int original_n;
						original_n = n;
						if (n <=1) return 1; // abort function
						my_clog2 = 0;
						while (n > 1) begin
						    n = n/2;
						    my_clog2++;
						end
						
						if (2**my_clog2 != original_n)
						begin
						     my_clog2 = my_clog2 + 1;
						end
						
						endfunction
						