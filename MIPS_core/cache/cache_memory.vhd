library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.axi_helper.all;

entity cache_memory is
	--generic(
	--	BRAM_data_width : POSITIVE := 512;
	--	BRAM_address_width : POSITIVE := 8
	--);
	port (
	resetn : in std_logic;
	clock : in std_logic;
	
	-- port A
	porta_address : in std_logic_vector(31 downto 0);
	porta_address_ready : out std_logic;
	porta_address_valid : in std_logic;
	porta_read_data : out std_logic_vector(31 downto 0);
	porta_read_data_ready : in std_logic;
	porta_read_data_valid : out std_logic;
	
	-- port B
	portb_address : in std_logic_vector(31 downto 0);
	portb_address_ready : out std_logic;
	portb_address_valid : in std_logic;
	portb_read_data : out std_logic_vector(31 downto 0);
	portb_read_data_ready : in std_logic;
	portb_read_data_valid : out std_logic;
	portb_write_data : in std_logic_vector(31 downto 0);
	portb_write_strobe : in std_logic_vector(3 downto 0);
	portb_write : in std_logic;
	
	
	-- AXI4 memory 
	M_AXI_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_arlock : out STD_LOGIC;
    M_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_arready : in STD_LOGIC;
    M_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_arvalid : out STD_LOGIC;
    M_AXI_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_awlock : out STD_LOGIC;
    M_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_awready : in STD_LOGIC;
    M_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_awvalid : out STD_LOGIC;
    M_AXI_bready : out STD_LOGIC;
    M_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_bvalid : in STD_LOGIC;
    M_AXI_rdata : in STD_LOGIC_VECTOR ( 511 downto 0 );
    M_AXI_rlast : in STD_LOGIC;
    M_AXI_rready : out STD_LOGIC;
    M_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_rvalid : in STD_LOGIC;
    M_AXI_wdata : out STD_LOGIC_VECTOR ( 511 downto 0 );
    M_AXI_wlast : out STD_LOGIC;
    M_AXI_wready : in STD_LOGIC;
    M_AXI_wstrb : out STD_LOGIC_VECTOR ( 63 downto 0 );
    M_AXI_wvalid : out STD_LOGIC;
	
	-- memory interface a
	mem_clka : OUT STD_LOGIC;
	mem_ena : OUT STD_LOGIC;
	mem_wea : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
	mem_addra : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	mem_dina : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
	mem_douta : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
	mem_rsta : OUT std_logic;
	
	-- memory interface b
	mem_clkb : OUT STD_LOGIC;
	mem_enb : OUT STD_LOGIC;
	mem_web : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
	mem_addrb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	mem_dinb : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
	mem_doutb : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
	mem_rstb : OUT std_logic
	
	);
end cache_memory;

architecture cache_memory_behavioral of cache_memory is
		
	ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
	ATTRIBUTE X_INTERFACE_INFO : STRING;
	
	attribute X_INTERFACE_PARAMETER of mem_clka : signal is "MODE Master";--, MASTER_TYPE BRAM_CTRL, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, READ_WRITE_MODE READ_WRITE, READ_LATENCY 1";
	ATTRIBUTE X_INTERFACE_INFO of mem_clka : SIGNAL is "xilinx.com:interface:bram_rtl:1.0 BRAM CLK";
	ATTRIBUTE X_INTERFACE_INFO of mem_addra : SIGNAL is "xilinx.com:interface:bram_rtl:1.0 BRAM ADDR";
	ATTRIBUTE X_INTERFACE_INFO of mem_dina : SIGNAL is "xilinx.com:interface:bram_rtl:1.0 BRAM DIN";
	ATTRIBUTE X_INTERFACE_INFO of mem_douta : SIGNAL is "xilinx.com:interface:bram_rtl:1.0 BRAM DOUT";
	ATTRIBUTE X_INTERFACE_INFO of mem_ena : SIGNAL is "xilinx.com:interface:bram_rtl:1.0 BRAM EN";
	ATTRIBUTE X_INTERFACE_INFO of mem_rsta : SIGNAL is "xilinx.com:interface:bram_rtl:1.0 BRAM RST";
	ATTRIBUTE X_INTERFACE_INFO of mem_wea : SIGNAL is "xilinx.com:interface:bram_rtl:1.0 BRAM WE";
	
	
	function log2(v : NATURAL) return NATURAL is
		variable tmp : NATURAL := 0;
		variable result : NATURAL := 0;
	begin
		tmp := v;
		while tmp /= 1 loop
			tmp := tmp / 2;
			result := result + 1;
		end loop;
		return result;
	end function;
	
	constant MEMORY_DATA_WIDTH_BYTES : NATURAL := 64;												-- memory data width in bytes
	constant LINE_LENGTH : NATURAL := 8;															-- in number of data width
	constant LINE_LENGTH_BYTES : NATURAL := LINE_LENGTH * MEMORY_DATA_WIDTH_BYTES;
	constant SET_SIZE : NATURAL := 16;																-- number of entries in a set
	constant WAY_COUNT : NATURAL := 2;
	constant CACHE_ADDRESS_WIDTH_BITS : NATURAL := log2(WAY_COUNT * SET_SIZE * LINE_LENGTH);		-- number of bits in the cache bram address
	constant ADDRESS_LOW : NATURAL := log2(MEMORY_DATA_WIDTH_BYTES * LINE_LENGTH * SET_SIZE);
	
	type cache_line_info_t is record
		address : std_logic_vector(31 downto ADDRESS_LOW);
		dirty : std_logic;														-- '1' if that cache line has been written to
		updating : std_logic;
	end record;
		
	type cache_line_info_array_t is array (NATURAL range <>) of cache_line_info_t;
	type cache_set_t is array (NATURAL range <>) of cache_line_info_t;
	type cache_way_t is array (NATURAL range <>) of cache_set_t(SET_SIZE-1 downto 0);
	subtype cache_set_index_t is UNSIGNED(log2(SET_SIZE)-1 downto 0);
	subtype cache_way_index_t is UNSIGNED(log2(WAY_COUNT)-1 downto 0);
	
	
	-- for each element in a set, its a list of index of last used
	-- (cache_set_used_t(5)(0) = way_index) is the way_index where the most recent element 5 was used
	-- (cache_set_used_t(5)(1) = way_index) is the way_index where the second most recent element 5 was used
	type cache_set_used_t is array (NATURAL range <>) of NATURAL;
	type cache_way_used_t is array (NATURAL range <>) of cache_set_used_t(SET_SIZE-1 downto 0);
	type natural_array_t is array (NATURAL range <>) of NATURAL;
	
	signal cache_ways : cache_way_t(WAY_COUNT-1 downto 0);
	signal cache_ways_next : cache_way_t(WAY_COUNT-1 downto 0);
			
	signal cache_set_used_order : cache_way_used_t(WAY_COUNT-1 downto 0);
	signal cache_set_used_order_next : cache_way_used_t(WAY_COUNT-1 downto 0);
	
	function get_cache_address(way_index : NATURAL; set_index : NATURAL; data_address : std_logic_vector) return std_logic_vector is
	begin
		return std_logic_vector(TO_UNSIGNED(way_index, log2(WAY_COUNT)) & TO_UNSIGNED(way_index, log2(SET_SIZE)) & UNSIGNED(data_address));
	end function;
	
	function get_cache_address(way_index : NATURAL; address : std_logic_vector) return std_logic_vector is
	begin
		return std_logic_vector(TO_UNSIGNED(way_index, log2(WAY_COUNT))) & address(log2(LINE_LENGTH_BYTES*SET_SIZE)-1 downto log2(MEMORY_DATA_WIDTH_BYTES));
	end function;
	
	function get_set_index(address : std_logic_vector) return NATURAL is
	begin
		return TO_INTEGER(unsigned(address(ADDRESS_LOW downto log2(MEMORY_DATA_WIDTH_BYTES * LINE_LENGTH))));
	end function;
	
	procedure cache_test(address : std_logic_vector; cways : cache_way_t; variable hit : out std_logic; variable way_index : out NATURAL) is
		constant set_index : NATURAL := get_set_index(address);
	begin
		for iway in cways'LOW to cways'HIGH loop
			if address(31 downto ADDRESS_LOW) = cways(iway)(set_index).address(31 downto ADDRESS_LOW) then 
				hit := '1';
				way_index := iway;
				return;
			end if;
		end loop;
		
		hit := '0';
		way_index := 0;
	end procedure;
	
	
	signal m_axi_mem_port_out : axi4_port_out_t;
	signal m_axi_mem_port_in : axi4_port_in_t;
	
	signal axi4_read_resp : std_logic_vector(1 downto 0);
			
	type port_process_state_t is (
		port_process_state_idle,
		port_process_state_request_update,
		port_process_state_wait_update);
	-- port a
	signal porta_enable : std_logic;
	signal porta_data_pending : std_logic;
	signal porta_data_pending_next : std_logic;
	signal porta_mem_data_index : NATURAL;
	signal porta_mem_data_index_next : NATURAL;
	signal porta_addr_ok : std_logic;
	signal porta_data_ok : std_logic;
	signal porta_update_request_address : std_logic_vector(31 downto 0);
	signal porta_update_request : std_logic;
	signal porta_update_request_granted : std_logic;
	signal porta_address_reg : std_logic_vector(31 downto 0);
	signal porta_address_reg_next : std_logic_vector(31 downto 0);
	signal porta_cache_address_reg : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal porta_cache_address_reg_next : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal porta_state : port_process_state_t;
	signal porta_state_next : port_process_state_t;
	
	signal porta_debug_hit : std_logic;
	signal porta_debug_index : NATURAL;
	
	signal porta_set_index : NATURAL;
	signal porta_way_index : NATURAL;
	signal porta_hit : std_logic;
	
	-- port b
	signal portb_enable : std_logic;
	signal portb_data_pending : std_logic;
	signal portb_data_pending_next : std_logic;
	signal portb_mem_data_index : NATURAL;
	signal portb_mem_data_index_next : NATURAL;
	signal portb_addr_ok : std_logic;
	signal portb_data_ok : std_logic;
	signal portb_update_request_address : std_logic_vector(31 downto 0);
	signal portb_update_request : std_logic;
	signal portb_update_request_granted : std_logic;
	signal portb_address_reg : std_logic_vector(31 downto 0);
	signal portb_address_reg_next : std_logic_vector(31 downto 0);
	signal portb_cache_address_reg : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal portb_cache_address_reg_next : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal portb_state : port_process_state_t;
	signal portb_state_next : port_process_state_t;
	signal portb_cache_line_dirty : std_logic;
	signal portb_write_data_reg : std_logic_vector(31 downto 0);
	signal portb_write_data_reg_next : std_logic_vector(31 downto 0);
	signal portb_write_strobe_reg : std_logic_vector(3 downto 0);
	signal portb_write_strobe_reg_next : std_logic_vector(3 downto 0);
	signal portb_write_reg : std_logic;
	signal portb_write_reg_next : std_logic;
	
	signal portb_debug_hit : std_logic;
	signal portb_debug_index : NATURAL;
	
	signal portb_set_index : NATURAL;
	signal portb_way_index : NATURAL;
	signal portb_hit : std_logic;
	
	-- updater
	signal updater_mem_en : STD_LOGIC;
	signal updater_mem_we : STD_LOGIC_VECTOR(63 DOWNTO 0);
	signal updater_mem_addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
	signal updater_mem_din : STD_LOGIC_VECTOR(511 DOWNTO 0);
	signal updater_mem_dout : STD_LOGIC_VECTOR(511 DOWNTO 0);
	signal updater_beat_counter : UNSIGNED(7 downto 0);
	signal updater_beat_counter_next : UNSIGNED(7 downto 0);
	type updater_state_t is (
		updater_state_idle,
		updater_state_update_line_write_addr,
		updater_state_update_line_write_data,
		updater_state_update_line_read_addr,
		updater_state_update_line_read_data);
	signal updater_state : updater_state_t;
	signal updater_state_next : updater_state_t;
	signal updater_address : std_logic_vector(31 downto 0);
	signal updater_address_next : std_logic_vector(31 downto 0);
	signal updater_cache_address : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal updater_cache_address_next : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal updater_cache_start_address : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal updater_cache_start_address_next : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	signal updater_done : std_logic;
	signal updater_cache_line_update : std_logic;
	signal updater_way : NATURAL;
	signal updater_set_index : NATURAL;
	signal updater_line_info : cache_line_info_t;
	signal updater_round_robin : std_logic;
	signal updater_round_robin_next : std_logic;
	
begin
	mem_ena <= '1';
	mem_clka <= clock;
	mem_rsta <= resetn;
	
	
	M_AXI_araddr <= m_axi_mem_port_out.araddr;
    M_AXI_arburst <= m_axi_mem_port_out.arburst;
    M_AXI_arcache <= m_axi_mem_port_out.arcache;
    M_AXI_arlen <= m_axi_mem_port_out.arlen;
    M_AXI_arlock <= m_axi_mem_port_out.arlock;
    M_AXI_arprot <= m_axi_mem_port_out.arprot;
    M_AXI_arsize <= m_axi_mem_port_out.arsize;
    M_AXI_arvalid <= m_axi_mem_port_out.arvalid;
    M_AXI_awaddr <= m_axi_mem_port_out.awaddr;
    M_AXI_awburst <= m_axi_mem_port_out.awburst;
    M_AXI_awcache <= m_axi_mem_port_out.awcache;
    M_AXI_awlen <= m_axi_mem_port_out.awlen;
    M_AXI_awlock <= m_axi_mem_port_out.awlock;
    M_AXI_awprot <= m_axi_mem_port_out.awprot;
    M_AXI_awsize <= m_axi_mem_port_out.awsize;
    M_AXI_awvalid <= m_axi_mem_port_out.awvalid;
    M_AXI_bready <= m_axi_mem_port_out.bready;
    M_AXI_rready <= m_axi_mem_port_out.rready;
    M_AXI_wdata <= m_axi_mem_port_out.wdata;
    M_AXI_wlast <= m_axi_mem_port_out.wlast;
    M_AXI_wstrb <= m_axi_mem_port_out.wstrb;
    M_AXI_wvalid <= m_axi_mem_port_out.wvalid;
    m_axi_mem_port_in.arready <= M_AXI_arready;
    m_axi_mem_port_in.awready <= M_AXI_awready;
    m_axi_mem_port_in.bresp <= M_AXI_bresp;
    m_axi_mem_port_in.bvalid <= M_AXI_bvalid;
    m_axi_mem_port_in.rdata <= M_AXI_rdata;
    m_axi_mem_port_in.rlast <= M_AXI_rlast;
    m_axi_mem_port_in.rresp <= M_AXI_rresp;
    m_axi_mem_port_in.rvalid <= M_AXI_rvalid;
    m_axi_mem_port_in.wready <= M_AXI_wready;
	
	
	process (clock) is
	begin
		if rising_edge(clock) then
			updater_state <= updater_state_next;
			
			cache_ways <= cache_ways_next;
			cache_set_used_order <= cache_set_used_order_next;
			
			-- port a
			porta_data_pending <= porta_data_pending_next;
			porta_mem_data_index <= porta_mem_data_index_next;
			porta_address_reg <= porta_address_reg_next;
			porta_cache_address_reg <= porta_cache_address_reg_next;
			porta_state <= porta_state_next;
			
			-- port b
			portb_data_pending <= portb_data_pending_next;
			portb_mem_data_index <= portb_mem_data_index_next;
			portb_address_reg <= portb_address_reg_next;
			portb_cache_address_reg <= portb_cache_address_reg_next;
			portb_state <= portb_state_next;
			portb_write_data_reg <= portb_write_data_reg_next;
			portb_write_strobe_reg <= portb_write_strobe_reg_next;
			portb_write_reg <= portb_write_reg_next;
	
	
			-- updater
			updater_beat_counter <= updater_beat_counter_next;
			updater_state <= updater_state_next;
			updater_address <= updater_address_next;
			updater_cache_address <= updater_cache_address_next;
			updater_cache_start_address <= updater_cache_start_address_next;
			updater_round_robin <= updater_round_robin_next;
		end if;
	end process;

	
	porta_process : process (
		resetn,
		porta_state,
		porta_address,
		porta_address_valid,
		porta_read_data_ready,
		mem_douta,
		porta_update_request_granted,
		updater_done,
		porta_enable,
		porta_data_ok,
		porta_addr_ok,
		porta_data_pending,
		porta_cache_address_reg,
		porta_mem_data_index,
		porta_address_reg,
		cache_ways,
		updater_mem_en,
		updater_mem_we,
		updater_mem_addr,
		updater_mem_din
		)
		variable hit : std_logic;
		variable way_index : NATURAL;
		variable vcache_address : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
	begin
		
		mem_ena <= '1';
		mem_wea <= (others => '0');
		mem_addra <= porta_cache_address_reg;
		mem_dina <= (others => '0');
				
		porta_data_pending_next <= porta_data_pending;
		porta_mem_data_index_next <= porta_mem_data_index;
		porta_address_reg_next <= porta_address_reg;
		porta_cache_address_reg_next <= porta_cache_address_reg;
		porta_state_next <= porta_state;
		
		porta_enable <= '0';
		porta_addr_ok <= '0';
		porta_data_ok <= '0';
		porta_update_request_address <= (others => '0');
		porta_update_request <= '0';
		porta_hit <= '0';
		porta_set_index <= 0;
		porta_way_index <= 0;
		
		porta_address_ready <= '0';
		porta_read_data_valid <= '0';
		porta_read_data <= (others => '0');
		
		porta_debug_hit <= '0';
		porta_debug_index <= 0;
		
		if resetn = '0' then
			porta_data_pending_next <= '0';
			porta_mem_data_index_next <= 0;
			porta_address_reg_next <= (others => '0');
			porta_cache_address_reg_next <= (others => '0');
			porta_state_next <= port_process_state_idle;
		else
			case porta_state is
				when port_process_state_idle =>
					porta_enable <= not porta_data_pending or porta_data_ok;
					porta_data_ok <= '0';
					porta_addr_ok <= '0';
					porta_data_pending_next <= porta_addr_ok or (porta_data_pending and not porta_data_ok);
					porta_update_request <= '0';
		
					if porta_data_pending = '1' then
						mem_addra <= porta_cache_address_reg;
						porta_read_data <= mem_douta(porta_mem_data_index*32 + 31 downto porta_mem_data_index*32);
						porta_read_data_valid <= '1';
						if porta_read_data_ready = '1' then
							porta_data_ok <= '1';
						end if;
					end if;
		
					if porta_enable = '1' then
						porta_address_ready <= '1';
						if porta_address_valid = '1' then
							cache_test(porta_address, cache_ways, hit, way_index);
							porta_debug_hit <= hit;
							porta_debug_index <= way_index;
							if hit = '1' and cache_ways(way_index)(get_set_index(porta_address)).updating = '0' then
								-- cache hit
								vcache_address := get_cache_address(way_index, porta_address);
								porta_cache_address_reg_next <= vcache_address;
								mem_addra <= vcache_address;
								porta_mem_data_index_next <= TO_INTEGER(unsigned(porta_address(5 downto 2)));
								porta_addr_ok <= '1';
						
								porta_set_index <= get_set_index(porta_address);
								porta_way_index <= way_index;
								porta_hit <= '1';
							else
								porta_address_reg_next <= porta_address;
								porta_update_request <= '1';
								porta_update_request_address <= porta_address_reg_next;
								porta_mem_data_index_next <= TO_INTEGER(unsigned(porta_address(5 downto 2)));
								if porta_update_request_granted = '1' then
									porta_state_next <= port_process_state_wait_update;
								else
									porta_state_next <= port_process_state_request_update;
								end if;
							end if;
						end if;
					end if;
				when port_process_state_request_update =>
					porta_update_request <= '1';
					porta_update_request_address <= porta_address_reg;
					if porta_update_request_granted = '1' then
						porta_state_next <= port_process_state_wait_update;
					end if;
		
				when port_process_state_wait_update =>
					mem_ena <= updater_mem_en;
					mem_wea <= updater_mem_we;
					mem_addra <= updater_mem_addr;
					mem_dina <= updater_mem_din;
					updater_mem_dout <= mem_douta;
			
					if updater_done = '1' then
						-- no need to test cache hit since we just updated
						cache_test(porta_address_reg, cache_ways, hit, way_index);
						porta_cache_address_reg_next <= get_cache_address(way_index, porta_address_reg);
						mem_ena <= '1';
						mem_wea <= (others => '0');
						mem_addra <= get_cache_address(way_index, porta_address_reg);
						mem_dina <= (others => '0');
						porta_data_pending_next <= '1';
						porta_state_next <= port_process_state_idle;
					end if;
			end case;
		end if;
	end process;
	
	portb_process : process (
		resetn,
		portb_state,
		portb_address,
		portb_address_valid,
		portb_read_data_ready,
		mem_douta,
		portb_update_request_granted,
		updater_done,
		portb_enable,
		portb_data_ok,
		portb_addr_ok,
		portb_data_pending,
		portb_cache_address_reg,
		portb_mem_data_index,
		portb_write_reg,
		portb_address_reg,
		portb_write_strobe_reg,
		portb_write_data_reg,
		cache_ways,
		updater_mem_en,
		updater_mem_we,
		updater_mem_addr,
		updater_mem_din
		)
		variable hit : std_logic;
		variable way_index : NATURAL;
		variable int32Index : NATURAL;
	begin
		
		mem_enb <= '1';
		mem_web <= (others => '0');
		mem_addrb <= portb_cache_address_reg;
		mem_dinb <= (others => '0');
				
		portb_data_pending_next <= portb_data_pending;
		portb_mem_data_index_next <= portb_mem_data_index;
		portb_address_reg_next <= portb_address_reg;
		portb_cache_address_reg_next <= portb_cache_address_reg;
		portb_state_next <= portb_state;
		
		portb_enable <= '0';
		portb_addr_ok <= '0';
		portb_data_ok <= '0';
		portb_update_request_address <= (others => '0');
		portb_update_request <= '0';
		portb_cache_line_dirty <= '0';
		porta_hit <= '0';
		porta_set_index <= 0;
		porta_way_index <= 0;
		
		portb_address_ready <= '0';
		portb_read_data_valid <= '0';
		portb_read_data <= (others => '0');
		
		portb_debug_hit <= '0';
		portb_debug_index <= 0;
		
		portb_write_data_reg <= portb_write_data_reg_next;
		portb_write_strobe_reg <= portb_write_strobe_reg_next;
		portb_write_reg <= portb_write_reg_next;
		
		if resetn = '0' then
			portb_data_pending_next <= '0';
			portb_mem_data_index_next <= 0;
			portb_address_reg_next <= (others => '0');
			portb_cache_address_reg_next <= (others => '0');
			portb_write_data_reg_next <= (others => '0');
			portb_write_strobe_reg <= (others => '0');
			portb_write_reg <= '0';
			portb_state_next <= port_process_state_idle;
		else
			case portb_state is
				when port_process_state_idle =>
					portb_enable <= not portb_data_pending or portb_data_ok;
					portb_data_ok <= '0';
					portb_addr_ok <= '0';
					portb_data_pending_next <= (portb_addr_ok and not portb_write) or (portb_data_pending and not portb_data_ok);
					portb_update_request <= '0';
		
					if portb_data_pending = '1' then
						mem_addrb <= portb_cache_address_reg;
						portb_read_data <= mem_douta(portb_mem_data_index*32 + 31 downto portb_mem_data_index*32);
						portb_read_data_valid <= '1';
						if portb_read_data_ready = '1' then
							portb_data_ok <= '1';
						end if;
					end if;
		
					if portb_enable = '1' then
						portb_address_ready <= '1';
						if portb_address_valid = '1' then
							cache_test(portb_address, cache_ways, hit, way_index);
							portb_debug_hit <= hit;
							portb_debug_index <= way_index;
							if hit = '1' and cache_ways(way_index)(get_set_index(portb_address)).updating = '0' then
								-- cache hit
								portb_cache_address_reg_next <= get_cache_address(way_index, portb_address);
								mem_addrb <= get_cache_address(way_index, portb_address);
								int32Index := TO_INTEGER(unsigned(portb_address(5 downto 2)));
								if portb_write = '1' then
									mem_web(4 * int32Index + 3 downto 4 * int32Index) <= portb_write_strobe;
									mem_dinb(32 * int32Index + 31 downto 32 * int32Index) <= portb_write_data;
									portb_cache_line_dirty <= '1';
								end if;
								portb_mem_data_index_next <= int32Index;
								portb_addr_ok <= '1';
						
								portb_set_index <= get_set_index(portb_address);
								portb_way_index <= way_index;
								portb_hit <= '1';
							else
								portb_address_reg_next <= portb_address;
								portb_write_data_reg_next <= portb_write_data;
								portb_write_strobe_reg_next <= portb_write_strobe;
								portb_write_reg_next <= portb_write;
								portb_update_request <= '1';
								portb_update_request_address <= portb_address_reg_next;
								portb_mem_data_index_next <= TO_INTEGER(unsigned(portb_address(5 downto 2)));
								if portb_update_request_granted = '1' then
									portb_state_next <= port_process_state_wait_update;
								else
									portb_state_next <= port_process_state_request_update;
								end if;
							end if;
						end if;
					end if;
				when port_process_state_request_update =>
					portb_update_request <= '1';
					portb_update_request_address <= portb_address_reg;
					if portb_update_request_granted = '1' then
						portb_state_next <= port_process_state_wait_update;
					end if;
		
				when port_process_state_wait_update =>
					mem_enb <= updater_mem_en;
					mem_web <= updater_mem_we;
					mem_addrb <= updater_mem_addr;
					mem_dinb <= updater_mem_din;
					updater_mem_dout <= mem_doutb;
			
					if updater_done = '1' then
						-- no need to test cache hit since we just updated
						cache_test(portb_address_reg, cache_ways, hit, way_index);
						portb_cache_address_reg_next <= get_cache_address(way_index, portb_address_reg);
						mem_enb <= '1';
						mem_web <= (others => '0');
						mem_addrb <= get_cache_address(way_index, portb_address_reg);
						mem_dinb <= (others => '0');
						int32Index := TO_INTEGER(unsigned(portb_address(5 downto 2)));
						if portb_write_reg = '1' then
							mem_web(4 * int32Index + 3 downto 4 * int32Index) <= portb_write_strobe_reg;
							mem_dinb(32 * int32Index + 31 downto 32 * int32Index) <= portb_write_data_reg;
							portb_cache_line_dirty <= '1';
							portb_write_reg_next <= '0';
						else
							portb_data_pending_next <= '1';
						end if;
						portb_state_next <= port_process_state_idle;
					end if;
			end case;
		end if;
	end process;
	
	updater_process : process(
		resetn,
		updater_state,
		porta_update_request,
		porta_update_request_address,
		portb_update_request,
		portb_update_request_address,
		cache_ways,
		updater_mem_dout,
		m_axi_mem_port_in,
		updater_beat_counter,
		updater_cache_address,
		updater_address,
		updater_round_robin,
		cache_set_used_order,
		updater_cache_start_address
	) is
		variable axi4_handshake : BOOLEAN;
		variable axi4_handshake2 : BOOLEAN;
		variable vcache_address : std_logic_vector(CACHE_ADDRESS_WIDTH_BITS-1 downto 0);
		variable vlast_used_way : NATURAL;
		variable vset_index : NATURAL;
	begin
		updater_done <= '0';
		updater_mem_en <= '1';
		updater_mem_we <= (others => '0');
		updater_mem_addr <= (others => '0');
		updater_mem_din <= (others => '0');
	
		updater_cache_start_address_next <= updater_cache_start_address;
		updater_cache_address_next <= updater_cache_address;
		updater_state_next <= updater_state;
		updater_beat_counter_next <= updater_beat_counter;
		updater_cache_line_update <= '0';
		updater_round_robin_next <= updater_round_robin;
		
		if resetn = '0' then
			updater_line_info.address <= (others => '1');
			updater_line_info.dirty <= '0';
			updater_line_info.updating <= '0';
			
			updater_cache_address_next <= (others => '0');
			updater_cache_start_address_next <= (others => '0');
			updater_beat_counter_next <= x"00";
			updater_mem_addr <= (others => '0');
			updater_mem_din <= (others => '0');
			updater_round_robin_next <= '0';
			updater_state_next <= updater_state_idle;
		else
					
			AXI4_idle(m_axi_mem_port_out);
			
			case updater_state is
				when updater_state_idle =>
					-- select a bram port to use
					if porta_update_request = '1' and (updater_round_robin = '0' or portb_update_request = '0') then
						-- validate the request, and save parameters
						porta_update_request_granted <= '1';
						updater_address_next <= porta_update_request_address(31 downto 9) & "000000000";
						vset_index := get_set_index(porta_update_request_address);
						vlast_used_way := cache_set_used_order(WAY_COUNT-1)(vset_index);
						vcache_address := get_cache_address(vlast_used_way, porta_update_request_address);
						updater_cache_start_address_next <= vcache_address;
						updater_cache_address_next <= vcache_address;
						-- update cache line info
						updater_line_info.address <= porta_update_request_address(31 downto ADDRESS_LOW);
						updater_line_info.updating <= '1';
						updater_line_info.dirty <= '0';
				
						updater_cache_line_update <= '1';
				
						updater_round_robin_next <= '1';
				
						if cache_ways(vlast_used_way)(vset_index).dirty = '1' then
							updater_state_next <= updater_state_update_line_write_addr;
						else
							updater_state_next <= updater_state_update_line_read_addr;
						end if;
					elsif portb_update_request = '1' and (updater_round_robin = '1' or porta_update_request = '0') then
						-- validate the request, and save parameters
						portb_update_request_granted <= '1';
						updater_address_next <= portb_update_request_address(31 downto 9) & "000000000";
						vset_index := get_set_index(portb_update_request_address);
						vlast_used_way := cache_set_used_order(WAY_COUNT-1)(vset_index);
						vcache_address := get_cache_address(vlast_used_way, portb_update_request_address);
						updater_cache_start_address_next <= vcache_address;
						updater_cache_address_next <= vcache_address;
						-- update cache line info
						updater_line_info.address <= portb_update_request_address(31 downto ADDRESS_LOW);
						updater_line_info.updating <= '1';
						updater_line_info.dirty <= '0';
				
						updater_cache_line_update <= '1';
				
						updater_round_robin_next <= '0';
				
						if cache_ways(vlast_used_way)(vset_index).dirty = '1' then
							updater_state_next <= updater_state_update_line_write_addr;
						else
							updater_state_next <= updater_state_update_line_read_addr;
						end if;
					end if;
				when updater_state_update_line_write_addr =>
					updater_mem_addr <= updater_cache_address;
					AXI4_write_addr(m_axi_mem_port_out, m_axi_mem_port_in, updater_address, AXI4_BURST_INCR, AXI4_BURST_SIZE_64, 8, axi4_handshake);
					AXI4_write_data(m_axi_mem_port_out, m_axi_mem_port_in, updater_mem_dout, x"FFFFFFFFFFFFFFFF", '0', axi4_handshake2);
					if axi4_handshake = TRUE and axi4_handshake2 = TRUE then
						updater_cache_address_next <= std_logic_vector(unsigned(updater_cache_address) + 1);
						updater_mem_addr <= updater_cache_address_next;
						updater_beat_counter_next <= TO_UNSIGNED(7, 8);
						updater_state_next <= updater_state_update_line_write_data;
					elsif axi4_handshake = TRUE then
						updater_beat_counter_next <= TO_UNSIGNED(8, 8);
						updater_state_next <= updater_state_update_line_write_data;
					end if;
				when updater_state_update_line_write_data =>
					updater_mem_addr <= updater_cache_address;
					AXI4_write_data(m_axi_mem_port_out, m_axi_mem_port_in, updater_mem_dout, x"FFFFFFFFFFFFFFFF", '0', axi4_handshake);
					if axi4_handshake = TRUE then
						updater_cache_address_next <= std_logic_vector(unsigned(updater_cache_address) + 1);
						updater_mem_addr <= updater_cache_address_next;
						updater_beat_counter_next <= updater_beat_counter - 1;
						if updater_beat_counter = TO_UNSIGNED(0, 8) then
							updater_cache_address_next <= updater_cache_start_address_next;
							updater_state_next <= updater_state_update_line_read_addr;
						end if;
					end if;
			
				when updater_state_update_line_read_addr =>
					AXI4_read_addr(m_axi_mem_port_out, m_axi_mem_port_in, updater_address(31 downto 9) & "000000000", AXI4_BURST_INCR, AXI4_BURST_SIZE_64, 8, axi4_handshake);
					AXI4_read_data(m_axi_mem_port_out, m_axi_mem_port_in, updater_mem_din, axi4_read_resp, axi4_handshake2);
					if axi4_handshake = TRUE and axi4_handshake2 = TRUE then
						updater_cache_address_next <= std_logic_vector(unsigned(updater_cache_address) + 1);
						updater_mem_addr <= updater_cache_address;
						updater_mem_we <= x"FFFFFFFFFFFFFFFF";
						updater_beat_counter_next <= TO_UNSIGNED(7, 8);
						updater_state_next <= updater_state_update_line_read_data;
					elsif axi4_handshake = TRUE then
						updater_beat_counter_next <= TO_UNSIGNED(8, 8);
						updater_state_next <= updater_state_update_line_read_data;
					end if;
				when updater_state_update_line_read_data =>
					AXI4_read_data(m_axi_mem_port_out, m_axi_mem_port_in, updater_mem_din, axi4_read_resp, axi4_handshake);
					if axi4_handshake = TRUE then
						updater_cache_address_next <= std_logic_vector(unsigned(updater_cache_address) + 1);
						updater_mem_addr <= updater_cache_address;
						updater_mem_we <= x"FFFFFFFFFFFFFFFF";
						updater_beat_counter_next <= updater_beat_counter - 1;
						if updater_beat_counter = TO_UNSIGNED(1, 8) then
							-- update cache line info again to clear updating flag
							updater_done <= '1';
							updater_state_next <= updater_state_idle;
						end if;
					end if;
			
				when others =>
					updater_state_next <= updater_state_idle;
			end case;
		end if;
	end process;
	
	
	-- synchronize and update cache lines order based on most recently used
	-- last one is discarded when we hit a cache miss
	cache_line_infos_updater_process : process (
		resetn,
		cache_ways,
		cache_ways_next,
		updater_cache_line_update,
		updater_set_index,
		updater_way,
		updater_line_info,
		porta_way_index,
		porta_set_index,
		portb_way_index,
		portb_set_index,
		cache_set_used_order,
		porta_hit,
		portb_hit,
		updater_done
		)
		variable vtmp : NATURAL;
	begin
		
		cache_ways_next <= cache_ways;
		cache_set_used_order_next <= cache_set_used_order;
		
		if resetn = '0' then
			for iway in 0 to WAY_COUNT-1 loop
				for set_index in 0 to SET_SIZE-1 loop
					cache_ways_next(iway)(set_index).address <= x"FFFFFFFF";
					--cache_ways_next(iway)(set_index).cache_address <= std_logic_vector(TO_UNSIGNED(iway*SET_SIZE*LINE_LENGTH + set_index*LINE_LENGTH, CACHE_ADDRESS_WIDTH_BITS));
					cache_ways_next(iway)(set_index).dirty <= '0';
					cache_ways_next(iway)(set_index).updating <= '0';
				end loop;
			end loop;
		else
			-- clear updating flag
			if updater_done = '1' then
				for i in 0 to WAY_COUNT-1 loop
					for j in 0 to SET_SIZE-1 loop
						cache_ways_next(i)(j).updating <= '0';
					end loop;
				end loop;
			end if;
			
			if updater_cache_line_update = '1' then
				-- update the last used element for that set index
				vtmp := cache_set_used_order(WAY_COUNT-1)(updater_set_index);
				cache_ways_next(vtmp)(updater_set_index) <= updater_line_info;
				
				for i in 1 to WAY_COUNT-1 loop
					cache_set_used_order_next(i)(updater_set_index) <= cache_set_used_order(i - 1)(updater_set_index);
				end loop;
				cache_set_used_order_next(0)(updater_set_index) <= vtmp;
			else
				-- we do not update at the same time as the updater for simplicity
				if porta_hit = '1' and portb_hit = '1' and porta_set_index = portb_set_index then
					-- collision, we refresh the oldest one
					if porta_way_index > portb_way_index then
						vtmp := porta_way_index;
					else
						vtmp := portb_way_index;
					end if;
					
					for i in 1 to vtmp loop
						cache_set_used_order_next(i)(porta_set_index) <= cache_set_used_order(i - 1)(porta_set_index);
					end loop;
					cache_set_used_order_next(0)(porta_set_index) <= cache_set_used_order(vtmp)(porta_set_index);
				else
					-- port a
					if porta_hit = '1' then
						for i in 1 to porta_way_index loop
							cache_set_used_order_next(i)(porta_set_index) <= cache_set_used_order(i - 1)(porta_set_index);
						end loop;
						cache_set_used_order_next(0)(porta_set_index) <= cache_set_used_order(porta_way_index)(porta_set_index);
					end if;
			
					-- port b
					if portb_hit = '1' then
						for i in 1 to portb_way_index loop
							cache_set_used_order_next(i)(portb_set_index) <= cache_set_used_order(i - 1)(portb_set_index);
						end loop;
						cache_set_used_order_next(0)(portb_set_index) <= cache_set_used_order(portb_way_index)(portb_set_index);
					end if;
				end if;
				
			end if;
			
		end if;
	end process;
	
end cache_memory_behavioral;
