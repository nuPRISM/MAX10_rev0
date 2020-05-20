source do_get_project_settings.cmd

echo "Making generating boot loader bsp..."
source do_generate_bootloader_bsp_without_linker_x_fix.cmd
echo "Making boot loader elf file..."
source do_make_bootloader_elf.cmd
echo "Making boot loader hex file..."
source do_make_bootloader_hex.cmd
echo "Updating memory contents within SOF and POF file..."
source do_update_main_fpga_pof_file.cmd