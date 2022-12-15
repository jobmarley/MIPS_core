library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity mips_fetch is
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
end mips_fetch;

architecture mips_fetch_behavioral of mips_fetch is
	signal current_address : std_logic_vector(31 downto 0);
	signal current_address_next : std_logic_vector(31 downto 0);
	signal instruction_address_plus_8_reg : std_logic_vector(31 downto 0);
	signal instruction_address_plus_8_reg_next : std_logic_vector(31 downto 0);
	signal instruction_address_plus_4_reg : std_logic_vector(31 downto 0);
	signal instruction_address_plus_4_reg_next : std_logic_vector(31 downto 0);
	signal instruction_address_reg : std_logic_vector(31 downto 0);
	signal instruction_address_reg_next : std_logic_vector(31 downto 0);
	signal instruction_data_reg : std_logic_vector(31 downto 0);
	signal instruction_data_reg_next : std_logic_vector(31 downto 0);
	signal instruction_data_valid_reg : std_logic;
	signal instruction_data_valid_reg_next : std_logic;
	
	type state_t is (state_read_address, state_read_data, state_send_data, state_wait_override);
	signal state : state_t;
	signal state_next : state_t;
	
	signal wait_jump_reg : std_logic;
	signal wait_jump_reg_next : std_logic;
	signal skip_jump_reg : std_logic;
	signal skip_jump_reg_next : std_logic;
	signal execute_delay_slot_reg : std_logic;
	signal execute_delay_slot_reg_next : std_logic;
	
	signal override_address_reg : std_logic_vector(31 downto 0);
	signal override_address_reg_next : std_logic_vector(31 downto 0);
	signal override_address_valid_reg : std_logic;
	signal override_address_valid_reg_next : std_logic;
		
begin
	instruction_address_plus_8 <= instruction_address_plus_8_reg;
	instruction_address_plus_4 <= instruction_address_plus_4_reg;
	instruction_address <= instruction_address_reg;
	instruction_data <= instruction_data_reg;
	instruction_data_valid <= instruction_data_valid_reg;
	
	process(clock)
	begin
		if rising_edge(clock) then
			current_address <= current_address_next;
			instruction_address_plus_8_reg <= instruction_address_plus_8_reg_next;
			instruction_address_plus_4_reg <= instruction_address_plus_4_reg_next;
			instruction_address_reg <= instruction_address_reg_next;
			instruction_data_reg <= instruction_data_reg_next;
			instruction_data_valid_reg <= instruction_data_valid_reg_next;
			state <= state_next;
			
			wait_jump_reg <= wait_jump_reg_next;
			override_address_reg <= override_address_reg_next;
			override_address_valid_reg <= override_address_valid_reg_next;
			skip_jump_reg <= skip_jump_reg_next;
			execute_delay_slot_reg <= execute_delay_slot_reg_next;
		end if;
	end process;

	process(
		enable,
		resetn,
		
		current_address,
		state,
		
		instruction_address_plus_8_reg,
		instruction_address_plus_4_reg,
		instruction_address_reg,
		instruction_data_reg,
		instruction_data_valid_reg,
		instruction_data_ready,
	
		m_axi_mem_arready,
		m_axi_mem_rvalid,
		m_axi_mem_rdata,
		m_axi_mem_rresp,
		
		wait_jump,
		wait_jump_reg,
		override_address_valid,
		override_address_valid_reg,
		override_address,
		override_address_reg,
		skip_jump,
		skip_jump_reg,
		execute_delay_slot,
		execute_delay_slot_reg
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
		
		instruction_address_plus_8_reg_next <= instruction_address_plus_8_reg;
		instruction_address_plus_4_reg_next <= instruction_address_plus_4_reg;
		instruction_address_reg_next <= instruction_address_reg;
		instruction_data_reg_next <= instruction_data_reg;
		current_address_next <= current_address;
		state_next <= state;
		
		error <= '0';
		
		override_address_valid_reg_next <= override_address_valid_reg;
		override_address_reg_next <= override_address_reg;
		instruction_data_valid_reg_next <= instruction_data_valid_reg;
		wait_jump_reg_next <= wait_jump_reg;
		skip_jump_reg_next <= skip_jump_reg;
		execute_delay_slot_reg_next <= execute_delay_slot_reg;
				
		wait_jump_reg_next <= wait_jump_reg or wait_jump;
		if override_address_valid = '1' then
			override_address_valid_reg_next <= '1';
			override_address_reg_next <= override_address;
		end if;
			
		skip_jump_reg_next <= skip_jump_reg or skip_jump;
		execute_delay_slot_reg_next <= execute_delay_slot_reg or execute_delay_slot;
		
		instruction_data_valid_reg_next <= instruction_data_valid_reg and not instruction_data_ready;
		
		if resetn = '0' then
			current_address_next <= (others => '0');
			instruction_data_reg_next <= (others => '0');
			instruction_data_valid_reg_next <= '0';
			wait_jump_reg_next <= '0';
			override_address_reg_next <= (others => '0');
			override_address_valid_reg_next <= '0';
			instruction_address_reg_next <= (others => '0');
			instruction_address_plus_8_reg_next <= (others => '0');
			instruction_address_plus_4_reg_next <= (others => '0');
			skip_jump_reg_next <= '0';
			execute_delay_slot_reg_next <= '0';
		else
			
			case state is
				when state_read_address =>
					m_axi_mem_araddr <= current_address;
					instruction_address_reg_next <= current_address;
					instruction_address_plus_8_reg_next <= std_logic_vector(UNSIGNED(current_address) + 8);
					instruction_address_plus_4_reg_next <= std_logic_vector(UNSIGNED(current_address) + 4);
					
					m_axi_mem_arvalid <= '1';
					if m_axi_mem_arready = '1' then
						state_next <= state_read_data;
						current_address_next <= std_logic_vector(UNSIGNED(current_address) + 4);
					end if;
				when state_read_data =>
					if instruction_data_valid_reg = '0' or instruction_data_ready = '1' then
						m_axi_mem_rready <= '1';
						if m_axi_mem_rvalid = '1' then
							instruction_data_reg_next <= m_axi_mem_rdata;
							error <= m_axi_mem_rresp(1);
							
							state_next <= state_send_data;
							
						end if;
					end if;
				
				-- when enable is '0', execution will stop here
				when state_send_data =>
					if enable = '1' then
						if wait_jump_reg = '1' then
							state_next <= state_wait_override;
						else
							-- if wait jump, we dont execute because we dont know if we should or not
							instruction_data_valid_reg_next <= '1';
							state_next <= state_read_address;
						end if;
					end if;
				when state_wait_override =>
					-- first we need to execute the delay slot
					if execute_delay_slot_reg = '1' then
						instruction_data_valid_reg_next <= '1';
						execute_delay_slot_reg_next <= '0';
					elsif skip_jump_reg = '1' then
						override_address_valid_reg_next <= '0';
						skip_jump_reg_next <= '0';
						wait_jump_reg_next <= '0';
						state_next <= state_read_address;
					elsif override_address_valid_reg = '1' then
						current_address_next <= override_address_reg;
						override_address_valid_reg_next <= '0';
						skip_jump_reg_next <= '0';
						wait_jump_reg_next <= '0';
						state_next <= state_read_address;
					end if;
				when others =>
			end case;
		end if;
	end process;
end mips_fetch_behavioral;
