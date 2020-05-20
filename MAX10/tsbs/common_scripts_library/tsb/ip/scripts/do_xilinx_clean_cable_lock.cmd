
IMPACT_RETURN_CODE=1
"$XILINX_TOOLS_PATH/bin/nt64/impact.exe" -batch ../../../tsbs/common_scripts_library/tsb/ip/scripts/xilinx_clean_cable_lock_impact_script.cmd
echo "cleaned cable lock, Impact Return code " $IMPACT_RETURN_CODE
