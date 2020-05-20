
//Author : Ebenezer Dwobeng  ebenezer-d@ti.com



module dec_data_capture_gz #(parameter M=2,SAMPLES_PER_CLK = 1,WR_ADDR_WIDTH=15,PRBS_L=16, PRBS_M=9,PRBS_N=5
)
(

	input  wire                  clk, //clock and reset associated with the slave interface
	input  wire                  rstn,
	input  wire                  clk_mem,
	input  wire                  rstn_mem,
	input  wire                  rstn_100,
	input wire 						clk_100,
	//input  wire                  afi_clock,//clock and reset associated with the master interface
	//input  wire                  afi_rstn,

	// Avalon Streaming Sink Interface
	// ready Latency = 0
	
	
	input  wire                  avst_valid,
	input  wire [M*SAMPLES_PER_CLK*16-1:0]       avst_data,
	
	output wire                  avst_ready,

	// Avalon Memory Mapped Slave Interface
	input  wire                 avmm_write_en,
	input  wire                 avmm_read_en,
	input  wire  [15:0]         avmm_addr,
 	input  wire  [31:0]         avmm_datain,

	//output  reg                 avmm_rddata_valid,
	//output  wire                avmm_waitrequest,
	output  reg  [31:0]         avmm_dataout,
	
	input	  wire						 lmfc_pulse_rx,

	// Avalon Memory Mapped Slave Master: used to write to external DDR3A memory
	output wire						 mem_avm_m1_read,
	input wire						 mem_avm_m1_waitrequest,
	input wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m1_readdata,
	output wire						 mem_avm_m1_write,
	output wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m1_writedata,
	input wire						 mem_avm_m1_readdatavalid,
	output wire	[31:0]			 mem_avm_m1_address,	
	output wire	[3:0]			 mem_avm_m1_burstcount,
	
	
	// Avalon Memory Mapped Slave Master: used to write to external DDR3B memory
	output wire						 mem_avm_m2_read,
	input wire						 mem_avm_m2_waitrequest,
	input wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m2_readdata,
	output wire						 mem_avm_m2_write,
	output wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m2_writedata,
	input wire						 mem_avm_m2_readdatavalid,
	output wire	[31:0]			 mem_avm_m2_address,	
	output wire	[3:0]			 mem_avm_m2_burstcount,
	
	input wire	[1:0]				jesd_rx_M
	
	);
//import jesdcon_pkg::*; //get the log2 function

`define DEC_CONTROL_REG_ADDR  16'h8000
`define PATTERN_MODE_ADDR  16'h0010
localparam WR_DATA_WIDTH = 16*M*SAMPLES_PER_CLK;
localparam WR_MEM_DEPTH = 2<<WR_ADDR_WIDTH;
localparam BURSTCOUNT = 8;

reg [27:0] capture_data_len,n_capture_data_len;
reg [27:0] data_len_a,data_len_b;
wire    capture_start;   
wire    capture_done; 
wire    prbs_checker;
wire	  xcvr_mode;

reg [WR_ADDR_WIDTH-1:0]  mem_wr_addr , n_mem_wr_addr, ddr3a_mem_wr_addr,n_ddr3a_mem_wr_addr,
								ddr3b_mem_wr_addr,n_ddr3b_mem_wr_addr, ddr3a_mem_wr_addr_dly1,ddr3a_mem_wr_addr_dly2,
								ddr3b_mem_wr_addr_dly1,ddr3b_mem_wr_addr_dly2;
reg [WR_DATA_WIDTH-1:0]  mem_wr_data , n_mem_wr_data, ddr3_mem_wr_data;
reg                      mem_wr_en   , n_mem_wr_en, ddr3a_wr_en,n_ddr3a_wr_en,ddr3b_wr_en,n_ddr3b_wr_en;
reg [15:0]               mem_rd_addr , n_mem_rd_addr;
wire [31:0]              mem_rd_data;

reg [31:0]               cntrl_reg , n_cntrl_reg;
reg [7:0]               pattern_mode, n_pattern_mode;
reg                      n_avmm_rddata_valid;
reg  [31:0]              n_avmm_dataout;
reg	[3:0]					avst_valid_r, mem_wr_en_r;
reg							flush_fifo_dly;


reg mem_rd_valid, n_mem_rd_valid, mem_rd_valid_d1, mem_rd_valid_d2;
reg [1:0] state, n_state;
reg [1:0]	dec_state_a, dec_state_b;
reg rd_state, n_rd_state;

reg ddr3_stop, n_ddr3_stop, n_fifo_wr, ddr3a_done, n_ddr3a_done, ddr3b_done, n_ddr3b_done;

	wire						 mem_avm_m0_read;
	wire						 mem_avm_m0_waitrequest;
	wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m0_readdata,mem_avm_m1_writedata_a,mem_avm_m1_writedata_b;
	wire						 mem_avm_m0_write;
	wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m0_writedata;
	wire						 mem_avm_m0_readdatavalid;
	wire	[31:0]			 mem_avm_m0_address;
	wire	[3:0]			 mem_avm_m0_burstcount;
	wire empty_a, empty_b, empty_c;
	wire [7:0]			wrusedw_a, wrusedw_b, wrusedw_c;
	wire 					en_ddr3a, en_ddr3b;
	reg      rd_start_a, rd_start_b, n_rd_start_a, n_rd_start_b;
	reg          count_update,count_update_a,count_update_b;
	
	reg			m1_write,m2_write;
	
	wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m1_writedata_a1;
	wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m2_writedata_a1;
	
	wire mem_en_a, mem_en_b;
	
	
//PRBS checker
wire [M-1:0][15:0] dec_data;

parameter IDLE = 2'b00,
	      AVST_WRITE = 2'b10,
			LMFC_WAIT=2'b01,
			DEC_IDLE_A =2'b00,
			DEC_IDLE_B =2'b00,
			DEC_STREAM_A =2'b01,
			DEC_STREAM_B =2'b01;			
parameter SEND_DATA = 1'b1;


//assign mem_avm_m1_writedata = mem_avm_m0_writedata[M*SAMPLES_PER_CLK*8-1:0];
//assign mem_avm_m2_writedata = mem_avm_m0_writedata[M*SAMPLES_PER_CLK*16-1:M*SAMPLES_PER_CLK*8];
assign mem_avm_m1_address = ddr3a_mem_wr_addr;
assign mem_avm_m2_address = ddr3b_mem_wr_addr;
//assign mem_avm_m1_write = n_ddr3a_wr_en;
//assign mem_avm_m2_write = n_ddr3b_wr_en;
assign mem_avm_m1_write = m1_write & rd_start_a & !mem_avm_m1_waitrequest;
assign mem_avm_m2_write = m2_write & rd_start_b & !mem_avm_m2_waitrequest;
//assign mem_avm_m1_write = mem_en_a;
//assign mem_avm_m2_write = mem_en_b;


assign mem_avm_m1_burstcount = BURSTCOUNT;
assign mem_avm_m2_burstcount = BURSTCOUNT;



assign		mem_avm_m1_read = 1'b0;
assign		mem_avm_m2_read = 1'b0;

//Dual port memory 
//dec_mem /*#(
//	.WR_MEM_DEPTH        (WR_MEM_DEPTH),
//	.WR_ADDR_WIDTH       (WR_ADDR_WIDTH),
//	.WR_DATA_WIDTH       (WR_DATA_WIDTH)
//)*/
//dec_mem_inst(
//	.clock ( clk ),
//	.data ( mem_wr_data),
//	.rdaddress ( mem_rd_addr), // Start read from the fourth address instead of first address because the data saved in the first three address are not valid as the valid signal has 4 cycle delay compared to ready signal
//	.wraddress ( mem_wr_addr),
//	.wren ( mem_wr_en ),
//	.q ( mem_rd_data )
//	);
/*
always @(*)
begin
    //n_mem_rd_addr       = mem_rd_addr; 
	//n_mem_rd_valid      = 1'b0;
	n_avmm_rddata_valid = 1'b0;
	n_avmm_dataout      = avmm_dataout;
	n_cntrl_reg =cntrl_reg;
	//n_rd_state = rd_state;
	

 // case(rd_state)
//	IDLE:
//	begin
				
		if(avmm_write_en) 
		begin
		   if(avmm_addr == `DEC_CNTROL_REG_ADDR)
		  	n_cntrl_reg = avmm_datain; //control register 
		//	if(avmm_addr == `PATTERN_MODE_ADDR)
		//	   n_pattern_mode = avmm_datain[7:0];
		end
					
		if(avmm_read_en)
		begin
		if(avmm_addr == `DEC_CNTROL_REG_ADDR)
		begin
		  		n_avmm_dataout = cntrl_reg; //control register
				n_avmm_rddata_valid = 1'b1;
		//	n_rd_state = IDLE;
		end
		end
		
		if(ddr3a_done && ddr3b_done && !mem_wr_en)
		n_cntrl_reg[1:0]   = 2'b10;

	//	if(avmm_read_en)
	//	begin
	 //    		n_mem_rd_addr = avmm_addr;				
	 //  		n_mem_rd_valid = 1'b1; 		
	//			n_rd_state = SEND_DATA;
	//    end
//	end
//	SEND_DATA:
//	begin
//		if(avmm_addr == `DEC_CNTROL_REG_ADDR)
//		begin
//		  		n_avmm_dataout = cntrl_reg; //control register
//				n_avmm_rddata_valid = 1'b1;
//			n_rd_state = IDLE;
//		end
//		else if(mem_rd_valid_d2) //two cycle delay to get the data fom memory
//		begin
//			n_avmm_dataout = mem_rd_data;
//		   	n_avmm_rddata_valid = 1'b1;
//			n_rd_state = IDLE;
//		end
		//n_rd_state = IDLE;
//	end
 //   default:
//	   n_rd_state = IDLE;
 //  endcase
end
*/

	always @ (posedge clk_100 or negedge rstn_100)
	begin
	if (!rstn_100)
	begin
	cntrl_reg <= 0;
	//data_len = 0;
	//capture_data_len = 0;
	//avmm_rddata_valid = 0;
	avmm_dataout <= 0;
	end
	
	else
	
	begin
	if(avmm_write_en)
	begin
		if(avmm_addr == `DEC_CONTROL_REG_ADDR)
		begin
		cntrl_reg <= avmm_datain; //control register
				
       end
	end
		
		 if(avmm_read_en)
	       begin
			 if(avmm_addr == `DEC_CONTROL_REG_ADDR)
			 begin
		//  avmm_rddata_valid  = 1'b1;
		  avmm_dataout       <= cntrl_reg; //expecting read data from AV_ST interface
	       end		
			 end
		//		else
		//	avmm_rddata_valid = 1'b0;
	
	if(n_ddr3a_done && n_ddr3b_done)
		cntrl_reg <= 'd2;
	//	if (clear_cntrl_reg)
	//	cntrl_reg = 0;
	
//		capture_done     = cntrl_reg[1];
//		
//		if (count_update)
//		begin
//		
//		capture_start    = cntrl_reg[0];
//				
//		xcvr_mode      = cntrl_reg[3];
//		
//		capture_data_len = cntrl_reg[31:4];
//		if(xcvr_mode)
//		data_len = cntrl_reg[31:4];
//		else
//		data_len = cntrl_reg[31:5];	
//		end
		
	end	
	end

	





//always @(*)
always @(posedge clk or negedge rstn)
begin
if (!rstn)
begin
    //n_cntrl_reg   = cntrl_reg;
	 //n_pattern_mode = pattern_mode;
    mem_wr_addr <= 0;
    //n_mem_wr_data = mem_wr_data;
    n_mem_wr_en   <= 1'b0;
	state <= IDLE;
	//count_update <= 1'b0;
	capture_data_len <= 0;
	//capture_data_len <= 0;
	//cntrl_reg <=0;
	//avmm_rddata_valid <=1'b0;
	//rd_start_a <= 1'b0;
	//rd_start_b <= 1'b0;
	//n_ddr3_stop = 1'b0;
//	n_ddr3a_mem_wr_addr = ddr3a_mem_wr_addr;
//	n_ddr3b_mem_wr_addr = ddr3b_mem_wr_addr;
//	n_ddr3a_wr_en = 1'b0;
//	n_ddr3b_wr_en = 1'b0;
//	n_ddr3a_done = ddr3a_done;
//	n_ddr3b_done = ddr3b_done;
//	n_rd_start_a = rd_start_a;
//		n_rd_start_b = rd_start_b;
	//n_fifo_wr = 1'b1;
end
//capture data in the memory

else
	begin

case(state)
	IDLE:
	begin
	mem_wr_addr <= 'd0;
	n_mem_wr_en   <= 1'b0;
	//count_update <=1'b1;
	capture_data_len <= cntrl_reg[31:4];
	
	if(!empty_c || !empty_b || !empty_a)
	flush_fifo_dly <= 1'b1;	
	else
		begin
	 flush_fifo_dly <= 1'b0;	
		//if(capture_start & (!capture_done))
		//if(rd_start_a & (rd_start_b | xcvr_mode) & avst_valid)
		if(rd_start_a && (rd_start_b || xcvr_mode))
		begin			
		//	count_update <=1'b0;
			state <= LMFC_WAIT;
		//state <= AVST_WRITE;		
		end
	end	
	end
	
	LMFC_WAIT:
		begin		
		if(lmfc_pulse_rx)
		begin
		//n_mem_wr_data = avst_data;
		//if (avst_valid)
		//begin
		//n_mem_wr_en   <= 1'b1;
		//mem_wr_addr <= mem_wr_addr + 1'b1;
		//end
		state <= AVST_WRITE;
		
		end
		end
		
	AVST_WRITE:
	begin
	//rd_start_a <= 1'b1;
	//rd_start_b <= 1'b1;
	//	  if(avst_valid)
	//  begin	  
	  
	  if (mem_wr_addr >= capture_data_len-1)
	  begin
	  if(avst_valid & n_mem_wr_en)
	  n_mem_wr_en <= 1'b0;
	  //mem_wr_addr <= mem_wr_addr;	  
	  end
	  	  else
	  begin
	 n_mem_wr_en <= 1'b1;
	 if(avst_valid & n_mem_wr_en)
	 mem_wr_addr <= mem_wr_addr + 1'b1;
		end		
	//	else
	//	n_mem_wr_en <= 1'b0;	  
	//  end
	//  else
	//  begin
	//  n_mem_wr_en <= 1'b0;
	  //n_mem_wr_en_b <= 1'b0;
	//  end
	  

		if(capture_done)
		begin
	//	cntrl_reg   <= 'd2;
		//rd_start_a <= 1'b0;
		//rd_start_b <= 1'b0;
		state <= IDLE;
		flush_fifo_dly <= 1'b1;
		//n_mem_wr_en <= 1'b0;
		end
		//n_rd_start_a = 1'b0;
		//n_rd_start_b = 1'b0;
		//n_ddr3a_mem_wr_addr = 0;
		//n_ddr3b_mem_wr_addr = 0;
//	end

	  end
//	end
	default:
	begin
			state <= IDLE;
	end
	
endcase
end
end

//always @ (*)
always @(posedge clk_mem or negedge rstn_mem)
begin
if (!rstn_mem)
  begin
   ddr3a_mem_wr_addr <= 0;
	//ddr3b_mem_wr_addr = 0;
	//ddr3a_wr_en <= 1'b0;
	//ddr3b_wr_en = 1'b0;
	n_ddr3a_done <= 1'b0;
	//n_ddr3b_done = 1'b0;
	rd_start_a <= 1'b0;
	dec_state_a <= DEC_IDLE_A;
	data_len_a <= 0;
	m1_write <= 1'b0;
	//rd_start_b = 1'b0;
	//state_mem = IDLE_MEM;
end

else 
begin

case (dec_state_a)

DEC_IDLE_A: begin

	n_ddr3a_done <= 1'b0;
	ddr3a_mem_wr_addr <= 0;
	rd_start_a <= 1'b0;
	m1_write <= 1'b0;
	if(xcvr_mode)
		data_len_a <= cntrl_reg[31:4];
		else
		data_len_a <= cntrl_reg[31:5];	
	
//if(capture_start & (!capture_done) & !empty_a & !mem_avm_m1_waitrequest)
if(capture_start && (!capture_done))
	begin
	//rd_start_a <= 1'b1;
	dec_state_a <= DEC_STREAM_A;
	
	//ddr3a_mem_wr_addr <= ddr3a_mem_wr_addr + 1'b1;
	end
end



DEC_STREAM_A: begin

		if (!mem_avm_m1_waitrequest)
		m1_write <= en_ddr3a;
		
	if(ddr3a_mem_wr_addr >= data_len_a-1)
	begin
		if (mem_avm_m1_write)
		begin
			n_ddr3a_done <= 1'b1;
			rd_start_a <= 1'b0;
		end
	end	
	else
	begin
		rd_start_a <= 1'b1;
		if (mem_avm_m1_write)
		ddr3a_mem_wr_addr <= ddr3a_mem_wr_addr + 1'b1;		
    end
		
	if (capture_done)
	begin
		dec_state_a <= DEC_IDLE_A;
		n_ddr3a_done <= 1'b0;
	end
	end
endcase

end
end


always @(posedge clk_mem or negedge rstn_mem)
begin
if (!rstn_mem)
  begin
   ddr3b_mem_wr_addr <= 0;
	//ddr3b_mem_wr_addr = 0;
	//ddr3b_wr_en <= 1'b0;
	//ddr3b_wr_en = 1'b0;
	n_ddr3b_done <= 1'b0;
	//n_ddr3b_done = 1'b0;
	data_len_b <= 0;
	rd_start_b <= 1'b0;
	dec_state_b <= DEC_IDLE_B;
	m2_write <= 1'b0;
	//rd_start_b = 1'b0;
	//state_mem = IDLE_MEM;
end

else 
begin

case (dec_state_b)

DEC_IDLE_B: begin

	n_ddr3b_done <= 1'b0;
	ddr3b_mem_wr_addr <= 0;
	rd_start_b <= 1'b0;
	m2_write <= 1'b0;

	if(xcvr_mode)
		data_len_b <= cntrl_reg[31:4];
		else
		data_len_b <= cntrl_reg[31:5];
	
//if(capture_start & (!capture_done) & !empty_b & !mem_avm_m2_waitrequest & !xcvr_mode)	
if(capture_start && (!capture_done) && !xcvr_mode)
	begin
	//rd_start_b <= 1'b1;
	dec_state_b <= DEC_STREAM_B;
	
	//ddr3b_mem_wr_addr <= ddr3b_mem_wr_addr + 1'b1;
	end
end


DEC_STREAM_B: begin	
	
	if (!mem_avm_m2_waitrequest)
	m2_write <= en_ddr3b;
	
	if(ddr3b_mem_wr_addr >= data_len_b-1)
	begin
		if (mem_avm_m2_write)
		begin
			n_ddr3b_done <= 1'b1;
			rd_start_b <= 1'b0;
		end
	end	
	else
	begin
		rd_start_b <= 1'b1;
		if (mem_avm_m2_write)
		ddr3b_mem_wr_addr <= ddr3b_mem_wr_addr + 1'b1;		
    end
	
 
	if (capture_done)
	begin
		dec_state_b <= DEC_IDLE_B;
		n_ddr3b_done <= 1'b0;
	end
	end
endcase

end
end

  
dec_fifo	dec_fifo_inst (
	//.clock ( clk ),
	.data ( avst_data [M*SAMPLES_PER_CLK*8-1:0]),
	.wrclk(clk),
	.rdclk(clk_mem),
	.rdreq ( !mem_avm_m1_waitrequest & en_ddr3a),
	//.rdreq (n_ddr3a_wr_en),
	.rdempty(empty_a),
	.wrusedw(wrusedw_a),
	//.wrreq ( mem_wr_en & !capture_done),
	//.wrreq ( !n_ddr3_stop & avst_valid),
	.wrreq (avst_valid & n_mem_wr_en & !xcvr_mode),
	.aclr	(flush_fifo_dly),
	.q ( mem_avm_m1_writedata_a )
	);

dec_fifo	dec_fifo_inst1 (
	//.clock ( clk ),
	.data ( avst_data [M*SAMPLES_PER_CLK*16-1:M*SAMPLES_PER_CLK*8]),
	.wrclk(clk),
	.rdclk(clk_mem),
	.rdreq ( !mem_avm_m2_waitrequest & en_ddr3b),
	//.rdreq (n_ddr3b_wr_en),
	.rdempty(empty_b),
	//.rdusedw(rdusedw_b),
	.wrusedw(wrusedw_b),
	//.wrreq ( mem_wr_en & !capture_done),
	//.wrreq ( !n_ddr3_stop & avst_valid),
	.wrreq ( avst_valid & n_mem_wr_en & !xcvr_mode),
	.aclr	(flush_fifo_dly),
	.q ( mem_avm_m2_writedata )
	);
	
	

dec_fifo_b	dec_fifo_inst2 (
	//.clock ( clk ),
	.data ( avst_data ),
	.wrclk(clk),
	.rdclk(clk_mem),
	.rdreq ( !mem_avm_m1_waitrequest & xcvr_mode & en_ddr3a),
	//.rdreq (n_ddr3a_wr_en),
	.rdempty(empty_c),
	.wrusedw(wrusedw_c),
	//.wrreq ( mem_wr_en & !capture_done),
	//.wrreq ( !n_ddr3_stop & avst_valid),
	.wrreq (avst_valid & n_mem_wr_en & xcvr_mode),
	.aclr	(flush_fifo_dly),
	.q ( mem_avm_m1_writedata_b )
	);	



	assign en_ddr3a = !xcvr_mode ? !empty_a : !empty_c;
	assign en_ddr3b = !xcvr_mode ? !empty_b : 1'b0;
	
	//assign mem_en_a = rd_start_a ? en_ddr3a : 1'b0;
	//assign mem_en_b = rd_start_b ? en_ddr3b : 1'b0;
	
	assign mem_avm_m1_writedata = !xcvr_mode ? mem_avm_m1_writedata_a : mem_avm_m1_writedata_b;
	
	//assign en_ddr3a = (wrusedw_a[7:3] > 0)? 1'b1:1'b0;
	//assign en_ddr3b = (wrusedw_b[7:3] > 0)? 1'b1:1'b0;

	//assign data_len = xcvr_mode ? capture_data_len : capture_data_len/2;

assign avst_ready = 1'b1;
//assign avmm_waitrequest = 1'b0;

//control register assignment
//assign capture_data_len = cntrl_reg[31:4];
assign capture_start    = cntrl_reg[0];
assign capture_done     = cntrl_reg[1]; //status
assign xcvr_mode     = cntrl_reg[3];
assign prbs_checker     = 1'b0;

//assign prbs_checker     = cntrl_reg[3]; //prbs_checker


function integer log2;
   input integer x;
   begin
     x = x - 1;
     for (log2 = 0; x > 0; log2 = log2 + 1)
       x = x / 2;
   end
 endfunction
 
 
 
 

endmodule

