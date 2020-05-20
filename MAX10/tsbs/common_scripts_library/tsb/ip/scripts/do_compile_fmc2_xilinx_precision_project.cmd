CURRPATH=`cygpath -u "$PRECISION_PATH/precision.exe"` 

"$CURRPATH" -rtlplus -nosplash -shell -file ../../../tsbs/common_scripts_library/tsb/ip/scripts/fmc2_precision_project_compile.tcl
source do_compile_xilinx_fmc2_software.cmd