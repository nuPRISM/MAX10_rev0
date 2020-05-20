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
--== Filename ..... blank_screen.vhd                                  ==--
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
--== This module generates a full frame of BT656 (4:2:2) YCbCr        ==--
--== digital video, including all the horizontal and vertical         ==--
--== blanking periods. The Active Video portion of the frame is       ==--
--== filled with a single colour. The user can preset this colour and ==--
--== also the video standard to be used, i.e. PAL or NTSC. The video  ==--
--== synchronisation signals, F, V and H are also provided and are    ==--
--== fully aligned to the 8-bit digital video.                        ==--
--==                                                                  ==--
--== For added usability two extra signals are also available, these  ==--
--== being line and sample. When V=0 and H=0 (Active Video) these     ==--
--== signals can be used to pinpoint the exact beam position on a TV  ==--
--== screen.                                                          ==--
--==                                                                  ==--
--== The tof signal provides a single pulse each time a new frame     ==--
--== starts. This signal can be used to trigger logic that needs to   ==--
--== be carried out away from the active video periods.               ==--
--==                                                                  ==--
---========================== End Description =========================---


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY blank_screen IS
  GENERIC(
          --== PAL OR NTSC Encoding ==--

          pal : BOOLEAN := TRUE;

          --== Floodfill Colour ==--

          Y   : NATURAL RANGE 16 TO 235 := 41;
          Cb  : NATURAL RANGE 16 TO 240 := 240;
          Cr  : NATURAL RANGE 16 TO 240 := 110
         );
  PORT(
       --== General Interface (Sync Rst, 27MHz Clock) ==--

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
END blank_screen;


ARCHITECTURE rtl OF blank_screen IS

---=========================---
--== Constant Declarations ==--
---=========================---

SIGNAL length_of_blk_video  : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL length_of_act_video  : STD_LOGIC_VECTOR(10 DOWNTO 0);

SIGNAL length_of_f1_top_blk : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL length_of_f2_top_blk : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL length_of_bottom_blk : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL length_of_act_lines  : STD_LOGIC_VECTOR(8 DOWNTO 0);

---=======================---
--== Signal Declarations ==--
---=======================---

SIGNAL h_int             : STD_LOGIC;
SIGNAL sample_i          : STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL at_end_blk_vid    : STD_LOGIC;
SIGNAL at_end_act_vid    : STD_LOGIC;
SIGNAL eav_sav           : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL fvh_i             : STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL v_int             : STD_LOGIC;
SIGNAL line_i            : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL at_end_f1_top_blk : STD_LOGIC;
SIGNAL at_end_f2_top_blk : STD_LOGIC;
SIGNAL at_end_bottom_blk : STD_LOGIC;
SIGNAL at_end_act_line   : STD_LOGIC;
SIGNAL f2_vblk           : STD_LOGIC;

BEGIN

  ---===================================---
  --== Customize logic for PAL or NTSC ==--
  ---===================================---

  G0 : IF pal GENERATE
    length_of_blk_video  <= CONV_STD_LOGIC_VECTOR(280, 11);
    length_of_act_video  <= CONV_STD_LOGIC_VECTOR(1440, 11);
    length_of_f1_top_blk <= CONV_STD_LOGIC_VECTOR(22, 9);
    length_of_act_lines  <= CONV_STD_LOGIC_VECTOR(288, 9);
    length_of_bottom_blk <= CONV_STD_LOGIC_VECTOR(2, 9);
  END GENERATE G0;

  G1 : IF NOT(pal) GENERATE
    length_of_blk_video  <= CONV_STD_LOGIC_VECTOR(268, 11);
    length_of_act_video  <= CONV_STD_LOGIC_VECTOR(1440, 11);
    length_of_f1_top_blk <= CONV_STD_LOGIC_VECTOR(19, 9);
    length_of_act_lines  <= CONV_STD_LOGIC_VECTOR(240, 9);
    length_of_bottom_blk <= CONV_STD_LOGIC_VECTOR(3, 9);
  END GENERATE G1;

  ---==================================================---
  --== Detect and register important sample positions ==--
  ---==================================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN

        at_end_blk_vid <= '0';
        at_end_act_vid <= '0';

      ELSE

        --
        -- Detect end of Blanking Video period.
        --
        IF (sample_i = length_of_blk_video - 2) THEN
          at_end_blk_vid <= '1';
        ELSE
          at_end_blk_vid <= '0';
        END IF;

        --
        -- Detect end of Active Video period.
        --
        IF (sample_i = length_of_act_video - 2) THEN
          at_end_act_vid <= '1';
        ELSE
          at_end_act_vid <= '0';
        END IF;

      END IF;
    END IF;
  END PROCESS;

  ---===============================---
  --== Generate H and sample count ==--
  ---===============================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN

        sample_i <= "11111111100";
        video    <= "11111111";
        h_int    <= '1';
        fvh_i(0) <= '1';
        f2_vblk <= '0';
        tof <= '0';

      ELSE

        tof <= '0';
        sample_i <= sample_i + 1;

        IF (sample_i(10 DOWNTO 9) = "11") THEN

          IF (sample_i(1) = '0') THEN
            --
            -- Generate second and third bytes of EAV/SAV Code.
            --
            video <= "00000000";
          ELSIF (sample_i(0) = '0') THEN
            --
            -- Generate fourth byte of EAV/SAV Code.
            --
            video <= eav_sav;
            --
            -- Generate top of frame logic.
            --
            IF (eav_sav(6 DOWNTO 4) = "110") THEN -- Field 2 VBlk SAV
              f2_vblk <= '1';
            ELSE
              f2_vblk <= '0';
            END IF;

            IF (eav_sav(6 DOWNTO 4) = "011") THEN -- Field 1 VBlk EAV
              tof <= f2_vblk;
            END IF;
          ELSIF (h_int = '1') THEN
            --
            -- Generate first byte of Blanking Video.
            --
            video <= sample_i(0) & "00" & NOT(sample_i(0)) & "0000";
          ELSE
            --
            -- Generate first byte of Active Video.
            --
            video <= CONV_STD_LOGIC_VECTOR(Cb, 8);
            fvh_i(0) <= '0';
          END IF;

        ELSIF (h_int = '1') THEN

          --
          -- Detect end of Blanking Video period.
          --
          IF (at_end_blk_vid = '1') THEN
            --
            -- Generate first byte of SAV Code.
            --
            sample_i <= "11111111100";
            h_int <= '0';
            video <= "11111111";
          ELSE
            --
            -- Generate rest of Blanking Video.
            --
            video <= sample_i(0) & "00" & NOT(sample_i(0)) & "0000";
          END IF;

        ELSE

          --
          -- Detect end of Active Video period.
          --
          IF (at_end_act_vid = '1') THEN
            --
            -- Generate first byte of EAV Code.
            --
            sample_i <= "11111111100";
            h_int <= '1';
            fvh_i(0) <= '1';
            video <= "11111111";
          ELSE
            --
            -- Generate rest of Active Video.
            --
            IF (sample_i(0) = '0') THEN
              video <= CONV_STD_LOGIC_VECTOR(Y, 8);
            ELSIF (sample_i(1) = '1') THEN
              video <= CONV_STD_LOGIC_VECTOR(Cb, 8);
            ELSE
              video <= CONV_STD_LOGIC_VECTOR(Cr, 8);
            END IF;

          END IF;

        END IF;

      END IF;
    END IF;
  END PROCESS;

  ---================================================---
  --== Detect and register important line positions ==--
  ---================================================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN

        at_end_f1_top_blk <= '0';
        at_end_f2_top_blk <= '0';
        at_end_bottom_blk <= '0';
        at_end_act_line   <= '0';

      ELSIF (at_end_act_vid = '1') THEN

        --
        -- Detect end of 1st Vertical Blanking period (Field 1).
        --
        IF (line_i = length_of_f1_top_blk - 2) THEN
          at_end_f1_top_blk <= '1';
        ELSE
          at_end_f1_top_blk <= '0';
        END IF;

        --
        -- Detect end of 1st Vertical Blanking period (Field 1).
        --
        at_end_f2_top_blk <= at_end_f1_top_blk;

        --
        -- Detect end of 2nd Vertical Blanking period (Field 1/2).
        --
        IF (line_i = length_of_bottom_blk - 2) THEN
          at_end_bottom_blk <= '1';
        ELSE
          at_end_bottom_blk <= '0';
        END IF;

        --
        -- Detect end of Active Video period (Field 1/2).
        --
        IF (line_i = length_of_act_lines - 2) THEN
          at_end_act_line <= '1';
        ELSE
          at_end_act_line <= '0';
        END IF;

      END IF;
    END IF;
  END PROCESS;

  ---==============================---
  --== Generate FV and line count ==--
  ---==============================---

  PROCESS(clk)
  BEGIN
    IF RISING_EDGE(clk) THEN
      IF (rst = '1') THEN

        line_i <= (OTHERS => '0');
        fvh_i(2 DOWNTO 1) <= "01";
        v_int <= '0';

      ELSIF (at_end_act_vid = '1') THEN

        line_i <= line_i + 1;

        IF (fvh_i(1) = '1') THEN

          IF (v_int = '0') THEN

            IF (fvh_i(2) = '0') THEN

              --
              -- Detect end of 1st Vertical Blanking period (Field 1).
              --
              IF (at_end_f1_top_blk = '1') THEN
                line_i <= (OTHERS => '0');
                v_int <= '1';
                fvh_i(1) <= '0';
              END IF;

            ELSE

              --
              -- Detect end of 1st Vertical Blanking period (Field 2).
              --
              IF (at_end_f2_top_blk = '1') THEN
                line_i <= (OTHERS => '0');
                v_int <= '1';
                fvh_i(1) <= '0';
              END IF;

            END IF;

          ELSE

            --
            -- Detect end of 2nd Vertical Blanking period (Field 1/2).
            --
            IF (at_end_bottom_blk = '1') THEN
              line_i <= (OTHERS => '0');
              v_int <= '0';
              fvh_i(2) <= NOT(fvh_i(2));
            END IF;

          END IF;

        ELSE

          --
          -- Detect end of Active Video period (Field 1/2).
          --
          IF (at_end_act_line = '1') THEN
            line_i <= (OTHERS => '0');
            fvh_i(1) <= '1';
          END IF;

        END IF;

      END IF;
    END IF;
  END PROCESS;

  ---========================---
  --== Generate line coding ==--
  ---========================---

  eav_sav(7) <= '1';
  eav_sav(6) <= fvh_i(2);
  eav_sav(5) <= fvh_i(1);
  eav_sav(4) <= h_int;
  eav_sav(3) <= fvh_i(1) XOR h_int;
  eav_sav(2) <= fvh_i(2) XOR h_int;
  eav_sav(1) <= fvh_i(2) XOR fvh_i(1);
  eav_sav(0) <= fvh_i(2) XOR fvh_i(1) XOR h_int;

  ---==================================================---
  --== Make internal signals visible to outside world ==--
  ---==================================================---

  sample <= sample_i;
  line <= line_i & fvh_i(2);
  fvh <= fvh_i;

END rtl;
