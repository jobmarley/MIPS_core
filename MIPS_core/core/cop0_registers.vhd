library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_utils.all;
use work.mips_core_config.all;

entity cop0_registers is
	generic(
		port_count : NATURAL
	);
	port(
		resetn : in std_logic;
		clock : in std_logic;
	
		ports_in : in cop0_register_port_in_array_t(port_count-1 downto 0);
		ports_out : out cop0_register_port_out_array_t(port_count-1 downto 0);
	
		perf_increment : in std_logic
	);
end cop0_registers;

architecture cop0_registers_behavioral of cop0_registers is
	
	
	type cop0_registers_set_t is record
		r0 : slv32_t;
		r1 : slv32_t;
		r2 : slv32_t;
		r3 : slv32_t;
		r4 : slv32_t;
		r5 : slv32_t;
		r6 : slv32_t;
		r7 : slv32_t;
		r8 : slv32_t;
		r9 : slv32_t;
		r9s1 : slv32_t;
		r10 : slv32_t;
		r11 : slv32_t;
		r12 : slv32_t;
		r13 : slv32_t;
		r14 : slv32_t;
		r15 : slv32_t;
		r16 : slv32_t;
		r16s1 : slv32_t;
		r17 : slv32_t;
		r18 : slv32_t;
		r19 : slv32_t;
		r20 : slv32_t;
		r21 : slv32_t;
		r22 : slv32_t;
		r22s1 : slv32_t;
		r22s2 : slv32_t;
		r22s3 : slv32_t;
		r22s4 : slv32_t;
		r22s5 : slv32_t;
		r22s6 : slv32_t;
		r22s7 : slv32_t;
		r23 : slv32_t;
		r24 : slv32_t;
		r25 : slv32_t;
		r26 : slv32_t;
		r27 : slv32_t;
		r28 : slv32_t;
		r29 : slv32_t;
		r30 : slv32_t;
		r31 : slv32_t;
	end record;
	
	signal registers : cop0_registers_set_t;	
	signal registers_next : cop0_registers_set_t;
	signal port_out_data_reg : slv32_array_t(port_count-1 downto 0);
	signal port_out_data_reg_next : slv32_array_t(port_count-1 downto 0);
	
	type register_row_t is array(7 downto 0) of slv32_t;
	type register_array_t is array(31 downto 0) of register_row_t;
	
	signal registers_connector_in : register_array_t;
	signal registers_connector_out : register_array_t;
begin
	registers_next.r0 <= registers_connector_in(0)(0);
	registers_next.r1 <= registers_connector_in(1)(0);
	registers_next.r2 <= registers_connector_in(2)(0);
	registers_next.r3 <= registers_connector_in(3)(0);
	registers_next.r4 <= registers_connector_in(4)(0);
	registers_next.r5 <= registers_connector_in(5)(0);
	registers_next.r6 <= registers_connector_in(6)(0);
	registers_next.r7 <= registers_connector_in(7)(0);
	registers_next.r8 <= registers_connector_in(8)(0);
	registers_next.r9 <= registers_connector_in(9)(0);
	registers_next.r9s1 <= registers_connector_in(9)(1);
	registers_next.r10 <= registers_connector_in(10)(0);
	registers_next.r11 <= registers_connector_in(11)(0);
	registers_next.r12 <= registers_connector_in(12)(0);
	registers_next.r13 <= registers_connector_in(13)(0);
	registers_next.r14 <= registers_connector_in(14)(0);
	registers_next.r15 <= registers_connector_in(15)(0);
	
	registers_next.r16(31) <= CONFIG0_CONFIG1_IMPLEMENTED;
	registers_next.r16(30 downto 16) <= CONFIG0_IMPL;
	registers_next.r16(15) <= CONFIG0_ENDIANNESS;
	registers_next.r16(14 downto 13) <= CONFIG0_ARCHITECTURE_TYPE;
	registers_next.r16(12 downto 10) <= CONFIG0_ARCHITECTURE_REVISION;
	registers_next.r16(9 downto 7) <= CONFIG0_MMU_TYPE;
	registers_next.r16(6 downto 3) <= (others => '0');
	registers_next.r16(2 downto 0) <= CONFIG0_KSEG0;
	
	registers_next.r16s1(31) <= CONFIG1_CONFIG2_IMPLEMENTED;
	registers_next.r16s1(30 downto 25) <= CONFIG1_MMU_SIZE;
	registers_next.r16s1(24 downto 22) <= CONFIG1_INSTR_CACHE_SETS;
	registers_next.r16s1(21 downto 19) <= CONFIG1_INSTR_CACHE_LINE_SIZE;
	registers_next.r16s1(18 downto 16) <= CONFIG1_INSTR_CACHE_ASSOCIATIVITY;
	registers_next.r16s1(15 downto 13) <= CONFIG1_DATA_CACHE_SETS;
	registers_next.r16s1(12 downto 10) <= CONFIG1_DATA_CACHE_LINE_SIZE;
	registers_next.r16s1(9 downto 7) <= CONFIG1_DATA_CACHE_ASSOCIATIVITY;
	registers_next.r16s1(6) <= CONFIG1_COP2_PRESENT;
	registers_next.r16s1(5) <= CONFIG1_MDMX_ASE;
	registers_next.r16s1(4) <= CONFIG1_PERFORMANCE_COUNTER_IMPLEMENTED;
	registers_next.r16s1(3) <= CONFIG1_WATCH_REGISTER_IMPLEMENTED;
	registers_next.r16s1(2) <= CONFIG1_MIPS16_IMPLEMENTED;
	registers_next.r16s1(1) <= CONFIG1_EJTAG_IMPLEMENTED;
	registers_next.r16s1(0) <= CONFIG1_FPU_IMPLEMENTED;
	
	registers_next.r17 <= registers_connector_in(17)(0);
	registers_next.r18 <= registers_connector_in(18)(0);
	registers_next.r19 <= registers_connector_in(19)(0);
	registers_next.r20 <= registers_connector_in(20)(0);
	registers_next.r21 <= registers_connector_in(21)(0);
	registers_next.r22 <= registers_connector_in(22)(0);
	registers_next.r22s1 <= registers_connector_in(22)(1);
	registers_next.r22s2 <= registers_connector_in(22)(2);
	registers_next.r22s3 <= registers_connector_in(22)(3);
	registers_next.r22s4 <= registers_connector_in(22)(4);
	registers_next.r22s5 <= registers_connector_in(22)(5);
	registers_next.r22s6 <= registers_connector_in(22)(6);
	registers_next.r22s7 <= registers_connector_in(22)(7);
	registers_next.r23 <= registers_connector_in(23)(0);
	registers_next.r24 <= registers_connector_in(24)(0);
	registers_next.r25 <= registers_connector_in(25)(0);
	registers_next.r26 <= registers_connector_in(26)(0);
	registers_next.r27 <= registers_connector_in(27)(0);
	registers_next.r28 <= registers_connector_in(28)(0);
	registers_next.r29 <= registers_connector_in(29)(0);
	registers_next.r30 <= registers_connector_in(30)(0);
	registers_next.r31 <= registers_connector_in(30)(0);
	
	registers_connector_out <= (
		0 => (0 => registers.r0, others => x"00000000"),
		1 => (0 => registers.r1, others => x"00000000"),
		2 => (0 => registers.r2, others => x"00000000"),
		3 => (0 => registers.r3, others => x"00000000"),
		4 => (0 => registers.r4, others => x"00000000"),
		5 => (0 => registers.r5, others => x"00000000"),
		6 => (0 => registers.r6, others => x"00000000"),
		7 => (0 => registers.r7, others => x"00000000"),
		8 => (0 => registers.r8, others => x"00000000"),
		9 => (0 => registers.r9, 1 => registers.r9s1, others => x"00000000"),
		10 => (0 => registers.r10, others => x"00000000"),
		11 => (0 => registers.r11, others => x"00000000"),
		12 => (0 => registers.r12, others => x"00000000"),
		13 => (0 => registers.r13, others => x"00000000"),
		14 => (0 => registers.r14, others => x"00000000"),
		15 => (0 => registers.r15, others => x"00000000"),
		16 => (0 => registers.r16, others => x"00000000"),
		17 => (0 => registers.r17, others => x"00000000"),
		18 => (0 => registers.r18, others => x"00000000"),
		19 => (0 => registers.r19, others => x"00000000"),
		20 => (0 => registers.r20, others => x"00000000"),
		21 => (0 => registers.r21, others => x"00000000"),
		22 => (0 => registers.r22, 1 => registers.r22s1, 2 => registers.r22s2, 3 => registers.r22s3, 4 => registers.r22s4, 5 => registers.r22s5, 6 => registers.r22s6, 7 => registers.r22s7, others => x"00000000"),
		23 => (0 => registers.r23, others => x"00000000"),
		24 => (0 => registers.r24, others => x"00000000"),
		25 => (0 => registers.r25, others => x"00000000"),
		26 => (0 => registers.r26, others => x"00000000"),
		27 => (0 => registers.r27, others => x"00000000"),
		28 => (0 => registers.r28, others => x"00000000"),
		29 => (0 => registers.r29, others => x"00000000"),
		30 => (0 => registers.r30, others => x"00000000"),
		31 => (0 => registers.r31, others => x"00000000"));
	
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
		
		port_out_data_reg,
		perf_increment,
		registers_connector_out
		)
		variable vregister_index : NATURAL;
		variable vregister_sel : NATURAL;
	begin
		
		for i in port_count-1 downto 0 loop
			ports_out(i).data <= port_out_data_reg(i);
		end loop;
				
		registers_connector_in <= registers_connector_out;
		port_out_data_reg_next <= port_out_data_reg;
		
		if resetn = '0' then
			registers_connector_in <= (others => (others => x"00000000"));
			port_out_data_reg_next <= (others => (others => '0'));
		else	
			registers_connector_in(COP0_REGISTER_COUNT)(0) <= std_logic_vector(unsigned(registers_connector_out(COP0_REGISTER_COUNT)(0)) + 1);
			if perf_increment = '1' then
				registers_connector_in(COP0_REGISTER_COUNT)(1) <= std_logic_vector(unsigned(registers_connector_out(COP0_REGISTER_COUNT)(1)) + 1);
			end if;
			
			for i in port_count-1 downto 0 loop
				vregister_index := TO_INTEGER(UNSIGNED(ports_in(i).address));
				vregister_sel := TO_INTEGER(UNSIGNED(ports_in(i).sel));
				port_out_data_reg_next(i) <= registers_connector_out(vregister_index)(vregister_sel);
				if ports_in(i).write_enable = '1' then
					for j in 3 downto 0 loop
						if ports_in(i).write_strobe(j) = '1' then
							registers_connector_in(vregister_index)(vregister_sel)(j * 8 + 7 downto j * 8) <= ports_in(i).write_data(j * 8 + 7 downto j * 8);
						end if;
					end loop;
				end if;
			end loop;
		end if;
	end process;
end cop0_registers_behavioral;
