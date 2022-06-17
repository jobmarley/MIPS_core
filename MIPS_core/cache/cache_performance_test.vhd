
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity cache_performance_test is
    port (
		SYSCLK_P : in std_logic;
		SYSCLK_N : in std_logic;
	
	LEDS : out std_logic_vector(7 downto 0)
	);
end cache_performance_test;

architecture cache_performance_test_behavioral of cache_performance_test is
  component cache_performance_test_design is
  port (
    CLK_IN1_D_0_clk_n : in STD_LOGIC;
    CLK_IN1_D_0_clk_p : in STD_LOGIC;
    porta_address_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    porta_address_valid_0 : in STD_LOGIC;
    porta_read_data_ready_0 : in STD_LOGIC;
    portb_address_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    portb_address_valid_0 : in STD_LOGIC;
    portb_read_data_ready_0 : in STD_LOGIC;
    portb_write_data_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    portb_write_strobe_0 : in STD_LOGIC_VECTOR ( 3 downto 0 );
    portb_write_0 : in STD_LOGIC;
    porta_address_ready_0 : out STD_LOGIC;
    porta_read_data_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    porta_read_data_valid_0 : out STD_LOGIC;
    portb_address_ready_0 : out STD_LOGIC;
    portb_read_data_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    portb_read_data_valid_0 : out STD_LOGIC;
    clk_out1_0 : out STD_LOGIC
  );
  end component cache_performance_test_design;
	
    signal porta_address_0 : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal porta_address_valid_0 : STD_LOGIC;
    signal porta_read_data_ready_0 : STD_LOGIC;
    signal portb_address_0 : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal portb_address_valid_0 : STD_LOGIC;
    signal portb_read_data_ready_0 : STD_LOGIC;
    signal portb_write_data_0 : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal portb_write_strobe_0 : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal portb_write_0 : STD_LOGIC;
    signal porta_address_ready_0 : STD_LOGIC;
    signal porta_read_data_0 : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal porta_read_data_valid_0 : STD_LOGIC;
    signal portb_address_ready_0 : STD_LOGIC;
    signal portb_read_data_0 : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal portb_read_data_valid_0 : STD_LOGIC;
    signal clk_out1_0 : STD_LOGIC;
	
	signal counter : UNSIGNED(31 downto 0) := x"00000000";
begin
cache_performance_test_design_i: component cache_performance_test_design
     port map (
      CLK_IN1_D_0_clk_n => SYSCLK_N,
      CLK_IN1_D_0_clk_p => SYSCLK_P,
      clk_out1_0 => clk_out1_0,
      porta_address_0(31 downto 0) => porta_address_0(31 downto 0),
      porta_address_ready_0 => porta_address_ready_0,
      porta_address_valid_0 => porta_address_valid_0,
      porta_read_data_0(31 downto 0) => porta_read_data_0(31 downto 0),
      porta_read_data_ready_0 => porta_read_data_ready_0,
      porta_read_data_valid_0 => porta_read_data_valid_0,
      portb_address_0(31 downto 0) => portb_address_0(31 downto 0),
      portb_address_ready_0 => portb_address_ready_0,
      portb_address_valid_0 => portb_address_valid_0,
      portb_read_data_0(31 downto 0) => portb_read_data_0(31 downto 0),
      portb_read_data_ready_0 => portb_read_data_ready_0,
      portb_read_data_valid_0 => portb_read_data_valid_0,
      portb_write_0 => portb_write_0,
      portb_write_data_0(31 downto 0) => portb_write_data_0(31 downto 0),
      portb_write_strobe_0(3 downto 0) => portb_write_strobe_0(3 downto 0)
    );
	
	process (clk_out1_0)
	begin
		if rising_edge(clk_out1_0) then
			counter <= counter + 1;
		end if;
	end process;
	
        porta_address_0 <= "00" & std_logic_vector(counter(31 downto 2));
        porta_address_valid_0 <= '1';
        porta_read_data_ready_0 <= '1';
        portb_address_0 <= (others => '0');
        portb_address_valid_0 <= '0';
        portb_read_data_ready_0 <= '0';
        portb_write_data_0 <= (others => '0');
        portb_write_strobe_0 <= (others => '0');
        portb_write_0 <= '0';
	
	LEDS <= porta_read_data_0(TO_INTEGER((counter mod 4)) * 8 + 7 downto TO_INTEGER((counter mod 4)) * 8);
end cache_performance_test_behavioral;
