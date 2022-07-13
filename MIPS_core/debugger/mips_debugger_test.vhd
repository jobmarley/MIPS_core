-- 
--  Copyright (C) 2022 jobmarley
-- 
--  This file is part of MIPS_core.
-- 
--  This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
--  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
--  You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
--  


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mips_debugger_test is
--  Port ( );
end mips_debugger_test;

architecture mips_debugger_test_behavioral of mips_debugger_test is
	
 component design_debugger is
  port (
    debug_0 : out STD_LOGIC_VECTOR ( 7 downto 0 );
    processor_enable_0 : out STD_LOGIC;
    done_0 : out STD_LOGIC;
    status_0 : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component design_debugger;
	
	signal debug : std_logic_vector(7 downto 0);
	signal done : std_logic;
	signal processor_enable : std_logic;
	signal status : std_logic_vector(31 downto 0);
begin
design_debugger_i: component design_debugger
     port map (
      debug_0(7 downto 0) => debug,
      done_0 => done,
      processor_enable_0 => processor_enable,
      status_0(31 downto 0) => status
    );

end mips_debugger_test_behavioral;
