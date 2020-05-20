library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity rmii_port is
port (
  rmii_rxdata   : in  std_logic_vector(1 downto 0);
  rmii_crs_rxdv : in  std_logic;
  rmii_txdata   : out std_logic_vector(1 downto 0) := "00";
  rmii_txen     : out std_logic := '0';
  rmii_clk		 : in  std_logic;

  mii_rxdata    : out std_logic_vector(3 downto 0) := x"0";
  mii_rxdv      : out std_logic := '0';
  mii_txdata    : in  std_logic_vector(3 downto 0);
  mii_txen      : in  std_logic;
  mii_clk		 : out std_logic := '0'
);
end rmii_port;

architecture beh of rmii_port is

type rx_state_type is (IDLE, RX0, RX1);
signal rx_state : rx_state_type := IDLE;

signal rx0_data : std_logic_vector(1 downto 0);
signal tx_sel   : std_logic := '0';
signal clk2     : std_logic := '0';

begin
	process
	begin
		wait until rising_edge(rmii_clk);

		case rx_state is
		when IDLE =>
			if rmii_crs_rxdv = '1' and rmii_rxdata /= "00" then
				rx0_data <= rmii_rxdata;
				rx_state <= RX1;
			end if;
		
		when RX0 =>
			rx0_data <= rmii_rxdata;
			rx_state <= RX1;
		
		when RX1 =>
			mii_rxdata <= rmii_rxdata & rx0_data;
			mii_rxdv   <= rmii_crs_rxdv;

			rx_state <= RX0;
			if rmii_crs_rxdv = '0' then
				rx_state <= IDLE;
			end if;
		end case;
	end process;

	process
	begin
		wait until rising_edge(rmii_clk);

		if tx_sel = '0' then
			rmii_txen <= mii_txen;
			if mii_txen = '1' then
				rmii_txdata <= mii_txdata(1 downto 0);
				tx_sel      <= '1';
			end if;
		else
			rmii_txdata    <= mii_txdata(3 downto 2);
			tx_sel         <= '0';
		end if;
	end process;

	process
	begin
		wait until rising_edge(rmii_clk);
		mii_clk <= clk2;
		clk2    <= not clk2;
	end process;
end beh;