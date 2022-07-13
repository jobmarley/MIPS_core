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


entity cache_design_test is
--  Port ( );
end cache_design_test;

architecture cache_design_test_behavioral of cache_design_test is
	

	
 component cache_design is
  port (
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
    portb_read_data_valid_0 : out STD_LOGIC
  );
  end component cache_design;
	
	signal porta_address : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal porta_address_valid : STD_LOGIC;
    signal porta_read_data_ready : STD_LOGIC;
    signal portb_address : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal portb_address_valid : STD_LOGIC;
    signal portb_read_data_ready : STD_LOGIC;
    signal portb_write_data : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal portb_write_strobe : STD_LOGIC_VECTOR ( 3 downto 0 );
    signal portb_write : STD_LOGIC;
    signal porta_address_ready : STD_LOGIC;
    signal porta_read_data : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal porta_read_data_valid : STD_LOGIC;
    signal portb_address_ready : STD_LOGIC;
    signal portb_read_data : STD_LOGIC_VECTOR ( 31 downto 0 );
    signal portb_read_data_valid : STD_LOGIC;
	
	procedure read_data_proc(
	address : std_logic_vector;
	signal read_address : out std_logic_vector;
	signal read_address_valid : out std_logic;
	signal read_address_ready : in std_logic;
	signal read_data : in std_logic_vector;
	signal read_data_valid : in std_logic) is
	begin
	    read_address <= address;
		read_address_valid <= '1';
		wait for 10ns;
		if read_address_ready = '0' then
			wait until read_address_ready = '1';
			wait for 10ns;
		end if;
		read_address_valid <= '0';
	end procedure;
	
begin
	
	process
	begin
	    porta_address <= x"00000000";
		porta_address_valid <= '0';
		porta_read_data_ready <= '1';
		wait for 205ns;
	    read_data_proc(x"00000000", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000004", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000008", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"0000000C", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000200", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000204", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000214", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000004", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000004", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000004", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000004", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000004", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
	    read_data_proc(x"00000004", porta_address, porta_address_valid, porta_address_ready, porta_read_data, porta_read_data_valid);
		wait for 200ns;
	end process;
	
cache_design_i: component cache_design
     port map (
      porta_address_0(31 downto 0) => porta_address,
      porta_address_ready_0 => porta_address_ready,
      porta_address_valid_0 => porta_address_valid,
      porta_read_data_0(31 downto 0) => porta_read_data,
      porta_read_data_ready_0 => porta_read_data_ready,
      porta_read_data_valid_0 => porta_read_data_valid,
      portb_address_0(31 downto 0) => portb_address,
      portb_address_ready_0 => portb_address_ready,
      portb_address_valid_0 => portb_address_valid,
      portb_read_data_0(31 downto 0) => portb_read_data,
      portb_read_data_ready_0 => portb_read_data_ready,
      portb_read_data_valid_0 => portb_read_data_valid,
      portb_write_0 => portb_write,
      portb_write_data_0(31 downto 0) => portb_write_data,
      portb_write_strobe_0(3 downto 0) => portb_write_strobe
    );
end cache_design_test_behavioral;
