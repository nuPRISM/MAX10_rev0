module version_function_wrapper 
(
output [31:0] version
);
`include "version_function.v"

assign version = get_compilation_version;

endmodule
