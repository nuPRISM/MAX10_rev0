source do_get_project_settings.cmd

nios2-download "$@" -g -d ${main_fpga_device_index} -i ${emif_nios_instance_index} -r ${emif_fpga_project_elf_path}/${emif_fpga_project_elf_filename_base}\.elf
cygstart nios2-terminal -d ${main_fpga_device_index} -i ${emif_nios_associated_jtag_uart_instance_index} "$@"
