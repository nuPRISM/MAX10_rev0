`ifndef UTILITIES_PACKAGE_V
`define UTILITIES_PACKAGE_V

package utilities;
				/*	function shortreal bitstoshortreal;
					  input logic [31:0] bits;

					  logic sign;
					  logic [7:0] exp;
					  logic [22:0] frac;
					  shortreal sr;
					  logic [23:0] xfrac;

					  sign = bits[31];
					  exp  = bits[30:23];
					  frac = bits[22: 0];

					  xfrac = {1'b1, frac};
					  sr = 1.0 * xfrac;
					  sr = sr / 8388608.0;
					  if (exp >= 8'h7F) begin
						exp  = bits[30:23] - 8'h7F;
						sr = sr * (1 << exp);
					  end
					  else begin
						exp = 8'h7F - bits[30:23];
						sr = sr / (1 << exp);
					  end

					  bitstoshortreal = bits == 0 ? 0 : sign ? -1.0 * sr : sr;
					endfunction

					function logic [31:0] shortrealtobits;
					  input shortreal r;

					  logic sign;
					  integer iexp;
					  logic [7:0] exp;
					  logic [22:0] frac;
					  shortreal abs, ffrac;

					  sign = r < 0.0 ? 1 : 0;
					  abs = sign ? -1.0*r : r;
					  iexp  = $floor($ln(abs) / $ln(2));
					  ffrac = abs / $pow(2, iexp);
					  ffrac = ffrac - 1.0;
					  frac = ffrac * 8388608.0;
					  exp = (r==0) ? 0 : 127 + iexp;

					  shortrealtobits = {sign, exp, frac};
					endfunction
					*/
					/*
					function automatic [NUM_REGS * 32 -1 : 0] hex_string_to_vector( input [NUM_REGS * 64 -1 : 0] sting_val);
					begin : func_inner
						reg [NUM_REGS * 32 -1 : 0] retval;
						reg [7:0] char;
						integer regnum;
						integer nibble_num;
						reg  [3:0] nibble_value;
						for (regnum = 0; regnum < NUM_REGS; regnum = regnum + 1) begin
							for (nibble_num = 0; nibble_num < 8; nibble_num = nibble_num + 1) begin
								char         = sting_val[(regnum * 64) + (nibble_num * 8) +: 8];
								nibble_value = 4'h0; // 4'hX;   // better default is it means software is OK and gets 0 instead of a compile-time generated value
								//lookup table below converts a 8 bit ASCI char into a hex nibble.
								case (char)
									"0" : begin nibble_value = 4'h0; end
									"1" : begin nibble_value = 4'h1; end
									"2" : begin nibble_value = 4'h2; end
									"3" : begin nibble_value = 4'h3; end
									"4" : begin nibble_value = 4'h4; end
									"5" : begin nibble_value = 4'h5; end
									"6" : begin nibble_value = 4'h6; end
									"7" : begin nibble_value = 4'h7; end
									"8" : begin nibble_value = 4'h8; end
									"9" : begin nibble_value = 4'h9; end
									"A" : begin nibble_value = 4'hA; end
									"B" : begin nibble_value = 4'hB; end
									"C" : begin nibble_value = 4'hC; end
									"D" : begin nibble_value = 4'hD; end
									"E" : begin nibble_value = 4'hE; end
									"F" : begin nibble_value = 4'hF; end
									default : begin
					//synthesis translate_off
										$error("function can not decode the ASCII for 0x:%2x", char);
					//synthesis translate_on
											  end
								endcase
								retval[(regnum * 32) + (nibble_num * 4)+:4] = nibble_value[0+:4];
							end // nibble exteraction
						end
						hex_string_to_vector = retval;
						//return(retval);
					end
					endfunction
					*/
					
					function automatic logic [7:0] sum_num_uarts_here(input logic [7:0] num_uarts_here[256], input int lower_index = 0, input int upper_index = 255);
					
					  sum_num_uarts_here = 0;
					  for (int i = lower_index; i <= upper_index; i++)
					  begin : sum_now
					       sum_num_uarts_here += num_uarts_here[i];
					  end
					 					  
					endfunction
					
endpackage
`endif