module compact_registers_keeper
#( 
  parameter [31:0] STATUS_WIDTH    =8,
  parameter [31:0] CONTROL0_DEFAULT=0,
  parameter [31:0] CONTROL1_DEFAULT=0,
  parameter [31:0] CONTROL2_DEFAULT=0,
  parameter [31:0] CONTROL3_DEFAULT=0,
  parameter [31:0] CONTROL4_DEFAULT=0,
  parameter [31:0] CONTROL5_DEFAULT=0,
  parameter [31:0] CONTROL6_DEFAULT=0,
  parameter [31:0] CONTROL7_DEFAULT=0,
  parameter [31:0] CONTROL8_DEFAULT=0,
  parameter [31:0] CONTROL9_DEFAULT=0,
  parameter [31:0] CONTROLA_DEFAULT=0,
  parameter [31:0] CONTROLB_DEFAULT=0,
  parameter [31:0] CONTROLC_DEFAULT=0,
  parameter [31:0] CONTROLD_DEFAULT=0,
  parameter [31:0] CONTROLE_DEFAULT=0,
  parameter [31:0] CONTROLF_DEFAULT=0,
  parameter [31:0] CONTROL10_DEFAULT=0,
  parameter [31:0] CONTROL11_DEFAULT=0,
  parameter [31:0] CONTROL12_DEFAULT=0,
  parameter [31:0] CONTROL13_DEFAULT=0,
  parameter [31:0] CONTROL14_DEFAULT=0,
  parameter [31:0] CONTROL15_DEFAULT=0,
  parameter [31:0] CONTROL16_DEFAULT=0,
  parameter [31:0] CONTROL17_DEFAULT=0,
  parameter [31:0] CONTROL18_DEFAULT=0,
  parameter [31:0] CONTROL19_DEFAULT=0,
  parameter [31:0] CONTROL1A_DEFAULT=0,
  parameter [31:0] CONTROL1B_DEFAULT=0,
  parameter [31:0] CONTROL1C_DEFAULT=0,
  parameter [31:0] CONTROL1D_DEFAULT=0,
  parameter [31:0] CONTROL1E_DEFAULT=0,
  parameter [31:0] CONTROL1F_DEFAULT=0,
  parameter [31:0] CONTROL20_DEFAULT=0,
  parameter [31:0] CONTROL21_DEFAULT=0,
  parameter [31:0] CONTROL22_DEFAULT=0,
  parameter [31:0] CONTROL23_DEFAULT=0,
  parameter [31:0] CONTROL24_DEFAULT=0,
  parameter [31:0] CONTROL25_DEFAULT=0,
  parameter [31:0] CONTROL26_DEFAULT=0,
  parameter [31:0] CONTROL27_DEFAULT=0,
  parameter [31:0] CONTROL28_DEFAULT=0,
  parameter [31:0] CONTROL29_DEFAULT=0,
  parameter [31:0] CONTROL2A_DEFAULT=0,
  parameter [31:0] CONTROL2B_DEFAULT=0,
  parameter [31:0] CONTROL2C_DEFAULT=0,
  parameter [31:0] CONTROL2D_DEFAULT=0,
  parameter [31:0] CONTROL2E_DEFAULT=0,
  parameter [31:0] CONTROL2F_DEFAULT=0,
  parameter [31:0] CONTROL30_DEFAULT=0,
  parameter [31:0] CONTROL31_DEFAULT=0,
  parameter [31:0] CONTROL32_DEFAULT=0,
  parameter [31:0] CONTROL33_DEFAULT=0,
  parameter [31:0] CONTROL34_DEFAULT=0,
  parameter [31:0] CONTROL35_DEFAULT=0,
  parameter [31:0] CONTROL36_DEFAULT=0,
  parameter [31:0] CONTROL37_DEFAULT=0,
  parameter [31:0] CONTROL38_DEFAULT=0,
  parameter [31:0] CONTROL39_DEFAULT=0,
  parameter [31:0] CONTROL3A_DEFAULT=0,
  parameter [31:0] CONTROL3B_DEFAULT=0,
  parameter [31:0] CONTROL3C_DEFAULT=0,
  parameter [31:0] CONTROL3D_DEFAULT=0,
  parameter [31:0] CONTROL3E_DEFAULT=0,
  parameter [31:0] CONTROL3F_DEFAULT=0,
  parameter [31:0] CONTROL40_DEFAULT=0,
  parameter [31:0] CONTROL41_DEFAULT=0,
  parameter [31:0] CONTROL42_DEFAULT=0,
  parameter [31:0] CONTROL43_DEFAULT=0,
  parameter [31:0] CONTROL44_DEFAULT=0,
  parameter [31:0] CONTROL45_DEFAULT=0,
  parameter [31:0] CONTROL46_DEFAULT=0,
  parameter [31:0] CONTROL47_DEFAULT=0,
  parameter [31:0] CONTROL48_DEFAULT=0,
  parameter [31:0] CONTROL49_DEFAULT=0,
  parameter [31:0] CONTROL4A_DEFAULT=0,
  parameter [31:0] CONTROL4B_DEFAULT=0,
  parameter [31:0] CONTROL4C_DEFAULT=0,
  parameter [31:0] CONTROL4D_DEFAULT=0,
  parameter [31:0] CONTROL4E_DEFAULT=0,
  parameter [31:0] CONTROL4F_DEFAULT=0,
  parameter [31:0] CONTROL50_DEFAULT=0,
  parameter [31:0] CONTROL51_DEFAULT=0,
  parameter [31:0] CONTROL52_DEFAULT=0,
  parameter [31:0] CONTROL53_DEFAULT=0,
  parameter [31:0] CONTROL54_DEFAULT=0,
  parameter [31:0] CONTROL55_DEFAULT=0,
  parameter [31:0] CONTROL56_DEFAULT=0,
  parameter [31:0] CONTROL57_DEFAULT=0,
  parameter [31:0] CONTROL58_DEFAULT=0,
  parameter [31:0] CONTROL59_DEFAULT=0,
  parameter [31:0] CONTROL5A_DEFAULT=0,
  parameter [31:0] CONTROL5B_DEFAULT=0,
  parameter [31:0] CONTROL5C_DEFAULT=0,
  parameter [31:0] CONTROL5D_DEFAULT=0,
  parameter [31:0] CONTROL5E_DEFAULT=0,
  parameter [31:0] CONTROL5F_DEFAULT=0,
  
  parameter [31:0] CONTROL60_DEFAULT=0,
  parameter [31:0] CONTROL61_DEFAULT=0,
  parameter [31:0] CONTROL62_DEFAULT=0,
  parameter [31:0] CONTROL63_DEFAULT=0,
  parameter [31:0] CONTROL64_DEFAULT=0,
  parameter [31:0] CONTROL65_DEFAULT=0,
  parameter [31:0] CONTROL66_DEFAULT=0,
  parameter [31:0] CONTROL67_DEFAULT=0,
  parameter [31:0] CONTROL68_DEFAULT=0,
  parameter [31:0] CONTROL69_DEFAULT=0,
  parameter [31:0] CONTROL6A_DEFAULT=0,
  parameter [31:0] CONTROL6B_DEFAULT=0,
  parameter [31:0] CONTROL6C_DEFAULT=0,
  parameter [31:0] CONTROL6D_DEFAULT=0,
  parameter [31:0] CONTROL6E_DEFAULT=0,
  parameter [31:0] CONTROL6F_DEFAULT=0,
  parameter [31:0] CONTROL70_DEFAULT=0,
  parameter [31:0] CONTROL71_DEFAULT=0,
  parameter [31:0] CONTROL72_DEFAULT=0,
  parameter [31:0] CONTROL73_DEFAULT=0,
  parameter [31:0] CONTROL74_DEFAULT=0,
  parameter [31:0] CONTROL75_DEFAULT=0,
  parameter [31:0] CONTROL76_DEFAULT=0,
  parameter [31:0] CONTROL77_DEFAULT=0,
  parameter [31:0] CONTROL78_DEFAULT=0,
  parameter [31:0] CONTROL79_DEFAULT=0,
  parameter [31:0] CONTROL7A_DEFAULT=0,
  parameter [31:0] CONTROL7B_DEFAULT=0,
  parameter [31:0] CONTROL7C_DEFAULT=0,
  parameter [31:0] CONTROL7D_DEFAULT=0,
  parameter [31:0] CONTROL7E_DEFAULT=0,
  parameter [31:0] CONTROL7F_DEFAULT=0,
  parameter [31:0] CONTROL80_DEFAULT=0,
  parameter [31:0] CONTROL81_DEFAULT=0,
  parameter [31:0] CONTROL82_DEFAULT=0,
  parameter [31:0] CONTROL83_DEFAULT=0,
  parameter [31:0] CONTROL84_DEFAULT=0,
  parameter [31:0] CONTROL85_DEFAULT=0,
  parameter [31:0] CONTROL86_DEFAULT=0,
  parameter [31:0] CONTROL87_DEFAULT=0,
  parameter [31:0] CONTROL88_DEFAULT=0,
  parameter [31:0] CONTROL89_DEFAULT=0,
  parameter [31:0] CONTROL8A_DEFAULT=0,
  parameter [31:0] CONTROL8B_DEFAULT=0,
  parameter [31:0] CONTROL8C_DEFAULT=0,
  parameter [31:0] CONTROL8D_DEFAULT=0,
  parameter [31:0] CONTROL8E_DEFAULT=0,
  parameter [31:0] CONTROL8F_DEFAULT=0,
  parameter [31:0] CONTROL90_DEFAULT=0,
  parameter [31:0] CONTROL91_DEFAULT=0,
  parameter [31:0] CONTROL92_DEFAULT=0,
  parameter [31:0] CONTROL93_DEFAULT=0,
  parameter [31:0] CONTROL94_DEFAULT=0,
  parameter [31:0] CONTROL95_DEFAULT=0,
  parameter [31:0] CONTROL96_DEFAULT=0,
  parameter [31:0] CONTROL97_DEFAULT=0,
  parameter [31:0] CONTROL98_DEFAULT=0,
  parameter [31:0] CONTROL99_DEFAULT=0,
  parameter [31:0] CONTROL9A_DEFAULT=0,
  parameter [31:0] CONTROL9B_DEFAULT=0,
  parameter [31:0] CONTROL9C_DEFAULT=0,
  parameter [31:0] CONTROL9D_DEFAULT=0,
  parameter [31:0] CONTROL9E_DEFAULT=0,
  parameter [31:0] CONTROL9F_DEFAULT=0,
  parameter [31:0] CONTROLA0_DEFAULT=0,
  parameter [31:0] CONTROLA1_DEFAULT=0,
  parameter [31:0] CONTROLA2_DEFAULT=0,
  parameter [31:0] CONTROLA3_DEFAULT=0,
  parameter [31:0] CONTROLA4_DEFAULT=0,
  parameter [31:0] CONTROLA5_DEFAULT=0,
  parameter [31:0] CONTROLA6_DEFAULT=0,
  parameter [31:0] CONTROLA7_DEFAULT=0,
  parameter [31:0] CONTROLA8_DEFAULT=0,
  parameter [31:0] CONTROLA9_DEFAULT=0,
  parameter [31:0] CONTROLAA_DEFAULT=0,
  parameter [31:0] CONTROLAB_DEFAULT=0,
  parameter [31:0] CONTROLAC_DEFAULT=0,
  parameter [31:0] CONTROLAD_DEFAULT=0,
  parameter [31:0] CONTROLAE_DEFAULT=0,
  parameter [31:0] CONTROLAF_DEFAULT=0,
  
  parameter [31:0] CONTROL0_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL1_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL2_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL3_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL4_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL5_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL6_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL7_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL8_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL9_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROLA_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROLB_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROLC_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROLD_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROLE_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROLF_ACTUAL_BITWIDTH= 8,
  parameter [31:0] CONTROL10_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL11_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL12_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL13_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL14_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL15_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL16_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL17_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL18_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL19_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL1A_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL1B_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL1C_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL1D_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL1E_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL1F_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL20_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL21_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL22_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL23_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL24_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL25_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL26_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL27_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL28_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL29_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL2A_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL2B_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL2C_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL2D_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL2E_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL2F_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL30_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL31_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL32_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL33_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL34_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL35_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL36_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL37_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL38_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL39_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL3A_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL3B_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL3C_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL3D_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL3E_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL3F_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL40_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL41_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL42_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL43_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL44_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL45_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL46_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL47_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL48_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL49_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL4A_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL4B_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL4C_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL4D_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL4E_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL4F_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL50_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL51_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL52_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL53_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL54_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL55_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL56_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL57_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL58_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL59_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL5A_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL5B_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL5C_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL5D_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL5E_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL5F_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL60_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL61_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL62_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL63_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL64_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL65_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL66_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL67_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL68_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL69_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL6A_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL6B_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL6C_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL6D_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL6E_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL6F_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL70_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL71_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL72_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL73_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL74_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL75_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL76_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL77_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL78_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL79_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL7A_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL7B_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL7C_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL7D_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL7E_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL7F_ACTUAL_BITWIDTH=8,
  parameter [31:0] CONTROL80_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL81_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL82_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL83_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL84_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL85_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL86_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL87_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL88_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL89_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL8A_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL8B_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL8C_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL8D_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL8E_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL8F_ACTUAL_BITWIDTH=1, 
  parameter [31:0] CONTROL90_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL91_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL92_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL93_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL94_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL95_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL96_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL97_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL98_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL99_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL9A_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL9B_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL9C_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL9D_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL9E_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROL9F_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA0_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA1_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA2_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA3_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA4_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA5_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA6_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA7_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA8_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLA9_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLAA_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLAB_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLAC_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLAD_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLAE_ACTUAL_BITWIDTH=1,
  parameter [31:0] CONTROLAF_ACTUAL_BITWIDTH=1
  
)
(
						
						//Inout legs
						DATA,				
						ADDRESS,
						CLK,
						ACTIVE_LOW_READ_LD_RESET,
						WRITE_ST,
						READ_ST,
						READ_LD,
						CONTROL0,
						CONTROL1,
						CONTROL2,
						CONTROL3,
						CONTROL4,
						CONTROL5,
						CONTROL6,
						CONTROL7,
						CONTROL8,
						CONTROL9,
						CONTROLA,
						CONTROLB,
						CONTROLC,
						CONTROLD,
						CONTROLE,
						CONTROLF,
						CONTROL10,
						CONTROL11,
						CONTROL12,
						CONTROL13,
						CONTROL14,
						CONTROL15,
						CONTROL16,
						CONTROL17,
						CONTROL18,
						CONTROL19,
						CONTROL1A,
						CONTROL1B,
						CONTROL1C,
						CONTROL1D,
						CONTROL1E,
						CONTROL1F,
						CONTROL20,
						CONTROL21,
						CONTROL22,
						CONTROL23,
						CONTROL24,
						CONTROL25,
						CONTROL26,
						CONTROL27,
						CONTROL28,
						CONTROL29,
						CONTROL2A,
						CONTROL2B,
						CONTROL2C,
						CONTROL2D,
						CONTROL2E,
						CONTROL2F,
						CONTROL30,
						CONTROL31,
						CONTROL32,
						CONTROL33,
						CONTROL34,
						CONTROL35,
						CONTROL36,
						CONTROL37,
						CONTROL38,
						CONTROL39,
						CONTROL3A,
						CONTROL3B,
						CONTROL3C,
						CONTROL3D,
						CONTROL3E,
						CONTROL3F,	
						CONTROL40,
						CONTROL41,
						CONTROL42,
						CONTROL43,
						CONTROL44,
						CONTROL45,
						CONTROL46,
						CONTROL47,
						CONTROL48,
						CONTROL49,
						CONTROL4A,
						CONTROL4B,
						CONTROL4C,
						CONTROL4D,
						CONTROL4E,
						CONTROL4F,
						CONTROL50,
						CONTROL51,
						CONTROL52,
						CONTROL53,
						CONTROL54,
						CONTROL55,
						CONTROL56,
						CONTROL57,
						CONTROL58,
						CONTROL59,
						CONTROL5A,
						CONTROL5B,
						CONTROL5C,
						CONTROL5D,
						CONTROL5E,
						CONTROL5F,
						CONTROL60,
						CONTROL61,
						CONTROL62,
						CONTROL63,
						CONTROL64,
						CONTROL65,
						CONTROL66,
						CONTROL67,
						CONTROL68,
						CONTROL69,
						CONTROL6A,
						CONTROL6B,
						CONTROL6C,
						CONTROL6D,
						CONTROL6E,
						CONTROL6F,
						CONTROL70,
						CONTROL71,
						CONTROL72,
						CONTROL73,
						CONTROL74,
						CONTROL75,
						CONTROL76,
						CONTROL77,
						CONTROL78,
						CONTROL79,
						CONTROL7A,
						CONTROL7B,
						CONTROL7C,
						CONTROL7D,
						CONTROL7E,
						CONTROL7F,
						CONTROL80,
						CONTROL81,
						CONTROL82,
						CONTROL83,
						CONTROL84,
						CONTROL85,
						CONTROL86,
						CONTROL87,
						CONTROL88,
						CONTROL89,
						CONTROL8A,
						CONTROL8B,
						CONTROL8C,
						CONTROL8D,
						CONTROL8E,
						CONTROL8F,
						
						CONTROL90,
						CONTROL91,
						CONTROL92,
						CONTROL93,
						CONTROL94,
						CONTROL95,
						CONTROL96,
						CONTROL97,
						CONTROL98,
						CONTROL99,
						CONTROL9A,
						CONTROL9B,
						CONTROL9C,
						CONTROL9D,
						CONTROL9E,
						CONTROL9F,
						CONTROLA0,
						CONTROLA1,
						CONTROLA2,
						CONTROLA3,
						CONTROLA4,
						CONTROLA5,
						CONTROLA6,
						CONTROLA7,
						CONTROLA8,
						CONTROLA9,
						CONTROLAA,
						CONTROLAB,
						CONTROLAC,
						CONTROLAD,
						CONTROLAE,
						CONTROLAF,
						
						STATUS0,
						STATUS1,
						STATUS2,
						STATUS3,
						STATUS4,
						STATUS5,
						STATUS6,
						STATUS7,
						STATUS8,
						STATUS9,
						STATUSA,
						STATUSB,
						STATUSC,
						STATUSD,
						STATUSE,
						STATUSF,
						STATUS10,
						STATUS11,
						STATUS12,
						STATUS13,
						STATUS14,
						STATUS15,
						STATUS16,
						STATUS17,
						STATUS18,
						STATUS19,
						STATUS1A,
						STATUS1B,
						STATUS1C,
						STATUS1D,
						STATUS1E,
						STATUS1F,
						STATUS20,
						STATUS21,
						STATUS22,
						STATUS23,
						STATUS24,
						STATUS25,
						STATUS26,
						STATUS27,
						STATUS28,
						STATUS29,
						STATUS2A,
						STATUS2B,
						STATUS2C,
						STATUS2D,
						STATUS2E,
						STATUS2F,
						STATUS30,
						STATUS31,
						STATUS32,
						STATUS33,
						STATUS34,
						STATUS35,
						STATUS36,
						STATUS37,
						STATUS38,
						STATUS39,
						STATUS3A,
						STATUS3B,
						STATUS3C,
						STATUS3D,
						STATUS3E,
						STATUS3F
						);

//`include "DEFAULT_REGISTER_VALUES.v"

						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) input wire [STATUS_WIDTH-1:0] STATUS0,
				STATUS1,
				STATUS2,
				STATUS3,
				STATUS4,
				STATUS5,
				STATUS6,
				STATUS7,
				STATUS8,
				STATUS9,
				STATUSA,
				STATUSB,
				STATUSC,
				STATUSD,
				STATUSE,
				STATUSF;

(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) input wire [STATUS_WIDTH-1:0] 
        STATUS10,
		STATUS11,
		STATUS12,
		STATUS13,
		STATUS14,
		STATUS15,
		STATUS16,
		STATUS17,
		STATUS18,
		STATUS19,
		STATUS1A,
		STATUS1B,
		STATUS1C,
		STATUS1D,
		STATUS1E,
		STATUS1F;	
		
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) input wire [STATUS_WIDTH-1:0] 
                STATUS20,
				STATUS21,
				STATUS22,
				STATUS23,
				STATUS24,
				STATUS25,
				STATUS26,
				STATUS27,
				STATUS28,
				STATUS29,
				STATUS2A,
				STATUS2B,
				STATUS2C,
				STATUS2D,
				STATUS2E,
				STATUS2F;
				
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) input wire [STATUS_WIDTH-1:0] 
                STATUS30,
				STATUS31,
				STATUS32,
				STATUS33,
				STATUS34,
				STATUS35,
				STATUS36,
				STATUS37,
				STATUS38,
				STATUS39,
				STATUS3A,
				STATUS3B,
				STATUS3C,
				STATUS3D,
				STATUS3E,
				STATUS3F;

				
						

			
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output	reg [31:0]	    CONTROL0=CONTROL0_DEFAULT;
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL1_ACTUAL_BITWIDTH-1:0] CONTROL1 = CONTROL1_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL2_ACTUAL_BITWIDTH-1:0] CONTROL2 = CONTROL2_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL3_ACTUAL_BITWIDTH-1:0] CONTROL3 = CONTROL3_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL4_ACTUAL_BITWIDTH-1:0] CONTROL4 = CONTROL4_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL5_ACTUAL_BITWIDTH-1:0] CONTROL5 = CONTROL5_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL6_ACTUAL_BITWIDTH-1:0] CONTROL6 = CONTROL6_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL7_ACTUAL_BITWIDTH-1:0] CONTROL7 = CONTROL7_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL8_ACTUAL_BITWIDTH-1:0] CONTROL8 = CONTROL8_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL9_ACTUAL_BITWIDTH-1:0] CONTROL9 = CONTROL9_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA_ACTUAL_BITWIDTH-1:0] CONTROLA = CONTROLA_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLB_ACTUAL_BITWIDTH-1:0] CONTROLB = CONTROLB_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLC_ACTUAL_BITWIDTH-1:0] CONTROLC = CONTROLC_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLD_ACTUAL_BITWIDTH-1:0] CONTROLD = CONTROLD_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLE_ACTUAL_BITWIDTH-1:0] CONTROLE = CONTROLE_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLF_ACTUAL_BITWIDTH-1:0] CONTROLF = CONTROLF_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL10_ACTUAL_BITWIDTH-1:0] CONTROL10 = CONTROL10_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL11_ACTUAL_BITWIDTH-1:0] CONTROL11 = CONTROL11_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL12_ACTUAL_BITWIDTH-1:0] CONTROL12 = CONTROL12_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL13_ACTUAL_BITWIDTH-1:0] CONTROL13 = CONTROL13_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL14_ACTUAL_BITWIDTH-1:0] CONTROL14 = CONTROL14_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL15_ACTUAL_BITWIDTH-1:0] CONTROL15 = CONTROL15_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL16_ACTUAL_BITWIDTH-1:0] CONTROL16 = CONTROL16_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL17_ACTUAL_BITWIDTH-1:0] CONTROL17 = CONTROL17_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL18_ACTUAL_BITWIDTH-1:0] CONTROL18 = CONTROL18_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL19_ACTUAL_BITWIDTH-1:0] CONTROL19 = CONTROL19_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL1A_ACTUAL_BITWIDTH-1:0] CONTROL1A = CONTROL1A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL1B_ACTUAL_BITWIDTH-1:0] CONTROL1B = CONTROL1B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL1C_ACTUAL_BITWIDTH-1:0] CONTROL1C = CONTROL1C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL1D_ACTUAL_BITWIDTH-1:0] CONTROL1D = CONTROL1D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL1E_ACTUAL_BITWIDTH-1:0] CONTROL1E = CONTROL1E_DEFAULT;
					    (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL1F_ACTUAL_BITWIDTH-1:0] CONTROL1F = CONTROL1F_DEFAULT;
						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output	reg [31:0]		CONTROL20=CONTROL20_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL21_ACTUAL_BITWIDTH-1:0] CONTROL21 = CONTROL21_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL22_ACTUAL_BITWIDTH-1:0] CONTROL22 = CONTROL22_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL23_ACTUAL_BITWIDTH-1:0] CONTROL23 = CONTROL23_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL24_ACTUAL_BITWIDTH-1:0] CONTROL24 = CONTROL24_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL25_ACTUAL_BITWIDTH-1:0] CONTROL25 = CONTROL25_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL26_ACTUAL_BITWIDTH-1:0] CONTROL26 = CONTROL26_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL27_ACTUAL_BITWIDTH-1:0] CONTROL27 = CONTROL27_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL28_ACTUAL_BITWIDTH-1:0] CONTROL28 = CONTROL28_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL29_ACTUAL_BITWIDTH-1:0] CONTROL29 = CONTROL29_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL2A_ACTUAL_BITWIDTH-1:0] CONTROL2A = CONTROL2A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL2B_ACTUAL_BITWIDTH-1:0] CONTROL2B = CONTROL2B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL2C_ACTUAL_BITWIDTH-1:0] CONTROL2C = CONTROL2C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL2D_ACTUAL_BITWIDTH-1:0] CONTROL2D = CONTROL2D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL2E_ACTUAL_BITWIDTH-1:0] CONTROL2E = CONTROL2E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL2F_ACTUAL_BITWIDTH-1:0] CONTROL2F = CONTROL2F_DEFAULT;

                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL30_ACTUAL_BITWIDTH-1:0] CONTROL30 = CONTROL30_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL31_ACTUAL_BITWIDTH-1:0] CONTROL31 = CONTROL31_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL32_ACTUAL_BITWIDTH-1:0] CONTROL32 = CONTROL32_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL33_ACTUAL_BITWIDTH-1:0] CONTROL33 = CONTROL33_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL34_ACTUAL_BITWIDTH-1:0] CONTROL34 = CONTROL34_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL35_ACTUAL_BITWIDTH-1:0] CONTROL35 = CONTROL35_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL36_ACTUAL_BITWIDTH-1:0] CONTROL36 = CONTROL36_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL37_ACTUAL_BITWIDTH-1:0] CONTROL37 = CONTROL37_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL38_ACTUAL_BITWIDTH-1:0] CONTROL38 = CONTROL38_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL39_ACTUAL_BITWIDTH-1:0] CONTROL39 = CONTROL39_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL3A_ACTUAL_BITWIDTH-1:0] CONTROL3A = CONTROL3A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL3B_ACTUAL_BITWIDTH-1:0] CONTROL3B = CONTROL3B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL3C_ACTUAL_BITWIDTH-1:0] CONTROL3C = CONTROL3C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL3D_ACTUAL_BITWIDTH-1:0] CONTROL3D = CONTROL3D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL3E_ACTUAL_BITWIDTH-1:0] CONTROL3E = CONTROL3E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL3F_ACTUAL_BITWIDTH-1:0] CONTROL3F = CONTROL3F_DEFAULT;
						
						
	(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL40_ACTUAL_BITWIDTH-1:0] CONTROL40 = CONTROL40_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL41_ACTUAL_BITWIDTH-1:0] CONTROL41 = CONTROL41_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL42_ACTUAL_BITWIDTH-1:0] CONTROL42 = CONTROL42_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL43_ACTUAL_BITWIDTH-1:0] CONTROL43 = CONTROL43_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL44_ACTUAL_BITWIDTH-1:0] CONTROL44 = CONTROL44_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL45_ACTUAL_BITWIDTH-1:0] CONTROL45 = CONTROL45_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL46_ACTUAL_BITWIDTH-1:0] CONTROL46 = CONTROL46_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL47_ACTUAL_BITWIDTH-1:0] CONTROL47 = CONTROL47_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL48_ACTUAL_BITWIDTH-1:0] CONTROL48 = CONTROL48_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL49_ACTUAL_BITWIDTH-1:0] CONTROL49 = CONTROL49_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL4A_ACTUAL_BITWIDTH-1:0] CONTROL4A = CONTROL4A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL4B_ACTUAL_BITWIDTH-1:0] CONTROL4B = CONTROL4B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL4C_ACTUAL_BITWIDTH-1:0] CONTROL4C = CONTROL4C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL4D_ACTUAL_BITWIDTH-1:0] CONTROL4D = CONTROL4D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL4E_ACTUAL_BITWIDTH-1:0] CONTROL4E = CONTROL4E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL4F_ACTUAL_BITWIDTH-1:0] CONTROL4F = CONTROL4F_DEFAULT;
						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL50_ACTUAL_BITWIDTH-1:0] CONTROL50 = CONTROL50_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL51_ACTUAL_BITWIDTH-1:0] CONTROL51 = CONTROL51_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL52_ACTUAL_BITWIDTH-1:0] CONTROL52 = CONTROL52_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL53_ACTUAL_BITWIDTH-1:0] CONTROL53 = CONTROL53_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL54_ACTUAL_BITWIDTH-1:0] CONTROL54 = CONTROL54_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL55_ACTUAL_BITWIDTH-1:0] CONTROL55 = CONTROL55_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL56_ACTUAL_BITWIDTH-1:0] CONTROL56 = CONTROL56_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL57_ACTUAL_BITWIDTH-1:0] CONTROL57 = CONTROL57_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL58_ACTUAL_BITWIDTH-1:0] CONTROL58 = CONTROL58_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL59_ACTUAL_BITWIDTH-1:0] CONTROL59 = CONTROL59_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL5A_ACTUAL_BITWIDTH-1:0] CONTROL5A = CONTROL5A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL5B_ACTUAL_BITWIDTH-1:0] CONTROL5B = CONTROL5B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL5C_ACTUAL_BITWIDTH-1:0] CONTROL5C = CONTROL5C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL5D_ACTUAL_BITWIDTH-1:0] CONTROL5D = CONTROL5D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL5E_ACTUAL_BITWIDTH-1:0] CONTROL5E = CONTROL5E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL5F_ACTUAL_BITWIDTH-1:0] CONTROL5F = CONTROL5F_DEFAULT;
						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL60_ACTUAL_BITWIDTH-1:0] CONTROL60 = CONTROL60_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL61_ACTUAL_BITWIDTH-1:0] CONTROL61 = CONTROL61_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL62_ACTUAL_BITWIDTH-1:0] CONTROL62 = CONTROL62_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL63_ACTUAL_BITWIDTH-1:0] CONTROL63 = CONTROL63_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL64_ACTUAL_BITWIDTH-1:0] CONTROL64 = CONTROL64_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL65_ACTUAL_BITWIDTH-1:0] CONTROL65 = CONTROL65_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL66_ACTUAL_BITWIDTH-1:0] CONTROL66 = CONTROL66_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL67_ACTUAL_BITWIDTH-1:0] CONTROL67 = CONTROL67_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL68_ACTUAL_BITWIDTH-1:0] CONTROL68 = CONTROL68_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL69_ACTUAL_BITWIDTH-1:0] CONTROL69 = CONTROL69_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL6A_ACTUAL_BITWIDTH-1:0] CONTROL6A = CONTROL6A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL6B_ACTUAL_BITWIDTH-1:0] CONTROL6B = CONTROL6B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL6C_ACTUAL_BITWIDTH-1:0] CONTROL6C = CONTROL6C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL6D_ACTUAL_BITWIDTH-1:0] CONTROL6D = CONTROL6D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL6E_ACTUAL_BITWIDTH-1:0] CONTROL6E = CONTROL6E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL6F_ACTUAL_BITWIDTH-1:0] CONTROL6F = CONTROL6F_DEFAULT;
						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL70_ACTUAL_BITWIDTH-1:0] CONTROL70 = CONTROL70_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL71_ACTUAL_BITWIDTH-1:0] CONTROL71 = CONTROL71_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL72_ACTUAL_BITWIDTH-1:0] CONTROL72 = CONTROL72_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL73_ACTUAL_BITWIDTH-1:0] CONTROL73 = CONTROL73_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL74_ACTUAL_BITWIDTH-1:0] CONTROL74 = CONTROL74_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL75_ACTUAL_BITWIDTH-1:0] CONTROL75 = CONTROL75_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL76_ACTUAL_BITWIDTH-1:0] CONTROL76 = CONTROL76_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL77_ACTUAL_BITWIDTH-1:0] CONTROL77 = CONTROL77_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL78_ACTUAL_BITWIDTH-1:0] CONTROL78 = CONTROL78_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL79_ACTUAL_BITWIDTH-1:0] CONTROL79 = CONTROL79_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL7A_ACTUAL_BITWIDTH-1:0] CONTROL7A = CONTROL7A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL7B_ACTUAL_BITWIDTH-1:0] CONTROL7B = CONTROL7B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL7C_ACTUAL_BITWIDTH-1:0] CONTROL7C = CONTROL7C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL7D_ACTUAL_BITWIDTH-1:0] CONTROL7D = CONTROL7D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL7E_ACTUAL_BITWIDTH-1:0] CONTROL7E = CONTROL7E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL7F_ACTUAL_BITWIDTH-1:0] CONTROL7F = CONTROL7F_DEFAULT;
						
						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL80_ACTUAL_BITWIDTH-1:0] CONTROL80 = CONTROL80_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL81_ACTUAL_BITWIDTH-1:0] CONTROL81 = CONTROL81_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL82_ACTUAL_BITWIDTH-1:0] CONTROL82 = CONTROL82_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL83_ACTUAL_BITWIDTH-1:0] CONTROL83 = CONTROL83_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL84_ACTUAL_BITWIDTH-1:0] CONTROL84 = CONTROL84_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL85_ACTUAL_BITWIDTH-1:0] CONTROL85 = CONTROL85_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL86_ACTUAL_BITWIDTH-1:0] CONTROL86 = CONTROL86_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL87_ACTUAL_BITWIDTH-1:0] CONTROL87 = CONTROL87_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL88_ACTUAL_BITWIDTH-1:0] CONTROL88 = CONTROL88_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL89_ACTUAL_BITWIDTH-1:0] CONTROL89 = CONTROL89_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL8A_ACTUAL_BITWIDTH-1:0] CONTROL8A = CONTROL8A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL8B_ACTUAL_BITWIDTH-1:0] CONTROL8B = CONTROL8B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL8C_ACTUAL_BITWIDTH-1:0] CONTROL8C = CONTROL8C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL8D_ACTUAL_BITWIDTH-1:0] CONTROL8D = CONTROL8D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL8E_ACTUAL_BITWIDTH-1:0] CONTROL8E = CONTROL8E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL8F_ACTUAL_BITWIDTH-1:0] CONTROL8F = CONTROL8F_DEFAULT;
						
						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL90_ACTUAL_BITWIDTH-1:0] CONTROL90 = CONTROL90_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL91_ACTUAL_BITWIDTH-1:0] CONTROL91 = CONTROL91_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL92_ACTUAL_BITWIDTH-1:0] CONTROL92 = CONTROL92_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL93_ACTUAL_BITWIDTH-1:0] CONTROL93 = CONTROL93_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL94_ACTUAL_BITWIDTH-1:0] CONTROL94 = CONTROL94_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL95_ACTUAL_BITWIDTH-1:0] CONTROL95 = CONTROL95_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL96_ACTUAL_BITWIDTH-1:0] CONTROL96 = CONTROL96_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL97_ACTUAL_BITWIDTH-1:0] CONTROL97 = CONTROL97_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL98_ACTUAL_BITWIDTH-1:0] CONTROL98 = CONTROL98_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL99_ACTUAL_BITWIDTH-1:0] CONTROL99 = CONTROL99_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL9A_ACTUAL_BITWIDTH-1:0] CONTROL9A = CONTROL9A_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL9B_ACTUAL_BITWIDTH-1:0] CONTROL9B = CONTROL9B_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL9C_ACTUAL_BITWIDTH-1:0] CONTROL9C = CONTROL9C_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL9D_ACTUAL_BITWIDTH-1:0] CONTROL9D = CONTROL9D_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL9E_ACTUAL_BITWIDTH-1:0] CONTROL9E = CONTROL9E_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROL9F_ACTUAL_BITWIDTH-1:0] CONTROL9F = CONTROL9F_DEFAULT;
						
						
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA0_ACTUAL_BITWIDTH-1:0] CONTROLA0 = CONTROLA0_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA1_ACTUAL_BITWIDTH-1:0] CONTROLA1 = CONTROLA1_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA2_ACTUAL_BITWIDTH-1:0] CONTROLA2 = CONTROLA2_DEFAULT;		
            			(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA3_ACTUAL_BITWIDTH-1:0] CONTROLA3 = CONTROLA3_DEFAULT;
                        (* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA4_ACTUAL_BITWIDTH-1:0] CONTROLA4 = CONTROLA4_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA5_ACTUAL_BITWIDTH-1:0] CONTROLA5 = CONTROLA5_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA6_ACTUAL_BITWIDTH-1:0] CONTROLA6 = CONTROLA6_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA7_ACTUAL_BITWIDTH-1:0] CONTROLA7 = CONTROLA7_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA8_ACTUAL_BITWIDTH-1:0] CONTROLA8 = CONTROLA8_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLA9_ACTUAL_BITWIDTH-1:0] CONTROLA9 = CONTROLA9_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLAA_ACTUAL_BITWIDTH-1:0] CONTROLAA = CONTROLAA_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLAB_ACTUAL_BITWIDTH-1:0] CONTROLAB = CONTROLAB_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLAC_ACTUAL_BITWIDTH-1:0] CONTROLAC = CONTROLAC_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLAD_ACTUAL_BITWIDTH-1:0] CONTROLAD = CONTROLAD_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLAE_ACTUAL_BITWIDTH-1:0] CONTROLAE = CONTROLAE_DEFAULT;
						(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *) output reg [CONTROLAF_ACTUAL_BITWIDTH-1:0] CONTROLAF = CONTROLAF_DEFAULT;

(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *)output reg  [31:0]				READ_LD;
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *)input  wire [31:0]				DATA;
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *)input  wire [8:0]				ADDRESS;
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *)input  wire 					    CLK;
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *)input  wire 					    ACTIVE_LOW_READ_LD_RESET;
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *)input  wire 					    READ_ST;
(* altera_attribute = "-name CUT ON -from *; -name CUT ON -to *" *)input  wire 					    WRITE_ST;

//-------------------------------------------------------------------------------

always @(posedge CLK)
		begin   
		      if (WRITE_ST)
			  begin
				if (ADDRESS	==	9'h00)	    CONTROL0		<=	DATA[CONTROL0_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h01)		CONTROL1		<=	DATA[CONTROL1_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h02)		CONTROL2		<=	DATA[CONTROL2_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h03)		CONTROL3		<=	DATA[CONTROL3_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h04)		CONTROL4		<=	DATA[CONTROL4_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h05)		CONTROL5		<=	DATA[CONTROL5_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h06)		CONTROL6		<=	DATA[CONTROL6_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h07)		CONTROL7		<=	DATA[CONTROL7_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h08)		CONTROL8		<=	DATA[CONTROL8_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h09)		CONTROL9		<=	DATA[CONTROL9_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h0A)		CONTROLA		<=	DATA[CONTROLA_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h0B)		CONTROLB		<=	DATA[CONTROLB_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h0C)		CONTROLC		<=	DATA[CONTROLC_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h0D)		CONTROLD		<=	DATA[CONTROLD_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h0E)		CONTROLE		<=	DATA[CONTROLE_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h0F)		CONTROLF		<=	DATA[CONTROLF_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h10)	    CONTROL10		<=	DATA[CONTROL10_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h11)		CONTROL11		<=	DATA[CONTROL11_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h12)		CONTROL12		<=	DATA[CONTROL12_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h13)		CONTROL13		<=	DATA[CONTROL13_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h14)		CONTROL14		<=	DATA[CONTROL14_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h15)		CONTROL15		<=	DATA[CONTROL15_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h16)		CONTROL16		<=	DATA[CONTROL16_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h17)		CONTROL17		<=	DATA[CONTROL17_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h18)		CONTROL18		<=	DATA[CONTROL18_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h19)		CONTROL19		<=	DATA[CONTROL19_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h1A)		CONTROL1A		<=	DATA[CONTROL1A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h1B)		CONTROL1B		<=	DATA[CONTROL1B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h1C)		CONTROL1C		<=	DATA[CONTROL1C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h1D)		CONTROL1D		<=	DATA[CONTROL1D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h1E)		CONTROL1E		<=	DATA[CONTROL1E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h1F)		CONTROL1F		<=	DATA[CONTROL1F_ACTUAL_BITWIDTH-1:0]; 
				if (ADDRESS	==	9'h20)	    CONTROL20		<=	DATA[CONTROL20_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h21)		CONTROL21		<=	DATA[CONTROL21_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h22)		CONTROL22		<=	DATA[CONTROL22_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h23)		CONTROL23		<=	DATA[CONTROL23_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h24)		CONTROL24		<=	DATA[CONTROL24_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h25)		CONTROL25		<=	DATA[CONTROL25_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h26)		CONTROL26		<=	DATA[CONTROL26_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h27)		CONTROL27		<=	DATA[CONTROL27_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h28)		CONTROL28		<=	DATA[CONTROL28_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h29)		CONTROL29		<=	DATA[CONTROL29_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h2A)		CONTROL2A		<=	DATA[CONTROL2A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h2B)		CONTROL2B		<=	DATA[CONTROL2B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h2C)		CONTROL2C		<=	DATA[CONTROL2C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h2D)		CONTROL2D		<=	DATA[CONTROL2D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h2E)		CONTROL2E		<=	DATA[CONTROL2E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h2F)		CONTROL2F		<=	DATA[CONTROL2F_ACTUAL_BITWIDTH-1:0]; 
				if (ADDRESS	==	9'h30)	    CONTROL30		<=	DATA[CONTROL30_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h31)		CONTROL31		<=	DATA[CONTROL31_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h32)		CONTROL32		<=	DATA[CONTROL32_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h33)		CONTROL33		<=	DATA[CONTROL33_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h34)		CONTROL34		<=	DATA[CONTROL34_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h35)		CONTROL35		<=	DATA[CONTROL35_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h36)		CONTROL36		<=	DATA[CONTROL36_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h37)		CONTROL37		<=	DATA[CONTROL37_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h38)		CONTROL38		<=	DATA[CONTROL38_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h39)		CONTROL39		<=	DATA[CONTROL39_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h3A)		CONTROL3A		<=	DATA[CONTROL3A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h3B)		CONTROL3B		<=	DATA[CONTROL3B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h3C)		CONTROL3C		<=	DATA[CONTROL3C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h3D)		CONTROL3D		<=	DATA[CONTROL3D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h3E)		CONTROL3E		<=	DATA[CONTROL3E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h3F)		CONTROL3F		<=	DATA[CONTROL3F_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h40)	    CONTROL40		<=	DATA[CONTROL40_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h41)		CONTROL41		<=	DATA[CONTROL41_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h42)		CONTROL42		<=	DATA[CONTROL42_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h43)		CONTROL43		<=	DATA[CONTROL43_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h44)		CONTROL44		<=	DATA[CONTROL44_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h45)		CONTROL45		<=	DATA[CONTROL45_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h46)		CONTROL46		<=	DATA[CONTROL46_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h47)		CONTROL47		<=	DATA[CONTROL47_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h48)		CONTROL48		<=	DATA[CONTROL48_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h49)		CONTROL49		<=	DATA[CONTROL49_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h4A)		CONTROL4A		<=	DATA[CONTROL4A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h4B)		CONTROL4B		<=	DATA[CONTROL4B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h4C)		CONTROL4C		<=	DATA[CONTROL4C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h4D)		CONTROL4D		<=	DATA[CONTROL4D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h4E)		CONTROL4E		<=	DATA[CONTROL4E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h4F)		CONTROL4F		<=	DATA[CONTROL4F_ACTUAL_BITWIDTH-1:0];				
				if (ADDRESS	==	9'h50)	    CONTROL50		<=	DATA[CONTROL50_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h51)		CONTROL51		<=	DATA[CONTROL51_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h52)		CONTROL52		<=	DATA[CONTROL52_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h53)		CONTROL53		<=	DATA[CONTROL53_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h54)		CONTROL54		<=	DATA[CONTROL54_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h55)		CONTROL55		<=	DATA[CONTROL55_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h56)		CONTROL56		<=	DATA[CONTROL56_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h57)		CONTROL57		<=	DATA[CONTROL57_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h58)		CONTROL58		<=	DATA[CONTROL58_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h59)		CONTROL59		<=	DATA[CONTROL59_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h5A)		CONTROL5A		<=	DATA[CONTROL5A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h5B)		CONTROL5B		<=	DATA[CONTROL5B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h5C)		CONTROL5C		<=	DATA[CONTROL5C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h5D)		CONTROL5D		<=	DATA[CONTROL5D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h5E)		CONTROL5E		<=	DATA[CONTROL5E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h5F)		CONTROL5F		<=	DATA[CONTROL5F_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h60)	    CONTROL60		<=	DATA[CONTROL60_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h61)		CONTROL61		<=	DATA[CONTROL61_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h62)		CONTROL62		<=	DATA[CONTROL62_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h63)		CONTROL63		<=	DATA[CONTROL63_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h64)		CONTROL64		<=	DATA[CONTROL64_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h65)		CONTROL65		<=	DATA[CONTROL65_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h66)		CONTROL66		<=	DATA[CONTROL66_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h67)		CONTROL67		<=	DATA[CONTROL67_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h68)		CONTROL68		<=	DATA[CONTROL68_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h69)		CONTROL69		<=	DATA[CONTROL69_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h6A)		CONTROL6A		<=	DATA[CONTROL6A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h6B)		CONTROL6B		<=	DATA[CONTROL6B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h6C)		CONTROL6C		<=	DATA[CONTROL6C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h6D)		CONTROL6D		<=	DATA[CONTROL6D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h6E)		CONTROL6E		<=	DATA[CONTROL6E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h6F)		CONTROL6F		<=	DATA[CONTROL6F_ACTUAL_BITWIDTH-1:0];				
				if (ADDRESS	==	9'h70)	    CONTROL70		<=	DATA[CONTROL70_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h71)		CONTROL71		<=	DATA[CONTROL71_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h72)		CONTROL72		<=	DATA[CONTROL72_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h73)		CONTROL73		<=	DATA[CONTROL73_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h74)		CONTROL74		<=	DATA[CONTROL74_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h75)		CONTROL75		<=	DATA[CONTROL75_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h76)		CONTROL76		<=	DATA[CONTROL76_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h77)		CONTROL77		<=	DATA[CONTROL77_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h78)		CONTROL78		<=	DATA[CONTROL78_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h79)		CONTROL79		<=	DATA[CONTROL79_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h7A)		CONTROL7A		<=	DATA[CONTROL7A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h7B)		CONTROL7B		<=	DATA[CONTROL7B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h7C)		CONTROL7C		<=	DATA[CONTROL7C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h7D)		CONTROL7D		<=	DATA[CONTROL7D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h7E)		CONTROL7E		<=	DATA[CONTROL7E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h7F)		CONTROL7F		<=	DATA[CONTROL7F_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h80)	    CONTROL80		<=	DATA[CONTROL80_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h81)		CONTROL81		<=	DATA[CONTROL81_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h82)		CONTROL82		<=	DATA[CONTROL82_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h83)		CONTROL83		<=	DATA[CONTROL83_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h84)		CONTROL84		<=	DATA[CONTROL84_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h85)		CONTROL85		<=	DATA[CONTROL85_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h86)		CONTROL86		<=	DATA[CONTROL86_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h87)		CONTROL87		<=	DATA[CONTROL87_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h88)		CONTROL88		<=	DATA[CONTROL88_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h89)		CONTROL89		<=	DATA[CONTROL89_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h8A)		CONTROL8A		<=	DATA[CONTROL8A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h8B)		CONTROL8B		<=	DATA[CONTROL8B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h8C)		CONTROL8C		<=	DATA[CONTROL8C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h8D)		CONTROL8D		<=	DATA[CONTROL8D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h8E)		CONTROL8E		<=	DATA[CONTROL8E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h8F)		CONTROL8F		<=	DATA[CONTROL8F_ACTUAL_BITWIDTH-1:0];				
				
				if (ADDRESS	==	9'h90)	    CONTROL90		<=	DATA[CONTROL90_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h91)		CONTROL91		<=	DATA[CONTROL91_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h92)		CONTROL92		<=	DATA[CONTROL92_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h93)		CONTROL93		<=	DATA[CONTROL93_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h94)		CONTROL94		<=	DATA[CONTROL94_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h95)		CONTROL95		<=	DATA[CONTROL95_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h96)		CONTROL96		<=	DATA[CONTROL96_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h97)		CONTROL97		<=	DATA[CONTROL97_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h98)		CONTROL98		<=	DATA[CONTROL98_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h99)		CONTROL99		<=	DATA[CONTROL99_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h9A)		CONTROL9A		<=	DATA[CONTROL9A_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h9B)		CONTROL9B		<=	DATA[CONTROL9B_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h9C)		CONTROL9C		<=	DATA[CONTROL9C_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h9D)		CONTROL9D		<=	DATA[CONTROL9D_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h9E)		CONTROL9E		<=	DATA[CONTROL9E_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'h9F)		CONTROL9F		<=	DATA[CONTROL9F_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA0)	    CONTROLA0		<=	DATA[CONTROLA0_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA1)		CONTROLA1		<=	DATA[CONTROLA1_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA2)		CONTROLA2		<=	DATA[CONTROLA2_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA3)		CONTROLA3		<=	DATA[CONTROLA3_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA4)		CONTROLA4		<=	DATA[CONTROLA4_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA5)		CONTROLA5		<=	DATA[CONTROLA5_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA6)		CONTROLA6		<=	DATA[CONTROLA6_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA7)		CONTROLA7		<=	DATA[CONTROLA7_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA8)		CONTROLA8		<=	DATA[CONTROLA8_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hA9)		CONTROLA9		<=	DATA[CONTROLA9_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hAA)		CONTROLAA		<=	DATA[CONTROLAA_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hAB)		CONTROLAB		<=	DATA[CONTROLAB_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hAC)		CONTROLAC		<=	DATA[CONTROLAC_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hAD)		CONTROLAD		<=	DATA[CONTROLAD_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hAE)		CONTROLAE		<=	DATA[CONTROLAE_ACTUAL_BITWIDTH-1:0];
				if (ADDRESS	==	9'hAF)		CONTROLAF		<=	DATA[CONTROLAF_ACTUAL_BITWIDTH-1:0];
		 end
     end

always @(posedge CLK or negedge ACTIVE_LOW_READ_LD_RESET)
				if (~ACTIVE_LOW_READ_LD_RESET)
				begin
					 READ_LD[31:0] <= 32'h0;
				end else
				begin
				if (READ_ST) begin
							case (ADDRESS) /* synthesis full_case */
								9'h00	:	READ_LD[31:0] 	<=	CONTROL0[CONTROL0_ACTUAL_BITWIDTH-1:0];		
								9'h01	:	READ_LD[31:0] 	<=	CONTROL1[CONTROL1_ACTUAL_BITWIDTH-1:0];		
								9'h02	:	READ_LD[31:0] 	<=	CONTROL2[CONTROL2_ACTUAL_BITWIDTH-1:0];		
								9'h03	:	READ_LD[31:0] 	<=	CONTROL3[CONTROL3_ACTUAL_BITWIDTH-1:0];		
								9'h04	:	READ_LD[31:0] 	<=	CONTROL4[CONTROL4_ACTUAL_BITWIDTH-1:0];		
								9'h05	:	READ_LD[31:0] 	<=	CONTROL5[CONTROL5_ACTUAL_BITWIDTH-1:0];		
								9'h06	:	READ_LD[31:0] 	<=	CONTROL6[CONTROL6_ACTUAL_BITWIDTH-1:0];		
								9'h07	:	READ_LD[31:0] 	<=	CONTROL7[CONTROL7_ACTUAL_BITWIDTH-1:0];		
								9'h08	:	READ_LD[31:0] 	<=	CONTROL8[CONTROL8_ACTUAL_BITWIDTH-1:0];		
								9'h09	:	READ_LD[31:0] 	<=	CONTROL9[CONTROL9_ACTUAL_BITWIDTH-1:0];		
								9'h0A	:	READ_LD[31:0] 	<=	CONTROLA[CONTROLA_ACTUAL_BITWIDTH-1:0];		
								9'h0B	:	READ_LD[31:0] 	<=	CONTROLB[CONTROLB_ACTUAL_BITWIDTH-1:0];		
								9'h0C	:	READ_LD[31:0] 	<=	CONTROLC[CONTROLC_ACTUAL_BITWIDTH-1:0];		
								9'h0D	:	READ_LD[31:0] 	<=	CONTROLD[CONTROLD_ACTUAL_BITWIDTH-1:0];		
								9'h0E	:	READ_LD[31:0] 	<=	CONTROLE[CONTROLE_ACTUAL_BITWIDTH-1:0];		
								9'h0F	:	READ_LD[31:0] 	<=	CONTROLF[CONTROLF_ACTUAL_BITWIDTH-1:0];
								9'h10	:	READ_LD[31:0] 	<=	CONTROL10[CONTROL10_ACTUAL_BITWIDTH-1:0];		
								9'h11	:	READ_LD[31:0] 	<=	CONTROL11[CONTROL11_ACTUAL_BITWIDTH-1:0];		
								9'h12	:	READ_LD[31:0] 	<=	CONTROL12[CONTROL12_ACTUAL_BITWIDTH-1:0];		
								9'h13	:	READ_LD[31:0] 	<=	CONTROL13[CONTROL13_ACTUAL_BITWIDTH-1:0];		
								9'h14	:	READ_LD[31:0] 	<=	CONTROL14[CONTROL14_ACTUAL_BITWIDTH-1:0];		
								9'h15	:	READ_LD[31:0] 	<=	CONTROL15[CONTROL15_ACTUAL_BITWIDTH-1:0];		
								9'h16	:	READ_LD[31:0] 	<=	CONTROL16[CONTROL16_ACTUAL_BITWIDTH-1:0];		
								9'h17	:	READ_LD[31:0] 	<=	CONTROL17[CONTROL17_ACTUAL_BITWIDTH-1:0];		
								9'h18	:	READ_LD[31:0] 	<=	CONTROL18[CONTROL18_ACTUAL_BITWIDTH-1:0];		
								9'h19	:	READ_LD[31:0] 	<=	CONTROL19[CONTROL19_ACTUAL_BITWIDTH-1:0];		
								9'h1A	:	READ_LD[31:0] 	<=	CONTROL1A[CONTROL1A_ACTUAL_BITWIDTH-1:0];		
								9'h1B	:	READ_LD[31:0] 	<=	CONTROL1B[CONTROL1B_ACTUAL_BITWIDTH-1:0];		
								9'h1C	:	READ_LD[31:0] 	<=	CONTROL1C[CONTROL1C_ACTUAL_BITWIDTH-1:0];		
								9'h1D	:	READ_LD[31:0] 	<=	CONTROL1D[CONTROL1D_ACTUAL_BITWIDTH-1:0];		
								9'h1E	:	READ_LD[31:0] 	<=	CONTROL1E[CONTROL1E_ACTUAL_BITWIDTH-1:0];		
								9'h1F	:	READ_LD[31:0] 	<=	CONTROL1F[CONTROL1F_ACTUAL_BITWIDTH-1:0]; 
								9'h20	:	READ_LD[31:0] 	<=	CONTROL20[CONTROL20_ACTUAL_BITWIDTH-1:0];		
								9'h21	:	READ_LD[31:0] 	<=	CONTROL21[CONTROL21_ACTUAL_BITWIDTH-1:0];		
								9'h22	:	READ_LD[31:0] 	<=	CONTROL22[CONTROL22_ACTUAL_BITWIDTH-1:0];		
								9'h23	:	READ_LD[31:0] 	<=	CONTROL23[CONTROL23_ACTUAL_BITWIDTH-1:0];		
								9'h24	:	READ_LD[31:0] 	<=	CONTROL24[CONTROL24_ACTUAL_BITWIDTH-1:0];		
								9'h25	:	READ_LD[31:0] 	<=	CONTROL25[CONTROL25_ACTUAL_BITWIDTH-1:0];		
								9'h26	:	READ_LD[31:0] 	<=	CONTROL26[CONTROL26_ACTUAL_BITWIDTH-1:0];		
								9'h27	:	READ_LD[31:0] 	<=	CONTROL27[CONTROL27_ACTUAL_BITWIDTH-1:0];		
								9'h28	:	READ_LD[31:0] 	<=	CONTROL28[CONTROL28_ACTUAL_BITWIDTH-1:0];		
								9'h29	:	READ_LD[31:0] 	<=	CONTROL29[CONTROL29_ACTUAL_BITWIDTH-1:0];		
								9'h2A	:	READ_LD[31:0] 	<=	CONTROL2A[CONTROL2A_ACTUAL_BITWIDTH-1:0];		
								9'h2B	:	READ_LD[31:0] 	<=	CONTROL2B[CONTROL2B_ACTUAL_BITWIDTH-1:0];		
								9'h2C	:	READ_LD[31:0] 	<=	CONTROL2C[CONTROL2C_ACTUAL_BITWIDTH-1:0];		
								9'h2D	:	READ_LD[31:0] 	<=	CONTROL2D[CONTROL2D_ACTUAL_BITWIDTH-1:0];		
								9'h2E	:	READ_LD[31:0] 	<=	CONTROL2E[CONTROL2E_ACTUAL_BITWIDTH-1:0];		
								9'h2F	:	READ_LD[31:0] 	<=	CONTROL2F[CONTROL2F_ACTUAL_BITWIDTH-1:0]; 
								9'h30	:	READ_LD[31:0] 	<=	CONTROL30[CONTROL30_ACTUAL_BITWIDTH-1:0];		
								9'h31	:	READ_LD[31:0] 	<=	CONTROL31[CONTROL31_ACTUAL_BITWIDTH-1:0];		
								9'h32	:	READ_LD[31:0] 	<=	CONTROL32[CONTROL32_ACTUAL_BITWIDTH-1:0];		
								9'h33	:	READ_LD[31:0] 	<=	CONTROL33[CONTROL33_ACTUAL_BITWIDTH-1:0];		
								9'h34	:	READ_LD[31:0] 	<=	CONTROL34[CONTROL34_ACTUAL_BITWIDTH-1:0];		
								9'h35	:	READ_LD[31:0] 	<=	CONTROL35[CONTROL35_ACTUAL_BITWIDTH-1:0];		
								9'h36	:	READ_LD[31:0] 	<=	CONTROL36[CONTROL36_ACTUAL_BITWIDTH-1:0];		
								9'h37	:	READ_LD[31:0] 	<=	CONTROL37[CONTROL37_ACTUAL_BITWIDTH-1:0];		
								9'h38	:	READ_LD[31:0] 	<=	CONTROL38[CONTROL38_ACTUAL_BITWIDTH-1:0];		
								9'h39	:	READ_LD[31:0] 	<=	CONTROL39[CONTROL39_ACTUAL_BITWIDTH-1:0];		
								9'h3A	:	READ_LD[31:0] 	<=	CONTROL3A[CONTROL3A_ACTUAL_BITWIDTH-1:0];		
								9'h3B	:	READ_LD[31:0] 	<=	CONTROL3B[CONTROL3B_ACTUAL_BITWIDTH-1:0];		
								9'h3C	:	READ_LD[31:0] 	<=	CONTROL3C[CONTROL3C_ACTUAL_BITWIDTH-1:0];		
								9'h3D	:	READ_LD[31:0] 	<=	CONTROL3D[CONTROL3D_ACTUAL_BITWIDTH-1:0];		
								9'h3E	:	READ_LD[31:0] 	<=	CONTROL3E[CONTROL3E_ACTUAL_BITWIDTH-1:0];		
								9'h3F	:	READ_LD[31:0] 	<=	CONTROL3F[CONTROL3F_ACTUAL_BITWIDTH-1:0];
								9'h40	:	READ_LD[31:0] 	<=	CONTROL40[CONTROL40_ACTUAL_BITWIDTH-1:0];		
								9'h41	:	READ_LD[31:0] 	<=	CONTROL41[CONTROL41_ACTUAL_BITWIDTH-1:0];		
								9'h42	:	READ_LD[31:0] 	<=	CONTROL42[CONTROL42_ACTUAL_BITWIDTH-1:0];		
								9'h43	:	READ_LD[31:0] 	<=	CONTROL43[CONTROL43_ACTUAL_BITWIDTH-1:0];		
								9'h44	:	READ_LD[31:0] 	<=	CONTROL44[CONTROL44_ACTUAL_BITWIDTH-1:0];		
								9'h45	:	READ_LD[31:0] 	<=	CONTROL45[CONTROL45_ACTUAL_BITWIDTH-1:0];		
								9'h46	:	READ_LD[31:0] 	<=	CONTROL46[CONTROL46_ACTUAL_BITWIDTH-1:0];		
								9'h47	:	READ_LD[31:0] 	<=	CONTROL47[CONTROL47_ACTUAL_BITWIDTH-1:0];		
								9'h48	:	READ_LD[31:0] 	<=	CONTROL48[CONTROL48_ACTUAL_BITWIDTH-1:0];		
								9'h49	:	READ_LD[31:0] 	<=	CONTROL49[CONTROL49_ACTUAL_BITWIDTH-1:0];		
								9'h4A	:	READ_LD[31:0] 	<=	CONTROL4A[CONTROL4A_ACTUAL_BITWIDTH-1:0];		
								9'h4B	:	READ_LD[31:0] 	<=	CONTROL4B[CONTROL4B_ACTUAL_BITWIDTH-1:0];		
								9'h4C	:	READ_LD[31:0] 	<=	CONTROL4C[CONTROL4C_ACTUAL_BITWIDTH-1:0];		
								9'h4D	:	READ_LD[31:0] 	<=	CONTROL4D[CONTROL4D_ACTUAL_BITWIDTH-1:0];		
								9'h4E	:	READ_LD[31:0] 	<=	CONTROL4E[CONTROL4E_ACTUAL_BITWIDTH-1:0];		
								9'h4F	:	READ_LD[31:0] 	<=	CONTROL4F[CONTROL4F_ACTUAL_BITWIDTH-1:0];
								9'h50	:	READ_LD[31:0] 	<=	CONTROL50[CONTROL50_ACTUAL_BITWIDTH-1:0];		
								9'h51	:	READ_LD[31:0] 	<=	CONTROL51[CONTROL51_ACTUAL_BITWIDTH-1:0];		
								9'h52	:	READ_LD[31:0] 	<=	CONTROL52[CONTROL52_ACTUAL_BITWIDTH-1:0];		
								9'h53	:	READ_LD[31:0] 	<=	CONTROL53[CONTROL53_ACTUAL_BITWIDTH-1:0];		
								9'h54	:	READ_LD[31:0] 	<=	CONTROL54[CONTROL54_ACTUAL_BITWIDTH-1:0];		
								9'h55	:	READ_LD[31:0] 	<=	CONTROL55[CONTROL55_ACTUAL_BITWIDTH-1:0];		
								9'h56	:	READ_LD[31:0] 	<=	CONTROL56[CONTROL56_ACTUAL_BITWIDTH-1:0];		
								9'h57	:	READ_LD[31:0] 	<=	CONTROL57[CONTROL57_ACTUAL_BITWIDTH-1:0];		
								9'h58	:	READ_LD[31:0] 	<=	CONTROL58[CONTROL58_ACTUAL_BITWIDTH-1:0];		
								9'h59	:	READ_LD[31:0] 	<=	CONTROL59[CONTROL59_ACTUAL_BITWIDTH-1:0];		
								9'h5A	:	READ_LD[31:0] 	<=	CONTROL5A[CONTROL5A_ACTUAL_BITWIDTH-1:0];		
								9'h5B	:	READ_LD[31:0] 	<=	CONTROL5B[CONTROL5B_ACTUAL_BITWIDTH-1:0];		
								9'h5C	:	READ_LD[31:0] 	<=	CONTROL5C[CONTROL5C_ACTUAL_BITWIDTH-1:0];		
								9'h5D	:	READ_LD[31:0] 	<=	CONTROL5D[CONTROL5D_ACTUAL_BITWIDTH-1:0];		
								9'h5E	:	READ_LD[31:0] 	<=	CONTROL5E[CONTROL5E_ACTUAL_BITWIDTH-1:0];		
								9'h5F	:	READ_LD[31:0] 	<=	CONTROL5F[CONTROL5F_ACTUAL_BITWIDTH-1:0];				    
								9'h60	:	READ_LD[31:0] 	<=	CONTROL60[CONTROL60_ACTUAL_BITWIDTH-1:0];		
								9'h61	:	READ_LD[31:0] 	<=	CONTROL61[CONTROL61_ACTUAL_BITWIDTH-1:0];		
								9'h62	:	READ_LD[31:0] 	<=	CONTROL62[CONTROL62_ACTUAL_BITWIDTH-1:0];		
								9'h63	:	READ_LD[31:0] 	<=	CONTROL63[CONTROL63_ACTUAL_BITWIDTH-1:0];		
								9'h64	:	READ_LD[31:0] 	<=	CONTROL64[CONTROL64_ACTUAL_BITWIDTH-1:0];		
								9'h65	:	READ_LD[31:0] 	<=	CONTROL65[CONTROL65_ACTUAL_BITWIDTH-1:0];		
								9'h66	:	READ_LD[31:0] 	<=	CONTROL66[CONTROL66_ACTUAL_BITWIDTH-1:0];		
								9'h67	:	READ_LD[31:0] 	<=	CONTROL67[CONTROL67_ACTUAL_BITWIDTH-1:0];		
								9'h68	:	READ_LD[31:0] 	<=	CONTROL68[CONTROL68_ACTUAL_BITWIDTH-1:0];		
								9'h69	:	READ_LD[31:0] 	<=	CONTROL69[CONTROL69_ACTUAL_BITWIDTH-1:0];		
								9'h6A	:	READ_LD[31:0] 	<=	CONTROL6A[CONTROL6A_ACTUAL_BITWIDTH-1:0];		
								9'h6B	:	READ_LD[31:0] 	<=	CONTROL6B[CONTROL6B_ACTUAL_BITWIDTH-1:0];		
								9'h6C	:	READ_LD[31:0] 	<=	CONTROL6C[CONTROL6C_ACTUAL_BITWIDTH-1:0];		
								9'h6D	:	READ_LD[31:0] 	<=	CONTROL6D[CONTROL6D_ACTUAL_BITWIDTH-1:0];		
								9'h6E	:	READ_LD[31:0] 	<=	CONTROL6E[CONTROL6E_ACTUAL_BITWIDTH-1:0];		
								9'h6F	:	READ_LD[31:0] 	<=	CONTROL6F[CONTROL6F_ACTUAL_BITWIDTH-1:0];
								9'h70	:	READ_LD[31:0] 	<=	CONTROL70[CONTROL70_ACTUAL_BITWIDTH-1:0];		
								9'h71	:	READ_LD[31:0] 	<=	CONTROL71[CONTROL71_ACTUAL_BITWIDTH-1:0];		
								9'h72	:	READ_LD[31:0] 	<=	CONTROL72[CONTROL72_ACTUAL_BITWIDTH-1:0];		
								9'h73	:	READ_LD[31:0] 	<=	CONTROL73[CONTROL73_ACTUAL_BITWIDTH-1:0];		
								9'h74	:	READ_LD[31:0] 	<=	CONTROL74[CONTROL74_ACTUAL_BITWIDTH-1:0];		
								9'h75	:	READ_LD[31:0] 	<=	CONTROL75[CONTROL75_ACTUAL_BITWIDTH-1:0];		
								9'h76	:	READ_LD[31:0] 	<=	CONTROL76[CONTROL76_ACTUAL_BITWIDTH-1:0];		
								9'h77	:	READ_LD[31:0] 	<=	CONTROL77[CONTROL77_ACTUAL_BITWIDTH-1:0];		
								9'h78	:	READ_LD[31:0] 	<=	CONTROL78[CONTROL78_ACTUAL_BITWIDTH-1:0];		
								9'h79	:	READ_LD[31:0] 	<=	CONTROL79[CONTROL79_ACTUAL_BITWIDTH-1:0];		
								9'h7A	:	READ_LD[31:0] 	<=	CONTROL7A[CONTROL7A_ACTUAL_BITWIDTH-1:0];		
								9'h7B	:	READ_LD[31:0] 	<=	CONTROL7B[CONTROL7B_ACTUAL_BITWIDTH-1:0];		
								9'h7C	:	READ_LD[31:0] 	<=	CONTROL7C[CONTROL7C_ACTUAL_BITWIDTH-1:0];		
								9'h7D	:	READ_LD[31:0] 	<=	CONTROL7D[CONTROL7D_ACTUAL_BITWIDTH-1:0];		
								9'h7E	:	READ_LD[31:0] 	<=	CONTROL7E[CONTROL7E_ACTUAL_BITWIDTH-1:0];		
								9'h7F	:	READ_LD[31:0] 	<=	CONTROL7F[CONTROL7F_ACTUAL_BITWIDTH-1:0];
								9'h80	:	READ_LD[31:0] 	<=	CONTROL80[CONTROL80_ACTUAL_BITWIDTH-1:0];		
								9'h81	:	READ_LD[31:0] 	<=	CONTROL81[CONTROL81_ACTUAL_BITWIDTH-1:0];		
								9'h82	:	READ_LD[31:0] 	<=	CONTROL82[CONTROL82_ACTUAL_BITWIDTH-1:0];		
								9'h83	:	READ_LD[31:0] 	<=	CONTROL83[CONTROL83_ACTUAL_BITWIDTH-1:0];		
								9'h84	:	READ_LD[31:0] 	<=	CONTROL84[CONTROL84_ACTUAL_BITWIDTH-1:0];		
								9'h85	:	READ_LD[31:0] 	<=	CONTROL85[CONTROL85_ACTUAL_BITWIDTH-1:0];		
								9'h86	:	READ_LD[31:0] 	<=	CONTROL86[CONTROL86_ACTUAL_BITWIDTH-1:0];		
								9'h87	:	READ_LD[31:0] 	<=	CONTROL87[CONTROL87_ACTUAL_BITWIDTH-1:0];		
								9'h88	:	READ_LD[31:0] 	<=	CONTROL88[CONTROL88_ACTUAL_BITWIDTH-1:0];		
								9'h89	:	READ_LD[31:0] 	<=	CONTROL89[CONTROL89_ACTUAL_BITWIDTH-1:0];		
								9'h8A	:	READ_LD[31:0] 	<=	CONTROL8A[CONTROL8A_ACTUAL_BITWIDTH-1:0];		
								9'h8B	:	READ_LD[31:0] 	<=	CONTROL8B[CONTROL8B_ACTUAL_BITWIDTH-1:0];		
								9'h8C	:	READ_LD[31:0] 	<=	CONTROL8C[CONTROL8C_ACTUAL_BITWIDTH-1:0];		
								9'h8D	:	READ_LD[31:0] 	<=	CONTROL8D[CONTROL8D_ACTUAL_BITWIDTH-1:0];		
								9'h8E	:	READ_LD[31:0] 	<=	CONTROL8E[CONTROL8E_ACTUAL_BITWIDTH-1:0];		
								9'h8F	:	READ_LD[31:0] 	<=	CONTROL8F[CONTROL8F_ACTUAL_BITWIDTH-1:0];
								9'h90	:	READ_LD[31:0] 	<=	CONTROL90[CONTROL90_ACTUAL_BITWIDTH-1:0];		
								9'h91	:	READ_LD[31:0] 	<=	CONTROL91[CONTROL91_ACTUAL_BITWIDTH-1:0];		
								9'h92	:	READ_LD[31:0] 	<=	CONTROL92[CONTROL92_ACTUAL_BITWIDTH-1:0];		
								9'h93	:	READ_LD[31:0] 	<=	CONTROL93[CONTROL93_ACTUAL_BITWIDTH-1:0];		
								9'h94	:	READ_LD[31:0] 	<=	CONTROL94[CONTROL94_ACTUAL_BITWIDTH-1:0];		
								9'h95	:	READ_LD[31:0] 	<=	CONTROL95[CONTROL95_ACTUAL_BITWIDTH-1:0];		
								9'h96	:	READ_LD[31:0] 	<=	CONTROL96[CONTROL96_ACTUAL_BITWIDTH-1:0];		
								9'h97	:	READ_LD[31:0] 	<=	CONTROL97[CONTROL97_ACTUAL_BITWIDTH-1:0];		
								9'h98	:	READ_LD[31:0] 	<=	CONTROL98[CONTROL98_ACTUAL_BITWIDTH-1:0];		
								9'h99	:	READ_LD[31:0] 	<=	CONTROL99[CONTROL99_ACTUAL_BITWIDTH-1:0];		
								9'h9A	:	READ_LD[31:0] 	<=	CONTROL9A[CONTROL9A_ACTUAL_BITWIDTH-1:0];		
								9'h9B	:	READ_LD[31:0] 	<=	CONTROL9B[CONTROL9B_ACTUAL_BITWIDTH-1:0];		
								9'h9C	:	READ_LD[31:0] 	<=	CONTROL9C[CONTROL9C_ACTUAL_BITWIDTH-1:0];		
								9'h9D	:	READ_LD[31:0] 	<=	CONTROL9D[CONTROL9D_ACTUAL_BITWIDTH-1:0];		
								9'h9E	:	READ_LD[31:0] 	<=	CONTROL9E[CONTROL9E_ACTUAL_BITWIDTH-1:0];		
								9'h9F	:	READ_LD[31:0] 	<=	CONTROL9F[CONTROL9F_ACTUAL_BITWIDTH-1:0];
								9'hA0	:	READ_LD[31:0] 	<=	CONTROLA0[CONTROLA0_ACTUAL_BITWIDTH-1:0];		
								9'hA1	:	READ_LD[31:0] 	<=	CONTROLA1[CONTROLA1_ACTUAL_BITWIDTH-1:0];		
								9'hA2	:	READ_LD[31:0] 	<=	CONTROLA2[CONTROLA2_ACTUAL_BITWIDTH-1:0];		
								9'hA3	:	READ_LD[31:0] 	<=	CONTROLA3[CONTROLA3_ACTUAL_BITWIDTH-1:0];		
								9'hA4	:	READ_LD[31:0] 	<=	CONTROLA4[CONTROLA4_ACTUAL_BITWIDTH-1:0];		
								9'hA5	:	READ_LD[31:0] 	<=	CONTROLA5[CONTROLA5_ACTUAL_BITWIDTH-1:0];		
								9'hA6	:	READ_LD[31:0] 	<=	CONTROLA6[CONTROLA6_ACTUAL_BITWIDTH-1:0];		
								9'hA7	:	READ_LD[31:0] 	<=	CONTROLA7[CONTROLA7_ACTUAL_BITWIDTH-1:0];		
								9'hA8	:	READ_LD[31:0] 	<=	CONTROLA8[CONTROLA8_ACTUAL_BITWIDTH-1:0];		
								9'hA9	:	READ_LD[31:0] 	<=	CONTROLA9[CONTROLA9_ACTUAL_BITWIDTH-1:0];		
								9'hAA	:	READ_LD[31:0] 	<=	CONTROLAA[CONTROLAA_ACTUAL_BITWIDTH-1:0];		
								9'hAB	:	READ_LD[31:0] 	<=	CONTROLAB[CONTROLAB_ACTUAL_BITWIDTH-1:0];		
								9'hAC	:	READ_LD[31:0] 	<=	CONTROLAC[CONTROLAC_ACTUAL_BITWIDTH-1:0];		
								9'hAD	:	READ_LD[31:0] 	<=	CONTROLAD[CONTROLAD_ACTUAL_BITWIDTH-1:0];		
								9'hAE	:	READ_LD[31:0] 	<=	CONTROLAE[CONTROLAE_ACTUAL_BITWIDTH-1:0];		
								9'hAF	:	READ_LD[31:0] 	<=	CONTROLAF[CONTROLAF_ACTUAL_BITWIDTH-1:0];
								
								9'h120   :  READ_LD[31:0] 	<= STATUS0;
								9'h121   :  READ_LD[31:0] 	<= STATUS1;
								9'h122   :  READ_LD[31:0] 	<= STATUS2;
								9'h123   :  READ_LD[31:0] 	<= STATUS3;
								9'h124   :  READ_LD[31:0] 	<= STATUS4;
								9'h125   :  READ_LD[31:0] 	<= STATUS5;
								9'h126   :  READ_LD[31:0] 	<= STATUS6;
								9'h127   :  READ_LD[31:0] 	<= STATUS7;
								9'h128   :  READ_LD[31:0] 	<= STATUS8;
								9'h129   :  READ_LD[31:0] 	<= STATUS9;
								9'h12A   :  READ_LD[31:0] 	<= STATUSA;
								9'h12B   :  READ_LD[31:0] 	<= STATUSB;
								9'h12C   :  READ_LD[31:0] 	<= STATUSC;
								9'h12D   :  READ_LD[31:0] 	<= STATUSD;
								9'h12E   :  READ_LD[31:0] 	<= STATUSE;
								9'h12F   :  READ_LD[31:0] 	<= STATUSF;
								
								9'h140   :  READ_LD[31:0] 	<= STATUS10;
								9'h141   :  READ_LD[31:0] 	<= STATUS11;
								9'h142   :  READ_LD[31:0] 	<= STATUS12;
								9'h143   :  READ_LD[31:0] 	<= STATUS13;
								9'h144   :  READ_LD[31:0] 	<= STATUS14;
								9'h145   :  READ_LD[31:0] 	<= STATUS15;
								9'h146   :  READ_LD[31:0] 	<= STATUS16;
								9'h147   :  READ_LD[31:0] 	<= STATUS17;
								9'h148   :  READ_LD[31:0] 	<= STATUS18;
								9'h149   :  READ_LD[31:0] 	<= STATUS19;
								9'h14A   :  READ_LD[31:0] 	<= STATUS1A;
								9'h14B   :  READ_LD[31:0] 	<= STATUS1B;
								9'h14C   :  READ_LD[31:0] 	<= STATUS1C;
								9'h14D   :  READ_LD[31:0] 	<= STATUS1D;
								9'h14E   :  READ_LD[31:0] 	<= STATUS1E;
								9'h14F   :  READ_LD[31:0] 	<= STATUS1F;
									
								9'h150   :  READ_LD[31:0] 	<= STATUS20;
								9'h151   :  READ_LD[31:0] 	<= STATUS21;
								9'h152   :  READ_LD[31:0] 	<= STATUS22;
								9'h153   :  READ_LD[31:0] 	<= STATUS23;
								9'h154   :  READ_LD[31:0] 	<= STATUS24;
								9'h155   :  READ_LD[31:0] 	<= STATUS25;
								9'h156   :  READ_LD[31:0] 	<= STATUS26;
								9'h157   :  READ_LD[31:0] 	<= STATUS27;
								9'h158   :  READ_LD[31:0] 	<= STATUS28;
								9'h159   :  READ_LD[31:0] 	<= STATUS29;
								9'h15A   :  READ_LD[31:0] 	<= STATUS2A;
								9'h15B   :  READ_LD[31:0] 	<= STATUS2B;
								9'h15C   :  READ_LD[31:0] 	<= STATUS2C;
								9'h15D   :  READ_LD[31:0] 	<= STATUS2D;
								9'h15E   :  READ_LD[31:0] 	<= STATUS2E;
								9'h15F   :  READ_LD[31:0] 	<= STATUS2F;
				
								9'h150   :  READ_LD[31:0] 	<= STATUS30;
								9'h151   :  READ_LD[31:0] 	<= STATUS31;
								9'h152   :  READ_LD[31:0] 	<= STATUS32;
								9'h153   :  READ_LD[31:0] 	<= STATUS33;
								9'h154   :  READ_LD[31:0] 	<= STATUS34;
								9'h155   :  READ_LD[31:0] 	<= STATUS35;
								9'h156   :  READ_LD[31:0] 	<= STATUS36;
								9'h157   :  READ_LD[31:0] 	<= STATUS37;
								9'h158   :  READ_LD[31:0] 	<= STATUS38;
								9'h159   :  READ_LD[31:0] 	<= STATUS39;
								9'h15A   :  READ_LD[31:0] 	<= STATUS3A;
								9'h15B   :  READ_LD[31:0] 	<= STATUS3B;
								9'h15C   :  READ_LD[31:0] 	<= STATUS3C;
								9'h15D   :  READ_LD[31:0] 	<= STATUS3D;
								9'h15E   :  READ_LD[31:0] 	<= STATUS3E;
								9'h15F   :  READ_LD[31:0] 	<= STATUS3F;
				
								endcase
					end
				end
endmodule
