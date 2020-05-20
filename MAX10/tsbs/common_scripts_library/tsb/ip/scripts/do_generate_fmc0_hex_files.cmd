cd ../exe
$XILINX_TOOLS_PATH/bin/nt64/promgen "$@" -u 0x0 fmc0_download.bit -o fmc0_download.mcs -p mcs
$XILINX_TOOLS_PATH/bin/nt64/promgen "$@" -u 0x0 fmc0_download.bit -o fmc0_download_raw.hex -p hex
$XILINX_TOOLS_PATH/bin/nt64/promgen "$@" -u 0x0 fmc0_download.bit -o fmc0_download_raw_bin.bin -p bin
cp fmc0_download.mcs  fmc0_download.hex
cd ../scripts