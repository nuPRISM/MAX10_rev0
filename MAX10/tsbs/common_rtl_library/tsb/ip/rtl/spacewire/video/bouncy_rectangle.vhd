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
--== Filename ..... bouncy_rectangle.vhd                              ==--
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
--== This module overlays a rectangle on the incomming video stream.  ==--
--== The rectangle automatically cycles its colours and also moves    ==--
--== around the screen bouncing off the edges.                        ==--
--==                                                                  ==--
---========================== End Description =========================---

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY bouncy_rectangle IS
  GENERIC(
          --== PAL OR NTSC Encoding ==--

          pal : BOOLEAN := TRUE;

          --== X Start Positions (PAL & NTSC = 0-1439) ==--

          XStart : NATURAL RANGE 0 TO 1439 := 50;
          XEnd   : NATURAL RANGE 0 TO 1439 := 100;

          --== Y Start Positions (PAL = 0-575, NTSC = 0-479) ==--

          YStart : NATURAL RANGE 0 TO 575 := 50;
          YEnd   : NATURAL RANGE 0 TO 575 := 100;

          --== Start Colour ==--

          Col    : NATURAL RANGE 16 TO 235 := 128
         );
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
END bouncy_rectangle;


ARCHITECTURE rtl OF bouncy_rectangle IS

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL en_i    : STD_LOGIC;
SIGNAL x_start : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL x_end   : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL y_start : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL y_end   : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL match   : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL colour  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL video_i : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL x_dir   : STD_LOGIC;
SIGNAL y_dir   : STD_LOGIC;
SIGNAL c_dir   : STD_LOGIC;

BEGIN

  ---==========================================---
  --== Cycle colour and edge bounce rectangle ==--
  ---==========================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN

        x_start <= CONV_STD_LOGIC_VECTOR(XStart, 11);
        y_start <= CONV_STD_LOGIC_VECTOR(YStart, 10);
        x_end   <= CONV_STD_LOGIC_VECTOR(XEnd, 11);
        y_end   <= CONV_STD_LOGIC_VECTOR(YEnd, 10);

        colour <= CONV_STD_LOGIC_VECTOR(Col, 8);

        x_dir <= '0';
        y_dir <= '0';
        c_dir <= '0';

      ELSE
        IF (tof_in = '1') THEN

          IF (c_dir = '0') THEN
            IF (colour = 235) THEN
              c_dir <= '1';
            ELSE
              colour <= colour + 1;
            END IF;
          ELSE
            IF (colour = 16) THEN
              c_dir <= '0';
            ELSE
              colour <= colour - 1;
            END IF;
          END IF;

          IF (x_dir = '0') THEN
            IF (x_end >= 1439-10) THEN
              x_dir <= '1';
            ELSE
              x_start <= x_start + 8;
              x_end <= x_end + 8;
            END IF;
          ELSE
            IF (x_start <= 0+10) THEN
              x_dir <= '0';
            ELSE
              x_start <= x_start - 8;
              x_end <= x_end - 8;
            END IF;
          END IF;

          IF (y_dir = '0') THEN
            IF ((pal = TRUE) AND (y_end >= 575-10)) OR
               ((pal = FALSE) AND (y_end >= 479-10)) THEN
              y_dir <= '1';
            ELSE
              y_start <= y_start + 4;
              y_end <= y_end + 4;
            END IF;
          ELSE
            IF (y_start <= 0+10) THEN
              y_dir <= '0';
            ELSE
              y_start <= y_start - 4;
              y_end <= y_end - 4;
            END IF;
          END IF;

        END IF;

      END IF;
    END IF;
  END PROCESS;

  ---==============================================================---
  --== Check screen area to see if rectangle should be draw there ==--
  ---==============================================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN

        match <= (OTHERS => '0');

      ELSE

        match <= (OTHERS => '0');

        IF (sample_in >= x_start) THEN
          match(0) <= '1';
        END IF;

        IF (sample_in <= x_end) THEN
          match(1) <= '1';
        END IF;

        IF (line_in >= y_start) THEN
          match(2) <= '1';
        END IF;

        IF (line_in <= y_end) THEN
          match(3) <= '1';
        END IF;

      END IF;
    END IF;
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

  ---=========================================---
  --== Multiplex rectangle into video stream ==--
  ---=========================================---

  PROCESS(en_i, fvh_in, match, colour, video_in)
  BEGIN
    IF (en_i = '1') AND (fvh_in(1 DOWNTO 0) = "00") AND (match = "1111") THEN
      video_i <= colour;
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