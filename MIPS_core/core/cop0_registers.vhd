library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_utils.all;

entity cop0_registers is
	generic(
		port_count : NATURAL
	);
	port(
		resetn : in std_logic;
		clock : in std_logic;
	
		ports_in : in cop0_register_port_in_array_t(port_count-1 downto 0);
		ports_out : out cop0_register_port_out_array_t(port_count-1 downto 0)
	);
end cop0_registers;

architecture cop0_registers_behavioral of cop0_registers is
	constant register_count : NATURAL := 32;
	signal registers : slv32_array_t(register_count-1 downto 0);
	signal registers_next : slv32_array_t(register_count-1 downto 0);
	signal port_out_data_reg : slv32_array_t(port_count-1 downto 0);
	signal port_out_data_reg_next : slv32_array_t(port_count-1 downto 0);
begin

	process(clock)
	begin
		if rising_edge(clock) then
			registers <= registers_next;
			port_out_data_reg <= port_out_data_reg_next;
		end if;
	end process;
	
	process(
		resetn,
		
		ports_in,
		registers,
		
		port_out_data_reg
		)
		variable vregister_index : NATURAL;
	begin
		
		for i in port_count-1 downto 0 loop
			ports_out(i).data <= port_out_data_reg(i);
		end loop;
				
		registers_next <= registers;
		port_out_data_reg_next <= port_out_data_reg;
		
		if resetn = '0' then
			registers_next <= (others => (others => '0'));
			port_out_data_reg_next <= (others => (others => '0'));
		else	
			for i in port_count-1 downto 0 loop
				vregister_index := TO_INTEGER(UNSIGNED(ports_in(i).address));
				port_out_data_reg_next(i) <= registers(vregister_index);
				if ports_in(i).write_enable = '1' then
					for j in 3 downto 0 loop
						if ports_in(i).write_strobe(j) = '1' then
							registers_next(vregister_index)(j * 8 + 7 downto j * 8) <= ports_in(i).write_data(j * 8 + 7 downto j * 8);
						end if;
					end loop;
				end if;
			end loop;
		end if;
	end process;
end cop0_registers_behavioral;
