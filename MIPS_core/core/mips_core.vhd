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
	
	component mips_core_internal is
	  Port ( 
		resetn : in std_logic;
		clock : in std_ulogic;
		
		enable : in std_logic;
	
		breakpoint : out std_logic;
	
		register_port_in_a : in register_port_in_t;
		register_port_out_a : out register_port_out_t;
	
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
		m_axi_memb_wvalid : out STD_LOGIC
		);
	end component;
	
	signal processor_enable : std_logic;
	signal breakpoint : std_logic;
	signal register_port_in_a : register_port_in_t;
	signal register_port_out_a : register_port_out_t;
	
begin
	
	mips_debugger_i : mips_debugger port map(
		resetn => resetn,
		clock => clock,
			
		xdma_clock => xdma_clock,
	
		register_port_in_a => register_port_in_a,
		register_port_out_a => register_port_out_a,
			
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
	mips_core_internal_i : mips_core_internal port map(
		resetn => resetn,
		clock => clock,
		
		enable => processor_enable,
		breakpoint => breakpoint,
		
		register_port_in_a => register_port_in_a,
		register_port_out_a => register_port_out_a,
	
		-- memory port a
		m_axi_mema_araddr => m_axi_mema_araddr,
		m_axi_mema_arburst => m_axi_mema_arburst,
		m_axi_mema_arcache => m_axi_mema_arcache,
		m_axi_mema_arlen => m_axi_mema_arlen,
		m_axi_mema_arlock => m_axi_mema_arlock,
		m_axi_mema_arprot => m_axi_mema_arprot,
		m_axi_mema_arready => m_axi_mema_arready,
		m_axi_mema_arsize => m_axi_mema_arsize,
		m_axi_mema_arvalid => m_axi_mema_arvalid,
		m_axi_mema_awaddr => m_axi_mema_awaddr,
		m_axi_mema_awburst => m_axi_mema_awburst,
		m_axi_mema_awcache => m_axi_mema_awcache,
		m_axi_mema_awlen => m_axi_mema_awlen,
		m_axi_mema_awlock => m_axi_mema_awlock,
		m_axi_mema_awprot => m_axi_mema_awprot,
		m_axi_mema_awready => m_axi_mema_awready,
		m_axi_mema_awsize => m_axi_mema_awsize,
		m_axi_mema_awvalid => m_axi_mema_awvalid,
		m_axi_mema_bready => m_axi_mema_bready,
		m_axi_mema_bresp => m_axi_mema_bresp,
		m_axi_mema_bvalid => m_axi_mema_bvalid,
		m_axi_mema_rdata => m_axi_mema_rdata,
		m_axi_mema_rlast => m_axi_mema_rlast,
		m_axi_mema_rready => m_axi_mema_rready,
		m_axi_mema_rresp => m_axi_mema_rresp,
		m_axi_mema_rvalid => m_axi_mema_rvalid,
		m_axi_mema_wdata => m_axi_mema_wdata,
		m_axi_mema_wlast => m_axi_mema_wlast,
		m_axi_mema_wready => m_axi_mema_wready,
		m_axi_mema_wstrb => m_axi_mema_wstrb,
		m_axi_mema_wvalid => m_axi_mema_wvalid,
	
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
		m_axi_memb_wvalid => m_axi_memb_wvalid
	);

end mips_core_behavioral;
