source do_get_project_settings.cmd
echo "Making main NIOS elf flash image..."
source do_make_elf_flash_image.cmd
echo "Making generating boot loader bsp..."
source do_generate_bootloader_bsp.cmd
echo "Making boot loader elf file..."
source do_make_bootloader_elf.cmd
echo "Making boot loader hex file..."
source do_make_bootloader_hex.cmd
echo "Updating bootloader ram withing SOF..."
source do_update_boot_loader_hex_within_sof.cmd
echo "Updating Main POF file..."
source do_update_main_pof_file.cmd
echo "Converting SOF to RBF file...."
source do_convert_original_sof_to_rbf.cmd
echo "Completed Main POF file generation. Now converting to RBF format..."
source convert_pof_to_rbf.cmd ../exe/$rbf_filename_for_programming_main_fpga_flash
echo "Now generating cropped file for programming via telnet and FTP...."
source do_generate_cropped_main_flash_image.cmd
echo "Completed Main POF and RBF file generation. Now need to program into FLASH"
