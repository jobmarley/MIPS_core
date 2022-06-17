library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity skid_buffer is
	generic(
		data_width : integer := 32
	);
	port (
		resetn : in std_logic;
		clock : in std_logic;
		
		in_valid : in std_logic;
		in_ready : out std_logic;
		in_data : in std_logic_vector(data_width-1 downto 0);
	
		out_valid : out std_logic;
		out_ready : in std_logic;
		out_data : out std_logic_vector(data_width-1 downto 0)
	 );
end skid_buffer;

architecture skid_buffer_behavioral of skid_buffer is
	signal data_reg : std_logic_vector(data_width-1 downto 0);
	signal data_reg_next : std_logic_vector(data_width-1 downto 0);
	signal valid_reg : std_logic;
	signal valid_reg_next : std_logic;
begin

	process (clock)
	begin
		if rising_edge(clock) then
			data_reg <= data_reg_next;
			valid_reg <= valid_reg_next;
		end if;
	end process;
	
	process (
		resetn,
		in_valid,
		in_data,
		out_ready,
		valid_reg,
		valid_reg_next,
		data_reg,
		data_reg_next
		)
		variable vready : std_logic;
	begin
		if resetn = '0' then
			data_reg_next <= (others => '0');
			valid_reg_next <= '0';
			in_ready <= '0';
			out_valid <= '0';
			out_data <= (others => '0');
		else
			out_valid <= '0';
			in_ready <= '0';
		
			data_reg_next <= data_reg;
			valid_reg_next <= valid_reg;
		
			if valid_reg = '1' then
				out_valid <= '1';
				out_data <= data_reg;
				if out_ready = '1' then
					in_ready <= '1';
					valid_reg_next <= in_valid;
					data_reg_next <= in_data;					
				end if;
			else
				in_ready <= '1';
				out_valid <= in_valid;
				out_data <= in_data;
				valid_reg_next <= in_valid and not out_ready;
				data_reg_next <= in_data;
			end if;
		end if;
	end process;
end skid_buffer_behavioral;
