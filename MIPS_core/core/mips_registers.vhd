library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_utils.all;

entity mips_registers is
	generic (
		port_type1_count : NATURAL
	);
	port (
		resetn : in std_logic;
		clock : in std_logic;
		
		port_in : in register_port_in_array_t(port_type1_count-1 downto 0);
		port_out : out register_port_out_array_t(port_type1_count-1 downto 0)
	
	);
end mips_registers;

architecture mips_registers_behavioral of mips_registers is
	constant register_count : NATURAL := 64;
	signal registers : slv32_array_t(register_count-1 downto 0);
	signal registers_next : slv32_array_t(register_count-1 downto 0);
	signal registers_pending : std_logic_vector(register_count-1 downto 0);
	signal registers_pending_next : std_logic_vector(register_count-1 downto 0);
	
	signal port_out_data_reg : slv32_array_t(port_type1_count-1 downto 0);
	signal port_out_data_reg_next : slv32_array_t(port_type1_count-1 downto 0);
	signal port_out_pending_reg : std_logic_vector(port_type1_count-1 downto 0);
	signal port_out_pending_reg_next : std_logic_vector(port_type1_count-1 downto 0);
begin


	process(clock)
	begin
		if rising_edge(clock) then
			registers <= registers_next;
			registers_pending <= registers_pending_next;
			
			-- register $0 is hardcoded 0
			registers(0) <= (others => '0');
			registers_pending(0) <= '0';
			
			port_out_data_reg <= port_out_data_reg_next;
			port_out_pending_reg <= port_out_pending_reg_next;
		end if;
	end process;
	
	process(
		resetn,
		
		port_in,
		registers,
		registers_pending,
		
		port_out_data_reg,
		port_out_pending_reg
		)
		variable vregister_index : NATURAL;
	begin
		
		for i in port_type1_count-1 downto 0 loop
			port_out(i).data <= port_out_data_reg(i);
			port_out(i).pending <= port_out_pending_reg(i);
		end loop;
		
		registers_next <= registers;
		registers_pending_next <= registers_pending;
		port_out_data_reg_next <= port_out_data_reg;
		port_out_pending_reg_next <= port_out_pending_reg;
		
		if resetn = '0' then
			registers_next <= (others => (others => '0'));
			registers_pending_next <= (others => '0');
			port_out_data_reg_next <= (others => (others => '0'));
			port_out_pending_reg_next <= (others => '0');
		else
			
			for i in port_type1_count-1 downto 0 loop
				vregister_index := TO_INTEGER(UNSIGNED(port_in(i).address));
				port_out_data_reg_next(i) <= registers(vregister_index);
				port_out_pending_reg_next(i) <= registers_pending(vregister_index);
				if port_in(i).write_enable = '1' then
					registers_pending_next(vregister_index) <= port_in(i).write_pending;
					for j in 3 downto 0 loop
						if port_in(i).write_strobe(j) = '1' then
							registers_next(vregister_index)(j * 8 + 7 downto j * 8) <= port_in(i).write_data(j * 8 + 7 downto j * 8);
						end if;
					end loop;
				end if;
			end loop;
		end if;
	end process;
end mips_registers_behavioral;
