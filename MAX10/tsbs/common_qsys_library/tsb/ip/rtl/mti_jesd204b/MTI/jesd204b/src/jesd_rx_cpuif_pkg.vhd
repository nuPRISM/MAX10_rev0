-- ****************************************************************************
-- ******************** (C) 2011 RadioComp ApS            *********************
-- ******************** Krakasvej 17                      *********************
-- ******************** DK-3400 Hilleroed, Denmark        *********************
-- ****************************************************************************
-- ****************** JESD204AB (JESD)                       ******************
-- ****************************************************************************
-- Filename : jesd_cpuif_pkg.vhd
-- Author   : KGOjesd
-- Contents : Package with register addresses pertaining to jesd_cpuif.vhd
-- ****************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package jesd_rx_cpuif_pkg is

  -----------------------------------------------------------------------------
  -- Values mapped into ID register
  -----------------------------------------------------------------------------

  constant JESD204B_RX_ID      : std_logic_vector(7 downto 0) := x"01"; 
  constant JESD204B_RX_VERSION : std_logic_vector(7 downto 0) := x"01";

  -----------------------------------------------------------------------------
  -- Register memory map
  -----------------------------------------------------------------------------
  
  constant REG_JESD_RX_ID           : std_logic_vector(11 downto 0) := conv_std_logic_vector(00,10) & "00";   -- ID
  constant REG_JESD_RX_CS           : std_logic_vector(11 downto 0) := conv_std_logic_vector(01,10) & "00";   -- Number of control bits per sample
  constant REG_JESD_RX_F            : std_logic_vector(11 downto 0) := conv_std_logic_vector(02,10) & "00";   -- Number of octets per frame
  constant REG_JESD_RX_HD           : std_logic_vector(11 downto 0) := conv_std_logic_vector(03,10) & "00";   -- High Density format 
  constant REG_JESD_RX_K            : std_logic_vector(11 downto 0) := conv_std_logic_vector(04,10) & "00";   -- Number of frames per multi frame
  constant REG_JESD_RX_L            : std_logic_vector(11 downto 0) := conv_std_logic_vector(05,10) & "00";   -- Number of lanes per converter device
  constant REG_JESD_RX_M            : std_logic_vector(11 downto 0) := conv_std_logic_vector(06,10) & "00";   -- Number of converters per device
  constant REG_JESD_RX_N            : std_logic_vector(11 downto 0) := conv_std_logic_vector(07,10) & "00";   -- Number of bits per sample
  constant REG_JESD_RX_NTOTAL       : std_logic_vector(11 downto 0) := conv_std_logic_vector(08,10) & "00";   -- Total number of bits per sample
  constant REG_JESD_RX_S            : std_logic_vector(11 downto 0) := conv_std_logic_vector(09,10) & "00";   -- Number of samples per converter per frame cycle
  constant REG_JESD_RX_SCR          : std_logic_vector(11 downto 0) := conv_std_logic_vector(10,10) & "00";   -- Scrambling enabled
  constant REG_JESD_RX_ENABLEMODULE : std_logic_vector(11 downto 0) := conv_std_logic_vector(11,10) & "00";   -- Enable operation of teh module
  constant REG_JESD_RX_TAILBITS     : std_logic_vector(11 downto 0) := conv_std_logic_vector(12,10) & "00";   -- Tail bits insertion
  constant REG_JESD_RX_TEST_MODE    : std_logic_vector(11 downto 0) := conv_std_logic_vector(13,10) & "00";   -- Enable link layer test        
  constant REG_JESD_RX_SYNC_STATUS  : std_logic_vector(11 downto 0) := conv_std_logic_vector(14,10) & "00";   -- Are the modules in SYNC or not?
  constant REG_JESD_RX_SUBCLASS     : std_logic_vector(11 downto 0) := conv_std_logic_vector(15,10) & "00";   -- Subclass
  constant REG_JESD_RX_ILA_VALID    : std_logic_vector(11 downto 0) := conv_std_logic_vector(16,10) & "00";   -- ILA RX sequence valid indications per lane
  constant REG_JESD_RX_SYSREF_DELAY : std_logic_vector(11 downto 0) := conv_std_logic_vector(17,10) & "00";   -- Delay from SYSREF to start of demapping

  constant REG_JESD_RX_BUF_LEVEL    : std_logic_vector(11 downto 0) := conv_std_logic_vector(32,10) & "00";   -- Number of elements in the the FIFO pertaining to lane 0
  constant REG_JESD_RX_ERRORCOUNTER : std_logic_vector(11 downto 0) := conv_std_logic_vector(40,10) & "00";   -- Number of detected errors on lane 0
  constant REG_JESD_RX_LANE_STATUS  : std_logic_vector(11 downto 0) := conv_std_logic_vector(48,10) & "00";   -- Lane state

  constant REG_JESD_RX_ILA          : std_logic_vector(11 downto 0) := conv_std_logic_vector(128,10) & "00";  -- ILA RX sequence (8 words per LANE)

end jesd_rx_cpuif_pkg;
