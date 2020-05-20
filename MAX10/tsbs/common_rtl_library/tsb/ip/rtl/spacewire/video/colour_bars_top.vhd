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
--== Filename ..... colour_bars_top.vhd                               ==--
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
--== Top level wrapper for digital video colour bar/block generator.  ==--
--==                                                                  ==--
---========================== End Description =========================---


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY colour_bars_top IS
  PORT(
       --==  General Input Interface (Async Rst, 54MHz Clock) ==--

       clk2x  : IN  STD_LOGIC;
       rst_n  : IN  STD_LOGIC;
       en     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);

       --== Digital Video Interface ==--

       vclk   : OUT STD_LOGIC;
       vrst_n : OUT STD_LOGIC;
       vpal   : OUT STD_LOGIC;
       video  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
END colour_bars_top;


ARCHITECTURE rtl OF colour_bars_top IS

---=========================---
--== Constant Declarations ==--
---=========================---

CONSTANT pal     : BOOLEAN := TRUE;
CONSTANT Y_fill  : NATURAL RANGE 16 TO 235 := 41;
CONSTANT Cb_fill : NATURAL RANGE 16 TO 240 := 240;
CONSTANT Cr_fill : NATURAL RANGE 16 TO 240 := 110;

---==========================---
--== Component Declarations ==--
---==========================---

COMPONENT blank_screen
  GENERIC(--== PAL OR NTSC Encoding ==--
          pal : BOOLEAN := TRUE;
          --== Floodfill Colour ==--
          Y   : NATURAL RANGE 16 TO 235 := 41;
          Cb  : NATURAL RANGE 16 TO 240 := 240;
          Cr  : NATURAL RANGE 16 TO 240 := 110
         );
  PORT(--== General Interface (Sync Rst, 27MHz Clock) ==--
       clk    : IN  STD_LOGIC;
       rst    : IN  STD_LOGIC;
       --== Digital Video Interface ==--
       video  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
       fvh    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
       --== TOP of Frame Pulse Interface ==--
       tof    : OUT STD_LOGIC;
       --== Line Position (PAL = 0-575, NTSC = 0-479) ==--
       line   : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
       --== Sample Position (PAL & NTSC = 0-1439) ==--
       sample : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
      );
END COMPONENT;

COMPONENT colour_bars
  PORT(--== General Interface (Sync Rst, 27MHz Clock) ==--
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
END COMPONENT;

COMPONENT colour_blocks
  GENERIC(--== PAL OR NTSC Encoding ==--
          pal : BOOLEAN := TRUE
         );
  PORT(--== General Interface (Sync Rst, 27MHz Clock) ==--
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
END COMPONENT;

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL clk       : STD_LOGIC := '0';
SIGNAL rst       : STD_LOGIC := '0';
SIGNAL rst_ff    : STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL p1_video  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL p1_fvh    : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL p1_tof    : STD_LOGIC;
SIGNAL p1_line   : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL p1_sample : STD_LOGIC_VECTOR(10 DOWNTO 0);

SIGNAL p2_video  : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL p2_fvh    : STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL p2_tof    : STD_LOGIC;
SIGNAL p2_line   : STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL p2_sample : STD_LOGIC_VECTOR(10 DOWNTO 0);

BEGIN

  ---===============================================================---
  --== Board specific logic - Divide clock by 2 to get video clock ==--
  ---===============================================================---

  PROCESS(clk2x)
  BEGIN
    IF RISING_EDGE(clk2x) THEN
      clk <= NOT(clk);
    END IF;
  END PROCESS;

  ---====================================================---
  --== Board specific logic - Syncronize & invert reset ==--
  ---====================================================---

  PROCESS(clk, rst_n)
  BEGIN
    IF (rst_n = '0') THEN
      rst_ff <= "110";
    ELSIF RISING_EDGE(clk) THEN
      rst_ff <= rst_ff(1 DOWNTO 0) & '0';
    END IF;
  END PROCESS;

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      rst <= rst_ff(2);
    END IF;
  END PROCESS;

  ---=======================================================---
  --== Board specific logic - Drive external video circuit ==--
  ---=======================================================---

  vclk   <= NOT(clk);
  vrst_n <= rst_n;
  vpal   <= '1' WHEN (pal = TRUE) ELSE '0';

  ---=========================---
  --== Create a blank screen ==--
  ---=========================---

  U0 : blank_screen
    GENERIC MAP
      (--== PAL OR NTSC Encoding ==--
       pal => pal,
       --== Floodfill Colour ==--
       Y   => Y_fill,
       Cb  => Cb_fill,
       Cr  => Cr_fill
      )
    PORT MAP
      (--== General Interface (Sync Rst, 27MHz Clock) ==--
       clk    => clk,
       rst    => rst,
       --== Digital Video Interface ==--
       video  => p1_video,
       fvh    => p1_fvh,
       --== TOP of Frame Pulse Interface ==--
       tof    => p1_tof,
       --== Line Position (PAL = 0-575, NTSC = 0-479) ==--
       line   => p1_line,
       --== Sample Position (PAL & NTSC = 0-1439) ==--
       sample => p1_sample
      );

  ---=======================================---
  --== Overlay colour bars on blank screen ==--
  ---=======================================---

  U1 : colour_bars
    PORT MAP
      (--== General Interface (Sync Rst, 27MHz Clock) ==--
       clk        => clk,
       rst        => rst,
       en         => en(0),
       --== Digital Video Interface ==--
       video_in   => p1_video,
       video_out  => p2_video,
       fvh_in     => p1_fvh,
       fvh_out    => p2_fvh,
       --== TOP of Frame Pulse Interface ==--
       tof_in     => p1_tof,
       tof_out    => p2_tof,
       --== Line Position (PAL = 0-575, NTSC = 0-479) ==--
       line_in    => p1_line,
       line_out   => p2_line,
       --== Sample Position (PAL & NTSC = 0-1439) ==--
       sample_in  => p1_sample,
       sample_out => p2_sample
      );

  ---=========================================---
  --== Overlay colour blocks on blank screen ==--
  ---=========================================---

  U2 : colour_blocks
    GENERIC MAP
      (--== PAL OR NTSC Encoding ==--
       pal => pal
      )
    PORT MAP
      (--== General Interface (Sync Rst, 27MHz Clock) ==--
       clk        => clk,
       rst        => rst,
       en         => en(1),
       --== Digital Video Interface ==--
       video_in   => p2_video,
       video_out  => video,
       fvh_in     => p2_fvh,
       fvh_out    => OPEN,
       --== TOP of Frame Pulse Interface ==--
       tof_in     => p2_tof,
       tof_out    => OPEN,
       --== Line Position (PAL = 0-575, NTSC = 0-479) ==--
       line_in    => p2_line,
       line_out   => OPEN,
       --== Sample Position (PAL & NTSC = 0-1439) ==--
       sample_in  => p2_sample,
       sample_out => OPEN
      );

END rtl;
