library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;
use work.ieee_ext.all ;

entity buf_ram is
  generic (
    DW      : integer := 36;
    AW      : integer := 9;
    DEPTH   : integer := 0;
    RAM_BLOCK_TYPE : string := "AUTO" );
  port (
    wr_clk  : in  std_logic;
    wr_en   : in  std_logic;
    wr_addr : in  std_logic_vector(AW-1 downto 0);
    wr_data : in  std_logic_vector(DW-1 downto 0);
    rd_clk  : in  std_logic;
    rd_en   : in  std_logic;
    rd_addr : in  std_logic_vector(AW-1 downto 0);
    rd_data : out std_logic_vector(DW-1 downto 0) );
end buf_ram;

architecture behaviour of buf_ram is
begin

  -- Remark:

  -- This simple RAM model does not emulate simultanous read and write from same address.

  process (wr_clk,rd_clk)
    constant NUMWORDS : integer := cond_expr((DEPTH = 0), 2**AW, DEPTH);
    type memory_type is array(0 to NUMWORDS-1) of std_logic_vector(DW-1 downto 0);
    variable memory : memory_type := (others => (others => '0'));
  begin
    if wr_clk'event and wr_clk = '1' then
      if wr_en = '1' then
        memory(conv_integer(unsigned(wr_addr))) := wr_data;
      end if;
    end if;
    if rd_clk'event and rd_clk = '1' then
      if rd_en = '1' then
        rd_data <= memory(conv_integer(unsigned(rd_addr)));
      end if;
    end if;
  end process;

end behaviour;
