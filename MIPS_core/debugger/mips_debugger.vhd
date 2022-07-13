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
use IEEE.NUMERIC_STD.ALL;

entity mips_debugger is
	port (
		resetn : in std_logic;
		clock : in std_logic;
			
		xdma_clock : in std_logic;
	
		register_out : in std_logic_vector(31 downto 0);
		register_in : out std_logic_vector(31 downto 0);
		register_write : out std_logic;
		register_address : out std_logic_vector(5 downto 0);
			
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
	
	constant status_enable_index : NATURAL := 0;
	constant status_breakpoint_index : NATURAL := 1;
	
	signal status_reg : std_logic_vector(31 downto 0);
	signal status_reg_next : std_logic_vector(31 downto 0);
	
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
	
	
	signal interrupt_reg1 : std_logic := '0';
	signal interrupt_reg2 : std_logic := '0';
begin	
	processor_enable <= status_reg(status_enable_index);
	debug <= leds_reg;
	
	s_axi_rresp <= s_axi_rresp_reg;
	s_axi_rdata <= s_axi_rdata_reg;
	s_axi_bresp <= s_axi_bresp_reg;
	
	interrupt <= interrupt_reg2;
	
	clock_to_xdma_clock_sync : process(xdma_clock) is
	begin
		if rising_edge(xdma_clock) then
			interrupt_reg1 <= status_reg(status_breakpoint_index);
			interrupt_reg2 <= interrupt_reg1;
		end if;
	end process;
	
    clock_process : process(clock)
    begin
	    if (rising_edge(clock)) then
			debugger_state <= debugger_state_next;
			
			leds_reg <= leds_reg_next;
			status_reg <= status_reg_next;
			
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
		leds_reg,
		status_reg,
		breakpoint
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
			leds_reg_next <= x"00";
			status_reg_next <= (others => '0');
		else
		
			s_axi_rresp_reg_next <= s_axi_rresp_reg;
			s_axi_rdata_reg_next <= s_axi_rdata_reg;
			s_axi_bresp_reg_next <= s_axi_bresp_reg;
			debugger_state_next <= debugger_state;
			leds_reg_next <= leds_reg;
			status_reg_next <= status_reg;
						
			if breakpoint = '1' then
				status_reg_next(status_enable_index) <= '0';
				status_reg_next(status_breakpoint_index) <= '1';
			end if;
			
			case (debugger_state) is
				when debugger_state_idle =>
					if s_axi_arvalid = '1' then
						s_axi_arready <= '1';
						if s_axi_araddr(11 downto 0) = x"000" then
							s_axi_rdata_reg_next <= status_reg;
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
							status_reg_next <= slv_select(status_reg, s_axi_wdata, s_axi_wstrb);
						elsif s_axi_awaddr(11 downto 0) = x"004" then
							leds_reg_next <= slv_select(leds_reg, s_axi_wdata, s_axi_wstrb(0 downto 0));
						elsif s_axi_awaddr(11 downto 7) = "00001" then
							register_address <= '0' & s_axi_awaddr(6 downto 2);	-- REGISTERS
							register_in <= s_axi_wdata;--slv_select(register_out, s_axi_wdata, s_axi_wstrb); -- doesnt work 1 cycle latency on read
							register_write <= '1';
						elsif s_axi_awaddr(11 downto 7) = "00010" then
							register_address <= '1' & s_axi_awaddr(6 downto 2); -- COP0
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
