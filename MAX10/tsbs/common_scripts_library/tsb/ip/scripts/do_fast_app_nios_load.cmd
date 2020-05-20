#!/bin/bash
source do_get_project_settings.cmd

SCRIPTS_PWD=$(pwd)
echo "SCRIPTS_PWD = " $SCRIPTS_PWD
SCRIPTS_PWD=`cygpath -w $SCRIPTS_PWD`
echo "SCRIPTS_PWD = " $SCRIPTS_PWD
corrected_pwd=`echo $SCRIPTS_PWD | tr '\\' '/'`
echo "corrected_pwd =" $corrected_pwd

usb=0
elf_filename=${main_fpga_project_elf_filename_base}
ddr_addr=${main_fpga_memory_space_start_addr}
nios_instance=${application_nios_instance_index}

for i in "$@"
do
case $i in
     -u=*|--usb=*)
    usb=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
    
	-f=*|--file=*)
    elf_filename=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
	-a=*|--addr=*)
    ddr_addr=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
		
	-n=*|--nios=*)
    nios_instance=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
		
	--default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
done

export fast_load_system_console_usb_cable=${usb}
export fast_load_system_console_elf_filename=${elf_filename}
export fast_load_system_console_directory_called_from=${corrected_pwd}
export fast_load_system_console_ddr_addr=${ddr_addr}
export fast_load_system_console_nios_instance=${nios_instance}

echo "Called from : " ${corrected_pwd}
echo ELF_FILENAME_BASE = ${elf_filename}
echo USB = ${usb}
echo DDR_ADDR = ${ddr_addr}
echo NIOS_INSTANCE = ${nios_instance}

source do_convert_elf_to_rbf.cmd ../exe/${elf_filename}
$SOPC_KIT_NIOS2/../quartus/sopc_builder/bin/system-console -disable_timeout -cli --rc_script=fast_elf_load_local_system_console_rc_script.tcl --script="../../../tsbs/common_scripts_library/tsb/ip/scripts/fast_elf_load.tcl"
cygstart nios2-terminal --no-quit-on-ctrl-d -d ${main_fpga_device_index} -i ${application_nios_associated_jtag_uart_instance_index} "$@"
