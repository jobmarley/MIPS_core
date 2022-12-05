library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package test_utils is
	function logic_to_char(l : std_logic) return CHARACTER;
	function slv_to_str(v : std_logic_vector) return STRING;
end test_utils;

package body test_utils is
	function logic_to_char(l : std_logic) return CHARACTER is
	begin
		case l is
			when '0' =>
				return '0';
			when '1' =>
				return '1';
			when 'X' =>
				return 'X';
			when 'U' =>
				return 'U';
			when 'Z' =>
				return 'Z';
			when 'W' =>
				return 'W';
			when 'L' =>
				return 'L';
			when 'H' =>
				return 'H';
			when others =>
				return '-';
		end case;
	end function;
	
	function slv_to_str(v : std_logic_vector) return STRING is
		variable s : STRING(1 to v'LENGTH);
	begin
		for i in s'HIGH downto s'LOW loop
			s(i) := logic_to_char(v(i-1));
		end loop;
		return s;
	end function;
end test_utils;