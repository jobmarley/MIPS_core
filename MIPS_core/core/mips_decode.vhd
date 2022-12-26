
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mips_utils.all;


entity mips_decode is
	port (
	enable : in std_logic;
	resetn : in std_logic;
	clock : in std_logic;
	
	instr_address_plus_8 : in std_logic_vector(31 downto 0);
	instr_address_plus_4 : in std_logic_vector(31 downto 0);
	instr_address : in std_logic_vector(31 downto 0);
	instr_data : in std_logic_vector(31 downto 0);
	instr_data_valid : in std_logic;
	instr_data_ready : out std_logic;
	
	register_a : out std_logic_vector(5 downto 0);
	register_b : out std_logic_vector(5 downto 0);
	register_c : out std_logic_vector(5 downto 0);
	operation : out decode_operation_t;
	operation_valid : out std_logic;
	load : out std_logic;
	store : out std_logic;
	memop_type : out std_logic_vector(2 downto 0);
	mov_strobe : out std_logic_vector(3 downto 0);
	
	immediate_a : out std_logic_vector(31 downto 0);
	immediate_b : out std_logic_vector(31 downto 0);
	link_address : out std_logic_vector(31 downto 0);
	
	override_address : out std_logic_vector(31 downto 0);
	override_address_valid : out std_logic;
	
	wait_jump : out std_logic;
	execute_delay_slot : out std_logic;
	
	breakpoint : out std_logic;
	panic : out std_logic
	);
end mips_decode;

architecture mips_decode_behavioral of mips_decode is
	
	signal register_a_reg : std_logic_vector(register_a'LENGTH-1 downto 0);
	signal register_a_reg_next : std_logic_vector(register_a'LENGTH-1 downto 0);
	signal register_b_reg : std_logic_vector(register_a'LENGTH-1 downto 0);
	signal register_b_reg_next : std_logic_vector(register_a'LENGTH-1 downto 0);
	signal register_c_reg : std_logic_vector(register_a'LENGTH-1 downto 0);
	signal register_c_reg_next : std_logic_vector(register_a'LENGTH-1 downto 0);
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
	signal override_address_reg : std_logic_vector(31 downto 0);
	signal override_address_reg_next : std_logic_vector(31 downto 0);
	signal override_address_valid_reg : std_logic;
	signal override_address_valid_reg_next : std_logic;
	
	signal immediate_a_reg : std_logic_vector(31 downto 0);
	signal immediate_a_reg_next : std_logic_vector(31 downto 0);
	signal immediate_b_reg : std_logic_vector(31 downto 0);
	signal immediate_b_reg_next : std_logic_vector(31 downto 0);
	signal link_address_reg : std_logic_vector(31 downto 0);
	signal link_address_reg_next : std_logic_vector(31 downto 0);
	signal mov_strobe_reg : std_logic_vector(3 downto 0);
	signal mov_strobe_reg_next : std_logic_vector(3 downto 0);
	
	function sign_extend(u : std_logic_vector; l : natural) return std_logic_vector is
        alias uu: std_logic_vector(u'LENGTH-1 downto 0) is u;
		variable result : std_logic_vector(l-1 downto 0);
	begin
		result := (others => uu(uu'LENGTH-1));
		result(uu'LENGTH-1 downto 0) := uu;
		return result;
	end function;
	
	signal instruction_data_r : instruction_r_t;
	signal instruction_data_i : instruction_i_t;
	signal instruction_data_j : instruction_j_t;
	signal instruction_data_cop0 : instruction_cop0_t;
begin
	
	instruction_data_r <= slv_to_instruction_r(instr_data);
	instruction_data_i <= slv_to_instruction_i(instr_data);
	instruction_data_j <= slv_to_instruction_j(instr_data);
	instruction_data_cop0 <= slv_to_instruction_cop0(instr_data);
	
	register_a <= register_a_reg;
	register_b <= register_b_reg;
	register_c <= register_c_reg;
	operation <= operation_reg;
	operation_valid <= operation_valid_reg;
	load <= load_reg;
	store <= store_reg;
	memop_type <= memop_type_reg;
	override_address <= override_address_reg;
	override_address_valid <= override_address_valid_reg;
	
	immediate_a <= immediate_a_reg;
	immediate_b <= immediate_b_reg;
	link_address <= link_address_reg;
	mov_strobe <= mov_strobe_reg;
	
	process(clock)
	begin
		if rising_edge(clock) then
			register_a_reg <= register_a_reg_next;
			register_b_reg <= register_b_reg_next;
			register_c_reg <= register_c_reg_next;
			operation_reg <= operation_reg_next;
			operation_valid_reg <= operation_valid_reg_next;
			load_reg <= load_reg_next;
			store_reg <= store_reg_next;
			memop_type_reg <= memop_type_reg_next;
			override_address_reg <= override_address_reg_next;
			override_address_valid_reg <= override_address_valid_reg_next;
			
			immediate_a_reg <= immediate_a_reg_next;
			immediate_b_reg <= immediate_b_reg_next;
			link_address_reg <= link_address_reg_next;
			mov_strobe_reg <= mov_strobe_reg_next;
		end if;
	end process;
	
	process (
		enable,
		resetn,
				
		instr_address_plus_8,
		instr_address_plus_4,
		instr_address,
		instr_data,
		instr_data_valid,
		instruction_data_r,
		instruction_data_i,
		instruction_data_j,
		instruction_data_cop0
	)
	begin
		register_a_reg_next <= (others => '0');
		register_b_reg_next <= (others => '0');
		register_c_reg_next <= (others => '0');
		operation_reg_next <= (others => '0');
		operation_valid_reg_next <= '0';
		load_reg_next <= '0';
		store_reg_next <= '0';
		memop_type_reg_next <= (others => '0');
		override_address_reg_next <= (others => '0');
		override_address_valid_reg_next <= '0';
		
		immediate_a_reg_next <= (others => '0');
		immediate_b_reg_next <= (others => '0');
		link_address_reg_next <= (others => '0');
		mov_strobe_reg_next <= x"0";
		
		instr_data_ready <= '0';
		panic <= '0';
		wait_jump <= '0';
		execute_delay_slot <= '0';
		breakpoint <= '0';
		
		if resetn = '0' then
			register_a_reg_next <= (others => '0');
			register_b_reg_next <= (others => '0');
			register_c_reg_next <= (others => '0');
			operation_reg_next <= (others => '0');
			operation_valid_reg_next <= '0';
			load_reg_next <= '0';
			store_reg_next <= '0';
			memop_type_reg_next <= (others => '0');
			
			immediate_a_reg_next <= (others => '0');
			immediate_b_reg_next <= (others => '0');
			link_address_reg_next <= (others => '0');
			mov_strobe_reg_next <= (others => '0');
		elsif enable = '1' then
			instr_data_ready <= '1';
			if instr_data_valid = '1' then
								
				case (instruction_data_r.opcode) is
					when instr_add_opc.opcode => -- add/u, sub/u, div/u, mult/u, noop, and, or, sll, sra, srl xor, nor, slt/u, jr/alr, mfc0, movn
						case (instruction_data_r.funct) is
							when instr_add_opc.funct | instr_addu_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_and_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_and <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_div_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_div <= '1';
								operation_reg_next.op_hi <= '1';
								operation_reg_next.op_lo <= '1';
								operation_reg_next.op_tohilo <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
							when instr_divu_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_div <= '1';
								operation_reg_next.op_unsigned <= '1';
								operation_reg_next.op_hi <= '1';
								operation_reg_next.op_lo <= '1';
								operation_reg_next.op_tohilo <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
							when instr_mult_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mul <= '1';
								operation_reg_next.op_hi <= '1';
								operation_reg_next.op_lo <= '1';
								operation_reg_next.op_tohilo <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
							when instr_multu_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mul <= '1';
								operation_reg_next.op_unsigned <= '1';
								operation_reg_next.op_hi <= '1';
								operation_reg_next.op_lo <= '1';
								operation_reg_next.op_tohilo <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
							-- -- noop is sll 0, 0, 0
							--when instr_noop_opc.funct =>
							--	operation_valid_reg_next <= '0';
							when instr_or_opc.funct =>
								-- can be optimized. If one register is $0, then this is a mov
								operation_valid_reg_next <= '1';
								operation_reg_next.op_or <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_sll_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_sll <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								immediate_b_reg_next <= x"000000" & "000" & instruction_data_r.shamt;
								operation_reg_next.op_immediate_b <= '1';
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_sllv_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_sll <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_b_reg_next <= '0' & instruction_data_r.rs;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_sra_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_sra <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								immediate_b_reg_next <= x"000000" & "000" & instruction_data_r.shamt;
								operation_reg_next.op_immediate_b <= '1';
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_srav_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_sra <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_b_reg_next <= '0' & instruction_data_r.rs;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_srl_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_srl <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								immediate_b_reg_next <= x"000000" & "000" & instruction_data_r.shamt;
								operation_reg_next.op_immediate_b <= '1';
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_srlv_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_srl <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_b_reg_next <= '0' & instruction_data_r.rs;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_sub_opc.funct | instr_subu_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_sub <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_xor_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_xor <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_nor_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_nor <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_slt_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_cmp <= '1';
								operation_reg_next.op_cmp_ge <= '1';
								operation_reg_next.op_cmp_invert <= '1';
								operation_reg_next.op_cmpmov <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_sltu_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_cmp <= '1';
								operation_reg_next.op_cmp_ge <= '1';
								operation_reg_next.op_cmp_invert <= '1';
								operation_reg_next.op_unsigned <= '1';
								operation_reg_next.op_cmpmov <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_jalr_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_jump <= '1';
								operation_reg_next.op_mov <= '1';
								mov_strobe_reg_next <= x"F";
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= "000000";
								register_c_reg_next <= '0' & instruction_data_r.rd;
								link_address_reg_next <= instr_address_plus_8;
								operation_reg_next.op_link <= '1';
								execute_delay_slot <= '1';
								wait_jump <= '1';
							when instr_jr_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_jump <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= "000000";
								execute_delay_slot <= '1';
								wait_jump <= '1';
							
							when instr_mfhi_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mov <= '1';
								operation_reg_next.op_hi <= '1';
								operation_reg_next.op_fromhilo <= '1';
								register_c_reg_next <= '0' & instruction_data_r.rd;
								mov_strobe_reg_next <= "1111";
							when instr_mflo_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mov <= '1';
								operation_reg_next.op_lo <= '1';
								operation_reg_next.op_fromhilo <= '1';
								register_c_reg_next <= '0' & instruction_data_r.rd;
								mov_strobe_reg_next <= "1111";
							when instr_mthi_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mov <= '1';
								operation_reg_next.op_hi <= '1';
								operation_reg_next.op_tohilo <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								mov_strobe_reg_next <= "1111";
							when instr_mtlo_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mov <= '1';
								operation_reg_next.op_lo <= '1';
								operation_reg_next.op_tohilo <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								mov_strobe_reg_next <= "1111";
	
							when instr_movn_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_cmp <= '1';
								operation_reg_next.op_cmp_eq <= '1';
								operation_reg_next.op_cmp_invert <= '1';
								operation_reg_next.op_cmpmov_alternate <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_b_reg_next <= '0' & instruction_data_r.rs;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								immediate_b_reg_next <= (others => '0');
								operation_reg_next.op_immediate_b <= '1';
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_movz_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_cmp <= '1';
								operation_reg_next.op_cmp_eq <= '1';
								operation_reg_next.op_cmpmov_alternate <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_b_reg_next <= '0' & instruction_data_r.rs;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								immediate_b_reg_next <= (others => '0');
								operation_reg_next.op_immediate_b <= '1';
								operation_reg_next.op_reg_c_set_pending <= '1';
	
							when instr_syscall_opc.funct =>
							when instr_break_opc.funct =>
	
							when instr_sync_opc.funct =>
							
							when others =>
								panic <= '1';
						end case;
					when instr_addi_opc.opcode | instr_addiu_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						operation_reg_next.op_reg_c_set_pending <= '1';
					when instr_andi_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_and <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= x"0000" & instruction_data_i.immediate;
						operation_reg_next.op_immediate_b <= '1';
						operation_reg_next.op_reg_c_set_pending <= '1';
					when instr_mul_opc.opcode =>
						case (instruction_data_r.funct) is
							when instr_mul_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mul <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_b_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_madd_opc.funct =>
							when instr_maddu_opc.funct =>
							when instr_msub_opc.funct =>
							when instr_msubu_opc.funct =>
							when instr_clo_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_clo <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_clz_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_clz <= '1';
								register_a_reg_next <= '0' & instruction_data_r.rs;
								register_c_reg_next <= '0' & instruction_data_r.rd;
								operation_reg_next.op_reg_c_set_pending <= '1';
							when instr_sdbbp_opc.funct =>
								breakpoint <= '1';
							when others =>
								panic <= '1';
						end case;
					when instr_ori_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_or <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= x"0000" & instruction_data_i.immediate;
						operation_reg_next.op_immediate_b <= '1';
						operation_reg_next.op_reg_c_set_pending <= '1';
					when instr_xori_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_xor <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= x"0000" & instruction_data_i.immediate;
						operation_reg_next.op_immediate_b <= '1';
						operation_reg_next.op_reg_c_set_pending <= '1';
					when instr_slti_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_ge <= '1';
						operation_reg_next.op_cmp_invert <= '1';
						operation_reg_next.op_cmpmov <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						operation_reg_next.op_reg_c_set_pending <= '1';
					when instr_sltiu_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_ge <= '1';
						operation_reg_next.op_cmp_invert <= '1';
						operation_reg_next.op_unsigned <= '1';
						operation_reg_next.op_cmpmov <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						operation_reg_next.op_reg_c_set_pending <= '1';
					when instr_beq_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_eq <= '1';
						operation_reg_next.op_branch <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= '0' & instruction_data_i.rt;
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						execute_delay_slot <= '1';
						wait_jump <= '1';
					when instr_beql_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_eq <= '1';
						operation_reg_next.op_branch <= '1';
						operation_reg_next.op_branch_likely <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= '0' & instruction_data_i.rt;
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						wait_jump <= '1';
					when instr_bltz_opc.opcode =>
						case (instruction_data_i.rt) is
							when instr_bltz_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_cmp_invert <= '1';
								operation_reg_next.op_branch <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								immediate_b_reg_next <= instr_address_plus_4;
								-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
								execute_delay_slot <= '1';
								wait_jump <= '1';
							when instr_bltzl_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_cmp_invert <= '1';
								operation_reg_next.op_branch <= '1';
								operation_reg_next.op_branch_likely <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								immediate_b_reg_next <= instr_address_plus_4;
								-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
								wait_jump <= '1';
							when instr_bltzal_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_cmp_invert <= '1';
								operation_reg_next.op_branch <= '1';
								mov_strobe_reg_next <= x"F";
								operation_reg_next.op_link_branch <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								register_c_reg_next <= "011111";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								-- do not set immediate_valid because we use ADD + CMP and OPERATION_INDEX_B takes care of that
								immediate_b_reg_next <= instr_address_plus_4;
								link_address_reg_next <= instr_address_plus_8;
								execute_delay_slot <= '1';
								wait_jump <= '1';
							when instr_bltzall_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_cmp_invert <= '1';
								operation_reg_next.op_branch <= '1';
								operation_reg_next.op_branch_likely <= '1';
								mov_strobe_reg_next <= x"F";
								operation_reg_next.op_link_branch <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								register_c_reg_next <= "011111";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								-- do not set immediate_valid because we use ADD + CMP and OPERATION_INDEX_B takes care of that
								immediate_b_reg_next <= instr_address_plus_4;
								link_address_reg_next <= instr_address_plus_8;
								wait_jump <= '1';
							when instr_bgez_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_branch <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								immediate_b_reg_next <= instr_address_plus_4;
								-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
								execute_delay_slot <= '1';
								wait_jump <= '1';
							when instr_bgezl_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_branch <= '1';
								operation_reg_next.op_branch_likely <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								immediate_b_reg_next <= instr_address_plus_4;
								-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
								wait_jump <= '1';
							when instr_bgezal_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_branch <= '1';
								mov_strobe_reg_next <= x"F";
								operation_reg_next.op_link_branch <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								register_c_reg_next <= "011111";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								-- do not set immediate_valid because we use ADD + CMP and OPERATION_INDEX_B takes care of that
								immediate_b_reg_next <= instr_address_plus_4;
								link_address_reg_next <= instr_address_plus_8;
								execute_delay_slot <= '1';
								wait_jump <= '1';
							when instr_bgezall_opc.rt =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_add <= '1';
								operation_reg_next.op_cmp_gez <= '1';
								operation_reg_next.op_branch <= '1';
								operation_reg_next.op_branch_likely <= '1';
								mov_strobe_reg_next <= x"F";
								operation_reg_next.op_link_branch <= '1';
								register_a_reg_next <= '0' & instruction_data_i.rs;
								register_b_reg_next <= "000000";
								register_c_reg_next <= "011111";
								immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
								-- do not set immediate_valid because we use ADD + CMP and OPERATION_INDEX_B takes care of that
								immediate_b_reg_next <= instr_address_plus_4;
								link_address_reg_next <= instr_address_plus_8;
								wait_jump <= '1';
							
							when others =>
								panic <= '1';
						end case;
					when instr_bgtz_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_le <= '1';
						operation_reg_next.op_cmp_invert <= '1';
						operation_reg_next.op_branch <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= "000000";
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						execute_delay_slot <= '1';
						wait_jump <= '1';
					when instr_bgtzl_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_le <= '1';
						operation_reg_next.op_cmp_invert <= '1';
						operation_reg_next.op_branch <= '1';
						operation_reg_next.op_branch_likely <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= "000000";
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						wait_jump <= '1';
					when instr_blez_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_le <= '1';
						operation_reg_next.op_branch <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= "000000";
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						execute_delay_slot <= '1';
						wait_jump <= '1';
					when instr_blezl_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_le <= '1';
						operation_reg_next.op_branch <= '1';
						operation_reg_next.op_branch_likely <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= "000000";
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						wait_jump <= '1';
					when instr_bne_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_eq <= '1';
						operation_reg_next.op_cmp_invert <= '1';
						operation_reg_next.op_branch <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= '0' & instruction_data_i.rt;
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						execute_delay_slot <= '1';
						wait_jump <= '1';
					when instr_bnel_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_cmp <= '1';
						operation_reg_next.op_cmp_eq <= '1';
						operation_reg_next.op_cmp_invert <= '1';
						operation_reg_next.op_branch <= '1';
						operation_reg_next.op_branch_likely <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_b_reg_next <= '0' & instruction_data_i.rt;
						immediate_a_reg_next <= sign_extend(instruction_data_i.immediate & "00", 32);
						immediate_b_reg_next <= instr_address_plus_4;
						-- dont set immediate_a/b because branch forces immediates for add and regs for cmp
						wait_jump <= '1';
					when instr_j_opc.opcode =>
						override_address_reg_next <= instr_address(31 downto 28) & instruction_data_j.address & "00";
						override_address_valid_reg_next <= '1';
						execute_delay_slot <= '1';
						wait_jump <= '1';
					when instr_jal_opc.opcode =>
						operation_valid_reg_next <= '1';
						override_address_reg_next <= instr_address(31 downto 28) & instruction_data_j.address & "00";
						override_address_valid_reg_next <= '1';
						operation_reg_next.op_mov <= '1';
						mov_strobe_reg_next <= x"F";
						register_a_reg_next <= "000000";
						register_c_reg_next <= "011111";
						immediate_a_reg_next <= instr_address_plus_8;
						operation_reg_next.op_immediate_a <= '1';
						execute_delay_slot <= '1';
						wait_jump <= '1';
					
					when instr_lb_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						operation_reg_next.op_reg_c_set_pending <= '1';
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						load_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_byte;
					when instr_lbu_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_unsigned <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						operation_reg_next.op_reg_c_set_pending <= '1';
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						load_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_byte;
					when instr_lh_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						operation_reg_next.op_reg_c_set_pending <= '1';
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						load_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_half;
					when instr_lhu_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						operation_reg_next.op_unsigned <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						operation_reg_next.op_reg_c_set_pending <= '1';
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						load_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_half;
					when instr_lui_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_mov <= '1';
						register_a_reg_next <= '0' & "00000";
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_a_reg_next <= instruction_data_i.immediate & x"0000";
						operation_reg_next.op_immediate_a <= '1';
						mov_strobe_reg_next <= "1111";
					when instr_lw_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						operation_reg_next.op_reg_c_set_pending <= '1';
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						load_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_word;
					when instr_lwl_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						operation_reg_next.op_reg_c_set_pending <= '1';
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						load_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_half_left;
					when instr_lwr_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						operation_reg_next.op_reg_c_set_pending <= '1';
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						load_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_half_right;
					
					when instr_sb_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						store_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_byte;
					when instr_sh_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						store_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_half;
					when instr_sw_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						store_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_word;
					when instr_swl_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						store_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_half_left;
					when instr_swr_opc.opcode =>
						operation_valid_reg_next <= '1';
						operation_reg_next.op_add <= '1';
						register_a_reg_next <= '0' & instruction_data_i.rs;
						register_c_reg_next <= '0' & instruction_data_i.rt;
						immediate_b_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						operation_reg_next.op_immediate_b <= '1';
						store_reg_next <= '1';
						memop_type_reg_next <= memory_op_type_half_right;
	
					when instr_sc_opc.opcode =>
					when instr_ll_opc.opcode =>
		
					when instr_cache_opc.opcode =>
					when instr_pref_opc.opcode =>
	
					
					when instr_mfc0_opc.opcode =>
						case (instruction_data_cop0.funct) is
							when instr_mfc0_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mov <= '1';
								mov_strobe_reg_next <= x"F";
								register_a_reg_next <= '1' & instruction_data_r.rd;
								register_c_reg_next <= '0' & instruction_data_r.rt;
							when instr_mtc0_opc.funct =>
								operation_valid_reg_next <= '1';
								operation_reg_next.op_mov <= '1';
								mov_strobe_reg_next <= x"F";
								register_a_reg_next <= '0' & instruction_data_r.rt;
								register_c_reg_next <= '1' & instruction_data_r.rd;
							--when instr_deret_opc.funct =>
							--when instr_eret_opc.funct =>
													
							when others =>
								panic <= '1';
						end case;
					
					when others =>
						panic <= '1';
				end case;
			end if;
		end if;
	end process;
	
end mips_decode_behavioral;
