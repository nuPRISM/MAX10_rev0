source do_get_project_settings.cmd
quartus_cdb --update_mif ${quartus_project_location_directory}/${main_fpga_project_filename_base}
quartus_asm ${quartus_project_location_directory}/${main_fpga_project_filename_base}
cp -f --backup ${quartus_project_postcompile_sof_location_directory}/${main_fpga_project_filename_base}.sof ../exe/
