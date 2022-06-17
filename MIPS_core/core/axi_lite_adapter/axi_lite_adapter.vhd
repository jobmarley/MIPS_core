library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

use work.axi_helper.all;

-- This component ensure correct data out
-- It support discarding last address data and variable delay in axi connection
-- It is also required because some AXI peripherals (AXI BRAM Controller) set rvalid = '1' randomly
-- so that peripheral makes sure we are waiting for data and the data is valid
entity axi_lite_adapter is
	port ( 
	resetn : in std_logic;
	clock : in std_logic;
	
	discard : in std_logic;
	
	address_in : in std_logic_vector(31 downto 0);
	address_ready : out std_logic;
	address_valid : in std_logic;
	write_enable : in std_logic;
	write_strobe : in std_logic_vector(3 downto 0);
	data_in : in std_logic_vector(31 downto 0);
	
	data_ready : in std_logic;
	data_valid : out std_logic;
	data_out : out std_logic_vector(31 downto 0);
	
	error : out std_logic;
	
	m_axil_awready : in STD_LOGIC;
	m_axil_wready : in STD_LOGIC;
	m_axil_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axil_bvalid : in STD_LOGIC;
	m_axil_arready : in STD_LOGIC;
	m_axil_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
	m_axil_rvalid : in STD_LOGIC;
	m_axil_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axil_awvalid : out STD_LOGIC;
	m_axil_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
	m_axil_wvalid : out STD_LOGIC;
	m_axil_bready : out STD_LOGIC;
	m_axil_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
	m_axil_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
	m_axil_arvalid : out STD_LOGIC;
	m_axil_rready : out STD_LOGIC
	);
end axi_lite_adapter;

architecture axi_lite_adapter_behavioral of axi_lite_adapter is
	
	signal axil_out : axi_lite_port_out_t;
	signal axil_in : axi_lite_port_in_t;
	
	signal axil_resp : std_logic_vector(1 downto 0);
		
	type state_t is (state_write_address, state_read_data, state_read_data_pending, state_write_data);
	signal state : state_t;
	signal state_next : state_t;
	signal data_in_reg : STD_LOGIC_VECTOR ( 31 downto 0 );
	signal data_in_reg_next : STD_LOGIC_VECTOR ( 31 downto 0 );
	signal write_strobe_reg : STD_LOGIC_VECTOR ( 3 downto 0 );
	signal write_strobe_reg_next : STD_LOGIC_VECTOR ( 3 downto 0 );
	signal data_out_reg : STD_LOGIC_VECTOR ( 31 downto 0 );
	signal data_out_reg_next : STD_LOGIC_VECTOR ( 31 downto 0 );
	signal discard_reg : std_logic;
	signal discard_reg_next : std_logic;
begin
	
	m_axil_araddr <= axil_out.araddr;
    m_axil_arvalid <= axil_out.arvalid;
    m_axil_awaddr <= axil_out.awaddr;
    m_axil_awvalid <= axil_out.awvalid;
    m_axil_bready <= axil_out.bready;
    m_axil_rready <= axil_out.rready;
    m_axil_wdata <= axil_out.wdata;
    m_axil_wstrb <= axil_out.wstrb;
    m_axil_wvalid <= axil_out.wvalid;
    axil_in.arready <= m_axil_arready;
    axil_in.awready <= m_axil_awready;
    axil_in.bresp <= m_axil_bresp;
    axil_in.bvalid <= m_axil_bvalid;
    axil_in.rdata <= m_axil_rdata;
    axil_in.rresp <= m_axil_rresp;
    axil_in.rvalid <= m_axil_rvalid;
    axil_in.wready <= m_axil_wready;
	
	process(clock)
	begin
		if rising_edge(clock) then
			state <= state_next;
			data_in_reg <= data_in_reg_next;
			data_out_reg <= data_out_reg_next;
			write_strobe_reg <= write_strobe_reg_next;
			discard_reg <= discard_reg_next;
		end if;
	end process;
	
	process(
		resetn,
		state,
		data_in_reg,
		data_out_reg,
		address_valid,
		write_enable,
		data_in,
		data_out_reg_next,
		data_ready,
		axil_in,
		write_strobe,
		write_strobe_reg,
		discard_reg,
		discard
		)
		variable vhandshake : BOOLEAN;
		variable vhandshake2 : BOOLEAN;
	begin
		address_ready <= '0';
		data_valid <= '0';
		data_out <= x"00000000";
		AXI_LITE_idle(axil_out);
		error <= '0';
		
		if resetn = '0' then
			state_next <= state_write_address;
			data_in_reg_next <= (others => '0');
			data_out_reg_next <= (others => '0');
			write_strobe_reg_next <= (others => '0');
			discard_reg_next <= '0';
		else
			state_next <= state;
			data_in_reg_next <= data_in_reg;
			data_out_reg_next <= data_out_reg;
			write_strobe_reg_next <= write_strobe_reg;
			discard_reg_next <= discard_reg;
		
			if discard = '1' then
				discard_reg_next <= '1';
			end if;
			
			case state is
				when state_write_address =>
					address_ready <= '0';
					if address_valid = '1' then
						discard_reg_next <= '0';
						if write_enable = '1' then
							AXI_LITE_write_addr(axil_out, axil_in, address_in, vhandshake);
							AXI_LITE_write_data(axil_out, axil_in, data_in, write_strobe, vhandshake2);
							if vhandshake and vhandshake2 then
								address_ready <= '1';
							elsif vhandshake then
								address_ready <= '1';
								data_in_reg_next <= data_in;
								write_strobe_reg_next <= write_strobe;
								state_next <= state_write_data;
							end if;
						else
							AXI_LITE_read_addr(axil_out, axil_in, address_in, vhandshake);
							if vhandshake then
								address_ready <= '1';
								state_next <= state_read_data;
							end if;
						end if;
					end if;
				when state_read_data =>
					AXI_LITE_read_data(axil_out, axil_in, data_out_reg_next, axil_resp, vhandshake);
					if vhandshake then
						data_valid <= not (discard_reg or discard);
						data_out <= data_out_reg_next;
						if data_ready = '1' then
							state_next <= state_write_address;
						else
							state_next <= state_read_data_pending;
						end if;
					end if;
				when state_read_data_pending =>
					data_valid <= not (discard_reg or discard);
					data_out <= data_out_reg;
					if data_ready = '1' then
						state_next <= state_write_address;
					end if;
				when state_write_data =>
					AXI_LITE_write_data(axil_out, axil_in, data_in_reg, write_strobe_reg, vhandshake2);
					if vhandshake2 then
						state_next <= state_write_address;
					end if;
				when others =>
					state_next <= state_write_address;
			end case;
		end if;
	end process;

end axi_lite_adapter_behavioral;
