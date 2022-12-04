library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mips_utils.all;

entity mips_readreg is
	port (
	enable : in std_logic;
	resetn : in std_logic;
	clock : in std_logic;
	
	-- decode
	register_a : in std_logic_vector(5 downto 0);
	register_b : in std_logic_vector(5 downto 0);
	register_c : in std_logic_vector(5 downto 0);
	operation : in decode_operation_t;
	operation_valid : in std_logic;
	load : in std_logic;
	store : in std_logic;
	memop_type : in std_logic_vector(2 downto 0);
	
	-- registers
	register_port_in_a : out register_port_in_t;
	register_port_out_a : in register_port_out_t;
	register_port_in_b : out register_port_in_t;
	register_port_out_b : in register_port_out_t;
	register_port_in_c : out register_port_in_t;
	register_port_out_c : in register_port_out_t;
	register_port_in_d : out register_port_in_t;
	register_port_out_d : in register_port_out_t;
	
	-- alu
	alu_in_ports : out alu_in_ports_t;
	
	override_address : out std_logic_vector(31 downto 0);
	override_address_valid : out std_logic;
	execute_delay_slot : out std_logic;
	skip_jump : out std_logic;
	
	immediate_a : in std_logic_vector(31 downto 0);
	immediate_b : in std_logic_vector(31 downto 0);
	link_address : in std_logic_vector(31 downto 0);
	
	stall : out std_logic
	);
end mips_readreg;

architecture mips_readreg_behavioral of mips_readreg is
	signal register_a_reg : std_logic_vector(5 downto 0);
	signal register_a_reg_next : std_logic_vector(5 downto 0);
	signal register_b_reg : std_logic_vector(5 downto 0);
	signal register_b_reg_next : std_logic_vector(5 downto 0);
	signal register_c_reg : std_logic_vector(5 downto 0);
	signal register_c_reg_next : std_logic_vector(5 downto 0);
	signal operation_reg : decode_operation_t;
	signal operation_reg_next : decode_operation_t;
	signal operation_valid_reg : std_logic;
	signal operation_valid_reg_next : std_logic;
	signal load_reg : std_logic;
	signal load_reg_next : std_logic;
	signal store_reg : std_logic;
	signal store_reg_next : std_logic;
	signal memop_type_reg : std_logic_vector(2 downto 0);
	signal memop_type_reg_next : std_logic_vector(2 downto 0);
	
	signal register_a_pending_bypass : std_logic;
	signal register_b_pending_bypass : std_logic;
	signal register_c_pending_bypass : std_logic;
	
	signal register_a_written : std_logic;
	signal register_a_written_next : std_logic;
	signal register_b_written : std_logic;
	signal register_b_written_next : std_logic;
	signal register_c_written : std_logic;
	signal register_c_written_next : std_logic;
	
	signal target_register_address : std_logic_vector(5 downto 0);
	signal target_register_address_next : std_logic_vector(5 downto 0);
	signal target_register_pending : std_logic;
	signal target_register_pending_next : std_logic;
	
	signal immediate_a_reg : std_logic_vector(31 downto 0);
	signal immediate_a_reg_next : std_logic_vector(31 downto 0);
	signal immediate_b_reg : std_logic_vector(31 downto 0);
	signal immediate_b_reg_next : std_logic_vector(31 downto 0);
	signal link_address_reg : std_logic_vector(31 downto 0);
	signal link_address_reg_next : std_logic_vector(31 downto 0);
	
	signal alu_add_tuser : alu_add_out_tuser_t;
	signal alu_cmp_tuser : alu_cmp_tuser_t;
	
	function reorder(b : std_logic_vector; a : std_logic_vector; r : std_logic) return std_logic_vector is
		ALIAS d1 : std_logic_vector(a'length-1 DOWNTO 0) is a;
		ALIAS d2 : std_logic_vector(b'length-1 DOWNTO 0) is b;
	begin
		if r = '1' then
			return d1 & d2;
		else
			return d2 & d1;
		end if;
	end function;
	
	function select_operand(a : std_logic_vector; b : std_logic_vector; s : std_logic) return std_logic_vector is
	begin
		if s = '1' then
			return b;
		else
			return a;
		end if;
	end function;
	
	signal stall_internal : std_logic;
	signal fast_cmp_result : std_logic;
begin
	fast_cmp_result <= (register_port_out_a.data(31) xor operation_reg.op_cmp_invert);
	execute_delay_slot <= operation_valid_reg and operation_reg.op_cmp_gez and fast_cmp_result and operation_reg.op_branch_likely;
	skip_jump <= operation_valid_reg and operation_reg.op_cmp_gez and not fast_cmp_result;
	
	stall <= stall_internal;
	
	register_a_pending_bypass <= register_a_written or register_port_out_a.pending;
	register_b_pending_bypass <= register_b_written or register_port_out_b.pending;
	register_c_pending_bypass <= register_c_written or register_port_out_c.pending;
	
	-- /!\ when branch, add operands are always immediates, because registers are used by cmp
	alu_in_ports.add_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b or operation_reg.op_branch) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a or operation_reg.op_branch);
	
	alu_in_ports.add_in_tvalid <= operation_reg.op_add and operation_valid_reg and not stall_internal when operation_reg.op_cmp_gez = '0'
		else operation_reg.op_add and operation_valid_reg and not stall_internal and fast_cmp_result;
	
	alu_in_ports.add_in_tuser <= add_out_tuser_to_slv(alu_add_tuser);
	alu_add_tuser.exclusive <= '0';
	alu_add_tuser.signed <= '0';
	alu_add_tuser.memop_type <= memop_type_reg;
	alu_add_tuser.store <= store_reg;
	alu_add_tuser.store_data <= register_port_out_c.data;
	alu_add_tuser.load <= load_reg;
	alu_add_tuser.rt <= register_c_reg;
	 -- when op_cmp_gez is used, we transform the branch in jump when cmp is successfull
	alu_add_tuser.branch <= operation_reg.op_branch when operation_reg.op_cmp_gez = '0' else not fast_cmp_result;
	alu_add_tuser.jump <= operation_reg.op_jump when operation_reg.op_cmp_gez = '0' else fast_cmp_result;
	
	alu_in_ports.sub_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.sub_in_tvalid <= operation_reg.op_sub and not stall_internal;
	alu_in_ports.sub_in_tuser <= register_c_reg;
	
	alu_in_ports.and_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.and_in_tvalid <= operation_reg.op_and and not stall_internal;
	alu_in_ports.and_in_tuser <= register_c_reg;
	
	alu_in_ports.or_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.or_in_tvalid <= operation_reg.op_or and not stall_internal;
	alu_in_ports.or_in_tuser <= register_c_reg;
	
	alu_in_ports.xor_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.xor_in_tvalid <= operation_reg.op_xor and not stall_internal;
	alu_in_ports.xor_in_tuser <= register_c_reg;
	
	alu_in_ports.nor_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.nor_in_tvalid <= operation_reg.op_nor and not stall_internal;
	alu_in_ports.nor_in_tuser <= register_c_reg;
	
	alu_in_ports.shl_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b)(4 downto 0) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.shl_in_tvalid <= operation_reg.op_sll and not stall_internal;
	alu_in_ports.shl_in_tuser <= register_c_reg;
	
	alu_in_ports.shr_in_tdata <= select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b)(4 downto 0) &
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.shr_in_tvalid <= (operation_reg.op_srl or operation_reg.op_sra) and not stall_internal;
	alu_in_ports.shr_in_tuser <= operation_reg.op_sra & register_c_reg;
	
	-- when branch, cmp always use registers
	alu_in_ports.cmp_in_tdata <= reorder(select_operand(register_port_out_b.data, immediate_b_reg, operation_reg.op_immediate_b and not operation_reg.op_branch),
		select_operand(register_port_out_a.data, immediate_a_reg, operation_reg.op_immediate_a and not operation_reg.op_branch), operation_reg.op_reorder);
	alu_in_ports.cmp_in_tvalid <= operation_reg.op_cmp and not stall_internal;
	alu_in_ports.cmp_in_tuser <= cmp_tuser_to_slv(alu_cmp_tuser);
	alu_cmp_tuser.eq <= operation_reg.op_cmp_eq;
	alu_cmp_tuser.ge <= operation_reg.op_cmp_ge;
	alu_cmp_tuser.le <= operation_reg.op_cmp_le;
	alu_cmp_tuser.rd <= register_c_reg;
	alu_cmp_tuser.invert <= operation_reg.op_cmp_invert;
	alu_cmp_tuser.unsigned <= operation_reg.op_unsigned;
	alu_cmp_tuser.branch <= operation_reg.op_branch;
	alu_cmp_tuser.likely <= operation_reg.op_branch_likely;
	
	override_address_valid <= '0';
	override_address <= register_port_out_a.data;
		
	--stall <= stall_reg;
	
	process(clock)
	begin
		if rising_edge(clock) then
			register_a_reg <= register_a_reg_next;
			register_b_reg <= register_b_reg_next;
			register_c_reg <= register_c_reg_next;
			immediate_a_reg <= immediate_a_reg_next;
			immediate_b_reg <= immediate_b_reg_next;
			operation_reg <= operation_reg_next;
			operation_valid_reg <= operation_valid_reg_next;
			load_reg <= load_reg_next;
			store_reg <= store_reg_next;
			memop_type_reg <= memop_type_reg_next;
			target_register_address <= target_register_address_next;
			target_register_pending <= target_register_pending_next;
			link_address_reg <= link_address_reg_next;
			
			register_a_written <= register_a_written_next;
			register_b_written <= register_b_written_next;
			register_c_written <= register_c_written_next;
		end if;
	end process;
	
	process (
		enable,
		resetn,
		register_a,
		register_b,
		register_c,
		register_a_reg,
		register_b_reg,
		register_c_reg,
		
		operation,
		operation_reg,
		operation_valid,
		operation_valid_reg,
		load,
		load_reg,
		store,
		store_reg,
		memop_type,
		memop_type_reg,
		immediate_a,
		immediate_a_reg,
		immediate_b,
		immediate_b_reg,
	
		register_a_pending_bypass,
		register_b_pending_bypass,
		register_c_pending_bypass,
		
		register_port_out_a,
		
		target_register_address,
		target_register_pending,
		
		link_address,
		link_address_reg,
		fast_cmp_result
	)
        variable instruction_data_r : instruction_r_t;
        variable instruction_data_i : instruction_i_t;
        variable instruction_data_j : instruction_j_t;
	begin
		register_port_in_a.address <= register_a;
		register_port_in_a.write_enable <= '0';
		register_port_in_a.write_data <= (others => '0');
		register_port_in_a.write_strobe <= (others => '0');
		register_port_in_a.write_pending <= '0';
		register_port_in_b.address <= register_b;
		register_port_in_b.write_enable <= '0';
		register_port_in_b.write_data <= (others => '0');
		register_port_in_b.write_strobe <= (others => '0');
		register_port_in_b.write_pending <= '0';
		register_port_in_c.address <= register_c;
		register_port_in_c.write_enable <= '0';
		register_port_in_c.write_data <= (others => '0');
		register_port_in_c.write_strobe <= (others => '0');
		register_port_in_c.write_pending <= '0';
		register_port_in_d.address <= register_c_reg;
		register_port_in_d.write_enable <= '0';
		register_port_in_d.write_data <= (others => '0');
		register_port_in_d.write_strobe <= (others => '0');
		register_port_in_d.write_pending <= '1';
		
		register_a_reg_next <= register_a_reg;
		register_b_reg_next <= register_b_reg;
		register_c_reg_next <= register_c_reg;
		operation_reg_next <= operation_reg;
		operation_valid_reg_next <= operation_valid_reg;
		load_reg_next <= load_reg;
		store_reg_next <= store_reg;
		memop_type_reg_next <= memop_type_reg;
		immediate_a_reg_next <= immediate_a_reg;
		immediate_b_reg_next <= immediate_b_reg;
				
		target_register_address_next <= target_register_address;
		target_register_pending_next <= target_register_pending;
		link_address_reg_next <= link_address_reg;
		
		register_a_written_next <= '0';
		register_b_written_next <= '0';
		register_c_written_next <= '0';
		
		stall_internal <= '0';
				
		if resetn = '0' then
			register_a_reg_next <= (others => '0');
			register_b_reg_next <= (others => '0');
			register_c_reg_next <= (others => '0');
			immediate_a_reg_next <= (others => '0');
			immediate_b_reg_next <= (others => '0');
			operation_reg_next <= (others => '0');
			operation_valid_reg_next <= '0';
			load_reg_next <= '0';
			store_reg_next <= '0';
			memop_type_reg_next <= (others => '0');
			link_address_reg_next <= (others => '0');
		elsif enable = '1' then
			target_register_address_next <= (others => '0');
			target_register_pending_next <= '0';
			
			-- if registers are unused, they must be set to $0 (never pending)
			if operation_valid_reg = '1' and 
				(register_a_pending_bypass = '1' or
				register_b_pending_bypass = '1' or
				register_c_pending_bypass = '1') then
				
				stall_internal <= '1';
				register_port_in_a.address <= register_a_reg;
				register_port_in_b.address <= register_b_reg;
				register_port_in_c.address <= register_c_reg;
			else
				stall_internal <= '0';
				register_a_reg_next <= register_a;
				register_b_reg_next <= register_b;
				register_c_reg_next <= register_c;
				operation_reg_next <= operation;
				operation_valid_reg_next <= operation_valid;
				load_reg_next <= load;
				store_reg_next <= store;
				memop_type_reg_next <= memop_type;
				immediate_a_reg_next <= immediate_a;
				immediate_b_reg_next <= immediate_b;
				link_address_reg_next <= link_address;
				
				-- write register pending for target register
				register_port_in_d.address <= register_c_reg;
				register_port_in_d.write_enable <= operation_valid_reg;
				
				-- OPERATION_INDEX_MOV is used to simply write a register
				if operation_reg.op_mov = '1' then
					if operation_reg.op_link = '1' and fast_cmp_result = '1' then
						register_port_in_d.write_data <= link_address_reg;
					elsif operation_reg.op_immediate_a = '1' then
						register_port_in_d.write_data <= immediate_a_reg;
					else
						register_port_in_d.write_data <= register_port_out_a.data;
					end if;
					register_port_in_d.write_strobe <= x"F";
					register_port_in_d.write_pending <= '0';
				else
					register_port_in_d.write_pending <= not store_reg;
				end if;
				target_register_address_next <= register_c_reg;
				
				-- register pending bypass, only when reg != $0
				if register_c_reg /= "000000" then
					if register_a = register_c_reg then
						register_a_written_next <= operation_valid_reg;
					end if;
					if register_b = register_c_reg then
						register_b_written_next <= operation_valid_reg;
					end if;
					if register_c = register_c_reg then
						register_c_written_next <= operation_valid_reg;
					end if;
					target_register_pending_next <= operation_valid_reg;
				end if;
			end if;
			
			
		end if;
	end process;
end mips_readreg_behavioral;
