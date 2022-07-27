library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mips_core_test_simple is
	port (
		sys_clk_p : in std_logic;
		sys_clk_n : in std_logic;
	
		CPU_RESET : in std_logic;
			
		led : out std_logic_vector(7 downto 0)
	);
end mips_core_test_simple;

architecture mips_core_test_simple_behavioral of mips_core_test_simple is
  component design_2 is
  port (
    CLK_IN1_D_0_clk_n : in STD_LOGIC;
    CLK_IN1_D_0_clk_p : in STD_LOGIC;
    LEDS_0 : out STD_LOGIC_VECTOR ( 7 downto 0 )
  );
  end component design_2;
begin
design_2_i: component design_2
     port map (
      CLK_IN1_D_0_clk_n => sys_clk_p,
      CLK_IN1_D_0_clk_p => sys_clk_n,
      LEDS_0(7 downto 0) => led
    );
end mips_core_test_simple_behavioral;
