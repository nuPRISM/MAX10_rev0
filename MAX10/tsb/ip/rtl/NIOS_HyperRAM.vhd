-- Copyright (C) 1991-2016 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions
-- and other software and tools, and its AMPP partner logic
-- functions, and any output files from any of the foregoing
-- (including device programming or simulation files), and any
-- associated documentation or information are expressly subject
-- to the terms and conditions of the Altera Program License
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other
-- applicable license agreement, including, without limitation,
-- that your use is for the sole purpose of programming logic
-- devices manufactured by Altera and sold by Altera or its
-- authorized distributors.  Please refer to the applicable
-- agreement for further details.

-- PROGRAM    "Quartus Prime"
-- VERSION    "Version 16.0.0 Build 211 04/27/2016 SJ Lite Edition"
-- CREATED    "Mon Apr 24 09:13:09 2017"

--  Standard libraries: 
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


ENTITY NIOS_HyperRAM IS
  PORT
  (
--global signals
   c10_resetn    :  IN  STD_LOGIC;
   c10_clk50m    :  IN  STD_LOGIC;
   clk100        :  IN  STD_LOGIC; --not used

--User IO
    arduino_led    :  OUT  STD_LOGIC_VECTOR(4 DOWNTO 0);
    led            :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
    arduino_button :  IN   STD_LOGIC_VECTOR(1 DOWNTO 0);
    button         :  IN   STD_LOGIC_VECTOR(1 DOWNTO 0);


--Hyperbus Signals
    hbus_rston :  IN     STD_LOGIC;                     --Hyperbus signals : reset from HyperFlash
    hbus_intn  :  IN     STD_LOGIC;                     --Hyperbus signals : interrupt  from HyperFlash
    hbus_rwds  :  INOUT  STD_LOGIC;                     --Hyperbus signals : read strobe - write mask
    hbus_clk0p :  OUT    STD_LOGIC;                     --Hyperbus signals : Clk diff (p)
    hbus_clk0n :  OUT    STD_LOGIC;                     --Hyperbus signals : Clk diff (n)
    hbus_clk1p :  OUT    STD_LOGIC;                     --Hyperbus signals : Clk diff (p)
    hbus_clk1n :  OUT    STD_LOGIC;                     --Hyperbus signals : Clk diff (n)
    hbus_cs1n  :  OUT    STD_LOGIC;                     --Hyperbus signals : HyperFLash Chip select
    hbus_cs2n  :  OUT    STD_LOGIC;                     --Hyperbus signals : HyperRAM Chip Select
    hbus_dq    :  INOUT  STD_LOGIC_VECTOR(7 DOWNTO 0)   --Hyperbus signals : Data
  );
END NIOS_HyperRAM;

ARCHITECTURE bdf_type OF NIOS_HyperRAM IS

COMPONENT hypernios
  PORT(
     clk_clk                            : IN    STD_LOGIC;
     rst_reset_n                        : IN    STD_LOGIC;
                                        
     pio_0_external_connection_export   : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
     pio_1_external_connection_export   : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
     pio_2_external_connection_export   : OUT   STD_LOGIC_VECTOR(4 DOWNTO 0);

     hyperbus_controller_top_HB_RSTn    : OUT   STD_LOGIC;
     hyperbus_controller_top_HB_WPn     : OUT   STD_LOGIC;
     hyperbus_controller_top_HB_INTn    : IN    STD_LOGIC;
     hyperbus_controller_top_HB_RWDS    : INOUT STD_LOGIC;
     hyperbus_controller_top_HB_RSTOn   : IN    STD_LOGIC;
     hyperbus_controller_top_HB_dq      : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     hyperbus_controller_top_HB_CLK0    : OUT   STD_LOGIC;
     hyperbus_controller_top_HB_CLK0n   : OUT   STD_LOGIC;
     hyperbus_controller_top_HB_CLK1    : OUT   STD_LOGIC;
     hyperbus_controller_top_HB_CLK1n   : OUT   STD_LOGIC;
     hyperbus_controller_top_HB_CS0n    : OUT   STD_LOGIC;
     hyperbus_controller_top_HB_CS1n    : OUT   STD_LOGIC
  );
END COMPONENT;

signal iled           : STD_LOGIC_VECTOR(7  DOWNTO 0);
BEGIN


----------------------------------------
--hyperios
----------------------------------------
b2v_inst : hypernios
PORT MAP(
     clk_clk                            => c10_clk50m,
     rst_reset_n                        => c10_resetn,

     --PIO
     pio_0_external_connection_export   => iled,
     pio_1_external_connection_export   => arduino_button,
     pio_2_external_connection_export   => arduino_led,

     --hyperbus signals
     hyperbus_controller_top_HB_WPn     => open ,
     hyperbus_controller_top_HB_RSTn    => open ,
     hyperbus_controller_top_HB_INTn    => hbus_intn,
     hyperbus_controller_top_HB_RWDS    => hbus_rwds,
     hyperbus_controller_top_HB_RSTOn   => hbus_rston,
     hyperbus_controller_top_HB_dq      => hbus_dq,
     hyperbus_controller_top_HB_CLK0    => hbus_clk0p,
     hyperbus_controller_top_HB_CLK0n   => hbus_clk0n,
     hyperbus_controller_top_HB_CLK1    => hbus_clk1p,
     hyperbus_controller_top_HB_CLK1n   => hbus_clk1n,
     hyperbus_controller_top_HB_CS0n    => hbus_cs1n,
     hyperbus_controller_top_HB_CS1n    => hbus_cs2n
);


---------------------------------------
--LEDS
---------------------------------------
   led(0)  <= '0' when (iled(0) = '1') else '1';  
   led(1)  <= '0' when (iled(1) = '1') else '1';  
   led(2)  <= '0' when (iled(2) = '1') else '1';  
   led(3)  <= '0' when (iled(3) = '1') else '1';  
   led(4)  <= '0' when (iled(4) = '1') else '1';  
   led(5)  <= '0' when (iled(5) = '1') else '1';  
   led(6)  <= '0' when (iled(6) = '1') else '1';  
   led(7)  <= '0' when (iled(7) = '1') else '1';  

END bdf_type;