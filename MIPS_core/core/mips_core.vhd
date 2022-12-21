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
	component mips_debugger is
		port (
			resetn : in std_logic;
			clock : in std_logic;
			
			xdma_clock : in std_logic;
	
			register_port_in_a : out register_port_in_t;
			register_port_out_a : in register_port_out_t;
			cop0_reg_port_in_a : out cop0_register_port_in_t;
			cop0_reg_port_out_a : in cop0_register_port_out_t;
			
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
	
			-- fetch
			fetch_instruction_address_plus_8 : in std_logic_vector(31 downto 0);
			fetch_instruction_address_plus_4 : in std_logic_vector(31 downto 0);
			fetch_instruction_address : in std_logic_vector(31 downto 0);
		
			fetch_override_address : out std_logic_vector(31 downto 0);
			fetch_override_address_valid : out std_logic;
			fetch_skip_jump : out std_logic;
			fetch_wait_jump : out std_logic;
			fetch_execute_delay_slot : out std_logic;
	
			debug : out std_logic_vector(7 downto 0)
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
	component mips_core_internal is
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
		
		registers_written : out registers_pending_t;
	
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
	end component;
	
	-- debugger
	signal processor_enable : std_logic;
	signal breakpoint : std_logic;
	signal register_port_in_a : register_port_in_t;
	signal register_port_out_a : register_port_out_t;
	
	signal register_hilo_in : hilo_register_port_in_t;
	signal register_hilo_out : hilo_register_port_out_t;
	
	signal register_cop0_reg_port_in_a : cop0_register_port_in_t;
	signal register_cop0_reg_port_out_a : cop0_register_port_out_t;
	
	signal stall : std_logic;
	
	signal debugger_override_address : std_logic_vector(31 downto 0);
	signal debugger_override_address_valid : std_logic;
	signal debugger_skip_jump : std_logic;
	signal debugger_wait_jump : std_logic;
	signal debugger_execute_delay_slot : std_logic;
	
	-- internal
	
	signal internal_instruction_data_ready : std_logic;
	signal internal_override_address : std_logic_vector(31 downto 0);
	signal internal_override_address_valid : std_logic;
	signal internal_skip_jump : std_logic;
	signal internal_wait_jump : std_logic;
	signal internal_execute_delay_slot : std_logic;
	
	-- fetch
	signal fetch_instruction_address_plus_8 : std_logic_vector(31 downto 0);
	signal fetch_instruction_address_plus_4 : std_logic_vector(31 downto 0);
	signal fetch_instruction_address : std_logic_vector(31 downto 0);
	signal fetch_instruction_data : std_logic_vector(31 downto 0);
	signal fetch_instruction_data_valid : std_logic;
	signal fetch_instruction_data_ready : std_logic;
		
	signal fetch_override_address : std_logic_vector(31 downto 0);
	signal fetch_override_address_valid : std_logic;
	signal fetch_execute_delay_slot : std_logic;
	signal fetch_skip_jump : std_logic;
	signal fetch_wait_jump : std_logic;
				
	signal fetch_error : std_logic;
begin
	fetch_instruction_data_ready <= internal_instruction_data_ready;
		
	fetch_override_address <= debugger_override_address when debugger_override_address_valid = '1' else internal_override_address;
	fetch_override_address_valid <= debugger_override_address_valid or internal_override_address_valid;
	fetch_execute_delay_slot <= debugger_execute_delay_slot or internal_execute_delay_slot;
	fetch_skip_jump <= debugger_skip_jump or internal_skip_jump;
	fetch_wait_jump <= debugger_wait_jump or internal_wait_jump;
	
	mips_debugger_i : mips_debugger port map(
		resetn => resetn,
		clock => clock,
			
		xdma_clock => xdma_clock,
	
		register_port_in_a => register_port_in_a,
		register_port_out_a => register_port_out_a,
			
		cop0_reg_port_in_a => register_cop0_reg_port_in_a,
		cop0_reg_port_out_a => register_cop0_reg_port_out_a,
	
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
		
		fetch_instruction_address_plus_8 => fetch_instruction_address_plus_8,
		fetch_instruction_address_plus_4 => fetch_instruction_address_plus_4,
		fetch_instruction_address => fetch_instruction_address,
	
		fetch_override_address => debugger_override_address,
		fetch_override_address_valid => debugger_override_address_valid,
		fetch_skip_jump => debugger_skip_jump,
		fetch_wait_jump => debugger_wait_jump,
		fetch_execute_delay_slot => debugger_execute_delay_slot,
	
		debug => LEDS
	);
	mips_core_internal_i : mips_core_internal port map(
		resetn => resetn,
		clock => clock,
		
		enable => processor_enable,
		breakpoint => breakpoint,
		
		register_port_in_a => register_port_in_a,
		register_port_out_a => register_port_out_a,
		
		register_hilo_in => register_hilo_in,
		register_hilo_out => register_hilo_out,
	
		cop0_reg_port_in_a => register_cop0_reg_port_in_a,
		cop0_reg_port_out_a => register_cop0_reg_port_out_a,
	
		-- memory => memory,
		m_axi_memb_araddr => m_axi_memb_araddr,
		m_axi_memb_arburst => m_axi_memb_arburst,
		m_axi_memb_arcache => m_axi_memb_arcache,
		m_axi_memb_arlen => m_axi_memb_arlen,
		m_axi_memb_arlock => m_axi_memb_arlock,
		m_axi_memb_arprot => m_axi_memb_arprot,
		m_axi_memb_arready => m_axi_memb_arready,
		m_axi_memb_arsize => m_axi_memb_arsize,
		m_axi_memb_arvalid => m_axi_memb_arvalid,
		m_axi_memb_awaddr => m_axi_memb_awaddr,
		m_axi_memb_awburst => m_axi_memb_awburst,
		m_axi_memb_awcache => m_axi_memb_awcache,
		m_axi_memb_awlen => m_axi_memb_awlen,
		m_axi_memb_awlock => m_axi_memb_awlock,
		m_axi_memb_awprot => m_axi_memb_awprot,
		m_axi_memb_awready => m_axi_memb_awready,
		m_axi_memb_awsize => m_axi_memb_awsize,
		m_axi_memb_awvalid => m_axi_memb_awvalid,
		m_axi_memb_bready => m_axi_memb_bready,
		m_axi_memb_bresp => m_axi_memb_bresp,
		m_axi_memb_bvalid => m_axi_memb_bvalid,
		m_axi_memb_rdata => m_axi_memb_rdata,
		m_axi_memb_rlast => m_axi_memb_rlast,
		m_axi_memb_rready => m_axi_memb_rready,
		m_axi_memb_rresp => m_axi_memb_rresp,
		m_axi_memb_rvalid => m_axi_memb_rvalid,
		m_axi_memb_wdata => m_axi_memb_wdata,
		m_axi_memb_wlast => m_axi_memb_wlast,
		m_axi_memb_wready => m_axi_memb_wready,
		m_axi_memb_wstrb => m_axi_memb_wstrb,
		m_axi_memb_wvalid => m_axi_memb_wvalid,
	
		-- fetch
		fetch_instruction_address_plus_8 => fetch_instruction_address_plus_8,
		fetch_instruction_address_plus_4 => fetch_instruction_address_plus_4,
		fetch_instruction_address => fetch_instruction_address,
		fetch_instruction_data => fetch_instruction_data,
		fetch_instruction_data_valid => fetch_instruction_data_valid,
		fetch_instruction_data_ready => internal_instruction_data_ready,
		
		fetch_override_address => internal_override_address,
		fetch_override_address_valid => internal_override_address_valid,
		fetch_skip_jump => internal_skip_jump,
		fetch_wait_jump => internal_wait_jump,
		fetch_execute_delay_slot => internal_execute_delay_slot,
	
		stall => stall
	);
	mips_fetch_i0 : mips_fetch port map(
		enable => processor_enable and not stall,
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
		instruction_address_plus_4 => fetch_instruction_address_plus_4,
		instruction_address => fetch_instruction_address,
		instruction_data => fetch_instruction_data,
		instruction_data_valid => fetch_instruction_data_valid,
		instruction_data_ready => fetch_instruction_data_ready,
		
		override_address => fetch_override_address,
		override_address_valid => fetch_override_address_valid,
	
		skip_jump => fetch_skip_jump,
		wait_jump => fetch_wait_jump,
		execute_delay_slot => fetch_execute_delay_slot,
		
		error => fetch_error
	);
end mips_core_behavioral;
