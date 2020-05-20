-- ****************************************************************************
-- ******************** (C) 2011 RadioComp ApS            *********************
-- ******************** Krakasvej 17                      *********************
-- ******************** DK-3400 Hilleroed, Denmark        *********************
-- ****************************************************************************
-- ****************** JESD204AB (JESD)                       ******************
-- ****************************************************************************
-- Filename : jesd_tx_cpuif_pkg.vhd
-- Author   : KGO
-- Contents : Package with register addresses pertaining to jesd_rx_cpuif.vhd
-- ****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package jesd_tx_cpuif_pkg is

  -----------------------------------------------------------------------------
  -- Values mapped into ID register
  -----------------------------------------------------------------------------

  constant JESD204B_TX_ID      : std_logic_vector(7 downto 0) := x"00"; 
  constant JESD204B_TX_VERSION : std_logic_vector(7 downto 0) := x"01";

  -----------------------------------------------------------------------------
  -- Register memory map
  -----------------------------------------------------------------------------
  
  constant REG_JESD_TX_ID           : std_logic_vector(11 downto 0) := conv_std_logic_vector(00,10) & "00";   -- ID
  constant REG_JESD_TX_CS           : std_logic_vector(11 downto 0) := conv_std_logic_vector(01,10) & "00";   -- Number of control bits per sample
  constant REG_JESD_TX_F            : std_logic_vector(11 downto 0) := conv_std_logic_vector(02,10) & "00";   -- Number of octets per frame
  constant REG_JESD_TX_HD           : std_logic_vector(11 downto 0) := conv_std_logic_vector(03,10) & "00";   -- High Density format 
  constant REG_JESD_TX_K            : std_logic_vector(11 downto 0) := conv_std_logic_vector(04,10) & "00";   -- Number of frames per multi frame
  constant REG_JESD_TX_L            : std_logic_vector(11 downto 0) := conv_std_logic_vector(05,10) & "00";   -- Number of lanes per converter device
  constant REG_JESD_TX_M            : std_logic_vector(11 downto 0) := conv_std_logic_vector(06,10) & "00";   -- Number of converters per device
  constant REG_JESD_TX_N            : std_logic_vector(11 downto 0) := conv_std_logic_vector(07,10) & "00";   -- Number of bits per sample
  constant REG_JESD_TX_NTOTAL       : std_logic_vector(11 downto 0) := conv_std_logic_vector(08,10) & "00";   -- Total number of bits per sample
  constant REG_JESD_TX_S            : std_logic_vector(11 downto 0) := conv_std_logic_vector(09,10) & "00";   -- Number of samples per converter per frame cycle
  constant REG_JESD_TX_SCR          : std_logic_vector(11 downto 0) := conv_std_logic_vector(10,10) & "00";   -- Scrambling enabled
  constant REG_JESD_TX_ENABLEMODULE : std_logic_vector(11 downto 0) := conv_std_logic_vector(11,10) & "00";   -- Enable operation of teh module
  constant REG_JESD_TX_TAILBITS     : std_logic_vector(11 downto 0) := conv_std_logic_vector(12,10) & "00";   -- Tail bits insertion
  constant REG_JESD_TX_TEST_MODE    : std_logic_vector(11 downto 0) := conv_std_logic_vector(13,10) & "00";   -- Enable link layer test        
  constant REG_JESD_TX_SYNC_STATUS  : std_logic_vector(11 downto 0) := conv_std_logic_vector(14,10) & "00";   -- Are the modules in SYNC or not?
  constant REG_JESD_TX_SUBCLASS     : std_logic_vector(11 downto 0) := conv_std_logic_vector(15,10) & "00";   -- Subclass

  constant REG_JESD_TX_BUF_LEVEL    : std_logic_vector(11 downto 0) := conv_std_logic_vector(32,10) & "00";   -- Number of elements in the the FIFO pertaining
  constant REG_JESD_TX_ILA          : std_logic_vector(11 downto 0) := conv_std_logic_vector(128,10) & "00";  -- ILA TX sequence

end jesd_tx_cpuif_pkg;
