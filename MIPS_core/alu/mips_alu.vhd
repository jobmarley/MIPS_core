library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.mips_utils.all;

entity mips_alu is
    port (
		enable : in std_logic;
		clock : in std_logic;
		resetn : in std_logic;
	
	    in_ports : in alu_in_ports_t;
	    out_ports : out alu_out_ports_t
	);
end mips_alu;

architecture mips_alu_behavioral of mips_alu is
    COMPONENT c_addsub_0
      PORT (
        A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        CLK : IN STD_LOGIC;
        ADD : IN STD_LOGIC;
        CE : IN STD_LOGIC;
        C_OUT : OUT STD_LOGIC;
        S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;
	
	signal add_sub_op_a : std_logic_vector(31 downto 0);
	signal add_sub_op_b : std_logic_vector(31 downto 0);
	signal add_sub_op_c : std_logic_vector(31 downto 0);
	signal add_sub_carry : std_logic;
	signal add_sub_select : std_logic; -- 1 for add, 0 for sub
	signal add_sub_ce : std_logic;
	
	signal add_result_pending : std_logic;
	signal add_result_pending_next : std_logic;
	signal add_tuser_reg : std_logic_vector(in_ports.add_in_tuser'LENGTH-1 downto 0);
	signal add_tuser_reg_next : std_logic_vector(in_ports.add_in_tuser'LENGTH-1 downto 0);
	signal sub_result_pending : std_logic;
	signal sub_result_pending_next : std_logic;
	signal sub_tuser_reg : std_logic_vector(in_ports.sub_in_tuser'LENGTH-1 downto 0);
	signal sub_tuser_reg_next : std_logic_vector(in_ports.sub_in_tuser'LENGTH-1 downto 0);
	COMPONENT mult_gen_0
	  PORT (
		CLK : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		CE : IN STD_LOGIC;
		P : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	  );
	END COMPONENT;
	COMPONENT mult_gen_1
	  PORT (
		CLK : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		CE : IN STD_LOGIC;
		P : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	  );
	END COMPONENT;
	COMPONENT div_gen_0
	  PORT (
		aclk : IN STD_LOGIC;
		aresetn : IN STD_LOGIC;
		s_axis_divisor_tvalid : IN STD_LOGIC;
		s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		s_axis_dividend_tvalid : IN STD_LOGIC;
		s_axis_dividend_tuser : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		m_axis_dout_tvalid : OUT STD_LOGIC;
		m_axis_dout_tuser : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	  );
	END COMPONENT;
	COMPONENT div_gen_1
	  PORT (
		aclk : IN STD_LOGIC;
		aresetn : IN STD_LOGIC;
		s_axis_divisor_tvalid : IN STD_LOGIC;
		s_axis_divisor_tready : OUT STD_LOGIC;
		s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		s_axis_dividend_tvalid : IN STD_LOGIC;
		s_axis_dividend_tready : OUT STD_LOGIC;
		s_axis_dividend_tuser : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		m_axis_dout_tvalid : OUT STD_LOGIC;
		m_axis_dout_tready : IN STD_LOGIC;
		m_axis_dout_tuser : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0)
	  );
	END COMPONENT;
	
	signal mul_ce : std_logic;
	
	type mul_sh_reg_rec is record
		tuser : std_logic_vector(5 downto 0);
		valid : std_logic;
	end record;
	
	type mul_sh_reg_t is array(NATURAL range <>) of mul_sh_reg_rec;
	
	constant MUL_PIPELINE_LENGTH : NATURAL := 5;
	signal mul_sh_reg : mul_sh_reg_t(MUL_PIPELINE_LENGTH-1 downto 0);
	signal mul_sh_reg_next : mul_sh_reg_t(MUL_PIPELINE_LENGTH-1 downto 0);
	
	signal multu_ce : std_logic;
	signal multu_sh_reg : mul_sh_reg_t(MUL_PIPELINE_LENGTH-1 downto 0);
	signal multu_sh_reg_next : mul_sh_reg_t(MUL_PIPELINE_LENGTH-1 downto 0);
	signal multu_result : std_logic_vector(63 downto 0);
	
	COMPONENT xbip_multadd_0
	  PORT (
		CLK : IN STD_LOGIC;
		CE : IN STD_LOGIC;
		SCLR : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		C : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		SUBTRACT : IN STD_LOGIC;
		P : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
		PCOUT : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
	  );
	END COMPONENT;
	COMPONENT xbip_multadd_1
	  PORT (
		CLK : IN STD_LOGIC;
		CE : IN STD_LOGIC;
		SCLR : IN STD_LOGIC;
		A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		C : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
		SUBTRACT : IN STD_LOGIC;
		P : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
		PCOUT : OUT STD_LOGIC_VECTOR(47 DOWNTO 0)
	  );
	END COMPONENT;
	
	constant MULTADD_PIPELINE_LENGTH : NATURAL := 9;
	constant MULTADD_C_DELAY : NATURAL := 7;
	signal multadd_ce : std_logic;
	signal multadd_sh_reg : mul_sh_reg_t(MULTADD_PIPELINE_LENGTH-1 downto 0);
	signal multadd_sh_reg_next : mul_sh_reg_t(MULTADD_PIPELINE_LENGTH-1 downto 0);
	
	type multadd_c_shift_reg_t is array(NATURAL range <>) of std_logic_vector(63 downto 0);
	signal multadd_c_shift_reg : multadd_c_shift_reg_t(MULTADD_C_DELAY-1 downto 0);
	signal multadd_c_shift_reg_next : multadd_c_shift_reg_t(MULTADD_C_DELAY-1 downto 0);
	
	signal multaddu_ce : std_logic;
	signal multaddu_sh_reg : mul_sh_reg_t(MULTADD_PIPELINE_LENGTH-1 downto 0);
	signal multaddu_sh_reg_next : mul_sh_reg_t(MULTADD_PIPELINE_LENGTH-1 downto 0);
	
	signal multaddu_c_shift_reg : multadd_c_shift_reg_t(MULTADD_C_DELAY-1 downto 0);
	signal multaddu_c_shift_reg_next : multadd_c_shift_reg_t(MULTADD_C_DELAY-1 downto 0);
	
	signal cmp_result : std_logic;
	signal cmp_result_next : std_logic;
	signal cmp_result_tuser : std_logic_vector(in_ports.cmp_in_tuser'LENGTH-1 downto 0);
	signal cmp_result_tuser_next : std_logic_vector(in_ports.cmp_in_tuser'LENGTH-1 downto 0);
	signal cmp_valid_reg : std_logic;
	signal cmp_valid_reg_next : std_logic;
	
	signal and_out_tdata_reg : std_logic_vector(31 downto 0);
	signal and_out_tdata_reg_next : std_logic_vector(31 downto 0);
	signal and_out_tuser_reg : std_logic_vector(in_ports.and_in_tuser'LENGTH-1 downto 0);
	signal and_out_tuser_reg_next : std_logic_vector(in_ports.and_in_tuser'LENGTH-1 downto 0);
	signal and_out_tvalid_reg : std_logic;
	signal and_out_tvalid_reg_next : std_logic;
	
	signal or_out_tdata_reg : std_logic_vector(31 downto 0);
	signal or_out_tdata_reg_next : std_logic_vector(31 downto 0);
	signal or_out_tuser_reg : std_logic_vector(in_ports.or_in_tuser'LENGTH-1 downto 0);
	signal or_out_tuser_reg_next : std_logic_vector(in_ports.or_in_tuser'LENGTH-1 downto 0);
	signal or_out_tvalid_reg : std_logic;
	signal or_out_tvalid_reg_next : std_logic;
	
	signal xor_out_tdata_reg : std_logic_vector(31 downto 0);
	signal xor_out_tdata_reg_next : std_logic_vector(31 downto 0);
	signal xor_out_tuser_reg : std_logic_vector(in_ports.xor_in_tuser'LENGTH-1 downto 0);
	signal xor_out_tuser_reg_next : std_logic_vector(in_ports.xor_in_tuser'LENGTH-1 downto 0);
	signal xor_out_tvalid_reg : std_logic;
	signal xor_out_tvalid_reg_next : std_logic;
	
	signal nor_out_tdata_reg : std_logic_vector(31 downto 0);
	signal nor_out_tdata_reg_next : std_logic_vector(31 downto 0);
	signal nor_out_tuser_reg : std_logic_vector(in_ports.nor_in_tuser'LENGTH-1 downto 0);
	signal nor_out_tuser_reg_next : std_logic_vector(in_ports.nor_in_tuser'LENGTH-1 downto 0);
	signal nor_out_tvalid_reg : std_logic;
	signal nor_out_tvalid_reg_next : std_logic;
	
	signal shl_out_tdata_reg : std_logic_vector(31 downto 0);
	signal shl_out_tdata_reg_next : std_logic_vector(31 downto 0);
	signal shl_out_tuser_reg : std_logic_vector(in_ports.shl_in_tuser'LENGTH-1 downto 0);
	signal shl_out_tuser_reg_next : std_logic_vector(in_ports.shl_in_tuser'LENGTH-1 downto 0);
	signal shl_out_tvalid_reg : std_logic;
	signal shl_out_tvalid_reg_next : std_logic;
	
	signal shr_out_tdata_reg : std_logic_vector(31 downto 0);
	signal shr_out_tdata_reg_next : std_logic_vector(31 downto 0);
	signal shr_out_tuser_reg : std_logic_vector(in_ports.shr_in_tuser'LENGTH-1 downto 0);
	signal shr_out_tuser_reg_next : std_logic_vector(in_ports.shr_in_tuser'LENGTH-1 downto 0);
	signal shr_out_tvalid_reg : std_logic;
	signal shr_out_tvalid_reg_next : std_logic;
		
	function shift_right_arith(data : std_logic_vector; n : NATURAL) return std_logic_vector is
		variable result : std_logic_vector(data'range);
	begin
		for i in 0 to data'LENGTH-1 loop
			if i + n < data'LENGTH then
				result(i) := data(i + n);
			else
				result(i) := data(data'LENGTH-1);
			end if;
		end loop;
		return result;
	end function;
	
	signal cmp_tuser : alu_cmp_tuser_t;
begin
	cmp_tuser <= slv_to_cmp_tuser(in_ports.cmp_in_tuser);
	
	out_ports.and_out_tvalid <= and_out_tvalid_reg;
	out_ports.and_out_tdata <= and_out_tdata_reg;
	out_ports.and_out_tuser <= and_out_tuser_reg;
	
	out_ports.or_out_tvalid <= or_out_tvalid_reg;
	out_ports.or_out_tdata <= or_out_tdata_reg;
	out_ports.or_out_tuser <= or_out_tuser_reg;
	
	out_ports.xor_out_tvalid <= xor_out_tvalid_reg;
	out_ports.xor_out_tdata <= xor_out_tdata_reg;
	out_ports.xor_out_tuser <= xor_out_tuser_reg;
	
	out_ports.nor_out_tvalid <= nor_out_tvalid_reg;
	out_ports.nor_out_tdata <= nor_out_tdata_reg;
	out_ports.nor_out_tuser <= nor_out_tuser_reg;
	
	out_ports.shl_out_tvalid <= shl_out_tvalid_reg;
	out_ports.shl_out_tdata <= shl_out_tdata_reg;
	out_ports.shl_out_tuser <= shl_out_tuser_reg;
	
	out_ports.shr_out_tvalid <= shr_out_tvalid_reg;
	out_ports.shr_out_tdata <= shr_out_tdata_reg;
	out_ports.shr_out_tuser <= shr_out_tuser_reg;
	
	out_ports.cmp_out_tdata(0) <= cmp_result;
	out_ports.cmp_out_tuser <= cmp_result_tuser;
	out_ports.cmp_out_tvalid <= cmp_valid_reg;
	
	process (clock) is
	begin
		if rising_edge(clock) then
			add_result_pending <= add_result_pending_next;
			add_tuser_reg <= add_tuser_reg_next;
			sub_result_pending <= sub_result_pending_next;
			sub_tuser_reg <= sub_tuser_reg_next;
			
			mul_sh_reg <= mul_sh_reg_next;
			multu_sh_reg <= multu_sh_reg_next;
			multadd_sh_reg <= multadd_sh_reg_next;
			multadd_c_shift_reg <= multadd_c_shift_reg_next;
			multaddu_sh_reg <= multaddu_sh_reg_next;
			multaddu_c_shift_reg <= multaddu_c_shift_reg_next;
			
			cmp_result <= cmp_result_next;
			cmp_result_tuser <= cmp_result_tuser_next;
			cmp_valid_reg <= cmp_valid_reg_next;
			
			and_out_tdata_reg <= and_out_tdata_reg_next;
			and_out_tuser_reg <= and_out_tuser_reg_next;
			and_out_tvalid_reg <= and_out_tvalid_reg_next;
			
			or_out_tdata_reg <= or_out_tdata_reg_next;
			or_out_tuser_reg <= or_out_tuser_reg_next;
			or_out_tvalid_reg <= or_out_tvalid_reg_next;
			
			xor_out_tdata_reg <= xor_out_tdata_reg_next;
			xor_out_tuser_reg <= xor_out_tuser_reg_next;
			xor_out_tvalid_reg <= xor_out_tvalid_reg_next;
			
			nor_out_tdata_reg <= nor_out_tdata_reg_next;
			nor_out_tuser_reg <= nor_out_tuser_reg_next;
			nor_out_tvalid_reg <= nor_out_tvalid_reg_next;
			
			shl_out_tdata_reg <= shl_out_tdata_reg_next;
			shl_out_tuser_reg <= shl_out_tuser_reg_next;
			shl_out_tvalid_reg <= shl_out_tvalid_reg_next;
			
			shr_out_tdata_reg <= shr_out_tdata_reg_next;
			shr_out_tuser_reg <= shr_out_tuser_reg_next;
			shr_out_tvalid_reg <= shr_out_tvalid_reg_next;
		end if;
	end process;
	
	process (
		enable,
		resetn,
			
		in_ports,
					
		add_result_pending,
		add_tuser_reg,
		sub_result_pending,
		sub_tuser_reg,
			
		add_sub_carry,
		add_sub_op_c
		)
	begin
		add_sub_op_a <= (others => '0');
		add_sub_op_b <= (others => '0');
		add_sub_select <= '1';
		add_sub_ce <= '0';
			
		out_ports.add_out_tvalid <= add_result_pending;
		out_ports.sub_out_tvalid <= sub_result_pending;
			
		out_ports.add_out_tdata <= add_sub_carry & add_sub_op_c;
		out_ports.sub_out_tdata <= add_sub_carry & add_sub_op_c;
			
		out_ports.add_out_tuser <= add_tuser_reg;
		out_ports.sub_out_tuser <= sub_tuser_reg;
			
		add_result_pending_next <= add_result_pending;
		add_tuser_reg_next <= add_tuser_reg;
		sub_result_pending_next <= sub_result_pending;
		sub_tuser_reg_next <= sub_tuser_reg;
		
		if resetn = '0' then
			add_result_pending_next <= '0';
			add_tuser_reg_next <= (others => '0');
			sub_result_pending_next <= '0';
			sub_tuser_reg_next <= (others => '0');
		elsif enable = '1' then
			add_result_pending_next <= in_ports.add_in_tvalid;
			add_tuser_reg_next <= add_tuser_reg;
			sub_result_pending_next <= in_ports.sub_in_tvalid and not in_ports.add_in_tvalid;
			sub_tuser_reg_next <= sub_tuser_reg;
			
			if in_ports.add_in_tvalid = '1' then
				add_sub_op_a <= in_ports.add_in_tdata(31 downto 0);
				add_sub_op_b <= in_ports.add_in_tdata(63 downto 32);
				add_sub_select <= '1';
				add_sub_ce <= '1';
				add_tuser_reg_next <= in_ports.add_in_tuser;
				add_result_pending_next <= '1';
			elsif in_ports.sub_in_tvalid = '1' then
				add_sub_op_a <= in_ports.sub_in_tdata(31 downto 0);
				add_sub_op_b <= in_ports.sub_in_tdata(63 downto 32);
				add_sub_select <= '0';
				add_sub_ce <= '1';
				sub_tuser_reg_next <= in_ports.sub_in_tuser;
				sub_result_pending_next <= '1';
			end if;
				
		end if;
	end process;
			
	-- multiply process
	process (
		enable,
		resetn,
		in_ports,
		mul_sh_reg
		)
	begin
		mul_sh_reg_next <= mul_sh_reg;
			
		mul_ce <= '0';
		out_ports.mul_out_tvalid <= '0';
		out_ports.mul_out_tuser <= (others => '0');
		
		if resetn = '0' then
			mul_ce <= '0';
			out_ports.mul_out_tvalid <= '0';
			out_ports.mul_out_tuser <= (others => '0');
			for i in 0 to mul_sh_reg'HIGH loop
				mul_sh_reg_next(i).tuser <= (others => '0');
				mul_sh_reg_next(i).valid <= '0';
			end loop;
		elsif enable = '1' then
			
			mul_ce <= '1';
			out_ports.mul_out_tuser <= mul_sh_reg(mul_sh_reg'HIGH).tuser;
			out_ports.mul_out_tvalid <= mul_sh_reg(mul_sh_reg'HIGH).valid;
				
			for i in 0 to mul_sh_reg'HIGH-1 loop
				mul_sh_reg_next(i + 1) <= mul_sh_reg(i);
			end loop;
			mul_sh_reg_next(0).tuser <= in_ports.mul_in_tuser;
			mul_sh_reg_next(0).valid <= in_ports.mul_in_tvalid;
		end if;
	end process;
		
	-- multiply unsigned
	out_ports.multu_out_tdata <= multu_result;
	process (
		enable,
		resetn,
		in_ports,
		multu_sh_reg
		)
	begin
		multu_sh_reg_next <= multu_sh_reg;
		
		multu_ce <= '0';
		out_ports.multu_out_tvalid <= '0';
		out_ports.multu_out_tuser <= (others => '0');
			
		if resetn = '0' then
			multu_ce <= '0';
			out_ports.multu_out_tvalid <= '0';
			out_ports.multu_out_tuser <= (others => '0');
			for i in 0 to multu_sh_reg'HIGH loop
				multu_sh_reg_next(i).tuser <= (others => '0');
				multu_sh_reg_next(i).valid <= '0';
			end loop;
		elsif enable = '1' then
			
			multu_ce <= '1';
			out_ports.multu_out_tuser <= multu_sh_reg(multu_sh_reg'HIGH).tuser;
			out_ports.multu_out_tvalid <= multu_sh_reg(multu_sh_reg'HIGH).valid;
				
			for i in 0 to multu_sh_reg'HIGH-1 loop
				multu_sh_reg_next(i + 1) <= multu_sh_reg(i);
			end loop;
			multu_sh_reg_next(0).tuser <= in_ports.multu_in_tuser;
			multu_sh_reg_next(0).valid <= in_ports.multu_in_tvalid;
		end if;
	end process;
		
	process (
		enable,
		resetn,
		in_ports,
		multadd_sh_reg,
		multadd_c_shift_reg
		)
	begin
		multadd_sh_reg_next <= multadd_sh_reg;
		multadd_c_shift_reg_next <= multadd_c_shift_reg;
		multadd_ce <= '0';
		out_ports.multadd_out_tvalid <= '0';
		out_ports.multadd_out_tuser <= (others => '0');
			
		if resetn = '0' then
			multadd_ce <= '0';
			out_ports.multadd_out_tvalid <= '0';
			out_ports.multadd_out_tuser <= (others => '0');
			for i in 0 to multadd_sh_reg'HIGH loop
				multadd_sh_reg_next(i).tuser <= (others => '0');
				multadd_sh_reg_next(i).valid <= '0';
			end loop;
			for i in 0 to multadd_c_shift_reg'HIGH loop
				multadd_c_shift_reg_next(i) <= (others => '0');
			end loop;
		elsif enable = '1' then
			
			multadd_ce <= '1';
			out_ports.multadd_out_tuser <= multadd_sh_reg(multadd_sh_reg'HIGH).tuser;
			out_ports.multadd_out_tvalid <= multadd_sh_reg(multadd_sh_reg'HIGH).valid;
		
			for i in 0 to multadd_sh_reg'HIGH-1 loop
				multadd_sh_reg_next(i + 1) <= multadd_sh_reg(i);
			end loop;
			multadd_sh_reg_next(0).tuser <= in_ports.multadd_in_tuser;
			multadd_sh_reg_next(0).valid <= in_ports.multadd_in_tvalid;
					
			for i in 0 to multadd_c_shift_reg'HIGH-1 loop
				multadd_c_shift_reg_next(i + 1) <= multadd_c_shift_reg(i);
			end loop;
			multadd_c_shift_reg_next(0) <= in_ports.multadd_in_tdata(127 downto 64);
		end if;
	end process;
		
	process (
		enable,
		resetn,
		in_ports,
		multaddu_sh_reg,
		multaddu_c_shift_reg
		)
	begin
		multaddu_sh_reg_next <= multaddu_sh_reg;
		multaddu_c_shift_reg_next <= multaddu_c_shift_reg;
		multaddu_ce <= '0';
		out_ports.multaddu_out_tvalid <= '0';
		out_ports.multaddu_out_tuser <= (others => '0');
			
		if resetn = '0' then
			multaddu_ce <= '0';
			out_ports.multaddu_out_tvalid <= '0';
			out_ports.multaddu_out_tuser <= (others => '0');
			for i in 0 to multaddu_sh_reg'HIGH loop
				multaddu_sh_reg_next(i).tuser <= (others => '0');
				multaddu_sh_reg_next(i).valid <= '0';
			end loop;
			for i in 0 to multaddu_c_shift_reg'HIGH loop
				multaddu_c_shift_reg_next(i) <= (others => '0');
			end loop;
		elsif enable = '1' then
			
			multaddu_ce <= '1';
			out_ports.multaddu_out_tuser <= multaddu_sh_reg(multaddu_sh_reg'HIGH).tuser;
			out_ports.multaddu_out_tvalid <= multaddu_sh_reg(multaddu_sh_reg'HIGH).valid;
		
			for i in 0 to multaddu_sh_reg'HIGH-1 loop
				multaddu_sh_reg_next(i + 1) <= multaddu_sh_reg(i);
			end loop;
			multaddu_sh_reg_next(0).tuser <= in_ports.multaddu_in_tuser;
			multaddu_sh_reg_next(0).valid <= in_ports.multaddu_in_tvalid;
					
			for i in 0 to multaddu_c_shift_reg'HIGH-1 loop
				multaddu_c_shift_reg_next(i + 1) <= multaddu_c_shift_reg(i);
			end loop;
			multaddu_c_shift_reg_next(0) <= in_ports.multaddu_in_tdata(127 downto 64);
		end if;
	end process;
		
		
	process (
		enable,
		resetn,
		in_ports,
		cmp_valid_reg,
		cmp_result_tuser,
		cmp_result,
		cmp_tuser
		)
	begin
		cmp_valid_reg_next <= cmp_valid_reg;
		cmp_result_tuser_next <= cmp_result_tuser;
		cmp_result_next <= cmp_result;
		
		if resetn = '0' then
			cmp_valid_reg_next <= '0';
			cmp_result_tuser_next <= (others => '0');
			cmp_result_next <= '0';
		elsif enable = '1' then
			cmp_valid_reg_next <= in_ports.cmp_in_tvalid;
			cmp_result_tuser_next <= cmp_result_tuser;
			cmp_result_next <= cmp_result;
				
			cmp_result_tuser_next <= in_ports.cmp_in_tuser;
			if cmp_tuser.eq = '1' then
				if in_ports.cmp_in_tdata(31 downto 0) = in_ports.cmp_in_tdata(63 downto 32) then
					cmp_result_next <= not cmp_tuser.invert;
				else
					cmp_result_next <= cmp_tuser.invert;
				end if;
			end if;
			if cmp_tuser.ge = '1' then
				if cmp_tuser.unsigned = '1' then
					if unsigned(in_ports.cmp_in_tdata(31 downto 0)) >= unsigned(in_ports.cmp_in_tdata(63 downto 32)) then
						cmp_result_next <= not cmp_tuser.invert;
					else
						cmp_result_next <= cmp_tuser.invert;
					end if;
				else
					if signed(in_ports.cmp_in_tdata(31 downto 0)) >= signed(in_ports.cmp_in_tdata(63 downto 32)) then
						cmp_result_next <= not cmp_tuser.invert;
					else
						cmp_result_next <= cmp_tuser.invert;
					end if;
				end if;
			end if;
			if cmp_tuser.le = '1' then
				if cmp_tuser.unsigned = '1' then
					if unsigned(in_ports.cmp_in_tdata(31 downto 0)) <= unsigned(in_ports.cmp_in_tdata(63 downto 32)) then
						cmp_result_next <= not cmp_tuser.invert;
					else
						cmp_result_next <= cmp_tuser.invert;
					end if;
				else
					if signed(in_ports.cmp_in_tdata(31 downto 0)) <= signed(in_ports.cmp_in_tdata(63 downto 32)) then
						cmp_result_next <= not cmp_tuser.invert;
					else
						cmp_result_next <= cmp_tuser.invert;
					end if;
				end if;
			end if;
		end if;
	end process;
	
	process (
		enable,
		resetn,
		in_ports,
		
		and_out_tdata_reg,
		and_out_tuser_reg,
		and_out_tvalid_reg,
		
		or_out_tdata_reg,
		or_out_tuser_reg,
		or_out_tvalid_reg,
		
		xor_out_tdata_reg,
		xor_out_tuser_reg,
		xor_out_tvalid_reg,
		
		nor_out_tdata_reg,
		nor_out_tuser_reg,
		nor_out_tvalid_reg,
		
		shl_out_tdata_reg,
		shl_out_tuser_reg,
		shl_out_tvalid_reg,
		
		shr_out_tdata_reg,
		shr_out_tuser_reg,
		shr_out_tvalid_reg
		)
	begin
		and_out_tdata_reg_next <= and_out_tdata_reg;
		and_out_tuser_reg_next <= and_out_tuser_reg;
		and_out_tvalid_reg_next <= and_out_tvalid_reg;
		
		or_out_tdata_reg_next <= or_out_tdata_reg;
		or_out_tuser_reg_next <= or_out_tuser_reg;
		or_out_tvalid_reg_next <= or_out_tvalid_reg;
		
		xor_out_tdata_reg_next <= xor_out_tdata_reg;
		xor_out_tuser_reg_next <= xor_out_tuser_reg;
		xor_out_tvalid_reg_next <= xor_out_tvalid_reg;
		
		nor_out_tdata_reg_next <= nor_out_tdata_reg;
		nor_out_tuser_reg_next <= nor_out_tuser_reg;
		nor_out_tvalid_reg_next <= nor_out_tvalid_reg;
		
		shl_out_tdata_reg_next <= shl_out_tdata_reg;
		shl_out_tuser_reg_next <= shl_out_tuser_reg;
		shl_out_tvalid_reg_next <= shl_out_tvalid_reg;
		
		shr_out_tdata_reg_next <= shr_out_tdata_reg;
		shr_out_tuser_reg_next <= shr_out_tuser_reg;
		shr_out_tvalid_reg_next <= shr_out_tvalid_reg;
					
		if resetn = '0' then
			and_out_tdata_reg_next <= (others => '0');
			and_out_tuser_reg_next <= (others => '0');
			and_out_tvalid_reg_next <= '0';
			
			or_out_tdata_reg_next <= (others => '0');
			or_out_tuser_reg_next <= (others => '0');
			or_out_tvalid_reg_next <= '0';
			
			xor_out_tdata_reg_next <= (others => '0');
			xor_out_tuser_reg_next <= (others => '0');
			xor_out_tvalid_reg_next <= '0';
			
			nor_out_tdata_reg_next <= (others => '0');
			nor_out_tuser_reg_next <= (others => '0');
			nor_out_tvalid_reg_next <= '0';
			
			shl_out_tdata_reg_next <= (others => '0');
			shl_out_tuser_reg_next <= (others => '0');
			shl_out_tvalid_reg_next <= '0';
			
			shr_out_tdata_reg_next <= (others => '0');
			shr_out_tuser_reg_next <= (others => '0');
			shr_out_tvalid_reg_next <= '0';
		elsif enable = '1' then
			and_out_tvalid_reg_next <= in_ports.and_in_tvalid;
			and_out_tdata_reg_next <= in_ports.and_in_tdata(63 downto 32) and in_ports.and_in_tdata(31 downto 0);
			and_out_tuser_reg_next <= in_ports.and_in_tuser;
			
			or_out_tvalid_reg_next <= in_ports.or_in_tvalid;
			or_out_tdata_reg_next <= in_ports.or_in_tdata(63 downto 32) or in_ports.or_in_tdata(31 downto 0);
			or_out_tuser_reg_next <= in_ports.or_in_tuser;
			
			xor_out_tvalid_reg_next <= in_ports.xor_in_tvalid;
			xor_out_tdata_reg_next <= in_ports.xor_in_tdata(63 downto 32) xor in_ports.xor_in_tdata(31 downto 0);
			xor_out_tuser_reg_next <= in_ports.xor_in_tuser;
			
			nor_out_tvalid_reg_next <= in_ports.nor_in_tvalid;
			nor_out_tdata_reg_next <= in_ports.nor_in_tdata(63 downto 32) nor in_ports.nor_in_tdata(31 downto 0);
			nor_out_tuser_reg_next <= in_ports.nor_in_tuser;
			
			shl_out_tvalid_reg_next <= in_ports.shl_in_tvalid;
			shl_out_tdata_reg_next <= in_ports.shl_in_tdata(31 downto 0) sll TO_INTEGER(UNSIGNED(in_ports.shl_in_tdata(36 downto 32)));
			shl_out_tuser_reg_next <= in_ports.shl_in_tuser;
			
			shr_out_tvalid_reg_next <= in_ports.shr_in_tvalid;
			if in_ports.shr_in_tuser(5) = '1' then
				shr_out_tdata_reg_next <= shift_right_arith(in_ports.shr_in_tdata(31 downto 0), TO_INTEGER(UNSIGNED(in_ports.shr_in_tdata(36 downto 32))));
			else
				shr_out_tdata_reg_next <= in_ports.shr_in_tdata(31 downto 0) srl TO_INTEGER(UNSIGNED(in_ports.shr_in_tdata(36 downto 32)));
			end if;
			shr_out_tuser_reg_next <= in_ports.shr_in_tuser;
		end if;
	end process;
	
	add_sub_i : c_addsub_0
	  PORT MAP (
		A => add_sub_op_a,
		B => add_sub_op_b,
		CLK => clock,
		ADD => add_sub_select,
		CE => add_sub_ce,
		C_OUT => add_sub_carry,
		S => add_sub_op_c
	  );
	mult_i : mult_gen_0
	  PORT MAP (
		CLK => clock,
		A => in_ports.mul_in_tdata(31 downto 0),
		B => in_ports.mul_in_tdata(63 downto 32),
		CE => mul_ce,
		P => out_ports.mul_out_tdata
	  );
	div_i : div_gen_0
	  PORT MAP (
		aclk => clock,
		aresetn => resetn,
		s_axis_divisor_tvalid => in_ports.div_in_tvalid,
		s_axis_divisor_tdata => in_ports.div_in_tdata(31 downto 0),
		s_axis_dividend_tvalid => in_ports.div_in_tvalid,
		s_axis_dividend_tuser => in_ports.div_in_tuser,
		s_axis_dividend_tdata => in_ports.div_in_tdata(63 downto 32),
		m_axis_dout_tvalid => out_ports.div_out_tvalid,
		m_axis_dout_tuser => out_ports.div_out_tuser,
		m_axis_dout_tdata => out_ports.div_out_tdata
	  );
	--mult_i2 : mult_gen_1
	--  PORT MAP (
	--	CLK => clock,
	--	A => multu_in_tdata(31 downto 0),
	--	B => multu_in_tdata(63 downto 32),
	--	CE => multu_ce,
	--	P => multu_result
	--  );
	--div_i2 : div_gen_1
	--  PORT MAP (
	--	aclk => clock,
	--	aresetn => resetn,
	--	s_axis_divisor_tvalid => divu_in_tvalid,
	--	s_axis_divisor_tready => divu_in_tready,
	--	s_axis_divisor_tdata => divu_in_tdata(31 downto 0),
	--	s_axis_dividend_tvalid => divu_in_tvalid,
	--	--s_axis_dividend_tready => s_axis_dividend_tready,
	--	s_axis_dividend_tuser => divu_in_tuser,
	--	s_axis_dividend_tdata => divu_in_tdata(63 downto 32),
	--	m_axis_dout_tvalid => divu_out_tvalid,
	--	m_axis_dout_tready => divu_out_tready,
	--	m_axis_dout_tuser => divu_out_tuser,
	--	m_axis_dout_tdata => divu_out_tdata
	--  );
			
	--multadd_i : xbip_multadd_0
	--  PORT MAP (
	--	CLK => clock,
	--	CE => multadd_ce,
	--	SCLR => '0',
	--	A => multadd_in_tdata(31 downto 0),
	--	B => multadd_in_tdata(63 downto 32),
	--	C => multadd_c_shift_reg(multadd_c_shift_reg'HIGH-1),
	--	SUBTRACT => multadd_in_tdata(128),
	--	P => multadd_out_tdata
	--	--PCOUT => PCOUT
	--  );
	--multadd_i2 : xbip_multadd_1
	--  PORT MAP (
	--	CLK => clock,
	--	CE => multaddu_ce,
	--	SCLR => '0',
	--	A => multaddu_in_tdata(31 downto 0),
	--	B => multaddu_in_tdata(63 downto 32),
	--	C => multaddu_c_shift_reg(multaddu_c_shift_reg'HIGH-1),
	--	SUBTRACT => multaddu_in_tdata(128),
	--	P => multaddu_out_tdata
	--	--PCOUT => PCOUT
	--  );
end mips_alu_behavioral;
