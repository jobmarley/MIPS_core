----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 6/12/2022 11:16:32 AM
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mips_core_unit_test is
--  Port ( );
end mips_core_unit_test;

architecture mips_core_unit_test_behavioral of mips_core_unit_test is
component mips_exec_test_design is
  end component mips_exec_test_design;
begin
mips_exec_test_design_i: component mips_exec_test_design
 ;
end mips_core_unit_test_behavioral;
