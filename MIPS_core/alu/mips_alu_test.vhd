library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mips_alu_test is
--  Port ( );
end mips_alu_test;

architecture mips_alu_test_behavioral of mips_alu_test is
  component mips_alu_test_design is
  end component mips_alu_test_design;
begin
mips_alu_test_design_i: component mips_alu_test_design
 ;

end mips_alu_test_behavioral;
