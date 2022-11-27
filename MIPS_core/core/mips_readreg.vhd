library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mips_utils.all;

entity mips_readreg is
	port (
	enable : in std_logic;
	resetn : in std_logic;
	clock : in std_logic;
	
	-- decode
	register_a : in std_logic_vector(4 downto 0);
	register_b : in std_logic_vector(4 downto 0);
	register_c : in std_logic_vector(4 downto 0);
	immediate : in std_logic_vector(31 downto 0);
	immediate_valid : in std_logic;
	operation : in std_logic_vector(OPERATION_INDEX_END-1 downto 0);
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
	
	stall : out std_logic
	);
end mips_readreg;

architecture mips_readreg_behavioral of mips_readreg is
	signal register_a_reg : std_logic_vector(4 downto 0);
	signal register_a_reg_next : std_logic_vector(4 downto 0);
	signal register_b_reg : std_logic_vector(4 downto 0);
	signal register_b_reg_next : std_logic_vector(4 downto 0);
	signal register_c_reg : std_logic_vector(4 downto 0);
	signal register_c_reg_next : std_logic_vector(4 downto 0);
	signal immediate_reg : std_logic_vector(31 downto 0);
	signal immediate_reg_next : std_logic_vector(31 downto 0);
	signal immediate_valid_reg : std_logic;
	signal immediate_valid_reg_next : std_logic;
	signal operation_reg : std_logic_vector(OPERATION_INDEX_END-1 downto 0);
	signal operation_reg_next : std_logic_vector(OPERATION_INDEX_END-1 downto 0);
	signal operation_valid_reg : std_logic;
	signal operation_valid_reg_next : std_logic;
	signal load_reg : std_logic;
	signal load_reg_next : std_logic;
	signal store_reg : std_logic;
	signal store_reg_next : std_logic;
	signal memop_type_reg : std_logic_vector(2 downto 0);
	signal memop_type_reg_next : std_logic_vector(2 downto 0);
	signal stall_reg : std_logic;
	signal stall_reg_next : std_logic;
	
	signal register_a_pending_bypass : std_logic;
	signal register_b_pending_bypass : std_logic;
	signal register_c_pending_bypass : std_logic;
	
	signal target_register_address : std_logic_vector(4 downto 0);
	signal target_register_address_next : std_logic_vector(4 downto 0);
	signal target_register_pending : std_logic;
	signal target_register_pending_next : std_logic;
	
	signal alu_add_tuser : alu_add_out_tuser_t;
	signal alu_cmp_tuser : alu_cmp_tuser_t;
	
	function reorder(data : std_logic_vector; invert : std_logic) return std_logic_vector is
		ALIAS data2 : std_logic_vector(data'length-1 DOWNTO 0) is data;
	begin
		if invert = '1' then
			return data2(31 downto 0) & data2(63 downto 31);
		else
			return data2(63 downto 0);
		end if;
	end function;
begin

	register_a_pending_bypass <= target_register_pending when target_register_address = register_a_reg else register_port_out_a.pending;
	register_b_pending_bypass <= target_register_pending when target_register_address = register_b_reg else register_port_out_b.pending;
	register_c_pending_bypass <= target_register_pending when target_register_address = register_c_reg else register_port_out_c.pending;
	
	alu_in_ports.add_in_tdata <= (register_port_out_a.data & immediate_reg) when immediate_valid_reg = '1' else (register_port_out_a.data & register_port_out_b.data);
	alu_in_ports.add_in_tvalid <= operation_reg(OPERATION_INDEX_ADD) and not stall_reg;
	alu_in_ports.add_in_tuser <= add_out_tuser_to_slv(alu_add_tuser);
	alu_add_tuser.exclusive <= '0';
	alu_add_tuser.signed <= '0';
	alu_add_tuser.memop_type <= memop_type_reg;
	alu_add_tuser.store <= store_reg;
	alu_add_tuser.store_data <= register_port_out_c.data;
	alu_add_tuser.load <= load_reg;
	alu_add_tuser.rt <= register_c_reg;
	alu_add_tuser.jump <= '0';
	
	alu_in_ports.sub_in_tdata <= (register_port_out_a.data & immediate_reg) when immediate_valid_reg = '1' else (register_port_out_a.data & register_port_out_b.data);
	alu_in_ports.sub_in_tvalid <= operation_reg(OPERATION_INDEX_SUB) and not stall_reg;
	alu_in_ports.sub_in_tuser <= register_c_reg;
	
	alu_in_ports.and_in_tdata <= (register_port_out_a.data & immediate_reg) when immediate_valid_reg = '1' else (register_port_out_a.data & register_port_out_b.data);
	alu_in_ports.and_in_tvalid <= operation_reg(OPERATION_INDEX_AND) and not stall_reg;
	alu_in_ports.and_in_tuser <= '0' & register_c_reg;
	
	alu_in_ports.or_in_tdata <= (register_port_out_a.data & immediate_reg) when immediate_valid_reg = '1' else (register_port_out_a.data & register_port_out_b.data);
	alu_in_ports.or_in_tvalid <= operation_reg(OPERATION_INDEX_OR) and not stall_reg;
	alu_in_ports.or_in_tuser <= '0' & register_c_reg;
	
	alu_in_ports.xor_in_tdata <= (register_port_out_a.data & immediate_reg) when immediate_valid_reg = '1' else (register_port_out_a.data & register_port_out_b.data);
	alu_in_ports.xor_in_tvalid <= operation_reg(OPERATION_INDEX_XOR) and not stall_reg;
	alu_in_ports.xor_in_tuser <= '0' & register_c_reg;
	
	alu_in_ports.nor_in_tdata <= (register_port_out_a.data & immediate_reg) when immediate_valid_reg = '1' else (register_port_out_a.data & register_port_out_b.data);
	alu_in_ports.nor_in_tvalid <= operation_reg(OPERATION_INDEX_NOR) and not stall_reg;
	alu_in_ports.nor_in_tuser <= '0' & register_c_reg;
	
	alu_in_ports.shl_in_tdata <= (immediate_reg(4 downto 0) & register_port_out_a.data) when immediate_valid_reg = '1' else (register_port_out_b.data(4 downto 0) & register_port_out_a.data);
	alu_in_ports.shl_in_tvalid <= operation_reg(OPERATION_INDEX_SLL) and not stall_reg;
	alu_in_ports.shl_in_tuser <= '0' & register_c_reg;
	
	alu_in_ports.shr_in_tdata <= (immediate_reg(4 downto 0) & register_port_out_a.data) when immediate_valid_reg = '1' else (register_port_out_b.data(4 downto 0) & register_port_out_a.data);
	alu_in_ports.shr_in_tvalid <= operation_reg(OPERATION_INDEX_SRL) and not stall_reg;
	alu_in_ports.shr_in_tuser <= operation_reg(OPERATION_INDEX_SRA) & register_c_reg;
	
	alu_in_ports.cmp_in_tdata <= reorder(immediate_reg & register_port_out_a.data, operation_reg(OPERATION_INDEX_CMP_INVERT)) when immediate_valid_reg = '1' else reorder(register_port_out_b.data & register_port_out_a.data, operation_reg(OPERATION_INDEX_CMP_INVERT));
	alu_in_ports.cmp_in_tvalid <= operation_reg(OPERATION_INDEX_CMP) and not stall_reg;
	alu_in_ports.cmp_in_tuser <= cmp_tuser_to_slv(alu_cmp_tuser);
	alu_cmp_tuser.eq <= operation_reg(OPERATION_INDEX_EQ);
	alu_cmp_tuser.ge <= operation_reg(OPERATION_INDEX_GE);
	alu_cmp_tuser.le <= operation_reg(OPERATION_INDEX_LE);
	alu_cmp_tuser.rd <= register_c_reg;
	alu_cmp_tuser.unsigned <= operation_reg(OPERATION_INDEX_UNSIGNED);
	
	override_address_valid <= operation_reg(OPERATION_INDEX_JUMP);
	override_address <= register_port_out_a.data;
		
	--stall <= stall_reg;
	
	process(clock)
	begin
		if rising_edge(clock) then
			register_a_reg <= register_a_reg_next;
			register_b_reg <= register_b_reg_next;
			register_c_reg <= register_c_reg_next;
			immediate_reg <= immediate_reg_next;
			immediate_valid_reg <= immediate_valid_reg_next;
			operation_reg <= operation_reg_next;
			operation_valid_reg <= operation_valid_reg_next;
			stall_reg <= stall_reg_next;
			load_reg <= load_reg_next;
			store_reg <= store_reg_next;
			memop_type_reg <= memop_type_reg_next;
			target_register_address <= target_register_address_next;
			target_register_pending <= target_register_pending_next;
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
		immediate,
		immediate_reg,
		immediate_valid,
		immediate_valid_reg,
	
		register_a_pending_bypass,
		register_b_pending_bypass,
		register_c_pending_bypass,
		
		register_port_out_a,
		
		stall_reg,
		target_register_address,
		target_register_pending
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
		stall_reg_next <= stall_reg;
		
		register_a_reg_next <= register_a_reg;
		register_b_reg_next <= register_b_reg;
		register_c_reg_next <= register_c_reg;
		operation_reg_next <= operation_reg;
		operation_valid_reg_next <= operation_valid_reg;
		load_reg_next <= load_reg;
		store_reg_next <= store_reg;
		memop_type_reg_next <= memop_type_reg;
		immediate_reg_next <= immediate_reg;
		immediate_valid_reg_next <= immediate_valid_reg;
				
		target_register_address_next <= target_register_address;
		target_register_pending_next <= target_register_pending;
		
		stall <= '0';
				
		if resetn = '0' then
			register_a_reg_next <= (others => '0');
			register_b_reg_next <= (others => '0');
			register_c_reg_next <= (others => '0');
			immediate_reg_next <= (others => '0');
			immediate_valid_reg_next <= '0';
			operation_reg_next <= (others => '0');
			operation_valid_reg_next <= '0';
			stall_reg_next <= '0';
			load_reg_next <= '0';
			store_reg_next <= '0';
			memop_type_reg_next <= (others => '0');
		elsif enable = '1' then
			target_register_address_next <= (others => '0');
			target_register_pending_next <= '0';
			
			if operation_valid_reg = '1' and 
				(register_a_pending_bypass = '1' or
				(register_b_pending_bypass = '1' and immediate_valid_reg = '0') or
				register_c_pending_bypass = '1') then
				
				stall <= '1';
				register_port_in_a.address <= register_a_reg;
				register_port_in_b.address <= register_b_reg;
				register_port_in_c.address <= register_c_reg;
			else
				stall <= '0';
				register_a_reg_next <= register_a;
				if immediate_valid_reg = '0' then
					register_b_reg_next <= register_b;
				else
					register_b_reg_next <= (others => '0');
				end if;
				register_c_reg_next <= register_c;
				operation_reg_next <= operation;
				operation_valid_reg_next <= operation_valid;
				load_reg_next <= load;
				store_reg_next <= store;
				memop_type_reg_next <= memop_type;
				immediate_reg_next <= immediate;
				immediate_valid_reg_next <= immediate_valid;
				
				-- write register pending for target register
				register_port_in_d.address <= register_c_reg;
				register_port_in_d.write_enable <= operation_valid_reg;
				
				-- OPERATION_INDEX_MOV is used to simply write a register
				if operation_reg(OPERATION_INDEX_MOV) = '1' then
					if immediate_valid_reg = '1' then
						register_port_in_d.write_data <= immediate_reg;
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
				if register_c_reg /= "00000" then
					target_register_pending_next <= operation_valid_reg;
				end if;
			end if;
			
			
		end if;
	end process;
end mips_readreg_behavioral;
