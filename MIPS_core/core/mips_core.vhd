
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mips_core is
  Port ( 
	resetn : in std_logic;
	clock : in std_ulogic;
	
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
	component mips_execution_unit is
	port (
		resetn : in std_logic;
		enable : in std_logic;
		clock : in std_ulogic;									
			
		register_out : out std_logic_vector(31 downto 0);
		register_in : in std_logic_vector(31 downto 0);
		register_write : in std_logic;
		register_address : in std_logic_vector(5 downto 0);
	
	
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
	end component;
	
	component mips_debugger is
		port (
			resetn : in std_logic;
			clock : in std_logic;
			
			register_out : in std_logic_vector(31 downto 0);
			register_in : out std_logic_vector(31 downto 0);
			register_write : out std_logic;
			register_address : out std_logic_vector(4 downto 0);
			
			processor_enable : out std_logic;
	
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
	signal register_out : std_logic_vector(31 downto 0);
	signal register_in : std_logic_vector(31 downto 0);
	signal register_write : std_logic;
	signal register_address : std_logic_vector(5 downto 0);
	signal processor_enable : std_logic;
begin

	mips_execution_unit_i : mips_execution_unit port map(
		resetn => resetn,
		enable => processor_enable,
		clock => clock,
	
		register_out => register_out,
		register_in => register_in,
		register_write => register_write,
		register_address => register_address,
	
		m_axil_mema_awready => m_axil_mema_awready,
		m_axil_mema_wready => m_axil_mema_wready,
		m_axil_mema_bresp => m_axil_mema_bresp,
		m_axil_mema_bvalid => m_axil_mema_bvalid,
		m_axil_mema_arready => m_axil_mema_arready,
		m_axil_mema_rdata => m_axil_mema_rdata,
		m_axil_mema_rresp => m_axil_mema_rresp,
		m_axil_mema_rvalid => m_axil_mema_rvalid,
		m_axil_mema_awaddr => m_axil_mema_awaddr,
		m_axil_mema_awprot => m_axil_mema_awprot,
		m_axil_mema_awvalid => m_axil_mema_awvalid,
		m_axil_mema_wdata => m_axil_mema_wdata,
		m_axil_mema_wstrb => m_axil_mema_wstrb,
		m_axil_mema_wvalid => m_axil_mema_wvalid,
		m_axil_mema_bready => m_axil_mema_bready,
		m_axil_mema_araddr => m_axil_mema_araddr,
		m_axil_mema_arprot => m_axil_mema_arprot,
		m_axil_mema_arvalid => m_axil_mema_arvalid,
		m_axil_mema_rready => m_axil_mema_rready,
	
		m_axil_memb_awready => m_axil_memb_awready,
		m_axil_memb_wready => m_axil_memb_wready,
		m_axil_memb_bresp => m_axil_memb_bresp,
		m_axil_memb_bvalid => m_axil_memb_bvalid,
		m_axil_memb_arready => m_axil_memb_arready,
		m_axil_memb_rdata => m_axil_memb_rdata,
		m_axil_memb_rresp => m_axil_memb_rresp,
		m_axil_memb_rvalid => m_axil_memb_rvalid,
		m_axil_memb_awaddr => m_axil_memb_awaddr,
		m_axil_memb_awprot => m_axil_memb_awprot,
		m_axil_memb_awvalid => m_axil_memb_awvalid,
		m_axil_memb_wdata => m_axil_memb_wdata,
		m_axil_memb_wstrb => m_axil_memb_wstrb,
		m_axil_memb_wvalid => m_axil_memb_wvalid,
		m_axil_memb_bready => m_axil_memb_bready,
		m_axil_memb_araddr => m_axil_memb_araddr,
		m_axil_memb_arprot => m_axil_memb_arprot,
		m_axil_memb_arvalid => m_axil_memb_arvalid,
		m_axil_memb_rready => m_axil_memb_rready
		--,debug => LEDS
	);
	mips_debugger_i : mips_debugger port map(
		resetn => resetn,
		clock => clock,
			
		register_out => register_out,
		register_in => register_in,
		register_write => register_write,
		register_address => register_address,
			
		processor_enable => processor_enable,
	
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
