source do_get_project_settings.cmd
nios2-download "$@" -g -d ${main_fpga_device_index} -i ${bootloader_nios_instance_index} -r ../exe/${bootloader_elf_base}\.elf
cygstart nios2-terminal --no-quit-on-ctrl-d -d ${main_fpga_device_index} -i ${bootloader_nios_associated_jtag_uart_instance_index} "$@"
