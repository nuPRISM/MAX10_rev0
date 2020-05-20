SCRIPTS_PWD=$(pwd)
SCRIPTS_PWD=`cygpath -u $SCRIPTS_PWD`
CUT_SCRIPTS_PWD=${SCRIPTS_PWD#*/}
echo "CUT_SCRIPTS_PWD = " $CUT_SCRIPTS_PWD
CUT_SCRIPTS_PWD=${CUT_SCRIPTS_PWD#*/}
echo "CUT_SCRIPTS_PWD = " $CUT_SCRIPTS_PWD
CUT_SCRIPTS_PWD=${CUT_SCRIPTS_PWD#*/}
echo "CUT_SCRIPTS_PWD = " $CUT_SCRIPTS_PWD
CUT_SCRIPTS_PWD=/$CUT_SCRIPTS_PWD
echo "CUT_SCRIPTS_PWD = " $CUT_SCRIPTS_PWD
echo "Path = " $PATH
old_path=$PATH
XILINX_EDK_PATH=`cygpath -u $XILINX_TOOLS_PATH/../EDK`
XILINX_TOOLS_PATH_CYG=`cygpath -u $XILINX_TOOLS_PATH`
new_path=$XILINX_TOOLS_PATH_CYG/lib/nt64:$XILINX_TOOLS_PATH_CYG/bin/nt64:$XILINX_EDK_PATH/lib/nt64:$XILINX_EDK_PATH/gnu/microblaze/nt64/bin:$XILINX_EDK_PATH/gnu/powerpc-eabi/nt64/bin:$XILINX_EDK_PATH/gnuwin/bin:$XILINX_EDK_PATH/gnu/arm/nt/bin:$XILINX_EDK_PATH/gnu/microblaze/linux_toolchain/nt64_be/bin:$XILINX_EDK_PATH/gnu/microblaze/linux_toolchain/nt64_le/bin:$PATH

echo "New Path = " $new_path
export PATH=$new_path
echo on
echo "Now compiling Stratix Xilinx FMC2 Software Project..."
cd ../../../tsbs/fmc2/tsb/ip/rtl/workspace/standalone_bsp_0
make
cd $SCRIPTS_PWD
cd ../../../tsbs/fmc2/tsb/ip/rtl/workspace/adc_fmc_mcs_ctrl/Debug
make clean
make

# elfcheck -hw ../../spartan_microblaze_processor_adc_ctrl_fmc/system.xml \
# -mode bootload -mem BRAM -pe microblaze_mcs_v1_3 \
# adc_fmc_mcs_ctrl.elf 

data2mem -bm \
../../../microblaze_mcs_v1_3_bd.bmm -bt \
$CUT_SCRIPTS_PWD/../../../tsbs/fmc2/tsb/ip/exe/fmc_out.bit -bd \
adc_fmc_mcs_ctrl.elf tag microblaze_mcs_v1_3 -o b \
$CUT_SCRIPTS_PWD/../exe/fmc2_download.bit


cd $SCRIPTS_PWD
export PATH=$old_path
echo "Revert to old path = " $PATH

