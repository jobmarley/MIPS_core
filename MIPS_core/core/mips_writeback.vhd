library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mips_utils.all;

entity mips_writeback is
	port (
	resetn : in std_logic;
	clock : in std_logic;
	
	-- alu
	add_out_tvalid : in std_logic;
	add_out_tdata : in std_logic_vector(32 downto 0);
	add_out_tuser : in std_logic_vector(43 downto 0);
		
	sub_out_tvalid : in std_logic;
	sub_out_tdata : in std_logic_vector(32 downto 0);
	sub_out_tuser : in std_logic_vector(4 downto 0);
	
	and_out_tvalid : in std_logic;
	and_out_tdata : in std_logic_vector(31 downto 0);
	and_out_tuser : in std_logic_vector(5 downto 0);
	
	or_out_tvalid : in std_logic;
	or_out_tdata : in std_logic_vector(31 downto 0);
	or_out_tuser : in std_logic_vector(5 downto 0);
	
	xor_out_tvalid : in std_logic;
	xor_out_tdata : in std_logic_vector(31 downto 0);
	xor_out_tuser : in std_logic_vector(5 downto 0);
	
	nor_out_tvalid : in std_logic;
	nor_out_tdata : in std_logic_vector(31 downto 0);
	nor_out_tuser : in std_logic_vector(5 downto 0);
	
	-- registers
	register_port_in_a : out register_port_in_t;
	register_port_out_a : in register_port_out_t;
	register_port_in_b : out register_port_in_t;
	register_port_out_b : in register_port_out_t
	
	);
end mips_writeback;

architecture mips_writeback_behavioral of mips_writeback is
	signal add_tuser : alu_add_out_tuser_t;
begin
	add_tuser <= slv_to_add_out_tuser(add_out_tuser);
	
	register_port_in_a.address <= add_out_tuser(4 downto 0);
	register_port_in_a.write_enable <= add_out_tvalid and not add_tuser.load and not add_tuser.store;
	register_port_in_a.write_data <= add_out_tdata(31 downto 0);
	register_port_in_a.write_strobe <= x"F";
	register_port_in_a.write_pending <= '0';
	
	process(clock)
	begin
		if rising_edge(clock) then
		end if;
	end process;
	
	process (
		resetn,
		
		and_out_tdata,
		and_out_tuser,
		and_out_tvalid,
		or_out_tdata,
		or_out_tuser,
		or_out_tvalid,
		xor_out_tdata,
		xor_out_tuser,
		xor_out_tvalid,
		nor_out_tdata,
		nor_out_tuser,
		nor_out_tvalid
		
	)
		variable andorxornor : std_logic_vector(3 downto 0);
	begin
		
		register_port_in_b.address <= (others => '0');
		register_port_in_b.write_data <= (others => '0');
		register_port_in_b.write_enable <= '0';
		register_port_in_b.write_pending <= '0';
		register_port_in_b.write_strobe <= x"0";
		
		andorxornor := and_out_tvalid & or_out_tvalid & xor_out_tvalid & nor_out_tvalid;
		if resetn = '0' then
		else
			case (andorxornor) is
				when "1000" =>
					register_port_in_b.address <= and_out_tuser(4 downto 0);
					register_port_in_b.write_data <= and_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0100" =>
					register_port_in_b.address <= or_out_tuser(4 downto 0);
					register_port_in_b.write_data <= or_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0010" =>
					register_port_in_b.address <= xor_out_tuser(4 downto 0);
					register_port_in_b.write_data <= xor_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when "0001" =>
					register_port_in_b.address <= nor_out_tuser(4 downto 0);
					register_port_in_b.write_data <= nor_out_tdata;
					register_port_in_b.write_enable <= '1';
					register_port_in_b.write_pending <= '0';
					register_port_in_b.write_strobe <= x"F";
				when others =>
			end case;
		end if;
	end process;
end mips_writeback_behavioral;
