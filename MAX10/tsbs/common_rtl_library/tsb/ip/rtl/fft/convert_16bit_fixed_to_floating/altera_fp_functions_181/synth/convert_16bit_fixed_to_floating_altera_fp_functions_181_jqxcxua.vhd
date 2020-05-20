-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 18.1 (Release Build #625)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2018 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from convert_16bit_fixed_to_floating_altera_fp_functions_181_jqxcxua
-- VHDL created on Tue Jul 09 12:59:45 2019


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY altera_lnsim;
USE altera_lnsim.altera_lnsim_components.altera_syncram;
LIBRARY lpm;
USE lpm.lpm_components.all;

library twentynm;
use twentynm.twentynm_components.twentynm_fp_mac;

entity convert_16bit_fixed_to_floating_altera_fp_functions_181_jqxcxua is
    port (
        a : in std_logic_vector(15 downto 0);  -- sfix16_en15
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end convert_16bit_fixed_to_floating_altera_fp_functions_181_jqxcxua;

architecture normal of convert_16bit_fixed_to_floating_altera_fp_functions_181_jqxcxua is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signX_uid6_fxpToFPTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal xXorSign_uid7_fxpToFPTest_b : STD_LOGIC_VECTOR (15 downto 0);
    signal xXorSign_uid7_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal yE_uid8_fxpToFPTest_a : STD_LOGIC_VECTOR (16 downto 0);
    signal yE_uid8_fxpToFPTest_b : STD_LOGIC_VECTOR (16 downto 0);
    signal yE_uid8_fxpToFPTest_o : STD_LOGIC_VECTOR (16 downto 0);
    signal yE_uid8_fxpToFPTest_q : STD_LOGIC_VECTOR (16 downto 0);
    signal y_uid9_fxpToFPTest_in : STD_LOGIC_VECTOR (15 downto 0);
    signal y_uid9_fxpToFPTest_b : STD_LOGIC_VECTOR (15 downto 0);
    signal maxCount_uid11_fxpToFPTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal inIsZero_uid12_fxpToFPTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal inIsZero_uid12_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal msbIn_uid13_fxpToFPTest_q : STD_LOGIC_VECTOR (6 downto 0);
    signal expPreRnd_uid14_fxpToFPTest_a : STD_LOGIC_VECTOR (7 downto 0);
    signal expPreRnd_uid14_fxpToFPTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expPreRnd_uid14_fxpToFPTest_o : STD_LOGIC_VECTOR (7 downto 0);
    signal expPreRnd_uid14_fxpToFPTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal zP_uid15_fxpToFPTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal fracRU_uid16_fxpToFPTest_in : STD_LOGIC_VECTOR (14 downto 0);
    signal fracRU_uid16_fxpToFPTest_b : STD_LOGIC_VECTOR (14 downto 0);
    signal fracRR_uid17_fxpToFPTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal udf_uid19_fxpToFPTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal udf_uid19_fxpToFPTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal udf_uid19_fxpToFPTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal udf_uid19_fxpToFPTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal expInf_uid20_fxpToFPTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal ovf_uid21_fxpToFPTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal ovf_uid21_fxpToFPTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal ovf_uid21_fxpToFPTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal ovf_uid21_fxpToFPTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal excSelector_uid22_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracZ_uid23_fxpToFPTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracRPostExc_uid24_fxpToFPTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPostExc_uid24_fxpToFPTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal udfOrInZero_uid25_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excSelector_uid26_fxpToFPTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid31_fxpToFPTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid31_fxpToFPTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal outRes_uid32_fxpToFPTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal zs_uid34_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cStage_uid44_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal zs_uid46_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cStage_uid51_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal zs_uid53_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal vCount_uid55_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cStage_uid58_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid62_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cStage_uid65_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_a : STD_LOGIC_VECTOR (6 downto 0);
    signal vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_b : STD_LOGIC_VECTOR (6 downto 0);
    signal vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_o : STD_LOGIC_VECTOR (6 downto 0);
    signal vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rVStage_uid40_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid40_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid47_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid47_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c : STD_LOGIC_VECTOR (11 downto 0);
    signal rVStage_uid54_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid54_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c : STD_LOGIC_VECTOR (13 downto 0);
    signal rVStage_uid61_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b : STD_LOGIC_VECTOR (0 downto 0);
    signal rVStage_uid61_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c : STD_LOGIC_VECTOR (14 downto 0);
    signal redist0_vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q_1_q : STD_LOGIC_VECTOR (4 downto 0);
    signal redist1_vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist2_vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q_1_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist3_vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist4_fracRU_uid16_fxpToFPTest_b_2_q : STD_LOGIC_VECTOR (14 downto 0);
    signal redist5_y_uid9_fxpToFPTest_b_1_q : STD_LOGIC_VECTOR (15 downto 0);
    signal redist6_signX_uid6_fxpToFPTest_b_5_q : STD_LOGIC_VECTOR (0 downto 0);

begin


    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- signX_uid6_fxpToFPTest(BITSELECT,5)@0
    signX_uid6_fxpToFPTest_b <= STD_LOGIC_VECTOR(a(15 downto 15));

    -- redist6_signX_uid6_fxpToFPTest_b_5(DELAY,83)
    redist6_signX_uid6_fxpToFPTest_b_5 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => signX_uid6_fxpToFPTest_b, xout => redist6_signX_uid6_fxpToFPTest_b_5_q, clk => clk, aclr => areset );

    -- expInf_uid20_fxpToFPTest(CONSTANT,19)
    expInf_uid20_fxpToFPTest_q <= "11111111";

    -- zP_uid15_fxpToFPTest(CONSTANT,14)
    zP_uid15_fxpToFPTest_q <= "00000000";

    -- maxCount_uid11_fxpToFPTest(CONSTANT,10)
    maxCount_uid11_fxpToFPTest_q <= "10000";

    -- zs_uid34_lzcShifterZ1_uid10_fxpToFPTest(CONSTANT,33)
    zs_uid34_lzcShifterZ1_uid10_fxpToFPTest_q <= "0000000000000000";

    -- xXorSign_uid7_fxpToFPTest(LOGICAL,6)@0
    xXorSign_uid7_fxpToFPTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((15 downto 1 => signX_uid6_fxpToFPTest_b(0)) & signX_uid6_fxpToFPTest_b));
    xXorSign_uid7_fxpToFPTest_q <= a xor xXorSign_uid7_fxpToFPTest_b;

    -- yE_uid8_fxpToFPTest(ADD,7)@0
    yE_uid8_fxpToFPTest_a <= STD_LOGIC_VECTOR("0" & xXorSign_uid7_fxpToFPTest_q);
    yE_uid8_fxpToFPTest_b <= STD_LOGIC_VECTOR("0000000000000000" & signX_uid6_fxpToFPTest_b);
    yE_uid8_fxpToFPTest_o <= STD_LOGIC_VECTOR(UNSIGNED(yE_uid8_fxpToFPTest_a) + UNSIGNED(yE_uid8_fxpToFPTest_b));
    yE_uid8_fxpToFPTest_q <= yE_uid8_fxpToFPTest_o(16 downto 0);

    -- y_uid9_fxpToFPTest(BITSELECT,8)@0
    y_uid9_fxpToFPTest_in <= STD_LOGIC_VECTOR(yE_uid8_fxpToFPTest_q(15 downto 0));
    y_uid9_fxpToFPTest_b <= STD_LOGIC_VECTOR(y_uid9_fxpToFPTest_in(15 downto 0));

    -- redist5_y_uid9_fxpToFPTest_b_1(DELAY,82)
    redist5_y_uid9_fxpToFPTest_b_1 : dspba_delay
    GENERIC MAP ( width => 16, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => y_uid9_fxpToFPTest_b, xout => redist5_y_uid9_fxpToFPTest_b_1_q, clk => clk, aclr => areset );

    -- vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest(LOGICAL,35)@1
    vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q <= "1" WHEN redist5_y_uid9_fxpToFPTest_b_1_q = zs_uid34_lzcShifterZ1_uid10_fxpToFPTest_q ELSE "0";

    -- redist3_vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q_2(DELAY,80)
    redist3_vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q, xout => redist3_vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q_2_q, clk => clk, aclr => areset );

    -- vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest(MUX,37)@1 + 1
    vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_s <= vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q;
    vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_s) IS
                WHEN "0" => vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q <= redist5_y_uid9_fxpToFPTest_b_1_q;
                WHEN "1" => vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q <= zs_uid34_lzcShifterZ1_uid10_fxpToFPTest_q;
                WHEN OTHERS => vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid40_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select(BITSELECT,73)@2
    rVStage_uid40_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b <= vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q(15 downto 8);
    rVStage_uid40_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c <= vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q(7 downto 0);

    -- vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest(LOGICAL,40)@2
    vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q <= "1" WHEN rVStage_uid40_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b = zP_uid15_fxpToFPTest_q ELSE "0";

    -- redist2_vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q_1(DELAY,79)
    redist2_vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q, xout => redist2_vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q_1_q, clk => clk, aclr => areset );

    -- zs_uid46_lzcShifterZ1_uid10_fxpToFPTest(CONSTANT,45)
    zs_uid46_lzcShifterZ1_uid10_fxpToFPTest_q <= "0000";

    -- cStage_uid44_lzcShifterZ1_uid10_fxpToFPTest(BITJOIN,43)@2
    cStage_uid44_lzcShifterZ1_uid10_fxpToFPTest_q <= rVStage_uid40_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c & zP_uid15_fxpToFPTest_q;

    -- vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest(MUX,44)@2
    vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_s <= vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q;
    vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_combproc: PROCESS (vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_s, vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q, cStage_uid44_lzcShifterZ1_uid10_fxpToFPTest_q)
    BEGIN
        CASE (vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_s) IS
            WHEN "0" => vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_q <= vStagei_uid38_lzcShifterZ1_uid10_fxpToFPTest_q;
            WHEN "1" => vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_q <= cStage_uid44_lzcShifterZ1_uid10_fxpToFPTest_q;
            WHEN OTHERS => vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid47_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select(BITSELECT,74)@2
    rVStage_uid47_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b <= vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_q(15 downto 12);
    rVStage_uid47_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c <= vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_q(11 downto 0);

    -- vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest(LOGICAL,47)@2
    vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q <= "1" WHEN rVStage_uid47_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b = zs_uid46_lzcShifterZ1_uid10_fxpToFPTest_q ELSE "0";

    -- redist1_vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q_1(DELAY,78)
    redist1_vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q_1 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q, xout => redist1_vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q_1_q, clk => clk, aclr => areset );

    -- zs_uid53_lzcShifterZ1_uid10_fxpToFPTest(CONSTANT,52)
    zs_uid53_lzcShifterZ1_uid10_fxpToFPTest_q <= "00";

    -- cStage_uid51_lzcShifterZ1_uid10_fxpToFPTest(BITJOIN,50)@2
    cStage_uid51_lzcShifterZ1_uid10_fxpToFPTest_q <= rVStage_uid47_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c & zs_uid46_lzcShifterZ1_uid10_fxpToFPTest_q;

    -- vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest(MUX,51)@2 + 1
    vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_s <= vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q;
    vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            CASE (vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_s) IS
                WHEN "0" => vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q <= vStagei_uid45_lzcShifterZ1_uid10_fxpToFPTest_q;
                WHEN "1" => vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q <= cStage_uid51_lzcShifterZ1_uid10_fxpToFPTest_q;
                WHEN OTHERS => vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
            END CASE;
        END IF;
    END PROCESS;

    -- rVStage_uid54_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select(BITSELECT,75)@3
    rVStage_uid54_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b <= vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q(15 downto 14);
    rVStage_uid54_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c <= vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q(13 downto 0);

    -- vCount_uid55_lzcShifterZ1_uid10_fxpToFPTest(LOGICAL,54)@3
    vCount_uid55_lzcShifterZ1_uid10_fxpToFPTest_q <= "1" WHEN rVStage_uid54_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b = zs_uid53_lzcShifterZ1_uid10_fxpToFPTest_q ELSE "0";

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- cStage_uid58_lzcShifterZ1_uid10_fxpToFPTest(BITJOIN,57)@3
    cStage_uid58_lzcShifterZ1_uid10_fxpToFPTest_q <= rVStage_uid54_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c & zs_uid53_lzcShifterZ1_uid10_fxpToFPTest_q;

    -- vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest(MUX,58)@3
    vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_s <= vCount_uid55_lzcShifterZ1_uid10_fxpToFPTest_q;
    vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_combproc: PROCESS (vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_s, vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q, cStage_uid58_lzcShifterZ1_uid10_fxpToFPTest_q)
    BEGIN
        CASE (vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_s) IS
            WHEN "0" => vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q <= vStagei_uid52_lzcShifterZ1_uid10_fxpToFPTest_q;
            WHEN "1" => vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q <= cStage_uid58_lzcShifterZ1_uid10_fxpToFPTest_q;
            WHEN OTHERS => vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid61_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select(BITSELECT,76)@3
    rVStage_uid61_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b <= vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q(15 downto 15);
    rVStage_uid61_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c <= vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q(14 downto 0);

    -- vCount_uid62_lzcShifterZ1_uid10_fxpToFPTest(LOGICAL,61)@3
    vCount_uid62_lzcShifterZ1_uid10_fxpToFPTest_q <= "1" WHEN rVStage_uid61_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_b = GND_q ELSE "0";

    -- vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest(BITJOIN,66)@3
    vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q <= redist3_vCount_uid36_lzcShifterZ1_uid10_fxpToFPTest_q_2_q & redist2_vCount_uid41_lzcShifterZ1_uid10_fxpToFPTest_q_1_q & redist1_vCount_uid48_lzcShifterZ1_uid10_fxpToFPTest_q_1_q & vCount_uid55_lzcShifterZ1_uid10_fxpToFPTest_q & vCount_uid62_lzcShifterZ1_uid10_fxpToFPTest_q;

    -- redist0_vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q_1(DELAY,77)
    redist0_vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q_1 : dspba_delay
    GENERIC MAP ( width => 5, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q, xout => redist0_vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q_1_q, clk => clk, aclr => areset );

    -- vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest(COMPARE,68)@3 + 1
    vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_a <= STD_LOGIC_VECTOR("00" & maxCount_uid11_fxpToFPTest_q);
    vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_b <= STD_LOGIC_VECTOR("00" & vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q);
    vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_o <= STD_LOGIC_VECTOR(UNSIGNED(vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_a) - UNSIGNED(vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_b));
        END IF;
    END PROCESS;
    vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_c(0) <= vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_o(6);

    -- vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest(MUX,70)@4
    vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_s <= vCountBig_uid69_lzcShifterZ1_uid10_fxpToFPTest_c;
    vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_combproc: PROCESS (vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_s, redist0_vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q_1_q, maxCount_uid11_fxpToFPTest_q)
    BEGIN
        CASE (vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_s) IS
            WHEN "0" => vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_q <= redist0_vCount_uid67_lzcShifterZ1_uid10_fxpToFPTest_q_1_q;
            WHEN "1" => vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_q <= maxCount_uid11_fxpToFPTest_q;
            WHEN OTHERS => vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- msbIn_uid13_fxpToFPTest(CONSTANT,12)
    msbIn_uid13_fxpToFPTest_q <= "1111111";

    -- expPreRnd_uid14_fxpToFPTest(SUB,13)@4 + 1
    expPreRnd_uid14_fxpToFPTest_a <= STD_LOGIC_VECTOR("0" & msbIn_uid13_fxpToFPTest_q);
    expPreRnd_uid14_fxpToFPTest_b <= STD_LOGIC_VECTOR("000" & vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_q);
    expPreRnd_uid14_fxpToFPTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expPreRnd_uid14_fxpToFPTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expPreRnd_uid14_fxpToFPTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expPreRnd_uid14_fxpToFPTest_a) - UNSIGNED(expPreRnd_uid14_fxpToFPTest_b));
        END IF;
    END PROCESS;
    expPreRnd_uid14_fxpToFPTest_q <= expPreRnd_uid14_fxpToFPTest_o(7 downto 0);

    -- ovf_uid21_fxpToFPTest(COMPARE,20)@5
    ovf_uid21_fxpToFPTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((10 downto 8 => expPreRnd_uid14_fxpToFPTest_q(7)) & expPreRnd_uid14_fxpToFPTest_q));
    ovf_uid21_fxpToFPTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000" & expInf_uid20_fxpToFPTest_q));
    ovf_uid21_fxpToFPTest_o <= STD_LOGIC_VECTOR(SIGNED(ovf_uid21_fxpToFPTest_a) - SIGNED(ovf_uid21_fxpToFPTest_b));
    ovf_uid21_fxpToFPTest_n(0) <= not (ovf_uid21_fxpToFPTest_o(10));

    -- inIsZero_uid12_fxpToFPTest(LOGICAL,11)@4 + 1
    inIsZero_uid12_fxpToFPTest_qi <= "1" WHEN vCountFinal_uid71_lzcShifterZ1_uid10_fxpToFPTest_q = maxCount_uid11_fxpToFPTest_q ELSE "0";
    inIsZero_uid12_fxpToFPTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => inIsZero_uid12_fxpToFPTest_qi, xout => inIsZero_uid12_fxpToFPTest_q, clk => clk, aclr => areset );

    -- udf_uid19_fxpToFPTest(COMPARE,18)@5
    udf_uid19_fxpToFPTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("000000000" & GND_q));
    udf_uid19_fxpToFPTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((9 downto 8 => expPreRnd_uid14_fxpToFPTest_q(7)) & expPreRnd_uid14_fxpToFPTest_q));
    udf_uid19_fxpToFPTest_o <= STD_LOGIC_VECTOR(SIGNED(udf_uid19_fxpToFPTest_a) - SIGNED(udf_uid19_fxpToFPTest_b));
    udf_uid19_fxpToFPTest_n(0) <= not (udf_uid19_fxpToFPTest_o(9));

    -- udfOrInZero_uid25_fxpToFPTest(LOGICAL,24)@5
    udfOrInZero_uid25_fxpToFPTest_q <= udf_uid19_fxpToFPTest_n or inIsZero_uid12_fxpToFPTest_q;

    -- excSelector_uid26_fxpToFPTest(BITJOIN,25)@5
    excSelector_uid26_fxpToFPTest_q <= ovf_uid21_fxpToFPTest_n & udfOrInZero_uid25_fxpToFPTest_q;

    -- expRPostExc_uid31_fxpToFPTest(MUX,30)@5
    expRPostExc_uid31_fxpToFPTest_s <= excSelector_uid26_fxpToFPTest_q;
    expRPostExc_uid31_fxpToFPTest_combproc: PROCESS (expRPostExc_uid31_fxpToFPTest_s, expPreRnd_uid14_fxpToFPTest_q, zP_uid15_fxpToFPTest_q, expInf_uid20_fxpToFPTest_q)
    BEGIN
        CASE (expRPostExc_uid31_fxpToFPTest_s) IS
            WHEN "00" => expRPostExc_uid31_fxpToFPTest_q <= expPreRnd_uid14_fxpToFPTest_q;
            WHEN "01" => expRPostExc_uid31_fxpToFPTest_q <= zP_uid15_fxpToFPTest_q;
            WHEN "10" => expRPostExc_uid31_fxpToFPTest_q <= expInf_uid20_fxpToFPTest_q;
            WHEN "11" => expRPostExc_uid31_fxpToFPTest_q <= expInf_uid20_fxpToFPTest_q;
            WHEN OTHERS => expRPostExc_uid31_fxpToFPTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracZ_uid23_fxpToFPTest(CONSTANT,22)
    fracZ_uid23_fxpToFPTest_q <= "00000000000000000000000";

    -- cStage_uid65_lzcShifterZ1_uid10_fxpToFPTest(BITJOIN,64)@3
    cStage_uid65_lzcShifterZ1_uid10_fxpToFPTest_q <= rVStage_uid61_lzcShifterZ1_uid10_fxpToFPTest_merged_bit_select_c & GND_q;

    -- vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest(MUX,65)@3
    vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_s <= vCount_uid62_lzcShifterZ1_uid10_fxpToFPTest_q;
    vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_combproc: PROCESS (vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_s, vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q, cStage_uid65_lzcShifterZ1_uid10_fxpToFPTest_q)
    BEGIN
        CASE (vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_s) IS
            WHEN "0" => vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_q <= vStagei_uid59_lzcShifterZ1_uid10_fxpToFPTest_q;
            WHEN "1" => vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_q <= cStage_uid65_lzcShifterZ1_uid10_fxpToFPTest_q;
            WHEN OTHERS => vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracRU_uid16_fxpToFPTest(BITSELECT,15)@3
    fracRU_uid16_fxpToFPTest_in <= vStagei_uid66_lzcShifterZ1_uid10_fxpToFPTest_q(14 downto 0);
    fracRU_uid16_fxpToFPTest_b <= fracRU_uid16_fxpToFPTest_in(14 downto 0);

    -- redist4_fracRU_uid16_fxpToFPTest_b_2(DELAY,81)
    redist4_fracRU_uid16_fxpToFPTest_b_2 : dspba_delay
    GENERIC MAP ( width => 15, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracRU_uid16_fxpToFPTest_b, xout => redist4_fracRU_uid16_fxpToFPTest_b_2_q, clk => clk, aclr => areset );

    -- fracRR_uid17_fxpToFPTest(BITJOIN,16)@5
    fracRR_uid17_fxpToFPTest_q <= redist4_fracRU_uid16_fxpToFPTest_b_2_q & zP_uid15_fxpToFPTest_q;

    -- excSelector_uid22_fxpToFPTest(LOGICAL,21)@5
    excSelector_uid22_fxpToFPTest_q <= inIsZero_uid12_fxpToFPTest_q or ovf_uid21_fxpToFPTest_n or udf_uid19_fxpToFPTest_n;

    -- fracRPostExc_uid24_fxpToFPTest(MUX,23)@5
    fracRPostExc_uid24_fxpToFPTest_s <= excSelector_uid22_fxpToFPTest_q;
    fracRPostExc_uid24_fxpToFPTest_combproc: PROCESS (fracRPostExc_uid24_fxpToFPTest_s, fracRR_uid17_fxpToFPTest_q, fracZ_uid23_fxpToFPTest_q)
    BEGIN
        CASE (fracRPostExc_uid24_fxpToFPTest_s) IS
            WHEN "0" => fracRPostExc_uid24_fxpToFPTest_q <= fracRR_uid17_fxpToFPTest_q;
            WHEN "1" => fracRPostExc_uid24_fxpToFPTest_q <= fracZ_uid23_fxpToFPTest_q;
            WHEN OTHERS => fracRPostExc_uid24_fxpToFPTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- outRes_uid32_fxpToFPTest(BITJOIN,31)@5
    outRes_uid32_fxpToFPTest_q <= redist6_signX_uid6_fxpToFPTest_b_5_q & expRPostExc_uid31_fxpToFPTest_q & fracRPostExc_uid24_fxpToFPTest_q;

    -- xOut(GPOUT,4)@5
    q <= outRes_uid32_fxpToFPTest_q;

END normal;
