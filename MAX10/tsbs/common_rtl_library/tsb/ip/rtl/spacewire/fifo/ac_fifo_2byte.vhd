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
--== Filename ..... ac_fifo_2byte.vhd                                 ==--
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
--== This module is a standalone two byte Autonomous Cascadable Dual  ==--
--== Port FIFO that has a single cycle latency. All the modules IO's  ==--
--== are registered which makes it ideal for use alongside other      ==--
--== modules that do not have time to register their IO's.            ==--
--==                                                                  ==--
---========================== End Description =========================---

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ac_fifo_2byte IS
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
END ac_fifo_2byte;


ARCHITECTURE rtl OF ac_fifo_2byte IS

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL full_i  : STD_LOGIC;
SIGNAL empty_i : STD_LOGIC;
SIGNAL store   : STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);

BEGIN

  ---========================---
  --== FIFO full flag logic ==--
  ---========================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        full_i <= '0';
      ELSE
        full_i <= NOT(empty_i) AND nread AND (full_i OR NOT(nwrite));
      END IF;
    END IF;
  END PROCESS;

  full <= full_i;

  ---=========================---
  --== FIFO empty flag logic ==--
  ---=========================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        empty_i <= '1';
      ELSE
        empty_i <= NOT(full_i) AND nwrite AND (empty_i OR NOT(nread));
      END IF;
    END IF;
  END PROCESS;

  empty <= empty_i;

  ---===============---
  --== FIFO memory ==--
  ---===============---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        store <= (OTHERS => '0');
      ELSIF (full_i = '0') THEN
        store <= din;
      END IF;
    END IF;
  END PROCESS;

  ---=======================---
  --== FIFO data out logic ==--
  ---=======================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        dout <= (OTHERS => '0');
      ELSIF (empty_i = '1') OR (nread = '0') THEN
        CASE full_i IS
          WHEN '0' => dout <= din;
          WHEN '1' => dout <= store;
          WHEN OTHERS => NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

END rtl;
