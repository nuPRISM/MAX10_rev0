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
--== Filename ..... colour_bars.vhd                                   ==--
--== Download ..... http://www.spacewire.co.uk                        ==--
--== Author ....... Steve Haywood (steve.haywood@ukonline.co.uk)      ==--
--== Copyright .... Copyright (c) 2004 Steve Haywood                  ==--
--== Project ...... Video Pipeline                                    ==--
--== Version ...... 1.00                                              ==--
--== Conception ... 8 May 2004                                        ==--
--== Modified ..... N/A                                               ==--
--==                                                                  ==--
---======================= End Copyright Notice =======================---


---========================= Start Description ========================---
--==                                                                  ==--
--== This module overlays a full set of eight colour bars on the      ==--
--== incomming video stream. The bars from left to right are, White,  ==--
--== Yellow, Cyan, Green, Magenta, Red, Blue and Black.               ==--
--==                                                                  ==--
---========================== End Description =========================---


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY colour_bars IS
  PORT(
       --== General Interface (Sync Rst, 27MHz Clock) ==--

       clk        : IN  STD_LOGIC;
       rst        : IN  STD_LOGIC;
       en         : IN  STD_LOGIC;

       --== Digital Video Interface ==--

       video_in   : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
       video_out  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       fvh_in     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
       fvh_out    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

       --== TOP of Frame Pulse Interface ==--

       tof_in     : IN  STD_LOGIC;
       tof_out    : OUT STD_LOGIC;

       --== Line Position (PAL = 0-575, NTSC = 0-479) ==--

       line_in    : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
       line_out   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);

       --== Sample Position (PAL & NTSC = 0-1439) ==--

       sample_in  : IN  STD_LOGIC_VECTOR(10 DOWNTO 0);
       sample_out : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
      );
END colour_bars;


ARCHITECTURE rtl OF colour_bars IS

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL en_i     : STD_LOGIC;
SIGNAL position : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL bar      : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL Y        : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Cb       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL Cr       : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL video_i  : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

  ---=============================================---
  --== Keep track of horizontal position and bar ==--
  ---=============================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        position <= (OTHERS => '0');
        bar <= (OTHERS => '0');
      ELSE
        IF (fvh_in(1 DOWNTO 0) = "00") THEN
          IF (position = 179) THEN
            position <= (OTHERS => '0');
            bar <= bar + 1;
          ELSE
            position <= position + 1;
          END IF;
        ELSE
          bar <= (OTHERS => '0');
        END IF;  
      END IF;
    END IF;
  END PROCESS;


  ---================================---
  --== Create the YCbCr colour bars ==--
  ---================================---

  PROCESS(bar)
  BEGIN
    CASE bar IS
      WHEN "000" => -- White

        Y  <= CONV_STD_LOGIC_VECTOR(235, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(128, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(128, 8);

      WHEN "001" => -- Yellow

        Y  <= CONV_STD_LOGIC_VECTOR(210, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(16, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(146, 8);

      WHEN "010" => -- Cyan

        Y  <= CONV_STD_LOGIC_VECTOR(170, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(166, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(16, 8);

      WHEN "011" => -- Green

        Y  <= CONV_STD_LOGIC_VECTOR(145, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(54, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(34, 8);

      WHEN "100" => -- Magenta

        Y  <= CONV_STD_LOGIC_VECTOR(107, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(202, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(222, 8);

      WHEN "101" => -- Red

        Y  <= CONV_STD_LOGIC_VECTOR(82, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(90, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(240, 8);

      WHEN "110" => -- Blue

        Y  <= CONV_STD_LOGIC_VECTOR(41, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(240, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(110, 8);

      WHEN "111" => -- Black

        Y  <= CONV_STD_LOGIC_VECTOR(16, 8);
        Cb <= CONV_STD_LOGIC_VECTOR(128, 8);
        Cr <= CONV_STD_LOGIC_VECTOR(128, 8);

      WHEN OTHERS =>

        NULL;

    END CASE;
  END PROCESS;

  ---=============================================================---
  --== Register enable at top of frame so video is not disturbed ==--
  ---=============================================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        en_i <= '0';
      ELSIF (tof_in = '1') THEN
        en_i <= en;
      END IF;
    END IF;
  END PROCESS;

  ---============================================---
  --== Multiplex Y, Cb and Cr into video stream ==--
  ---============================================---

  PROCESS(en_i, fvh_in, position, Y, Cb, Cr, video_in)
  BEGIN
    IF (en_i = '1') AND (fvh_in(1 DOWNTO 0) = "00") THEN
      IF (position(0) = '1') THEN
        video_i <= Y;
      ELSIF (position(1) = '0') THEN
        video_i <= Cb;
      ELSE
        video_i <= Cr;
      END IF;
    ELSE
      video_i <= video_in;
    END IF;
  END PROCESS;

  ---=======================================---
  --== Register outputs and pass on inputs ==--
  ---=======================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN
        video_out  <= (OTHERS => '0');
        fvh_out    <= "011";
        tof_out <= '0';
        line_out   <= (OTHERS => '0');
        sample_out <= (OTHERS => '0');
      ELSE
        video_out  <= video_i;
        fvh_out    <= fvh_in;
        tof_out    <= tof_in;
        line_out   <= line_in;
        sample_out <= sample_in;
      END IF;
    END IF;
  END PROCESS;

END rtl;
