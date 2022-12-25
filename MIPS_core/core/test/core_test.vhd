
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.numeric_std.all;
use work.mips_utils.all;
use work.axi_helper.all;
use work.test_utils.all;

entity core_test is
  Port ( 
	resetn : in std_logic;
	clock : in std_ulogic;
					
	-- memory port a
	m_axi_mema_araddr : out std_logic_vector ( 31 downto 0 );
	m_axi_mema_arburst : out std_logic_vector ( 1 downto 0 );
	m_axi_mema_arcache : out std_logic_vector ( 3 downto 0 );
	m_axi_mema_arlen : out std_logic_vector ( 7 downto 0 );
	m_axi_mema_arlock : out std_logic;
	m_axi_mema_arprot : out std_logic_vector ( 2 downto 0 );
	m_axi_mema_arready : in std_logic;
	m_axi_mema_arsize : out std_logic_vector ( 2 downto 0 );
	m_axi_mema_arvalid : out std_logic;
	m_axi_mema_awaddr : out std_logic_vector ( 31 downto 0 );
	m_axi_mema_awburst : out std_logic_vector ( 1 downto 0 );
	m_axi_mema_awcache : out std_logic_vector ( 3 downto 0 );
	m_axi_mema_awlen : out std_logic_vector ( 7 downto 0 );
	m_axi_mema_awlock : out std_logic;
	m_axi_mema_awprot : out std_logic_vector ( 2 downto 0 );
	m_axi_mema_awready : in std_logic;
	m_axi_mema_awsize : out std_logic_vector ( 2 downto 0 );
	m_axi_mema_awvalid : out std_logic;
	m_axi_mema_bready : out std_logic;
	m_axi_mema_bresp : in std_logic_vector ( 1 downto 0 );
	m_axi_mema_bvalid : in std_logic;
	m_axi_mema_rdata : in std_logic_vector ( 31 downto 0 );
	m_axi_mema_rlast : in std_logic;
	m_axi_mema_rready : out std_logic;
	m_axi_mema_rresp : in std_logic_vector ( 1 downto 0 );
	m_axi_mema_rvalid : in std_logic;
	m_axi_mema_wdata : out std_logic_vector ( 31 downto 0 );
	m_axi_mema_wlast : out std_logic;
	m_axi_mema_wready : in std_logic;
	m_axi_mema_wstrb : out std_logic_vector ( 3 downto 0 );
	m_axi_mema_wvalid : out std_logic;
	
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
		
		register_hilo_in : in hilo_register_port_in_t;
		register_hilo_out : out hilo_register_port_out_t;
	
		cop0_reg_port_in_a : in cop0_register_port_in_t;
		cop0_reg_port_out_a : out cop0_register_port_out_t;
	
		debug_registers_written : out registers_pending_t;
		debug_registers_values : out registers_values_t;
	
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
		
	signal processor_enable : std_logic;
	signal breakpoint : std_logic;
	
	signal register_port_in_a : register_port_in_t;
	signal register_port_out_a : register_port_out_t;
	signal register_hilo_in : hilo_register_port_in_t;
	signal register_hilo_out : hilo_register_port_out_t;
	
	signal cop0_reg_port_in_a : cop0_register_port_in_t;
	signal cop0_reg_port_out_a : cop0_register_port_out_t;
	
	signal debug_registers_written : registers_pending_t;
	signal debug_registers_values : registers_values_t;
	
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
		
	type fetch_data_in_t is record
		fetch_instruction_data_ready : std_logic;
		fetch_override_address : std_logic_vector(31 downto 0);
		fetch_override_address_valid : std_logic;
		fetch_execute_delay_slot : std_logic;
		fetch_skip_jump : std_logic;
		fetch_wait_jump : std_logic;
		stall : std_logic;
	end record;
	type fetch_data_out_t is record
		fetch_instruction_address_plus_8 : std_logic_vector(31 downto 0);
		fetch_instruction_address_plus_4 : std_logic_vector(31 downto 0);
		fetch_instruction_address : std_logic_vector(31 downto 0);
		fetch_instruction_data : std_logic_vector(31 downto 0);
		fetch_instruction_data_valid : std_logic;
		fetch_error : std_logic;
	end record;
	
	signal fetch_data_in : fetch_data_in_t;
	signal fetch_data_out : fetch_data_out_t;
	
	procedure send_instruction(instr : std_logic_vector; signal fdi : in fetch_data_in_t; signal fdo : out fetch_data_out_t)  is
	begin
		fdo.fetch_error <= '0';
		fdo.fetch_instruction_data_valid <= '1';
		fdo.fetch_instruction_data <= instr;
		if fdi.fetch_instruction_data_ready = '0' then
			wait until fdi.fetch_instruction_data_ready = '1' for 10*clock_period;
		end if;
		assert fdi.fetch_instruction_data_ready = '1' report "send_instruction: decode ready timed out" severity FAILURE;
		wait for clock_period;
		fdo.fetch_instruction_data_valid <= '0';
	end procedure;
	
	procedure check_register_value(r : std_logic_vector; data : std_logic_vector;
		signal pin : out register_port_in_t;
		signal pout : in register_port_out_t;
		signal pc0in : out cop0_register_port_in_t;
		signal pc0out : in cop0_register_port_out_t;
		variable reg_mask : out registers_pending_t) is
	begin
		if r(5) = '0' then
			pin.address <= r(4 downto 0);
			pin.write_enable <= '0';
			wait for clock_period;
			wait for clock_period;
			
			assert pout.data = data report "check_register_value failed for register $" & INTEGER'image(TO_INTEGER(unsigned(r))) & ", expected " & hex(unsigned(data)) & ", got " & hex(unsigned(pout.data)) severity FAILURE;
			reg_mask.gp_registers(TO_INTEGER(unsigned(r(4 downto 0)))) := '1';
		else
			pc0in.address <= r(4 downto 0);
			pc0in.write_enable <= '0';
			wait for clock_period;
			wait for clock_period;
			
			assert pc0out.data = data report "check_register_value failed for register $" & INTEGER'image(TO_INTEGER(unsigned(r))) & ", expected " & hex(unsigned(data)) & ", got " & hex(unsigned(pc0out.data)) severity FAILURE;
		end if;
	end procedure;
	
	procedure check_hilo_value(
		data : std_logic_vector;
		signal pin : out hilo_register_port_in_t;
		signal pout : in hilo_register_port_out_t;
		variable reg_mask : out registers_pending_t) is
	begin
		pin.write_enable <= '0';
		wait for clock_period;
				
		assert pout.data = data report "check_hilo_value failed, expected " & hex(unsigned(data), 64) & ", got " & hex(unsigned(pout.data), 64) severity FAILURE;
		reg_mask.hi := '1';
		reg_mask.lo := '1';
	end procedure;
	
	procedure check_branch(
		override_address : std_logic_vector;
		execute_delay_slot : std_logic;
		skip : std_logic;
		signal bcd : in fetch_data_in_t) is
	begin
		assert bcd.fetch_wait_jump = '1' report "CHECK_BRANCH failed, wait_jump was not set in first cycle" severity FAILURE;
		assert bcd.fetch_skip_jump = skip report "CHECK_BRANCH failed, skip value wrong, expected " & logic_to_char(skip) & ", got " & logic_to_char(bcd.fetch_skip_jump) severity FAILURE;
		assert bcd.fetch_execute_delay_slot = execute_delay_slot report "CHECK_BRANCH failed, execute_delay_slot value wrong, expected " & logic_to_char(execute_delay_slot) & ", got " & logic_to_char(bcd.fetch_execute_delay_slot) severity FAILURE;
		assert bcd.fetch_override_address_valid = '1' or bcd.fetch_skip_jump = '1' report "CHECK_BRANCH failed, didn't receive skip/override address" severity FAILURE;
		assert bcd.fetch_override_address_valid = '0' or bcd.fetch_override_address = override_address report "CHECK_BRANCH failed, override_address value wrong, expected " & hex(unsigned(override_address), 32) & ", got " & hex(unsigned(bcd.fetch_override_address), 32) severity FAILURE;	
	end procedure;
	
	procedure write_register(r : std_logic_vector; data : std_logic_vector; signal p : out register_port_in_t; signal pc0 : out cop0_register_port_in_t) is
	begin
		p.address <= r(4 downto 0);
		p.write_data <= data;
		p.write_enable <= not r(5);
		p.write_strobe <= x"F";
		
		pc0.address <= r(4 downto 0);
		pc0.write_data <= data;
		pc0.write_enable <= r(5);
		pc0.write_strobe <= x"F";
		
		wait for clock_period;
		p.write_enable <= '0';
		pc0.write_enable <= '0';
	end procedure;
	
	procedure write_hilo(data : std_logic_vector; signal p : out hilo_register_port_in_t) is
	begin
		p.write_data <= data;
		p.write_enable <= '1';
		p.write_strobe <= "11";
		wait for clock_period;
		p.write_enable <= '0';
	end procedure;
	
	signal axi4_mem_out : axi4_port_out_t;
	signal axi4_mem_in : axi4_port_in_t;
	
	signal current_address : std_logic_vector(31 downto 0);
	
	signal fetch_data_in_reg : fetch_data_in_t;
	
	signal registers_check_reg : registers_pending_t;
	signal registers_check_on : std_logic;
	
	
	signal branch_checker_data : fetch_data_in_t;
	signal branch_checker_on : std_logic;
	signal expected_branch_data : fetch_data_in_t;
	
	procedure validate_written_registers(
		mask : registers_pending_t;
		registers_written : registers_pending_t
		) is
	begin		
		for i in mask.gp_registers'range loop
			if mask.gp_registers(i) = '1' and registers_written.gp_registers(i) /= '1' then
				report "register " & INTEGER'image(i) & " was not written" severity FAILURE;
			end if;
			if mask.gp_registers(i) = '0' and registers_written.gp_registers(i) = '1' then
				report "register " & INTEGER'image(i) & " was written but shouldn't have been" severity FAILURE;
			end if;
		end loop;
		
		
		if mask.hi = '1' and registers_written.hi /= '1' then
			report "register hi was reset but not written" severity FAILURE;
		end if;
		if mask.hi = '0' and registers_written.hi = '1' then
			report "register hi was written but shouldn't have been" severity FAILURE;
		end if;
		
		if mask.lo = '1' and registers_written.lo /= '1' then
			report "register lo was reset but not written" severity FAILURE;
		end if;
		if mask.lo = '0' and registers_written.lo = '1' then
			report "register lo was written but shouldn't have been" severity FAILURE;
		end if;
	end procedure;
			
	procedure validate_branch(
		expected : fetch_data_in_t;
		result : fetch_data_in_t) is
	begin
		assert expected.fetch_execute_delay_slot = result.fetch_execute_delay_slot report "validate_branch failed, execute delay slot was expected and not set" severity FAILURE;
		assert expected.fetch_skip_jump = result.fetch_skip_jump report "validate_branch failed, skip was expected and not set" severity FAILURE;
		assert expected.fetch_wait_jump = result.fetch_wait_jump report "validate_branch failed, wait jump was expected and not set" severity FAILURE;
		assert expected.fetch_override_address_valid = result.fetch_override_address_valid report "validate_branch failed, override valid was expected and not set" severity FAILURE;
		if expected.fetch_override_address_valid = '1' then
			assert expected.fetch_override_address = result.fetch_override_address report "validate_branch failed, address do not match" severity FAILURE;
		end if;
	end procedure;
	
	signal expected_register_write : registers_pending_t;
	signal expected_register_values : registers_values_t;
begin	
	fetch_instruction_address <= current_address;
	fetch_instruction_address_plus_4 <= std_logic_vector(unsigned(current_address) + 4);
	fetch_instruction_address_plus_8 <= std_logic_vector(unsigned(current_address) + 8);
	
	processor_enable <= resetn;
	
	axi4_mem_in.arready <= m_axi_mema_arready;
	axi4_mem_in.awready <= m_axi_mema_awready;
	axi4_mem_in.bresp <= m_axi_mema_bresp;
	axi4_mem_in.bvalid <= m_axi_mema_bvalid;
	axi4_mem_in.rdata <= m_axi_mema_rdata;
	axi4_mem_in.rlast <= m_axi_mema_rlast;
	axi4_mem_in.rresp <= m_axi_mema_rresp;
	axi4_mem_in.rvalid <= m_axi_mema_rvalid;
	axi4_mem_in.wready <= m_axi_mema_wready;

	m_axi_mema_araddr <= axi4_mem_out.araddr;
	m_axi_mema_arburst <= axi4_mem_out.arburst;
	m_axi_mema_arcache <= axi4_mem_out.arcache;
	m_axi_mema_arlen <= axi4_mem_out.arlen;
	m_axi_mema_arlock <= axi4_mem_out.arlock;
	m_axi_mema_arprot <= axi4_mem_out.arprot;
	m_axi_mema_arsize <= axi4_mem_out.arsize;
	m_axi_mema_arvalid <= axi4_mem_out.arvalid;
	m_axi_mema_awaddr <= axi4_mem_out.awaddr;
	m_axi_mema_awburst <= axi4_mem_out.awburst;
	m_axi_mema_awcache <= axi4_mem_out.awcache;
	m_axi_mema_awlen <= axi4_mem_out.awlen;
	m_axi_mema_awlock <= axi4_mem_out.awlock;
	m_axi_mema_awprot <= axi4_mem_out.awprot;
	m_axi_mema_awsize <= axi4_mem_out.awsize;
	m_axi_mema_awvalid <= axi4_mem_out.awvalid;
	m_axi_mema_bready <= axi4_mem_out.bready;
	m_axi_mema_rready <= axi4_mem_out.rready;
	m_axi_mema_wdata <= axi4_mem_out.wdata;
	m_axi_mema_wlast <= axi4_mem_out.wlast;
	m_axi_mema_wstrb <= axi4_mem_out.wstrb;
	m_axi_mema_wvalid <= axi4_mem_out.wvalid;
	
	fetch_data_in.fetch_instruction_data_ready <= fetch_instruction_data_ready;
	fetch_data_in.fetch_override_address <= fetch_override_address;
	fetch_data_in.fetch_override_address_valid <= fetch_override_address_valid;
	fetch_data_in.fetch_execute_delay_slot <= fetch_execute_delay_slot;
	fetch_data_in.fetch_skip_jump <= fetch_skip_jump;
	fetch_data_in.fetch_wait_jump <= fetch_wait_jump;
	fetch_data_in.stall <= stall;
	
	fetch_instruction_data <= fetch_data_out.fetch_instruction_data;
	fetch_instruction_data_valid <= fetch_data_out.fetch_instruction_data_valid;
	fetch_error <= fetch_data_out.fetch_error;
	
	
	process(clock)
	begin
		if rising_edge(clock) then
			fetch_data_in_reg <= fetch_data_in;
		end if;
	end process;
	
	-- registers process: keep track of written registers and raise an error if a register is written twice
	process(clock)
	begin
		if rising_edge(clock) then
			if registers_check_on = '0' then
				registers_check_reg.gp_registers <= (others => '0');
				registers_check_reg.hi <= '0';
				registers_check_reg.lo <= '0';
			else
				for i in debug_registers_written.gp_registers'range loop
					assert registers_check_reg.gp_registers(i) = '0' or debug_registers_written.gp_registers(i) = '0' report "register written twice, reg " & INTEGER'image(i) severity FAILURE;
					assert debug_registers_written.gp_registers(i) = '0' or expected_register_write.gp_registers(i) = '1' report "register " & INTEGER'image(i) & " written but shouldn't have been, reg " & INTEGER'image(i) severity FAILURE;
					assert registers_check_reg.gp_registers(i) = '0' or debug_registers_values.gp_registers(i) = expected_register_values.gp_registers(i) report "register written but value is not good. expected " & hex(unsigned(expected_register_values.gp_registers(i)), 32) & ", got " & hex(unsigned(debug_registers_values.gp_registers(i)), 32) severity FAILURE;
				end loop;
				assert registers_check_reg.hi = '0' or debug_registers_written.hi = '0' report "register hi written twice" severity FAILURE;
				assert debug_registers_written.hi = '0' or expected_register_write.hi = '1' report "register hi written but shouldn't have been" severity FAILURE;
				assert registers_check_reg.hi = '0' or debug_registers_values.hi = expected_register_values.hi report "register hi written but value is not good. expected " & hex(unsigned(expected_register_values.hi), 32) & ", got " & hex(unsigned(debug_registers_values.hi), 32) severity FAILURE;
				
				assert registers_check_reg.lo = '0' or debug_registers_written.lo = '0' report "register lo written twice" severity FAILURE;
				assert debug_registers_written.lo = '0' or expected_register_write.lo = '1' report "register lo written but shouldn't have been" severity FAILURE;
				assert registers_check_reg.lo = '0' or debug_registers_values.lo = expected_register_values.lo report "register lo written but value is not good. expected " & hex(unsigned(expected_register_values.lo), 32) & ", got " & hex(unsigned(debug_registers_values.lo), 32) severity FAILURE;
				
				registers_check_reg.gp_registers <= (registers_check_reg.gp_registers or debug_registers_written.gp_registers);
				registers_check_reg.hi <= (registers_check_reg.hi or debug_registers_written.hi);
				registers_check_reg.lo <= (registers_check_reg.lo or debug_registers_written.lo);
			end if;
		end if;
	end process;
	
	-- branch process
	process(clock)
	begin
		if rising_edge(clock) then
			if branch_checker_on = '0' then
				branch_checker_data.fetch_override_address <= (others => '0');
				branch_checker_data.fetch_override_address_valid <= '0';
				branch_checker_data.fetch_skip_jump <= '0';
				branch_checker_data.fetch_wait_jump <= '0';
				branch_checker_data.fetch_execute_delay_slot <= '0';
			else
				if fetch_override_address_valid = '1' then
					assert expected_branch_data.fetch_override_address_valid = '1' report "override address valid but was not expected" severity FAILURE;
					assert branch_checker_data.fetch_override_address_valid = '0' report "override address valid set twice" severity FAILURE;
					assert expected_branch_data.fetch_override_address = fetch_override_address report "override address doesnt match. expected " & hex(unsigned(expected_branch_data.fetch_override_address), 32) & ", got " & hex(unsigned(fetch_override_address), 32) severity FAILURE;
					branch_checker_data.fetch_override_address <= fetch_override_address;
					branch_checker_data.fetch_override_address_valid <= '1';
				end if;
				
				assert branch_checker_data.fetch_skip_jump = '0' or fetch_skip_jump = '0' report "skip jump set twice" severity FAILURE;
				assert fetch_skip_jump = '0' or expected_branch_data.fetch_skip_jump = '1' report "skip jump set but not expected" severity FAILURE;
				assert branch_checker_data.fetch_wait_jump = '0' or fetch_wait_jump = '0' report "wait jump set twice" severity FAILURE;
				assert fetch_wait_jump = '0' or expected_branch_data.fetch_wait_jump = '1' report "wait jump set but not expected" severity FAILURE;
				assert branch_checker_data.fetch_execute_delay_slot = '0' or fetch_execute_delay_slot = '0' report "execute delay slot set twice" severity FAILURE;
				assert fetch_execute_delay_slot = '0' or expected_branch_data.fetch_execute_delay_slot = '1' report "execute delay slot set but not expected" severity FAILURE;
				branch_checker_data.fetch_skip_jump <= branch_checker_data.fetch_skip_jump or fetch_skip_jump;
				branch_checker_data.fetch_wait_jump <= branch_checker_data.fetch_wait_jump or (fetch_instruction_data_valid and fetch_wait_jump);
				branch_checker_data.fetch_execute_delay_slot <= branch_checker_data.fetch_execute_delay_slot or fetch_execute_delay_slot;
			end if;
		end if;
	end process;
	
	process
		-- filepaths are relative to the core_test_proj.sim\sim_1\behav\xsim folder
		file f : text open read_mode is "../../../../../instruction_test_commands.txt";
		variable l : line;
		file f2 : text open read_mode is "../../../../../instruction_test_asm.asm";
		variable l2 : line;
		
		variable parts : line_array_ptr_t;
		variable itmp : UNSIGNED(31 downto 0);
		variable instr_data : std_logic_vector(31 downto 0);
		variable expected_reg : std_logic_vector(5 downto 0);
		variable expected_data : std_logic_vector(31 downto 0);
		variable expected_data_hilo : std_logic_vector(63 downto 0);
		variable ram_address : std_logic_vector(31 downto 0);
		variable ram_data : std_logic_vector(31 downto 0);
		variable ram_result : std_logic_vector(31 downto 0);
		variable ram_resp : std_logic_vector(1 downto 0);
		variable iline : NATURAL := 0;
		variable success : BOOLEAN;
		variable ireg : INTEGER;
	begin	
		AXI4_idle(axi4_mem_out);
		
		fetch_data_out.fetch_instruction_data <= (others => '0');
		fetch_data_out.fetch_error <= '0';
		fetch_data_out.fetch_instruction_data_valid <= '0';
		register_port_in_a.address <= (others => '0');
		register_port_in_a.write_data <= (others => '0');
		register_port_in_a.write_enable <= '0';
		register_port_in_a.write_strobe <= x"F";
		
		cop0_reg_port_in_a.address <= (others => '0');
		cop0_reg_port_in_a.write_data <= (others => '0');
		cop0_reg_port_in_a.write_enable <= '0';
		cop0_reg_port_in_a.write_strobe <= x"F";
		
		current_address <= (others => '0');
		
		expected_register_values <= (gp_registers => (others => (others => '0')), others => (others => '0'));
		expected_register_write <= (gp_registers => (others => '0'), others => '0');
		registers_check_on <= '0';
		expected_branch_data <= (fetch_override_address => (others => '0'), others => '0');
		branch_checker_on <= '0';
		wait until resetn = '1';
		
		while not endfile(f) loop
			READLINE(f,l);
		
			string_split(l(l'range), ' ', parts);
			if l(1) = '#' then
				-- comment
			elsif parts(0)(parts(0)'range) = "EXEC" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				instr_data := std_logic_vector(itmp);
				send_instruction(instr_data, fetch_data_in, fetch_data_out);
				-- needs to be longer than longest operation aka div
				--wait for 40*clock_period;
				READLINE(f2,l2);
				report "executing " & l2(l2'range);
			elsif parts(0)(parts(0)'range) = "SKIP_ASM_LINE" then
				READLINE(f2,l2);
			elsif parts(0)(parts(0)'range) = "CHECK_HILO" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_data_hilo(63 downto 32) := std_logic_vector(itmp);
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data_hilo(31 downto 0) := std_logic_vector(itmp);
			
				assert expected_register_write.hi = '0' and expected_register_write.lo = '0' report "cannot check twice the same register (hilo)" severity FAILURE;
				expected_register_write.hi <= '1';
				expected_register_write.lo <= '1';
				expected_register_values.hi <= expected_data_hilo(63 downto 32);
				expected_register_values.lo <= expected_data_hilo(31 downto 0);
			
			elsif parts(0)(parts(0)'range) = "WRITE_HILO" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_data_hilo(63 downto 32) := std_logic_vector(itmp);
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data_hilo(31 downto 0) := std_logic_vector(itmp);
				write_hilo(expected_data_hilo, register_hilo_in);
			elsif parts(0)(parts(0)'range) = "CHECK_REG" then
				ireg := TO_INTEGER(string_to_integer(parts(1)(parts(1)'range)));
				expected_reg := std_logic_vector(itmp(5 downto 0));
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data := std_logic_vector(itmp);
						
				assert ireg >= 0 and ireg <= 31 report "CHECK_REG register must be between 0 and 31" severity FAILURE;
				assert expected_register_write.gp_registers(ireg) = '0' report "cannot check twice the same register (" & INTEGER'image(ireg) & ")" severity FAILURE;
				expected_register_write.gp_registers(ireg) <= '1';
				expected_register_values.gp_registers(ireg) <= expected_data;
			
			elsif  parts(0)(parts(0)'range) = "WRITE_REG" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_reg := std_logic_vector(itmp(5 downto 0));
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data := std_logic_vector(itmp);
				write_register(expected_reg, expected_data, register_port_in_a, cop0_reg_port_in_a);
			elsif  parts(0)(parts(0)'range) = "WRITE_PC" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				current_address <= std_logic_vector(itmp);
			elsif parts(0)(parts(0)'range) = "CHECK_RAM" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				ram_address := std_logic_vector(itmp);
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data := std_logic_vector(itmp);
				AXI4_test_read(axi4_mem_out, axi4_mem_in, ram_address, AXI4_BURST_INCR, AXI4_BURST_SIZE_32, 1, clock_period*20, ram_result, ram_resp);
				assert ram_resp = AXI_RESP_OKAY report "CHECK_RAM failed for instruction " & l2(l2'range) & ", expected " & AXI_resp_to_string(AXI_RESP_OKAY) & ", got " & AXI_resp_to_string(ram_resp) severity FAILURE;
				assert expected_data = ram_result report "CHECK_RAM failed for instruction " & l2(l2'range) & ", expected " & hex(unsigned(expected_data), 32) & ", got " & hex(unsigned(ram_result), 32) severity FAILURE;
			elsif parts(0)(parts(0)'range) = "CHECK_BRANCH" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_branch_data.fetch_override_address <= std_logic_vector(itmp);
				itmp := string_to_integer(parts(2)(parts(2)'range));
				if itmp = 0 then
					expected_branch_data.fetch_skip_jump <= '0';
					expected_branch_data.fetch_override_address_valid <= '1';
				else
					expected_branch_data.fetch_skip_jump <= '1';
					expected_branch_data.fetch_override_address_valid <= '0';
				end if;
				itmp := string_to_integer(parts(3)(parts(3)'range));
				if itmp = 0 then
					expected_branch_data.fetch_execute_delay_slot <= '0';
				else
					expected_branch_data.fetch_execute_delay_slot <= '1';
				end if;
				expected_branch_data.fetch_wait_jump <= '1';
			elsif parts(0)(parts(0)'range) = "BEGIN" then
				wait for clock_period; -- make sure all writes are finished
				registers_check_on <= '1';
				branch_checker_on <= '1';
			elsif parts(0)(parts(0)'range) = "END" then
				wait for 40*clock_period;
				validate_written_registers(expected_register_write, registers_check_reg);
				if branch_checker_on = '1' then
					validate_branch(expected_branch_data, branch_checker_data);
				end if;
				registers_check_on <= '0';
				branch_checker_on <= '0';
				expected_register_write <= (gp_registers => (others => '0'), others => '0');
				expected_branch_data <= (fetch_override_address => (others => '0'), others => '0');
			
				wait for clock_period;
			
			elsif parts(0)(parts(0)'range) = "WAIT" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				wait for TO_INTEGER(itmp)*clock_period;
			else
				report "core_test invalid command " & parts(0)(parts(0)'range) & " on line " & INTEGER'image(iline) severity FAILURE;
			end if;
				
			iline := iline + 1;
		end loop;
		assert FALSE report "ALL TESTS PASSED!!!" severity FAILURE;
	end process;
	
	mips_core_internal_i0 : mips_core_internal port map ( 
		resetn => resetn,
		clock => clock,
		
		enable => processor_enable,
	
		breakpoint => breakpoint,
	
		register_port_in_a => register_port_in_a,
		register_port_out_a => register_port_out_a,
		register_hilo_in => register_hilo_in,
		register_hilo_out => register_hilo_out,
		
		cop0_reg_port_in_a => cop0_reg_port_in_a,
		cop0_reg_port_out_a => cop0_reg_port_out_a,
	
		debug_registers_written => debug_registers_written,
		debug_registers_values => debug_registers_values,
	
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
