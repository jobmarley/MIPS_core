library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mips_utils.all;

entity mips_writeback is
	port (
	resetn : in std_logic;
	clock : in std_logic;
	
	-- alu
	alu_out_ports : in alu_out_ports_t;
	
	-- registers
	register_port_in_a : out register_port_in_t;
	register_port_out_a : in register_port_out_t;
	register_port_in_b : out register_port_in_t;
	register_port_out_b : in register_port_out_t;
	register_port_in_c : out register_port_in_t;
	register_port_out_c : in register_port_out_t;
	
	register_hilo_in : out hilo_register_port_in_t;
	
	-- fetch
	fetch_override_address : out std_logic_vector(31 downto 0);
	fetch_override_address_valid : out std_logic;
	fetch_skip_jump : out std_logic;
	fetch_execute_delay_slot : out std_logic
	);
end mips_writeback;

architecture mips_writeback_behavioral of mips_writeback is
	signal add_tuser : alu_add_out_tuser_t;
	signal cmp_tuser : alu_cmp_tuser_t;
	signal cmp_result : std_logic;
	signal mul_tuser : alu_mul_tuser_t;
	
	signal branch_pending : std_logic;
	signal branch_pending_next : std_logic;
	
	signal register_port_in_a_reg : register_port_in_t;
	signal register_port_in_a_reg_next : register_port_in_t;
	signal register_port_in_b_reg : register_port_in_t;
	signal register_port_in_b_reg_next : register_port_in_t;
	signal register_port_in_c_reg : register_port_in_t;
	signal register_port_in_c_reg_next : register_port_in_t;
	signal register_hilo_in_reg : hilo_register_port_in_t;
	signal register_hilo_in_reg_next : hilo_register_port_in_t;
	
	signal fetch_override_address_reg : std_logic_vector(31 downto 0);
	signal fetch_override_address_reg_next : std_logic_vector(31 downto 0);
	signal fetch_override_address_valid_reg : std_logic;
	signal fetch_override_address_valid_reg_next : std_logic;
	signal fetch_skip_jump_reg : std_logic;
	signal fetch_skip_jump_reg_next : std_logic;
	signal fetch_execute_delay_slot_reg : std_logic;
	signal fetch_execute_delay_slot_reg_next : std_logic;
begin
	register_port_in_a <= register_port_in_a_reg;
	register_port_in_b <= register_port_in_b_reg;
	register_port_in_c <= register_port_in_c_reg;
	register_hilo_in <= register_hilo_in_reg;
	
	fetch_override_address <= fetch_override_address_reg_next;
	fetch_override_address_valid <= fetch_override_address_valid_reg_next;
	fetch_skip_jump <= fetch_skip_jump_reg_next;
	fetch_execute_delay_slot <= fetch_execute_delay_slot_reg_next;
	
	cmp_result <= alu_out_ports.cmp_out_tdata(0);
	
	add_tuser <= slv_to_add_out_tuser(alu_out_ports.add_out_tuser);
	cmp_tuser <= slv_to_cmp_tuser(alu_out_ports.cmp_out_tuser);
	mul_tuser <= slv_to_mul_tuser(alu_out_ports.mul_out_tuser);
	
	fetch_override_address_reg_next <= alu_out_ports.add_out_tdata(31 downto 0);
	fetch_override_address_valid_reg_next <= (branch_pending or add_tuser.jump) and alu_out_ports.add_out_tvalid;
	fetch_skip_jump_reg_next <= not cmp_result and alu_out_ports.cmp_out_tvalid and cmp_tuser.branch;
	fetch_execute_delay_slot_reg_next <= (not cmp_tuser.likely or cmp_result) and alu_out_ports.cmp_out_tvalid and cmp_tuser.branch;
	branch_pending_next <= (not (add_tuser.branch and alu_out_ports.add_out_tvalid) and branch_pending) or (cmp_result and alu_out_ports.cmp_out_tvalid and cmp_tuser.branch);
	
	
	process(clock)
	begin
		if rising_edge(clock) then
			branch_pending <= branch_pending_next;
			register_port_in_a_reg <= register_port_in_a_reg_next;
			register_port_in_b_reg <= register_port_in_b_reg_next;
			register_port_in_c_reg <= register_port_in_c_reg_next;
			register_hilo_in_reg <= register_hilo_in_reg_next;
			
			fetch_override_address_reg <= fetch_override_address_reg_next;
			fetch_override_address_valid_reg <= fetch_override_address_valid_reg_next;
			fetch_skip_jump_reg <= fetch_skip_jump_reg_next;
			fetch_execute_delay_slot_reg <= fetch_execute_delay_slot_reg_next;
		end if;
	end process;
	
	-- add/sub/mul
	process (
		resetn,
		alu_out_ports,
		mul_tuser,
		add_tuser
	)
	begin
		register_port_in_a_reg_next.address <= (others => '0');
		register_port_in_a_reg_next.write_enable <= '0';
		register_port_in_a_reg_next.write_data <= (others => '0');
		register_port_in_a_reg_next.write_strobe <= x"F";
		register_port_in_a_reg_next.write_pending <= '0';
	
		register_port_in_c_reg_next.address <= (others => '0');
		register_port_in_c_reg_next.write_enable <= '0';
		register_port_in_c_reg_next.write_data <= (others => '0');
		register_port_in_c_reg_next.write_strobe <= x"F";
		register_port_in_c_reg_next.write_pending <= '0';
		
		if resetn = '0' then
		else
			if alu_out_ports.add_out_tvalid = '1' then
				register_port_in_a_reg_next.address <= alu_out_ports.add_out_tuser(4 downto 0);
				register_port_in_a_reg_next.write_data <= alu_out_ports.add_out_tdata(31 downto 0);
			else
				register_port_in_a_reg_next.address <= alu_out_ports.sub_out_tuser(4 downto 0);
				register_port_in_a_reg_next.write_data <= alu_out_ports.sub_out_tdata(31 downto 0);
			end if;
			register_port_in_a_reg_next.write_enable <= (alu_out_ports.add_out_tvalid and add_tuser.mov) or alu_out_ports.sub_out_tvalid;
			register_port_in_a_reg_next.write_strobe <= x"F";
			register_port_in_a_reg_next.write_pending <= '0';
	
			register_port_in_c_reg_next.address <= alu_out_ports.mul_out_tuser(4 downto 0);
			register_port_in_c_reg_next.write_enable <= not mul_tuser.use_hilo and alu_out_ports.mul_out_tvalid;
			register_port_in_c_reg_next.write_data <= alu_out_ports.mul_out_tdata(31 downto 0);
			register_port_in_c_reg_next.write_strobe <= x"F";
			register_port_in_c_reg_next.write_pending <= '0';
		end if;
	end process;
	
	-- div/mult
	process (
		resetn,
		alu_out_ports,
		mul_tuser
	)
	begin
		-- no need to synchronize that, cause readreg will stall if hi/lo is pending
		register_hilo_in_reg_next.write_data <= (others => '0');
		register_hilo_in_reg_next.write_enable <= '0';
		register_hilo_in_reg_next.write_pending <= '0';
		register_hilo_in_reg_next.write_strobe <= "11";
		
		if resetn = '0' then
		else
			-- no need to synchronize that, cause readreg will stall if hi/lo is pending
			if alu_out_ports.div_out_tvalid = '1' then
				register_hilo_in_reg_next.write_data <= alu_out_ports.div_out_tdata(31 downto 0) & alu_out_ports.div_out_tdata(63 downto 32);
			elsif alu_out_ports.divu_out_tvalid = '1' then
				register_hilo_in_reg_next.write_data <= alu_out_ports.divu_out_tdata(31 downto 0) & alu_out_ports.divu_out_tdata(63 downto 32);
			elsif alu_out_ports.mul_out_tvalid = '1' then
				register_hilo_in_reg_next.write_data <= alu_out_ports.mul_out_tdata;
			else
				register_hilo_in_reg_next.write_data <= alu_out_ports.multu_out_tdata;
			end if;
			
			register_hilo_in_reg_next.write_enable <= (alu_out_ports.mul_out_tvalid and mul_tuser.use_hilo)
				or alu_out_ports.multu_out_tvalid
				or alu_out_ports.div_out_tvalid
				or alu_out_ports.divu_out_tvalid;
			register_hilo_in_reg_next.write_pending <= '0';
			register_hilo_in_reg_next.write_strobe <= "11";
		end if;
	end process;
	
	-- or xor nor shl shr cmp clo clz
	process (
		resetn,
		alu_out_ports,
		add_tuser,
		cmp_tuser,
		cmp_result
	)
		variable andorxornor : std_logic_vector(8 downto 0);
	begin
		
		register_port_in_b_reg_next.address <= (others => '0');
		register_port_in_b_reg_next.write_data <= (others => '0');
		register_port_in_b_reg_next.write_enable <= '0';
		register_port_in_b_reg_next.write_pending <= '0';
		register_port_in_b_reg_next.write_strobe <= x"0";
		
		andorxornor := alu_out_ports.and_out_tvalid &
			alu_out_ports.or_out_tvalid &
			alu_out_ports.xor_out_tvalid &
			alu_out_ports.nor_out_tvalid &
			alu_out_ports.shl_out_tvalid & 
			alu_out_ports.shr_out_tvalid &
			alu_out_ports.cmp_out_tvalid &
			alu_out_ports.clo_out_tvalid &
			alu_out_ports.clz_out_tvalid;
		
		if resetn = '0' then
		else
			
			case (andorxornor) is
				when "100000000" =>
					register_port_in_b_reg_next.address <= alu_out_ports.and_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.and_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when "010000000" =>
					register_port_in_b_reg_next.address <= alu_out_ports.or_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.or_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when "001000000" =>
					register_port_in_b_reg_next.address <= alu_out_ports.xor_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.xor_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when "000100000" =>
					register_port_in_b_reg_next.address <= alu_out_ports.nor_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.nor_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when "000010000" =>
					register_port_in_b_reg_next.address <= alu_out_ports.shl_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.shl_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when "000001000" =>
					register_port_in_b_reg_next.address <= alu_out_ports.shr_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.shr_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when "000000100" =>
					register_port_in_b_reg_next.address <= alu_out_ports.cmp_out_tuser(4 downto 0);
					if cmp_tuser.mov = '0' then
						register_port_in_b_reg_next.write_data <= x"0000000" & "000" & cmp_result;
						register_port_in_b_reg_next.write_strobe <= x"F";
					else
						register_port_in_b_reg_next.write_data <= cmp_tuser.alternate_value;
						if cmp_result = '0' then
							register_port_in_b_reg_next.write_strobe <= x"0";
						else
							register_port_in_b_reg_next.write_strobe <= x"F";
						end if;
					end if;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
				when "000000010" =>
					register_port_in_b_reg_next.address <= alu_out_ports.clo_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.clo_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when "000000001" =>
					register_port_in_b_reg_next.address <= alu_out_ports.clz_out_tuser(4 downto 0);
					register_port_in_b_reg_next.write_data <= alu_out_ports.clz_out_tdata;
					register_port_in_b_reg_next.write_enable <= '1';
					register_port_in_b_reg_next.write_pending <= '0';
					register_port_in_b_reg_next.write_strobe <= x"F";
				when others =>
			end case;
		end if;
	end process;
end mips_writeback_behavioral;
