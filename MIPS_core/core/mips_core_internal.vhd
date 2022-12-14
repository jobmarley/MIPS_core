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
use work.mips_utils.all;


entity mips_core_internal is
  Port ( 
	resetn : in std_logic;
	clock : in std_ulogic;
		
	enable : in std_logic;
	
	breakpoint : out std_logic;
	
	register_port_in_a : in register_port_in_t;
	register_port_out_a : out register_port_out_t;
		
	register_hilo_in : in hilo_register_port_in_t;
	register_hilo_out : out hilo_register_port_out_t;
	
	cop0_reg_port_in_a : in cop0_register_port_in_t;
	cop0_reg_port_out_a : out cop0_register_port_out_t;
	
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
	
	-- fetch
	fetch_instruction_address_plus_8 : in std_logic_vector(31 downto 0);
	fetch_instruction_address_plus_4 : in std_logic_vector(31 downto 0);
	fetch_instruction_address : in std_logic_vector(31 downto 0);
	fetch_instruction_data : in std_logic_vector(31 downto 0);
	fetch_instruction_data_valid : in std_logic;
	fetch_instruction_data_ready : out std_logic;
		
	fetch_override_address : out std_logic_vector(31 downto 0);
	fetch_override_address_valid : out std_logic;
	fetch_skip_jump : out std_logic;
	fetch_wait_jump : out std_logic;
	fetch_execute_delay_slot : out std_logic;
	
	stall : out std_logic
	);
end mips_core_internal;

architecture mips_core_internal_behavioral of mips_core_internal is
	component mips_readmem is
		port (
		resetn : in std_logic;
		clock : in std_logic;
		
		m_axi_mem_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_mem_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_mem_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
		m_axi_mem_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
		m_axi_mem_arlock : out STD_LOGIC;
		m_axi_mem_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_mem_arready : in STD_LOGIC;
		m_axi_mem_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_mem_arvalid : out STD_LOGIC;
		m_axi_mem_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_mem_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_mem_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
		m_axi_mem_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
		m_axi_mem_awlock : out STD_LOGIC;
		m_axi_mem_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_mem_awready : in STD_LOGIC;
		m_axi_mem_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
		m_axi_mem_awvalid : out STD_LOGIC;
		m_axi_mem_bready : out STD_LOGIC;
		m_axi_mem_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_mem_bvalid : in STD_LOGIC;
		m_axi_mem_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_mem_rlast : in STD_LOGIC;
		m_axi_mem_rready : out STD_LOGIC;
		m_axi_mem_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
		m_axi_mem_rvalid : in STD_LOGIC;
		m_axi_mem_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
		m_axi_mem_wlast : out STD_LOGIC;
		m_axi_mem_wready : in STD_LOGIC;
		m_axi_mem_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
		m_axi_mem_wvalid : out STD_LOGIC;
		
		add_out_tvalid : in std_logic;
		add_out_tdata : in std_logic_vector(32 downto 0);
		add_out_tuser : in std_logic_vector(alu_add_out_tuser_length-1 downto 0);
	
		-- registers
		register_port_in_a : out register_port_in_t;
		register_port_out_a : in register_port_out_t;
	
		stall : out std_logic;
		error : out std_logic
		);
	end component;
		
	component mips_alu is
		port (
			enable : in std_logic;
			clock : in std_logic;
			resetn : in std_logic;
	
			in_ports : in alu_in_ports_t;
			out_ports : out alu_out_ports_t 
		);
	end component;
	
	component mips_registers is
		generic (
			port_type1_count : NATURAL;
			port_hilo_in_count : NATURAL;
			port_hilo_out_count : NATURAL
		);
		port (
			resetn : in std_logic;
			clock : in std_logic;
		
			port_in : in register_port_in_array_t(port_type1_count-1 downto 0);
			port_out : out register_port_out_array_t(port_type1_count-1 downto 0);
	
			hilo_in : in hilo_register_port_in_array_t(port_hilo_in_count-1 downto 0);
			hilo_out : out hilo_register_port_out_array_t(port_hilo_out_count-1 downto 0)
		);
	end component;

	component cop0_registers is
		generic(
			port_count : NATURAL
		);
		port(
			resetn : in std_logic;
			clock : in std_logic;
	
			ports_in : in cop0_register_port_in_array_t(port_count-1 downto 0);
			ports_out : out cop0_register_port_out_array_t(port_count-1 downto 0)
		);
	end component;

	component mips_writeback is
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
	end component;
	
	component mips_fetch is
		port(
			enable : in std_logic;
			resetn : in std_logic;
			clock : in std_logic;
	
			m_axi_mem_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
			m_axi_mem_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
			m_axi_mem_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
			m_axi_mem_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
			m_axi_mem_arlock : out STD_LOGIC;
			m_axi_mem_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
			m_axi_mem_arready : in STD_LOGIC;
			m_axi_mem_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
			m_axi_mem_arvalid : out STD_LOGIC;
			m_axi_mem_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
			m_axi_mem_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
			m_axi_mem_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
			m_axi_mem_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
			m_axi_mem_awlock : out STD_LOGIC;
			m_axi_mem_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
			m_axi_mem_awready : in STD_LOGIC;
			m_axi_mem_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
			m_axi_mem_awvalid : out STD_LOGIC;
			m_axi_mem_bready : out STD_LOGIC;
			m_axi_mem_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
			m_axi_mem_bvalid : in STD_LOGIC;
			m_axi_mem_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
			m_axi_mem_rlast : in STD_LOGIC;
			m_axi_mem_rready : out STD_LOGIC;
			m_axi_mem_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
			m_axi_mem_rvalid : in STD_LOGIC;
			m_axi_mem_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
			m_axi_mem_wlast : out STD_LOGIC;
			m_axi_mem_wready : in STD_LOGIC;
			m_axi_mem_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
			m_axi_mem_wvalid : out STD_LOGIC;
	
			instruction_address_plus_8 : out std_logic_vector(31 downto 0);
			instruction_address_plus_4 : out std_logic_vector(31 downto 0);
			instruction_address : out std_logic_vector(31 downto 0);
			instruction_data : out std_logic_vector(31 downto 0);
			instruction_data_valid : out std_logic;
			instruction_data_ready : in std_logic;
		
			override_address : in std_logic_vector(31 downto 0);
			override_address_valid : in std_logic;
			skip_jump : in std_logic;
			wait_jump : in std_logic;
			execute_delay_slot : in std_logic;
			
			error : out std_logic
		);
	end component;
	
	component mips_decode is
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
	end component;
	
	component mips_readreg is
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
	
		immediate_a : in std_logic_vector(31 downto 0);
		immediate_b : in std_logic_vector(31 downto 0);
		link_address : in std_logic_vector(31 downto 0);
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
	
		-- alu
		alu_in_ports : out alu_in_ports_t;
	
		override_address : out std_logic_vector(31 downto 0);
		override_address_valid : out std_logic;
		execute_delay_slot : out std_logic;
		skip_jump : out std_logic;
	
		stall : out std_logic
		);
	end component;
		
	
	signal register_write : std_logic;
	signal register_address : std_logic_vector(5 downto 0);
	signal processor_enable : std_logic;
	
	signal alu_in_ports : alu_in_ports_t;
	signal alu_out_ports : alu_out_ports_t;
		
	signal readmem_stall : std_logic;
	signal readmem_error : std_logic;
	
	-- registers
	constant register_port_count : NATURAL := 9;
	constant register_hilo_in_count : NATURAL := 3;
	constant register_hilo_out_count : NATURAL := 2;
	signal register_port_out : register_port_out_array_t(register_port_count-1 downto 0);
	signal register_port_in : register_port_in_array_t(register_port_count-1 downto 0);
	signal register_hilo_in_internal : hilo_register_port_in_array_t(register_hilo_in_count-1 downto 0);
	signal register_hilo_out_internal : hilo_register_port_out_array_t(register_hilo_out_count-1 downto 0);
		
	constant cop0_port_count : NATURAL := 3;
	signal cop0_ports_in : cop0_register_port_in_array_t(cop0_port_count-1 downto 0);
	signal cop0_ports_out : cop0_register_port_out_array_t(cop0_port_count-1 downto 0);
	
	-- decode	
	signal decode_register_a : std_logic_vector(5 downto 0);
	signal decode_register_b : std_logic_vector(5 downto 0);
	signal decode_register_c : std_logic_vector(5 downto 0);
	signal decode_immediate : std_logic_vector(31 downto 0);
	signal decode_immediate_valid : std_logic;
	signal decode_operation : decode_operation_t;
	signal decode_operation_valid : std_logic;
	signal decode_load : std_logic;
	signal decode_store : std_logic;
	signal decode_memop_type : std_logic_vector(2 downto 0);
	signal decode_immediate_a : std_logic_vector(31 downto 0);
	signal decode_immediate_b : std_logic_vector(31 downto 0);
	signal decode_link_address : std_logic_vector(31 downto 0);
	signal decode_mov_strobe : std_logic_vector(3 downto 0);
	
	signal decode_override_address : std_logic_vector(31 downto 0);
	signal decode_override_address_valid : std_logic;
	signal decode_wait_jump : std_logic;
	signal decode_execute_delay_slot : std_logic;
	
	signal decode_breakpoint : std_logic;
	signal decode_panic : std_logic;
	
	-- readreg
	signal readreg_stall : std_logic;
	signal readreg_override_address : std_logic_vector(31 downto 0);
	signal readreg_override_address_valid : std_logic;
	signal readreg_execute_delay_slot : std_logic;
	signal readreg_skip_jump : std_logic;
	
	-- writeback
	signal writeback_override_address : std_logic_vector(31 downto 0);
	signal writeback_override_address_valid : std_logic;
	signal writeback_skip_jump : std_logic;
	signal writeback_execute_delay_slot : std_logic;
begin
	stall <= readreg_stall or readmem_stall;
	breakpoint <= decode_breakpoint;
	
	register_port_in(7) <= register_port_in_a;
	register_port_out_a <= register_port_out(7);
	register_hilo_in_internal(2) <= register_hilo_in;
	register_hilo_out <= register_hilo_out_internal(1);
	
	cop0_ports_in(1) <= cop0_reg_port_in_a;
	cop0_reg_port_out_a <= cop0_ports_out(1);
	
	fetch_override_address <= decode_override_address when decode_override_address_valid = '1'
		else readreg_override_address when readreg_override_address_valid = '1'
		else writeback_override_address;
	fetch_override_address_valid <= decode_override_address_valid or readreg_override_address_valid or writeback_override_address_valid;
	fetch_execute_delay_slot <= decode_execute_delay_slot or readreg_execute_delay_slot or writeback_execute_delay_slot;
	fetch_skip_jump <= readreg_skip_jump or writeback_skip_jump;
	fetch_wait_jump <= decode_wait_jump;
	
	mips_readreg_i0 : mips_readreg port map(
		enable => not readmem_stall,
		resetn => resetn,
		clock => clock,
	
		-- decode
		register_a => decode_register_a,
		register_b => decode_register_b,
		register_c => decode_register_c,
		operation => decode_operation,
		operation_valid => decode_operation_valid,
		load => decode_load,
		store => decode_store,
		memop_type => decode_memop_type,
		mov_strobe => decode_mov_strobe,
	
		-- registers
		register_port_in_a => register_port_in(3),
		register_port_out_a => register_port_out(3),
		register_port_in_b => register_port_in(4),
		register_port_out_b => register_port_out(4),
		register_port_in_c => register_port_in(5),
		register_port_out_c => register_port_out(5),
		register_port_in_d => register_port_in(6),
		register_port_out_d => register_port_out(6),
		register_hilo_in => register_hilo_in_internal(1),
		register_hilo_out => register_hilo_out_internal(0),
	
		cop0_reg_port_in_a => cop0_ports_in(0),
		cop0_reg_port_out_a => cop0_ports_out(0),
		cop0_reg_port_in_b => cop0_ports_in(2),
		cop0_reg_port_out_b => cop0_ports_out(2),
	
		-- alu
		alu_in_ports => alu_in_ports,
	
		override_address => readreg_override_address,
		override_address_valid => readreg_override_address_valid,
		execute_delay_slot => readreg_execute_delay_slot,
		skip_jump => readreg_skip_jump,
	
		immediate_a => decode_immediate_a,
		immediate_b => decode_immediate_b,
		link_address => decode_link_address,
	
		stall => readreg_stall
		);
	
	mips_decode_i0 : mips_decode port map(
		enable => not readreg_stall and not readmem_stall,
		resetn => resetn,
		clock => clock,
	
		instr_address_plus_8 => fetch_instruction_address_plus_8,
		instr_address_plus_4 => fetch_instruction_address_plus_4,
		instr_address => fetch_instruction_address,
		instr_data => fetch_instruction_data,
		instr_data_valid => fetch_instruction_data_valid,
		instr_data_ready => fetch_instruction_data_ready,
	
		register_a => decode_register_a,
		register_b => decode_register_b,
		register_c => decode_register_c,
		operation => decode_operation,
		operation_valid => decode_operation_valid,
		load => decode_load,
		store => decode_store,
		memop_type => decode_memop_type,
		mov_strobe => decode_mov_strobe,
	
		immediate_a => decode_immediate_a,
		immediate_b => decode_immediate_b,
		link_address => decode_link_address,
	
		override_address => decode_override_address,
		override_address_valid => decode_override_address_valid,
		wait_jump => decode_wait_jump,
		execute_delay_slot => decode_execute_delay_slot,
	
		breakpoint => decode_breakpoint,
		panic => decode_panic
		);
	
	mips_writeback_i0 : mips_writeback port map(
		resetn => resetn,
		clock => clock,
	
		-- alu
		alu_out_ports => alu_out_ports,
	
		-- registers
		register_port_in_a => register_port_in(1),
		register_port_out_a => register_port_out(1),
		register_port_in_b => register_port_in(2),
		register_port_out_b => register_port_out(2),
		register_port_in_c => register_port_in(8),
		register_port_out_c => register_port_out(8),
	
		register_hilo_in => register_hilo_in_internal(0),
	
		-- fetch
		fetch_override_address => writeback_override_address,
		fetch_override_address_valid => writeback_override_address_valid,
		fetch_skip_jump => writeback_skip_jump,
		fetch_execute_delay_slot => writeback_execute_delay_slot
		);
	
	mips_registers_i0 : mips_registers 
		generic map(
			port_type1_count => register_port_count,
			port_hilo_in_count => register_hilo_in_count,
			port_hilo_out_count => register_hilo_out_count
		)
		port map(
			resetn => resetn,
			clock => clock,
			port_in => register_port_in,
			port_out => register_port_out,
	
			hilo_in => register_hilo_in_internal,
			hilo_out => register_hilo_out_internal
		);
	
	cop0_registers_i0 : cop0_registers 
		generic map(
			port_count => cop0_port_count
		)
		port map(
			resetn => resetn,
			clock => clock,
	
			ports_in => cop0_ports_in,
			ports_out => cop0_ports_out
		);
	
	mips_readmem_i0 : mips_readmem port map(
		resetn => resetn,
		clock => clock,
		
		m_axi_mem_araddr => m_axi_memb_araddr,
		m_axi_mem_arburst => m_axi_memb_arburst,
		m_axi_mem_arcache => m_axi_memb_arcache,
		m_axi_mem_arlen => m_axi_memb_arlen,
		m_axi_mem_arlock => m_axi_memb_arlock,
		m_axi_mem_arprot => m_axi_memb_arprot,
		m_axi_mem_arready => m_axi_memb_arready,
		m_axi_mem_arsize => m_axi_memb_arsize,
		m_axi_mem_arvalid => m_axi_memb_arvalid,
		m_axi_mem_awaddr => m_axi_memb_awaddr,
		m_axi_mem_awburst => m_axi_memb_awburst,
		m_axi_mem_awcache => m_axi_memb_awcache,
		m_axi_mem_awlen => m_axi_memb_awlen,
		m_axi_mem_awlock => m_axi_memb_awlock,
		m_axi_mem_awprot => m_axi_memb_awprot,
		m_axi_mem_awready => m_axi_memb_awready,
		m_axi_mem_awsize => m_axi_memb_awsize,
		m_axi_mem_awvalid => m_axi_memb_awvalid,
		m_axi_mem_bready => m_axi_memb_bready,
		m_axi_mem_bresp => m_axi_memb_bresp,
		m_axi_mem_bvalid => m_axi_memb_bvalid,
		m_axi_mem_rdata => m_axi_memb_rdata,
		m_axi_mem_rlast => m_axi_memb_rlast,
		m_axi_mem_rready => m_axi_memb_rready,
		m_axi_mem_rresp => m_axi_memb_rresp,
		m_axi_mem_rvalid => m_axi_memb_rvalid,
		m_axi_mem_wdata => m_axi_memb_wdata,
		m_axi_mem_wlast => m_axi_memb_wlast,
		m_axi_mem_wready => m_axi_memb_wready,
		m_axi_mem_wstrb => m_axi_memb_wstrb,
		m_axi_mem_wvalid => m_axi_memb_wvalid,
		
		add_out_tvalid => alu_out_ports.add_out_tvalid,
		add_out_tdata => alu_out_ports.add_out_tdata,
		add_out_tuser => alu_out_ports.add_out_tuser,
	
		-- registers
		register_port_in_a => register_port_in(0),
		register_port_out_a => register_port_out(0),
	
		stall => readmem_stall,
		error => readmem_error
		);
	mips_alu_0 : mips_alu
		port map(
			enable => not readmem_stall,
			clock => clock,
			resetn => resetn,
		
			in_ports => alu_in_ports,
			out_ports => alu_out_ports
			);

end mips_core_internal_behavioral;
