library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;

entity sp_ram is
  generic (
    aw      : in integer;
    dw      : in integer := 32);
  port (
    address : in std_logic_vector(AW-1 downto 0);
    clock   : in std_logic ;
    data    : in std_logic_vector(DW-1 downto 0);
    wren    : in std_logic ;
    q	    : out std_logic_vector(DW-1 downto 0) );
end sp_ram;

architecture behaviour of sp_ram is
begin

  process (clock)
    constant NUMWORDS : integer := 2**AW;
    type memory_type is array(0 to NUMWORDS-1) of std_logic_vector(DW-1 downto 0);
    variable memory : memory_type;
  begin
    if clock'event and clock = '1' then
      if wren = '1' then
        memory(conv_integer(unsigned(address))) := data;
      end if;
      q <= memory(conv_integer(unsigned(address)));
    end if;
  end process;

end behaviour;
