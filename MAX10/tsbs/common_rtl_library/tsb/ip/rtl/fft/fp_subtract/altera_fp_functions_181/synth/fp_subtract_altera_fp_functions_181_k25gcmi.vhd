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

-- VHDL created from fp_subtract_altera_fp_functions_181_k25gcmi
-- VHDL created on Tue Jul 09 13:02:23 2019


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

entity fp_subtract_altera_fp_functions_181_k25gcmi is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end fp_subtract_altera_fp_functions_181_k25gcmi;

architecture normal of fp_subtract_altera_fp_functions_181_k25gcmi is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fpSubTest_impl_ax0 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpSubTest_impl_ay0 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpSubTest_impl_q0 : STD_LOGIC_VECTOR (31 downto 0);
    signal fpSubTest_impl_reset0 : std_logic;
    signal fpSubTest_impl_fpSubTest_impl_ena0 : std_logic;

begin


    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- fpSubTest_impl(FPCOLUMN,5)@0
    -- out q0@3
    fpSubTest_impl_ax0 <= STD_LOGIC_VECTOR(b);
    fpSubTest_impl_ay0 <= STD_LOGIC_VECTOR(a);
    fpSubTest_impl_reset0 <= areset;
    fpSubTest_impl_fpSubTest_impl_ena0 <= '1';
    fpSubTest_impl_DSP0 : twentynm_fp_mac
    GENERIC MAP (
        operation_mode => "sp_add",
        adder_subtract => "true",
        ax_clock => "0",
        ay_clock => "0",
        adder_input_clock => "0",
        output_clock => "0"
    )
    PORT MAP (
        aclr(0) => fpSubTest_impl_reset0,
        aclr(1) => fpSubTest_impl_reset0,
        clk(0) => clk,
        clk(1) => '0',
        clk(2) => '0',
        ena(0) => fpSubTest_impl_fpSubTest_impl_ena0,
        ena(1) => '0',
        ena(2) => '0',
        ax => fpSubTest_impl_ax0,
        ay => fpSubTest_impl_ay0,
        resulta => fpSubTest_impl_q0
    );

    -- xOut(GPOUT,4)@3
    q <= fpSubTest_impl_q0;

END normal;
