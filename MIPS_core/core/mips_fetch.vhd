library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity mips_fetch is
	port(
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
	
		instruction_data : out std_logic_vector(31 downto 0);
		instruction_data_valid : out std_logic;
		instruction_data_ready : in std_logic;
		
		--override_address : in std_logic_vector(31 downto 0);
		--override_address_valid : in std_logic;
	
		error : out std_logic
	);
end mips_fetch;

architecture mips_fetch_behavioral of mips_fetch is
	signal current_address : std_logic_vector(31 downto 0);
	signal current_address_next : std_logic_vector(31 downto 0);
	signal instruction_data_reg : std_logic_vector(31 downto 0);
	signal instruction_data_reg_next : std_logic_vector(31 downto 0);
	signal instruction_data_valid_reg : std_logic;
	signal instruction_data_valid_reg_next : std_logic;
	
	type state_t is (read_address, read_data);
	signal state : state_t;
	signal state_next : state_t;
begin
	instruction_data <= instruction_data_reg;
	instruction_data_valid <= instruction_data_valid_reg;
	
	process(clock)
	begin
		if rising_edge(clock) then
			current_address <= current_address_next;
			instruction_data_reg <= instruction_data_reg_next;
			instruction_data_valid_reg <= instruction_data_valid_reg_next;
			state <= state_next;
		end if;
	end process;

	process(
		resetn,
		
		current_address,
		state,
		
		instruction_data_reg,
		instruction_data_valid_reg,
		instruction_data_ready,
	
		m_axi_mem_arready,
		m_axi_mem_rvalid,
		m_axi_mem_rdata,
		m_axi_mem_rresp--,
		
		--override_address,
		--override_address_valid
		)
	begin
		m_axi_mem_awaddr <= (others => '0');
		m_axi_mem_awprot <= (others => '0');
		m_axi_mem_awvalid <= '0';
		m_axi_mem_wdata <= (others => '0');
		m_axi_mem_wstrb <= (others => '0');
		m_axi_mem_wvalid <= '0';
		m_axi_mem_bready <= '0';
		m_axi_mem_araddr <= (others => '0');
		m_axi_mem_arprot <= (others => '0');
		m_axi_mem_arvalid <= '0';
		m_axi_mem_rready <= '0';
		
		m_axi_mem_arburst <= "00";
		m_axi_mem_arcache <= (others => '0');
		m_axi_mem_arlen <= (others => '0');
		m_axi_mem_arlock <= '0';
		m_axi_mem_arprot <= (others => '0');
		m_axi_mem_arsize <= "110";
		m_axi_mem_awburst <= (others => '0');
		m_axi_mem_awcache <= (others => '0');
		m_axi_mem_awlen <= (others => '0');
		m_axi_mem_awlock <= '0';
		m_axi_mem_awprot <= (others => '0');
		m_axi_mem_awsize <= (others => '0');
		m_axi_mem_wlast <= '0';
		
		instruction_data_reg_next <= instruction_data_reg;
		current_address_next <= current_address;
		state_next <= state;
		
		error <= '0';
		
		instruction_data_valid_reg_next <= instruction_data_valid_reg and not instruction_data_ready;
		
		if resetn = '0' then
			current_address_next <= (others => '0');
			instruction_data_reg_next <= (others => '0');
			instruction_data_valid_reg_next <= '0';
		else
			case state is
				when read_address =>
					-- override_address_valid = '1' then
					--	m_axi_mem_araddr <= override_address;
					--	instruction_data_valid_reg_next <= '0';
					--else
						m_axi_mem_araddr <= current_address;
					--end if;
					m_axi_mem_arvalid <= '1';
					if m_axi_mem_arready = '1' then
						state_next <= read_data;
						current_address_next <= std_logic_vector(UNSIGNED(current_address) + 4);
					end if;
				when read_data =>
					if instruction_data_valid_reg = '0' or instruction_data_ready = '1' then--or override_address_valid = '1' then
						m_axi_mem_rready <= '1';
						if m_axi_mem_rvalid = '1' then
							instruction_data_valid_reg_next <= '1';
							instruction_data_reg_next <= m_axi_mem_rdata;
							error <= m_axi_mem_rresp(1);
							state_next <= read_address;
						end if;
					end if;
				when others =>
			end case;
		end if;
	end process;
end mips_fetch_behavioral;
