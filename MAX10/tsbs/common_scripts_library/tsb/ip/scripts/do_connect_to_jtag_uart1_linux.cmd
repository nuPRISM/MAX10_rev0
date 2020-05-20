source do_get_project_settings.cmd
nios2-terminal --no-quit-on-ctrl-d -d ${main_fpga_device_index} -i ${bootloader_nios_associated_jtag_uart_instance_index} "$@" 
