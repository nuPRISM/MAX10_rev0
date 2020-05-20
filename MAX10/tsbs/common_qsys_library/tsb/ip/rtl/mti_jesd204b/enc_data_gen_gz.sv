
//Author: Ebenezer Dwobeng :ebenezer-d@ti.com

module enc_data_gen_gz #(parameter M=2, S=1, SAMPLES_PER_CLK=1,RD_ADDR_WIDTH = 15, PRBS_L=16, PRBS_M=9,PRBS_N=5
		      )
   (

    input  wire                  clk, 
	input  wire                  rstn,
	input  wire                  clk_mem,
	input  wire                  rstn_mem,
	input  wire                  rstn_100,
	input wire 						clk_100,
    // Avalon Streaming Sink Interface
    // Ready Latency = 0
   
    output  				    avst_valid,
    output reg [M*16*SAMPLES_PER_CLK*S-1:0] avst_data,
   
    input wire 				    avst_ready,

    // Avalon Memory Mapped Slave Interface
	 input wire [3:0]			wbyteenable,
    input wire 				    avmm_write_en,
    input wire 				    avmm_read_en,
    input wire [15:0] 			    avmm_addr,
    input wire [31:0] 			    avmm_datain,

    //output reg 				    avmm_rddata_valid,
    //output  wire                avmm_waitrequest,
    output reg [31:0] 			    avmm_dataout,

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
	
	
    output reg 				    scope_trig,
	 
	 input wire						tx_ready,
	 
	 input wire	[1:0]				jesd_tx_M
   

    );

	 
	 
   //import jesdcon_pkg::*; //get the log2 function
//`define ENC_CONTROL_REG_ADDR  16'h200
`define ENC_CONTROL_REG_ADDR  16'h8000
   localparam RD_DATA_WIDTH = 16*M*SAMPLES_PER_CLK*S;
   localparam RD_MEM_DEPTH = 2<<RD_ADDR_WIDTH;
	localparam BURST_LENGTH = 8;

   localparam IDLE = 2'b00,
     AVST_READY = 2'b01,
	  IDLE_A = 2'b00,
     IDLE_B= 2'b00,
     STREAM_A = 2'b01,
     STREAM_B = 2'b01;
   

	wire					avst_ready_eb;
   reg [27:0] 				    read_data_len,n_read_data_len;
	reg [27:0]			 data_len;
   reg 				    read_start;   
   reg 				    read_loop;    
   reg 				    read_stop ;
   wire 				    prbs_gen;
	reg	  				 xcvr_mode;

   reg [15:0] 				    mem_wr_addr , n_mem_wr_addr;
   reg [255:0] 				    mem_wr_data , n_mem_wr_data;
   reg 					    mem_wr_en   , n_mem_wr_en;
   reg [RD_ADDR_WIDTH-1:0] 		    mem_rd_addr , n_mem_rd_addr;
   reg [RD_DATA_WIDTH-1:0] 		    mem_rd_data,mem_rd_data_l,mem_rd_data_a,mem_rd_data_b;
      reg [RD_DATA_WIDTH-1:0] 		    mem_rd_data_dly;


   reg [M*16*SAMPLES_PER_CLK*S-1:0] 	    n_avst_data;
   reg 					    n_avst_valid;

   reg [31:0] 				    cntrl_reg , n_cntrl_reg;
   reg 					    n_avmm_rddata_valid;
   reg [31:0] 				    n_avmm_dataout,n_avmm_datain;

   reg 					    mem_rd_valid, n_mem_rd_valid;

   reg 					    n_clear_cntrl_reg, clear_cntrl_reg;
   reg [1:0] 				    state, n_state, stateA, stateB;

   reg 					    n_avmm_waitrequest;
   reg 					    mem_rd_valid_d1;
   
   wire [M-1:0] [15:0] 			    PRBS;
   wire [M*16-1:0] 			    PRBS_data;

   reg [3:0] [RD_DATA_WIDTH-1:0] 	    fifo;
	wire								aempty_a, aempty_b;
  

   reg 					    n_scope_trig;
   reg [2:0] wr_addr, n_wr_addr, rd_addr , n_rd_addr;
   reg [3:0] [RD_DATA_WIDTH-1:0] mem_rd_data_str, n_mem_rd_data_str;
    
//added signals -- Eben
	wire									full_a, full;
	reg									rd_en_a, n_rd_en_a, rd_en_b, n_rd_en_b, prefetch_done, n_prefetch_done, str_start, prefetch_start, n_prefetch_start;
	reg	[RD_ADDR_WIDTH-1:0]		ddr3a_rd_addr, n_ddr3a_rd_addr,ddr3b_rd_addr, n_ddr3b_rd_addr;
	reg [M*16*SAMPLES_PER_CLK*S-1:0] 	mem_avm_m0_readdata_r, mem_avm_m0_readdata_r1;
	reg									flush_fifo, n_flush_fifo,flush_fifo_dly,n_flush_fifo_dly;
	reg						mem_avm_m1_readdatavalid_dly, mem_avm_m2_readdatavalid_dly;
	reg								ddr3_stop, n_ddr3_stop;
	
	reg	[2:0]						burst_del_cnt;
	reg 	[15:0]					addr_cnt, n_addr_cnt;
	reg								afull_r;
	reg								avst_ready_r;
	
	wire						 mem_avm_m0_read;
	wire						 mem_avm_m0_waitrequest;
	wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m0_readdata;
	wire						 mem_avm_m0_write;
	wire	[M*SAMPLES_PER_CLK*16-1:0]			 mem_avm_m0_writedata;
	wire						 mem_avm_m0_readdatavalid;
	wire	[31:0]			 mem_avm_m0_address;	
	wire	[3:0]			 mem_avm_m0_burstcount;
	
	reg [M*SAMPLES_PER_CLK*16-1:0]		mem_avm_m1_readdata_dly, mem_avm_m2_readdata_dly;
	reg						mem_avm_m0_waitrequest_dly;
	
	wire [10:0]				usedw_a, usedw_b, usedw_c;
	
	reg n_stop_a, n_stop_b;
	
	reg[3:0]					shift_rd_valid;
	reg						mem_rd_start;
	reg						flush_fifo_a,flush_fifo_b,flush_fifo_c;
	reg          count_update,count_update_a,count_update_b;

		
		assign mem_avm_m1_write = 1'b0;
		assign mem_avm_m2_write = 1'b0;
		
		  assign avst_ready_eb = tx_ready;
		  

	enc_fifo	enc_fifo_inst (
	//.clock ( clk ),	
	.data ( mem_avm_m1_readdata),
	.wrclk(clk_mem),
	.rdclk(clk),	
	.rdreq (avst_ready_r && mem_rd_valid),	
	.wrreq ( mem_avm_m1_readdatavalid),
	//.full(full_a),
	.rdempty(empty_a),
	.wrusedw(usedw_a),
	//.sclr (flush_fifo_dly || scope_trig),
	.aclr (flush_fifo_a),
	.q ( mem_rd_data_a [M*SAMPLES_PER_CLK*8-1:0])
	);
	
	
	enc_fifo	enc_fifo_inst1 (
	//.clock ( clk ),
	.data ( mem_avm_m2_readdata),
	.wrclk(clk_mem),
	.rdclk(clk),
	.rdreq (avst_ready_r && mem_rd_valid),	
	.wrreq ( mem_avm_m2_readdatavalid),
	//.full(full_b),
	.rdempty(empty_b),
	.wrusedw(usedw_b),
	//.sclr (flush_fifo_dly || scope_trig),
	.aclr (flush_fifo_b),	
	.q ( mem_rd_data_a [M*SAMPLES_PER_CLK*16-1:M*SAMPLES_PER_CLK*8] )
	);
	
	
	enc_fifo_b	enc_fifo_inst2 (
	//.clock ( clk ),
	.data ( mem_avm_m2_readdata),
	.wrclk(clk_mem),
	.rdclk(clk),
	//.rdreq ( !(mem_rd_addr < 4096-1) & avst_ready),
	.rdreq (avst_ready_r && mem_rd_valid),
	.wrreq ( mem_avm_m2_readdatavalid),
	//.full(full_b),
	.rdempty(empty_c),
	.wrusedw(usedw_c),
	//.sclr (flush_fifo_dly || scope_trig),
	.aclr (flush_fifo_b),
	.q ( mem_rd_data_b )
	);
	
	
	
	
	always @ (posedge clk_100 or negedge rstn_100)
	begin
	
	if (!rstn_100)
	begin
	cntrl_reg = 0;
	read_start = 1'b0;
	read_loop =1'b0;
	read_stop = 1'b0;
	xcvr_mode = 1'b0;
	//avmm_rddata_valid = 0;
	avmm_dataout = 0;
	end
	
	else
	begin
	if(avmm_write_en)
	begin
		if(avmm_addr == `ENC_CONTROL_REG_ADDR)
		begin
		cntrl_reg = avmm_datain; //control register
		       end
	end
		
		 if(avmm_read_en)
	       begin
			 if(avmm_addr == `ENC_CONTROL_REG_ADDR)
			 begin
		  //avmm_rddata_valid  = 1'b1;
		  avmm_dataout       = 32'hDEADBEBE; //expecting read data from AV_ST interface
	       end			
			 end
			//else
			//avmm_rddata_valid  = 1'b0;
	
		//read_start    = cntrl_reg[0];
		read_loop     = cntrl_reg[1];
		read_stop     = cntrl_reg[2];
		xcvr_mode      = cntrl_reg[3];
	
	if (count_update)
	begin
		read_data_len = cntrl_reg[31:4];
		//mem_rd_start = 1'b1;
		read_start = cntrl_reg[0];
		if(xcvr_mode)
		data_len = cntrl_reg[31:4];
		else
		data_len = cntrl_reg[31:5];	

	end	
	
	end	
	end
		
	always @ (posedge clk or negedge rstn)
	begin
	if(!rstn)
	begin
      //read data from the memory
      //clear_cntrl_reg <= 1'b0;
      state <= IDLE;
      mem_rd_addr <= 0; //clk		
      mem_rd_valid <= 1'b0; //clk
      scope_trig   <= 1'b0;    //clk
		flush_fifo_dly <= 1'b0;
		avst_ready_r <= 1'b0;
		shift_rd_valid <= 4'b0000;
		count_update <= 1'b0;
		end
	
	else
	begin
	
	avst_ready_r <= avst_ready;
	
	shift_rd_valid <= {shift_rd_valid[2:0],mem_rd_valid};
      case(state)
	IDLE:
	
	  begin
		if (count_update_a && count_update_b)
		count_update <= 1'b1;
		
		flush_fifo_dly <= 1'b0;
		mem_rd_valid  <= 1'b0;
		scope_trig <= 1'b0;
		mem_rd_addr <= 0;

				
		  if(read_start && !read_stop && avst_ready_eb)//do not read from memory until link has been established
	       begin
			 
									
									if(xcvr_mode ? !aempty_b : !aempty_a && !aempty_b)
									begin
									state <= AVST_READY;
									count_update <=1'b0;
									end
	 end
	 end

	  
	AVST_READY:
	  begin
	       if (avst_ready_eb) 
	          begin
				 
				 if (xcvr_mode)
	          avst_data <= mem_rd_data_b;
				 else
				 avst_data <= mem_rd_data_a;
				 
		  if(mem_rd_addr >= (read_data_len-1) && avst_ready_r)
		    begin
				
				 mem_rd_valid <= 1'b1;
				 mem_rd_addr <= 0;
		       scope_trig <= 1'b1;
				 
				 end
				 
				 else if (avst_ready_r && (xcvr_mode ? !empty_c : !empty_a && !empty_b))
				 begin
				 mem_rd_valid <= 1'b1;				 
				 if(shift_rd_valid[1])
				 begin
				 scope_trig <= 1'b0;				  
		        mem_rd_addr <= mem_rd_addr + 1'b1;
				  end
				end
			
				if(!read_loop || read_stop)
	    		 begin
	    		    state <= IDLE;
	    		 end
		    end	          
  	 end
	 
	 
	default:
	  begin
	     state <= IDLE;
	  end
      endcase
		
		end
   end


always @ (posedge clk_mem or negedge rstn_mem)
	
	   begin
	if(!rstn_mem)
	  begin	     		 
	
				ddr3a_rd_addr <= {RD_ADDR_WIDTH{1'b0}};
				//ddr3a_rd_addr_dly <= {RD_ADDR_WIDTH{1'b0}};
				n_rd_en_a	<= 1'b0;		
				flush_fifo_a <= 1'b0;
				count_update_a <=1'b0;
				stateA <= IDLE_A;
			//	rd_start_a <=1'b0;
				 
	  end
	  else
	  begin
	  
	 // ddr3a_rd_addr_dly = ddr3a_rd_addr;
		 
		 case (stateA)
		   
		IDLE_A: begin
		     
		count_update_a <= 1'b1;
		n_rd_en_a <= 1'b0;
		//rd_start_a <=1'b0;
		ddr3a_rd_addr <= 0;
		if (empty_a)
		flush_fifo_a <= 1'b0;
		else
		flush_fifo_a <= 1'b1;
		
		if (read_start && !read_stop && aempty_a && !xcvr_mode)
		  begin
		  n_rd_en_a <= 1'b1;
		  count_update_a <= 1'b0;
		  stateA <= STREAM_A;
		   end
		end
		
		 
		STREAM_A: begin
		
		
			
			if(mem_avm_m1_read)
			begin
			if(ddr3a_rd_addr >= data_len-BURST_LENGTH)
			begin
			  ddr3a_rd_addr <= 0;				
			end			
			else 
				  ddr3a_rd_addr <= ddr3a_rd_addr + BURST_LENGTH;				  
			end

		
		if(!read_loop || read_stop)
				stateA <= IDLE_A;
		end
		
		endcase
	end
	end	
		
				 
			

always @ (posedge clk_mem or negedge rstn_mem)
	
	   begin
	if(!rstn_mem)
	  begin	     		 
	
				ddr3b_rd_addr <= {RD_ADDR_WIDTH{1'b0}};
				//ddr3b_rd_addr_dly <= {RD_ADDR_WIDTH{1'b0}};
				n_rd_en_b	<= 1'b0;		
				flush_fifo_b <= 1'b0;				
				 count_update_b <=1'b0;
				 stateB <= IDLE_B;
				 //rd_start_b <=1'b0;
	  end
	  else
	  begin
	    
	     case (stateB)
		   
		IDLE_B: begin
		     
		count_update_b <= 1'b1;
		n_rd_en_b <= 1'b0;
		//rd_start_b <=1'b0;
		ddr3b_rd_addr <= 0;
		if (empty_b)
		flush_fifo_b <= 1'b0;
		else
		flush_fifo_b <= 1'b1;
		
		if (read_start && !read_stop && aempty_b)
		  begin
		  n_rd_en_b <= 1'b1;
		  count_update_b <= 1'b0;
		  stateB <= STREAM_B;
		   end
		end
		
		 
		STREAM_B: begin

			
			if(mem_avm_m2_read)
			begin
			if(ddr3b_rd_addr >= data_len-BURST_LENGTH)
			begin
			  ddr3b_rd_addr <= 0;				
			end			
			else 
				  ddr3b_rd_addr <= ddr3b_rd_addr + BURST_LENGTH;				  
			end
	
		
		if(!read_loop || read_stop)
				stateB <= IDLE_B;
		
		end
		
		endcase
	    end
	    end
	    

	
	
	
		  assign aempty_a = !usedw_a[10];
		  assign aempty_b = !xcvr_mode ? !usedw_b[10] : !usedw_c[7];
		  
	
		  
	  
	assign mem_avm_m1_address = ddr3a_rd_addr;
	assign mem_avm_m1_read = n_rd_en_a ? aempty_a & !mem_avm_m1_waitrequest : 1'b0;
	
	assign mem_avm_m2_address = ddr3b_rd_addr;
	assign mem_avm_m2_read = n_rd_en_b ? aempty_b & !mem_avm_m2_waitrequest : 1'b0;
	  assign mem_avm_m0_burstcount = BURST_LENGTH;
	  

	assign mem_avm_m1_burstcount =   mem_avm_m0_burstcount;
	
	assign mem_avm_m2_burstcount =   mem_avm_m0_burstcount;
	
	  
   //assign avmm_waitrequest = 1'b0;
   //control register assignment
  // assign read_data_len = cntrl_reg[31:4];
   //assign read_start    = cntrl_reg[0];
   //assign read_loop     = cntrl_reg[1];
   //assign read_stop     = cntrl_reg[2];
	//assign xcvr_mode      = cntrl_reg[3];
  // assign prbs_gen      = 1'b0; //if this is set then no need to set the read_data_len
   
   assign avst_valid = avst_ready_eb;
   function integer log2;
      input integer x;
      begin
	 x = x - 1;
	 for (log2 = 0; x > 0; log2 = log2 + 1)
	   x = x / 2;
      end
   endfunction

endmodule

