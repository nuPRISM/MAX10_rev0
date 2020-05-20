source do_get_project_settings.cmd
echo "Compiling bootloader Nios software..."
cd ${bootloader_sw_path}/
make clean
make all
cd -
