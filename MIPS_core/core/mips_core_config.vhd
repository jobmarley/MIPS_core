library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


package mips_core_config is
	
	-----------------------------------------------------------
	-- CONFIG 0
	-----------------------------------------------------------
	constant CONFIG0_CONFIG1_IMPLEMENTED : std_logic := '0';
	constant CONFIG0_IMPL : std_logic_vector(14 downto 0) := (others => '0');
	
	constant CONFIG0_ENDIANNESS_LITTLE : std_logic := '0';
	constant CONFIG0_ENDIANNESS : std_logic := CONFIG0_ENDIANNESS_LITTLE;
	
	constant CONFIG0_ARCHITECTURE_TYPE_MIPS32 : std_logic_vector(1 downto 0) := "00";
	constant CONFIG0_ARCHITECTURE_TYPE : std_logic_vector(1 downto 0) := CONFIG0_ARCHITECTURE_TYPE_MIPS32;

	constant CONFIG0_ARCHITECTURE_REVISION : std_logic_vector(2 downto 0) := "000";
	
	constant CONFIG0_MMU_TYPE_NONE : std_logic_vector(2 downto 0) := "000";
	constant CONFIG0_MMU_TYPE : std_logic_vector(2 downto 0) := CONFIG0_MMU_TYPE_NONE;
	
	constant CONFIG0_KSEG0 : std_logic_vector(2 downto 0) := "000";
	
	-----------------------------------------------------------
	-- CONFIG 1
	-----------------------------------------------------------
	constant CONFIG1_CONFIG2_IMPLEMENTED : std_logic := '0';
	constant CONFIG1_MMU_SIZE : std_logic_vector(5 downto 0) := (others => '0');
	constant CONFIG1_INSTR_CACHE_SETS : std_logic_vector(2 downto 0) := std_logic_vector(TO_UNSIGNED(0, 3)); -- 64 * 2^i
	constant CONFIG1_INSTR_CACHE_LINE_SIZE : std_logic_vector(2 downto 0) := std_logic_vector(TO_UNSIGNED(4, 3)); -- 2 * 2^i (0 => no instruction cache)
	constant CONFIG1_INSTR_CACHE_ASSOCIATIVITY : std_logic_vector(2 downto 0) := std_logic_vector(TO_UNSIGNED(1, 3)); -- 2^i
	
	constant CONFIG1_DATA_CACHE_SETS : std_logic_vector(2 downto 0) := std_logic_vector(TO_UNSIGNED(0, 3)); -- 64 * 2^i
	constant CONFIG1_DATA_CACHE_LINE_SIZE : std_logic_vector(2 downto 0) := std_logic_vector(TO_UNSIGNED(0, 3)); -- 2 * 2^i (0 => no instruction cache)
	constant CONFIG1_DATA_CACHE_ASSOCIATIVITY : std_logic_vector(2 downto 0) := std_logic_vector(TO_UNSIGNED(0, 3)); -- 2^i
	constant CONFIG1_COP2_PRESENT : std_logic := '0';
	constant CONFIG1_MDMX_ASE : std_logic := '0';		-- mips64 only
	constant CONFIG1_PERFORMANCE_COUNTER_IMPLEMENTED : std_logic := '0';
	constant CONFIG1_WATCH_REGISTER_IMPLEMENTED : std_logic := '0';
	constant CONFIG1_MIPS16_IMPLEMENTED : std_logic := '0';
	constant CONFIG1_EJTAG_IMPLEMENTED : std_logic := '0';
	constant CONFIG1_FPU_IMPLEMENTED : std_logic := '0';
	
end mips_core_config;