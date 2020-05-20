----------------------------------------------------------------------
--                                                                  --
--  THIS VHDL SOURCE CODE IS PROVIDED UNDER THE GNU PUBLIC LICENSE  --
--                                                                  --
----------------------------------------------------------------------
--                                                                  --
--    Filename            : dds_waveform_gen.vhd                        --
--                                                                  --
--    Author              : Simon Doherty                           --
--                          Senior Design Consultant                --
--                          www.zipcores.com                        --
--                                                                  --
--    Date last modified  : 24.10.2008                              --
--                                                                  --
--    Description         : NCO / Periodic Waveform Generator       --
--                                                                  --
----------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.dds_vhdl_type_package.all;

entity dds_waveform_gen_8_parallel is

port (

  -- system signals
  clk         : in  std_logic;
  reset       : in  std_logic;
  
  -- clock-enable
  en          : in  std_logic;
  
  -- NCO frequency control
  phase_inc   : in  std_logic_vector(31 downto 0);
  
  
  -- Output waveforms
  sin_out     : out data_out_array;
  cos_out     : out data_out_array;
  squ_out     : out data_out_array;
  saw_out     : out data_out_array );
  
  --attribute BLACK_BOX : boolean;
  --attribute BLACK_BOX of dds_waveform_gen : entity is true;

end entity;


architecture rtl of dds_waveform_gen_8_parallel is


component sincos_lut_for_dds

port (

  clk      : in  std_logic;
  en       : in  std_logic;
  addr     : in  std_logic_vector(11 downto 0);
  sin_out  : out std_logic_vector(11 downto 0);
  cos_out  : out std_logic_vector(11 downto 0));
  
end component;


signal  phase_acc     : phase_inc_array;
signal  phase_acc_raw     : phase_inc_array;
signal  lut_addr      : data_out_array;
signal  lut_addr_reg  : data_out_array;


begin


--------------------------------------------------------------------------
-- Phase accumulator increments by 'phase_inc' every clock cycle        --
-- Output frequency determined by formula: Phase_inc = (Fout/Fclk)*2^32 --
-- E.g. Fout = 36MHz, Fclk = 100MHz,  Phase_inc = 36*2^32/100           --
-- Frequency resolution is 100MHz/2^32 = 0.00233Hz                      --
--------------------------------------------------------------------------



---------------------------------------------------------------------
-- use top 12-bits of phase accumulator to address the SIN/COS LUT --
---------------------------------------------------------------------


----------------------------------------------------------------------
-- SIN/COS LUT is 4096 by 12-bit ROM                                --
-- 12-bit output allows sin/cos amplitudes between 2047 and -2047   --
-- (-2048 not used to keep the output signal perfectly symmetrical) --
-- Phase resolution is 2Pi/4096 = 0.088 degrees                     --
----------------------------------------------------------------------

GEN_LUT: 
for I in 0 to 7 generate
                with I select phase_acc_raw(I) <= (unsigned(phase_acc_raw(I-1)) + (unsigned(phase_inc(28 downto 0)) srl 3)) when "0",                               
                    (unsigned(phase_acc(I-1)) + unsigned(phase_inc(31 downto 0)))  when "1",
                   (unsigned(phase_acc_raw(I-1)) + unsigned(phase_inc(31 downto 0))) when others; 
               
                     lut_addr(J) <= unsigned(phase_acc(31 downto 20));

                	phase_acc_reg: process(clk, reset)
					begin
					  if reset = '0' then
						phase_acc <= (others => '0');
					  elsif clk'event and clk = '1' then
						if en = '1' then						
						        phase_acc(I) <= phase_acc_raw(I); 						  
						end if;
					  end if;
					end process phase_acc_reg;

				lut: sincos_lut_for_dds
				port map (

					clk       => clk,
					en        => en,
					addr      => lut_addr_reg(I),
					sin_out   => sin_out(I),
					cos_out   => cos_out(I) );
				 
				 ---------------------------------
				-- Hide the latency of the LUT --
				---------------------------------

				delay_regs: process(clk)
				begin
				  if clk'event and clk = '1' then
					if en = '1' then
					  lut_addr_reg(I) <= lut_addr(I);
					end if;
				  end if;
				end process delay_regs;

				---------------------------------------------
				-- Square output is msb of the accumulator --
				---------------------------------------------
				delay_square: process(clk)
				begin
				  if clk'event and clk = '1' then
					  if lut_addr_reg(I)(11) = '1' then 
								squ_out(I) <= "011111111111";
						else 
						 squ_out(I) <= "100000000000";
						end if;
				   end if;
				end process delay_square;

				-------------------------------------------------------
				-- Sawtooth output is top 12-bits of the accumulator --
				-------------------------------------------------------

				saw_out(I) <= lut_addr_reg(I);
				 
 
 end generate GEN_LUT;
 


    
    
end rtl;