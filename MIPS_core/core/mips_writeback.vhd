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
	
	-- registers
	register_port_in_a : out register_port_in_t;
	register_port_out_a : in register_port_out_t
	
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
		
		add_out_tvalid,
		add_out_tdata,
		add_out_tuser,
		
		add_tuser
	)
	begin
		
		if resetn = '0' then
		else			
			
		end if;
	end process;
end mips_writeback_behavioral;
