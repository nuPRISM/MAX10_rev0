
IMPACT_RETURN_CODE=1
until [ $IMPACT_RETURN_CODE -eq 0 ]; do
		"$XILINX_TOOLS_PATH/bin/nt64/impact.exe" -batch ../../../tsbs/common_scripts_library/tsb/ip/scripts/xilinx_load_fmc0_impact_script.cmd
		IMPACT_RETURN_CODE=$?
		echo "Impact Return code" $IMPACT_RETURN_CODE
done