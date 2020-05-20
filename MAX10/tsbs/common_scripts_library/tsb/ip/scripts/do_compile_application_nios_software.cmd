source do_get_project_settings.cmd
echo "Compiling Application Nios software..."
cd ${application_nios_sw_bsp_path}/
make clean
cd -
cd ${application_nios_sw_path}/
make clean
make all
cd -
