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
begin
	cmp_result <= alu_out_ports.cmp_out_tdata(0) xor cmp_tuser.invert;
	
	add_tuser <= slv_to_add_out_tuser(alu_out_ports.add_out_tuser);
	cmp_tuser <= slv_to_cmp_tuser(alu_out_ports.cmp_out_tuser);
	
	register_port_in_a.address <= '0' & alu_out_ports.add_out_tuser(4 downto 0) when alu_out_ports.add_out_tvalid = '1' else '0' & alu_out_ports.sub_out_tuser(4 downto 0);
	register_port_in_a.write_enable <= (alu_out_ports.add_out_tvalid and not add_tuser.load and not add_tuser.store and not add_tuser.branch) or alu_out_ports.sub_out_tvalid;
	register_port_in_a.write_data <= alu_out_ports.add_out_tdata(31 downto 0) when alu_out_ports.add_out_tvalid = '1' else alu_out_ports.sub_out_tdata(31 downto 0);
	register_port_in_a.write_strobe <= x"F";
	register_port_in_a.write_pending <= '0';
	
	fetch_override_address <= alu_out_ports.add_out_tdata(31 downto 0);
	fetch_override_address_valid <= ((cmp_result and alu_out_ports.cmp_out_tvalid and cmp_tuser.branch and add_tuser.branch) or add_tuser.jump) and alu_out_ports.add_out_tvalid;
	fetch_skip_jump <= not cmp_result and alu_out_ports.cmp_out_tvalid and cmp_tuser.branch;
	fetch_execute_delay_slot <= (not cmp_tuser.likely or cmp_result) and alu_out_ports.cmp_out_tvalid and cmp_tuser.branch;
	
	process(clock)
	begin
		if rising_edge(clock) then
		end if;
	end process;
	
	process (
		resetn,
		
		alu_out_ports,
		
		add_tuser,
		cmp_tuser,
		cmp_result
		
	)
		variable andorxornor : std_logic_vector(6 downto 0);
	begin
		
		register_port_in_b.address <= (others => '0');
		register_port_in_b.write_data <= (others => '0');
		register_port_in_b.write_enable <= '0';
		register_port_in_b.write_pending <= '0';
		register_port_in_b.write_strobe <= x"0";
		
		andorxornor := alu_out_ports.and_out_tvalid &
			alu_out_ports.or_out_tvalid &
			alu_out_ports.xor_out_tvalid &
			alu_out_ports.nor_out_tvalid &
			alu_out_ports.shl_out_tvalid & 
			alu_out_ports.shr_out_tvalid &
			alu_out_ports.cmp_out_tvalid;
		
		if resetn = '0' then
		else
			
			case (andorxornor) is
				when "1000000" =>
					register_port_in_b.address <= '0' & alu_out_ports.and_out_tuser(4 downto 0);
					register_port_in_b.write_data <= alu_out_ports.and_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0100000" =>
					register_port_in_b.address <= '0' & alu_out_ports.or_out_tuser(4 downto 0);
					register_port_in_b.write_data <= alu_out_ports.or_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0010000" =>
					register_port_in_b.address <= '0' & alu_out_ports.xor_out_tuser(4 downto 0);
					register_port_in_b.write_data <= alu_out_ports.xor_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0001000" =>
					register_port_in_b.address <= '0' & alu_out_ports.nor_out_tuser(4 downto 0);
					register_port_in_b.write_data <= alu_out_ports.nor_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0000100" =>
					register_port_in_b.address <= '0' & alu_out_ports.shl_out_tuser(4 downto 0);
					register_port_in_b.write_data <= alu_out_ports.shl_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0000010" =>
					register_port_in_b.address <= '0' & alu_out_ports.shr_out_tuser(4 downto 0);
					register_port_in_b.write_data <= alu_out_ports.shr_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0000001" =>
					register_port_in_b.address <= '0' & alu_out_ports.cmp_out_tuser(4 downto 0);
					register_port_in_b.write_data <= x"0000000" & "000" & cmp_result;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when others =>
			end case;
		end if;
	end process;
end mips_writeback_behavioral;
