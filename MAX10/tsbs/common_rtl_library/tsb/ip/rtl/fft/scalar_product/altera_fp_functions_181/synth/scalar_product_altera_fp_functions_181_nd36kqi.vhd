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

-- VHDL created from scalar_product_altera_fp_functions_181_nd36kqi
-- VHDL created on Tue Jul 09 13:03:09 2019


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

entity scalar_product_altera_fp_functions_181_nd36kqi is
    port (
        a0 : in std_logic_vector(31 downto 0);  -- float32_m23
        b0 : in std_logic_vector(31 downto 0);  -- float32_m23
        a1 : in std_logic_vector(31 downto 0);  -- float32_m23
        b1 : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end scalar_product_altera_fp_functions_181_nd36kqi;

architecture normal of scalar_product_altera_fp_functions_181_nd36kqi is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fpScalarProduct_sp0_impl_ay0 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpScalarProduct_sp0_impl_az0 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpScalarProduct_sp0_impl_q0 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpScalarProduct_sp0_impl_reset0 : std_logic;
    signal fpScalarProduct_sp0_impl_fpScalarProduct_sp0_impl_ena0 : std_logic;
    signal fpScalarProduct_sp0_impl_ay1 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpScalarProduct_sp0_impl_az1 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpScalarProduct_sp0_impl_chain1 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpScalarProduct_sp0_impl_reset1 : std_logic;
    signal fpScalarProduct_sp0_impl_fpScalarProduct_sp0_impl_ena1 : std_logic;
    signal redist0_xIn_a0_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist1_xIn_b0_1_q : STD_LOGIC_VECTOR (31 downto 0);

begin


    -- redist1_xIn_b0_1(DELAY,8)
    redist1_xIn_b0_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => b0, xout => redist1_xIn_b0_1_q, clk => clk, aclr => areset );

    -- redist0_xIn_a0_1(DELAY,7)
    redist0_xIn_a0_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => a0, xout => redist0_xIn_a0_1_q, clk => clk, aclr => areset );

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- fpScalarProduct_sp0_impl(FPCOLUMN,6)@0
    -- in y0@1
    -- in z0@1
    -- out q0@5
    fpScalarProduct_sp0_impl_ay0 <= STD_LOGIC_VECTOR(redist0_xIn_a0_1_q);
    fpScalarProduct_sp0_impl_az0 <= STD_LOGIC_VECTOR(redist1_xIn_b0_1_q);
    fpScalarProduct_sp0_impl_reset0 <= areset;
    fpScalarProduct_sp0_impl_fpScalarProduct_sp0_impl_ena0 <= '1';
    fpScalarProduct_sp0_impl_DSP0 : twentynm_fp_mac
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
        aclr(0) => fpScalarProduct_sp0_impl_reset0,
        aclr(1) => fpScalarProduct_sp0_impl_reset0,
        clk(0) => clk,
        clk(1) => '0',
        clk(2) => '0',
        ena(0) => fpScalarProduct_sp0_impl_fpScalarProduct_sp0_impl_ena0,
        ena(1) => '0',
        ena(2) => '0',
        ay => fpScalarProduct_sp0_impl_ay0,
        az => fpScalarProduct_sp0_impl_az0,
        chainin => fpScalarProduct_sp0_impl_chain1,
        resulta => fpScalarProduct_sp0_impl_q0
    );
    fpScalarProduct_sp0_impl_ay1 <= STD_LOGIC_VECTOR(a1);
    fpScalarProduct_sp0_impl_az1 <= STD_LOGIC_VECTOR(b1);
    fpScalarProduct_sp0_impl_reset1 <= areset;
    fpScalarProduct_sp0_impl_fpScalarProduct_sp0_impl_ena1 <= '1';
    fpScalarProduct_sp0_impl_DSP1 : twentynm_fp_mac
    GENERIC MAP (
        operation_mode => "sp_mult",
        ay_clock => "0",
        az_clock => "0",
        mult_pipeline_clock => "0",
        output_clock => "0"
    )
    PORT MAP (
        aclr(0) => fpScalarProduct_sp0_impl_reset1,
        aclr(1) => fpScalarProduct_sp0_impl_reset1,
        clk(0) => clk,
        clk(1) => '0',
        clk(2) => '0',
        ena(0) => fpScalarProduct_sp0_impl_fpScalarProduct_sp0_impl_ena1,
        ena(1) => '0',
        ena(2) => '0',
        ay => fpScalarProduct_sp0_impl_ay1,
        az => fpScalarProduct_sp0_impl_az1,
        chainout => fpScalarProduct_sp0_impl_chain1
    );

    -- xOut(GPOUT,4)@5
    q <= fpScalarProduct_sp0_impl_q0;

END normal;
