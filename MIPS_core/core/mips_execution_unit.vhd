-- 
--  Copyright (C) 2022 jobmarley
-- 
--  This file is part of MIPS_core.
-- 
--  This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
--  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
--  You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
--  

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
	register_address : in std_logic_vector(5 downto 0);
	
	breakpoint : out std_logic;
	
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
	
	-- this is full AXI4 because we need support for exclusive access for atomic operations
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
	
	function instruction_cmp(i : instruction_r_t; i2 : std_logic_vector) return BOOLEAN is
	begin
		if (i.opcode = i2(31 downto 26)) and (i.funct = i2(5 downto 0)) then
			return TRUE;
		else
			return FALSE;
		end if;
	end function;
	
	function instruction_cmp(i : instruction_i_t; i2 : std_logic_vector) return BOOLEAN is
	begin
		if (i.opcode = i2(31 downto 26)) then
			return TRUE;
		else
			return FALSE;
		end if;
	end function;
	
	function instruction_cmp(i : instruction_j_t; i2 : std_logic_vector) return BOOLEAN is
	begin
		if (i.opcode = i2(31 downto 26)) then
			return TRUE;
		else
			return FALSE;
		end if;
	end function;
	
	function instruction_cmp(i : instruction_cop0_t; i2 : std_logic_vector) return BOOLEAN is
	begin
		if (i.opcode = i2(31 downto 26)) and (i.funct = i2(25 downto 21)) then
			return TRUE;
		else
			return FALSE;
		end if;
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
	
	function shift_right_arith(data : std_logic_vector; n : NATURAL) return std_logic_vector is
		variable result : std_logic_vector(data'range);
	begin
		for i in 0 to data'LENGTH-1 loop
			if i + n < data'LENGTH then
				result(i) := data(i + n);
			else
				result(i) := data(data'LENGTH-1);
			end if;
		end loop;
		return result;
	end function;
	constant instr_add_opc : instruction_r_t := ( opcode => "000000", funct => "100000", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_addu_opc : instruction_r_t := ( opcode => "000000", funct => "100001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_addi_opc : instruction_i_t := ( opcode => "001000", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_addiu_opc : instruction_i_t := ( opcode => "001001", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_and_opc : instruction_r_t := ( opcode => "000000", funct => "100100", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_andi_opc : instruction_i_t := ( opcode => "001100", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_div_opc : instruction_r_t := ( opcode => "000000", funct => "011010", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_divu_opc : instruction_r_t := ( opcode => "000000", funct => "011011", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_mul_opc : instruction_r_t := ( opcode => "011100", funct => "000010", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_mult_opc : instruction_r_t := ( opcode => "000000", funct => "011000", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_multu_opc : instruction_r_t := ( opcode => "000000", funct => "011001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_madd_opc : instruction_r_t := ( opcode => "011100", funct => "000000", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_maddu_opc : instruction_r_t := ( opcode => "011100", funct => "000001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_msub_opc : instruction_r_t := ( opcode => "011100", funct => "000100", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
	constant instr_msubu_opc : instruction_r_t := ( opcode => "011100", funct => "000101", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '0') );
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
	constant instr_nor_opc : instruction_r_t := ( opcode => "000000", funct => "100111", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	
	constant instr_slt_opc : instruction_r_t := ( opcode => "000000", funct => "101010", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_slti_opc : instruction_i_t := ( opcode => "001010", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_sltiu_opc : instruction_i_t := ( opcode => "001011", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_sltu_opc : instruction_r_t := ( opcode => "000000", funct => "101011", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	
	constant instr_clo_opc : instruction_r_t := ( opcode => "011100", funct => "100001", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_clz_opc : instruction_r_t := ( opcode => "011100", funct => "100000", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	
	
	constant instr_beq_opc : instruction_i_t := ( opcode => "000100", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_beql_opc : instruction_i_t := ( opcode => "010100", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_bltz_opc : instruction_i_t := ( opcode => "000001", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_bltzl_opc : instruction_i_t := ( opcode => "000001", rt => "00010", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00010
	constant instr_bltzal_opc : instruction_i_t := ( opcode => "000001", rt => "10000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 10000
	constant instr_bltzall_opc : instruction_i_t := ( opcode => "000001", rt => "10010", rs => (others => '-'), immediate => (others => '-') );	-- rt is 10010
	constant instr_bgez_opc : instruction_i_t := ( opcode => "000001", rt => "00001", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00001
	constant instr_bgezl_opc : instruction_i_t := ( opcode => "000001", rt => "00011", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00011
	constant instr_bgezal_opc : instruction_i_t := ( opcode => "000001", rt => "10001", rs => (others => '-'), immediate => (others => '-') );	-- rt is 10001
	constant instr_bgezall_opc : instruction_i_t := ( opcode => "000001", rt => "10011", rs => (others => '-'), immediate => (others => '-') );	-- rt is 10011
	constant instr_bgtz_opc : instruction_i_t := ( opcode => "000111", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_bgtzl_opc : instruction_i_t := ( opcode => "010111", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_blez_opc : instruction_i_t := ( opcode => "000110", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_blezl_opc : instruction_i_t := ( opcode => "010110", rt => "00000", rs => (others => '-'), immediate => (others => '-') );	-- rt is 00000
	constant instr_bne_opc : instruction_i_t := ( opcode => "000101", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_bnel_opc : instruction_i_t := ( opcode => "010101", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );

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
	constant instr_sc_opc : instruction_i_t := ( opcode => "111000", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_mfc0_opc : instruction_cop0_t := ( opcode => "010000", funct => "00000", rt => (others => '-'), rd => (others => '-'), zero => (others => '0'), sel => "---" );
	constant instr_mtc0_opc : instruction_cop0_t := ( opcode => "010000", funct => "00100", rt => (others => '-'), rd => (others => '-'), zero => (others => '0'), sel => "---" );
	constant instr_ll_opc : instruction_i_t := ( opcode => "110000", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_lwl_opc : instruction_i_t := ( opcode => "100010", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_lwr_opc : instruction_i_t := ( opcode => "100110", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_swl_opc : instruction_i_t := ( opcode => "101010", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_swr_opc : instruction_i_t := ( opcode => "101110", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_movn_opc : instruction_r_t := ( opcode => "000000", funct => "001011", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_movz_opc : instruction_r_t := ( opcode => "000000", funct => "001010", shamt => (others => '0'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	
	constant instr_syscall_opc : instruction_r_t := ( opcode => "000000", funct => "001100", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_break_opc : instruction_r_t := ( opcode => "000000", funct => "001101", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
	constant instr_sdbbp_opc : instruction_r_t := ( opcode => "011100", funct => "111111", shamt => (others => '-'), rs => (others => '-'), rt => (others => '-'), rd => (others => '-') );
		
	constant instr_cache_opc : instruction_i_t := ( opcode => "101111", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_pref_opc : instruction_i_t := ( opcode => "110011", rt => (others => '-'), rs => (others => '-'), immediate => (others => '-') );
	constant instr_sync_opc : instruction_r_t := ( opcode => "000000", funct => "001111", shamt => (others => '-'), rs => (others => '0'), rt => (others => '0'), rd => (others => '0') );
	constant instr_deret_opc : instruction_r_t := ( opcode => "010000", funct => "011111", shamt => (others => '0'), rs => "10000", rt => (others => '0'), rd => (others => '0') );
	constant instr_eret_opc : instruction_r_t := ( opcode => "010000", funct => "011000", shamt => (others => '0'), rs => "10000", rt => (others => '0'), rd => (others => '0') );
	
	-- registers
	signal registers : register_array_t := (others => x"00000000");
	signal registers_next : register_array_t := (others => x"00000000");
	signal registers_pending : std_logic_vector(31 downto 0);
	signal registers_pending_next : std_logic_vector(31 downto 0);
	
	signal cp0_registers : register_array_t := (others => x"00000000");
	signal cp0_registers_next : register_array_t := (others => x"00000000");
	
	signal register_hi : std_logic_vector(31 downto 0) := x"00000000";
	signal register_hi_next : std_logic_vector(31 downto 0) := x"00000000";
	signal register_hi_pending : std_logic;
	signal register_hi_pending_next : std_logic;
	signal register_lo : std_logic_vector(31 downto 0) := x"00000000";
	signal register_lo_next : std_logic_vector(31 downto 0) := x"00000000";
	signal register_lo_pending : std_logic;
	signal register_lo_pending_next : std_logic;
	
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
	function get_reg_id(r : std_logic_vector(4 downto 0)) return NATURAL is
	begin
		return to_integer(unsigned(r)); 
	end function;
			
	type load_type_t is (
		load_type_byte_signed,
		load_type_byte_unsigned,
		load_type_halfword_signed,
		load_type_halfword_unsigned,
		load_type_word_unsigned,
		load_type_word_exclusive,
		load_type_word_left,
		load_type_word_right);
	
	signal load_pending : boolean := FALSE;
	signal load_pending_next : boolean := FALSE;
	signal load_pending_reg : std_logic_vector(4 downto 0);
	signal load_pending_reg_next : std_logic_vector(4 downto 0);
	signal load_type : load_type_t := load_type_byte_signed;
	signal load_type_next : load_type_t := load_type_byte_signed;
	signal load_address : std_logic_vector(31 downto 0) := x"00000000";
	signal load_address_next : std_logic_vector(31 downto 0) := x"00000000";
	signal store_pending : boolean := FALSE;
	signal store_pending_next : boolean := FALSE;
	signal store_pending_reg : std_logic_vector(4 downto 0);
	signal store_pending_reg_next : std_logic_vector(4 downto 0);
	
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
	signal memb_rdata_skid_resp : std_logic_vector(1 downto 0);
	signal memb_rdata_skid_valid : std_logic;
	signal memb_rdata_skid_ready : std_logic;
	-- memb raddress skid
	signal memb_raddress_skid_data : std_logic_vector(31 downto 0);
	signal memb_raddress_skid_lock : std_logic;
	signal memb_raddress_skid_valid : std_logic;
	signal memb_raddress_skid_ready : std_logic;
	-- memb wdata skid
	signal memb_wdata_skid_data : std_logic_vector(31 downto 0);
	signal memb_wdata_skid_strobe : std_logic_vector(3 downto 0);
	signal memb_wdata_skid_valid : std_logic;
	signal memb_wdata_skid_ready : std_logic;
	-- memb waddress skid
	signal memb_waddress_skid_data : std_logic_vector(31 downto 0);
	signal memb_waddress_skid_lock : std_logic;
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
		
	function is_register_pending(i : instruction_r_t; registers_pending : std_logic_vector) return BOOLEAN is
	begin
		if registers_pending(to_integer(unsigned(i.rd))) = '1' or
			registers_pending(to_integer(unsigned(i.rs))) = '1' or
			registers_pending(to_integer(unsigned(i.rt))) = '1' then
			return TRUE;
		else
			return FALSE;
		end if;
	end function;
	function is_register_pending(i : instruction_i_t; registers_pending : std_logic_vector) return BOOLEAN is
	begin
		if registers_pending(to_integer(unsigned(i.rs))) = '1' or
			registers_pending(to_integer(unsigned(i.rt))) = '1' then
			return TRUE;
		else
			return FALSE;
		end if;
	end function;
	
	component mips_alu is
		port (
			clock : in std_logic;
			resetn : in std_logic;
	
			add_in_tready : out std_logic;
			add_in_tvalid : in std_logic;
			add_in_tdata : in std_logic_vector(63 downto 0);
			add_in_tuser : in std_logic_vector(5 downto 0);
			add_out_tready : in std_logic;
			add_out_tvalid : out std_logic;
			add_out_tdata : out std_logic_vector(32 downto 0);
			add_out_tuser : out std_logic_vector(5 downto 0);
		
			sub_in_tready : out std_logic;
			sub_in_tvalid : in std_logic;
			sub_in_tdata : in std_logic_vector(63 downto 0);
			sub_in_tuser : in std_logic_vector(5 downto 0);
			sub_out_tready : in std_logic;
			sub_out_tvalid : out std_logic;
			sub_out_tdata : out std_logic_vector(32 downto 0);
			sub_out_tuser : out std_logic_vector(5 downto 0);
	
			mul_in_tready : out std_logic;
			mul_in_tvalid : in std_logic;
			mul_in_tdata : in std_logic_vector(63 downto 0);
			mul_in_tuser : in std_logic_vector(5 downto 0);
			mul_out_tready : in std_logic;
			mul_out_tvalid : out std_logic;
			mul_out_tdata : out std_logic_vector(63 downto 0);
			mul_out_tuser : out std_logic_vector(5 downto 0);
	
			multu_in_tready : out std_logic;
			multu_in_tvalid : in std_logic;
			multu_in_tdata : in std_logic_vector(63 downto 0);
			multu_in_tuser : in std_logic_vector(5 downto 0);
			multu_out_tready : in std_logic;
			multu_out_tvalid : out std_logic;
			multu_out_tdata : out std_logic_vector(63 downto 0);
			multu_out_tuser : out std_logic_vector(5 downto 0);
	
			div_in_tready : out std_logic;
			div_in_tvalid : in std_logic;
			div_in_tdata : in std_logic_vector(63 downto 0);
			div_in_tuser : in std_logic_vector(5 downto 0);
			div_out_tready : in std_logic;
			div_out_tvalid : out std_logic;
			div_out_tdata : out std_logic_vector(63 downto 0);
			div_out_tuser : out std_logic_vector(5 downto 0);
	
			divu_in_tready : out std_logic;
			divu_in_tvalid : in std_logic;
			divu_in_tdata : in std_logic_vector(63 downto 0);
			divu_in_tuser : in std_logic_vector(5 downto 0);
			divu_out_tready : in std_logic;
			divu_out_tvalid : out std_logic;
			divu_out_tdata : out std_logic_vector(63 downto 0);
			divu_out_tuser : out std_logic_vector(5 downto 0);
	
			multadd_in_tready : out std_logic;
			multadd_in_tvalid : in std_logic;
			multadd_in_tdata : in std_logic_vector(128 downto 0);
			multadd_in_tuser : in std_logic_vector(5 downto 0);
			multadd_out_tready : in std_logic;
			multadd_out_tvalid : out std_logic;
			multadd_out_tdata : out std_logic_vector(63 downto 0);
			multadd_out_tuser : out std_logic_vector(5 downto 0);
	
			multaddu_in_tready : out std_logic;
			multaddu_in_tvalid : in std_logic;
			multaddu_in_tdata : in std_logic_vector(128 downto 0);
			multaddu_in_tuser : in std_logic_vector(5 downto 0);
			multaddu_out_tready : in std_logic;
			multaddu_out_tvalid : out std_logic;
			multaddu_out_tdata : out std_logic_vector(63 downto 0);
			multaddu_out_tuser : out std_logic_vector(5 downto 0)
		);
	end component;
	
	signal add_in_tready : std_logic;
	signal add_in_tvalid : std_logic;
	signal add_in_tdata : std_logic_vector(63 downto 0);
	signal add_in_tuser : std_logic_vector(5 downto 0);
	signal add_out_tready : std_logic;
	signal add_out_tvalid : std_logic;
	signal add_out_tdata : std_logic_vector(32 downto 0);
	signal add_out_tuser : std_logic_vector(5 downto 0);
		
	signal sub_in_tready : std_logic;
	signal sub_in_tvalid : std_logic;
	signal sub_in_tdata : std_logic_vector(63 downto 0);
	signal sub_in_tuser : std_logic_vector(5 downto 0);
	signal sub_out_tready : std_logic;
	signal sub_out_tvalid : std_logic;
	signal sub_out_tdata : std_logic_vector(32 downto 0);
	signal sub_out_tuser : std_logic_vector(5 downto 0);
	
	signal mul_in_tready : std_logic;
	signal mul_in_tvalid : std_logic;
	signal mul_in_tdata : std_logic_vector(63 downto 0);
	signal mul_in_tuser : std_logic_vector(5 downto 0);
	signal mul_out_tready : std_logic;
	signal mul_out_tvalid : std_logic;
	signal mul_out_tdata : std_logic_vector(63 downto 0);
	signal mul_out_tuser : std_logic_vector(5 downto 0);
	
	signal multu_in_tready : std_logic;
	signal multu_in_tvalid : std_logic;
	signal multu_in_tdata : std_logic_vector(63 downto 0);
	signal multu_in_tuser : std_logic_vector(5 downto 0);
	signal multu_out_tready : std_logic;
	signal multu_out_tvalid : std_logic;
	signal multu_out_tdata : std_logic_vector(63 downto 0);
	signal multu_out_tuser : std_logic_vector(5 downto 0);
	
	signal div_in_tready : std_logic;
	signal div_in_tvalid : std_logic;
	signal div_in_tdata : std_logic_vector(63 downto 0);
	signal div_in_tuser : std_logic_vector(5 downto 0);
	signal div_out_tready : std_logic;
	signal div_out_tvalid : std_logic;
	signal div_out_tdata : std_logic_vector(63 downto 0);
	signal div_out_tuser : std_logic_vector(5 downto 0);
	
	signal divu_in_tready : std_logic;
	signal divu_in_tvalid : std_logic;
	signal divu_in_tdata : std_logic_vector(63 downto 0);
	signal divu_in_tuser : std_logic_vector(5 downto 0);
	signal divu_out_tready : std_logic;
	signal divu_out_tvalid : std_logic;
	signal divu_out_tdata : std_logic_vector(63 downto 0);
	signal divu_out_tuser : std_logic_vector(5 downto 0);
	
	signal multadd_in_tready : std_logic;
	signal multadd_in_tvalid : std_logic;
	signal multadd_in_tdata : std_logic_vector(128 downto 0);
	signal multadd_in_tuser : std_logic_vector(5 downto 0);
	signal multadd_out_tready : std_logic;
	signal multadd_out_tvalid : std_logic;
	signal multadd_out_tdata : std_logic_vector(63 downto 0);
	signal multadd_out_tuser : std_logic_vector(5 downto 0);
	
	signal multaddu_in_tready : std_logic;
	signal multaddu_in_tvalid : std_logic;
	signal multaddu_in_tdata : std_logic_vector(128 downto 0);
	signal multaddu_in_tuser : std_logic_vector(5 downto 0);
	signal multaddu_out_tready : std_logic;
	signal multaddu_out_tvalid : std_logic;
	signal multaddu_out_tdata : std_logic_vector(63 downto 0);
	signal multaddu_out_tuser : std_logic_vector(5 downto 0);
begin
	
    m_axi_memb_arburst <= "00";
    m_axi_memb_awburst <= "00";
    m_axi_memb_arsize <= "010";	-- 32bits
    m_axi_memb_awsize <= "010";	-- 32bits
    m_axi_memb_arlen <= x"00";	-- 1 beat
    m_axi_memb_awlen <= x"00";	-- 1 beat
    m_axi_memb_wlast <= '1';
    m_axi_memb_arprot <= "000";
    m_axi_memb_awprot <= "000";
    m_axi_memb_arcache <= "0000";
    m_axi_memb_awcache <= "0000";
	
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
		generic map(data_width => 32 + 2) -- rdata + rresp
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => m_axi_memb_rvalid,
			in_ready => m_axi_memb_rready,
			in_data(31 downto 0) => m_axi_memb_rdata,
			in_data(33 downto 32) => m_axi_memb_rresp,
		
			out_valid => memb_rdata_skid_valid,
			out_ready => memb_rdata_skid_ready,
			out_data(31 downto 0) => memb_rdata_skid_data,
			out_data(33 downto 32) => memb_rdata_skid_resp
		);
	memb_raddress_skid : skid_buffer
		generic map(data_width => 32 + 1) -- address + lock
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => memb_raddress_skid_valid,
			in_ready => memb_raddress_skid_ready,
			in_data(31 downto 0) => memb_raddress_skid_data,
			in_data(32) => memb_raddress_skid_lock,
		
			out_valid => m_axi_memb_arvalid,
			out_ready => m_axi_memb_arready,
			out_data(31 downto 0) => m_axi_memb_araddr,
			out_data(32) => m_axi_memb_arlock
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
		
			out_valid => m_axi_memb_wvalid,
			out_ready => m_axi_memb_wready,
			out_data(31 downto 0) => m_axi_memb_wdata,
			out_data(35 downto 32) => m_axi_memb_wstrb	
		);
	memb_waddress_skid : skid_buffer
		generic map(data_width => 32 + 1) -- address + lock
		port map(
			resetn => resetn,
			clock => clock,
	
			in_valid => memb_waddress_skid_valid,
			in_ready => memb_waddress_skid_ready,
			in_data(31 downto 0) => memb_waddress_skid_data,
			in_data(32) => memb_waddress_skid_lock,
		
			out_valid => m_axi_memb_awvalid,
			out_ready => m_axi_memb_awready,
			out_data(31 downto 0) => m_axi_memb_awaddr,
			out_data(32) => m_axi_memb_awlock
		);
					
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
			store_pending <= store_pending_next;
			store_pending_reg <= store_pending_reg_next;
			
			panic <= panic_next;
			address_error_exception <= address_error_exception_next;
									
			register_out <= register_out_next;
			
			force_fetch <= force_fetch_next;
			
			registers_pending <= registers_pending_next;
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
			store_pending,
			store_pending_reg,
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
			memb_rdata_skid_resp,
			memb_waddress_skid_ready,
			memb_wdata_skid_ready,
		
			m_axi_memb_bvalid,
			m_axi_memb_bresp,
		
			registers_pending,
			register_hi_pending,
			register_lo_pending,
			add_out_tvalid,
			sub_out_tvalid,
			mul_out_tvalid,
			multu_out_tvalid,
			div_out_tvalid,
			divu_out_tvalid,
			multadd_out_tvalid,
			multaddu_out_tvalid,
			add_out_tdata,
			sub_out_tdata,
			mul_out_tdata,
			multu_out_tdata,
			div_out_tdata,
			divu_out_tdata,
			multadd_out_tdata,
			multaddu_out_tdata,
			add_in_tready,
			sub_in_tready,
			mul_in_tready,
			multu_in_tready,
			div_in_tready,
			divu_in_tready,
			multadd_in_tready,
			multaddu_in_tready,
			mul_out_tuser
			) is
		variable vinstruction_data : std_logic_vector(31 downto 0);
        variable instruction_data_r : instruction_r_t;
        variable instruction_data_i : instruction_i_t;
        variable instruction_data_j : instruction_j_t;
        variable instruction_data_cop0 : instruction_cop0_t;
        variable vec32 : std_logic_vector(31 downto 0);
        variable vec64 : std_logic_vector(63 downto 0);
		variable vhandshake : BOOLEAN;
		variable vzero_count : NATURAL;
		variable vregister_id : NATURAL;
		variable vinstruction_handled : BOOLEAN;
	begin
		
		instruction_address_skid_valid <= '0';
		instruction_data_skid_ready <= '0';
		memb_raddress_skid_lock <= '0';
		memb_waddress_skid_lock <= '0';
			
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
		m_axi_memb_awprot <= (others => '0');
		m_axi_memb_bready <= '1';
		m_axi_memb_arprot <= (others => '0');
		
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
		store_pending_next <= store_pending;
		store_pending_reg_next <= store_pending_reg;
		
			
		panic_next <= panic;
		address_error_exception_next <= address_error_exception;
					
		force_fetch_next <= force_fetch;
		
		registers_pending_next <= registers_pending;
		register_hi_pending_next <= register_hi_pending;
		register_lo_pending_next <= register_lo_pending;
		
		vinstruction_data := instruction_to_slv(instr_noop_opc);
		
		breakpoint <= '0';
		
		add_out_tready <= '0';
		add_in_tvalid <= '0';
		add_in_tuser <= (others => '0');
		add_in_tdata <= (others => '0');
		sub_out_tready <= '0';
		sub_in_tvalid <= '0';
		sub_in_tuser <= (others => '0');
		sub_in_tdata <= (others => '0');
		mul_out_tready <= '0';
		mul_in_tvalid <= '0';
		mul_in_tuser <= (others => '0');
		mul_in_tdata <= (others => '0');
		multu_out_tready <= '0';
		multu_in_tvalid <= '0';
		multu_in_tuser <= (others => '0');
		multu_in_tdata <= (others => '0');
		div_out_tready <= '0';
		div_in_tvalid <= '0';
		div_in_tuser <= (others => '0');
		div_in_tdata <= (others => '0');
		divu_out_tready <= '0';
		divu_in_tvalid <= '0';
		divu_in_tuser <= (others => '0');
		divu_in_tdata <= (others => '0');
		multadd_out_tready <= '0';
		multadd_in_tvalid <= '0';
		multadd_in_tuser <= (others => '0');
		multadd_in_tdata <= (others => '0');
		multaddu_out_tready <= '0';
		multaddu_in_tvalid <= '0';
		multaddu_in_tuser <= (others => '0');
		multaddu_in_tdata <= (others => '0');
		
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
			
			registers_pending_next <= (others => '0');
			register_hi_pending_next <= '0';
			register_lo_pending_next <= '0';
		else
			
			-- handle pending alu
			if add_out_tvalid = '1' then
				add_out_tready <= '1';
				registers_pending_next(get_reg_id(add_out_tuser(4 downto 0))) <= '0';
				registers_next(get_reg_id(add_out_tuser(4 downto 0))) <= add_out_tdata(31 downto 0);
			end if;
			if sub_out_tvalid = '1' then
				sub_out_tready <= '1';
				registers_pending_next(get_reg_id(sub_out_tuser(4 downto 0))) <= '0';
				registers_next(get_reg_id(sub_out_tuser(4 downto 0))) <= sub_out_tdata(31 downto 0);
			end if;
			if mul_out_tvalid = '1' then
				mul_out_tready <= '1';
				if mul_out_tuser(5) = '1' then
					registers_pending_next(get_reg_id(mul_out_tuser(4 downto 0))) <= '0';
					registers_next(get_reg_id(mul_out_tuser(4 downto 0))) <= mul_out_tdata(31 downto 0);
				else
					register_hi_pending_next <= '0';
					register_lo_pending_next <= '0';
					register_lo_next <= mul_out_tdata(63 downto 32);
					register_hi_next <= mul_out_tdata(31 downto 0);
				end if;
			end if;
			if multu_out_tvalid = '1' then
				multu_out_tready <= '1';
				register_hi_pending_next <= '0';
				register_lo_pending_next <= '0';
				register_lo_next <= multu_out_tdata(63 downto 32);
				register_hi_next <= multu_out_tdata(31 downto 0);
			end if;
			if div_out_tvalid = '1' then
				div_out_tready <= '1';
				register_hi_pending_next <= '0';
				register_lo_pending_next <= '0';
				register_lo_next <= div_out_tdata(63 downto 32);
				register_hi_next <= div_out_tdata(31 downto 0);
			end if;
			if divu_out_tvalid = '1' then
				divu_out_tready <= '1';
				register_hi_pending_next <= '0';
				register_lo_pending_next <= '0';
				register_lo_next <= divu_out_tdata(63 downto 32);
				register_hi_next <= divu_out_tdata(31 downto 0);
			end if;
			if multadd_out_tvalid = '1' then
				multadd_out_tready <= '1';
				register_hi_pending_next <= '0';
				register_lo_pending_next <= '0';
				register_lo_next <= multadd_out_tdata(63 downto 32);
				register_hi_next <= multadd_out_tdata(31 downto 0);
			end if;
			if multaddu_out_tvalid = '1' then
				multaddu_out_tready <= '1';
				register_hi_pending_next <= '0';
				register_lo_pending_next <= '0';
				register_lo_next <= multaddu_out_tdata(63 downto 32);
				register_hi_next <= multaddu_out_tdata(31 downto 0);
			end if;
			
			-- handle the pending load operation
			if load_pending = TRUE then
				memb_rdata_skid_ready <= '1';
				if memb_rdata_skid_valid = '1' then
					
					-- read complete, no more load pending, and free the pending register
					load_pending_next <= FALSE;
					vregister_id := to_integer(unsigned(load_pending_reg));
					registers_pending_next(vregister_id) <= '0';
					
					case load_type is
						when load_type_byte_signed =>
							if load_address(1 downto 0) = "00" then
								registers_next(vregister_id) <= sign_extend(memb_rdata_skid_data(7 downto 0), 32);
							elsif load_address(1 downto 0) = "01" then
								registers_next(vregister_id) <= sign_extend(memb_rdata_skid_data(15 downto 8), 32);
							elsif load_address(1 downto 0) = "10" then
								registers_next(vregister_id) <= sign_extend(memb_rdata_skid_data(23 downto 16), 32);
							elsif load_address(1 downto 0) = "11" then
								registers_next(vregister_id) <= sign_extend(memb_rdata_skid_data(31 downto 24), 32);
							end if;
						when load_type_byte_unsigned =>
							if load_address(1 downto 0) = "00" then
								registers_next(vregister_id) <= x"000000" & memb_rdata_skid_data(7 downto 0);
							elsif load_address(1 downto 0) = "01" then
								registers_next(vregister_id) <= x"000000" & memb_rdata_skid_data(15 downto 8);
							elsif load_address(1 downto 0) = "10" then
								registers_next(vregister_id) <= x"000000" & memb_rdata_skid_data(23 downto 16);
							elsif load_address(1 downto 0) = "11" then
								registers_next(vregister_id) <= x"000000" & memb_rdata_skid_data(31 downto 24);
							end if;
						when load_type_halfword_signed =>
							if load_address(1 downto 0) = "10" then
								registers_next(vregister_id) <= sign_extend(memb_rdata_skid_data(31 downto 16), 32);
							else
								registers_next(vregister_id) <= sign_extend(memb_rdata_skid_data(15 downto 0), 32);
							end if;
						when load_type_halfword_unsigned =>
							if load_address(1 downto 0) = "10" then
								registers_next(vregister_id) <= x"0000" & memb_rdata_skid_data(31 downto 16);
							else
								registers_next(vregister_id) <= x"0000" & memb_rdata_skid_data(15 downto 0);
							end if;
						when load_type_word_unsigned =>
							registers_next(vregister_id) <= memb_rdata_skid_data;
						when load_type_word_exclusive =>
							if memb_rdata_skid_resp /= AXI_RESP_EXOKAY then
								panic_next <= '1';
							end if;
							registers_next(vregister_id) <= memb_rdata_skid_data;
					
						-- NOTE: those two are dependent on endianess
						when load_type_word_left =>
							if load_address(1 downto 0) = "00" then
								registers_next(vregister_id) <= memb_rdata_skid_data(7 downto 0) & registers(vregister_id)(23 downto 0);
							elsif load_address(1 downto 0) = "01" then
								registers_next(vregister_id) <= memb_rdata_skid_data(15 downto 0) & registers(vregister_id)(15 downto 0);
							elsif load_address(1 downto 0) = "10" then
								registers_next(vregister_id) <= memb_rdata_skid_data(23 downto 0) & registers(vregister_id)(7 downto 0);
							elsif load_address(1 downto 0) = "11" then
								registers_next(vregister_id) <= memb_rdata_skid_data;
							end if;
						when load_type_word_right =>
							if load_address(1 downto 0) = "00" then
								registers_next(vregister_id) <= memb_rdata_skid_data;
							elsif load_address(1 downto 0) = "01" then
								registers_next(vregister_id) <= registers(vregister_id)(31 downto 24) & memb_rdata_skid_data(31 downto 8);
							elsif load_address(1 downto 0) = "10" then
								registers_next(vregister_id) <= registers(vregister_id)(31 downto 16) & memb_rdata_skid_data(31 downto 16);
							elsif load_address(1 downto 0) = "11" then
								registers_next(vregister_id) <= registers(vregister_id)(31 downto 8) & memb_rdata_skid_data(31 downto 24);
							end if;
					end case;
				end if;
			end if;
			
			-- handle the pending store operation
			-- this is only used for SC instruction
			if store_pending = TRUE then
				if m_axi_memb_bvalid = '1' then
					store_pending_next <= FALSE;
					vregister_id := to_integer(unsigned(store_pending_reg));
					registers_pending_next(vregister_id) <= '0';
					if m_axi_memb_bresp = AXI_RESP_EXOKAY then
						registers_next(vregister_id) <= x"00000001";
					else
						registers_next(vregister_id) <= x"00000000";
					end if;
				end if;
			end if;
			
			if enable = '0' then
				-- handle external register read/write
				-- enable select the access to the register file
				if register_address = "000000" then -- use 0 as program counter
					register_out_next <= pc;
				elsif register_address(5) = '0' then
					register_out_next <= registers(to_integer(unsigned(register_address(4 downto 0))));
				else
					register_out_next <= cp0_registers(to_integer(unsigned(register_address(4 downto 0))));
				end if;
			
				if register_write = '1' then
					if register_address = "000000" then -- use 0 as program counter
						pc_next <= register_in;
						force_fetch_next <= '1';
					elsif register_address(5) = '0' then
						registers_next(to_integer(unsigned(register_address(4 downto 0)))) <= register_in;
					else
						cp0_registers_next(to_integer(unsigned(register_address(4 downto 0)))) <= register_in;
					end if;
				end if;
			elsif panic = '1' then
				-- do nothing
			elsif force_fetch = '1' then
				-- used for initial instruction fetch
				
				-- make sure there are no pending transactions
				if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' and
					load_pending = FALSE and store_pending = FALSE then
					-- we wait for addresses to be ready to make sure the pending data arrived
					-- then we mark data ready to flush the buffers
					instruction_data_skid_ready <= '1';
					memb_rdata_skid_ready <= '1';
					registers_pending_next <= (others => '0');
					-- reset load/store pending
					load_pending_next <= FALSE;
					store_pending_next <= FALSE;
					-- we write instruction address then go to normal execution
					instruction_address_skid_valid <= '1';
					force_fetch_next <= '0';
				end if;
			else
				-- increment the clock counter (even though we might not execute anything)
				cp0_registers_next(COP0_REGISTER_COUNT) <= std_logic_vector(unsigned(cp0_registers(COP0_REGISTER_COUNT)) + to_unsigned(1, 32));
			
				
			
				if instruction_data_skid_valid = '1' then -- execute instruction
				
					vinstruction_data := instruction_data_skid_data;
					instruction_data_r := slv_to_instruction_r(vinstruction_data);
					instruction_data_i := slv_to_instruction_i(vinstruction_data);
					instruction_data_j := slv_to_instruction_j(vinstruction_data);
					instruction_data_cop0 := slv_to_instruction_cop0(vinstruction_data);
				
					vinstruction_handled := FALSE;
					
					-- add
					-- NOTE: for all unsigned version, it does the same operation but does not trap on overflow
					if instruction_cmp(instr_add_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								add_in_tvalid <= '1';
								add_in_tuser <= '0' & instruction_data_r.rd;
								add_in_tdata <= std_logic_vector(get_reg_u(instruction_data_r.rs) & get_reg_u(instruction_data_r.rt));
								registers_pending_next(get_reg_id(instruction_data_r.rd)) <= '1';
								
								if add_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					if instruction_cmp(instr_addu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								add_in_tvalid <= '1';
								add_in_tuser <= '0' & instruction_data_r.rd;
								add_in_tdata <= std_logic_vector(get_reg_u(instruction_data_r.rs) & get_reg_u(instruction_data_r.rt));
								registers_pending_next(get_reg_id(instruction_data_r.rd)) <= '1';
								
								if add_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					if instruction_cmp(instr_addi_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								add_in_tvalid <= '1';
								add_in_tuser <= '0' & instruction_data_i.rt;
								add_in_tdata <= std_logic_vector(get_reg_u(instruction_data_i.rs) & unsigned(sign_extend(instruction_data_i.immediate, 32)));
								registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								
								if add_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					if instruction_cmp(instr_addiu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								add_in_tvalid <= '1';
								add_in_tuser <= '0' & instruction_data_i.rt;
								add_in_tdata <= std_logic_vector(get_reg_u(instruction_data_i.rs) & unsigned(sign_extend(instruction_data_i.immediate, 32)));
								registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								
								if add_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					-- sub
					if instruction_cmp(instr_sub_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								sub_in_tvalid <= '1';
								sub_in_tuser <= '0' & instruction_data_r.rd;
								sub_in_tdata <= std_logic_vector(get_reg_s(instruction_data_r.rt) & get_reg_s(instruction_data_r.rs));
								registers_pending_next(get_reg_id(instruction_data_r.rd)) <= '1';
								
								if sub_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					if instruction_cmp(instr_subu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								sub_in_tvalid <= '1';
								sub_in_tuser <= '0' & instruction_data_r.rd;
								sub_in_tdata <= std_logic_vector(get_reg_s(instruction_data_r.rt) & get_reg_s(instruction_data_r.rs));
								registers_pending_next(get_reg_id(instruction_data_r.rd)) <= '1';
								
								if sub_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
			
					-- div	
					if instruction_cmp(instr_div_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								div_in_tvalid <= '1';
								div_in_tdata <= std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if div_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					if instruction_cmp(instr_divu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								divu_in_tvalid <= '1';
								divu_in_tdata <= std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if divu_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					-- mult
					if instruction_cmp(instr_mul_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								mul_in_tvalid <= '1';
								mul_in_tdata <= std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								mul_in_tuser <= '1' & instruction_data_r.rd;
								registers_pending_next(get_reg_id(instruction_data_r.rd)) <= '1';
								
								if mul_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					if instruction_cmp(instr_mult_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								mul_in_tvalid <= '1';
								mul_in_tdata <= std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								mul_in_tuser <= (others => '0');
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if mul_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;
					end if;
					if instruction_cmp(instr_multu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								multu_in_tvalid <= '1';
								multu_in_tdata <= std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if multu_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;		
					end if;
					if instruction_cmp(instr_madd_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								multadd_in_tvalid <= '1';
								multadd_in_tdata <= '0' & register_hi & register_lo & std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if multadd_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;	
					end if;
					if instruction_cmp(instr_maddu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								multaddu_in_tvalid <= '1';
								multaddu_in_tdata <= '0' & register_hi & register_lo & std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if multaddu_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;			
					end if;
					if instruction_cmp(instr_msub_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								multadd_in_tvalid <= '1';
								multadd_in_tdata <= '1' & register_hi & register_lo & std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if multadd_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;	
					end if;
					if instruction_cmp(instr_msubu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								multaddu_in_tvalid <= '1';
								multaddu_in_tdata <= '1' & register_hi & register_lo & std_logic_vector(get_reg_s(instruction_data_r.rs) & get_reg_s(instruction_data_r.rt));
								register_hi_pending_next <= '1';
								register_lo_pending_next <= '1';
								
								if multaddu_in_tready = '1' then
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
									instruction_address_skid_valid <= '1';
									instruction_data_skid_ready <= '1';
								end if;
							end if;
						end if;		
					end if;
					if instruction_cmp(instr_noop_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
					
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					-- and
					if instruction_cmp(instr_and_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) and get_reg_u(instruction_data_r.rt));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_andi_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(get_reg_u(instruction_data_i.rs) and (unsigned(sign_extend(instruction_data_i.immediate, 32))));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					-- or
					if instruction_cmp(instr_or_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) or get_reg_u(instruction_data_r.rt));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_ori_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(get_reg_u(instruction_data_i.rs) + (unsigned(sign_extend(instruction_data_i.immediate, 32))));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					-- xor
					if instruction_cmp(instr_xor_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) xor get_reg_u(instruction_data_r.rt));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_xori_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) xor (unsigned(sign_extend(instruction_data_i.immediate, 32))));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					-- nor
					if instruction_cmp(instr_nor_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rs) nor get_reg_u(instruction_data_r.rt));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
				
					-- shift left
					if instruction_cmp(instr_sll_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) sll to_integer(unsigned(instruction_data_r.shamt)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_sllv_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) sll to_integer(get_reg_u(instruction_data_r.rs)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					-- shift left
					if instruction_cmp(instr_sra_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= shift_right_arith(std_logic_vector(get_reg_u(instruction_data_r.rt)), to_integer(unsigned(instruction_data_r.shamt)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_srl_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) srl to_integer(unsigned(instruction_data_r.shamt)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_srlv_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(get_reg_u(instruction_data_r.rt) srl to_integer(get_reg_u(instruction_data_r.rs)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					-- set	
					if instruction_cmp(instr_slt_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								if get_reg_s(instruction_data_r.rs) < get_reg_s(instruction_data_r.rt) then
									registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(1, 32));
								else
									registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(0, 32));
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_sltu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								if get_reg_u(instruction_data_r.rs) < get_reg_u(instruction_data_r.rt) then
									registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(1, 32));
								else
									registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(0, 32));
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_slti_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								if get_reg_s(instruction_data_i.rs) < signed(instruction_data_i.immediate) then
									registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(1, 32));
								else
									registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(0, 32));
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_sltiu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								if get_reg_u(instruction_data_i.rs) < unsigned(instruction_data_i.immediate) then
									registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(1, 32));
								else
									registers_next(to_integer(unsigned(instruction_data_i.rt))) <= std_logic_vector(to_unsigned(0, 32));
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					-- count zero
					if instruction_cmp(instr_clo_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								vzero_count := 32;
								for i in 31 downto 0 loop
									if get_reg_u(instruction_data_r.rs)(i) = '0' then
										vzero_count := 31 - i;
										exit;
									end if;
								end loop;
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(vzero_count, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_clz_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								vzero_count := 32;
								for i in 31 downto 0 loop
									if get_reg_u(instruction_data_r.rs)(i) = '1' then
										vzero_count := 31 - i;
										exit;
									end if;
								end loop;
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= std_logic_vector(to_unsigned(vzero_count, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
																												
					-- branch
					-- NOTE: we are a missing cop branch fp and cop1+ branch because we dont have it
					if instruction_cmp(instr_beq_opc, vinstruction_data) or instruction_cmp(instr_beql_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								if get_reg_u(instruction_data_i.rs) = get_reg_u(instruction_data_i.rt) then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_bgez_opc, vinstruction_data) or instruction_cmp(instr_bgezl_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								if get_reg_u(instruction_data_i.rs) >= 0 then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_bgezal_opc, vinstruction_data) or instruction_cmp(instr_bgezall_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								if get_reg_u(instruction_data_i.rs) >= 0 then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_bgtz_opc, vinstruction_data) or instruction_cmp(instr_bgtzl_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								if get_reg_u(instruction_data_i.rs) > 0 then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_blez_opc, vinstruction_data) or instruction_cmp(instr_blezl_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								if get_reg_u(instruction_data_i.rs) <= 0 then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_bltz_opc, vinstruction_data) or instruction_cmp(instr_bltzl_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								if get_reg_u(instruction_data_i.rs) < 0 then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_bltzal_opc, vinstruction_data) or instruction_cmp(instr_bltzall_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
							
								if get_reg_u(instruction_data_i.rs) < 0 then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_bne_opc, vinstruction_data) or instruction_cmp(instr_bnel_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								if get_reg_u(instruction_data_i.rs) /= get_reg_u(instruction_data_i.rt) then
									pc_next <= std_logic_vector(unsigned(pc) + (unsigned(sign_extend(instruction_data_i.immediate, 30)) & "00"));
									--instruction_data_skid_discard <= '1';
								else
									pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								end if;
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					-- jump
					if instruction_cmp(instr_j_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							vec32 := std_logic_vector(unsigned(pc) + 4);
							pc_next <= vec32(31 downto 28) & instruction_data_j.address & "00";
							--instruction_data_skid_discard <= '1';
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					if instruction_cmp(instr_jal_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							vec32 := std_logic_vector(unsigned(pc) + 4);
							pc_next <= vec32(31 downto 28) & instruction_data_j.address & "00";
							registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
							--instruction_data_skid_discard <= '1';
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					if instruction_cmp(instr_jalr_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							pc_next <= std_logic_vector(get_reg_u(instruction_data_i.rs));
							if get_reg_u(instruction_data_i.rs)(1 downto 0) /= "00" then
								panic_next <= '1';
							end if;
							registers_next(31) <= std_logic_vector(unsigned(pc) + 8);
							--instruction_data_skid_discard <= '1';
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					if instruction_cmp(instr_jr_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							pc_next <= std_logic_vector(get_reg_u(instruction_data_i.rs));
							if get_reg_u(instruction_data_i.rs)(1 downto 0) /= "00" then
								panic_next <= '1';
							end if;
							--instruction_data_skid_discard <= '1';
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
				
					-- load
					if instruction_cmp(instr_lb_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
							
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));	
						
								memb_raddress_skid_data <= vec32(31 downto 2) & "00";
								memb_raddress_skid_valid <= '1';
												
								load_type_next <= load_type_byte_signed;
								load_pending_reg_next <= instruction_data_i.rt;
								load_pending_next <= TRUE;
								load_address_next <= vec32;
								registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_lbu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
							
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						
								memb_raddress_skid_data <= vec32(31 downto 2) & "00";
								memb_raddress_skid_valid <= '1';
												
								load_type_next <= load_type_byte_unsigned;
								load_pending_reg_next <= instruction_data_i.rt;
								load_pending_next <= TRUE;
								load_address_next <= vec32;
								registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_lh_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
						
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
									registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_lhu_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
						
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
									registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_lui_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_i.rt))) <= instruction_data_i.immediate & x"0000";
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_lw_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
							
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
									registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_ll_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
						
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
								if vec32(1 downto 0) /= "00" then
									address_error_exception_next <= '1';
									panic_next <= '1';
								else
								
									memb_raddress_skid_data <= vec32(31 downto 2) & "00";
									memb_raddress_skid_lock <= '1';
									memb_raddress_skid_valid <= '1';
														
									load_type_next <= load_type_word_unsigned;
									load_pending_reg_next <= instruction_data_i.rt;
									load_pending_next <= TRUE;
									registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_mfhi_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= register_hi;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_mflo_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
								registers_next(to_integer(unsigned(instruction_data_r.rd))) <= register_lo;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_mthi_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
							
								register_hi_next <= registers(to_integer(unsigned(instruction_data_r.rs)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_mtlo_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
						
								register_lo_next <= registers(to_integer(unsigned(instruction_data_r.rs)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_lwl_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
						
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						
								memb_raddress_skid_data <= vec32(31 downto 2) & "00";
								memb_raddress_skid_valid <= '1';
														
								load_type_next <= load_type_word_left;
								load_pending_reg_next <= instruction_data_i.rt;
								load_pending_next <= TRUE;
								registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
						
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_lwr_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_raddress_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and load_pending = FALSE then
						
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						
								memb_raddress_skid_data <= vec32(31 downto 2) & "00";
								memb_raddress_skid_valid <= '1';
														
								load_type_next <= load_type_word_right;
								load_pending_reg_next <= instruction_data_i.rt;
								load_pending_next <= TRUE;
								registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
						
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_sb_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
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
						end if;
					end if;
					if instruction_cmp(instr_sh_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
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
						end if;
					end if;
					if instruction_cmp(instr_sw_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
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
						end if;
					end if;
					if instruction_cmp(instr_sc_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE and store_pending = FALSE then
						
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
								if vec32(1 downto 0) /= "00" then
									address_error_exception_next <= '1';
									panic_next <= '1';
								else
								
									memb_waddress_skid_data <= vec32(31 downto 2) & "00";
									memb_waddress_skid_valid <= '1';
									memb_waddress_skid_lock <= '1';
									memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt));
									memb_wdata_skid_strobe <= "1111";
									memb_wdata_skid_valid <= '1';
								end if;
						
								store_pending_reg_next <= instruction_data_i.rt;
								store_pending_next <= TRUE;
								registers_pending_next(get_reg_id(instruction_data_i.rt)) <= '1';
						
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_swl_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						
								memb_waddress_skid_data <= vec32(31 downto 2) & "00";
								memb_waddress_skid_valid <= '1';
						
								if vec32(1 downto 0) = "00" then
									memb_wdata_skid_data <= x"000000" & std_logic_vector(get_reg_u(instruction_data_i.rt)(31 downto 24));
									memb_wdata_skid_strobe <= "0001";
								elsif vec32(1 downto 0) = "01" then
									memb_wdata_skid_data <= x"0000" & std_logic_vector(get_reg_u(instruction_data_i.rt)(31 downto 16));
									memb_wdata_skid_strobe <= "0011";
								elsif vec32(1 downto 0) = "10" then
									memb_wdata_skid_data <= x"00" & std_logic_vector(get_reg_u(instruction_data_i.rt)(31 downto 8));
									memb_wdata_skid_strobe <= "0111";
								elsif vec32(1 downto 0) = "11" then
									memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt));
									memb_wdata_skid_strobe <= "1111";
								end if;
								memb_wdata_skid_valid <= '1';
						
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_swr_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' and memb_waddress_skid_ready = '1' and memb_wdata_skid_ready = '1' then
							if is_register_pending(instruction_data_i, registers_pending) = FALSE then
						
								vec32 := std_logic_vector(get_reg_u(instruction_data_i.rs) + unsigned(sign_extend(instruction_data_i.immediate, 32)));
						
								memb_waddress_skid_data <= vec32(31 downto 2) & "00";
								memb_waddress_skid_valid <= '1';
						
								if vec32(1 downto 0) = "00" then
									memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt));
									memb_wdata_skid_strobe <= "1111";
								elsif vec32(1 downto 0) = "01" then
									memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt)(23 downto 0)) & x"00";
									memb_wdata_skid_strobe <= "1110";
								elsif vec32(1 downto 0) = "10" then
									memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt)(15 downto 0)) & x"0000";
									memb_wdata_skid_strobe <= "1100";
								elsif vec32(1 downto 0) = "11" then
									memb_wdata_skid_data <= std_logic_vector(get_reg_u(instruction_data_i.rt)(7 downto 0)) & x"000000";
									memb_wdata_skid_strobe <= "1000";
								end if;
								memb_wdata_skid_valid <= '1';
						
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_mfc0_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if registers_pending(to_integer(unsigned(instruction_data_cop0.rt))) = '0' then
								registers_next(to_integer(unsigned(instruction_data_cop0.rt))) <= cp0_registers(to_integer(unsigned(instruction_data_cop0.rd)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_mtc0_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if registers_pending(to_integer(unsigned(instruction_data_cop0.rt))) = '0' then
							-- /!\ This is not exact should handle sel field
								cp0_registers_next(to_integer(unsigned(instruction_data_cop0.rd))) <= registers(to_integer(unsigned(instruction_data_cop0.rt)));
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_movn_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
								if get_reg_u(instruction_data_r.rt) /= 0 then
									registers_next(to_integer(unsigned(instruction_data_r.rd))) <= registers(to_integer(unsigned(instruction_data_r.rs)));
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					if instruction_cmp(instr_movz_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							if is_register_pending(instruction_data_r, registers_pending) = FALSE then
								if get_reg_u(instruction_data_r.rt) = 0 then
									registers_next(to_integer(unsigned(instruction_data_r.rd))) <= registers(to_integer(unsigned(instruction_data_r.rs)));
								end if;
								pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
								instruction_address_skid_valid <= '1';
								instruction_data_skid_ready <= '1';
							end if;
						end if;
					end if;
					
					-- cache
					if instruction_cmp(instr_cache_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							-- does nothing for now
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					if instruction_cmp(instr_pref_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							-- does nothing for now
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					if instruction_cmp(instr_sync_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							-- does nothing for now
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					-- syscall
					if instruction_cmp(instr_syscall_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					end if;
					-- does nothing for now
					if instruction_cmp(instr_break_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
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
					end if;
					if instruction_cmp(instr_sdbbp_opc, vinstruction_data) then
						vinstruction_handled := TRUE;
						if instruction_address_skid_ready = '1' then
							cp0_registers_next(COP0_REGISTER_DEPC) <= pc;
							breakpoint <= '1';
						
							pc_next <= std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
							instruction_address_skid_valid <= '1';
							instruction_data_skid_ready <= '1';
						end if;
					
					end if;
					if instruction_cmp(instr_deret_opc, vinstruction_data) then
					end if;
					if instruction_cmp(instr_eret_opc, vinstruction_data) then
					end if;
					
					if vinstruction_handled = FALSE then
						panic_next <= '1';
					else
						panic_next <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
	mips_alu_0 : mips_alu
		port map(
			clock => clock,
			resetn => resetn,
	
			add_in_tready => add_in_tready,
			add_in_tvalid => add_in_tvalid,
			add_in_tdata => add_in_tdata,
			add_in_tuser => add_in_tuser,
			add_out_tready => add_out_tready,
			add_out_tvalid => add_out_tvalid,
			add_out_tdata => add_out_tdata,
			add_out_tuser => add_out_tuser,
		
			sub_in_tready => sub_in_tready,
			sub_in_tvalid => sub_in_tvalid,
			sub_in_tdata => sub_in_tdata,
			sub_in_tuser => sub_in_tuser,
			sub_out_tready => sub_out_tready,
			sub_out_tvalid => sub_out_tvalid,
			sub_out_tdata => sub_out_tdata,
			sub_out_tuser => sub_out_tuser,
	
			mul_in_tready => mul_in_tready,
			mul_in_tvalid => mul_in_tvalid,
			mul_in_tdata => mul_in_tdata,
			mul_in_tuser => mul_in_tuser,
			mul_out_tready => mul_out_tready,
			mul_out_tvalid => mul_out_tvalid,
			mul_out_tdata => mul_out_tdata,
			mul_out_tuser => mul_out_tuser,
	
			multu_in_tready => multu_in_tready,
			multu_in_tvalid => multu_in_tvalid,
			multu_in_tdata => multu_in_tdata,
			multu_in_tuser => multu_in_tuser,
			multu_out_tready => multu_out_tready,
			multu_out_tvalid => multu_out_tvalid,
			multu_out_tdata => multu_out_tdata,
			multu_out_tuser => multu_out_tuser,
	
			div_in_tready => div_in_tready,
			div_in_tvalid => div_in_tvalid,
			div_in_tdata => div_in_tdata,
			div_in_tuser => div_in_tuser,
			div_out_tready => div_out_tready,
			div_out_tvalid => div_out_tvalid,
			div_out_tdata => div_out_tdata,
			div_out_tuser => div_out_tuser,
	
			divu_in_tready => divu_in_tready,
			divu_in_tvalid => divu_in_tvalid,
			divu_in_tdata => divu_in_tdata,
			divu_in_tuser => divu_in_tuser,
			divu_out_tready => divu_out_tready,
			divu_out_tvalid => divu_out_tvalid,
			divu_out_tdata => divu_out_tdata,
			divu_out_tuser => divu_out_tuser,
	
			multadd_in_tready => multadd_in_tready,
			multadd_in_tvalid => multadd_in_tvalid,
			multadd_in_tdata => multadd_in_tdata,
			multadd_in_tuser => multadd_in_tuser,
			multadd_out_tready => multadd_out_tready,
			multadd_out_tvalid => multadd_out_tvalid,
			multadd_out_tdata => multadd_out_tdata,
			multadd_out_tuser => multadd_out_tuser,
	
			multaddu_in_tready => multaddu_in_tready,
			multaddu_in_tvalid => multaddu_in_tvalid,
			multaddu_in_tdata => multaddu_in_tdata,
			multaddu_in_tuser => multaddu_in_tuser,
			multaddu_out_tready => multaddu_out_tready,
			multaddu_out_tvalid => multaddu_out_tvalid,
			multaddu_out_tdata => multaddu_out_tdata,
			multaddu_out_tuser => multaddu_out_tuser
			);
	
end mips_execution_unit_behavioral;
