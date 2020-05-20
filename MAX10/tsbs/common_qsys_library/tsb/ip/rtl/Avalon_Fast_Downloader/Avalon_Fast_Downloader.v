//------------------------------------------------------------------------------
//Copyright (C) 1991-2007 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions
//and other software and tools, and its AMPP partner logic
//functions, and any output files from any of the foregoing
//(including device programming or simulation files), and any
//associated documentation or information are expressly subject
//to the terms and conditions of the Altera Program License
//Subscription Agreement, Altera MegaCore Function License
//Agreement, or other applicable license agreement, including,
//without limitation, that your use is for the sole purpose of
//programming logic devices manufactured by Altera and sold by
//Altera or its authorized distributors.  Please refer to the
//applicable agreement for further details.

//rev 1.00a
// 20-feb-2009  CJR registered the jtag_sunk_read and jtag_source _valid
//	 so only one two signals are going accross the clock boundary
//		( asside from the read and wrtie data and these have a lot of settle time.
// added the altera_std_syncronizer
//	added the phy so now everything is in this one file.




// synopsys translate_off
`timescale 1 ns / 1 ps
// synopsys translate_on
//////////////////////////////////////////////////////////////
//
// Here is the real code
//
//////////////////////////////////////////////////////////////

module Avalon_Fast_Downloader (
     output wire [31:0] avm_m1_address,
     output wire 	avm_m1_read,
     output wire 	avm_m1_write,
     output reg [7:0] 	avm_m1_writedata,
     input wire [7:0] 	avm_m1_readdata,
     input wire 	avm_m1_waitrequest,
     input 		clk,
     input 		reset_n
                       );


    // IR Values
    localparam 		LOOPBACK = 0;        // used to send the data back immediately
    localparam 		WRITE = 1;           // write data at the preloaded addres
    localparam 		READ = 2;            // read data at the preloaded address
    localparam 		ADDRESS = 3;         // load and read the 32 adress field
    localparam 		PRESET_ADDRESS = 4;  // load address with a predefined value for delay chain measurements.

    localparam 		IRWIDTH = 8;         // Instruction width -- right now I only need 3 bits so this could be reduced

    // JTAG Signals
    wire [IRWIDTH - 1 : 0] ir_out;
    wire [IRWIDTH - 1 : 0] ir_in;
    reg 		   tdo = 0;
    wire 		   tck;
    wire 		   tdi;
    wire 		   e1dr;
    wire 		   cdr;
    wire 		   sdr;

    // Sourcing Signals
    reg [2:0] 		   byte_index = 3'b0;
    // Sinking Signals
    reg [6:0] 		   data_in_transit = 7'h25;   // the first char read will be this one. however this is not criticle.
    reg [7:0] 		   next_data_in_transit = 8'b0;

    // Idle Signals
    reg [7:0] 		   writedata = 8'h4a;
    reg [7:0] 		   jtag_source_data_next;  // shift in register for write data.
    reg 		   jtag_source_valid = 1'b0;
    reg [7:0] 		   readdata;
    reg 		   jtag_sink_ready;
    reg 		   jtag_sink_ready_r;
    reg			   jtag_source_valid_r;
    reg 		   bytestream_started = 1'b0;

    reg [15:0]		   sdr_d;
    wire                   the_sdr;

    assign 		   ir_out = ir_in;
    
    always @ (posedge tck)
    begin
	sdr_d <= {sdr_d[14:0],sdr};
    end
       // this is a 16 to 1 mux
    	lpm_mux	the_lpm_mux_component (
				.sel (ir_in[7:4]),
				.data ({sdr_d[14:0],sdr}),
				.result (the_sdr)
				// synopsys translate_off
				,
				.aclr (),
				.clken (),
				.clock ()
				// synopsys translate_on
				);
	defparam
		the_lpm_mux_component.lpm_size = 16,
		the_lpm_mux_component.lpm_type = "LPM_MUX",
		the_lpm_mux_component.lpm_width = 1,
		the_lpm_mux_component.lpm_widths = 4;


     always @ (posedge tck)
    begin
    jtag_source_valid_r <= byte_index == 3'b001 && (sdr | e1dr);
    end // always @ (posedge tck) - bytestream_started


    // Sourcing   -- writing
    always @ (posedge tck)
    begin
	if (~bytestream_started && ( the_sdr &&(ir_in[3:0] !=IDLE)))      //fixed delay this now seems to work for all fpga family members.
	begin
	    bytestream_started <= 1'b1;
	end
	else if (bytestream_started && e1dr)
	begin
	    bytestream_started <= 1'b0;
	end
	     else
	     begin
		 bytestream_started <= bytestream_started;
	     end
    end // always @ (posedge tck) - bytestream_started

    always @(posedge tck)
    begin
	if(sdr && (ir_in[3:0] !=IDLE))
	begin
	    writedata <= { tdi, writedata[7:1] };
	end
	else
	begin
	    writedata <= writedata;
	end
    end // always @ (posedge tck) - writedata


    always @(posedge tck)
    begin
	if(~bytestream_started)
	begin
	    byte_index <= 3'b111; // Keep the counter from counting if byestream has not started.
	end
	else if(sdr && (ir_in[3:0] !=IDLE))
	begin
	    byte_index <= byte_index - 1'b1;     // otherwise decrement the byte_index
	end

    end // always @ (posedge tck) - source_byte_index


    // Sinking  Reading
    always @*
    begin
	jtag_sink_ready      = (byte_index == 3'b001) & sdr;
	if (jtag_sink_ready )
	   next_data_in_transit = (ir_in[3:0] == ADDRESS)?address_av[31:24]:readdata;
        else
	     next_data_in_transit = {1'b0, data_in_transit};
    end

    always @ (posedge tck)
    begin
    jtag_sink_ready_r <= (byte_index == 3'b000) & sdr;
    end // always @ (posedge tck) - bytestream_started


    // Sink Registers
    always @ (posedge tck)
    begin
	if (sdr && ( ir_in[3:0] == READ  || ir_in[3:0] == WRITE) || (ir_in[3:0] == ADDRESS))
	begin
	    {data_in_transit,tdo} <= next_data_in_transit;   // shift out the data.
	end
        else
        begin
		 tdo              <= tdi;            // all elses fails just pass the in to the out.
        end
    end

    // PHY Instantiation
	//sld_virtual_jtag  just instatiates sld_virtual_jtag_basic
        // I just called sld_virtual_jtag_basic to beginwith.


    	sld_virtual_jtag_basic	sld_virtual_jtag_component (
				.ir_out (ir_out),
				.tdo (tdo),
				.tdi (tdi),
				.tck (tck),
				.ir_in (ir_in),
				.virtual_state_cir (),
				.virtual_state_pdr (),
				.virtual_state_uir (),
				.virtual_state_sdr (sdr),      // we are shifting now
				.virtual_state_cdr (cdr),    // shifting into data register
				.virtual_state_udr (),
				.virtual_state_e1dr (e1dr),   // last bit into data register
				.virtual_state_e2dr ()
				// synopsys translate_off
				,
				.jtag_state_cdr (),
				.jtag_state_cir (),
				.jtag_state_e1dr (),
				.jtag_state_e1ir (),
				.jtag_state_e2dr (),
				.jtag_state_e2ir (),
				.jtag_state_pdr (),
				.jtag_state_pir (),
				.jtag_state_rti (),
				.jtag_state_sdr (),
				.jtag_state_sdrs (),
				.jtag_state_sir (),
				.jtag_state_sirs (),
				.jtag_state_tlr (),
				.jtag_state_udr (),
				.jtag_state_uir (),
				.tms ()
				// synopsys translate_on
				);
	defparam
	    sld_virtual_jtag_component.sld_mfg_id = 110,       // Altera
		sld_virtual_jtag_component.sld_type_id = 134,  // this is an offical resvered number for this component.
		sld_virtual_jtag_component.sld_version = 0,
		sld_virtual_jtag_component.sld_auto_instance_index = "YES",  // let quartus choose the instance number
		sld_virtual_jtag_component.sld_instance_index = 0,            // not used unless autoindex is NO
		sld_virtual_jtag_component.sld_ir_width = 8;   // instruction length is 8 however I am currntly not using all 8
//		sld_virtual_jtag_component.sld_sim_action = "((1,1,1,2),(1,2,12345678AABBCCDDEEFF112200000008,80),(1,1,2,2),(1,2,00000000000000000000000000000000008,88))",
//		sld_virtual_jtag_component.sld_sim_n_scan = 4,
//		sld_virtual_jtag_component.sld_sim_total_length = 268;


    ////************************ here is the avalon state machine  ********************
    // everything below here is based on the avalon clock.
    //*********************************************************************************

    reg [31:0] address_av;
    reg [3:0]  ir_in_av;
    reg        write_av;
    reg        read_av;
    wire        jtag_source_valid_av;
    wire        bytestream_started_av;
    reg [1:0]  byte_count;
    reg        jtag_source_valid_av_rr;
    reg        jtag_source_valid_av_r;
    wire       valid_rising;
    wire        jtag_sink_ready_av;
    reg        jtag_sink_ready_av_r;
    reg        jtag_sink_ready_av_rr;
    wire       ready_rising;
    wire       ready_falling;

    reg [2:0]  state;
    reg [2:0]  nextstate;
    // need to look at both the av and av_r signals to make sure it is not a glitch.
    assign     valid_rising = jtag_source_valid_av && jtag_source_valid_av_r && !jtag_source_valid_av_rr;
    assign     ready_rising = jtag_sink_ready_av   && jtag_sink_ready_av_r   && !jtag_sink_ready_av_rr;
    assign     ready_falling = !jtag_sink_ready_av   && !jtag_sink_ready_av_r   && jtag_sink_ready_av_rr;

    localparam [2:0] IDLE                    = 0,
		     ADDRESS_ST              = 1,
		     WRITE_ST                = 2,
		     WRITE_HOLD_ST           = 3,   // wait request is asserted.
		     READ_ST                 = 4,
		     READ_HOLD_ST            = 5,   // wait request is asserted.
		     PRESET_ADDRESS_ST       = 6;


    // register combinatorial nextstate to state
    always @(posedge clk or negedge reset_n)
    begin
	if ( !reset_n )
	state =#5  IDLE;
	else
	state =#5  nextstate;
    end


    always @(posedge clk or negedge reset_n)
    begin
	if ( !reset_n )
	begin
            write_av   <= 1'b0;
	    read_av    <= 1'b0;
	    address_av <= 32'h00000000;
	    byte_count <= 2'b0;
	end
	else
	begin

            case ( state )

		IDLE:
		begin
		    write_av   <= 1'b0;
		    read_av    <= 1'b0;
		    address_av <= address_av;
		    byte_count <= 2'b0;
		end

		ADDRESS_ST:
		begin
		    write_av <= 1'b0;
		    read_av  <= 1'b0;
		    if( valid_rising)
		    begin
			byte_count <= byte_count+1;
			address_av <= {address_av[30:0],writedata}; // piece the address together.
			// writedata (clocked by tck) has been valid and held for multiple "clk" cycles
			// assumption: clk must be faster than 20 MHz for this to work
		    end
		    else
		    begin
 			byte_count <= byte_count;
			address_av <= address_av; // piece the address together.
		    end
		end

		WRITE_ST:
		begin
		    write_av   <= valid_rising;
		    read_av    <= 1'b0;
		    address_av <= address_av;
		    byte_count <= 2'b0;
		end
		WRITE_HOLD_ST:
		begin
		    write_av   <= avm_m1_waitrequest;
		    read_av    <= 1'b0;
		    address_av <= avm_m1_waitrequest ? address_av: address_av+1;
		    byte_count <= 2'b0;
		end
		READ_ST:
		begin
		    write_av   <= 1'b0;
		    read_av    <= ready_falling; // ready rising
		    address_av <= address_av;
		    byte_count <= 2'b0;
		end
		READ_HOLD_ST:
		begin
		    write_av   <= 1'b0;
		    read_av    <= avm_m1_waitrequest;
		    address_av <= avm_m1_waitrequest? address_av: address_av+1;
		    byte_count <= 2'b0;
		end
		PRESET_ADDRESS_ST:     // this state is for preloading the address with a know quantity
		begin
		    write_av   <= 1'b0;
		    read_av    <= 1'b0;
		    address_av <= 32'h12345678;
		    byte_count <= 2'b0;
		end
		default:
		begin
		    write_av   <= 1'b0;
		    read_av    <= 1'b0;
		    address_av <= address_av;
		    byte_count <= 2'b0;
		end
	    endcase
	end
    end


    always @*
    begin

	nextstate = state;

	case ( state )

            IDLE:
            begin
		if( bytestream_started_av  && (ir_in_av == ADDRESS)) // first 4 bytes are the address
                nextstate = ADDRESS_ST;
		else  if ( bytestream_started_av  && (ir_in_av == READ))
                nextstate = READ_ST;
		      else  if ( bytestream_started_av  && (ir_in_av == WRITE))
                      nextstate = WRITE_ST;
			    else if (ir_in_av == PRESET_ADDRESS)
			    nextstate = PRESET_ADDRESS_ST;
			        else
			          nextstate = IDLE;
            end
            ADDRESS_ST:
            begin
		if(!bytestream_started_av )
		begin
		    nextstate = IDLE;
		end
		else
		nextstate = ADDRESS_ST;
            end
            WRITE_ST:
            begin
		if( valid_rising)
                nextstate = WRITE_HOLD_ST;
		else if ( !bytestream_started_av )
                nextstate = IDLE;
		     else
                     nextstate = WRITE_ST;
            end
            WRITE_HOLD_ST:
            begin
		if( !avm_m1_waitrequest)
                nextstate = WRITE_ST;
		else if ( !bytestream_started_av )
                nextstate = IDLE;
		     else
                     nextstate = WRITE_HOLD_ST;
            end

            READ_ST:
            begin
         if( ready_falling)        // not sure what this should be yet.
                nextstate = READ_HOLD_ST;
		else if ( !bytestream_started_av )
                nextstate = IDLE;
		     else
                     nextstate = READ_ST;

            end

            READ_HOLD_ST:
            begin
                if( !avm_m1_waitrequest)
                nextstate = READ_ST;
		else if ( !bytestream_started_av )
                nextstate = IDLE;
		     else
                     nextstate = READ_HOLD_ST;

            end


            default: nextstate = IDLE;
	endcase // case ( state )
    end // always @ (...

    always @(posedge clk or negedge reset_n) begin
	if ( !reset_n )
	begin
	    avm_m1_writedata <= 8'b00000000;
	end
	else  if( valid_rising)
	begin
	    avm_m1_writedata <= writedata;
	end
    end
    
    always @(posedge clk or negedge reset_n) begin
	if ( !reset_n )
	begin
	    readdata <= 8'b00000000;
	end
	else  if( avm_m1_read && !avm_m1_waitrequest)         // read case
	begin
	    readdata <= avm_m1_readdata;
	end
	else if( avm_m1_write )                              // write read back case
	begin
	     readdata <= avm_m1_writedata;
	end
	else
	begin                                                //default case
	     readdata <= readdata;
	end
    end


    always @(posedge clk or negedge reset_n) begin
	if ( !reset_n )
	begin
	    ir_in_av                <= 4'b0000;
	    jtag_source_valid_av_r  <= 1'b0;
	    jtag_source_valid_av_rr <= 1'b0;
	    jtag_sink_ready_av_r    <= 1'b0;
	    jtag_sink_ready_av_rr   <= 1'b0;
	end
	else
	begin
	    ir_in_av <= ir_in[3:0];
	    jtag_source_valid_av_r   <= jtag_source_valid_av;
	    jtag_source_valid_av_rr  <= jtag_source_valid_av_r;
	    jtag_sink_ready_av_r     <= jtag_sink_ready_av;
	    jtag_sink_ready_av_rr    <= jtag_sink_ready_av_r;

	end
    end
    // theses synchronize the data going between the clock domains
	altera_std_synchronizer sync1 (
				.clk (clk), 
				.reset_n (reset_n), 
				.din (jtag_source_valid_r), 
				.dout (jtag_source_valid_av)
				);
	altera_std_synchronizer sync2 (
				.clk (clk), 
				.reset_n (reset_n), 
				.din (jtag_sink_ready_r), 
				.dout (jtag_sink_ready_av)
				);
    altera_std_synchronizer sync3 (
				.clk (clk), 
				.reset_n (reset_n), 
				.din (bytestream_started), 
				.dout (bytestream_started_av)
				);


    assign avm_m1_read    = read_av;
    assign avm_m1_write   = write_av;
    assign avm_m1_address = address_av;
endmodule
