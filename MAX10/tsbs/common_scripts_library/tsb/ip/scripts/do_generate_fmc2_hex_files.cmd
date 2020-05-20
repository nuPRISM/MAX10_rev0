cd ../exe
$XILINX_TOOLS_PATH/bin/nt64/promgen "$@"  -u 0x0 fmc2_download.bit -o fmc2_download.mcs -p mcs
$XILINX_TOOLS_PATH/bin/nt64/promgen "$@"  -u 0x0 fmc2_download.bit -o fmc2_download_raw.hex -p hex
$XILINX_TOOLS_PATH/bin/nt64/promgen "$@"  -u 0x0 fmc2_download.bit -o fmc2_download_raw_bin.bin -p bin
cp fmc2_download.mcs  fmc2_download.hex
cd ../scripts