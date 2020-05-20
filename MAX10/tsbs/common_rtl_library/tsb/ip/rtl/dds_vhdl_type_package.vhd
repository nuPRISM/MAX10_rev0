library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

package dds_vhdl_type_package is
type data_out_array is array (7 downto 0) of std_logic_vector(11 downto 0) ;
type phase_inc_array is array (7 downto 0) of std_logic_vector(31 downto 0) ;

end package dds_vhdl_type_package;
