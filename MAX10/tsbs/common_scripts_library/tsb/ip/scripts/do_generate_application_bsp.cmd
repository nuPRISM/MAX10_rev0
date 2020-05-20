source do_get_project_settings.cmd
echo "erasing linker.x ..."
rm -f ${application_nios_sw_bsp_path}/linker.x
echo "Generating Application BSP..."
nios2-bsp-generate-files  --verbose --bsp-dir ${application_nios_sw_bsp_path}/ --settings ${application_nios_sw_bsp_path}/settings.bsp
echo "fixing linker.x ..."
source do_fix_altera_linker_x_bug.cmd ${application_nios_sw_bsp_path}/linker.x