library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
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
	mov_strobe : in std_logic_vector(3 downto 0);
	
	-- registers
	register_port_in_a : out register_port_in_t;
	register_port_out_a : in register_port_out_t;
	register_port_in_b : out register_port_in_t;
	register_port_out_b : in register_port_out_t;
	register_port_in_c : out register_port_in_t;
	register_port_out_c : in register_port_out_t;
	register_port_in_d : out register_port_in_t;
	register_port_out_d : in register_port_out_t;
	
	register_hilo_in : out hilo_register_port_in_t;
	register_hilo_out : in hilo_register_port_out_t;
	
	cop0_reg_port_in_a : out cop0_register_port_in_t;
	cop0_reg_port_out_a : in cop0_register_port_out_t;
	cop0_reg_port_in_b : out cop0_register_port_in_t;
	cop0_reg_port_out_b : in cop0_register_port_out_t;
	
	registers_pending_reset_in_a : in registers_pending_t;
	registers_pending_reset_in_b : in registers_pending_t;
	
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
	
	signal register_a_pending : std_logic;
	signal register_b_pending : std_logic;
	signal register_c_pending : std_logic;
			
	signal immediate_a_reg : std_logic_vector(31 downto 0);
	signal immediate_a_reg_next : std_logic_vector(31 downto 0);
	signal immediate_b_reg : std_logic_vector(31 downto 0);
	signal immediate_b_reg_next : std_logic_vector(31 downto 0);
	signal link_address_reg : std_logic_vector(31 downto 0);
	signal link_address_reg_next : std_logic_vector(31 downto 0);
	signal mov_strobe_reg : std_logic_vector(3 downto 0);
	signal mov_strobe_reg_next : std_logic_vector(3 downto 0);
	
	signal alu_add_tuser : alu_add_out_tuser_t;
	signal alu_cmp_tuser : alu_cmp_tuser_t;
	signal alu_mul_tuser : alu_mul_tuser_t;
		
	function select_operand(a : std_logic_vector; b : std_logic_vector; s : std_logic) return std_logic_vector is
	begin
		if s = '1' then
			return b;
		else
			return a;
		end if;
	end function;
	
	signal fast_cmp_result : std_logic;
	
	signal registers_pending_reg : registers_pending_t;
	signal registers_pending_reg_next : registers_pending_t;
	
	signal registers_pending_set : registers_pending_t;
	
	type state_t is (state_idle, state_stall);
	signal state : state_t;
	signal state_next : state_t;
	
	signal out_valid_reg : std_logic;
	signal out_valid_reg_next : std_logic;
			
	signal register_a_value : slv32_t;
	signal register_b_value : slv32_t;
	signal register_hi_value : slv32_t;
	signal register_lo_value : slv32_t;
	
	signal register_c_value : slv32_t;
	
	-- contain the last value written to register c
	-- this is only valid if the last operation was a write to the same register
	signal register_c_bypass_value : slv32_t;
	signal register_c_bypass_value_next : slv32_t;
	signal register_hi_bypass_value : slv32_t;
	signal register_hi_bypass_value_next : slv32_t;
	signal register_lo_bypass_value : slv32_t;
	signal register_lo_bypass_value_next : slv32_t;
	
	signal register_a_use_bypass : std_logic;
	signal register_a_use_bypass_next : std_logic;
	signal register_b_use_bypass : std_logic;
	signal register_b_use_bypass_next : std_logic;
	signal register_c_use_bypass : std_logic;
	signal register_c_use_bypass_next : std_logic;
	signal register_hi_use_bypass : std_logic;
	signal register_hi_use_bypass_next : std_logic;
	signal register_lo_use_bypass : std_logic;
	signal register_lo_use_bypass_next : std_logic;
begin
	register_a_value <= register_c_bypass_value when register_a_use_bypass = '1' else register_port_out_a.data when register_a_reg(5) = '0' else cop0_reg_port_out_a.data;
	register_b_value <= register_c_bypass_value when register_b_use_bypass = '1' else register_port_out_b.data;
	register_hi_value <= register_hi_bypass_value when register_hi_use_bypass = '1' else register_hilo_out.data(63 downto 32);
	register_lo_value <= register_lo_bypass_value when register_lo_use_bypass = '1' else register_hilo_out.data(31 downto 0);
	
	register_c_value <= link_address_reg when (operation_reg.op_link = '1' or (operation_reg.op_link_branch = '1' and fast_cmp_result = '1'))
		else immediate_a_reg when operation_reg.op_immediate_a = '1'
		else register_hi_value when operation_reg.op_fromhilo = '1' and operation_reg.op_hi = '1'
		else register_lo_value when operation_reg.op_fromhilo = '1' and operation_reg.op_lo = '1'
		else register_a_value;
	
	-- bypass, keep values of the last register written
	-- readreg stage is in two cycles : 1) we check if we must stall, 2) we send the data to the alu, or write to register
	-- which means, when we get the next instruction, the data is BEING written to register. Since we might need it in the next cycle we use bypass
	process(
		out_valid_reg,
		register_c_bypass_value,
		register_hi_bypass_value,
		register_lo_bypass_value,
		register_c_value,
		register_hi_value,
		register_lo_value
		)
	begin
		register_c_bypass_value_next <= register_c_bypass_value;
		register_hi_bypass_value_next <= register_hi_bypass_value;
		register_lo_bypass_value_next <= register_lo_bypass_value;
		
		if out_valid_reg = '1' then
			register_c_bypass_value_next <= register_c_value;
			register_hi_bypass_value_next <= register_hi_value;
			register_lo_bypass_value_next <= register_lo_value;
		end if;
	end process;
	
	-- the is the set pending. We set register pending if the op_reg_c_set_pending flag is set
	-- but not if the operation is mov (which means move to another register), because in that case we use bypass to avoid stall
	process(
		register_c_reg,
		operation_reg,
		operation,
		out_valid_reg_next,
		state
		)
	begin
		registers_pending_set <= (gp_registers => (others => '0'), others => '0');
		
		-- we use out_valid_reg_next so we dont have to wait 1 more cycle
		if out_valid_reg_next = '1' then
			case state is
				when state_idle =>
					-- pending must not be set when we stall. Otherwise we might deadlock
					-- eg. we execute mthi, but a div is already pending. So we stall waiting for dest(hi) to be cleared. But it never happens since we set it pending during stall
					registers_pending_set.gp_registers <= (others => '0');
					registers_pending_set.gp_registers(TO_INTEGER(unsigned(register_c(4 downto 0)))) <= operation.op_reg_c_set_pending;
					registers_pending_set.hi <= operation.op_hi and operation.op_tohilo and not operation.op_mov;
					registers_pending_set.lo <= operation.op_lo and operation.op_tohilo and not operation.op_mov;
				when state_stall =>
					registers_pending_set.gp_registers <= (others => '0');
					registers_pending_set.gp_registers(TO_INTEGER(unsigned(register_c_reg(4 downto 0)))) <= operation_reg.op_reg_c_set_pending;
					registers_pending_set.hi <= operation_reg.op_hi and operation_reg.op_tohilo and not operation_reg.op_mov;
					registers_pending_set.lo <= operation_reg.op_lo and operation_reg.op_tohilo and not operation_reg.op_mov;
			end case;
		end if;
	end process;
		
	-- this check if any required register is pending
	process(
		resetn,
		operation,
		operation_reg,
		registers_pending_reg,
		register_a,
		register_a_reg,
		register_b,
		register_b_reg,
		register_c,
		register_c_reg,
		state
		)
		variable ireg_a : NATURAL;
		variable ireg_b : NATURAL;
		variable ireg_c : NATURAL;
		variable op : decode_operation_t;
	begin
		register_a_pending <= '0';
		register_b_pending <= '0';
		register_c_pending <= '0';
		
		if state = state_idle then
			ireg_a := TO_INTEGER(unsigned(register_a(4 downto 0)));
			ireg_b := TO_INTEGER(unsigned(register_b(4 downto 0)));
			ireg_c := TO_INTEGER(unsigned(register_c(4 downto 0)));
			op := operation;
		else
			ireg_a := TO_INTEGER(unsigned(register_a_reg(4 downto 0)));
			ireg_b := TO_INTEGER(unsigned(register_b_reg(4 downto 0)));
			ireg_c := TO_INTEGER(unsigned(register_c_reg(4 downto 0)));
			op := operation_reg;
		end if;
		
		if resetn = '0' then
			register_a_pending <= '0';
			register_b_pending <= '0';
			register_c_pending <= '0';
		else
			if op.op_fromhilo = '1' then
				if op.op_hi = '1' then
					register_a_pending <= registers_pending_reg.hi;
				else
					register_a_pending <= registers_pending_reg.lo;
				end if;
			elsif op.op_immediate_a = '1' then
				register_a_pending <= '0';
			else
				register_a_pending <= registers_pending_reg.gp_registers(ireg_a);
			end if;
				
			if op.op_immediate_b = '1' then
				register_b_pending <= '0';
			else
				register_b_pending <= registers_pending_reg.gp_registers(ireg_b);
			end if;
				
			if op.op_tohilo = '1' then
				if op.op_hi = '1' then
					register_c_pending <= (registers_pending_reg.hi and not op.op_mov);
				else
					register_c_pending <= (registers_pending_reg.lo and not op.op_mov);
				end if;
			else
				register_c_pending <= registers_pending_reg.gp_registers(ireg_c);
			end if;
		end if;
	end process;
	
	fast_cmp_result <= (not register_a_value(31) xor operation_reg.op_cmp_invert);
	execute_delay_slot <= operation_valid_reg and operation_reg.op_cmp_gez and fast_cmp_result and operation_reg.op_branch_likely;
	skip_jump <= operation_valid_reg and operation_reg.op_cmp_gez and not fast_cmp_result;
	
	stall <= '1' when state = state_stall else '0';
	
	-- /!\ when branch, add operands are always immediates, because registers are used by cmp
	alu_in_ports.add_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b or operation_reg.op_branch) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a or operation_reg.op_branch);
	
	alu_in_ports.add_in_tvalid <= operation_reg.op_add and operation_valid_reg and out_valid_reg when operation_reg.op_cmp_gez = '0'
		else operation_reg.op_add and operation_valid_reg and out_valid_reg and fast_cmp_result;
	
	alu_in_ports.add_in_tuser <= add_out_tuser_to_slv(alu_add_tuser);
	alu_add_tuser.exclusive <= '0';
	alu_add_tuser.signed <= not operation_reg.op_unsigned;
	alu_add_tuser.memop_type <= memop_type_reg;
	alu_add_tuser.store <= store_reg;
	alu_add_tuser.store_data <= register_port_out_c.data;
	alu_add_tuser.load <= load_reg;
	alu_add_tuser.rt <= register_c_reg;
	 -- when op_cmp_gez is used, we transform the branch in jump when cmp is successfull
	alu_add_tuser.branch <= operation_reg.op_branch when operation_reg.op_cmp_gez = '0' else not fast_cmp_result;
	alu_add_tuser.jump <= operation_reg.op_jump when operation_reg.op_cmp_gez = '0' else fast_cmp_result;
	-- thats ugly... write to register only if not anything else
	alu_add_tuser.mov <= not operation_reg.op_jump and not operation_reg.op_branch and not store_reg and not load_reg;
	
	alu_in_ports.sub_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.sub_in_tvalid <= operation_reg.op_sub and out_valid_reg;
	alu_in_ports.sub_in_tuser <= register_c_reg;
	
	alu_in_ports.mul_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.mul_in_tvalid <= operation_reg.op_mul and not operation_reg.op_unsigned and out_valid_reg;
	alu_in_ports.mul_in_tuser <= mul_tuser_to_slv(alu_mul_tuser);
	alu_mul_tuser.rd <= register_c_reg;
	alu_mul_tuser.use_hilo <= operation_reg.op_hi or operation_reg.op_lo;
	
	alu_in_ports.multu_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.multu_in_tvalid <= operation_reg.op_mul and operation_reg.op_unsigned and out_valid_reg;
	alu_in_ports.multu_in_tuser <= register_c_reg;
	
	alu_in_ports.div_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.div_in_tvalid <= operation_reg.op_div and not operation_reg.op_unsigned and out_valid_reg;
	alu_in_ports.div_in_tuser <= register_c_reg;
	
	alu_in_ports.divu_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.divu_in_tvalid <= operation_reg.op_div and operation_reg.op_unsigned and out_valid_reg;
	alu_in_ports.divu_in_tuser <= register_c_reg;
	
	alu_in_ports.and_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.and_in_tvalid <= operation_reg.op_and and out_valid_reg;
	alu_in_ports.and_in_tuser <= register_c_reg;
	
	alu_in_ports.or_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.or_in_tvalid <= operation_reg.op_or and out_valid_reg;
	alu_in_ports.or_in_tuser <= register_c_reg;
	
	alu_in_ports.xor_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.xor_in_tvalid <= operation_reg.op_xor and out_valid_reg;
	alu_in_ports.xor_in_tuser <= register_c_reg;
	
	alu_in_ports.nor_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.nor_in_tvalid <= operation_reg.op_nor and out_valid_reg;
	alu_in_ports.nor_in_tuser <= register_c_reg;
	
	alu_in_ports.shl_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b)(4 downto 0) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.shl_in_tvalid <= operation_reg.op_sll and out_valid_reg;
	alu_in_ports.shl_in_tuser <= register_c_reg;
	
	alu_in_ports.shr_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b)(4 downto 0) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.shr_in_tvalid <= (operation_reg.op_srl or operation_reg.op_sra) and out_valid_reg;
	alu_in_ports.shr_in_tuser <= operation_reg.op_sra & register_c_reg;
	
	-- when branch, cmp always use registers
	alu_in_ports.cmp_in_tdata <= select_operand(register_b_value, immediate_b_reg, operation_reg.op_immediate_b and not operation_reg.op_branch) &
		select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a and not operation_reg.op_branch);
	alu_in_ports.cmp_in_tvalid <= operation_reg.op_cmp and out_valid_reg;
	alu_in_ports.cmp_in_tuser <= cmp_tuser_to_slv(alu_cmp_tuser);
	alu_cmp_tuser.eq <= operation_reg.op_cmp_eq;
	alu_cmp_tuser.ge <= operation_reg.op_cmp_ge;
	alu_cmp_tuser.le <= operation_reg.op_cmp_le;
	alu_cmp_tuser.rd <= register_c_reg;
	alu_cmp_tuser.invert <= operation_reg.op_cmp_invert;
	alu_cmp_tuser.unsigned <= operation_reg.op_unsigned;
	alu_cmp_tuser.branch <= operation_reg.op_branch;
	alu_cmp_tuser.likely <= operation_reg.op_branch_likely;
	alu_cmp_tuser.alternate_value <= register_b_value;
	alu_cmp_tuser.mov_alternate <= operation_reg.op_cmpmov_alternate;
	alu_cmp_tuser.mov <= operation_reg.op_cmpmov;
	
	alu_in_ports.clo_in_tdata <= select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.clo_in_tvalid <= operation_reg.op_clo and out_valid_reg;
	alu_in_ports.clo_in_tuser <= register_c_reg;
	
	alu_in_ports.clz_in_tdata <= select_operand(register_a_value, immediate_a_reg, operation_reg.op_immediate_a);
	alu_in_ports.clz_in_tvalid <= operation_reg.op_clz and out_valid_reg;
	alu_in_ports.clz_in_tuser <= register_c_reg;
	
	register_hilo_in.write_data <= register_a_value & register_a_value;
	register_hilo_in.write_strobe <= operation_reg.op_hi & operation_reg.op_lo;
	register_hilo_in.write_enable <= operation_reg.op_tohilo and operation_reg.op_mov and out_valid_reg;
	
	override_address_valid <= '0';
	override_address <= register_a_value;
		
	register_port_in_d.address <= register_c_reg(4 downto 0);
	register_port_in_d.write_data <= register_c_value;
	register_port_in_d.write_strobe <= mov_strobe_reg;
	register_port_in_d.write_enable <= (fast_cmp_result and operation_valid_reg and out_valid_reg) when operation_reg.op_link_branch = '1' else (not register_c_reg(5) and operation_reg.op_mov and not operation_reg.op_tohilo and operation_valid_reg and out_valid_reg);
	
	cop0_reg_port_in_a.address <= register_a(4 downto 0);
	cop0_reg_port_in_a.write_data <= (others => '0');
	cop0_reg_port_in_a.write_enable <= '0';
	cop0_reg_port_in_a.write_strobe <= (others => '0');
	
	cop0_reg_port_in_b.address <= register_c_reg(4 downto 0);
	cop0_reg_port_in_b.write_data <= register_a_value;
	cop0_reg_port_in_b.write_enable <= operation_reg.op_mov and register_c_reg(5) and operation_valid_reg;
	cop0_reg_port_in_b.write_strobe <= mov_strobe_reg;
	
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
			link_address_reg <= link_address_reg_next;
			mov_strobe_reg <= mov_strobe_reg_next;
						
			registers_pending_reg <= registers_pending_reg_next;
			registers_pending_reg.gp_registers(0) <= '0';
			
			out_valid_reg <= out_valid_reg_next;
			
			state <= state_next;
						
			register_c_bypass_value <= register_c_bypass_value_next;
			register_hi_bypass_value <= register_hi_bypass_value_next;
			register_lo_bypass_value <= register_lo_bypass_value_next;
	
			register_a_use_bypass <= register_a_use_bypass_next;
			register_b_use_bypass <= register_b_use_bypass_next;
			register_c_use_bypass <= register_c_use_bypass_next;
			register_hi_use_bypass <= register_hi_use_bypass_next;
			register_lo_use_bypass <= register_lo_use_bypass_next;
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
	
		register_a_pending,
		register_b_pending,
		register_c_pending,
		
		register_port_out_a,
				
		link_address,
		link_address_reg,
		fast_cmp_result,
		mov_strobe,
		mov_strobe_reg,
		registers_pending_reg,
		
		registers_pending_reset_in_a,
		registers_pending_reset_in_b,
		registers_pending_set,
		
		state
	)
        variable instruction_data_r : instruction_r_t;
        variable instruction_data_i : instruction_i_t;
        variable instruction_data_j : instruction_j_t;
	begin
		register_port_in_a.address <= register_a(4 downto 0);
		register_port_in_a.write_enable <= '0';
		register_port_in_a.write_data <= (others => '0');
		register_port_in_a.write_strobe <= (others => '0');
		register_port_in_b.address <= register_b(4 downto 0);
		register_port_in_b.write_enable <= '0';
		register_port_in_b.write_data <= (others => '0');
		register_port_in_b.write_strobe <= (others => '0');
		register_port_in_c.address <= register_c(4 downto 0);
		register_port_in_c.write_enable <= '0';
		register_port_in_c.write_data <= (others => '0');
		register_port_in_c.write_strobe <= (others => '0');
		
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
				
		link_address_reg_next <= link_address_reg;
		mov_strobe_reg_next <= mov_strobe_reg;
				
		state_next <= state;
		
		registers_pending_reg_next.gp_registers <= (registers_pending_reg.gp_registers and not (registers_pending_reset_in_a.gp_registers or registers_pending_reset_in_b.gp_registers)) or registers_pending_set.gp_registers;
		registers_pending_reg_next.gp_registers(0) <= '0';
		registers_pending_reg_next.hi <= (registers_pending_reg.hi and not (registers_pending_reset_in_a.hi or registers_pending_reset_in_b.hi)) or registers_pending_set.hi;
		registers_pending_reg_next.lo <= (registers_pending_reg.lo and not (registers_pending_reset_in_a.lo or registers_pending_reset_in_b.lo)) or registers_pending_set.lo;
						
		out_valid_reg_next <= '0';
		
		register_a_use_bypass_next <= '0';
		register_b_use_bypass_next <= '0';
		register_c_use_bypass_next <= '0';
		register_hi_use_bypass_next <= '0';
		register_lo_use_bypass_next <= '0';
		
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
			mov_strobe_reg_next <= (others => '0');
			
			registers_pending_reg_next.gp_registers <= (others => '0');
			registers_pending_reg_next.hi <= '0';
			registers_pending_reg_next.lo <= '0';
			
			state_next <= state_idle;
		elsif enable = '1' then
			
			register_a_use_bypass_next <= '0';
			register_b_use_bypass_next <= '0';
			
			case state is
				when state_idle =>
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
					mov_strobe_reg_next <= mov_strobe;
					
					register_port_in_a.address <= register_a(4 downto 0);
					register_port_in_b.address <= register_b(4 downto 0);
					register_port_in_c.address <= register_c(4 downto 0);
				
					-- if registers are unused, they must be set to $0 (never pending)
					if operation_valid = '1' and (register_a_pending or register_b_pending or register_c_pending) = '1' then
						state_next <= state_stall;
					elsif operation_valid = '1' then
						out_valid_reg_next <= '1';
						
						-- if we wrote a register in the last operation, we need to bypass to avoid waiting
						if operation_reg.op_mov = '1' then
							if (operation.op_fromhilo and operation.op_hi and operation_reg.op_tohilo and operation_reg.op_hi) = '1' then
								register_hi_use_bypass_next <= '1';
							elsif (operation.op_fromhilo and operation.op_lo and operation_reg.op_tohilo and operation_reg.op_lo) = '1' then
								register_lo_use_bypass_next <= '1';
							end if;
							
							if register_c_reg = register_a then
								register_a_use_bypass_next <= '1';
							end if;
							if register_c_reg = register_b then
								register_b_use_bypass_next <= '1';
							end if;
						end if;
					end if;
				
				when state_stall =>
					register_port_in_a.address <= register_a_reg(4 downto 0);
					register_port_in_b.address <= register_b_reg(4 downto 0);
					register_port_in_c.address <= register_c_reg(4 downto 0);
					
					if (register_a_pending or register_b_pending or register_c_pending) = '0' then
						out_valid_reg_next <= '1';
						state_next <= state_idle;
					end if;
			end case;
			
		end if;
	end process;
end mips_readreg_behavioral;
