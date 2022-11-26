library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mips_utils.all;
use work.axi_helper.all;

entity mips_readmem is
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
	
	ready : out std_logic;
	error : out std_logic
	);
end mips_readmem;

architecture mips_readmem_behavioral of mips_readmem is
	type reader_state_t is (reader_state_read_address, reader_state_read_address2, reader_state_read_data, reader_state_read_data2);
	signal reader_state : reader_state_t;
	signal reader_state_next : reader_state_t;
	
	signal add_tuser : alu_add_out_tuser_t;
	
	-- read
	signal read_address_reg : std_logic_vector(31 downto 0);
	signal read_address_reg_next : std_logic_vector(31 downto 0);
	
	signal read_data : std_logic_vector(31 downto 0);
	signal read_data_next : std_logic_vector(31 downto 0);
	signal read_data_valid : std_logic;
	signal read_data_valid_next : std_logic;
	
	signal read_tuser_reg : alu_add_out_tuser_t;
	signal read_tuser_reg_next : alu_add_out_tuser_t;
	
	-- write
	type writer_state_t is (writer_state_address, writer_state_address2, writer_state_data, writer_state_data2, writer_state_resp);
	signal writer_state : writer_state_t;
	signal writer_state_next : writer_state_t;
	
	signal write_address_reg : std_logic_vector(31 downto 0);
	signal write_address_reg_next : std_logic_vector(31 downto 0);
	
	signal write_add_tuser_reg : alu_add_out_tuser_t;
	signal write_add_tuser_reg_next : alu_add_out_tuser_t;
	
	function sign_extend(u : std_logic_vector; l : natural) return std_logic_vector is
        alias uu: std_logic_vector(u'LENGTH-1 downto 0) is u;
		variable result : std_logic_vector(l-1 downto 0);
	begin
		result := (others => uu(uu'LENGTH-1));
		result(uu'LENGTH-1 downto 0) := uu;
		return result;
	end function;
	
begin
	add_tuser <= slv_to_add_out_tuser(add_out_tuser);
	
	process(clock)
	begin
		if rising_edge(clock) then
			reader_state <= reader_state_next;
			read_tuser_reg <= read_tuser_reg_next;
			read_address_reg <= read_address_reg_next;
			read_data <= read_data_next;
			read_data_valid <= read_data_valid_next;
			
			writer_state <= writer_state_next;
			write_address_reg <= write_address_reg_next;
			write_add_tuser_reg <= write_add_tuser_reg_next;
		end if;
	end process;
	
	process (
		resetn,
		
		reader_state,
		read_address_reg,
		
		add_out_tdata,
		add_out_tvalid,
		add_tuser,
		read_tuser_reg,
		
		read_data,
		read_data_valid,
		
		m_axi_mem_arready,
		m_axi_mem_rvalid,
		m_axi_mem_rdata,
		m_axi_mem_rresp,
		m_axi_mem_rlast,
		
		writer_state,
		write_address_reg,
		write_add_tuser_reg,
	
		m_axi_mem_awready,
		m_axi_mem_wready,
		m_axi_mem_bvalid,
		m_axi_mem_bresp
	)
	begin
		register_port_in_a.address <= read_tuser_reg.rt;
		register_port_in_a.write_enable <= read_data_valid;
		register_port_in_a.write_data <= (others => '0');
		register_port_in_a.write_strobe <= "0000";
		register_port_in_a.write_pending <= '0';
		
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
		
		m_axi_mem_arburst <= "01";
		m_axi_mem_arcache <= (others => '0');
		m_axi_mem_arlen <= (others => '0');
		m_axi_mem_arlock <= '0';
		m_axi_mem_arprot <= (others => '0');
		m_axi_mem_arsize <= "101";
		m_axi_mem_awburst <= (others => '0');
		m_axi_mem_awcache <= (others => '0');
		m_axi_mem_awlen <= (others => '0');
		m_axi_mem_awlock <= '0';
		m_axi_mem_awprot <= (others => '0');
		m_axi_mem_awsize <= "101";
		m_axi_mem_wlast <= '0';
		
		ready <= '0';
		error <= '0';
		
		reader_state_next <= reader_state;
		read_address_reg_next <= read_address_reg;
		read_tuser_reg_next <= read_tuser_reg;
		read_data_valid_next <= '0';
		
		writer_state_next <= writer_state;
		write_address_reg_next <= write_address_reg;
		write_add_tuser_reg_next <= write_add_tuser_reg;
		
		
		if resetn = '0' then
			reader_state_next <= reader_state_read_address;
			read_address_reg_next <= (others => '0');
		else
			-- handle axi read
			case reader_state is
				when reader_state_read_address =>
					ready <= '1';
					m_axi_mem_araddr <= add_out_tdata(31 downto 0);
					m_axi_mem_arvalid <= add_tuser.load and add_out_tvalid;
					read_address_reg_next <= add_out_tdata(31 downto 0);
					read_tuser_reg_next <= add_tuser;
					if m_axi_mem_arready = '1' then
						reader_state_next <= reader_state_read_data;
					elsif add_tuser.load = '1' and add_out_tvalid = '1' then
						reader_state_next <= reader_state_read_address2;
					end if;
				when reader_state_read_address2 =>
					m_axi_mem_araddr <= read_address_reg;
					m_axi_mem_arvalid <= '1';
					if m_axi_mem_arready = '1' then
						reader_state_next <= reader_state_read_data;
					end if;
				when reader_state_read_data =>
					m_axi_mem_rready <= '1';
					if m_axi_mem_rvalid = '1' then
						error <= m_axi_mem_rresp(1);
						read_data_valid_next <= '1';
						reader_state_next <= reader_state_read_address;
					end if;
				when others =>
			end case;
			
			-- handle axi write
			case writer_state is
				when writer_state_address =>
					ready <= '1';
					m_axi_mem_awaddr <= add_out_tdata(31 downto 0);
					m_axi_mem_awvalid <= add_tuser.store and add_out_tvalid;
					m_axi_mem_wvalid <= add_tuser.store and add_out_tvalid;
					m_axi_mem_wdata <= add_tuser.store_data;
					m_axi_mem_wlast <= '1';
					write_address_reg_next <= add_out_tdata(31 downto 0);
					write_add_tuser_reg_next <= add_tuser;
					if add_tuser.store = '1' and add_out_tvalid = '1' then
						if m_axi_mem_awready = '1' and m_axi_mem_wready = '1' then
							writer_state_next <= writer_state_resp;
						elsif m_axi_mem_awready = '1' then
							writer_state_next <= writer_state_data;
						else
							writer_state_next <= writer_state_address2;
						end if;
					end if;
				when writer_state_address2 =>
					m_axi_mem_awaddr <= write_address_reg(31 downto 0);
					m_axi_mem_awvalid <= '1';
					m_axi_mem_wvalid <= '1';
					m_axi_mem_wdata <= write_add_tuser_reg.store_data;
					m_axi_mem_wlast <= '1';
					if m_axi_mem_awready = '1' and m_axi_mem_wready = '1' then
						writer_state_next <= writer_state_resp;
					elsif m_axi_mem_awready = '1' then
						writer_state_next <= writer_state_data;
					end if;
				when writer_state_data =>
					m_axi_mem_wvalid <= '1';
					m_axi_mem_wdata <= write_add_tuser_reg.store_data;
					m_axi_mem_wlast <= '1';
					if m_axi_mem_wready = '1' then
						writer_state_next <= writer_state_resp;
					end if;
				when writer_state_resp =>
					m_axi_mem_bready <= '1';
					if m_axi_mem_bvalid = '1' then
						error <= m_axi_mem_bresp(1);
						writer_state_next <= writer_state_address;
					end if;
				when others =>
			end case;
			
			-- handle the register port and strobe
			if read_data_valid = '1' then
				register_port_in_a.write_enable <= '1';
				case read_tuser_reg.memop_type is
					when memory_op_type_byte =>
						register_port_in_a.write_strobe <= "1111";
						if read_tuser_reg.signed = '1' then
							case read_address_reg(1 downto 0) is
								when "00" =>
									register_port_in_a.write_data <= sign_extend(read_data(7 downto 0), 32);
								when "01" =>
									register_port_in_a.write_data <= sign_extend(read_data(15 downto 8), 32);
								when "10" =>
									register_port_in_a.write_data <= sign_extend(read_data(23 downto 16), 32);
								when "11" =>
									register_port_in_a.write_data <= sign_extend(read_data(31 downto 24), 32);
								when others =>
							end case;
						else
							case read_address_reg(1 downto 0) is
								when "00" =>
									register_port_in_a.write_data <= x"000000" & read_data(7 downto 0);
								when "01" =>
									register_port_in_a.write_data <= x"000000" & read_data(15 downto 8);
								when "10" =>
									register_port_in_a.write_data <= x"000000" & read_data(23 downto 16);
								when "11" =>
									register_port_in_a.write_data <= x"000000" & read_data(31 downto 24);
								when others =>
							end case;
						end if;
					when memory_op_type_half =>
						register_port_in_a.write_strobe <= "1111";
						if read_tuser_reg.signed = '1' then
							if read_address_reg(1 downto 0) = "10" then
								register_port_in_a.write_data <= sign_extend(read_data(31 downto 16), 32);
							else
								register_port_in_a.write_data <= sign_extend(read_data(15 downto 0), 32);
							end if;
						else
							if read_address_reg(1 downto 0) = "10" then
								register_port_in_a.write_data <= x"0000" & read_data(31 downto 16);
							else
								register_port_in_a.write_data <= x"0000" & read_data(15 downto 0);
							end if;
						end if;
					when memory_op_type_word =>
						register_port_in_a.write_strobe <= "1111";
						register_port_in_a.write_data <= read_data;
					
					-- NOTE: those two are dependent on endianess
					when memory_op_type_half_left =>
						case read_address_reg(1 downto 0) is
							when "00" =>
								register_port_in_a.write_strobe <= "1000";
								register_port_in_a.write_data <= read_data(7 downto 0) & x"000000";
							when "01" =>
								register_port_in_a.write_strobe <= "1100";
								register_port_in_a.write_data <= read_data(15 downto 0) & x"0000";
							when "10" =>
								register_port_in_a.write_strobe <= "1110";
								register_port_in_a.write_data <= read_data(23 downto 0) & x"00";
							when "11" =>
								register_port_in_a.write_strobe <= "1111";
								register_port_in_a.write_data <= read_data;
							when others =>
						end case;
					when memory_op_type_half_right =>
						case read_address_reg(1 downto 0) is
							when "00" =>
								register_port_in_a.write_strobe <= "1111";
								register_port_in_a.write_data <= read_data;
							when "01" =>
								register_port_in_a.write_strobe <= "0111";
								register_port_in_a.write_data <= x"00" & read_data(31 downto 8);
							when "10" =>
								register_port_in_a.write_strobe <= "0011";
								register_port_in_a.write_data <= x"0000" & read_data(31 downto 16);
							when "11" =>
								register_port_in_a.write_strobe <= "0001";
								register_port_in_a.write_data <= x"000000" & read_data(31 downto 24);
							when others =>
						end case;
					when others =>
							
				end case;
			end if;
		end if;
	end process;

end mips_readmem_behavioral;
