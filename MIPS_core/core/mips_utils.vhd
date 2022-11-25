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

package mips_utils is

	type register_array_t is array(natural range 31 downto 0) of std_logic_vector(31 downto 0);
	
	type memory_port_t is record
		enable : STD_LOGIC;
		write_enable : STD_LOGIC_VECTOR(3 DOWNTO 0);
		address : STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
	end record;
	
	-- coprocessor 0 register numbers
	constant COP0_REGISTER_INDEX : NATURAL := 0;	-- Index into the TLB array
	constant COP0_REGISTER_INDEX_SEL : NATURAL := 0;
	constant COP0_REGISTER_RANDOM : NATURAL := 1;	-- Randomly generated index into the TLB array
	constant COP0_REGISTER_RANDOM_SEL : NATURAL := 0;
	constant COP0_REGISTER_ENTRYLO0 : NATURAL := 2;	-- Low-order portion of the TLB entry for even-numbered virtual pages
	constant COP0_REGISTER_ENTRYLO0_SEL : NATURAL := 0;
	constant COP0_REGISTER_ENTRYLO1 : NATURAL := 3;	-- Low-order portion of the TLB entry for odd-numbered virtual pages 
	constant COP0_REGISTER_ENTRYLO1_SEL : NATURAL := 0;
	constant COP0_REGISTER_CONTEXT : NATURAL := 4;	-- Pointer to page table entry in memory
	constant COP0_REGISTER_CONTEXT_SEL : NATURAL := 0;
	constant COP0_REGISTER_PAGEMASK : NATURAL := 5;	-- Control for variable page size in TLB entries
	constant COP0_REGISTER_PAGEMASK_SEL : NATURAL := 0;
	constant COP0_REGISTER_WIRED : NATURAL := 6;	-- Controls the number of fixed (“wired”) TLB entries
	constant COP0_REGISTER_WIRED_SEL : NATURAL := 0;
	constant COP0_REGISTER_7 : NATURAL := 7;		-- Reserved for future extensions
	constant COP0_REGISTER_7_SEL : NATURAL := 0;
	constant COP0_REGISTER_BADVADDR : NATURAL := 8;	-- Reports the address for the most recent address-related exception
	constant COP0_REGISTER_BADVADDR_SEL : NATURAL := 0;
	constant COP0_REGISTER_COUNT : NATURAL := 9;	-- Processor cycle count
	constant COP0_REGISTER_COUNT_SEL : NATURAL := 0;
	constant COP0_REGISTER_ENTRYHI : NATURAL := 10;	-- High-order portion of the TLB entry
	constant COP0_REGISTER_ENTRYHI_SEL : NATURAL := 0;
	constant COP0_REGISTER_COMPARE : NATURAL := 11;	-- Timer interrupt control 
	constant COP0_REGISTER_COMPARE_SEL : NATURAL := 0;
	constant COP0_REGISTER_STATUS : NATURAL := 12;	-- Processor status and control
	constant COP0_REGISTER_STATUS_SEL : NATURAL := 0;
	constant COP0_REGISTER_CAUSE : NATURAL := 13;	-- Cause of last general exception 
	constant COP0_REGISTER_CAUSE_SEL : NATURAL := 0;
	constant COP0_REGISTER_EPC : NATURAL := 14;		-- Program counter at last exception
	constant COP0_REGISTER_EPC_SEL : NATURAL := 0;
	constant COP0_REGISTER_PRID : NATURAL := 15;	-- Processor identification and revision
	constant COP0_REGISTER_PRID_SEL : NATURAL := 0;
	constant COP0_REGISTER_CONFIG : NATURAL := 16;	-- Configuration register
	constant COP0_REGISTER_CONFIG_SEL : NATURAL := 0;
	constant COP0_REGISTER_CONFIG1 : NATURAL := 16;	-- Configuration register 1 
	constant COP0_REGISTER_CONFIG1_SEL : NATURAL := 1;
	constant COP0_REGISTER_CONFIG2 : NATURAL := 16;	-- Configuration register 2
	constant COP0_REGISTER_CONFIG2_SEL : NATURAL := 2;
	constant COP0_REGISTER_CONFIG3 : NATURAL := 16;	-- Configuration register 3
	constant COP0_REGISTER_CONFIG3_SEL : NATURAL := 3;
	constant COP0_REGISTER_LLADDR : NATURAL := 17;	-- Load linked address
	constant COP0_REGISTER_LLADDR_SEL : NATURAL := 0;
	constant COP0_REGISTER_WATCHLO : NATURAL := 18;	-- Watchpoint address
	constant COP0_REGISTER_WATCHLO_SEL : NATURAL := 0;
	constant COP0_REGISTER_WATCHHI : NATURAL := 19;	-- Watchpoint control
	constant COP0_REGISTER_WATCHHI_SEL : NATURAL := 0;
	constant COP0_REGISTER_20 : NATURAL := 20;		-- XContext in 64-bit implementations
	constant COP0_REGISTER_20_SEL : NATURAL := 0;
	constant COP0_REGISTER_21 : NATURAL := 21;		-- Reserved for future extensions
	constant COP0_REGISTER_21_SEL : NATURAL := 0;
	constant COP0_REGISTER_22 : NATURAL := 22;		-- Available for implementation dependent use
	constant COP0_REGISTER_22_SEL : NATURAL := 0;
	constant COP0_REGISTER_DEBUG : NATURAL := 23;	-- EJTAG Debug register
	constant COP0_REGISTER_DEBUG_SEL : NATURAL := 0;
	constant COP0_REGISTER_DEPC : NATURAL := 24;	-- Program counter at last EJTAG debug exception 
	constant COP0_REGISTER_DEPC_SEL : NATURAL := 0;
	constant COP0_REGISTER_PERFCNT : NATURAL := 25;	-- Performance counter interface
	constant COP0_REGISTER_PERFCNT_SEL : NATURAL := 0;
	constant COP0_REGISTER_ERRCTL : NATURAL := 26;	-- Parity/ECC error control and status
	constant COP0_REGISTER_ERRCTL_SEL : NATURAL := 0;
	constant COP0_REGISTER_CACHERR : NATURAL := 27;	-- Cache parity error control and status 
	constant COP0_REGISTER_CACHERR_SEL : NATURAL := 0;
	constant COP0_REGISTER_TAGLO : NATURAL := 28;	-- Low-order portion of cache tag interface
	constant COP0_REGISTER_TAGLO_SEL : NATURAL := 0;
	constant COP0_REGISTER_DATALO : NATURAL := 28;	-- Low-order portion of cache data interface
	constant COP0_REGISTER_DATALO_SEL : NATURAL := 1;
	constant COP0_REGISTER_TAGHI : NATURAL := 29;	-- High-order portion of cache tag interface
	constant COP0_REGISTER_TAGHI_SEL : NATURAL := 0;
	constant COP0_REGISTER_DATAHI : NATURAL := 29;	-- High-order portion of cache data interface
	constant COP0_REGISTER_DATAHI_SEL : NATURAL := 1;
	constant COP0_REGISTER_ERROREPC : NATURAL := 30;-- Program counter at last error 
	constant COP0_REGISTER_ERROREPC_SEL : NATURAL := 0;
	constant COP0_REGISTER_DESAVE : NATURAL := 31;	-- EJTAG debug exception save register 
	constant COP0_REGISTER_DESAVE_SEL : NATURAL := 0;
	
	constant COP0_EXCCODE_INT : std_logic_vector(4 downto 0) := '0' & x"0";			-- Interrupt
	constant COP0_EXCCODE_MOD : std_logic_vector(4 downto 0) := '0' & x"1";			-- TLB modification exception
	constant COP0_EXCCODE_TLBL : std_logic_vector(4 downto 0) := '0' & x"2";		-- TLB exception (load or instruction fetch)
	constant COP0_EXCCODE_TLBS : std_logic_vector(4 downto 0) := '0' & x"3";		-- TLB exception (store)
	constant COP0_EXCCODE_ADEL : std_logic_vector(4 downto 0) := '0' & x"4";		-- Address error exception (load or instruction fetch)
	constant COP0_EXCCODE_ADES : std_logic_vector(4 downto 0) := '0' & x"5";		-- Address error exception (store)
	constant COP0_EXCCODE_IBE : std_logic_vector(4 downto 0) := '0' & x"6";			-- Bus error exception (instruction fetch)
	constant COP0_EXCCODE_DBE : std_logic_vector(4 downto 0) := '0' & x"7";			-- Bus error exception (data reference: load or store)
	constant COP0_EXCCODE_SYS : std_logic_vector(4 downto 0) := '0' & x"8";			-- Syscall exception
	constant COP0_EXCCODE_BP : std_logic_vector(4 downto 0) := '0' & x"9";			-- Breakpoint exception
	constant COP0_EXCCODE_RI : std_logic_vector(4 downto 0) := '0' & x"A";			-- Reserved instruction exception
	constant COP0_EXCCODE_CPU : std_logic_vector(4 downto 0) := '0' & x"B";			-- Coprocessor Unusable exception
	constant COP0_EXCCODE_OV : std_logic_vector(4 downto 0) := '0' & x"C";			-- Arithmetic Overflow exception
	constant COP0_EXCCODE_TR : std_logic_vector(4 downto 0) := '0' & x"D";			-- Trap exception
	constant COP0_EXCCODE_FPE : std_logic_vector(4 downto 0) := '0' & x"F";			-- Floating point exception
	constant COP0_EXCCODE_C2E : std_logic_vector(4 downto 0) := '1' & x"2";			-- Reserved for precise Coprocessor 2 exceptions
	constant COP0_EXCCODE_MDMX : std_logic_vector(4 downto 0) := '1' & x"6";		-- Reserved for MDMX Unusable Exception in MIPS64 implementations
	constant COP0_EXCCODE_WATCH : std_logic_vector(4 downto 0) := '1' & x"7";		-- Reference to WatchHi/WatchLo address
	constant COP0_EXCCODE_MCHECK : std_logic_vector(4 downto 0) := '1' & x"8";		-- Machine check
	constant COP0_EXCCODE_CACHEERR : std_logic_vector(4 downto 0) := '1' & x"E";	-- Cache error
	
	subtype slv32_t is std_logic_vector(31 downto 0);
	type slv32_array_t is array(NATURAL RANGE <>) of slv32_t;
	type cop0_register_t is array(31 downto 0) of slv32_array_t(7 downto 0);
	
	type register_port_in_t is record
		address : std_logic_vector(4 DOWNTO 0);
		write_enable : std_logic;
		write_data : std_logic_vector(31 downto 0);
		write_strobe : std_logic_vector(3 downto 0);
		write_pending : std_logic;
	end record;
	type register_port_out_t is record
		data : std_logic_vector(31 downto 0);
		pending : std_logic;
	end record;
	type register_port_in_array_t is array(NATURAL RANGE <>) of register_port_in_t;
	type register_port_out_array_t is array(NATURAL RANGE <>) of register_port_out_t;
	
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
	
	function slv_to_instruction_r(v : std_logic_vector(31 downto 0)) return instruction_r_t;
	function slv_to_instruction_i(v : std_logic_vector(31 downto 0)) return instruction_i_t;
	function slv_to_instruction_j(v : std_logic_vector(31 downto 0)) return instruction_j_t;
	function slv_to_instruction_cop0(v : std_logic_vector(31 downto 0)) return instruction_cop0_t;
	
	function instruction_to_slv(i : instruction_r_t) return std_logic_vector;
	function instruction_to_slv(i : instruction_i_t) return std_logic_vector;
	function instruction_to_slv(i : instruction_j_t) return std_logic_vector;
	function instruction_to_slv(i : instruction_cop0_t) return std_logic_vector;
	
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
	
	constant OPERATION_INDEX_ADD : NATURAL := 0;
	constant OPERATION_INDEX_SUB : NATURAL := 1;
	constant OPERATION_INDEX_MUL : NATURAL := 2;
	constant OPERATION_INDEX_DIV : NATURAL := 3;
	
	constant memory_op_type_word : std_logic_vector(2 downto 0) := "000";
	constant memory_op_type_byte : std_logic_vector(2 downto 0) := "001";
	constant memory_op_type_half : std_logic_vector(2 downto 0) := "010";
	constant memory_op_type_half_left : std_logic_vector(2 downto 0) := "100";
	constant memory_op_type_half_right : std_logic_vector(2 downto 0) := "101";
	type alu_add_out_tuser_t is record
		exclusive : std_logic;
		signed : std_logic;
		memop_type : std_logic_vector(2 downto 0);
		store : std_logic;
		store_data : std_logic_vector(31 downto 0);
		load : std_logic;
		rt : std_logic_vector(4 downto 0);
	end record;
	function slv_to_add_out_tuser(data : std_logic_vector) return alu_add_out_tuser_t;
	function add_out_tuser_to_slv(tuser : alu_add_out_tuser_t) return std_logic_vector;
end package;


package body mips_utils is
	
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
	
	function slv_to_add_out_tuser(data : std_logic_vector) return alu_add_out_tuser_t is
		variable vresult : alu_add_out_tuser_t;
	begin
		vresult.rt := data(4 downto 0);
		vresult.load := data(5);
		vresult.store := data(6);
		vresult.store_data := data(38 downto 7);
		vresult.memop_type := data(41 downto 39);
		vresult.signed := data(42);
		vresult.exclusive := data(43);
		return vresult;
	end function;
	
	function add_out_tuser_to_slv(tuser : alu_add_out_tuser_t) return std_logic_vector is
		variable vresult : std_logic_vector(43 downto 0);
	begin
		vresult(4 downto 0) := tuser.rt;
		vresult(5) := tuser.load;
		vresult(6) := tuser.store;
		vresult(38 downto 7) := tuser.store_data;
		vresult(41 downto 39) := tuser.memop_type;
		vresult(42) := tuser.signed;
		vresult(43) := tuser.exclusive;
		return vresult;
	end function;
end mips_utils;