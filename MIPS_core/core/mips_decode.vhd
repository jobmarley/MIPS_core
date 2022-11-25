
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mips_utils.all;


entity mips_decode is
	port (
	resetn : in std_logic;
	clock : in std_logic;
	
	instr_data : in std_logic_vector(31 downto 0);
	instr_data_valid : in std_logic;
	instr_data_ready : out std_logic;
	
	register_a : out std_logic_vector(4 downto 0);
	register_b : out std_logic_vector(4 downto 0);
	register_c : out std_logic_vector(4 downto 0);
	immediate : out std_logic_vector(31 downto 0);
	immediate_valid : out std_logic;
	operation : out std_logic_vector(7 downto 0);
	operation_valid : out std_logic;
	load : out std_logic;
	store : out std_logic;
	memop_type : out std_logic_vector(2 downto 0);
	
	panic : out std_logic
	);
end mips_decode;

architecture mips_decode_behavioral of mips_decode is
	
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
	signal operation_reg : std_logic_vector(7 downto 0);
	signal operation_reg_next : std_logic_vector(7 downto 0);
	signal operation_valid_reg : std_logic;
	signal operation_valid_reg_next : std_logic;
	signal load_reg : std_logic;
	signal load_reg_next : std_logic;
	signal store_reg : std_logic;
	signal store_reg_next : std_logic;
	signal memop_type_reg : std_logic_vector(2 downto 0);
	signal memop_type_reg_next : std_logic_vector(2 downto 0);
	
	function sign_extend(u : std_logic_vector; l : natural) return std_logic_vector is
        alias uu: std_logic_vector(u'LENGTH-1 downto 0) is u;
		variable result : std_logic_vector(l-1 downto 0);
	begin
		result := (others => uu(uu'LENGTH-1));
		result(uu'LENGTH-1 downto 0) := uu;
		return result;
	end function;
begin

	instr_data_ready <= operation_valid_reg_next;
	
	register_a <= register_a_reg;
	register_b <= register_b_reg;
	register_c <= register_c_reg;
	immediate <= immediate_reg;
	immediate_valid <= immediate_valid_reg;
	operation <= operation_reg;
	operation_valid <= operation_valid_reg;
	load <= load_reg;
	store <= store_reg;
	memop_type <= memop_type_reg;
	
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
			load_reg <= load_reg_next;
			store_reg <= store_reg_next;
			memop_type_reg <= memop_type_reg_next;
		end if;
	end process;
	
	process (
		resetn,
		
		register_a_reg,
		register_b_reg,
		register_c_reg,
		immediate_reg,
		immediate_valid_reg,
		operation_reg,
		operation_valid_reg,
		load_reg,
		store_reg,
		memop_type_reg,
		
		instr_data,
		instr_data_valid
		
	)
        variable instruction_data_r : instruction_r_t;
        variable instruction_data_i : instruction_i_t;
        variable instruction_data_j : instruction_j_t;
	begin
		register_a_reg_next <= (others => '0');
		register_b_reg_next <= (others => '0');
		register_c_reg_next <= (others => '0');
		immediate_reg_next <= (others => '0');
		immediate_valid_reg_next <= '0';
		operation_reg_next <= (others => '0');
		operation_valid_reg_next <= '0';
		load_reg_next <= '0';
		store_reg_next <= '0';
		memop_type_reg_next <= (others => '0');
		
		panic <= '0';
		
		if resetn = '0' then
			register_a_reg_next <= (others => '0');
			register_b_reg_next <= (others => '0');
			register_c_reg_next <= (others => '0');
			immediate_reg_next <= (others => '0');
			immediate_valid_reg_next <= '0';
			operation_reg_next <= (others => '0');
			operation_valid_reg_next <= '0';
			load_reg_next <= '0';
			store_reg_next <= '0';
			memop_type_reg_next <= (others => '0');
		else
			if instr_data_valid = '1' then
				
				instruction_data_r := slv_to_instruction_r(instr_data);
				instruction_data_i := slv_to_instruction_i(instr_data);
				instruction_data_j := slv_to_instruction_j(instr_data);
				
				case (instruction_data_r.opcode) is
					when "000000" => -- add/u, sub/u, div/u, mult/u, noop, and, or, sll, sra, srl xor, nor, slt/u, jr/alr, mfc0, movn
						case (instruction_data_r.funct) is
							when instr_add_opc.funct => -- add
								operation_valid_reg_next <= '1';
								operation_reg_next <= (OPERATION_INDEX_ADD => '1', others => '0');
								register_a_reg_next <= instruction_data_r.rs;
								register_b_reg_next <= instruction_data_r.rt;
								register_c_reg_next <= instruction_data_r.rd;
							when instr_addu_opc.funct => -- addu
								operation_valid_reg_next <= '1';
								operation_reg_next <= (OPERATION_INDEX_ADD => '1', others => '0');
								register_a_reg_next <= instruction_data_r.rs;
								register_b_reg_next <= instruction_data_r.rt;
								register_c_reg_next <= instruction_data_r.rd;
							
							when others =>
						end case;
					when "001000" =>
						operation_valid_reg_next <= '1';
						operation_reg_next <= (OPERATION_INDEX_ADD => '1', others => '0');
						register_a_reg_next <= instruction_data_i.rs;
						register_c_reg_next <= instruction_data_r.rt;
						immediate_reg_next <= sign_extend(instruction_data_i.immediate, 32);
						immediate_valid_reg_next <= '1';
						
					when others =>
				end case;
			end if;
		end if;
	end process;
	
end mips_decode_behavioral;
