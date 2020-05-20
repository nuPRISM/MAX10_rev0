source do_get_project_settings.cmd

nios2-download "$@" -g -d ${main_fpga_device_index} -i ${dut_nios_instance_index} -r ${dut_fpga_project_elf_path}/${dut_fpga_project_elf_filename_base}\.elf
cygstart nios2-terminal --no-quit-on-ctrl-d --flush -d ${main_fpga_device_index} -i ${dut_nios_associated_jtag_uart_instance_index} "$@"
