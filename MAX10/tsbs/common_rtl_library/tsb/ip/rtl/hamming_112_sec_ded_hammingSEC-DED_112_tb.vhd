--================================================================--
-- FAULT-TOLERANT REGISTER --
--================================================================--
library ieee;
use ieee.std_logic_1164.all;
use work.hamm_package_112bit.all;

entity reg is
port(
  clock   : in  std_logic;
  datain  : in  data_ham_112bit;
  dataout : out data_ham_112bit;
  error_out : out std_logic_vector(1 downto 0)
);
end reg;

architecture reg of reg is
  signal temp : coded_ham_112bit;
begin
   process(clock)
   begin
      if (clock'event and clock='1') then
         temp <= (datain & hamming_encoder_112bit(datain));
      end if;
   end process;

   hamming_decoder_112bit(temp,error_out,dataout);
end reg;

--================================================================--
-- TB HAMMING  --
--================================================================--
library ieee,modelsim_lib;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.hamm_package_112bit.all;
use modelsim_lib.util.all;

entity tb_hamming is
end tb_hamming;

architecture tb_hamming of tb_hamming is
  signal datain         : data_ham_112bit;
  signal dataout        : data_ham_112bit;
  signal error_out      : std_logic_vector(1 downto 0);
  signal clock          : std_logic := '0';

  -- set this constant to TRUE to insert SINGLE FAULTS in the register, or
  -- set it to FALSE to insert DOUBLE FAULTS in the register
  constant SINGLE_FAULT_INJECTION : boolean := true;
begin

  clock <= not clock after 10 ns;

  faulty_reg: entity work.reg
  port map(
    clock => clock,
    datain => datain,
    dataout => dataout,
    error_out => error_out
  );

  -- generate the input patterns
  datain <= (others => '0');

-- insert a single faults in the register
single_fault: if SINGLE_FAULT_INJECTION = true generate
begin
  process
  begin
      wait for 100 ns;
      for i in 0 to coded_ham_112bit'high loop
         signal_force("/tb_hamming/faulty_reg/temp(" & integer'image(i) & ")","1", open, freeze);
         wait for 10 ns;
         signal_release("/tb_hamming/faulty_reg/temp(" & integer'image(i) & ")");
         wait for 50 ns;
      end loop;
      report "End of Simulation!" severity failure;
      wait;
  end process;
end generate;

-- insert a double faults in the register
double_fault: if SINGLE_FAULT_INJECTION = false generate
begin
  process
  begin
      wait for 100 ns;
      for i in 0 to coded_ham_112bit'high loop
         for j in i+1 to coded_ham_112bit'high loop
            signal_force("/tb_hamming/faulty_reg/temp(" & integer'image(i) & ")","1", open, freeze);
            signal_force("/tb_hamming/faulty_reg/temp(" & integer'image(j) & ")","1", open, freeze);
            wait for 10 ns;
            signal_release("/tb_hamming/faulty_reg/temp(" & integer'image(i) & ")");
            signal_release("/tb_hamming/faulty_reg/temp(" & integer'image(j) & ")");
            wait for 50 ns;
         end loop;
      end loop;
      report "End of Simulation!" severity failure;
      wait;
  end process;
end generate;

  -- evaluate the output
  process
  begin
    wait for 100 ns;
    wait until clock'event and clock='0';
    while true loop
      if (datain /= dataout) then
        report "Error: output does not match!"
        severity note;
      end if;
      wait for 1 ns;
    end loop;
  end process;

end tb_hamming;
