library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;
use work.ieee_ext.all ;

entity dp_ram is
  generic (
    DW : integer;
    AW : integer); 
  port (
    clk       : in  std_logic;
    addr_a    : in  std_logic_vector(AW-1 downto 0);
    wr_en_a   : in  std_logic;
    wr_data_a : in  std_logic_vector(DW-1 downto 0);
    rd_data_a : out std_logic_vector(DW-1 downto 0);
    addr_b    : in  std_logic_vector(AW-1 downto 0);
    wr_en_b   : in  std_logic;
    wr_data_b : in  std_logic_vector(DW-1 downto 0);
    rd_data_b : out std_logic_vector(DW-1 downto 0) );
end dp_ram;

architecture synth of dp_ram is
  type ram_type is array (2**AW-1 downto 0) of std_logic_vector(DW-1 downto 0);
  signal RAM : ram_type;
  signal read_addr_a : std_logic_vector(AW-1 downto 0);
  signal read_addr_b : std_logic_vector(AW-1 downto 0);
begin

  process (clk)
  begin
    if (clk'event and clk = '1') then
      if (wr_en_a = '1') then
        RAM(conv_integer(addr_a)) <= wr_data_a;
      end if;
      if (wr_en_b = '1') then
        RAM(conv_integer(addr_b)) <= wr_data_b;
      end if;
      read_addr_a <= addr_a;
      read_addr_b <= addr_b;
    end if;
  end process;

  rd_data_a <= RAM(conv_integer(read_addr_a));

  rd_data_b <= RAM(conv_integer(read_addr_b));

end synth;
