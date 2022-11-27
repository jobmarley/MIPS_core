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


entity mips_core is
  Port ( 
	resetn : in std_logic;
	clock : in std_ulogic;
	
	xdma_clock : in std_logic;
	
	-- AXI4 memory
	--m_axi_awready : in STD_LOGIC;
 --   m_axi_wready : in STD_LOGIC;
 --   m_axi_bid : in STD_LOGIC_VECTOR ( 3 downto 0 );
 --   m_axi_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
 --   m_axi_bvalid : in STD_LOGIC;
 --   m_axi_arready : in STD_LOGIC;
 --   m_axi_rid : in STD_LOGIC_VECTOR ( 3 downto 0 );
 --   m_axi_rdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
 --   m_axi_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
 --   m_axi_rlast : in STD_LOGIC;
 --   m_axi_rvalid : in STD_LOGIC;
 --   m_axi_awid : out STD_LOGIC_VECTOR ( 3 downto 0 );
 --   m_axi_awaddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
 --   m_axi_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
 --   m_axi_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
 --   m_axi_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
 --   m_axi_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
 --   m_axi_awvalid : out STD_LOGIC;
 --   m_axi_awlock : out STD_LOGIC;
 --   m_axi_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
 --   m_axi_wdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
 --   m_axi_wstrb : out STD_LOGIC_VECTOR ( 7 downto 0 );
 --   m_axi_wlast : out STD_LOGIC;
 --   m_axi_wvalid : out STD_LOGIC;
 --   m_axi_bready : out STD_LOGIC;
 --   m_axi_arid : out STD_LOGIC_VECTOR ( 3 downto 0 );
 --   m_axi_araddr : out STD_LOGIC_VECTOR ( 63 downto 0 );
 --   m_axi_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
 --   m_axi_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
 --   m_axi_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
 --   m_axi_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
 --   m_axi_arvalid : out STD_LOGIC;
 --   m_axi_arlock : out STD_LOGIC;
 --   m_axi_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
 --   m_axi_rready : out STD_LOGIC;
	
	interrupt : out std_logic;
	interrupt_ack : in std_logic;
	
	-- memory port a
	m_axi_mema_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_mema_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
	m_axi_mema_arlock : out STD_LOGIC;
	m_axi_mema_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_arready : in STD_LOGIC;
	m_axi_mema_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_arvalid : out STD_LOGIC;
	m_axi_mema_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_mema_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
	m_axi_mema_awlock : out STD_LOGIC;
	m_axi_mema_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_awready : in STD_LOGIC;
	m_axi_mema_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axi_mema_awvalid : out STD_LOGIC;
	m_axi_mema_bready : out STD_LOGIC;
	m_axi_mema_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_bvalid : in STD_LOGIC;
	m_axi_mema_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_rlast : in STD_LOGIC;
	m_axi_mema_rready : out STD_LOGIC;
	m_axi_mema_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axi_mema_rvalid : in STD_LOGIC;
	m_axi_mema_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axi_mema_wlast : out STD_LOGIC;
	m_axi_mema_wready : in STD_LOGIC;
	m_axi_mema_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axi_mema_wvalid : out STD_LOGIC;
	
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
	
	-- AXI lite debug
	s_axil_debug_awready : out STD_LOGIC;
	s_axil_debug_wready : out STD_LOGIC;
	s_axil_debug_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
	s_axil_debug_bvalid : out STD_LOGIC;
	s_axil_debug_arready : out STD_LOGIC;
	s_axil_debug_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
	s_axil_debug_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
	s_axil_debug_rvalid : out STD_LOGIC;
	s_axil_debug_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
	s_axil_debug_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
	s_axil_debug_awvalid : in STD_LOGIC;
	s_axil_debug_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
	s_axil_debug_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
	s_axil_debug_wvalid : in STD_LOGIC;
	s_axil_debug_bready : in STD_LOGIC;
	s_axil_debug_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
	s_axil_debug_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
	s_axil_debug_arvalid : in STD_LOGIC;
	s_axil_debug_rready : in STD_LOGIC;
	
	LEDS : out std_logic_vector(7 downto 0)
	);
end mips_core;

architecture mips_core_behavioral of mips_core is
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
	
	component mips_debugger is
		port (
			resetn : in std_logic;
			clock : in std_logic;
			
			xdma_clock : in std_logic;
	
			register_port_in_a : out register_port_in_t;
			register_port_out_a : in register_port_out_t;
			
			processor_enable : out std_logic;
	
			breakpoint : in std_logic;
			interrupt : out std_logic;
			interrupt_ack : in std_logic;
	
			s_axi_awready : out STD_LOGIC;
			s_axi_wready : out STD_LOGIC;
			s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
			s_axi_bvalid : out STD_LOGIC;
			s_axi_arready : out STD_LOGIC;
			s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
			s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
			s_axi_rvalid : out STD_LOGIC;
			s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
			s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
			s_axi_awvalid : in STD_LOGIC;
			s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
			s_axi_wstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
			s_axi_wvalid : in STD_LOGIC;
			s_axi_bready : in STD_LOGIC;
			s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
			s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
			s_axi_arvalid : in STD_LOGIC;
			s_axi_rready : in STD_LOGIC;
	
			debug : out std_logic_vector(7 downto 0)
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
			port_type1_count : NATURAL
		);
		port (
			resetn : in std_logic;
			clock : in std_logic;
		
			port_in : in register_port_in_array_t(port_type1_count-1 downto 0);
			port_out : out register_port_out_array_t(port_type1_count-1 downto 0)
	
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
		register_port_out_b : in register_port_out_t
	
		-- fetch
		--fetch_override_address : out std_logic_vector(31 downto 0);
		--fetch_override_address_valid : out std_logic
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
			instruction_address : out std_logic_vector(31 downto 0);
			instruction_data : out std_logic_vector(31 downto 0);
			instruction_data_valid : out std_logic;
			instruction_data_ready : in std_logic;
		
			override_address : in std_logic_vector(31 downto 0);
			override_address_valid : in std_logic;
		
			delay_slot : in std_logic;
	
			error : out std_logic
		);
	end component;
	
	component mips_decode is
		port (
		enable : in std_logic;
		resetn : in std_logic;
		clock : in std_logic;
	
		instr_address_plus_8 : in std_logic_vector(31 downto 0);
		instr_address : in std_logic_vector(31 downto 0);
		instr_data : in std_logic_vector(31 downto 0);
		instr_data_valid : in std_logic;
		instr_data_ready : out std_logic;
	
		register_a : out std_logic_vector(5 downto 0);
		register_b : out std_logic_vector(5 downto 0);
		register_c : out std_logic_vector(5 downto 0);
		immediate : out std_logic_vector(31 downto 0);
		immediate_valid : out std_logic;
		operation : out std_logic_vector(OPERATION_INDEX_END-1 downto 0);
		operation_valid : out std_logic;
		load : out std_logic;
		store : out std_logic;
		memop_type : out std_logic_vector(2 downto 0);
	
		override_address : out std_logic_vector(31 downto 0);
		override_address_valid : out std_logic;
		delay_slot : out std_logic;
	
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
	end component;
	
	signal register_out : std_logic_vector(31 downto 0);
	signal register_in : std_logic_vector(31 downto 0);
	signal register_write : std_logic;
	signal register_address : std_logic_vector(5 downto 0);
	signal processor_enable : std_logic;
	signal breakpoint : std_logic;
	
	signal alu_in_ports : alu_in_ports_t;
	signal alu_out_ports : alu_out_ports_t;
		
	signal readmem_stall : std_logic;
	signal readmem_error : std_logic;
	
	-- registers
	constant register_port_count : NATURAL := 8;
	signal register_port_out : register_port_out_array_t(register_port_count-1 downto 0);
	signal register_port_in : register_port_in_array_t(register_port_count-1 downto 0);
	
	-- fetch
	signal fetch_instruction_address_plus_8 : std_logic_vector(31 downto 0);
	signal fetch_instruction_address : std_logic_vector(31 downto 0);
	signal fetch_instruction_data : std_logic_vector(31 downto 0);
	signal fetch_instruction_data_valid : std_logic;
	signal fetch_instruction_data_ready : std_logic;
	
	signal fetch_override_address : std_logic_vector(31 downto 0);
	signal fetch_override_address_valid : std_logic;
	signal fetch_delay_slot : std_logic;
			
	signal fetch_error : std_logic;
	
	-- decode	
	signal decode_register_a : std_logic_vector(5 downto 0);
	signal decode_register_b : std_logic_vector(5 downto 0);
	signal decode_register_c : std_logic_vector(5 downto 0);
	signal decode_immediate : std_logic_vector(31 downto 0);
	signal decode_immediate_valid : std_logic;
	signal decode_operation : std_logic_vector(OPERATION_INDEX_END-1 downto 0);
	signal decode_operation_valid : std_logic;
	signal decode_load : std_logic;
	signal decode_store : std_logic;
	signal decode_memop_type : std_logic_vector(2 downto 0);
	
	signal decode_override_address : std_logic_vector(31 downto 0);
	signal decode_override_address_valid : std_logic;
	
	signal decode_panic : std_logic;
	
	-- readreg
	signal readreg_stall : std_logic;
	signal readreg_override_address : std_logic_vector(31 downto 0);
	signal readreg_override_address_valid : std_logic;
	
	-- writeback
	--signal writeback_override_address : std_logic_vector(31 downto 0);
	--signal writeback_override_address_valid : std_logic;
begin
	fetch_override_address <= decode_override_address when decode_override_address_valid = '1' else readreg_override_address;-- when readreg_override_address_valid = '1' else writeback_override_address;
	fetch_override_address_valid <= decode_override_address_valid or readreg_override_address_valid;-- or writeback_override_address_valid;
	
	mips_readreg_i0 : mips_readreg port map(
		enable => not readmem_stall,
		resetn => resetn,
		clock => clock,
	
		-- decode
		register_a => decode_register_a,
		register_b => decode_register_b,
		register_c => decode_register_c,
		immediate => decode_immediate,
		immediate_valid => decode_immediate_valid,
		operation => decode_operation,
		operation_valid => decode_operation_valid,
		load => decode_load,
		store => decode_store,
		memop_type => decode_memop_type,
	
		-- registers
		register_port_in_a => register_port_in(3),
		register_port_out_a => register_port_out(3),
		register_port_in_b => register_port_in(4),
		register_port_out_b => register_port_out(4),
		register_port_in_c => register_port_in(5),
		register_port_out_c => register_port_out(5),
		register_port_in_d => register_port_in(6),
		register_port_out_d => register_port_out(6),
	
		-- alu
		alu_in_ports => alu_in_ports,
	
		override_address => readreg_override_address,
		override_address_valid => readreg_override_address_valid,
	
		stall => readreg_stall
		);
	
	mips_decode_i0 : mips_decode port map(
		enable => not readreg_stall and not readmem_stall,
		resetn => resetn,
		clock => clock,
	
		instr_address_plus_8 => fetch_instruction_address_plus_8,
		instr_address => fetch_instruction_address,
		instr_data => fetch_instruction_data,
		instr_data_valid => fetch_instruction_data_valid,
		instr_data_ready => fetch_instruction_data_ready,
	
		register_a => decode_register_a,
		register_b => decode_register_b,
		register_c => decode_register_c,
		immediate => decode_immediate,
		immediate_valid => decode_immediate_valid,
		operation => decode_operation,
		operation_valid => decode_operation_valid,
		load => decode_load,
		store => decode_store,
		memop_type => decode_memop_type,
	
		override_address => decode_override_address,
		override_address_valid => decode_override_address_valid,
		delay_slot => fetch_delay_slot,
	
		panic => decode_panic
		);
	
		mips_fetch_i0 : mips_fetch port map(
			enable => not readreg_stall and not readmem_stall,
			resetn => resetn,
			clock => clock,
	
			m_axi_mem_araddr => m_axi_mema_araddr,
			m_axi_mem_arburst => m_axi_mema_arburst,
			m_axi_mem_arcache => m_axi_mema_arcache,
			m_axi_mem_arlen => m_axi_mema_arlen,
			m_axi_mem_arlock => m_axi_mema_arlock,
			m_axi_mem_arprot => m_axi_mema_arprot,
			m_axi_mem_arready => m_axi_mema_arready,
			m_axi_mem_arsize => m_axi_mema_arsize,
			m_axi_mem_arvalid => m_axi_mema_arvalid,
			m_axi_mem_awaddr => m_axi_mema_awaddr,
			m_axi_mem_awburst => m_axi_mema_awburst,
			m_axi_mem_awcache => m_axi_mema_awcache,
			m_axi_mem_awlen => m_axi_mema_awlen,
			m_axi_mem_awlock => m_axi_mema_awlock,
			m_axi_mem_awprot => m_axi_mema_awprot,
			m_axi_mem_awready => m_axi_mema_awready,
			m_axi_mem_awsize => m_axi_mema_awsize,
			m_axi_mem_awvalid => m_axi_mema_awvalid,
			m_axi_mem_bready => m_axi_mema_bready,
			m_axi_mem_bresp => m_axi_mema_bresp,
			m_axi_mem_bvalid => m_axi_mema_bvalid,
			m_axi_mem_rdata => m_axi_mema_rdata,
			m_axi_mem_rlast => m_axi_mema_rlast,
			m_axi_mem_rready => m_axi_mema_rready,
			m_axi_mem_rresp => m_axi_mema_rresp,
			m_axi_mem_rvalid => m_axi_mema_rvalid,
			m_axi_mem_wdata => m_axi_mema_wdata,
			m_axi_mem_wlast => m_axi_mema_wlast,
			m_axi_mem_wready => m_axi_mema_wready,
			m_axi_mem_wstrb => m_axi_mema_wstrb,
			m_axi_mem_wvalid => m_axi_mema_wvalid,
	
			instruction_address_plus_8 => fetch_instruction_address_plus_8,
			instruction_address => fetch_instruction_address,
			instruction_data => fetch_instruction_data,
			instruction_data_valid => fetch_instruction_data_valid,
			instruction_data_ready => fetch_instruction_data_ready,
		
			override_address => fetch_override_address,
			override_address_valid => fetch_override_address_valid,
			delay_slot => fetch_delay_slot,
	
			error => fetch_error
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
		register_port_out_b => register_port_out(2)
	
		-- fetch
		--fetch_override_address => fetch_override_address,
		--fetch_override_address_valid => fetch_override_address_valid
		);
	
	mips_registers_i0 : mips_registers 
		generic map(
			port_type1_count => register_port_count
		)
		port map(
			resetn => resetn,
			clock => clock,
			port_in => register_port_in,
			port_out => register_port_out
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
	
	mips_debugger_i : mips_debugger port map(
		resetn => resetn,
		clock => clock,
			
		xdma_clock => xdma_clock,
	
		register_port_in_a => register_port_in(7),
		register_port_out_a => register_port_out(7),
			
		processor_enable => processor_enable,
	
		breakpoint => breakpoint,
		interrupt => interrupt,
		interrupt_ack => interrupt_ack,
	
		s_axi_awready => s_axil_debug_awready,
		s_axi_wready => s_axil_debug_wready,
		s_axi_bresp => s_axil_debug_bresp,
		s_axi_bvalid => s_axil_debug_bvalid,
		s_axi_arready => s_axil_debug_arready,
		s_axi_rdata => s_axil_debug_rdata,
		s_axi_rresp => s_axil_debug_rresp,
		s_axi_rvalid => s_axil_debug_rvalid,
		s_axi_awaddr => s_axil_debug_awaddr,
		s_axi_awprot => s_axil_debug_awprot,
		s_axi_awvalid => s_axil_debug_awvalid,
		s_axi_wdata => s_axil_debug_wdata,
		s_axi_wstrb => s_axil_debug_wstrb,
		s_axi_wvalid => s_axil_debug_wvalid,
		s_axi_bready => s_axil_debug_bready,
		s_axi_araddr => s_axil_debug_araddr,
		s_axi_arprot => s_axil_debug_arprot,
		s_axi_arvalid => s_axil_debug_arvalid,
		s_axi_rready => s_axil_debug_rready,
		
		debug => LEDS
	);

end mips_core_behavioral;
