# (C) 2001-2017 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


##Copyright (C) 2004 Altera Corporation
##Any megafunction design, and related net list (encrypted or decrypted),
##support information, device programming or simulation file, and any other
##associated documentation or information provided by Altera or a partner
##under Altera's Megafunction Partnership Program may be used only to
##program PLD devices (but not masked PLD devices) from Altera.  Any other
##use of such megafunction design, net list, support information, device
##programming or simulation file, or any other related documentation or
##information is prohibited for any other purpose, including, but not
##limited to modification, reverse engineering, de-compiling, or use with
##any other silicon devices, unless such use is explicitly licensed under
##a separate agreement with Altera or a megafunction partner.  Title to
##the intellectual property, including patents, copyrights, trademarks,
##trade secrets, or maskworks, embodied in any such megafunction design,
##net list, support information, device programming or simulation file, or
##any other related documentation or information provided by Altera or a
##megafunction partner, remains with Altera, the megafunction partner, or
##their respective licensors.  No other licenses, including any licenses
##needed under any third party's intellectual property, are provided herein.
##Copying or modifying any file, or portion thereof, to which this notice
##is attached violates this copyright.

package em_onchip_memory2_qsys;
use Exporter;
@ISA = Exporter;
use e_parameter;
@EXPORT = qw(
    &make_mem
);


use strict;
use europa_all;
use wiz_utils;
use format_conversion_utils;
###############################################################################
# Component parameter check, internal variables will be used for RTL generation
###############################################################################

# internal variables with default value, will considered as verilog parameter
my $device_family_mapped = qq("");

my $ram_block_type;
my $init_contents_file;
my $non_default_init_file_enabled;
my $gui_ram_block_type;
my $device_family;
my $Writeable;
my $dual_port;
my $single_clock_operation;
my $Size_Value;
my $Size_Multiple;
my $use_shallow_mem_blocks;
my $init_mem_content;
my $en_pr_init_mode;
my $allow_in_system_memory_content_editor;
my $instance_id;
my $read_during_write_mode;
my $sim_meminit_only_filename;
my $ignore_auto_block_type_assignment;
my $Data_Width; 
my $Data_Width2;
my $Address_Width;
my $Address_Width2;
my $slave1Latency;
my $slave2Latency;
my $derived_is_hardcopy;               
my $ecc_enabled;

my $Address_Span;
my $num_lanes;
my $num_lanes2;
my $make_individual_byte_lanes;
my $num_words;
my $num_words2;
my $ecc_actual_data_width;
my $ecc_actual_data_width2;
my $name;
my $maximum_depth;


###############################################################################
# Validate onChip memory options
###############################################################################
sub validate_options
{
  my ($Opt) = @_;

  # Make the module name available in a handy format. [TODO] need to find out this feature 
  #$Opt->{name} = $project->_target_module_name();  

  # Boolean variables specify what kind of I/O we have:
  #
  validate_parameter({hash    => $Opt,
                       name    => "Writeable",
                       type    => "boolean",
                       default => 1,
                      });

  # Only check for non-ecc case
  if (!$Opt->{ecc_enabled}) {
    if (!is_computer_acceptable_bit_width($Opt->{Data_Width}))
    {
      ribbit(
        "ERROR:  Parameter validation failed.\n" .
        "  Parameter 'Data_Width' (= $Opt->{Data_Width})\n" .
        "  is not an allowed value.\n"
      );
    }
	
	if (!is_computer_acceptable_bit_width($Opt->{Data_Width2}))
    {
      ribbit(
        "ERROR:  Parameter validation failed.\n" .
        "  Parameter 'Data_Width2' (= $Opt->{Data_Width2})\n" .
        "  is not an allowed value.\n"
      );
    }
  }

  # Create fictitious (derived) Option "Address_Span" from existing
  #   "Size_Value" and "Size_Multiple" Opt:
  validate_parameter({hash    => $Opt,
                       name    => "Size_Multiple",
                       type    => "integer",
                       allowed => [1,1024],
                       default => 1,
                      });
  
  validate_parameter({hash    => $Opt,
                       name    => "Size_Value",
                       type    => "integer",
                      });

  $Opt->{Address_Span} = $Opt->{Size_Multiple} * 
                             $Opt->{Size_Value};

  # Write this parameter back into the ptf file. 
  # $project->WSA()->{Address_Span} = $Opt->{Address_Span}; 
      
  # This is probably irrelevant, but it could be helpful someday.
  # Write the WSA/Size assignment, for HAL use.
  # $project->WSA()->{Size} = $Opt->{Address_Span};

  validate_parameter({hash    => $Opt,
                       name    => "ram_block_type",
                       type     => "string",
                       allowed => ["M512", 
                                   "M4K", 
                                   "M-RAM",              
                                   "M9K",
                                   "M144K",
                                   "M20K",
                                   "M10K",
                                   "MLAB",
                                   "AUTO"],
                       default  => "AUTO",
                      });

  ####################################################################################
  #Decide parameters for Automatic ram_block_type and if it should be initialized 
  ####################################################################################
  #Ignore auto block type assignment from class.ptf if it is design from preview flow
  if ($Opt -> {ignore_auto_block_type_assignment} == 1)
  {
    if ($Opt->{gui_ram_block_type} =~ "Automatic")
    {
      $Opt->{ram_block_type} = "AUTO";
    }
  }
  
  #Decide value for init_mem_content if it is not being set properly from legacy mode
  if (($Opt->{init_mem_content}) != 0 && ($Opt->{init_mem_content} != 1))
  {
  	  if ($Opt->{Writeable} && $Opt->{derived_is_hardcopy})
      {
          $Opt->{init_mem_content} = 0;
      }
      else
      {
        if ($Opt->{ram_block_type} =~ /M-RAM/)
        {
          $Opt->{init_mem_content} = 0;
        }                                                            
        else
        {
          $Opt->{init_mem_content} = 1;
        }
      }
  }
  ####################################################################################
  
  #### Derived parameters:
  if ( $Opt->{ecc_enabled} ) {
      $Opt->{num_lanes}     = 0;
	  $Opt->{num_lanes2}    = 0;

      # Reverse engineer the Data_width to obtain the ecc bits size
      my $ecc_bits = 1;
      while ((2**$ecc_bits - 1) < $Opt->{Data_Width}) {
        $ecc_bits++;
      }
      # addtional one bit for SECDED
      $ecc_bits++;
      my $actual_data = $Opt->{Data_Width} - $ecc_bits;
      my $byte_width = int($actual_data/ 8);
      $Opt->{ecc_actual_data_width} = $actual_data;
      $Opt->{num_words} = ceil ($Opt->{Address_Span} / $byte_width);
	  
	  my $ecc_bits2 = 1;
      while ((2**$ecc_bits2 - 1) < $Opt->{Data_Width2}) {
        $ecc_bits2++;
      }
      # addtional one bit for SECDED
      $ecc_bits2++;
      my $actual_data2 = $Opt->{Data_Width2} - $ecc_bits2;
      my $byte_width2 = int($actual_data2/ 8);
      $Opt->{ecc_actual_data_width2} = $actual_data2;
      $Opt->{num_words2} = ceil ($Opt->{Address_Span} / $byte_width2);

  } else {
      $Opt->{num_lanes}     = $Opt->{Data_Width} / 8;
	  $Opt->{num_lanes2}     = $Opt->{Data_Width2} / 8;
      
      # The depth of the memory, in words, is handy to know.  
      # This is all-too-easily confused with the size of the RAM, in
      # bytes.  Not the same thing at all.
      my $byte_width = int($Opt->{Data_Width} / 8);
      $Opt->{num_words} = ceil ($Opt->{Address_Span} / $byte_width);
	  
      # The depth of the memory, in words, is handy to know.  
      # This is all-too-easily confused with the size of the RAM, in
      # bytes.  Not the same thing at all.
      my $byte_width2 = int($Opt->{Data_Width2} / 8);
      $Opt->{num_words2} = ceil ($Opt->{Address_Span} / $byte_width2);
  }
  $Opt->{make_individual_byte_lanes} = $Opt->{ram_block_type} eq 'M512' && $Opt->{num_lanes} > 1;

  # The address-bus can be wider than required by the span.  This allows
  # memories to occupy more address-space than the actual, physically-
  # implemented memory block.
  validate_parameter({hash    => $Opt,
                       name    => "Address_Width",
                       type    => "integer",
                       range   => [ceil(log2($Opt->{num_words})), 32],
                       });
  
  validate_parameter({hash    => $Opt,
                       name    => "Address_Width2",
                       type    => "integer",
                       range   => [ceil(log2($Opt->{num_words2})), 32],
                       });

  # $Opt->{base_addr_as_number} = $SBI->{Base_Address};
  # $Opt->{base_addr_as_number} = oct($Opt->{base_addr_as_number})
  #   if ($Opt->{base_addr_as_number} =~ /^0/);         
      
  validate_parameter({hash     => $Opt,
                       name     => "slave1Latency",
                       type     => "integer",             
                       range    => [1, 2],                                   
                       default  => 0,
                       });

  validate_parameter({hash     => $Opt,
                       name     => "slave2Latency",
                       type     => "integer",
                       range    => [1, 2],
                       default  => 0,                
                       });
  # [to be review] remove hdl language validation
  # $Opt->{lang} =
  #   $project->system_ptf()->{WIZARD_SCRIPT_ARGUMENTS}{hdl_language};
  # validate_parameter({hash    => $Opt,
  #                      name    => "lang",
  #                      type     => "string",
  #                      allowed => ["verilog", 
  #                                  "vhdl",],
  #                      default  => "verilog",
  #                     });
                       
  # Sekrit option.  Keep out!  If set, the placeholder memory contents 
  # file memory is full of random data, rather than 0.
  # $Opt->{set_rand_contents} = $Opt->{set_rand_contents};

  # Add a couple of handy references for make_placeholder_contents_files.
  # $Opt->{Base_Address} = $SBI->{Base_Address};
  # $Opt->{Address_Span} = $SBI->{Address_Span};
  
  #########################################################################################
  # Tidy up the init_contents_file if it is needed
  #########################################################################################
  # If the user selected a non-default initialization file but failed to specify an 
  # initialization file name OR if one doesn't exist in a legacy (pre 5.1) PTF,
  # then set the name to be the default (module name)
  
  if ($Opt->{init_contents_file} eq ".hex")
  {
	  $Opt->{init_contents_file} = $Opt->{name}.".hex";
  }
  
  # If user choose not to initialized memory, we should keep the file name to module name
  # We do this in generator instead of model because we want to keep the string of filename 
  # in GUI.
  if ($Opt->{init_mem_content} == 0)
  {
    $Opt->{init_contents_file} = $Opt->{name};
  }         

  #########################################################################################
  # pass down config content from .tcl to local variable 
  #########################################################################################
  $ram_block_type			= $Opt->{ram_block_type};
  $init_contents_file			= $Opt->{init_contents_file};
  $non_default_init_file_enabled	= $Opt->{non_default_init_file_enabled};
  $gui_ram_block_type			= $Opt->{gui_ram_block_type};
  $device_family			= $Opt->{device_family};
  $Writeable				= $Opt->{Writeable};
  $dual_port				= $Opt->{dual_port};
  $single_clock_operation		= $Opt->{single_clock_operation};
  $Size_Value				= $Opt->{Size_Value};
  $Size_Multiple			= $Opt->{Size_Multiple};
  $use_shallow_mem_blocks		= $Opt->{use_shallow_mem_blocks};
  $init_mem_content			= $Opt->{init_mem_content};
  $en_pr_init_mode			= $Opt->{en_pr_init_mode};
  $allow_in_system_memory_content_editor= $Opt->{allow_in_system_memory_content_editor};
  $instance_id				= $Opt->{instance_id};
  $read_during_write_mode		= $Opt->{read_during_write_mode};
  $sim_meminit_only_filename		= $Opt->{sim_meminit_only_filename};
  $ignore_auto_block_type_assignment	= $Opt->{ignore_auto_block_type_assignment};
  $Data_Width				= $Opt->{Data_Width}; 
  $Data_Width2				= $Opt->{Data_Width2}; 
  $Address_Width			= $Opt->{Address_Width};
  $Address_Width2			= $Opt->{Address_Width2};
  $slave1Latency			= $Opt->{slave1Latency};
  $slave2Latency			= $Opt->{slave2Latency};
  $derived_is_hardcopy			= $Opt->{derived_is_hardcopy};
  $ecc_enabled		       	        = $Opt->{ecc_enabled};

  $Address_Span				= $Opt->{Address_Span};
  $num_lanes				= $Opt->{num_lanes};
  $num_lanes2				= $Opt->{num_lanes2};
  $make_individual_byte_lanes		= $Opt->{make_individual_byte_lanes};
  $num_words				= $Opt->{num_words};
  $num_words2				= $Opt->{num_words2};
  $name					    = $Opt->{name};
  $ecc_actual_data_width    = $Opt->{ecc_actual_data_width};
  $ecc_actual_data_width2   = $Opt->{ecc_actual_data_width2};
  #$maximum_depth			= $Opt->{maximum_depth};  
}  
  

# Try to estimate usage.  Gets the wrong answer, I think,
# when byte lanes are used.
sub report_usage
{
  my $Opt = shift;
  
  print STDERR "  $name memory usage summary:\n";
  my %trimatrix_bits = (
    M512  => 512,
    M4K   => 4096,
    'M-RAM' => 512*1024,
  );
  my $bits_consumed = $num_words * $Data_Width;
  my $block_granularity = $trimatrix_bits{$ram_block_type};
  if ($make_individual_byte_lanes)
  {
    $block_granularity *= $num_lanes;
  }

  print STDERR "$num_words words, $Data_Width bits wide ($bits_consumed bits) ";
  print STDERR "(@{[ceil($bits_consumed / $trimatrix_bits{$ram_block_type})]} $ram_block_type blocks.\n";
}

# Generating simulation Hex file  
          

################################################################
# make_mem
#
# Given a name and a hashful of options, builds an e_module object
# which implements an onchip-memory peripheral.
#
################################################################
sub make_mem
{
  my ($module, $Opt, $project) = (@_);
  #my $Opt = &copy_of_hash ($project->WSA());
  #my $SBI1 = &copy_of_hash ($project->SBI("s1"));

  $Opt->{name} = $module->name();

  validate_options($Opt);
  
  # [to be review] move this dual_port condition checking into validate_options()   
  # if ($Opt->{dual_port})
  # {
  #   my $SBI2 = &copy_of_hash ($project->SBI("s2"));
  # 
  #   validate_options($Opt);
  # }             
                                                                        
  # [to be review] remove hex file generation in PTF related feature    
  #$project->do_makefile_target_ptf_assignments(
  #    's1',  
  #    ['dat', 'hex', 'sym', ], 
  #    $Opt,
  #);    
  
  my $hex_data_width = $Data_Width;
  my $hex_address_span = $Address_Span;
  if ($Opt->{ecc_enabled}) {
      # A routine to obtain closest by 8
      my $i = 0;
      $hex_data_width = 0;
      for ($i = 0 ; ($hex_data_width <= $Data_Width) ; $i = $i + 1) {
          $hex_data_width = $i * 8;
      }
      
      my $ecc_num_bytes = $ecc_actual_data_width / 8;
      my $depth_in_byte = $Address_Span / $ecc_num_bytes;
      $hex_address_span = $depth_in_byte * $hex_data_width / 8;
  }

  # if using default init file name
	  if ($Opt->{init_mem_content}) {
		  if (!$non_default_init_file_enabled) { 
		
			  my %target_hash;
			  if ($make_individual_byte_lanes) {
				  for my $lane (0 .. -1 + $num_lanes) {
					  my $stub = $init_contents_file . "_lane$lane";         
					  $target_hash{full_path} = $Opt->{project_info}{system_directory} . $stub . ".hex"; 
					  $project->make_placeholder_contents_files(           
						  {                    
							name => $stub,
							Base_Address => 0,
							Address_Span => $hex_address_span,                   
							Data_Width   => $hex_data_width,
							set_rand_contents => 0,                                                
							make_individual_byte_lanes => $make_individual_byte_lanes,                       
							num_lanes => $num_lanes,
							hdl_contents_file => { target => 'hex', targets => [\%target_hash]}
						  },
					  );
				  }                                                 
			  }
			  
			  # Always make the non-laned file.
			  $target_hash{full_path} = $Opt->{project_info}{system_directory} . $init_contents_file . ".hex";
			  $project->make_placeholder_contents_files(           
				  {                    
					name => $init_contents_file,
					Base_Address => 0,
					Address_Span => $hex_address_span,                   
					Data_Width   => $hex_data_width,                                  
					set_rand_contents => 0,                                                
					make_individual_byte_lanes => $make_individual_byte_lanes,                       
					num_lanes => $num_lanes,
					hdl_contents_file => { target => 'hex', targets => [\%target_hash]} 
				  },
			  );
		  }
	  }
  
  # make device family aware by component, tentatively not used 
  $device_family_mapped = do_device_family_name_mapping($device_family);
  # if ($device_family_mapped =~ /Stratix IV/){
  #    print STDERR "  DEVICE FAMILY is Stratix IV \n";
  # }

  # report_usage($Opt);
  
  instantiate_memory($module, $Opt);

  # Since signal-widths don't "bubble" through assignments, specify 
  # address-port width explicitly:
  e_port->new({within    => $module,
               name      => "address",
               width     => $Address_Width,
               direction => "in",
              });

  e_port->new({within    => $module,
               name      => "reset",
               width     => 1,
               direction => "in",
              });
  
  e_port->new({within    => $module,
               name      => "reset_req",
               width     => 1,
               direction => "in",
              });
  
  e_port->new({within    => $module,
               name      => "freeze",
               width     => 1,
               direction => "in",
              });

  # Our slave-port name is taken from the SLAVE section which 
  # is named in our class.ptf file.
  e_avalon_slave->new({within => $module,
                       name   => "s1",
                       sideband_signals => [ "clken" ],
                       type_map => {
                         debugaccess => 'debugaccess',
                         reset => 'reset',
                         },
                       });

  my %slave_2_type_map = reverse
  (                                            
     clk        => "clk2",
     clken      => "clken2",
     address    => "address2",
     readdata   => "readdata2",
     chipselect => "chipselect2",
     write      => "write2",
     writedata  => "writedata2",
     debugaccess=> 'debugaccess',
     reset      => 'reset2',
  );

  e_avalon_slave->new({within => $module,
                       name   => "s2",
                       sideband_signals => [ "clken" ],
                       type_map => \%slave_2_type_map,
                    });
} 

sub instantiate_memory     
{
  my ($module, $Opt) = @_;

  my $marker = e_default_module_marker->new($module);

  #my $SBI1 = $project->SBI("s1");
  #my $SBI2 = $project->SBI("s2");

  # Basic ports that all memory types have:
  e_port->adds(
    ['clk',        1,              'in'],
    ['address',    $Address_Width, 'in'],
    ['readdata',   $Data_Width,    'out'],
  );

  e_port->new({within    => $module,
              name      => "reset",
              width     => 1,
              direction => "in",
            });

  e_port->adds({name => "clken", width => 1, direction => "in",
    default_value => "1'b1"});
  e_signal->adds(
        ['clocken0', 1],
      );

  # Basic input port, output port maps for all memory types:
  my $in_port_map = {
    clock0      => 'clk',
    clocken0    => 'clocken0',
    address_a   => 'address',
    wren_a      => 'wren',
    rden_a      => "1'b1",
    data_a      => 'writedata',
  };

  my $out_port_map = 
    ($slave1Latency == 1) ? 
      { q_a => 'readdata' } :
      { q_a => 'readdata_ram' };
                                             
  # Pipeline read data if required.
  # explicitly remove the reset signal to the flop because we are not clearing 
  # the onchip memory content even during reset, this will prevent reset_n being exported to the top
  if ($slave1Latency > 1) {
    e_register->add(
      {out => ["readdata", $Data_Width],            
       in => "readdata_ram",  
       enable => "clken",
	   reset => '',
       delay => ($slave1Latency - 1),
      }
    );
  }

  # Whether RAM or ROM, the memory gets these ports:
  e_port->adds(
    ['chipselect', 1,              'in'],
    ['write',      1,              'in'],
    ['writedata',  $Data_Width,    'in'],
  );

  if ($Writeable)
  {
    if ($single_clock_operation)
    {
      e_assign->add(['wren', and_array('chipselect', 'write', 'clken')]);
    }
    else                                                                    
    {
      e_assign->add(['wren', and_array('chipselect', 'write')]);
    }
  }
  else                                         
  {
    # "ROM".  Make a RAM which can be written when debugaccess is set
    # (unless hardcopy).
    e_port->adds(
      ['debugaccess', 1, 'in'],                            
    );
    if ($derived_is_hardcopy)
    {
      # Hardcopy is targeted, so wire the write-enable inactive and let
      # Quartus figure out that this is really a ROM (and can have
      # an init_file).
      e_assign->add(['wren', 0]);
    }
    else
    {
      e_assign->add(['wren', and_array('chipselect', 'write', 'debugaccess')]);
    }
  }
  $maximum_depth = $num_words;
  
  # Optimization currently only for M4Ks 
  if($ram_block_type eq qq(M4K) && $use_shallow_mem_blocks eq "1")
  {
    	$maximum_depth = &calculate_maximum_depth($Opt);
  }
  my $parameter_map = {
    operation_mode            => qq("SINGLE_PORT"),
    width_a                   => $Data_Width,
    widthad_a                 => $Address_Width,
    numwords_a                => $num_words,
    lpm_type                  => qq("altsyncram"),
    byte_size                 => 8,
    outdata_reg_a             => qq("UNREGISTERED"),
    ram_block_type            => qq("$ram_block_type"),
    maximum_depth             => $maximum_depth,
	clock_enable_input_a      => qq("NORMAL"),
	clock_enable_input_b      => qq("NORMAL"),
	clock_enable_output_a     => qq("BYPASS"),
	clock_enable_output_b     => qq("BYPASS"),
	outdata_aclr_a            => qq("NONE"),
	outdata_aclr_b            => qq("NONE")
  };





  #Use In-System Memory Content Editor
  if ($allow_in_system_memory_content_editor)
  {
  	my $lpm_hint = "ENABLE_RUNTIME_MOD=YES, INSTANCE_NAME=$instance_id";
  	$parameter_map->{lpm_hint} = qq("$lpm_hint");
  }
  
  # More than one byte lane? Add ports as needed.
  if ($num_lanes > 1)
  {
     # This module needs a byteenable input.
    e_port->adds(["byteenable", $num_lanes,     "in" ],);
	e_signal->adds(
        ['byteenable', $Data_Width / 8],
      );
    if ($ram_block_type eq 'M512')
    {
      # Don't mention anything byteenable-related in the instantiation
      # of the byte-lane M512s, or Quartus gets angry.
    }
    else
    {
      $in_port_map->{byteena_a} = 'byteenable';
      $parameter_map->{width_byteena_a} = $num_lanes;
    }
  }

  if ($dual_port)
  {
    #add a bunch of new ports;
    e_port->adds(
      ['address2',    $Address_Width2, 'in'],
      ['readdata2',   $Data_Width2,    'out'],
    );

    if (!($single_clock_operation))
    {
      e_port->adds(
        ['clk2',        1,                     "in"],
        );

      e_port->new({within    => $module,
                name      => "reset2",
                width     => 1,
                direction => "in",
              });
      e_port->new({within    => $module,
                name      => "reset_req2",
                width     => 1,
                direction => "in",
              });
      e_signal->adds(
        ['clocken1', 1],
       );
      
        if ($en_pr_init_mode)
        {
            e_signal->adds(
                ['clocken0_int', 1],
            );
            
            e_signal->adds(
                ['clocken1_int', 1],
            );
            
            e_assign->add(['clocken0_int', 'clken & ~reset_req']);
            e_assign->add(['clocken1_int', 'clken2 & ~reset_req2']);
    
            e_register->add(
                {   out => ["sync_freeze_n", 1],            
                    in => "1'b1",  
		    clock => "clk",
                    enable => "1'b1",
	            reset => "freeze",
                    delay => 2,
                    reset_level => 1,
                }
            );
            
            e_register->add(
                {   out => ["sync2_freeze_n", 1],            
                    in => "1'b1",  
		    clock => "clk2",
                    enable => "1'b1",
	            reset => "freeze",
                    delay => 2,
                    reset_level => 1,
                }
            );

            e_register->add(
                {   out => ["clocken0", 1],            
                    in => "clocken0_int",  
		    clock => "clk",
                    enable => "1'b1",
	            reset => "sync_freeze_n",
                    delay => 1,
                }
            );
            
            e_register->add(
                {   out => ["clocken1", 1],            
                    in => "clocken1_int",  
		    clock => "clk2",
                    enable => "1'b1",
	            reset => "sync2_freeze_n",
                    delay => 1,
                }
            );

        } else {
            e_assign->add(['clocken0', 'clken & ~reset_req']);
            e_assign->add(['clocken1', 'clken2 & ~reset_req2']);
        }

    # Additional ports for dual-port ROM or RAM.
    $in_port_map->{clock1}      = 'clk2';
    $in_port_map->{clocken1}    = 'clocken1';
  # clken2 is maintain as avalon need this port but altsyncram do not need this if only single clock mode
  # basically the clken2 port is inserted to suite avalon need but never assign to altsyncram. 
  # Hence, in single clock mode, s2 do not support TCM

    } else { # single clock operation in dual port mode
        if (!($device_family =~ /STRATIX10/)) {
            e_assign->add(['not_clken', '~clken']);	    
            e_assign->add(['not_clken2', '~clken2']);
            $in_port_map->{addressstall_a} = "not_clken";
            $in_port_map->{addressstall_b} = "not_clken2";
        }
    
        
        if ($en_pr_init_mode) {
            
            e_signal->adds(
                ['clocken0_int', 1],
            );

            e_assign->add(['clocken0_int', '~reset_req']);
            
            e_register->add(
                {   out => ["sync_freeze_n", 1],            
                    in => "1'b1",  
		    clock => "clk",
                    enable => "1'b1",
	            reset => "freeze",
                    delay => 2,
                    reset_level => 1,
                }
            );
            
            e_register->add(
                {   out => ["clocken0", 1],            
                    in => "clocken0_int",  
		    clock => "clk",
                    enable => "1'b1",
	            reset => "sync_freeze_n",
                    delay => 1,
                }
            );

        } else {
            e_assign->add(['clocken0', '~reset_req']);
        }

    $in_port_map->{clocken0}    = "clocken0";
    }
 
    e_port->adds({name => "clken2", width => 1, direction => "in",
      default_value => "1'b1"});

    $in_port_map->{address_b}   = 'address2';
    $in_port_map->{wren_b}      = 'wren2';
    $in_port_map->{rden_b}      = "1'b1";
    $in_port_map->{data_b}      = 'writedata2';
	$in_port_map->{aclr0}          = "1'b0";
	$in_port_map->{aclr1}          = "1'b0";
	$in_port_map->{addressstall_a} = "1'b0";
	$in_port_map->{addressstall_b} = "1'b0";
    $in_port_map->{clocken2} = "1'b1";
	$in_port_map->{clocken3} = "1'b1";
	

    $out_port_map->{q_b} = 
      ($slave2Latency == 1) ? 'readdata2' : 'readdata2_ram';

    # Pipeline read data if required.
    if ($slave2Latency > 1) {
	if ($single_clock_operation)
	{
	e_register->add(
        {out => ["readdata2", $Data_Width2],            
         in => "readdata2_ram",  
		 clock => "clk",
		 reset => '',
         enable => "clken2",
         delay => ($slave2Latency - 1),     
        }
      );  

} else {



	  # explicitly remove the reset signal to the flop because we are not clearing the 
	  # onchip memory content even during reset, this will prevent reset_n being exported to the top
	  e_register->add(
        {out => ["readdata2", $Data_Width2],            
         in => "readdata2_ram",  
		 clock => "clk2",
		 reset => '',
         enable => "clken2",
         delay => ($slave2Latency - 1),
        }
      );
}
    }

    # Additional ports and signals for dual-port RAM.
    e_signal->adds(
      ['wren2', 1],
      ['write2', 1],
      ['chipselect2', 1],
      ['writedata2',  $Data_Width2],
    );

    if ($num_lanes2 > 1)
    {
      e_signal->adds(
        ['byteenable2', 1],
      );
      $in_port_map->{byteena_b} = "1'b1";
      $parameter_map->{width_byteena_b} = 1;
    }

    if ($Writeable)
    {
      if ($single_clock_operation)
      {
        e_assign->add(['wren2', and_array('chipselect2', 'write2', 'clken2')]);
      }
      else
      {
        e_assign->add(['wren2', and_array('chipselect2', 'write2')]);
      }
    }
    else
    {
      if ($derived_is_hardcopy)
      {
        # Hardcopy is targeted, so wire the write-enable inactive and let
        # Quartus figure out that this is really a ROM (and can have
        # an init_file).
        e_assign->add(['wren2', 0]);
      }
      else
      {
        e_assign->add(['wren2', and_array('chipselect2', 'write2', 'debugaccess')]);
      }
    }

if (!($single_clock_operation))
{
    # Parameters particular to dual-port memory.
    # Port A always uses clock 0 so no *_reg_a parameters exist or are needed.
    $parameter_map->{operation_mode} = qq("BIDIR_DUAL_PORT");
    $parameter_map->{width_b} = $Data_Width2;
    $parameter_map->{widthad_b} = $Address_Width2;
    $parameter_map->{numwords_b} = $num_words2;
    $parameter_map->{outdata_reg_b} = qq("UNREGISTERED");
    $parameter_map->{byteena_reg_b} = qq("CLOCK1");
    $parameter_map->{indata_reg_b} = qq("CLOCK1");
    $parameter_map->{address_reg_b} = qq("CLOCK1");
    $parameter_map->{intended_device_family} = qq("Cyclone V");
    $parameter_map->{wrcontrol_wraddress_reg_b} = qq("CLOCK1");
    $parameter_map->{read_during_write_mode_port_a} = qq("NEW_DATA_NO_NBE_READ");
    $parameter_map->{read_during_write_mode_port_b} = qq("NEW_DATA_NO_NBE_READ");   
    $parameter_map->{power_up_uninitialized} = qq("FALSE");   
} else {
    # when there is single_clock_operation in dual port mode
    $parameter_map->{operation_mode} = qq("BIDIR_DUAL_PORT");
    $parameter_map->{width_b} = $Data_Width2;
    $parameter_map->{widthad_b} = $Address_Width2;
    $parameter_map->{numwords_b} = $num_words2;
    $parameter_map->{outdata_reg_b} = qq("UNREGISTERED");
    $parameter_map->{byteena_reg_b} = qq("CLOCK0");
    $parameter_map->{indata_reg_b} = qq("CLOCK0");
    $parameter_map->{address_reg_b} = qq("CLOCK0");
    $parameter_map->{wrcontrol_wraddress_reg_b} = qq("CLOCK0");

    if ((($ram_block_type =~ /M9K/) or ($ram_block_type =~ /M144K/)) && (!($read_during_write_mode =~ /DONT_CARE/))) 
    {   
    $parameter_map->{read_during_write_mode_port_a} = qq("$read_during_write_mode");
    $parameter_map->{read_during_write_mode_port_b} = qq("$read_during_write_mode");
    }



}
  }
  else
  {
    # Single-port RAM/ROM.
    if ($en_pr_init_mode) {
        
        e_signal->adds(
            ['clocken0_int', 1],
        );

        e_assign->add(['clocken0_int', 'clken & ~reset_req']);
            
        e_register->add(
            {   out => ["sync_freeze_n", 1],            
                in => "1'b1",  
		clock => "clk",
                enable => "1'b1",
	        reset => "freeze",
                delay => 2,
                reset_level => 1,
            }
        );
            
        e_register->add(
            {   out => ["clocken0", 1],            
                in => "clocken0_int",  
		clock => "clk",
                enable => "1'b1",
	        reset => "sync_freeze_n",
                delay => 1,
            }
        );

    } else {
        e_assign->add(['clocken0', 'clken & ~reset_req']);
    }

    $parameter_map->{read_during_write_mode_port_a} = qq("DONT_CARE");
  }

  # Right now compilation and simulation versions of the altsyncram
  # have only very small differences, which show up in the parameters.
  
  # I could avoid the tags (have a single e_blind_instance) as follows:
  # For VHDL: specify the absolute path to the contents file, so that 
  # both Modelsim and Quartus can find it with no path issues.
  # For Verilog, use two levels of `ifdef:
  # if MODEL_TECH
  #   if NO_PLI
  #     dat file (in simulation directory)
  #   else
  #     ../hex file (up one level, in quartus directory)
  # else
  #   hex file (in quartus directory)
  # end
  # 
  # The decree is that there shall be no absolute path names in
  # files - so, stick with different compilation and simulation
  # instantiations.

  my $sim_parameter_map = {%$parameter_map};


  my $hdl_file_info = $Opt->{target_info}->{hex};
  my $sim_file_info = $Opt->{target_info}->{dat};

	  if ($make_individual_byte_lanes)
	  {
		# Complicated instantiation for M512, which lacks byte enables.
		
		# Modify the parameter map and the input port map as needed, 
		# given that we're creating byte-lanes rather than a single
		# monolithic memory instantiation.
		$parameter_map->{width_a} = 8;
		$sim_parameter_map->{width_a} = 8;
		
		for my $lane (0 .. $num_lanes - 1)
		{
		  e_assign->add(["write_lane$lane", and_array('wren', "byteenable\[$lane\]")]);
		  $in_port_map->{wren_a} = "write_lane$lane";
		  $in_port_map->{data_a} = sprintf("writedata[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8);
		  
		  # SPR 188154 : if num of lanes > 1, out_port map is not checked for Read_latency
		  $out_port_map->{q_a} = ($slave1Latency == 1) ? 
		  sprintf("readdata[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8) :
		  sprintf("readdata_ram[%d : %d]", ($lane + 1) * 8 - 1, $lane * 8);
	
		  set_init_file_parameters(
			$Opt,
			$parameter_map,
			$sim_parameter_map,
			$hdl_file_info,
			$sim_file_info,
			$lane,
			#$project,
		  );
	
		  # Create a synthesis-tagged memory module for this lane.
		  e_blind_instance->add({
			#tag    => 'synthesis',   
			name   => "the_altsyncram_$lane",
			module => 'altsyncram',
			in_port_map => $in_port_map,
			out_port_map => $out_port_map,
			parameter_map => $parameter_map,
		  });
	
		  # Create a simulation-tagged memory module for this lane. (remove sim part, they're same as synthesis)
		  # e_blind_instance->add({
		  #   tag    => 'simulation',
		  #   name   => "the_altsyncram_$lane",
		  #   module => 'altsyncram',
		  #   in_port_map => $in_port_map,
		  #   out_port_map => $out_port_map,
		  #   parameter_map => $sim_parameter_map,
		  #   use_sim_models => 1,
		  # }); 
		}      
	  }
	  else
	  {                
		set_init_file_parameters(
		  $Opt,
		  $parameter_map,
		  $sim_parameter_map,
		  $hdl_file_info,
		  $sim_file_info,
		  #$project,
		);
	
		if ($ram_block_type =~ /M-RAM/ )
		{
		  # If this is an M-RAM that allows simulation contents, lie to the sim
		  # model about the block type (Quartus' overzealous sim model doesn't
		  # allow initialization for M-RAMs, so we have to fool it).
		  $sim_parameter_map->{ram_block_type} = qq("M4K");
		}
	
		# Create a synthesis-tagged memory module.
		e_blind_instance->add({
		  #tag    => 'synthesis',
		  name   => 'the_altsyncram',
		  module => 'altsyncram',
		  in_port_map => $in_port_map,
		  out_port_map => $out_port_map,
		  parameter_map => $parameter_map,
		});
	
		# Create a simulation-tagged memory module. (remove sim portion, they're same as synthesis)
		# e_blind_instance->add({
		#   tag    => 'simulation',
		#   name   => 'the_altsyncram',
		#   module => 'altsyncram',
		#   in_port_map => $in_port_map,
		#   out_port_map => $out_port_map,
		#   parameter_map => $sim_parameter_map,
		#   use_sim_models => 1,
		# });
	  }
  return $module;
}

sub set_init_file_parameters
{ 
  my (
    $Opt,
    $parameter_map,
    $sim_parameter_map,
    $hdl_file_info,
    $sim_file_info,
    $lane,
    $project,
  ) = @_;  
  
  #if ($hdl_file_info) 
  if (1)
  {           
    my $rec = shift @{$hdl_file_info->{targets}};
    # Explicitly perform altsyncram parameter map for the init file
    
    my $stub = $init_contents_file;
   
    #SPR 238959
    #Replace all character \ with /
    $stub =~ s|\\|/|g;
    # if using default init file name, $init_contents_file = "onchip_ram_0"
    # if using user's init file name , $init_contents_file = "user_input.hex" 
    my $hex = "$stub";
    # if using default init file name, then we need to append a ".hex"
    if (!$non_default_init_file_enabled) {
        $hex = "$stub.hex";
    }
    
    #for M512s:
    #otherwise append the byte lane index
    if($make_individual_byte_lanes)
    {
      # Retrieve the byte-lane index
      #split "lane", $rec->{ptf_key};
      #$hex = $stub."_lane".$_[1].".hex";
      $hex = $stub."_lane".$lane.".hex";
    }
    
    # For Simulation, simulation and synthesis portion always come together
    my $file;
    $file = qq($hex);
    
    #Forget all about going out one folder higher if it is a full path
    #California model is going to filter out relative path.
    if (($stub =~ m|/|) || ($sim_meminit_only_filename) ) 
    {
      $file = qq($hex);
    }
    
    # [TODO] Qsys don't support for multiple mem_init file, defer to later for fixing 
    # if($make_individual_byte_lanes)
    # {
    #     e_parameter->adds(
    #       {
    #         name => "INIT_FILE$lane",
    #         default => $hex,
    #         vhdl_type => "STRING",   
    #       },                              
    #     );
    #     
    #     $sim_parameter_map->{init_file} = 'INIT_FILE'.$lane;
    # } else {  
        
		  #If user decide not to initialized the memory in hardware, do it now
		  if ($Opt->{init_mem_content})
		  {
			e_parameter->adds(
			  {
				name => "INIT_FILE",
				default => $file,
				vhdl_type => "STRING",   
			  },                              
			);
		
			$parameter_map->{init_file} = 'INIT_FILE';
			$sim_parameter_map->{init_file} = 'INIT_FILE';   
		  } else {
			$parameter_map->{init_file} = qq("UNUSED");
			$sim_parameter_map->{init_file} = qq("UNUSED");
		 }
    # } 
  }                                                         
}  

# calculate_maximum_depth

# input : $Opt (WSA hash ref) 
# Returns the "optimal" maximum depth so that the memory is packed into 
# M4K's as efficiently as possible. 
sub calculate_maximum_depth
{
	(my $Opt) = @_;
	#is num_words a power of 2?
	# If it is then trying to shrink it won't do anything
	if(&is_power_of_two($num_words))
	{
		return $num_words;
	}
	else
	{
		my $next_power_of_2 = &next_higher_power_of_two($num_words);
		# obtain the greatest common divisor of the prescribed overall depth and its next 
		# greatest power of 2
		
		my $gcd = &gcd_euclid($num_words, $next_power_of_2);
		# return the maximum of the GCD and number of words per M4K (4096 bits)
		return &max($gcd, int(4096/$Data_Width));
		
	}

}
# Euclids classic algorithm to find the GCD of two integers
sub gcd_euclid
{
	my $p = shift;
	my $q = shift;
	my $mod_val = 0;
	while ($p > 0)
        {
          $mod_val = $q % $p;
          $q = $p;
          $p = $mod_val;
        }
        return $q;
}

###########################################################
# perform device family name mapping

sub do_device_family_name_mapping
  {
  	my $device_name = @_[0];
  	
		my %translate_device_name = (
			"CYCLONE" => "Cyclone",
			"CYCLONEII" => "Cyclone II",
			"CYCLONEIII" => "Cyclone III",
			"TARPON" => "Cyclone III LPS",
			"STINGRAY" => "Cyclone IV GX",
			"CYCLONEIVE" => "Cyclone IV E",
			"STRATIX" => "Stratix",
			"STRATIXGX" => "Stratix GX",
			"STRATIXII" => "Stratix II",
			"STRATIXIII" => "Stratix III",
			"STRATIXIIGX" => "Stratix II GX",
			"STRATIXIV" => "Stratix IV",
			"STRATIXV" => "Stratix V",
			"ARRIAGX" => "Arria GX",
			"ARRIAII" => "Arria II",
			"ARRIAIIGZ" => "Arria II GZ",
			"HARDCOPYII" => "HardCopy II",
			"HARDCOPYIII" => "HardCopy III",
			"HARDCOPYIV" => "HardCopy IV",
		);
		
		my $tr_device_name = $translate_device_name{$device_name};
		
		if($tr_device_name ne ""){
			return $tr_device_name;
		}else{
			return $device_name;
		}
  } 

1;  
