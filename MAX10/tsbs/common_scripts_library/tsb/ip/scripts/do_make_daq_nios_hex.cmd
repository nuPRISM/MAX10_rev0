source do_get_project_settings.cmd
cd ${quartus_project_daq_nios_app_software_directory}/${daq_nios_filename_base}
make mem_init_generate 
cd -
