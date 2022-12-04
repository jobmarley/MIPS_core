
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.numeric_std.all;
use work.mips_utils.all;

entity core_test is
  Port ( 
	resetn : in std_logic;
	clock : in std_ulogic;
					
	-- memory port a
	m_axi_mema_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_mema_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
	m_axi_mema_arlock : out STD_LOGIC;
	m_axi_mema_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_arready : in STD_LOGIC;
	m_axi_mema_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_arvalid : out STD_LOGIC;
	m_axi_mema_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_mema_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
	m_axi_mema_awlock : out STD_LOGIC;
	m_axi_mema_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_awready : in STD_LOGIC;
	m_axi_mema_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_awvalid : out STD_LOGIC;
	m_axi_mema_bready : out STD_LOGIC;
	m_axi_mema_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_bvalid : in STD_LOGIC;
	m_axi_mema_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_rlast : in STD_LOGIC;
	m_axi_mema_rready : out STD_LOGIC;
	m_axi_mema_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_rvalid : in STD_LOGIC;
	m_axi_mema_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_wlast : out STD_LOGIC;
	m_axi_mema_wready : in STD_LOGIC;
	m_axi_mema_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_mema_wvalid : out STD_LOGIC;
	
	-- memory port b
	m_axi_memb_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_memb_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_memb_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_memb_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
	m_axi_memb_arlock : out STD_LOGIC;
	m_axi_memb_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_memb_arready : in STD_LOGIC;
	m_axi_memb_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_memb_arvalid : out STD_LOGIC;
	m_axi_memb_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_memb_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_memb_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_memb_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
	m_axi_memb_awlock : out STD_LOGIC;
	m_axi_memb_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_memb_awready : in STD_LOGIC;
	m_axi_memb_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_memb_awvalid : out STD_LOGIC;
	m_axi_memb_bready : out STD_LOGIC;
	m_axi_memb_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_memb_bvalid : in STD_LOGIC;
	m_axi_memb_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_memb_rlast : in STD_LOGIC;
	m_axi_memb_rready : out STD_LOGIC;
	m_axi_memb_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_memb_rvalid : in STD_LOGIC;
	m_axi_memb_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_memb_wlast : out STD_LOGIC;
	m_axi_memb_wready : in STD_LOGIC;
	m_axi_memb_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_memb_wvalid : out STD_LOGIC
	);
end core_test;

architecture core_test_behavioral of core_test is

	component mips_core_internal is
	  Port ( 
		resetn : in std_logic;
		clock : in std_ulogic;
		
		enable : in std_logic;
	
		breakpoint : out std_logic;
	
		register_port_in_a : in register_port_in_t;
		register_port_out_a : out register_port_out_t;
		
		-- memory port b
		m_axi_memb_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_memb_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_memb_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
		m_axi_memb_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
		m_axi_memb_arlock : out STD_LOGIC;
		m_axi_memb_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_memb_arready : in STD_LOGIC;
		m_axi_memb_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_memb_arvalid : out STD_LOGIC;
		m_axi_memb_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_memb_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_memb_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
		m_axi_memb_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
		m_axi_memb_awlock : out STD_LOGIC;
		m_axi_memb_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_memb_awready : in STD_LOGIC;
		m_axi_memb_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_memb_awvalid : out STD_LOGIC;
		m_axi_memb_bready : out STD_LOGIC;
		m_axi_memb_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_memb_bvalid : in STD_LOGIC;
		m_axi_memb_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_memb_rlast : in STD_LOGIC;
		m_axi_memb_rready : out STD_LOGIC;
		m_axi_memb_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_memb_rvalid : in STD_LOGIC;
		m_axi_memb_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_memb_wlast : out STD_LOGIC;
		m_axi_memb_wready : in STD_LOGIC;
		m_axi_memb_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
		m_axi_memb_wvalid : out STD_LOGIC;
	
		-- fetch
		fetch_instruction_address_plus_8 : in std_logic_vector(31 downto 0);
		fetch_instruction_address_plus_4 : in std_logic_vector(31 downto 0);
		fetch_instruction_address : in std_logic_vector(31 downto 0);
		fetch_instruction_data : in std_logic_vector(31 downto 0);
		fetch_instruction_data_valid : in std_logic;
		fetch_instruction_data_ready : out std_logic;
		
		fetch_override_address : out std_logic_vector(31 downto 0);
		fetch_override_address_valid : out std_logic;
		fetch_skip_jump : out std_logic;
		fetch_wait_jump : out std_logic;
		fetch_execute_delay_slot : out std_logic;
	
		stall : out std_logic
		);
	end component;

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
	type string_ptr_t is access STRING;
	type string_ptr_array_t is array(NATURAL range <>) of string_ptr_t; 
	type string_ptr_array_ptr_t is access string_ptr_array_t;
	
	procedure index_of(s : STRING; c : CHARACTER; start : INTEGER; index : out INTEGER) is
	begin
		index := -1;
		for i in start to s'LENGTH-1 loop
			if s(i) = c then
				index := i;
			end if;
		end loop;
	end procedure;
		
	type line_array_t is array(NATURAL RANGE <>) of LINE;
	type line_array_ptr_t is access line_array_t;
	procedure string_split(s : STRING; del : CHARACTER; parts : out line_array_ptr_t) is
		variable count : NATURAL := char_count(s, del);
		variable index : INTEGER := 1;
		variable j : INTEGER := 1;
		variable zzz : LINE;
	begin
		parts := new line_array_t(0 to count);
			
		for i in 0 to count-1 loop
			index_of(s, ',', index, j);
			zzz := new STRING'(s(index to j-1));
			parts(i) := zzz;
			index := j+1;
		end loop;
		if index > s'HIGH then
			parts(parts'LENGTH-1) := new STRING'("");
		else
			parts(parts'LENGTH-1) := new STRING'(s(index to s'HIGH));
		end if;
	end procedure;
	
	function string_to_integer(l : STRING) return INTEGER is
		variable index : INTEGER := 1;
		variable result : INTEGER := 0;
		variable digit : INTEGER := 0;
	begin
		while index <= l'LENGTH and l(index) = ' ' loop
			index := index + 1;
		end loop;
		assert index < l'LENGTH report "integer expected" severity ERROR;
		while index <= l'LENGTH loop
			if CHARACTER'POS(l(index)) >= CHARACTER'POS('a') and CHARACTER'POS(l(index)) <= CHARACTER'POS('f') then
				digit := CHARACTER'POS(l(index)) - CHARACTER'POS('a');
			elsif CHARACTER'POS(l(index)) >= CHARACTER'POS('A') and CHARACTER'POS(l(index)) <= CHARACTER'POS('F') then
				digit := CHARACTER'POS(l(index)) - CHARACTER'POS('A');
			elsif l(index) = ' ' then
				exit;
			else
				report "invalid character: " & CHARACTER'image(l(index)) severity ERROR;
			end if;
			result := result * 16 + digit;
			index := index + 1;
		end loop;
		return result;
	end function;
		
	signal processor_enable : std_logic;
	signal breakpoint : std_logic;
	
	signal register_port_in_a : register_port_in_t;
	signal register_port_out_a : register_port_out_t;
	
	-- fetch
	signal fetch_instruction_address_plus_8 : std_logic_vector(31 downto 0);
	signal fetch_instruction_address_plus_4 : std_logic_vector(31 downto 0);
	signal fetch_instruction_address : std_logic_vector(31 downto 0);
	signal fetch_instruction_data : std_logic_vector(31 downto 0);
	signal fetch_instruction_data_valid : std_logic;
	signal fetch_instruction_data_ready : std_logic;
		
	signal fetch_override_address : std_logic_vector(31 downto 0);
	signal fetch_override_address_valid : std_logic;
	signal fetch_execute_delay_slot : std_logic;
	signal fetch_skip_jump : std_logic;
	signal fetch_wait_jump : std_logic;
	signal fetch_error : std_logic;
	signal stall : std_logic;
	
	constant clock_period : TIME := 10ns;
	
	signal instr_address : UNSIGNED(31 downto 0);
	
	procedure send_instruction(instr : std_logic_vector) is
	begin
		fetch_error <= '0';
		fetch_instruction_data_valid <= '1';
		fetch_instruction_data <= instr;
		fetch_instruction_address <= std_logic_vector(instr_address);
		fetch_instruction_address_plus_4 <= std_logic_vector(instr_address + 4);
		fetch_instruction_address_plus_8 <= std_logic_vector(instr_address + 8);
		wait until fetch_instruction_data_ready = '1';
		wait for clock_period;
		instr_address <= instr_address + 4;
		fetch_instruction_data_valid <= '0';
	end procedure;
	
	procedure check_register_value(r : std_logic_vector; data : std_logic_vector; success : BOOLEAN) is
	begin
	end procedure;
	
	procedure write_register(r : std_logic_vector; data : std_logic_vector) is
	begin
		register_port_in_a.address <= r;
		register_port_in_a.write_data <= data;
		register_port_in_a.write_enable <= '1';
		register_port_in_a.write_pending <= '0';
		register_port_in_a.write_strobe <= x"F";
		wait for clock_period;
		register_port_in_a.write_enable <= '0';
	end procedure;
begin

	process
		file f : text open read_mode is "instruction_test_commands.txt";
		variable l : line;
		
		variable parts : line_array_ptr_t;
		variable itmp : INTEGER;
		variable instr_data : std_logic_vector(31 downto 0);
		variable expected_reg : std_logic_vector(5 downto 0);
		variable expected_data : std_logic_vector(31 downto 0);
		variable iline : NATURAL := 0;
		variable success : BOOLEAN;
	begin
		while not endfile(f) and not endfile(f) loop
			READLINE(f,l);
		
			string_split(l(l'range), ' ', parts);
		
			if parts(0)(parts(0)'range) = "EXEC" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				instr_data := std_logic_vector(TO_UNSIGNED(itmp, 32));
				send_instruction(instr_data);
			elsif parts(0)(parts(0)'range) = "CHECK_REG" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_reg := std_logic_vector(TO_UNSIGNED(itmp, 6));
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data := std_logic_vector(TO_UNSIGNED(itmp, 32));
				check_register_value(expected_reg, expected_data, success);
			elsif  parts(0)(parts(0)'range) = "WRITE_REG" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_reg := std_logic_vector(TO_UNSIGNED(itmp, 6));
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data := std_logic_vector(TO_UNSIGNED(itmp, 32));
				write_register(expected_reg, expected_data);
			end if;
		
			if not success then
				report "instruction test failed on line " & INTEGER'image(iline) severity ERROR;
				report "instruction " & l(l'range) severity ERROR;
			end if;
		
			iline := iline + 1;
		end loop;
		wait;
	end process;
	
	mips_core_internal_i0 : mips_core_internal port map ( 
		resetn => resetn,
		clock => clock,
		
		enable => processor_enable,
	
		breakpoint => breakpoint,
	
		register_port_in_a => register_port_in_a,
		register_port_out_a => register_port_out_a,
		
		m_axi_memb_araddr => m_axi_memb_araddr,
		m_axi_memb_arburst => m_axi_memb_arburst,
		m_axi_memb_arcache => m_axi_memb_arcache,
		m_axi_memb_arlen => m_axi_memb_arlen,
		m_axi_memb_arlock => m_axi_memb_arlock,
		m_axi_memb_arprot => m_axi_memb_arprot,
		m_axi_memb_arready => m_axi_memb_arready,
		m_axi_memb_arsize => m_axi_memb_arsize,
		m_axi_memb_arvalid => m_axi_memb_arvalid,
		m_axi_memb_awaddr => m_axi_memb_awaddr,
		m_axi_memb_awburst => m_axi_memb_awburst,
		m_axi_memb_awcache => m_axi_memb_awcache,
		m_axi_memb_awlen => m_axi_memb_awlen,
		m_axi_memb_awlock => m_axi_memb_awlock,
		m_axi_memb_awprot => m_axi_memb_awprot,
		m_axi_memb_awready => m_axi_memb_awready,
		m_axi_memb_awsize => m_axi_memb_awsize,
		m_axi_memb_awvalid => m_axi_memb_awvalid,
		m_axi_memb_bready => m_axi_memb_bready,
		m_axi_memb_bresp => m_axi_memb_bresp,
		m_axi_memb_bvalid => m_axi_memb_bvalid,
		m_axi_memb_rdata => m_axi_memb_rdata,
		m_axi_memb_rlast => m_axi_memb_rlast,
		m_axi_memb_rready => m_axi_memb_rready,
		m_axi_memb_rresp => m_axi_memb_rresp,
		m_axi_memb_rvalid => m_axi_memb_rvalid,
		m_axi_memb_wdata => m_axi_memb_wdata,
		m_axi_memb_wlast => m_axi_memb_wlast,
		m_axi_memb_wready => m_axi_memb_wready,
		m_axi_memb_wstrb => m_axi_memb_wstrb,
		m_axi_memb_wvalid => m_axi_memb_wvalid,
	
		-- fetch
		fetch_instruction_address_plus_8 => fetch_instruction_address_plus_8,
		fetch_instruction_address_plus_4 => fetch_instruction_address_plus_4,
		fetch_instruction_address => fetch_instruction_address,
		fetch_instruction_data => fetch_instruction_data,
		fetch_instruction_data_valid => fetch_instruction_data_valid,
		fetch_instruction_data_ready => fetch_instruction_data_ready,
		
		fetch_override_address => fetch_override_address,
		fetch_override_address_valid => fetch_override_address_valid,
		fetch_skip_jump => fetch_skip_jump,
		fetch_wait_jump => fetch_wait_jump,
		fetch_execute_delay_slot => fetch_execute_delay_slot,
	
		stall => stall
		);
end core_test_behavioral;
