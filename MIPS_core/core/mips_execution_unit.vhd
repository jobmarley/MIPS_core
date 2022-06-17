library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use work.mips_utils.ALL;

use work.axi_helper.all;

entity mips_execution_unit is
	port (
	resetn : in std_logic;
	enable : in std_logic;
	clock : in std_ulogic;									
			
	register_out : out std_logic_vector(31 downto 0);
	register_in : in std_logic_vector(31 downto 0);
	register_write : in std_logic;
	register_address : in std_logic_vector(4 downto 0);
	
	
	-- memory port a
	m_axil_mema_awready : in STD_LOGIC;
	m_axil_mema_wready : in STD_LOGIC;
	m_axil_mema_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axil_mema_bvalid : in STD_LOGIC;
	m_axil_mema_arready : in STD_LOGIC;
	m_axil_mema_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_mema_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axil_mema_rvalid : in STD_LOGIC;
	m_axil_mema_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_mema_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axil_mema_awvalid : out STD_LOGIC;
	m_axil_mema_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_mema_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axil_mema_wvalid : out STD_LOGIC;
	m_axil_mema_bready : out STD_LOGIC;
	m_axil_mema_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_mema_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axil_mema_arvalid : out STD_LOGIC;
	m_axil_mema_rready : out STD_LOGIC;
	-- memory port b
	m_axil_memb_awready : in STD_LOGIC;
	m_axil_memb_wready : in STD_LOGIC;
	m_axil_memb_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axil_memb_bvalid : in STD_LOGIC;
	m_axil_memb_arready : in STD_LOGIC;
	m_axil_memb_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_memb_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axil_memb_rvalid : in STD_LOGIC;
	m_axil_memb_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_memb_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axil_memb_awvalid : out STD_LOGIC;
	m_axil_memb_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_memb_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axil_memb_wvalid : out STD_LOGIC;
	m_axil_memb_bready : out STD_LOGIC;
	m_axil_memb_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_memb_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axil_memb_arvalid : out STD_LOGIC;
	m_axil_memb_rready : out STD_LOGIC;
	
	debug : out std_logic_vector(7 downto 0)
	);
end mips_execution_unit;

architecture mips_execution_unit_behavioral of mips_execution_unit is
	-- helper for accessing instruction data fields
	type instruction_r_t is record
		opcode : std_logic_vector(5 downto 0);
		rs : std_logic_vector(4 downto 0);
		rt : std_logic_vector(4 downto 0);
		rd : std_logic_vector(4 downto 0);
		shamt : std_logic_vector(4 downto 0);
		funct : std_logic_vector(5 downto 0);
	end record;
	type instruction_i_t is record
		opcode : std_logic_vector(5 downto 0);
		rs : std_logic_vector(4 downto 0);
		rt : std_logic_vector(4 downto 0);
		immediate : std_logic_vector(15 downto 0);
	end record;
	type instruction_j_t is record
		opcode : std_logic_vector(5 downto 0);
		address : std_logic_vector(25 downto 0);
	end record;
	type instruction_cop0_t is record
		opcode : std_logic_vector(5 downto 0);
		funct : std_logic_vector(4 downto 0);
		rt : std_logic_vector(4 downto 0);
		rd : std_logic_vector(4 downto 0);
		zero : std_logic_vector(7 downto 0);
		sel : std_logic_vector(2 downto 0);
	end record;
	
	function slv_to_instruction_r(v : std_logic_vector(31 downto 0)) return instruction_r_t is
		variable r : instruction_r_t;
	begin
		r.opcode := v(31 downto 26);
		r.rs := v(25 downto 21);
		r.rt := v(20 downto 16);
		r.rd := v(15 downto 11);
		r.shamt := v(10 downto 6);
		r.funct := v(5 downto 0);
		return r;
	end function;
	function slv_to_instruction_i(v : std_logic_vector(31 downto 0)) return instruction_i_t is
		variable r : instruction_i_t;
	begin
		r.opcode := v(31 downto 26);
		r.rs := v(25 downto 21);
		r.rt := v(20 downto 16);
		r.immediate := v(15 downto 0);
		return r;
	end function;
	function slv_to_instruction_j(v : std_logic_vector(31 downto 0)) return instruction_j_t is
		variable r : instruction_j_t;
	begin
		r.opcode := v(31 downto 26);
		r.address := v(25 downto 0);
		return r;
	end function;
	function slv_to_instruction_cop0(v : std_logic_vector(31 downto 0)) return instruction_cop0_t is
		variable r : instruction_cop0_t;
	begin
		r.opcode := v(31 downto 26);
		r.funct := v(25 downto 21);
		r.rt := v(20 downto 16);
		r.rd := v(15 downto 11);
		r.zero := v(10 downto 3);
		r.sel := v(2 downto 0);
		return r;
	end function;
	
	function instruction_to_slv(i : instruction_r_t) return std_logic_vector is
	begin
		return i.opcode & i.rs & i.rt & i.rd & i.shamt & i.funct;
	end function;
	
	function instruction_to_slv(i : instruction_i_t) return std_logic_vector is
	begin
		return i.opcode & i.rs & i.rt & i.immediate;
	end function;
	
	function instruction_to_slv(i : instruction_j_t) return std_logic_vector is
	begin
		return i.opcode & i.address;
	end function;
	
	function instruction_to_slv(i : instruction_cop0_t) return std_logic_vector is
	begin
		return i.opcode & i.funct & i.rt & i.rd & i.zero & i.sel;
	end function;
	
	function slv_compare(v1 : std_logic_vector(31 downto 0); v2: std_logic_vector(31 downto 0)) return BOOLEAN is
		variable r : boolean;
	begin
		r := TRUE;
		for i in 0 to 31 loop
			r := r and ((v1(i) = v2(i)) or (v1(i) = '-') or (v2(i) = '-'));
		end loop;
		return r;
	end function;
	
	constant instr_add_opc : instruction_r_t := ( opcode => "000000", funct => "100000", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_addu_opc : instruction_r_t := ( opcode => "000000", funct => "100001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_addi_opc : instruction_i_t := ( opcode => "001000", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_addiu_opc : instruction_i_t := ( opcode => "001001", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_and_opc : instruction_r_t := ( opcode => "000000", funct => "100100", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_andi_opc : instruction_i_t := ( opcode => "001100", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_div_opc : instruction_r_t := ( opcode => "000000", funct => "011010", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_divu_opc : instruction_r_t := ( opcode => "000000", funct => "011011", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_mult_opc : instruction_r_t := ( opcode => "000000", funct => "011000", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_multu_opc : instruction_r_t := ( opcode => "000000", funct => "011001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_noop_opc : instruction_r_t := ( opcode => "000000", funct => "000000", shamt => (others => '0'), rs => (others => '0'), rt => (others => '0'), rd => (others => '0') );
	constant instr_or_opc : instruction_r_t := ( opcode => "000000", funct => "100101", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_ori_opc : instruction_i_t := ( opcode => "001101", rs => (others => '-'), rt => (others => '-'), immediate => (others => '-') );
	constant instr_sll_opc : instruction_r_t := ( opcode => "000000", funct => "000000", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_sllv_opc : instruction_r_t := ( opcode => "000000", funct => "000100", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_sra_opc : instruction_r_t := ( opcode => "000000", funct => "000011", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_srl_opc : instruction_r_t := ( opcode => "000000", funct => "000010", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_srlv_opc : instruction_r_t := ( opcode => "000000", funct => "000110", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_sub_opc : instruction_r_t := ( opcode => "000000", funct => "100010", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_subu_opc : instruction_r_t := ( opcode => "000000", funct => "100011", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_xor_opc : instruction_r_t := ( opcode => "000000", funct => "100110", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_xori_opc : instruction_i_t := ( opcode => "001110", rs => (others => '-'), rt => (others => '-'), immediate => (others => '-') );
	
	constant instr_slt_opc : instruction_r_t := ( opcode => "000000", funct => "101010", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_slti_opc : instruction_i_t := ( opcode => "001010", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_sltiu_opc : instruction_i_t := ( opcode => "001011", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_sltu_opc : instruction_r_t := ( opcode => "000000", funct => "101011", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	
	constant instr_beq_opc : instruction_i_t := ( opcode => "000100", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_bltz_opc : instruction_i_t := ( opcode => "000001", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_bltzal_opc : instruction_i_t := ( opcode => "000001", rt => "10000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 10000
	constant instr_bgez_opc : instruction_i_t := ( opcode => "000001", rt => "00001", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00001
	constant instr_bgezal_opc : instruction_i_t := ( opcode => "000001", rt => "10001", rs => (others => '-'), immediate => (others => '-') );	-- rt is 10001
	constant instr_bgtz_opc : instruction_i_t := ( opcode => "000111", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_blez_opc : instruction_i_t := ( opcode => "000110", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_bne_opc : instruction_i_t := ( opcode => "000101", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	
	constant instr_j_opc : instruction_j_t := ( opcode => "000010", address => (others => '-') );
	constant instr_jal_opc : instruction_j_t := ( opcode => "000011", address => (others => '-') );
	constant instr_jalr_opc : instruction_r_t := ( opcode => "000000", funct => "001001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '0'), rd => (others => '-') );
	constant instr_jr_opc : instruction_r_t := ( opcode => "000000", funct => "001000", shamt => (others => '0'), rs => (others => '-'), rt => (others => '0'), rd => (others => '0') );
	
	constant instr_lb_opc : instruction_i_t := ( opcode => "100000", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_lbu_opc : instruction_i_t := ( opcode => "100100", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_lh_opc : instruction_i_t := ( opcode => "100001", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_lhu_opc : instruction_i_t := ( opcode => "100101", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_lui_opc : instruction_i_t := ( opcode => "001111", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_lw_opc : instruction_i_t := ( opcode => "100011", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_mfhi_opc : instruction_r_t := ( opcode => "000000", funct => "010000", shamt => (others => '0'), rs => (others => '0'), rt => (others => '0'), rd => (others => '-') );
	constant instr_mflo_opc : instruction_r_t := ( opcode => "000000", funct => "010010", shamt => (others => '0'), rs => (others => '0'), rt => (others => '0'), rd => (others => '-') );
	constant instr_mthi_opc : instruction_r_t := ( opcode => "000000", funct => "010001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '0'), rd => (others => '0') );
	constant instr_mtlo_opc : instruction_r_t := ( opcode => "000000", funct => "010011", shamt => (others => '0'), rs => (others => '-'), rt => (others => '0'), rd => (others => '0') );
	constant instr_sb_opc : instruction_i_t := ( opcode => "101000", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_sh_opc : instruction_i_t := ( opcode => "101001", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_sw_opc : instruction_i_t := ( opcode => "101011", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_mfc0_opc : instruction_cop0_t := ( opcode => "010000", funct => "00000", rt => (others => '-'), rd => (others => '-'), zero => (others => '0'), sel => "---" );
	constant instr_mtc0_opc : instruction_cop0_t := ( opcode => "010000", funct => "00100", rt => (others => '-'), rd => (others => '-'), zero => (others => '0'), sel => "---" );
	
	constant instr_syscall_opc : instruction_r_t := ( opcode => "000000", funct => "001100", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_break_opc : instruction_r_t := ( opcode => "000000", funct => "001101", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
		
	-- registers
	signal registers : register_array_t := (others => x"00000000");
	signal registers_next : register_array_t := (others => x"00000000");
	
	signal cp0_registers : register_array_t := (others => x"00000000");
	signal cp0_registers_next : register_array_t := (others => x"00000000");
	
	signal register_hi : std_logic_vector(31 downto 0) := x"00000000";
	signal register_hi_next : std_logic_vector(31 downto 0) := x"00000000";
	signal register_lo : std_logic_vector(31 downto 0) := x"00000000";
	signal register_lo_next : std_logic_vector(31 downto 0) := x"00000000";
	
	signal pc : std_logic_vector(31 downto 0) := x"00000000";
	signal pc_next : std_logic_vector(31 downto 0) := x"00000000";
	
	impure function get_reg_u(r : std_logic_vector(4 downto 0)) return unsigned is
	begin
		return unsigned(registers(to_integer(unsigned(r))));
	end function;
	impure function get_reg_s(r : std_logic_vector(4 downto 0)) return signed is
	begin
		return signed(registers(to_integer(unsigned(r)))); 
	end function;
			
	type load_type_t is (load_type_byte_signed, load_type_byte_unsigned, load_type_halfword_signed, load_type_halfword_unsigned, load_type_word_unsigned);
	
	signal load_pending : boolean := FALSE;
	signal load_pending_next : boolean := FALSE;
	signal load_pending_reg : std_logic_vector(4 downto 0);
	signal load_pending_reg_next : std_logic_vector(4 downto 0);
	signal load_type : load_type_t := load_type_byte_signed;
	signal load_type_next : load_type_t := load_type_byte_signed;
	signal load_address : std_logic_vector(31 downto 0) := x"00000000";
	signal load_address_next : std_logic_vector(31 downto 0) := x"00000000";
	
	signal panic : std_logic := '0';
	signal panic_next : std_logic := '0';
	
	function sign_extend(u : std_logic_vector; l : natural) return std_logic_vector is
        alias uu: std_logic_vector(u'LENGTH-1 downto 0) is u;
		variable result : std_logic_vector(l-1 downto 0);
	begin
		result := (others => uu(uu'LENGTH-1));
		result(uu'LENGTH-1 downto 0) := uu;
		return result;
	end function;
	
	signal address_error_exception : std_logic := '0';
	signal address_error_exception_next : std_logic := '0';
			
	signal pc_debug : unsigned(31 downto 0);
	
	signal register_out_next : std_logic_vector(31 downto 0);
					
	-- instruction data skid
	signal instruction_data_skid_data : std_logic_vector(31 downto 0);
	signal instruction_data_skid_valid : std_logic;
	signal instruction_data_skid_ready : std_logic;
	
	-- instruction address skid
	signal instruction_address_skid_data : std_logic_vector(31 downto 0);
	signal instruction_address_skid_valid : std_logic;
	signal instruction_address_skid_ready : std_logic;
	
	-- memb rdata skid
	signal memb_rdata_skid_data : std_logic_vector(31 downto 0);
	signal memb_rdata_skid_valid : std_logic;
	signal memb_rdata_skid_ready : std_logic;
	-- memb raddress skid
	signal memb_raddress_skid_data : std_logic_vector(31 downto 0);
	signal memb_raddress_skid_valid : std_logic;
	signal memb_raddress_skid_ready : std_logic;
	-- memb wdata skid
	signal memb_wdata_skid_data : std_logic_vector(31 downto 0);
	signal memb_wdata_skid_strobe : std_logic_vector(3 downto 0);
	signal memb_wdata_skid_valid : std_logic;
	signal memb_wdata_skid_ready : std_logic;
	-- memb waddress skid
	signal memb_waddress_skid_data : std_logic_vector(31 downto 0);
	signal memb_waddress_skid_valid : std_logic;
	signal memb_waddress_skid_ready : std_logic;
	
	
	component skid_buffer is
		generic(
			data_width : integer := 32
		);
		port (
			resetn : in std_logic;
			clock : in std_logic;
		
			in_valid : in std_logic;
			in_ready : out std_logic;
			in_data : in std_logic_vector(data_width-1 downto 0);
	
			out_valid : out std_logic;
			out_ready : in std_logic;
			out_data : out std_logic_vector(data_width-1 downto 0)
		 );
	end component;
	
	
	signal force_fetch : std_logic;
	signal force_fetch_next : std_logic;
begin
	
	debug(0) <= force_fetch;
	debug(1) <= instruction_data_skid_valid;
	debug(2) <= instruction_address_skid_ready;
	debug(3) <= panic;
	debug(4) <= '1' when load_pending = TRUE else '0';
	debug(5) <= memb_raddress_skid_ready;
	debug(6) <= memb_rdata_skid_valid;
	debug(7) <= '1';
	
	instruction_address_skid_data <= pc_next;
	
	instruction_data_skid : skid_buffer
		generic map(data_width => 32)
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => m_axil_mema_rvalid,
			in_ready => m_axil_mema_rready,
			in_data => m_axil_mema_rdata,
		
			out_valid => instruction_data_skid_valid,
			out_ready => instruction_data_skid_ready,
			out_data => instruction_data_skid_data
		);
	instruction_address_skid : skid_buffer
		generic map(data_width => 32)
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => instruction_address_skid_valid,
			in_ready => instruction_address_skid_ready,
			in_data => instruction_address_skid_data,
		
			out_valid => m_axil_mema_arvalid,
			out_ready => m_axil_mema_arready,
			out_data => m_axil_mema_araddr
		);
	
	memb_rdata_skid : skid_buffer
		generic map(data_width => 32)
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => m_axil_memb_rvalid,
			in_ready => m_axil_memb_rready,
			in_data => m_axil_memb_rdata,
		
			out_valid => memb_rdata_skid_valid,
			out_ready => memb_rdata_skid_ready,
			out_data => memb_rdata_skid_data
		);
	memb_raddress_skid : skid_buffer
		generic map(data_width => 32)
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => memb_raddress_skid_valid,
			in_ready => memb_raddress_skid_ready,
			in_data => memb_raddress_skid_data,
		
			out_valid => m_axil_memb_arvalid,
			out_ready => m_axil_memb_arready,
			out_data => m_axil_memb_araddr
		);
	memb_wdata_skid : skid_buffer
		generic map(data_width => 32 + 4) -- data + strobe
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => memb_wdata_skid_valid,
			in_ready => memb_wdata_skid_ready,
			in_data(31 downto 0) => memb_wdata_skid_data,
			in_data(35 downto 32) => memb_wdata_skid_strobe,
		
			out_valid => m_axil_memb_wvalid,
			out_ready => m_axil_memb_wready,
			out_data(31 downto 0) => m_axil_memb_wdata,
			out_data(35 downto 32) => m_axil_memb_wstrb	
		);
	memb_waddress_skid : skid_buffer
		generic map(data_width => 32)
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => memb_waddress_skid_valid,
			in_ready => memb_waddress_skid_ready,
			in_data => memb_waddress_skid_data,
		
			out_valid => m_axil_memb_awvalid,
			out_ready => m_axil_memb_awready,
			out_data => m_axil_memb_awaddr
		);
	
	pc_debug <= unsigned(pc(29 downto 0)) & "00";
				
	clock_process : process(clock) is
	begin
		if rising_edge(clock) then
			pc <= pc_next;
			registers(0) <= x"00000000";
			registers(31 downto 1) <= registers_next(31 downto 1);
			cp0_registers <= cp0_registers_next;
			
			load_pending <= load_pending_next;
			load_pending_reg <= load_pending_reg_next;
			load_type <= load_type_next;
			load_address <= load_address_next;
			
			panic <= panic_next;
			address_error_exception <= address_error_exception_next;
									
			register_out <= register_out_next;
			
			force_fetch <= force_fetch_next;
		end if;
	end process;
		
	ctrl_process : process(resetn,
			enable,
			load_address,
			pc_next,
			instruction_data_skid_data,
			instruction_data_skid_valid,
			pc,
			registers,
			cp0_registers,
			load_pending,
			load_pending_reg,
			load_type,
			panic,
			register_in,
			register_address,
			register_write,
			address_error_exception,
			load_address_next,
			register_hi,
			register_lo,
			cp0_registers,
			force_fetch,
			instruction_address_skid_ready,
			
			memb_raddress_skid_ready,
			memb_rdata_skid_valid,
			memb_rdata_skid_data,
			memb_waddress_skid_ready,
			memb_wdata_skid_ready
			) is
		variable vinstruction_data : std_logic_vector(31 downto 0);
        variable instruction_data_r : instruction_r_t;
        variable instruction_data_i : instruction_i_t;
        variable instruction_data_j : instruction_j_t;
        variable instruction_data_cop0 : instruction_cop0_t;
        variable vec32 : std_logic_vector(31 downto 0);
        variable vec64 : std_logic_vector(63 downto 0);
		variable vhandshake : BOOLEAN;
	begin
		
		instruction_address_skid_valid <= '0';
		instruction_data_skid_ready <= '0';
			
		-- memb rdata skid
		memb_rdata_skid_ready <= '0';
		-- memb raddress skid
		memb_raddress_skid_data <= (others => '0');
		memb_raddress_skid_valid <= '0';
		-- memb wdata skid
		memb_wdata_skid_data <= (others => '0');
		memb_wdata_skid_valid <= '0';
		memb_wdata_skid_strobe <= "0000";
		-- memb waddress skid
		memb_waddress_skid_data <= (others => '0');
		memb_waddress_skid_valid <= '0';
		
		m_axil_mema_awaddr <= (others => '0');
		m_axil_mema_awprot <= (others => '0');
		m_axil_mema_awvalid <= '0';
		m_axil_mema_wdata <= (others => '0');
		m_axil_mema_wstrb <= (others => '0');
		m_axil_mema_wvalid <= '0';
		m_axil_mema_bready <= '0';
		m_axil_mema_arprot <= (others => '0');
		m_axil_memb_awprot <= (others => '0');
		m_axil_memb_bready <= '1';
		m_axil_memb_arprot <= (others => '0');
		
		-- keep the same state
		pc_next <= pc;
		registers_next <= registers;
		cp0_registers_next <= cp0_registers;		
	
		register_out_next <= (others => '0');
		
		register_lo_next <= register_lo;
		register_hi_next <= register_hi;
		
		load_pending_next <= load_pending;
		load_pending_reg_next <= load_pending_reg;
		load_type_next <= load_type;
		load_address_next <= load_address;
			
		panic_next <= panic;
		address_error_exception_next <= address_error_exception;
					
		force_fetch_next <= force_fetch;
		
		vinstruction_data := instruction_to_slv(instr_noop_opc);
		
		if resetn = '0' then
			pc_next <= x"00000000";
			registers_next <= (others => x"00000000");
			
			register_lo_next <= (others => '0');
			register_hi_next <= (others => '0');
			
			load_pending_next <= FALSE;
			load_pending_reg_next <= "00000";
			load_type_next <= load_type_byte_signed;
			load_address_next <= x"00000000";
			
			panic_next <= '0';
			address_error_exception_next <= '0';
			
			cp0_registers_next <= (others => x"00000000");
			cp0_registers_next(COP0_REGISTER_COUNT) <= x"00000000";
			
			force_fetch_next <= '1';
		elsif enable = '0' then
			-- handle external register read/write
			-- enable select the access to the register file
			if register_address = "00000" then -- use 0 as program counter
				register_out_next <= pc;
			else
				register_out_next <= registers(to_integer(unsigned(register_address)));
			end if;
			
			if register_write = '1' then
				if register_address = "00000" then -- use 0 as program counter
					pc_next <= register_in;
				else
					registers_next(to_integer(unsigned(register_address))) <= register_in;
				end if;
			end if;
		elsif panic = '1' then
			-- do nothing
		elsif force_fetch = '1' then
			-- used for initial instruction fetch
			if instruction_address_skid_ready = '1' then
				instruction_address_skid_valid <= '1';
				force_fetch_next <= '0';
			end if;
		else
			-- increment the clock counter (even though we might not execute anything)
			cp0_registers_next(COP0_REGISTER_COUNT) <= std_logic_vector(unsigned(cp0_registers(COP0_REGISTER_COUNT)) + to_unsigned(1, 32));
			
			if load_pending = TRUE then
				memb_rdata_skid_ready <= '1';
				if memb_rdata_skid_valid = '1' then
					load_pending_next <= FALSE;
					case load_type is
						when load_type_byte_signed =>
							if load_address(1 downto 0) = "00" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= sign_extend(memb_rdata_skid_data(7 downto 0), 32);
							elsif load_address(1 downto 0) = "01" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= sign_extend(memb_rdata_skid_data(15 downto 8), 32);
							elsif load_address(1 downto 0) = "10" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= sign_extend(memb_rdata_skid_data(23 downto 16), 32);
							elsif load_address(1 downto 0) = "11" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= sign_extend(memb_rdata_skid_data(31 downto 24), 32);
							end if;
						when load_type_byte_unsigned =>
							if load_address(1 downto 0) = "00" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= x"000000" & memb_rdata_skid_data(7 downto 0);
							elsif load_address(1 downto 0) = "01" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= x"000000" & memb_rdata_skid_data(15 downto 8);
							elsif load_address(1 downto 0) = "10" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= x"000000" & memb_rdata_skid_data(23 downto 16);
							elsif load_address(1 downto 0) = "11" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= x"000000" & memb_rdata_skid_data(31 downto 24);
							end if;
						when load_type_halfword_signed =>
							if load_address(1 downto 0) = "10" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= sign_extend(memb_rdata_skid_data(31 downto 16), 32);
							else
								registers_next(to_integer(unsigned(load_pending_reg))) <= sign_extend(memb_rdata_skid_data(15 downto 0), 32);
							end if;
						when load_type_halfword_unsigned =>
							if load_address(1 downto 0) = "10" then
								registers_next(to_integer(unsigned(load_pending_reg))) <= x"0000" & memb_rdata_skid_data(31 downto 16);
							else
								registers_next(to_integer(unsigned(load_pending_reg))) <= x"0000" & memb_rdata_skid_data(15 downto 0);
							end if;
						when load_type_word_unsigned =>
							registers_next(to_integer(unsigned(load_pending_reg))) <= memb_rdata_skid_data;
					end case;
				end if;
					
			elsif instruction_data_skid_valid = '1' then -- execute instruction
				
				vinstruction_data := instruction_data_skid_data;
				instruction_data_r := slv_to_instruction_r(vinstruction_data);
				instruction_data_i := slv_to_instruction_i(vinstruction_data);
				instruction_data_j := slv_to_instruction_j(vinstruction_data);
				instruction_data_cop0 := slv_to_instruction_cop0(vinstruction_data);
				
				-- add
				if slv_compare(instruction_to_slv(instr_add_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_s(instruction_data_r.rs) + get_reg_s(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_addu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) + get_reg_u(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_addi_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(get_reg_s(instruction_data_i.rs) + signed(instruction_data_i.immediate));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_addiu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- sub
				elsif slv_compare(instruction_to_slv(instr_sub_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_s(instruction_data_r.rs) - get_reg_s(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_subu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) - get_reg_u(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
			
				-- div	
				elsif slv_compare(instruction_to_slv(instr_div_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						register_lo_next <= std_logic_vector(get_reg_s(instruction_data_r.rs) / get_reg_s(instruction_data_r.rt));
						register_hi_next <= std_logic_vector(get_reg_s(instruction_data_r.rs) mod get_reg_s(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_divu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						register_lo_next <= std_logic_vector(get_reg_u(instruction_data_r.rs) / get_reg_u(instruction_data_r.rt));
						register_hi_next <= std_logic_vector(get_reg_u(instruction_data_r.rs) mod get_reg_u(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- mult
				elsif slv_compare(instruction_to_slv(instr_mult_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						vec64 := std_logic_vector(get_reg_s(instruction_data_r.rs) * get_reg_s(instruction_data_r.rt));
						register_lo_next <= vec64(31 downto 0);
						register_hi_next <= vec64(63 downto 32);
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_multu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						vec64 := std_logic_vector(get_reg_u(instruction_data_r.rs) * get_reg_u(instruction_data_r.rt));
						register_lo_next <= vec64(31 downto 0);
						register_hi_next <= vec64(63 downto 32);
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;				
				elsif slv_compare(instruction_to_slv(instr_noop_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
					
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- and
				elsif slv_compare(instruction_to_slv(instr_and_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) and get_reg_u(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_andi_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(get_reg_u(instruction_data_i.rs) and (unsigned(sign_extend(instruction_data_i.immediate, 32))));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- or
				elsif slv_compare(instruction_to_slv(instr_or_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) or get_reg_u(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_ori_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(get_reg_u(instruction_data_i.rs) + (unsigned(sign_extend(instruction_data_i.immediate, 32))));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- xor
				elsif slv_compare(instruction_to_slv(instr_xor_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) xor get_reg_u(instruction_data_r.rt));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_xori_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) xor (unsigned(sign_extend(instruction_data_i.immediate, 32))));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				
				-- shift left							
				elsif slv_compare(instruction_to_slv(instr_sll_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) sll to_integer(unsigned(instruction_data_r.shamt)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_sllv_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) sll to_integer(get_reg_u(instruction_data_r.rs)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- shift left
				elsif slv_compare(instruction_to_slv(instr_sra_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						--registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_s(instruction_data_r.rt) sra to_integer(unsigned(instruction_data_r.shamt)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_srl_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) srl to_integer(unsigned(instruction_data_r.shamt)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_srlv_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) srl to_integer(get_reg_u(instruction_data_r.rs)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- set	
				elsif slv_compare(instruction_to_slv(instr_slt_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_s(instruction_data_r.rs) < get_reg_s(instruction_data_r.rt) then
							registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(1, 32));
						else
							registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(0, 32));
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_sltu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_r.rs) < get_reg_u(instruction_data_r.rt) then
							registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(1, 32));
						else
							registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(0, 32));
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_slti_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_s(instruction_data_i.rs) < signed(instruction_data_i.immediate) then
							registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(1, 32));
						else
							registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(0, 32));
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_sltiu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) < unsigned(instruction_data_i.immediate) then
							registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(1, 32));
						else
							registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(0, 32));
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
																													
				-- branch
				elsif slv_compare(instruction_to_slv(instr_beq_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) = get_reg_u(instruction_data_i.rt) then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_bgez_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) >= 0 then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_bgezal_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) >= 0 then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_bgtz_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) > 0 then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_blez_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) <= 0 then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_bltz_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) < 0 then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_bltzal_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) < 0 then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_bne_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if get_reg_u(instruction_data_i.rs) /= get_reg_u(instruction_data_i.rt) then
							pc_next <= std_logic_vector(unsigned(pc) + (unsigned(instruction_data_i.immediate) & "00"));
							--instruction_data_skid_discard <= '1';
						else
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						end if;
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				-- jump
				elsif slv_compare(instruction_to_slv(instr_j_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						pc_next <= pc(31 downto 28) & instruction_data_j.address & "00";
						--instruction_data_skid_discard <= '1';
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_jal_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						pc_next <= pc(31 downto 28) & instruction_data_j.address & "00";
						registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
						--instruction_data_skid_discard <= '1';
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_jalr_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						pc_next <= std_logic_vector(get_reg_u(instruction_data_i.rs)(31 downto 2)) & "00";
						registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
						--instruction_data_skid_discard <= '1';
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_jr_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						pc_next <= std_logic_vector(get_reg_u(instruction_data_i.rs)(31 downto 2)) & "00";
						--instruction_data_skid_discard <= '1';
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				
				-- load
				elsif slv_compare(instruction_to_slv(instr_lb_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));	
						
						memb_raddress_skid_data <= vec32(31 downto 2) & "00";
						memb_raddress_skid_valid <= '1';
												
						load_type_next <= load_type_byte_signed;
						load_pending_reg_next <= instruction_data_i.rt;
						load_pending_next <= TRUE;
						load_address_next <= vec32;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_lbu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						
						memb_raddress_skid_data <= vec32(31 downto 2) & "00";
						memb_raddress_skid_valid <= '1';
												
						load_type_next <= load_type_byte_unsigned;
						load_pending_reg_next <= instruction_data_i.rt;
						load_pending_next <= TRUE;
						load_address_next <= vec32;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_lh_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						if vec32(0) /= '0' then
							address_error_exception_next <= '1';
							panic_next <= '1';
						else
							load_address_next <= vec32;
							
							memb_raddress_skid_data <= vec32(31 downto 2) & "00";
							memb_raddress_skid_valid <= '1';
													
							load_type_next <= load_type_halfword_signed;
							load_pending_reg_next <= instruction_data_i.rt;
							load_pending_next <= TRUE;
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_lhu_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						if vec32(0) /= '0' then
							address_error_exception_next <= '1';
							panic_next <= '1';
						else
							load_address_next <= vec32;
							
							memb_raddress_skid_data <= vec32(31 downto 2) & "00";
							memb_raddress_skid_valid <= '1';
													
							load_type_next <= load_type_halfword_unsigned;
							load_pending_reg_next <= instruction_data_i.rt;
							load_pending_next <= TRUE;
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_lui_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_i.rt))) <= instruction_data_i.immediate & x"0000";
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_lw_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						if vec32(1 downto 0) /= "00" then
							address_error_exception_next <= '1';
							panic_next <= '1';
						else
								
							memb_raddress_skid_data <= vec32(31 downto 2) & "00";
							memb_raddress_skid_valid <= '1';
														
							load_type_next <= load_type_word_unsigned;
							load_pending_reg_next <= instruction_data_i.rt;
							load_pending_next <= TRUE;
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_mfhi_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= register_hi;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_mflo_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_r.rd))) <= register_lo;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_mthi_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						register_hi_next <= registers(to_integer(unsigned(instruction_data_r.rs)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_mtlo_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						register_lo_next <= registers(to_integer(unsigned(instruction_data_r.rs)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_sb_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						--mem_port_b_processor.enable <= '1';
						if vec32(1 downto 0) = "00" then
							
							memb_waddress_skid_data <= vec32(31 downto 2) & "00";
							memb_waddress_skid_valid <= '1';
							memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt));
							memb_wdata_skid_strobe <= "0001";
							memb_wdata_skid_valid <= '1';
							
						elsif vec32(1 downto 0) = "01" then
							
							memb_waddress_skid_data <= vec32(31 downto 2) & "00";
							memb_waddress_skid_valid <= '1';
							memb_wdata_skid_data <= x"0000" & std_logic_vector(get_reg_u(instruction_data_i.rt)(7 downto 0)) & x"00";
							memb_wdata_skid_strobe <= "0010";
							memb_wdata_skid_valid <= '1';
							
						elsif vec32(1 downto 0) = "10" then
							
							memb_waddress_skid_data <= vec32(31 downto 2) & "00";
							memb_waddress_skid_valid <= '1';
							memb_wdata_skid_data <= x"00" & std_logic_vector(get_reg_u(instruction_data_i.rt)(7 downto 0)) & x"0000";
							memb_wdata_skid_strobe <= "0100";
							memb_wdata_skid_valid <= '1';
							
						elsif vec32(1 downto 0) = "11" then
							
							memb_waddress_skid_data <= vec32(31 downto 2) & "00";
							memb_waddress_skid_valid <= '1';
							memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt)(7 downto 0)) & x"000000";
							memb_wdata_skid_strobe <= "1000";
							memb_wdata_skid_valid <= '1';
							
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_sh_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						--mem_port_b_processor.enable <= '1';
						if vec32(0) /= '0' then
							-- address exception
							panic_next <= '1';
						end if;
						
						memb_waddress_skid_data <= vec32(31 downto 1) & '0';
						memb_waddress_skid_valid <= '1';
						if vec32(1) = '0' then
							memb_wdata_skid_data <= x"0000" & std_logic_vector(get_reg_u(instruction_data_i.rt)(15 downto 0));
							memb_wdata_skid_strobe <= "0011";
						else
							memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt)(15 downto 0)) & x"0000";
							memb_wdata_skid_strobe <= "1100";
						end if;
						memb_wdata_skid_valid <= '1';
						
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_sw_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
						vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						if vec32(1 downto 0) /= "00" then
							address_error_exception_next <= '1';
							panic_next <= '1';
						else
								
							memb_waddress_skid_data <= vec32(31 downto 2) & "00";
							memb_waddress_skid_valid <= '1';
							memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt));
							memb_wdata_skid_strobe <= "1111";
							memb_wdata_skid_valid <= '1';
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_mfc0_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						registers_next(to_integer(unsigned(instruction_data_cop0.rt))) <= cp0_registers(to_integer(unsigned(instruction_data_cop0.rd)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				elsif slv_compare(instruction_to_slv(instr_mtc0_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
					-- /!\ This is not exact should handle sel field
						cp0_registers_next(to_integer(unsigned(instruction_data_cop0.rd))) <= registers(to_integer(unsigned(instruction_data_cop0.rt)));
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
					
				-- syscall
				elsif slv_compare(instruction_to_slv(instr_syscall_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
					-- does nothing for now
				elsif slv_compare(instruction_to_slv(instr_break_opc), vinstruction_data) then
					if instruction_address_skid_ready = '1' then
						if cp0_registers(COP0_REGISTER_STATUS)(0) = '1' and cp0_registers(COP0_REGISTER_STATUS)(1) = '0' then
							cp0_registers_next(COP0_REGISTER_CAUSE)(31) <= '0';
							cp0_registers_next(COP0_REGISTER_CAUSE)(6 downto 2) <= COP0_EXCCODE_BP;
							cp0_registers_next(COP0_REGISTER_EPC) <= pc;
						end if;
						pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
						instruction_address_skid_valid <= '1';
						instruction_data_skid_ready <= '1';
					end if;
				else
					-- exception
					panic_next <= '1';
				end if;
			end if;
		end if;
	end process;
	
end mips_execution_unit_behavioral;
