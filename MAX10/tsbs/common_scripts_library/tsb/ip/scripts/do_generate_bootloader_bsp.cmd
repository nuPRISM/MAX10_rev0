source do_get_project_settings.cmd
echo "erasing linker.x ..."
rm -f ${bootloader_sw_bsp_path}/linker.x
echo "erasing mem_init.mk ..."
rm -f ${bootloader_sw_bsp_path}/mem_init.mk
echo "Generating Bootloader BSP..."
nios2-bsp-generate-files  --verbose --bsp-dir ${bootloader_sw_bsp_path}/ --settings ${bootloader_sw_bsp_path}/settings.bsp
echo "fixing linker.x ..."
source do_fix_altera_linker_x_bug.cmd ${bootloader_sw_bsp_path}/linker.x
echo "fixing elf2hex bug ..."
source do_fix_altera_elf2hex_bug.cmd ${bootloader_sw_bsp_path}/mem_init.mk
