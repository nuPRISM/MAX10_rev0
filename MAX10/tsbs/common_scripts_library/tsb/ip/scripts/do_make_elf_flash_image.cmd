source do_get_project_settings.cmd
../../../tsbs/common_scripts_library/tsb/ip/scripts/make_flash_image_script.sh ../exe/${main_fpga_project_elf_filename_base}.elf ${main_fpga_flash_base_addr} ${main_fpga_flash_end_addr}
bin2flash --input=../exe/${main_fpga_project_elf_filename_base}.elf.flash.bin --output=../exe/${main_fpga_project_elf_filename_base}.flash --location=0x0
nios2-elf-objcopy -I srec -O ihex ../exe/${main_fpga_project_elf_filename_base}.elf.flash.srec ../exe/${main_fpga_project_elf_filename_base}.flash.hex