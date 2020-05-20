#*******************************************************************************
#                                                                              *
#                   Copyright (C) 2009 Altera Corporation                      *
#                                                                              *
#  ALTERA, ARRIA, CYCLONE, HARDCOPY, MAX, MEGACORE, NIOS, QUARTUS & STRATIX    *
#  are Reg. U.S. Pat. & Tm. Off. and Altera marks in and outside the U.S.      *
#                                                                              *
#  All information provided herein is provided on as �as is� basis, without    *
#  warranty of any kind.                                                       *
#                                                                              *
#  File Name: mk_avalon_state_machine_mastter.pl                               *
#                                                                              *
#  File Function: Script to generate Verilog Avalon master state machine       *
#                                                                              *
#  REVISION HISTORY:                                                           *
#   Revision 1.0    02/05/2011 - Initial Revision                              *
# ******************************************************************************

#!C:\altera\11.1\quartus\bin64\perl\bin\perl

# Create variables to get the arguments from the component instance in Qsys GUI
my $arg;				# Variable to stores the instance arguments
my $file;			# Variable to stores design file, fullpath
my $entityname;			# Variable to stores name given to component in system
my $avalon_commands;	# Variable to stores the Avalon transfer requests to be performed by the Avalon master (as a scalar)
my @avalon_commands;	# Variable to stores the Avalon transfer requests to be performed by the Avalon master (as an array)

# Loop to retrieve the arguments passed into the Perl script
foreach $arg (@ARGV) {
	if ($arg =~ /^file\s*=\s*(\S+)$/) {
		$file = $1;    
	} elsif ($arg =~ /^entityname\s*=\s*(\S+)$/) {
		$entityname = $1;
	} elsif ($arg =~ /^av_commands\s*=\s*(\S.+)$/) {
		$avalon_commands = $1;
	}
}

# Create variables used to build the Avalon state machine logic
my @verilog_state_machine;		# Array variable to store the next state HDL code
my $state_name_index = 0;		# Variable to store the number of states in state machine
my $state_name_prefix = "st_";	# Variable to store the prefix string for each state name 'st_'
my $state_default;				# Variable to store the reset string
my @state_name_list;			# Array variable to store state names
my $i;							# Variable used as index in generating the state names

# Convert scalar variable of Avalon transfer requests into an variable array of transfer requests
#    (Each transfer request is an element in the array)
@avalon_commands = split /;/, $avalon_commands;


# Start the state machine sequence with an idle state
&idle;

# Decode the Avalon transfer requests into actual state machine commands
foreach $_ (@avalon_commands) {
	
	# Is it a read command?
	if (/^\s*read\s+([0-9a-fA-F]{1,8})/i) {
		&read(uc($1));
	}
 
	# Is it a write command?
	if (/^\s*write\s+([0-9a-fA-F]{1,8})\s+(data|[0-9a-fA-F]{1,8})/i) {
		&write(uc($1), uc($2));
	}

	# Or an idle?
	if (/^\s*idle/i) {
		&idle;
	}
	
	# Is it a testword command?
	if (/^\s*testword\s+([0-9a-fA-F]{1,8})/i) {
		&testword(uc($1));
	}

	# Is it a testbit command?
	if (/^\s*testbit\s+(\d+)\s+([01])/i) {
		&testbit(uc($1), uc($2));
	}	
	
	# Is it a loop command?
	if (/^\s*loop\s+(\d{1,8})/i) {
		&loop($1);
	}
	
	# Is it an end command?
	if (/^\s*end/i) {
		&end;
	}	
	
}

# Generate the state names (as well as the default condition) using the index 
for ($i = 0; $i <= $state_name_index; $i++) {
	if($i == 0) {
		$state_default = sprintf "%s%d", $state_name_prefix, $i;
	}
	push @state_name_list, sprintf "%s%d", $state_name_prefix, $i; 
	if($i == $state_name_index) {
		push @state_name_list, sprintf " = %d;", $i; 
	}
	else {
		push @state_name_list, sprintf " = %d, ", $i; 
	}
}	
	
# Create the Verilog file.
open FILE_OUT, ">$file" or die "cannot create: $!";

# Write out the complete Verilog code.
print FILE_OUT "
/*******************************************************************************
 *                                                                             *
 *                  Copyright (C) 2011 Altera Corporation                      *
 *                                                                             *
 * ALTERA, ARRIA, CYCLONE, HARDCOPY, MAX, MEGACORE, NIOS, QUARTUS & STRATIX    *
 * are Reg. U.S. Pat. & Tm. Off. and Altera marks in and outside the U.S.      *
 *                                                                             *
 * All information provided herein is provided on an \"as is\" basis,            *
 * without warranty of any kind.                                               *
 *                                                                             *
 * Module Name: $entityname                                                       *
 * File Name:   $entityname.v                                                     *
 *                                                                             *
 * Module Function: This file contains an Avalon state machine master which    *
 *                  will create Avalon-MM bus transactions.                    *
 *                                                                             *
 * REVISION HISTORY:                                                           *
 *  Revision 1.0    02/28/2011 - Initial Revision                              *
 *  Revision 2.0    04/18/2011 - Added header                                  *
 ******************************************************************************/

module $entityname (
	input 				rst, clk,
	input 				am_waitreq,
	input [31:0] 		am_data_in,
	output reg [31:0] 	am_addr,
	output reg [31:0]	am_data_out,
	output reg			am_rd, am_wr
);

	reg [31:0]			data_reg;
	reg					data_reg_ena;
	
	reg [$state_name_index:0]	current_state, next_state;

	localparam		@state_name_list

	// Data register
	always @ (posedge clk, posedge rst)
	begin:  data_reg_proc
		if (rst)
			data_reg <= 32'h0;
		else begin
			if (data_reg_ena)
				data_reg <= am_data_in;
		end
	end // data_reg_proc	

	// State register transitions
	always @ (posedge clk, posedge rst)
	begin:  state_reg_proc
		if (rst)
			current_state <= $state_default;
		else
			current_state <= next_state;
	end // state_reg_proc
	
	// Next state logic
	always @ *
	begin:  next_state_proc
		am_addr <= 32'h0;
		am_wr <= 1'b0;
		am_rd <= 1'b0;
		am_data_out <= 32'h0;
		data_reg_ena <= 1'b0;
		
		case (current_state)
@verilog_state_machine			
						
			default :
						next_state <= $state_default;

		endcase	

	end
						
endmodule
";
close FILE_OUT;
select STDOUT;
exit (0);

# Sub-program to process the Avalon transfer write commands to write states in the state machine
sub write {
push @verilog_state_machine, sprintf "\n";
push @verilog_state_machine, sprintf "\t\t\t%s%d :\t// write %s, %s\n", $state_name_prefix, $state_name_index, $_[0], $_[1];
push @verilog_state_machine, sprintf "\t\t\t\t\tbegin\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\tam_addr <= 32'h%s;\n", $_[0];
push @verilog_state_machine, sprintf "\t\t\t\t\t\tam_wr <= 1'b1;\n";
if ($_[1] eq 'DATA') {
	push @verilog_state_machine, sprintf "\t\t\t\t\t\tam_data_out <= data_reg;\n";
} else {
	push @verilog_state_machine, sprintf "\t\t\t\t\t\tam_data_out <= 32'h%s;\n", $_[1];
}
push @verilog_state_machine, sprintf "\t\t\t\t\t\tif (am_waitreq)\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, $state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\t\telse\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, ++$state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\tend\n";
} 

# Sub-program to process the Avalon transfer read commands into read states in the state machine
sub read {
push @verilog_state_machine, sprintf "\n";
push @verilog_state_machine, sprintf "\t\t\t%s%d :\t// read %s\n", $state_name_prefix, $state_name_index, $_[0];
push @verilog_state_machine, sprintf "\t\t\t\t\tbegin\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\tam_addr <= 32'h%s;\n", $_[0];
push @verilog_state_machine, sprintf "\t\t\t\t\t\tam_rd <= 1'b1;\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\tif (am_waitreq)\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, $state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\t\telse begin\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tdata_reg_ena <= 1'b1;\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, ++$state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\t\tend\n";
push @verilog_state_machine, sprintf "\t\t\t\t\tend\n";
} 

# Sub-program to process the "idle" commands into idle states in the state machine
sub idle {
push @verilog_state_machine, sprintf "\n";
push @verilog_state_machine, sprintf "\t\t\t%s%d :\t// idle\n", $state_name_prefix, $state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, ++$state_name_index;
}

# Sub-program to test value read into DATA register from immediately preceeding read command; Sends state machine back to
#     read command until DATA register equals programmed value
sub testword {
push @verilog_state_machine, sprintf "\n";
push @verilog_state_machine, sprintf "\t\t\t%s%d :\t// testword %s\n", $state_name_prefix, $state_name_index, $_[0];
push @verilog_state_machine, sprintf "\t\t\t\t\tbegin\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\tif (data_reg != %s)\n", $_[0];
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, ($state_name_index-1);
push @verilog_state_machine, sprintf "\t\t\t\t\t\telse\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, ++$state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\tend\n";
} 

# Sub-program to test a single bit from the value read into DATA register from immediately preceeding read command; 
#     Sends state machine back to read command until tested bit equals programmed value
sub testbit {
push @verilog_state_machine, sprintf "\n";
push @verilog_state_machine, sprintf "\t\t\t%s%d :\t// testbit %d, %d\n", $state_name_prefix, $state_name_index, $_[0], $_[1];
push @verilog_state_machine, sprintf "\t\t\t\t\tbegin\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\tif (data_reg[%d] == 1'b%d)\n", $_[0], $_[1];
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, ++$state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\t\telse\n";
push @verilog_state_machine, sprintf "\t\t\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, ($state_name_index-2);
push @verilog_state_machine, sprintf "\t\t\t\t\tend\n";
}

# Sub-program to loop state machine back to previous state (may require running script once to get state definitions
#     Use 0 for idle state; Meant to be last state in state machine
sub loop {
push @verilog_state_machine, sprintf "\n";
push @verilog_state_machine, sprintf "\t\t\t%s%d :\t// loop %d\n", $state_name_prefix, $state_name_index, $_[0];
push @verilog_state_machine, sprintf "\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, $_[0];
} 

# Sub-program to end state machine processing; Creates endless loop
sub end {
push @verilog_state_machine, sprintf "\n";
push @verilog_state_machine, sprintf "\t\t\t%s%d :\t// end\n", $state_name_prefix, $state_name_index;
push @verilog_state_machine, sprintf "\t\t\t\t\tnext_state <= %s%d;\n",  $state_name_prefix, $state_name_index;
}