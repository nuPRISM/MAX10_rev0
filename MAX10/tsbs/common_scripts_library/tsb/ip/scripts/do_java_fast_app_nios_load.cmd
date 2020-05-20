source do_get_project_settings.cmd

# nios2-download "$@" -g -d ${main_fpga_device_index} -i ${application_nios_instance_index} -r ../exe/${main_fpga_project_elf_filename_base}\.elf
# $QUARTUS_ROOTDIR/bin64/jre/bin/java -verbose -cp ../../../tsbs/common_scripts_library/tsb/ip/software/DownloadElf_quartus_9_1/src/systemconsole/fast/downloader:. -jar ../../../tsbs/common_scripts_library/tsb/ip/scripts/DownloadElf.jar ../exe/${main_fpga_project_elf_filename_base}\.elf "$@" -g -d ${main_fpga_device_index} -ip ${application_nios_instance_index} -r
# $QUARTUS_ROOTDIR/bin64/jre/bin/javaw -verbose -cp :. -jar  /cygdrive/d/griffin/edevel00249_grifc_slave/tsbs/common_scripts_library/tsb/ip/scripts/DownloadElf.jar ../exe/${main_fpga_project_elf_filename_base}\.elf "$@" -g -d ${main_fpga_device_index} -ip ${application_nios_instance_index} -r

# $QUARTUS_ROOTDIR/bin64/jre/bin/javaw -verbose d:/griffin/edevel00249_grifc_slave/tsbs/common_scripts_library/tsb/ip/software/DownloadElf_quartus_9_1/src/systemconsole/fast/downloader/DownloadElf ../exe/${main_fpga_project_elf_filename_base}\.elf "$@" -g -d ${main_fpga_device_index} -ip ${application_nios_instance_index} -r
# $QUARTUS_ROOTDIR/bin64/jre/bin/javaw -verbose -cp ../../../tsbs/common_scripts_library/tsb/ip/software/DownloadElf_quartus_9_1/src:. DownloadElf ../exe/${main_fpga_project_elf_filename_base}\.elf "$@" -g -d ${main_fpga_device_index} -ip ${application_nios_instance_index} -r


cd ../../../tsbs/common_scripts_library/tsb/ip/scripts
java -verbose -jar DownloadElf.jar ../../../../../tsb/ip/exe/${main_fpga_project_elf_filename_base}\.elf "$@" -g -d ${main_fpga_device_index} -ip ${application_nios_instance_index}
cygstart nios2-terminal --no-quit-on-ctrl-d -d ${main_fpga_device_index} -i ${application_nios_associated_jtag_uart_instance_index} "$@"
cd -