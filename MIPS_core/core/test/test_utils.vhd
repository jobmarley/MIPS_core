library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use std.textio.all;

package test_utils is
	type string_ptr_t is access STRING;
	type string_ptr_array_t is array(NATURAL range <>) of string_ptr_t; 
	type string_ptr_array_ptr_t is access string_ptr_array_t;
	type line_array_t is array(NATURAL RANGE <>) of LINE;
	type line_array_ptr_t is access line_array_t;
	
	function char_count(s : STRING; c : CHARACTER) return NATURAL;
	function index_of(s : STRING; c : CHARACTER; start : INTEGER) return INTEGER;
	procedure string_split(s : STRING; del : CHARACTER; parts : out line_array_ptr_t);
	function string_to_integer(l : STRING; size : NATURAL := 32) return UNSIGNED;
	function hexchar(n : NATURAL) return CHARACTER;
	function hex(n : UNSIGNED; size : NATURAL := 32) return STRING;
	
	function logic_to_char(l : std_logic) return CHARACTER;
	function slv_to_str(v : std_logic_vector) return STRING;
end test_utils;

package body test_utils is
	
	
	function char_count(s : STRING; c : CHARACTER) return NATURAL is
		variable count : NATURAL := 0;
	begin
		for i in 1 to s'LENGTH loop
			if s(i) = c then
				count := count + 1;
			end if;
		end loop;
		return count;
	end function;
	
	function index_of(s : STRING; c : CHARACTER; start : INTEGER) return INTEGER is
	begin
		for i in start to s'LENGTH-1 loop
			if s(i) = c then
				return i;
			end if;
		end loop;
		return -1;
	end function;
		
	procedure string_split(s : STRING; del : CHARACTER; parts : out line_array_ptr_t) is
		variable count : NATURAL := char_count(s, del);
		variable index : INTEGER := 1;
		variable j : INTEGER := 1;
	begin
		parts := new line_array_t(0 to count);
			
		for i in 0 to count-1 loop
			j := index_of(s, del, index);
			parts(i) := new STRING'(s(index to j-1));
			index := j+1;
		end loop;
		if index > s'HIGH then
			parts(parts'HIGH) := new STRING'("");
		else
			parts(parts'HIGH) := new STRING'(s(index to s'HIGH));
		end if;
	end procedure;
	
	-- use unsigned because integer is only signed 32bits
	-- if we have > 0x80000000 that fails
	function string_to_integer(l : STRING; size : NATURAL := 32) return UNSIGNED is
		variable index : INTEGER := l'LOW;
		variable result : UNSIGNED(size-1 downto 0) := TO_UNSIGNED(0, size);
		variable digit : INTEGER := 0;
		variable tmp : UNSIGNED(size*2-1 downto 0);
	begin
		while index <= l'HIGH and l(index) = ' ' loop
			index := index + 1;
		end loop;
		assert index < l'HIGH report "integer expected" severity ERROR;
		while index <= l'HIGH loop
			if CHARACTER'POS(l(index)) >= CHARACTER'POS('0') and CHARACTER'POS(l(index)) <= CHARACTER'POS('9') then
				digit := CHARACTER'POS(l(index)) - CHARACTER'POS('0');
			elsif CHARACTER'POS(l(index)) >= CHARACTER'POS('a') and CHARACTER'POS(l(index)) <= CHARACTER'POS('f') then
				digit := CHARACTER'POS(l(index)) - CHARACTER'POS('a') + 10;
			elsif CHARACTER'POS(l(index)) >= CHARACTER'POS('A') and CHARACTER'POS(l(index)) <= CHARACTER'POS('F') then
				digit := CHARACTER'POS(l(index)) - CHARACTER'POS('A') + 10;
			elsif l(index) = ' ' then
				exit;
			else
				report "invalid character: " & CHARACTER'image(l(index)) severity ERROR;
			end if;
			tmp := result * 16;
			result := tmp(size-1 downto 0) + TO_UNSIGNED(digit, size);
			index := index + 1;
		end loop;
		return result;
	end function;
	
	function hexchar(n : NATURAL) return CHARACTER is
	begin
		if n < 10 then
			return CHARACTER'VAL(CHARACTER'POS('0') + n);
		else
			return CHARACTER'VAL(CHARACTER'POS('A') + (n mod 10));
		end if;
	end function;
	
	function hex(n : UNSIGNED; size : NATURAL := 32) return STRING is
		variable s : STRING(1 to size / 4);
		variable j : UNSIGNED(n'range) := n;
	begin
		for i in s'HIGH downto s'LOW loop
			s(i) := hexchar(TO_INTEGER(j(3 downto 0)));
			j := "0000" & j(j'HIGH downto j'LOW+4);
		end loop;
		return s;
	end function;
	
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