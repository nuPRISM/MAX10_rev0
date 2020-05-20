setmode -bscan
setCable -p auto -b 19200

setPreference -pref UserLevel:expert
identify
assignfile -p 1 -file ../exe/fmc2_download.bit
program -p 1
quit
