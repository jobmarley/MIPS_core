
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
		variable success : out BOOLEAN) is
	begin
		if r(5) = '0' then
			pin.address <= r(4 downto 0);
			pin.write_enable <= '0';
			wait for clock_period;
			if pout.pending = '0' then
				wait until pout.pending = '1' for 50*clock_period;
			end if;
			if pout.pending = '1' then
				wait until pout.pending = '0' for 50*clock_period;
			end if;
		
			-- if pending is still '1' after 10 clocks, its an error
			if pout.pending /= '0' then
				report "check_register_value pending timed out" severity ERROR;
				success := FALSE;
				return;
			end if;
		
			wait for clock_period;
			if pout.data = data then
				success := TRUE;
			else
				success := FALSE;
				report "check_register_value failed for register $" & INTEGER'image(TO_INTEGER(unsigned(r))) & ", expected " & hex(unsigned(data)) & ", got " & hex(unsigned(pout.data));
			end if;
		else
			pc0in.address <= r(4 downto 0);
			pc0in.write_enable <= '0';
			wait for clock_period;
			wait until pc0out.data = data for 50*clock_period;
			if pc0out.data = data then
				success := TRUE;
			else
				success := FALSE;
				report "check_register_value failed for register $" & INTEGER'image(TO_INTEGER(unsigned(r))) & ", expected " & hex(unsigned(data)) & ", got " & hex(unsigned(pc0out.data));
			end if;
		end if;
	end procedure;
	
	procedure check_hilo_value(data : std_logic_vector; signal pin : out hilo_register_port_in_t; signal pout : in hilo_register_port_out_t; variable success : out BOOLEAN) is
	begin
		pin.write_enable <= '0';
		wait for clock_period;
		if pout.pending = '0' then
			wait until pout.pending = '1' for 50*clock_period;
		end if;
		if pout.pending = '1' then
			wait until pout.pending = '0' for 50*clock_period;
		end if;
		
		-- if pending is still '1' after 10 clocks, its an error
		if pout.pending /= '0' then
			report "check_hilo_value pending timed out" severity ERROR;
			success := FALSE;
			return;
		end if;
		
		wait for clock_period;
		if pout.data = data then
			success := TRUE;
		else
			success := FALSE;
			report "check_hilo_value failed, expected " & hex(unsigned(data), 64) & ", got " & hex(unsigned(pout.data), 64);
		end if;
	end procedure;
	
	procedure check_branch(override_address : std_logic_vector; execute_delay_slot : std_logic; skip : std_logic; signal fdi : in fetch_data_in_t; signal fdi_reg : in fetch_data_in_t; signal fdo : out fetch_data_out_t; variable success : out BOOLEAN) is
		variable result_skip : std_logic := fdi_reg.fetch_skip_jump;
		variable result_execute_delay_slot : std_logic := fdi_reg.fetch_execute_delay_slot;
		variable result_override_address : std_logic_vector(31 downto 0) := fdi_reg.fetch_override_address;
		variable result_valid : std_logic := fdi_reg.fetch_override_address_valid;
		variable timeout : NATURAL := 20;
	begin
		success := TRUE;
		
		if fdi_reg.fetch_wait_jump = '1' then
			report "CHECK_BRANCH failed, wait_jump should be 1" severity ERROR;
			success := FALSE;
			return;
		end if;
		
		while result_valid = '0' and result_skip = '0' loop
			result_skip := result_skip or fdi.fetch_skip_jump;
			result_execute_delay_slot := result_execute_delay_slot or fdi.fetch_execute_delay_slot;
			if fdi.fetch_override_address_valid = '1' then
				result_override_address := fdi.fetch_override_address;
				result_valid := '1';
			end if;
			wait for clock_period;
			timeout := timeout - 1;
			if timeout = 0 then
				report "CHECK_BRANCH timed out" severity ERROR;
				success := FALSE;
				return;
			end if;
		end loop;
		
		if result_skip /= skip then
			report "CHECK_BRANCH failed, skip value wrong, expected " & logic_to_char(skip) & ", got " & logic_to_char(result_skip) severity ERROR;
			success := FALSE;
			return;
		end if;
		if result_execute_delay_slot /= execute_delay_slot then
			report "CHECK_BRANCH failed, execute_delay_slot value wrong, expected " & logic_to_char(execute_delay_slot) & ", got " & logic_to_char(result_execute_delay_slot) severity ERROR;
			success := FALSE;
			return;
		end if;
		if result_valid = '0' and result_skip = '0' then
			report "CHECK_BRANCH failed, didn't receive override address" severity ERROR;
			success := FALSE;
			return;
		end if;
		if result_valid /= '0' and result_override_address /= override_address then
			report "CHECK_BRANCH failed, override_address value wrong, expected " & hex(unsigned(override_address), 32) & ", got " & hex(unsigned(result_override_address), 32) severity ERROR;
			success := FALSE;
			return;
		end if;
	
	end procedure;
	
	procedure write_register(r : std_logic_vector; data : std_logic_vector; signal p : out register_port_in_t; signal pc0 : out cop0_register_port_in_t) is
	begin
		p.address <= r(4 downto 0);
		p.write_data <= data;
		p.write_enable <= not r(5);
		p.write_pending <= '0';
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
		p.write_pending <= '0';
		p.write_strobe <= "11";
		wait for clock_period;
		p.write_enable <= '0';
	end procedure;
	
	signal axi4_mem_out : axi4_port_out_t;
	signal axi4_mem_in : axi4_port_in_t;
	
	signal current_address : std_logic_vector(31 downto 0);
	
	signal fetch_data_in_reg : fetch_data_in_t;
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
		variable expected_branch_address : std_logic_vector(31 downto 0);
		variable expected_skip : std_logic;
		variable expected_delay_slot : std_logic;
	begin	
		AXI4_idle(axi4_mem_out);
		
		fetch_data_out.fetch_instruction_data <= (others => '0');
		fetch_data_out.fetch_error <= '0';
		fetch_data_out.fetch_instruction_data_valid <= '0';
		register_port_in_a.address <= (others => '0');
		register_port_in_a.write_data <= (others => '0');
		register_port_in_a.write_enable <= '0';
		register_port_in_a.write_pending <= '0';
		register_port_in_a.write_strobe <= x"F";
		
		cop0_reg_port_in_a.address <= (others => '0');
		cop0_reg_port_in_a.write_data <= (others => '0');
		cop0_reg_port_in_a.write_enable <= '0';
		cop0_reg_port_in_a.write_strobe <= x"F";
		
		current_address <= (others => '0');
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
				READLINE(f2,l2);
			elsif parts(0)(parts(0)'range) = "SKIP_ASM_LINE" then
				READLINE(f2,l2);
			elsif parts(0)(parts(0)'range) = "CHECK_HILO" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_data_hilo(63 downto 32) := std_logic_vector(itmp);
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data_hilo(31 downto 0) := std_logic_vector(itmp);
				check_hilo_value(expected_data_hilo, register_hilo_in, register_hilo_out, success);
				assert success report "CHECK_HILO failed for instruction " & l2(l2'range) severity FAILURE;
			elsif parts(0)(parts(0)'range) = "WRITE_HILO" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_data_hilo(63 downto 32) := std_logic_vector(itmp);
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data_hilo(31 downto 0) := std_logic_vector(itmp);
				write_hilo(expected_data_hilo, register_hilo_in);
			elsif parts(0)(parts(0)'range) = "CHECK_REG" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_reg := std_logic_vector(itmp(5 downto 0));
				itmp := string_to_integer(parts(2)(parts(2)'range));
				expected_data := std_logic_vector(itmp);
				check_register_value(expected_reg, expected_data, register_port_in_a, register_port_out_a, cop0_reg_port_in_a, cop0_reg_port_out_a, success);
				assert success report "CHECK_REG failed for instruction " & l2(l2'range) severity FAILURE;
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
				-- wait for 20 clocks to make sure whatever previous operation is completed
				wait for 20*clock_period;
				AXI4_test_read(axi4_mem_out, axi4_mem_in, ram_address, AXI4_BURST_INCR, AXI4_BURST_SIZE_32, 1, clock_period*20, ram_result, ram_resp);
				assert ram_resp = AXI_RESP_OKAY report "CHECK_RAM failed for instruction " & l2(l2'range) & ", expected " & AXI_resp_to_string(AXI_RESP_OKAY) & ", got " & AXI_resp_to_string(ram_resp) severity FAILURE;
				assert expected_data = ram_result report "CHECK_RAM failed for instruction " & l2(l2'range) & ", expected " & hex(unsigned(expected_data), 32) & ", got " & hex(unsigned(ram_result), 32) severity FAILURE;
			elsif parts(0)(parts(0)'range) = "CHECK_BRANCH" then
				itmp := string_to_integer(parts(1)(parts(1)'range));
				expected_branch_address := std_logic_vector(itmp);
				itmp := string_to_integer(parts(2)(parts(2)'range));
				if itmp = 0 then
					expected_skip := '0';
				else
					expected_skip := '1';
				end if;
				itmp := string_to_integer(parts(3)(parts(3)'range));
				if itmp = 0 then
					expected_delay_slot := '0';
				else
					expected_delay_slot := '1';
				end if;
				check_branch(expected_branch_address, expected_delay_slot, expected_skip, fetch_data_in, fetch_data_in_reg, fetch_data_out, success);
				assert success report "CHECK_BRANCH failed for instruction " & l2(l2'range) severity FAILURE;
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
