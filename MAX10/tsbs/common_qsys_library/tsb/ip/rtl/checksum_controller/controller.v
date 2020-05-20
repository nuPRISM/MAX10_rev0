module controller(
	clk,
	reset,
	
	avs_address,
	avs_read,
	avs_readdata,
	avs_write,
	avs_writedata,
	avs_byteenable,
	avs_waitrequest,
	
	src_cmd_data,
	src_cmd_valid,
	src_cmd_ready,
	
	snk_response_data,
	snk_response_valid,
	snk_response_ready,
	
	snk_result_data,
	snk_result_valid,
	snk_result_ready,
	
	irq
);

	input clk;
	input reset;
	input [2:0] avs_address;
	input avs_read;
	output wire [31:0] avs_readdata;
	input avs_write;
	input [31:0] avs_writedata;
	input [3:0] avs_byteenable;
	output wire avs_waitrequest;
	
	output reg [255:0] src_cmd_data;
	output reg src_cmd_valid;
	input src_cmd_ready;
	
	input [255:0] snk_response_data;
	input snk_response_valid;
	output wire snk_response_ready;
	
	input [15:0] snk_result_data;
	input snk_result_valid;
	output reg snk_result_ready;
	
	output wire irq;
	
	reg [31:0] read_address_register;
	reg [31:0] length_register;
	reg [31:0] control_register;
	reg [31:0] status_register;
	reg [15:0] checksum_result;
	reg control_go_d1;
	reg done_d1;
	reg [31:0] control_readdata_temp_d1;
	reg [2:0] avs_address_dl;
	reg avs_write_dl;
	reg [3:0] avs_byteenable_dl;
	
	wire [255:0] read_command_data_out;
	wire interrupt_en;
	wire result_invert;
	wire control_go;	
	wire done;
	wire done_strobe;
	wire [31:0] control_readdata_temp;
	wire [31:0] checksum_register;
	

/**************************************************************
 Readback path (latency 1)
 **************************************************************/
	assign checksum_register = (result_invert == 1)? ~checksum_result : checksum_result;
	
	assign control_readdata_temp = (avs_address == 3'b000)? read_address_register :
							  (avs_address == 3'b001)? length_register :
							  (avs_address == 3'b010)? control_register :
							  (avs_address == 3'b011)? status_register : 
							  (avs_address == 3'b100)? checksum_register : 0;
							
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			control_readdata_temp_d1 <= 0;
		end
		else
		begin
			if (avs_read == 1)
			begin
				control_readdata_temp_d1 <= control_readdata_temp;
			end
		end
	end
	
	assign avs_readdata = control_readdata_temp_d1;

	
/**************************************************************
 Read address register
 **************************************************************/
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			read_address_register <= 0;
		end
		else
		begin
			if ((avs_address == 3'b000) & (avs_write == 1))
			begin
				if (avs_byteenable[0] == 1)
				begin
					read_address_register[7:0] <= avs_writedata[7:0];
				end
				if (avs_byteenable[1] == 1)
				begin
					read_address_register[15:8] <= avs_writedata[15:8];
				end
				if (avs_byteenable[2] == 1)
				begin
					read_address_register[23:16] <= avs_writedata[23:16];
				end
				if (avs_byteenable[3] == 1)
				begin
					read_address_register[31:24] <= avs_writedata[31:24];
				end		
			end
		end
	end
	
/**************************************************************
 Length register
 **************************************************************/
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			length_register <= 0;
		end
		else
		begin
			if ((avs_address == 3'b001) & (avs_write == 1))
			begin
				if (avs_byteenable[0] == 1)
				begin
					length_register[7:0] <= avs_writedata[7:0];
				end
				if (avs_byteenable[1] == 1)
				begin
					length_register[15:8] <= avs_writedata[15:8];
				end
				if (avs_byteenable[2] == 1)
				begin
					length_register[23:16] <= avs_writedata[23:16];
				end
				if (avs_byteenable[3] == 1)
				begin
					length_register[31:24] <= avs_writedata[31:24];
				end		
			end
		end
	end

/**************************************************************
 Delayed registers
 **************************************************************/	
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			avs_write_dl <= 0;
			avs_address_dl <= 0;
			avs_byteenable_dl <= 0;
		end
		else
		begin
			avs_write_dl <= avs_write;
			avs_address_dl <= avs_address;
			avs_byteenable_dl <= avs_byteenable;
		end
	end
	
/**************************************************************
 Control register
 **************************************************************/
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			control_register <= 0;
		end
		else
		begin
			if ((avs_address == 3'b010) & (avs_write == 1))
			begin
				if (avs_byteenable[0] == 1)
				begin
					control_register[7:0] <= avs_writedata[7:0];
				end
				if (avs_byteenable[1] == 1)
				begin
					control_register[15:8] <= avs_writedata[15:8];
				end
				if (avs_byteenable[2] == 1)
				begin
					control_register[23:16] <= avs_writedata[23:16];
				end
				if (avs_byteenable[3] == 1)
				begin
					control_register[31:24] <= avs_writedata[31:24];
				end		
			end
		end
	end
	
	assign interrupt_en = control_register[0];
	assign result_invert = control_register[8];
	assign control_go = ((avs_address_dl == 3'b010) & (avs_write_dl == 1) & (avs_byteenable_dl[2] == 1)) & control_register[16]; //write this bit after finish writing length and read addr

	
/**************************************************************
 Status register, done, busy, interrupt
 **************************************************************/
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			status_register <= 0;
		end
		else
		begin
			if (done_strobe == 1)
			begin
				status_register <= 32'h00000001;  //done
			end
			else if (control_go == 1)
			begin
				status_register <= 32'h00000100;  //busy
			end
			else if ((avs_address == 3'b011) & (avs_write == 1))
			begin
				status_register <= 32'h0;  // clear on write
			end
		end
	end

	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			done_d1 <= 0;
		end
		else
		begin			
				done_d1 <= done;			
		end
	end
	
	assign done = snk_result_valid;
	assign done_strobe = (done == 1) & (done_d1 == 0);
	
	assign irq = interrupt_en & status_register[0];
	
/**************************************************************
 Checksum result register
 **************************************************************/
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			checksum_result <= 0;
		end
		else
		begin
			if (snk_result_valid == 1)
			begin
				checksum_result <= snk_result_data;
			end		
		end
	end
		
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			snk_result_ready <= 1;
		end
		else
		begin
			if (status_register[0] == 1)
			begin
				snk_result_ready <= 0;
			end
			else if (status_register[0] == 0)
			begin
				snk_result_ready <= 1;
			end			
		end
	end


/**************************************************************
 Command sent to read master with valid signal
 **************************************************************/
	assign read_command_data_out = {{148{1'b0}},  // zero pad the upper 148 bits
                                 {8{1'b0}},			// error support is not used
                                 {16{1'b0}},		// stride addressing is disabled
                                 {8{1'b0}},			// BURST!!!
                                 1'b0,					// sw reset is disabled
                                 1'b0,					// sw stop is disabled
                                 1'b1,					// EOP = 1
                                 1'b1,					// SOP = 1
                                 {8{1'b0}},			// channel support is not used
                                 length_register,
                                 read_address_register};

	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			src_cmd_data <= 0;
		end
		else
		begin
			if (control_go == 1) 
			begin
				src_cmd_data <= read_command_data_out;
			end
		end
	end
	
	always @ (posedge clk or posedge reset)
	begin
		if (reset)
		begin
			src_cmd_valid <= 0;
		end
		else
		begin
			if (control_go == 1) 
			begin
				src_cmd_valid <= 1'b1;
			end
			else if ((src_cmd_valid == 1) & (src_cmd_ready == 1))
			begin
				src_cmd_valid <= 1'b0;
			end
		end
	end
	
/**************************************************************
 Do nothing with the response receive from the read master
 **************************************************************/
	assign snk_response_ready = 1'b1;

	
/**************************************************************
 Waitrequest wired to ground
 **************************************************************/
	assign avs_waitrequest = 1'b0;
	
endmodule
