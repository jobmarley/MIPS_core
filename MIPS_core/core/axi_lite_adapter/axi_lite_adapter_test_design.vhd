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
use IEEE.numeric_std.all;

entity axi_lite_adapter_test_design is
--  Port ( );
end axi_lite_adapter_test_design;

architecture axi_lite_adapter_test_design_behavioral of axi_lite_adapter_test_design is

      signal address_in : std_logic_vector(31 downto 0) := x"00000000";
      signal address_ready : std_logic;
      signal address_valid : std_logic;
      signal data_out : std_logic_vector(31 downto 0);
      signal data_ready : std_logic;
      signal data_valid : std_logic;
      signal discard : std_logic;
	
  component il_test_design is
  port (
    data_ready_0 : in STD_LOGIC;
    discard_0 : in STD_LOGIC;
    address_in_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    address_valid_0 : in STD_LOGIC;
    data_valid_0 : out STD_LOGIC;
    address_ready_0 : out STD_LOGIC;
    data_out_0 : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component il_test_design;
begin
	address_valid <= '1';
	data_ready <= '1';
	process
	begin
	    discard <= '0';
		wait for 235ns;
		discard <= '1';
		wait for 10ns;
	    discard <= '0';
	end process;
		
	process 
	begin
	    if address_ready = '0' then
		    wait until address_ready = '1';
		    wait for 10ns;
		end if;
		
		address_in <= std_logic_vector(unsigned(address_in) + 4);
		wait for 10ns;
	end process;
	
il_test_design_i: component il_test_design
     port map (
      address_in_0(31 downto 0) => address_in,
      address_ready_0 => address_ready,
      address_valid_0 => address_valid,
      data_out_0(31 downto 0) => data_out,
      data_ready_0 => data_ready,
      data_valid_0 => data_valid,
      discard_0 => discard
    );
end axi_lite_adapter_test_design_behavioral;
