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

-- VHDL created from fp_complex_mult_altera_fp_functions_181_jqzgwvq
-- VHDL created on Tue Jul 09 13:01:53 2019


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

entity fp_complex_mult_altera_fp_functions_181_jqzgwvq is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        c : in std_logic_vector(31 downto 0);  -- float32_m23
        d : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        r : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end fp_complex_mult_altera_fp_functions_181_jqzgwvq;

architecture normal of fp_complex_mult_altera_fp_functions_181_jqzgwvq is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracB_uid6_fpComplexMulTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expB_uid7_fpComplexMulTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal signB_uid8_fpComplexMulTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal invSignB_uid9_fpComplexMulTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal mB_uid10_fpComplexMulTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal rReal_uid11_fpComplexMulTest_impl_ay0 : STD_LOGIC_VECTOR (31 downto 0);
    signal rReal_uid11_fpComplexMulTest_impl_az0 : STD_LOGIC_VECTOR (31 downto 0);
    signal rReal_uid11_fpComplexMulTest_impl_q0 : STD_LOGIC_VECTOR (31 downto 0);
    signal rReal_uid11_fpComplexMulTest_impl_reset0 : std_logic;
    signal rReal_uid11_fpComplexMulTest_impl_rReal_uid11_fpComplexMulTest_impl_ena0 : std_logic;
    signal rReal_uid11_fpComplexMulTest_impl_ay1 : STD_LOGIC_VECTOR (31 downto 0);
    signal rReal_uid11_fpComplexMulTest_impl_az1 : STD_LOGIC_VECTOR (31 downto 0);
    signal rReal_uid11_fpComplexMulTest_impl_chain1 : STD_LOGIC_VECTOR (31 downto 0);
    signal rReal_uid11_fpComplexMulTest_impl_reset1 : std_logic;
    signal rReal_uid11_fpComplexMulTest_impl_rReal_uid11_fpComplexMulTest_impl_ena1 : std_logic;
    signal rImag_uid12_fpComplexMulTest_impl_ay0 : STD_LOGIC_VECTOR (31 downto 0);
    signal rImag_uid12_fpComplexMulTest_impl_az0 : STD_LOGIC_VECTOR (31 downto 0);
    signal rImag_uid12_fpComplexMulTest_impl_q0 : STD_LOGIC_VECTOR (31 downto 0);
    signal rImag_uid12_fpComplexMulTest_impl_reset0 : std_logic;
    signal rImag_uid12_fpComplexMulTest_impl_rImag_uid12_fpComplexMulTest_impl_ena0 : std_logic;
    signal rImag_uid12_fpComplexMulTest_impl_ay1 : STD_LOGIC_VECTOR (31 downto 0);
    signal rImag_uid12_fpComplexMulTest_impl_az1 : STD_LOGIC_VECTOR (31 downto 0);
    signal rImag_uid12_fpComplexMulTest_impl_chain1 : STD_LOGIC_VECTOR (31 downto 0);
    signal rImag_uid12_fpComplexMulTest_impl_reset1 : std_logic;
    signal rImag_uid12_fpComplexMulTest_impl_rImag_uid12_fpComplexMulTest_impl_ena1 : std_logic;
    signal redist0_xIn_a_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist1_xIn_c_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist2_xIn_d_1_q : STD_LOGIC_VECTOR (31 downto 0);

begin


    -- redist2_xIn_d_1(DELAY,18)
    redist2_xIn_d_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => d, xout => redist2_xIn_d_1_q, clk => clk, aclr => areset );

    -- redist0_xIn_a_1(DELAY,16)
    redist0_xIn_a_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => a, xout => redist0_xIn_a_1_q, clk => clk, aclr => areset );

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- rImag_uid12_fpComplexMulTest_impl(FPCOLUMN,15)@0
    -- in y0@1
    -- in z0@1
    -- out q0@5
    rImag_uid12_fpComplexMulTest_impl_ay0 <= STD_LOGIC_VECTOR(redist0_xIn_a_1_q);
    rImag_uid12_fpComplexMulTest_impl_az0 <= STD_LOGIC_VECTOR(redist2_xIn_d_1_q);
    rImag_uid12_fpComplexMulTest_impl_reset0 <= areset;
    rImag_uid12_fpComplexMulTest_impl_rImag_uid12_fpComplexMulTest_impl_ena0 <= '1';
    rImag_uid12_fpComplexMulTest_impl_DSP0 : twentynm_fp_mac
    GENERIC MAP (
        operation_mode => "sp_mult_add",
        use_chainin => "true",
        ay_clock => "0",
        az_clock => "0",
        mult_pipeline_clock => "0",
        adder_input_clock => "0",
        ax_chainin_pl_clock => "0",
        output_clock => "0"
    )
    PORT MAP (
        aclr(0) => rImag_uid12_fpComplexMulTest_impl_reset0,
        aclr(1) => rImag_uid12_fpComplexMulTest_impl_reset0,
        clk(0) => clk,
        clk(1) => '0',
        clk(2) => '0',
        ena(0) => rImag_uid12_fpComplexMulTest_impl_rImag_uid12_fpComplexMulTest_impl_ena0,
        ena(1) => '0',
        ena(2) => '0',
        ay => rImag_uid12_fpComplexMulTest_impl_ay0,
        az => rImag_uid12_fpComplexMulTest_impl_az0,
        chainin => rImag_uid12_fpComplexMulTest_impl_chain1,
        resulta => rImag_uid12_fpComplexMulTest_impl_q0
    );
    rImag_uid12_fpComplexMulTest_impl_ay1 <= STD_LOGIC_VECTOR(b);
    rImag_uid12_fpComplexMulTest_impl_az1 <= STD_LOGIC_VECTOR(c);
    rImag_uid12_fpComplexMulTest_impl_reset1 <= areset;
    rImag_uid12_fpComplexMulTest_impl_rImag_uid12_fpComplexMulTest_impl_ena1 <= '1';
    rImag_uid12_fpComplexMulTest_impl_DSP1 : twentynm_fp_mac
    GENERIC MAP (
        operation_mode => "sp_mult",
        ay_clock => "0",
        az_clock => "0",
        mult_pipeline_clock => "0",
        output_clock => "0"
    )
    PORT MAP (
        aclr(0) => rImag_uid12_fpComplexMulTest_impl_reset1,
        aclr(1) => rImag_uid12_fpComplexMulTest_impl_reset1,
        clk(0) => clk,
        clk(1) => '0',
        clk(2) => '0',
        ena(0) => rImag_uid12_fpComplexMulTest_impl_rImag_uid12_fpComplexMulTest_impl_ena1,
        ena(1) => '0',
        ena(2) => '0',
        ay => rImag_uid12_fpComplexMulTest_impl_ay1,
        az => rImag_uid12_fpComplexMulTest_impl_az1,
        chainout => rImag_uid12_fpComplexMulTest_impl_chain1
    );

    -- signB_uid8_fpComplexMulTest(BITSELECT,7)@0
    signB_uid8_fpComplexMulTest_b <= STD_LOGIC_VECTOR(b(31 downto 31));

    -- invSignB_uid9_fpComplexMulTest(LOGICAL,8)@0
    invSignB_uid9_fpComplexMulTest_q <= not (signB_uid8_fpComplexMulTest_b);

    -- expB_uid7_fpComplexMulTest(BITSELECT,6)@0
    expB_uid7_fpComplexMulTest_b <= b(30 downto 23);

    -- fracB_uid6_fpComplexMulTest(BITSELECT,5)@0
    fracB_uid6_fpComplexMulTest_b <= b(22 downto 0);

    -- mB_uid10_fpComplexMulTest(BITJOIN,9)@0
    mB_uid10_fpComplexMulTest_q <= invSignB_uid9_fpComplexMulTest_q & expB_uid7_fpComplexMulTest_b & fracB_uid6_fpComplexMulTest_b;

    -- redist1_xIn_c_1(DELAY,17)
    redist1_xIn_c_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => c, xout => redist1_xIn_c_1_q, clk => clk, aclr => areset );

    -- rReal_uid11_fpComplexMulTest_impl(FPCOLUMN,14)@0
    -- in y0@1
    -- in z0@1
    -- out q0@5
    rReal_uid11_fpComplexMulTest_impl_ay0 <= STD_LOGIC_VECTOR(redist0_xIn_a_1_q);
    rReal_uid11_fpComplexMulTest_impl_az0 <= STD_LOGIC_VECTOR(redist1_xIn_c_1_q);
    rReal_uid11_fpComplexMulTest_impl_reset0 <= areset;
    rReal_uid11_fpComplexMulTest_impl_rReal_uid11_fpComplexMulTest_impl_ena0 <= '1';
    rReal_uid11_fpComplexMulTest_impl_DSP0 : twentynm_fp_mac
    GENERIC MAP (
        operation_mode => "sp_mult_add",
        use_chainin => "true",
        ay_clock => "0",
        az_clock => "0",
        mult_pipeline_clock => "0",
        adder_input_clock => "0",
        ax_chainin_pl_clock => "0",
        output_clock => "0"
    )
    PORT MAP (
        aclr(0) => rReal_uid11_fpComplexMulTest_impl_reset0,
        aclr(1) => rReal_uid11_fpComplexMulTest_impl_reset0,
        clk(0) => clk,
        clk(1) => '0',
        clk(2) => '0',
        ena(0) => rReal_uid11_fpComplexMulTest_impl_rReal_uid11_fpComplexMulTest_impl_ena0,
        ena(1) => '0',
        ena(2) => '0',
        ay => rReal_uid11_fpComplexMulTest_impl_ay0,
        az => rReal_uid11_fpComplexMulTest_impl_az0,
        chainin => rReal_uid11_fpComplexMulTest_impl_chain1,
        resulta => rReal_uid11_fpComplexMulTest_impl_q0
    );
    rReal_uid11_fpComplexMulTest_impl_ay1 <= STD_LOGIC_VECTOR(mB_uid10_fpComplexMulTest_q);
    rReal_uid11_fpComplexMulTest_impl_az1 <= STD_LOGIC_VECTOR(d);
    rReal_uid11_fpComplexMulTest_impl_reset1 <= areset;
    rReal_uid11_fpComplexMulTest_impl_rReal_uid11_fpComplexMulTest_impl_ena1 <= '1';
    rReal_uid11_fpComplexMulTest_impl_DSP1 : twentynm_fp_mac
    GENERIC MAP (
        operation_mode => "sp_mult",
        ay_clock => "0",
        az_clock => "0",
        mult_pipeline_clock => "0",
        output_clock => "0"
    )
    PORT MAP (
        aclr(0) => rReal_uid11_fpComplexMulTest_impl_reset1,
        aclr(1) => rReal_uid11_fpComplexMulTest_impl_reset1,
        clk(0) => clk,
        clk(1) => '0',
        clk(2) => '0',
        ena(0) => rReal_uid11_fpComplexMulTest_impl_rReal_uid11_fpComplexMulTest_impl_ena1,
        ena(1) => '0',
        ena(2) => '0',
        ay => rReal_uid11_fpComplexMulTest_impl_ay1,
        az => rReal_uid11_fpComplexMulTest_impl_az1,
        chainout => rReal_uid11_fpComplexMulTest_impl_chain1
    );

    -- xOut(GPOUT,4)@5
    q <= rReal_uid11_fpComplexMulTest_impl_q0;
    r <= rImag_uid12_fpComplexMulTest_impl_q0;

END normal;
