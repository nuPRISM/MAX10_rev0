`ifndef EMBEDDED_SERIAL_DATA_INTEFACE_DEFS_V
`define EMBEDDED_SERIAL_DATA_INTEFACE_DEFS_V

interface embedded_2_bit_serial_data_interface;
		parameter num_data_streams = 4;
		parameter num_parallel_2_bit_chunks = 4;
        logic [num_parallel_2_bit_chunks-1 : 0] serial_data[num_data_streams];
        logic [num_parallel_2_bit_chunks-1 : 0] serial_sop [num_data_streams];
endinterface

`endif