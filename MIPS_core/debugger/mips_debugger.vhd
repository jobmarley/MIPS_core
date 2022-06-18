library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mips_debugger is
	port (
		resetn : in std_logic;
		clock : in std_logic;
			
		register_out : in std_logic_vector(31 downto 0);
		register_in : out std_logic_vector(31 downto 0);
		register_write : out std_logic;
		register_address : out std_logic_vector(5 downto 0);
			
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
end mips_debugger;

architecture mips_debugger_behavioral of mips_debugger is
			
	type debugger_state_e is (
		debugger_state_idle,
		debugger_state_read_reg,
		debugger_state_read_resp,
		debugger_state_write_resp
		);
	signal debugger_state : debugger_state_e := debugger_state_idle;
	signal debugger_state_next : debugger_state_e := debugger_state_idle;
	
	signal processor_enable_reg : std_logic;
	signal processor_enable_reg_next : std_logic;
	
	signal leds_reg : std_logic_vector(7 downto 0) := x"00";
	signal leds_reg_next : std_logic_vector(7 downto 0) := x"00";
	
	signal s_axi_rresp_reg : std_logic_vector(1 downto 0);
	signal s_axi_rresp_reg_next : std_logic_vector(1 downto 0);
	signal s_axi_bresp_reg : std_logic_vector(1 downto 0);
	signal s_axi_bresp_reg_next : std_logic_vector(1 downto 0);
	signal s_axi_rdata_reg : std_logic_vector(31 downto 0);
	signal s_axi_rdata_reg_next : std_logic_vector(31 downto 0);
	
	function slv_select(data1 : std_logic_vector; data2 : std_logic_vector; s : std_logic_vector) return std_logic_vector is
		variable result : std_logic_vector(data1'LENGTH-1 downto 0);
	begin
		for i in 0 to s'HIGH loop
			if s(i) = '1' then
				result(i*8+7 downto i*8) := data2(i*8+7 downto i*8);
			else
				result(i*8+7 downto i*8) := data1(i*8+7 downto i*8);
			end if;
		end loop;
		return result;
	end function;
	
	constant AXI_RESP_OKAY : std_logic_vector(1 downto 0) := "00";
	constant AXI_RESP_EXOKAY : std_logic_vector(1 downto 0) := "01";
	constant AXI_RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
	constant AXI_RESP_DECERR : std_logic_vector(1 downto 0) := "11";
begin	
	processor_enable <= processor_enable_reg;
	debug <= leds_reg;
	
	s_axi_rresp <= s_axi_rresp_reg;
	s_axi_rdata <= s_axi_rdata_reg;
	s_axi_bresp <= s_axi_bresp_reg;
	
    clock_process : process(clock)
    begin
	    if (rising_edge(clock)) then
			debugger_state <= debugger_state_next;
			
			processor_enable_reg <= processor_enable_reg_next;
			leds_reg <= leds_reg_next;
			
			s_axi_rdata_reg <= s_axi_rdata_reg_next;
			s_axi_rresp_reg <= s_axi_rresp_reg_next;
			s_axi_bresp_reg <= s_axi_bresp_reg_next;
		end if;
	end process;
		
	process (resetn,
		debugger_state,
		s_axi_awaddr,
		s_axi_awprot,
		s_axi_awvalid,
		s_axi_wdata,
		s_axi_wstrb,
		s_axi_wvalid,
		s_axi_bready,
		s_axi_araddr,
		s_axi_arprot,
		s_axi_arvalid,
		s_axi_rready,
		register_out,
		s_axi_rresp_reg,
		s_axi_rdata_reg,
		s_axi_bresp_reg,
		processor_enable_reg,
		leds_reg
		)
	begin
		s_axi_awready <= '0';
		s_axi_wready <= '0';
		s_axi_bvalid <= '0';
		s_axi_arready <= '0';
		s_axi_rvalid <= '0';
		
		register_write <= '0';
		register_in <= (others => '0');
		register_address <= (others => '0');
		
		if resetn = '0' then
			s_axi_rresp_reg_next <= (others => '0');
			s_axi_rdata_reg_next <= (others => '0');
			s_axi_bresp_reg_next <= (others => '0');
			debugger_state_next <= debugger_state_idle;
			processor_enable_reg_next <= '0';
			leds_reg_next <= x"00";
		else
		
			s_axi_rresp_reg_next <= s_axi_rresp_reg;
			s_axi_rdata_reg_next <= s_axi_rdata_reg;
			s_axi_bresp_reg_next <= s_axi_bresp_reg;
			debugger_state_next <= debugger_state;
			processor_enable_reg_next <= processor_enable_reg;
			leds_reg_next <= leds_reg;
						
			case (debugger_state) is
				when debugger_state_idle =>
					if s_axi_arvalid = '1' then
						s_axi_arready <= '1';
						if s_axi_araddr(11 downto 0) = x"000" then
							s_axi_rdata_reg_next <= x"0000000" & "000" & processor_enable_reg;
							s_axi_rresp_reg_next <= AXI_RESP_OKAY;
							debugger_state_next <= debugger_state_read_resp;
						elsif s_axi_araddr(11 downto 0) = x"004" then
							s_axi_rdata_reg_next <= x"000000" & leds_reg;
							s_axi_rresp_reg_next <= AXI_RESP_OKAY;
							debugger_state_next <= debugger_state_read_resp;
						elsif s_axi_araddr(11 downto 7) = "00001" then -- REGISTERS
							register_address <= '0' & s_axi_araddr(6 downto 2);
							s_axi_rresp_reg_next <= AXI_RESP_OKAY;
							debugger_state_next <= debugger_state_read_reg;
						elsif s_axi_araddr(11 downto 7) = "00010" then -- COP0
							register_address <= '1' & s_axi_araddr(6 downto 2);
							s_axi_rresp_reg_next <= AXI_RESP_OKAY;
							debugger_state_next <= debugger_state_read_reg;
						else
							s_axi_rdata_reg_next <= (others => '0');
							s_axi_rresp_reg_next <= AXI_RESP_OKAY;
							debugger_state_next <= debugger_state_read_resp;
						end if ;
					elsif s_axi_awvalid = '1' and s_axi_wvalid = '1' then
						s_axi_awready <= '1';
						s_axi_wready <= '1';
						if s_axi_awaddr(11 downto 0) = x"000" then
							if s_axi_wstrb(0) = '1' then
								processor_enable_reg_next <= s_axi_wdata(0);
							end if;
						elsif s_axi_awaddr(11 downto 0) = x"004" then
							if s_axi_wstrb(0) = '1' then
								leds_reg_next <= s_axi_wdata(7 downto 0);
							end if;
						elsif s_axi_araddr(11 downto 7) = "00001" then
							register_address <= '0' & s_axi_araddr(6 downto 2);	-- REGISTERS
							register_in <= s_axi_wdata;--slv_select(register_out, s_axi_wdata, s_axi_wstrb); -- doesnt work 1 cycle latency on read
							register_write <= '1';
						elsif s_axi_araddr(11 downto 7) = "00010" then
							register_address <= '1' & s_axi_araddr(6 downto 2); -- COP0
							register_in <= s_axi_wdata;--slv_select(register_out, s_axi_wdata, s_axi_wstrb); -- doesnt work 1 cycle latency on read
							register_write <= '1';
						else
						end if ;
						s_axi_bresp_reg_next <= AXI_RESP_OKAY;
						debugger_state_next <= debugger_state_write_resp;
					end if;
				when debugger_state_read_reg =>
					s_axi_rdata_reg_next <= register_out;
					s_axi_rresp_reg_next <= AXI_RESP_OKAY;
					debugger_state_next <= debugger_state_read_resp;
				when debugger_state_read_resp =>
					s_axi_rvalid <= '1';
					if s_axi_rready = '1' then
						debugger_state_next <= debugger_state_idle;
					end if;
				when debugger_state_write_resp =>
					s_axi_bvalid <= '1';
					if s_axi_bready = '1' then
						debugger_state_next <= debugger_state_idle;
					end if;
				when others =>
					debugger_state_next <= debugger_state_idle;
			end case;
		end if;
	end process;
	
end mips_debugger_behavioral;
