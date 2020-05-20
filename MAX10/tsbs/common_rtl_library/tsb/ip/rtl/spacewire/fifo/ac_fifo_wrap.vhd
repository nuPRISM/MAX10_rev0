---====================== Start Software License ======================---
--==                                                                  ==--
--== This license governs the use of this software, and your use of   ==--
--== this software constitutes acceptance of this license. Agreement  ==--
--== with all points is required to use this software.                ==--
--==                                                                  ==--
--== 1. You may use this software freely for personal use.            ==--
--==                                                                  ==--
--== 2. You may use this software freely to determine feasibility for ==--
--==    commercial use.                                               ==--
--==                                                                  ==--
--== 3. You may use this software for commercial use if the author    ==--
--==    has given you written consent.                                ==--
--==                                                                  ==--
--== 4. You may modify this software provided you do not remove the   ==--
--==    license and copyright notice.                                 ==--
--==                                                                  ==--
--== 5. You may distribute this software and derivative works to      ==--
--==    personal friends and work colleagues only.                    ==--
--==                                                                  ==--
--== 6. You agree that this software comes “as-is” and with no        ==--
--==    warranty whatsoever, either expressed or implied, including,  ==--
--==    but not limited to, warranties of merchantability or fitness  ==--
--==    for a particular purpose.                                     ==--
--==                                                                  ==--
--== 7. You agree that the author will not be liable for any damages  ==--
--==    relating from the use of this software, including direct,     ==--
--==    indirect, consequential or incidental. This software is used  ==--
--==    entirely at your own risk and should it prove defective, you  ==--
--==    will assume full responsibility for all costs associated with ==--
--==    servicing, repair or correction.                              ==--
--==                                                                  ==--
--== Your rights under this license are terminated immediately if you ==--
--== breach it in any way.                                            ==--
--==                                                                  ==--
---======================= End Software License =======================---


---====================== Start Copyright Notice ======================---
--==                                                                  ==--
--== Filename ..... ac_fifo_wrap.vhd                                  ==--
--== Download ..... http://www.spacewire.co.uk                        ==--
--== Author ....... Steve Haywood (steve.haywood@ukonline.co.uk)      ==--
--== Copyright .... Copyright (c) 2004 Steve Haywood                  ==--
--== Project ...... Autonomous Cascadable Dual Port FIFO              ==--
--== Version ...... 1.00                                              ==--
--== Conception ... 12 June 2004                                      ==--
--== Modified ..... N/A                                               ==--
--==                                                                  ==--
---======================= End Copyright Notice =======================---


---========================= Start Description ========================---
--==                                                                  ==--
--== This module converts a standard Xilinx dual port FIFO into an    ==--
--== Autonomous Cascadable Dual Port FIFO. The module is simply a     ==--
--== wrapper that adds the neccassary handshake logic to a standard   ==--
--== FIFO design.                                                     ==--
--==                                                                  ==--
---========================== End Description =========================---

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ac_fifo_wrap IS
  GENERIC(
          --== Data Width ==--

          data_width : NATURAL := 8
         );
  PORT(
       --==  General Interface ==--

       rst    : IN  STD_LOGIC;
       clk    : IN  STD_LOGIC;

       --== Input Interface ==--

       nwrite : IN  STD_LOGIC;
       full   : OUT STD_LOGIC;
       din    : IN  STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);

       --== Output Interface ==--

       empty  : OUT STD_LOGIC;
       nread  : IN  STD_LOGIC;
       dout   : OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0)
      );
END ac_fifo_wrap;


ARCHITECTURE rtl OF ac_fifo_wrap IS

---==========================---
--== Component Declarations ==--
---==========================---

COMPONENT xilinx_fifo
  PORT(sinit : IN  STD_LOGIC;
       clk   : IN  STD_LOGIC;
       din   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
       rd_en : IN  STD_LOGIC;
       wr_en : IN  STD_LOGIC;
       dout  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       full  : OUT STD_LOGIC;
       empty : OUT STD_LOGIC
      );
END COMPONENT;

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL empty_int : STD_LOGIC;
SIGNAL empty_i   : STD_LOGIC;
SIGNAL full_i    : STD_LOGIC;
SIGNAL rd_en     : STD_LOGIC;
SIGNAL wr_en     : STD_LOGIC;

BEGIN

  ---====================---
  --== FIFO write logic ==--
  ---====================---

  wr_en <= NOT(full_i) AND NOT(nwrite);

  full <= full_i;

  ---================================---
  --== Xilinx FIFO (CoreGen Module) ==--
  ---================================---

  U0 : xilinx_fifo
    PORT MAP
      (sinit => rst,
       clk   => clk,
       din   => din,
       rd_en => rd_en,
       wr_en => wr_en,
       dout  => dout,
       full  => full_i,
       empty => empty_int
      );

  ---===================---
  --== FIFO read logic ==--
  ---===================---

  rd_en <= NOT(empty_int) AND (empty_i OR NOT(nread));

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        empty_i <= '1';
      ELSE
        empty_i <= empty_int AND (empty_i OR NOT(nread));
      END IF;
    END IF;
  END PROCESS;

  empty <= empty_i;

END rtl;
