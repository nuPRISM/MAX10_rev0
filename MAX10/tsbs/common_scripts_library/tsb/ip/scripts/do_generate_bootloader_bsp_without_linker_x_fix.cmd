source do_get_project_settings.cmd
echo "Generating Bootloader BSP..."
nios2-bsp-generate-files  --verbose --bsp-dir ${bootloader_sw_bsp_path}/ --settings ${bootloader_sw_bsp_path}/settings.bsp
