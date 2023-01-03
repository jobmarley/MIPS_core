library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_utils.all;

entity mips_fetch is
	port(
		enable : in std_logic;
		resetn : in std_logic;
		clock : in std_logic;
	
		-- cache
		porta_address : out std_logic_vector(31 downto 0);
		porta_address_ready : in std_logic;
		porta_address_valid : out std_logic;
		porta_read_data : in std_logic_vector(31 downto 0);
		porta_read_data_ready : out std_logic;
		porta_read_data_valid : in std_logic;
		
		-- decode
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
		
	constant FIFO_SIZE : NATURAL := 3;
	signal fifo_used : UNSIGNED(1 downto 0);
	signal fifo_used_next : UNSIGNED(1 downto 0);
	signal instruction_address_fifo : slv32_array_t(FIFO_SIZE-1 downto 0);
	signal instruction_address_fifo_next : slv32_array_t(FIFO_SIZE-1 downto 0);
	signal discard_counter : UNSIGNED(1 downto 0);
	signal discard_counter_next : UNSIGNED(1 downto 0);
	
	signal send_address : std_logic;
	signal receive_data : std_logic;
	
	signal sporta_address_valid : std_logic;
	signal sporta_read_data_ready : std_logic;
begin
	porta_address_valid <= sporta_address_valid;
	porta_read_data_ready <= sporta_read_data_ready;
	
	send_address <= sporta_address_valid and porta_address_ready;
	receive_data <= sporta_read_data_ready and porta_read_data_valid;
	
	instruction_address_plus_8 <= instruction_address_plus_8_reg;
	instruction_address_plus_4 <= instruction_address_plus_4_reg;
	instruction_address <= instruction_address_fifo(0);
	instruction_address_plus_8_reg_next <= std_logic_vector(unsigned(instruction_address_fifo_next(0)) + 8);
	instruction_address_plus_4_reg_next <= std_logic_vector(unsigned(instruction_address_fifo_next(0)) + 4);
	
	process(clock)
	begin
		if rising_edge(clock) then
			current_address <= current_address_next;
			instruction_address_plus_8_reg <= instruction_address_plus_8_reg_next;
			instruction_address_plus_4_reg <= instruction_address_plus_4_reg_next;
			
			wait_jump_reg <= wait_jump_reg_next;
			override_address_reg <= override_address_reg_next;
			override_address_valid_reg <= override_address_valid_reg_next;
			skip_jump_reg <= skip_jump_reg_next;
			execute_delay_slot_reg <= execute_delay_slot_reg_next;
			
			fifo_used <= fifo_used_next;
			instruction_address_fifo <= instruction_address_fifo_next;
			discard_counter <= discard_counter_next;
		end if;
	end process;

	
	
	-- handle address fifo
	process(
		resetn,
		send_address,
		receive_data,
		fifo_used,
		instruction_address_fifo,
		current_address,
		instruction_address_plus_8_reg,
		instruction_address_plus_4_reg
		)
	begin
		fifo_used_next <= fifo_used;
		instruction_address_fifo_next <= instruction_address_fifo;
		
		
		if resetn = '0' then
			instruction_address_fifo_next <= (others => (others => '0'));
			fifo_used_next <= TO_UNSIGNED(0, fifo_used'LENGTH);
		else
			if send_address = '1' and receive_data = '1' then
				for i in 0 downto FIFO_SIZE-2 loop
					instruction_address_fifo_next(i) <= instruction_address_fifo(i+1);
				end loop;
				instruction_address_fifo_next(TO_INTEGER(fifo_used-1)) <= current_address;
			elsif send_address = '1' then
				instruction_address_fifo_next(TO_INTEGER(fifo_used)) <= current_address;
				fifo_used_next <= fifo_used + 1;
			elsif receive_data = '1' then
				for i in 0 downto FIFO_SIZE-2 loop
					instruction_address_fifo_next(i) <= instruction_address_fifo(i+1);
				end loop;
				fifo_used_next <= fifo_used - 1;
			end if;
		end if;
	end process;
	
	process(
		enable,
		resetn,
		
		current_address,
		
		porta_address_ready,
		porta_read_data,
		porta_read_data_valid,
		
		instruction_data_ready,
			
		wait_jump,
		wait_jump_reg,
		override_address_valid,
		override_address_valid_reg,
		override_address,
		override_address_reg,
		skip_jump,
		skip_jump_reg,
		execute_delay_slot,
		execute_delay_slot_reg,
		
		fifo_used,
		discard_counter
		)
	begin
		porta_address <= current_address;
		sporta_address_valid <= '0';
		sporta_read_data_ready <= '0';
		
		current_address_next <= current_address;
		
		error <= '0';
		
		override_address_valid_reg_next <= override_address_valid_reg;
		override_address_reg_next <= override_address_reg;
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
						
		instruction_data_valid <= '0';
		instruction_data <= (others => '0');
		discard_counter_next <= discard_counter;
		
		if resetn = '0' then
			current_address_next <= (others => '0');
			wait_jump_reg_next <= '0';
			override_address_reg_next <= (others => '0');
			override_address_valid_reg_next <= '0';
			skip_jump_reg_next <= '0';
			execute_delay_slot_reg_next <= '0';
			
			discard_counter_next <= (others => '0');
		else
			
			porta_address <= current_address;
					
			-- send address and increment
			if fifo_used < 3 then
				sporta_address_valid <= '1';
				if porta_address_ready = '1' then
					current_address_next <= std_logic_vector(UNSIGNED(current_address) + 4);
				end if;
			end if;
					
			if discard_counter > 0 then
				if porta_read_data_valid = '1' then
					-- just discard data and decrement counter
					sporta_read_data_ready <= '1';
					discard_counter_next <= discard_counter - 1;
				end if;
			else
				-- dont send any data if processor is paused
				if enable = '1' then
					-- forward data only if we dont discard (after a jump)		
					sporta_read_data_ready <= instruction_data_ready;
					instruction_data_valid <= porta_read_data_valid;
					instruction_data <= porta_read_data;
					
					-- if we jump, we wait to have a data pending (the delay slot), but we dont send the data
					if wait_jump_reg = '1' then
						-- dont send anymore data
						instruction_data_valid <= '0';
						sporta_read_data_ready <= '0';
																
						if execute_delay_slot_reg = '1' then
							-- forward data
							sporta_read_data_ready <= instruction_data_ready;
							instruction_data_valid <= porta_read_data_valid;
							instruction_data <= porta_read_data;
						
							-- send 1 instruction
							if instruction_data_ready = '1' and porta_read_data_valid = '1' then
								execute_delay_slot_reg_next <= '0';
							end if;
						elsif skip_jump_reg = '1' then
							-- skip the jump, we do nothing, just keep executing
							-- could actually send address here to not waste a cycle
							override_address_valid_reg_next <= '0';
							skip_jump_reg_next <= '0';
							wait_jump_reg_next <= '0';
						elsif override_address_valid_reg = '1' then
							porta_address <= override_address_reg;
							if porta_address_ready = '1' and fifo_used < 3 then
								current_address_next <= std_logic_vector(unsigned(override_address_reg) + 4);
							else
								current_address_next <= override_address_reg;
							end if;
							override_address_valid_reg_next <= '0';
							skip_jump_reg_next <= '0';
							wait_jump_reg_next <= '0';
							discard_counter_next <= fifo_used; -- discard all instructions in the pipeline
						end if;
					end if;
				end if;
			end if;
		end if;
	end process;
end mips_fetch_behavioral;
