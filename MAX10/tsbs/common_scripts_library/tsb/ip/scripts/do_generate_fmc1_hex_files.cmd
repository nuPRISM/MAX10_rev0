cd ../exe
$XILINX_TOOLS_PATH/bin/nt64/promgen  "$@" -u 0x0 fmc1_download.bit -o fmc1_download.mcs -p mcs
$XILINX_TOOLS_PATH/bin/nt64/promgen  "$@" -u 0x0 fmc1_download.bit -o fmc1_download_raw.hex -p hex
$XILINX_TOOLS_PATH/bin/nt64/promgen  "$@" -u 0x0 fmc1_download.bit -o fmc1_download_raw_bin.bin -p bin
cp fmc1_download.mcs  fmc1_download.hex
cd ../scripts