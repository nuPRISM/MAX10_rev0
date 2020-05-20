echo "Nios Terminal Processes will be killed..."
echo "-----------------------------------------------------------"
ps aux | grep '[n]ios2-terminal' | awk '{print $1}'
kill $(ps aux | grep '[n]ios2-terminal' | awk '{print $1}')
echo "-----------------------------------------------------------"
source do_altera_hardware_load.cmd
source do_app_nios_load.cmd
sleep 30
source do_run_system_console.cmd "$@"