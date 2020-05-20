echo "Nios Terminal Processes will be killed..."
echo "-----------------------------------------------------------"
ps aux | grep '[n]ios2-terminal' | awk '{print $1}'
kill $(ps aux | grep '[n]ios2-terminal' | awk '{print $1}')
echo "-----------------------------------------------------------"
source do_altera_hardware_load.cmd
source do_board_nios_load.cmd
sleep 10
source do_fmc0_xilinx_hardware_load.cmd
source do_app_nios_load.cmd
source do_run_system_console.cmd "$@"