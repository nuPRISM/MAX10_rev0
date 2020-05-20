source do_get_project_settings.cmd

nios2-configure-sof --device $main_fpga_device_index "$@" ../exe/$main_fpga_project_filename_base\.sof 