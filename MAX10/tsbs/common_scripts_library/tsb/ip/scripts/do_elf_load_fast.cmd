 set bstreams [ get_service_paths master ]
  puts "bstreams = ($bstreams)"
  set desired_master [lsearch $bstreams "*download_0*"]
  puts "desired_master = $desired_master"; 
  set ::sdr_master [lindex $bstreams $desired_master]
  puts "Set sdr_master to $::sdr_master";
  set elf_binary_filename $::env(system_console_elf_binary_filename)
  set ddr_start_location $::env(system_console_ddr_start_location)
  master_write_from_file $::sdr_master $elf_binary_filename $ddr_start_location
 