SCRIPTS_PWD=$(pwd)
echo "SCRIPTS_PWD = " $SCRIPTS_PWD
SCRIPTS_PWD=`cygpath -w $SCRIPTS_PWD`
echo "SCRIPTS_PWD = " $SCRIPTS_PWD
CUT_SCRIPTS_PWD=${SCRIPTS_PWD#*/}
echo "CUT_SCRIPTS_PWD = " $CUT_SCRIPTS_PWD
CUT_SCRIPTS_PWD=${CUT_SCRIPTS_PWD#*/}
echo "CUT_SCRIPTS_PWD = " $CUT_SCRIPTS_PWD
CUT_SCRIPTS_PWD=${CUT_SCRIPTS_PWD#*/}
echo "CUT_SCRIPTS_PWD = " $CUT_SCRIPTS_PWD

# ugly script to fixe Xilinx's aversion to relative paths
# <?xml version="1.0" encoding="UTF-8"?>
# <section name="Workbench">
#	<item value="D:\deap\edevel00279_deap_trigger\tsb\ip\rtl\workspace\adc_fmc_mcs_ctrl\Debug\adc_fmc_mcs_ctrl.elf" key="spartan_microblaze_processor_adc_ctrl_fmc-microblaze_mcs_v1_3-initElf"/>
#	<item value="D:\deap\edevel00279_deap_trigger\tsb\ip\rtl\microblaze_mcs_v1_3_bd.bmm" key="spartan_microblaze_processor_adc_ctrl_fmc-bmmFile"/>
#	<item value="D:\deap\edevel00279_deap_trigger\tsb\ip\exe\fmc_out.bit" key="spartan_microblaze_processor_adc_ctrl_fmc-bitFile"/>
# </section>


# Replace line 3
echo on
elf_path=$SCRIPTS_PWD\\..\\..\\..\\tsbs\\fmc1\\tsb\\ip\\rtl\\workspace\\adc_fmc_mcs_ctrl\\Debug\\adc_fmc_mcs_ctrl.elf
echo "elf_path =" $elf_path
echo "corrected_elf_path=" $corrected_elf_path
replacement_str="<item value=\"$elf_path\" key=\"spartan_microblaze_processor_adc_ctrl_fmc-microblaze_mcs_v1_3-initElf\"\/>"
echo "replacement_str = " $replacement_str
corrected_replacement_str=${replacement_str//\\/\/}
echo "corrected_replacement_str = " $corrected_replacement_str
corrected_replacement_str2=${corrected_replacement_str//\/\//\/}
echo "corrected_replacement_str2 = " $corrected_replacement_str2
file_to_replace=$SCRIPTS_PWD\/..\/..\/..\/tsbs\/fmc1\/tsb\/ip\/rtl\/workspace\/.metadata\/.plugins\/com.xilinx.sdk.targetmanager.ui\/dialog_settings.xml
echo "file_to_replace=" $file_to_replace

 encodedurl=`
   echo $corrected_replacement_str2 | hexdump -v -e '1/1 "%02x\t"' -e '1/1 "%_c\n"' |
   LANG=C awk '
     $1 == "20"                    { printf("%s",   "+"); next } # space becomes plus
     $1 ~  /0[adAD]/               {                      next } # strip newlines
     $2 ~  /^[a-zA-Z0-9.*()\/-]$/  { printf("%s",   $2);  next } # pass through what we can
                                   { printf("%%%s", $1)        } # take hex value of everything else
   '`

echo "encodedurl= " $encodedurl
tclsh ../../../tsbs/common_scripts_library/tsb/ip/scripts/replace_line_in_file.tcl $file_to_replace 3 $encodedurl


# Replace line 4
echo on
bmm_path=$SCRIPTS_PWD\\..\\..\\..\\tsbs\\fmc1\\tsb\\ip\\rtl\\microblaze_mcs_v1_3_bd.bmm
echo "bmm_path =" $bmm_path
echo "corrected_elf_path=" $corrected_elf_path
replacement_str="<item value=\"$bmm_path\" key=\"spartan_microblaze_processor_adc_ctrl_fmc-bmmFile\"\/>"
echo "replacement_str = " $replacement_str
corrected_replacement_str=${replacement_str//\\/\/}
echo "corrected_replacement_str = " $corrected_replacement_str
corrected_replacement_str2=${corrected_replacement_str//\/\//\/}
echo "corrected_replacement_str2 = " $corrected_replacement_str2
file_to_replace=$SCRIPTS_PWD\/..\/..\/..\/tsbs\/fmc1\/tsb\/ip\/rtl\/workspace\/.metadata\/.plugins\/com.xilinx.sdk.targetmanager.ui\/dialog_settings.xml
echo "file_to_replace=" $file_to_replace

 encodedurl=`
   echo $corrected_replacement_str2 | hexdump -v -e '1/1 "%02x\t"' -e '1/1 "%_c\n"' |
   LANG=C awk '
     $1 == "20"                    { printf("%s",   "+"); next } # space becomes plus
     $1 ~  /0[adAD]/               {                      next } # strip newlines
     $2 ~  /^[a-zA-Z0-9.*()\/-]$/  { printf("%s",   $2);  next } # pass through what we can
                                   { printf("%%%s", $1)        } # take hex value of everything else
   '`

echo "encodedurl= " $encodedurl
tclsh ../../../tsbs/common_scripts_library/tsb/ip/scripts/replace_line_in_file.tcl $file_to_replace 4 $encodedurl


# Replace line 5
echo on
bit_path=$SCRIPTS_PWD\\..\\..\\..\\tsbs\\fmc1\\tsb\\ip\\exe\\fmc_out.bit
echo "bit_path =" $bit_path
echo "corrected_elf_path=" $corrected_elf_path
replacement_str="<item value=\"$bit_path\" key=\"spartan_microblaze_processor_adc_ctrl_fmc-bitFile\"\/>"
echo "replacement_str = " $replacement_str
corrected_replacement_str=${replacement_str//\\/\/}
echo "corrected_replacement_str = " $corrected_replacement_str
corrected_replacement_str2=${corrected_replacement_str//\/\//\/}
echo "corrected_replacement_str2 = " $corrected_replacement_str2
file_to_replace=$SCRIPTS_PWD\/..\/..\/..\/tsbs\/fmc1\/tsb\/ip\/rtl\/workspace\/.metadata\/.plugins\/com.xilinx.sdk.targetmanager.ui\/dialog_settings.xml
echo "file_to_replace=" $file_to_replace

 encodedurl=`
   echo $corrected_replacement_str2 | hexdump -v -e '1/1 "%02x\t"' -e '1/1 "%_c\n"' |
   LANG=C awk '
     $1 == "20"                    { printf("%s",   "+"); next } # space becomes plus
     $1 ~  /0[adAD]/               {                      next } # strip newlines
     $2 ~  /^[a-zA-Z0-9.*()\/-]$/  { printf("%s",   $2);  next } # pass through what we can
                                   { printf("%%%s", $1)        } # take hex value of everything else
   '`

echo "encodedurl= " $encodedurl
tclsh ../../../tsbs/common_scripts_library/tsb/ip/scripts/replace_line_in_file.tcl $file_to_replace 5 $encodedurl