module mod_IQ_dec_filter_w_1strm_parameterized2 #(
parameter num_accumulator_bits=16, 
parameter num_data_bits=8, 
parameter clk_count_num_bits=8,
parameter shift_num_bits = 8)(
						out_data_Io,
						out_data_Ie,
						out_data_Qo,
						out_data_Qe,
						out_clk,
						out_clk_non_global,
						in_data_Ie,
						in_data_Io,
						in_data_Qe,
						in_data_Qo,
						in_clk,
						clk_count,
						Reset,
						shift,
						single_strm_clk,
						single_strm_I,
						single_strm_Q,
						out_data_Ie_full,
						out_data_Io_full,
						out_data_Qe_full,
						out_data_Qo_full, 
						single_strm_I_full, 
						single_strm_Q_full);

localparam sign_extension_bits = num_accumulator_bits-num_data_bits;
// input and output ports - start
output	[num_data_bits-1:0]	out_data_Ie,out_data_Io,out_data_Qe,out_data_Qo, single_strm_I, single_strm_Q;
output	[num_accumulator_bits-1:0]	out_data_Ie_full,out_data_Io_full,out_data_Qe_full,out_data_Qo_full, single_strm_I_full, single_strm_Q_full;
output			out_clk,out_clk_non_global,single_strm_clk;
input [clk_count_num_bits-1:0] clk_count;
input [shift_num_bits-1:0] shift;
input	[num_data_bits-1:0]	in_data_Ie,in_data_Io,in_data_Qe,in_data_Qo;
input			in_clk,Reset;
// input and output ports - end 

wire[num_accumulator_bits-1:0] current_I_1strm_sample, current_Q_1strm_sample;
wire current_sample_is_even;


reg 	[num_accumulator_bits-1:0]	sumreg1_out,sumreg2_out,sumreg3_out,sumreg4_out,mux1_reg,mux2_reg,mux3_reg,mux4_reg,
			    c_out_data1,c_out_data1_temp,c_out_data2,c_out_data2_temp,c_out_data3,c_out_data3_temp,
				 c_out_data4,c_out_data4_temp, single_strm_I_reg, single_strm_Q_reg; 
reg		[clk_count_num_bits-1:0]	down_count_reg,down_count2_reg;
reg				tiqc_reg_temp,tiqc_reg2_temp,tiqc_reg,tiqc2_reg /*synthesis syn_noclockbuf=1*/ ;
reg				out_clk1_late,out_clk2_late;
reg 		    out_clk /* synthesis syn_preserve = 1 */;
reg 		    out_clk_non_global /* synthesis syn_preserve = 1 */;


wire	[num_accumulator_bits-1:0]	mux1_out,mux2_out,mux3_out,mux4_out,sum1_out,sum2_out,sum3_out,sum4_out;
wire	[num_data_bits-1:0]	single_strm_I, single_strm_Q, in_data_Ie,in_data_Io,in_data_Qe,in_data_Qo,out_data_Ie,out_data_Io,out_data_Qe,out_data_Qo;
wire			in_clk,Reset;
wire			out_clk1_early,out_clk2_early;
wire			mux_ctl1,mux_ctl2,div_m_clk;
reg [num_accumulator_bits-1:0]      delay_out_data2, delay_out_data4;

reg			    reset_capture,reset_sync1,reset_sync2,reset_sync3,reset_negedge_sync;
wire 			clr_reset_capture;
wire			actual_reset_signal;
wire			actual_negedge_reset_signal;



assign out_data_Io = c_out_data1[shift+num_data_bits-1 -: num_data_bits];
assign out_data_Ie = c_out_data2[shift+num_data_bits-1 -: num_data_bits];
assign out_data_Qo = c_out_data3[shift+num_data_bits-1 -: num_data_bits];
assign out_data_Qe = c_out_data4[shift+num_data_bits-1 -: num_data_bits];

assign single_strm_clk = !div_m_clk;

assign single_strm_I = single_strm_I_reg[shift+num_data_bits-1 -: num_data_bits];
assign single_strm_Q = single_strm_Q_reg[shift+num_data_bits-1 -: num_data_bits];

assign out_data_Ie_full   = c_out_data2;
assign out_data_Io_full   = c_out_data1;
assign out_data_Qe_full   = c_out_data4;
assign out_data_Qo_full   = c_out_data3;
assign single_strm_I_full = single_strm_I_reg;
assign single_strm_Q_full = single_strm_Q_reg;

// We need to create a 1/2 duty cycle clock for the div_m_clock
//   so we made a new down_couter
assign div_m_clk = ~tiqc2_reg;


assign mux_ctl1 = out_clk1_early && ~out_clk1_late;
assign mux_ctl2 = out_clk2_early && ~out_clk2_late;


wire[num_accumulator_bits-1:0] sign_extended_Ie, sign_extended_Qe,sum1_out_old,sum2_out_old,sum3_out_old,sum4_out_old;
wire[num_accumulator_bits-1:0] sum1_out_new,sum2_out_new,sum3_out_new,sum4_out_new;

assign sign_extended_Ie = {{sign_extension_bits{in_data_Ie[num_data_bits-1]}},in_data_Ie[num_data_bits-1:0]};
assign sign_extended_Qe = {{sign_extension_bits{in_data_Qe[num_data_bits-1]}},in_data_Qe[num_data_bits-1:0]};


// Remove commenting of following for simulation
assign sum1_out_old = sign_extended_Ie + sumreg1_out;
assign sum2_out_old = sign_extended_Ie + sumreg2_out;
assign sum3_out_old = sign_extended_Qe + sumreg3_out;
assign sum4_out_old = sign_extended_Qe + sumreg4_out;

assign sum1_out_new = sign_extended_Ie;
assign sum2_out_new = sign_extended_Ie;
assign sum3_out_new = sign_extended_Qe;
assign sum4_out_new = sign_extended_Qe;

assign sum1_out = mux_ctl1 ? sum1_out_new : sum1_out_old;
assign sum2_out = mux_ctl2 ? sum2_out_new : sum2_out_old;
assign sum3_out = mux_ctl1 ? sum3_out_new : sum3_out_old;
assign sum4_out = mux_ctl2 ? sum4_out_new : sum4_out_old;

//  The following section contains the Down Counter and CLOCKS creation
//	We use duble buffering so that there will be no glitch, when the counter
///	is changing from 0000,0010 -> 0000,0001 there can be a split moment that the 
//	counter changes to 0000,0000 and TC_reg will be activated.

assign out_clk1_early = tiqc_reg;
assign out_clk2_early = ~tiqc_reg;

always @(negedge in_clk or negedge actual_reset_signal)
		if (!actual_reset_signal) begin
			down_count_reg 	<= 0;
			tiqc_reg 			<= 1'h0;
			tiqc_reg_temp		<= 1'h0;  
			out_clk1_late	<= 1'h0;
			out_clk2_late	<= 1'h0;
		end else begin 
			if (down_count_reg != 0) begin 				// Down Counter
				down_count_reg <= down_count_reg - 1;	 
				if (down_count_reg == 1)
					tiqc_reg_temp <= !tiqc_reg_temp;
			end else begin
				down_count_reg <= clk_count;
			end
			tiqc_reg <= tiqc_reg_temp;

			out_clk1_late <= tiqc_reg;
			out_clk2_late <= ~tiqc_reg;
	
		end



/* Create out_data1 register clock enable */
always @(posedge in_clk or negedge actual_negedge_reset_signal)
	if (!actual_negedge_reset_signal) begin
		down_count2_reg 	<= 0;
		tiqc_reg2_temp		<= 1'h0;  
		tiqc2_reg			<= 1'h0;
		sumreg1_out 	<= 0;
		sumreg2_out		<= 0;
		sumreg3_out 	<= 0;
		sumreg4_out		<= 0;

	end	else begin

		if (down_count2_reg != 0) begin 				// Down Counter
			down_count2_reg <= down_count2_reg - 1;	 
			if (down_count2_reg == 1)
				tiqc_reg2_temp <= !tiqc_reg2_temp;
		end else begin
			down_count2_reg <= (clk_count >> 1);
		end
		/* This is here so that the div_M_clock is created on the posedge */

		if (clk_count==1) 
		begin
		    tiqc2_reg <= ~tiqc2_reg;
		end else
		begin
			tiqc2_reg <= tiqc_reg2_temp;
		end
 		//	This small section does not belong to the clock creation, but to the
		//	Sum_Register's
		sumreg1_out <= sum1_out;
		sumreg2_out <= sum2_out;
		sumreg3_out <= sum3_out;
		sumreg4_out <= sum4_out;

	end

/* ------------------------------------------------------------------------- */

always @(posedge mux_ctl1 or negedge actual_reset_signal)
	begin
		if (!actual_reset_signal)
		begin
			mux1_reg <= 0;
			mux3_reg <= 0;
	    end else
		begin
			mux1_reg <= sumreg1_out;
		    mux3_reg <= sumreg3_out;
		end
	end

always @(posedge mux_ctl2 or negedge actual_reset_signal)
	begin
		if (!actual_reset_signal)
		begin
			mux2_reg <= 0;
			mux4_reg <= 0;
		end else
		begin
			mux2_reg <= sumreg2_out;
			mux4_reg <= sumreg4_out;
		end
	end

/* ------------------------------------------------------------------------- */

/* Latch the Data coming from the Mux so that we can send the 
   data out according to the div_m_clk. The data from MUX_OUT_DATA is stable 
   on the nededge of the IN_CLOCK so that when the div_m_clock comes around the
   mux1_reg/mux2_reg is 100% stable */

always @(posedge div_m_clk or negedge actual_negedge_reset_signal)
	begin
		if (!actual_negedge_reset_signal)
        begin
			delay_out_data2 <= 0;
			delay_out_data4 <= 0;
		end else begin
			delay_out_data2 <= mux2_reg;
			delay_out_data4 <= mux4_reg;
		end
	end

assign current_sample_is_even = out_clk1_late;

assign current_I_1strm_sample = current_sample_is_even ? mux1_reg : mux2_reg;

assign current_Q_1strm_sample = current_sample_is_even ? mux3_reg : mux4_reg;




always @(negedge div_m_clk or negedge actual_negedge_reset_signal)
	begin
		if (!actual_negedge_reset_signal) begin
						
			single_strm_I_reg <= 0;
			single_strm_Q_reg <= 0;

		end else begin
				
			single_strm_I_reg <=current_I_1strm_sample;
			single_strm_Q_reg <=current_Q_1strm_sample;
		end
end

always @(posedge div_m_clk or negedge actual_negedge_reset_signal)
	begin
		if (!actual_negedge_reset_signal) begin
			c_out_data1_temp <= 0;
			c_out_data2_temp <= 0;
			c_out_data3_temp <= 0;
			c_out_data4_temp <= 0;
		end else begin
			c_out_data1_temp <= mux1_reg;
			c_out_data2_temp <= delay_out_data2;
			c_out_data3_temp <= mux3_reg;
			c_out_data4_temp <= delay_out_data4;
		end
	end

always @(negedge div_m_clk or negedge actual_negedge_reset_signal)
    begin
    	if (!actual_negedge_reset_signal) begin
    		out_clk <= 0;
			out_clk_non_global <= 0;
		end else
	    begin
	    	out_clk <= !out_clk;
			out_clk_non_global <= !out_clk;
	    end
	end

always @(posedge out_clk or negedge actual_negedge_reset_signal)
    begin
    	if (!actual_negedge_reset_signal) begin
  	 	    c_out_data1 <= 0;
			c_out_data2 <= 0;
			c_out_data3 <= 0;
			c_out_data4 <= 0;
	    end else
	    begin
	        c_out_data1 <= c_out_data1_temp;
			c_out_data2 <= c_out_data2_temp;
			c_out_data3 <= c_out_data3_temp;
			c_out_data4 <= c_out_data4_temp;
	    end
	end

//--------------------------------------------------------------------------------------------------
// Reset Signal Generation

always @(negedge Reset or posedge clr_reset_capture)
begin
	 if (clr_reset_capture)
	 begin
      	 reset_capture <= 1'b0;
	 end else
	 begin
	 	 reset_capture <= 1'b1;
	 end
end



always @(posedge in_clk or posedge clr_reset_capture)
begin
	 if (clr_reset_capture)
	 begin
	 	  reset_sync1 <= 1'b0;
	 end else
	 begin
	 	  reset_sync1 <= reset_capture;
	 end

end



always @(posedge in_clk)
begin
	 reset_sync2 <= reset_sync1;
	 reset_sync3 <= reset_sync2;
end

always @(negedge in_clk)
begin
	 reset_negedge_sync	<= reset_sync3;
end

assign clr_reset_capture = reset_sync3;
assign actual_reset_signal = !reset_sync3;
assign actual_negedge_reset_signal = !reset_negedge_sync;



endmodule

