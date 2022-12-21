library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_utils.all;

entity mips_registers is
	generic (
		port_type1_count : NATURAL;
		port_hilo_in_count : NATURAL;
		port_hilo_out_count : NATURAL
	);
	port (
		resetn : in std_logic;
		clock : in std_logic;
		
		port_in : in register_port_in_array_t(port_type1_count-1 downto 0);
		port_out : out register_port_out_array_t(port_type1_count-1 downto 0);
	
		hilo_in : in hilo_register_port_in_array_t(port_hilo_in_count-1 downto 0);
		hilo_out : out hilo_register_port_out_array_t(port_hilo_out_count-1 downto 0);
	
		registers_written : out registers_pending_t
	);
end mips_registers;

architecture mips_registers_behavioral of mips_registers is
	constant register_count : NATURAL := 32;
	signal registers : slv32_array_t(register_count-1 downto 0);
	signal registers_next : slv32_array_t(register_count-1 downto 0);
	
	signal port_out_data_reg : slv32_array_t(port_type1_count-1 downto 0);
	signal port_out_data_reg_next : slv32_array_t(port_type1_count-1 downto 0);
	
	signal hilo_reg : std_logic_vector(63 downto 0);
	signal hilo_reg_next : std_logic_vector(63 downto 0);
begin
	process(clock)
	begin
		if rising_edge(clock) then
			registers <= registers_next;
			
			-- register $0 is hardcoded 0
			registers(0) <= (others => '0');
			
			port_out_data_reg <= port_out_data_reg_next;
			
			hilo_reg <= hilo_reg_next;
		end if;
	end process;
	
	process(
		resetn,
		
		port_in,
		registers,
		
		port_out_data_reg,
		
		hilo_reg,
		hilo_in
		)
		variable vregister_index : NATURAL;
	begin
		
		for i in port_type1_count-1 downto 0 loop
			port_out(i).data <= port_out_data_reg(i);
		end loop;
		
		for i in hilo_out'range loop
			hilo_out(i).data <= hilo_reg;
		end loop;
		
		registers_next <= registers;
		port_out_data_reg_next <= port_out_data_reg;
		hilo_reg_next <= hilo_reg;
		
		registers_written <= (gp_registers => (others => '0'), others => '0');
		
		if resetn = '0' then
			registers_next <= (others => (others => '0'));
			port_out_data_reg_next <= (others => (others => '0'));
			hilo_reg_next <= (others => '0');
		else
			
			for i in hilo_in'range loop
				if hilo_in(i).write_enable = '1' then
					if hilo_in(i).write_strobe(0) = '1' then
						hilo_reg_next(31 downto 0) <= hilo_in(i).write_data(31 downto 0);
						registers_written.hi <= '1';
					end if;
					if hilo_in(i).write_strobe(1) = '1' then
						hilo_reg_next(63 downto 32) <= hilo_in(i).write_data(63 downto 32);
						registers_written.lo <= '1';
					end if;
				end if;
			end loop;
	
			for i in port_type1_count-1 downto 0 loop
				vregister_index := TO_INTEGER(UNSIGNED(port_in(i).address));
				port_out_data_reg_next(i) <= registers(vregister_index);
				if port_in(i).write_enable = '1' then
					registers_written.gp_registers(TO_INTEGER(unsigned(port_in(i).address))) <= '1';
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
