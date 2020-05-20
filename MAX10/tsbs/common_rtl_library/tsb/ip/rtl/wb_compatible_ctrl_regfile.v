module wb_compatible_ctrl_regfile
#(
parameter num_address_bits = 8,
parameter NUM_OF_CTRL_REGS = 2**num_address_bits,
parameter DATA_WIDTH = 32
)
(
   wb_clk_i, 
	wb_rst_i, 
	wb_adr_i, 
	wb_dat_i, 
	wb_dat_o,
	wb_we_i, 
	wb_stb_i, 
	wb_cyc_i, 
	wb_ack_o, 
	wb_inta_o,
	CTRL  
);

	// wishbone signals
	input        wb_clk_i;                        // master clock input
	input        wb_rst_i;                        // synchronous active high reset
	input  [num_address_bits-1:0] wb_adr_i;       // lower address bits
	input  [DATA_WIDTH-1:0] wb_dat_i;                       // databus input
	input        wb_we_i;                        // write enable input
	input        wb_stb_i;                       // stobe/core select signal
	input        wb_cyc_i;                       // valid bus cycle input
	output  reg     wb_ack_o;                       // bus cycle acknowledge output
	output       wb_inta_o;                      // interrupt request signal output
	output  reg [DATA_WIDTH-1:0] wb_dat_o;                       // databus output
    output  wire [DATA_WIDTH-1:0]                CTRL [NUM_OF_CTRL_REGS-1:0];

	assign wb_inta_o = 0;
  
	// generate wishbone signals
	wire wb_wacc = wb_cyc_i & wb_stb_i & wb_we_i;

	// generate acknowledge output signal
	always @(posedge wb_clk_i)
	begin
	  wb_ack_o <= #1 wb_cyc_i & wb_stb_i & ~wb_ack_o; // because timing is always honored
    end
	
	// assign DAT_O
	always @(posedge wb_clk_i)
	begin
	     wb_dat_o <= CTRL[wb_adr_i];
	end	
	
	// generate registers
	always @(posedge wb_clk_i)
	begin
	   if (wb_rst_i)
	    begin
	        for (int i = 0; i < NUM_OF_CTRL_REGS; i++)
			begin
	             CTRL[i] <= 0;
			end
	    end
	  else
	  begin
	      if (wb_wacc)
		  begin
	      	         CTRL[wb_adr_i] <= #1 wb_dat_i;
		  end
	  end 
	end
endmodule