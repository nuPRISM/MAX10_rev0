set_global_assignment -entity "lvds_tx_x2_m10" -library "lib_lvds_tx_x2_m10" -name IP_TOOL_NAME "altera_soft_lvds"
set_global_assignment -entity "lvds_tx_x2_m10" -library "lib_lvds_tx_x2_m10" -name IP_TOOL_VERSION "14.1"
set_global_assignment -entity "lvds_tx_x2_m10" -library "lib_lvds_tx_x2_m10" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_lvds_tx_x2_m10" -name SPD_FILE [file join $::quartus(sip_path) "lvds_tx_x2_m10.spd"]

set_global_assignment -library "lib_lvds_tx_x2_m10" -name MISC_FILE [file join $::quartus(sip_path) "lvds_tx_x2_m10_sim/lvds_tx_x2_m10.v"]
