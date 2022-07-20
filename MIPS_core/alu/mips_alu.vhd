library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mips_alu is
    port (
		clock : in std_logic;
		resetn : in std_logic;
	
	    add_in_tready : out std_logic;
	    add_in_tvalid : in std_logic;
	    add_in_tdata : in std_logic_vector(63 downto 0);
	    add_in_tuser : in std_logic_vector(5 downto 0);
	    add_out_tready : in std_logic;
	    add_out_tvalid : out std_logic;
	    add_out_tdata : out std_logic_vector(32 downto 0);
	    add_out_tuser : out std_logic_vector(5 downto 0);
		
	    sub_in_tready : out std_logic;
	    sub_in_tvalid : in std_logic;
	    sub_in_tdata : in std_logic_vector(63 downto 0);
	    sub_in_tuser : in std_logic_vector(5 downto 0);
	    sub_out_tready : in std_logic;
	    sub_out_tvalid : out std_logic;
	    sub_out_tdata : out std_logic_vector(32 downto 0);
	    sub_out_tuser : out std_logic_vector(5 downto 0);
	
	    mul_in_tready : out std_logic;
	    mul_in_tvalid : in std_logic;
	    mul_in_tdata : in std_logic_vector(63 downto 0);
	    mul_in_tuser : in std_logic_vector(5 downto 0);
	    mul_out_tready : in std_logic;
	    mul_out_tvalid : out std_logic;
	    mul_out_tdata : out std_logic_vector(63 downto 0);
	    mul_out_tuser : out std_logic_vector(5 downto 0);
	
	    multu_in_tready : out std_logic;
	    multu_in_tvalid : in std_logic;
	    multu_in_tdata : in std_logic_vector(63 downto 0);
	    multu_in_tuser : in std_logic_vector(5 downto 0);
	    multu_out_tready : in std_logic;
	    multu_out_tvalid : out std_logic;
	    multu_out_tdata : out std_logic_vector(63 downto 0);
	    multu_out_tuser : out std_logic_vector(5 downto 0);
	
	    div_in_tready : out std_logic;
	    div_in_tvalid : in std_logic;
	    div_in_tdata : in std_logic_vector(63 downto 0);
	    div_in_tuser : in std_logic_vector(5 downto 0);
	    div_out_tready : in std_logic;
	    div_out_tvalid : out std_logic;
	    div_out_tdata : out std_logic_vector(63 downto 0);
	    div_out_tuser : out std_logic_vector(5 downto 0);
	
	    divu_in_tready : out std_logic;
	    divu_in_tvalid : in std_logic;
	    divu_in_tdata : in std_logic_vector(63 downto 0);
	    divu_in_tuser : in std_logic_vector(5 downto 0);
	    divu_out_tready : in std_logic;
	    divu_out_tvalid : out std_logic;
	    divu_out_tdata : out std_logic_vector(63 downto 0);
	    divu_out_tuser : out std_logic_vector(5 downto 0);
	
	    multadd_in_tready : out std_logic;
	    multadd_in_tvalid : in std_logic;
	    multadd_in_tdata : in std_logic_vector(128 downto 0);
	    multadd_in_tuser : in std_logic_vector(5 downto 0);
	    multadd_out_tready : in std_logic;
	    multadd_out_tvalid : out std_logic;
	    multadd_out_tdata : out std_logic_vector(63 downto 0);
	    multadd_out_tuser : out std_logic_vector(5 downto 0);
	
	    multaddu_in_tready : out std_logic;
	    multaddu_in_tvalid : in std_logic;
	    multaddu_in_tdata : in std_logic_vector(128 downto 0);
	    multaddu_in_tuser : in std_logic_vector(5 downto 0);
	    multaddu_out_tready : in std_logic;
	    multaddu_out_tvalid : out std_logic;
	    multaddu_out_tdata : out std_logic_vector(63 downto 0);
	    multaddu_out_tuser : out std_logic_vector(5 downto 0)
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
	signal add_tuser_reg : std_logic_vector(5 downto 0);
	signal add_tuser_reg_next : std_logic_vector(5 downto 0);
	signal sub_result_pending : std_logic;
	signal sub_result_pending_next : std_logic;
	signal sub_tuser_reg : std_logic_vector(5 downto 0);
	signal sub_tuser_reg_next : std_logic_vector(5 downto 0);
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
begin
	
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
		end if;
	end process;
	
	process (
		resetn,
		
		add_in_tvalid,
		add_in_tdata,
		add_in_tuser,
		add_out_tready,
		
		sub_in_tvalid,
		sub_in_tdata,
		sub_in_tuser,
		sub_out_tready,
				
		add_result_pending,
		add_tuser_reg,
		sub_result_pending,
		sub_tuser_reg,
		
		add_sub_carry,
		add_sub_op_c
		)
		variable vadvance : std_logic;
	begin
		add_in_tready <= '0';
		sub_in_tready <= '0';
		add_sub_op_a <= (others => '0');
		add_sub_op_b <= (others => '0');
		add_sub_select <= '1';
		add_sub_ce <= '0';
		
		add_out_tvalid <= add_result_pending;
		sub_out_tvalid <= sub_result_pending;
		
		add_out_tdata <= add_sub_carry & add_sub_op_c;
		sub_out_tdata <= add_sub_carry & add_sub_op_c;
		
		add_out_tuser <= add_tuser_reg;
		sub_out_tuser <= sub_tuser_reg;
		
		if resetn = '0' then
			add_result_pending_next <= '0';
			add_tuser_reg_next <= (others => '0');
			sub_result_pending_next <= '0';
			sub_tuser_reg_next <= (others => '0');
		else
			add_result_pending_next <= (add_result_pending and not add_out_tready) or add_in_tvalid;
			add_tuser_reg_next <= add_tuser_reg;
			sub_result_pending_next <= (sub_result_pending and not sub_out_tready) or sub_in_tvalid;
			sub_tuser_reg_next <= sub_tuser_reg;
		
			if add_in_tvalid = '1' and (add_result_pending = '0' or add_out_tready = '1') and
				(sub_result_pending = '0' or sub_out_tready = '1') then
				
				add_in_tready <= '1';
				add_sub_op_a <= add_in_tdata(31 downto 0);
				add_sub_op_b <= add_in_tdata(63 downto 32);
				add_sub_select <= '1';
				add_sub_ce <= '1';
				add_tuser_reg_next <= add_in_tuser;
				add_result_pending_next <= '1';
			elsif sub_in_tvalid = '1' and (sub_result_pending = '0' or sub_out_tready = '1') and
				(add_result_pending = '0' or add_out_tready = '1') then
				
				sub_in_tready <= '1';
				add_sub_op_a <= sub_in_tdata(31 downto 0);
				add_sub_op_b <= sub_in_tdata(63 downto 32);
				add_sub_select <= '0';
				add_sub_ce <= '1';
				sub_tuser_reg_next <= sub_in_tuser;
				sub_result_pending_next <= '1';
			end if;
			
		end if;
	end process;
		
	-- multiply process
	process (
		resetn,
		mul_in_tvalid,
		mul_in_tuser,
		mul_out_tready,
		mul_sh_reg
		)
		variable vadvance : std_logic;
	begin
		mul_sh_reg_next <= mul_sh_reg;
		
		if resetn = '0' then
			mul_ce <= '0';
			mul_out_tvalid <= '0';
			mul_in_tready <= '0';
			mul_out_tuser <= (others => '0');
			for i in 0 to mul_sh_reg'HIGH loop
				mul_sh_reg_next(i).tuser <= (others => '0');
				mul_sh_reg_next(i).valid <= '0';
			end loop;
		else
			vadvance := not mul_sh_reg(mul_sh_reg'HIGH).valid or mul_out_tready;
		
			mul_ce <= vadvance;
			mul_in_tready <= mul_in_tvalid and vadvance;
			mul_out_tuser <= mul_sh_reg(mul_sh_reg'HIGH).tuser;
			mul_out_tvalid <= mul_sh_reg(mul_sh_reg'HIGH).valid;
			
			if vadvance = '1' then
				for i in 0 to mul_sh_reg'HIGH-1 loop
					mul_sh_reg_next(i + 1) <= mul_sh_reg(i);
				end loop;
				mul_sh_reg_next(0).tuser <= mul_in_tuser;
				mul_sh_reg_next(0).valid <= mul_in_tvalid;
			end if;
		end if;
	end process;
	
	-- multiply unsigned
	multu_out_tdata <= multu_result;
	process (
		resetn,
		multu_in_tvalid,
		multu_in_tuser,
		multu_out_tready,
		multu_sh_reg
		)
		variable vadvance : std_logic;
	begin
		multu_sh_reg_next <= multu_sh_reg;
		
		if resetn = '0' then
			multu_ce <= '0';
			multu_out_tvalid <= '0';
			multu_in_tready <= '0';
			multu_out_tuser <= (others => '0');
			for i in 0 to multu_sh_reg'HIGH loop
				multu_sh_reg_next(i).tuser <= (others => '0');
				multu_sh_reg_next(i).valid <= '0';
			end loop;
		else
			vadvance := not multu_sh_reg(multu_sh_reg'HIGH).valid or multu_out_tready;
		
			multu_ce <= vadvance;
			multu_in_tready <= multu_in_tvalid and vadvance;
			multu_out_tuser <= multu_sh_reg(multu_sh_reg'HIGH).tuser;
			multu_out_tvalid <= multu_sh_reg(multu_sh_reg'HIGH).valid;
			
			if vadvance = '1' then
				for i in 0 to multu_sh_reg'HIGH-1 loop
					multu_sh_reg_next(i + 1) <= multu_sh_reg(i);
				end loop;
				multu_sh_reg_next(0).tuser <= multu_in_tuser;
				multu_sh_reg_next(0).valid <= multu_in_tvalid;
			end if;
		end if;
	end process;
	
	process (
		resetn,
		multadd_in_tvalid,
		multadd_in_tuser,
		multadd_out_tready,
		multadd_sh_reg,
		multadd_in_tdata,
		multadd_c_shift_reg
		)
		variable vadvance : std_logic;
	begin
		multadd_sh_reg_next <= multadd_sh_reg;
		multadd_c_shift_reg_next <= multadd_c_shift_reg;
		
		if resetn = '0' then
			multadd_ce <= '0';
			multadd_out_tvalid <= '0';
			multadd_in_tready <= '0';
			multadd_out_tuser <= (others => '0');
			for i in 0 to multadd_sh_reg'HIGH loop
				multadd_sh_reg_next(i).tuser <= (others => '0');
				multadd_sh_reg_next(i).valid <= '0';
			end loop;
			for i in 0 to multadd_c_shift_reg'HIGH loop
				multadd_c_shift_reg_next(i) <= (others => '0');
			end loop;
		else
			vadvance := not multadd_sh_reg(multadd_sh_reg'HIGH).valid or multadd_out_tready;
		
			multadd_ce <= vadvance;
			multadd_in_tready <= multadd_in_tvalid and vadvance;
			multadd_out_tuser <= multadd_sh_reg(multadd_sh_reg'HIGH).tuser;
			multadd_out_tvalid <= multadd_sh_reg(multadd_sh_reg'HIGH).valid;
	
			if vadvance = '1' then
				for i in 0 to multadd_sh_reg'HIGH-1 loop
					multadd_sh_reg_next(i + 1) <= multadd_sh_reg(i);
				end loop;
				multadd_sh_reg_next(0).tuser <= multadd_in_tuser;
				multadd_sh_reg_next(0).valid <= multadd_in_tvalid;
				
				for i in 0 to multadd_c_shift_reg'HIGH-1 loop
					multadd_c_shift_reg_next(i + 1) <= multadd_c_shift_reg(i);
				end loop;
				multadd_c_shift_reg_next(0) <= multadd_in_tdata(127 downto 64);
			end if;
		end if;
	end process;
	
	process (
		resetn,
		multaddu_in_tvalid,
		multaddu_in_tuser,
		multaddu_out_tready,
		multaddu_sh_reg,
		multaddu_in_tdata,
		multaddu_c_shift_reg
		)
		variable vadvance : std_logic;
	begin
		multaddu_sh_reg_next <= multaddu_sh_reg;
		multaddu_c_shift_reg_next <= multaddu_c_shift_reg;
		
		if resetn = '0' then
			multaddu_ce <= '0';
			multaddu_out_tvalid <= '0';
			multaddu_in_tready <= '0';
			multaddu_out_tuser <= (others => '0');
			for i in 0 to multaddu_sh_reg'HIGH loop
				multaddu_sh_reg_next(i).tuser <= (others => '0');
				multaddu_sh_reg_next(i).valid <= '0';
			end loop;
			for i in 0 to multaddu_c_shift_reg'HIGH loop
				multaddu_c_shift_reg_next(i) <= (others => '0');
			end loop;
		else
			vadvance := not multaddu_sh_reg(multaddu_sh_reg'HIGH).valid or multaddu_out_tready;
		
			multaddu_ce <= vadvance;
			multaddu_in_tready <= multaddu_in_tvalid and vadvance;
			multaddu_out_tuser <= multaddu_sh_reg(multaddu_sh_reg'HIGH).tuser;
			multaddu_out_tvalid <= multaddu_sh_reg(multaddu_sh_reg'HIGH).valid;
	
			if vadvance = '1' then
				for i in 0 to multaddu_sh_reg'HIGH-1 loop
					multaddu_sh_reg_next(i + 1) <= multaddu_sh_reg(i);
				end loop;
				multaddu_sh_reg_next(0).tuser <= multaddu_in_tuser;
				multaddu_sh_reg_next(0).valid <= multaddu_in_tvalid;
				
				for i in 0 to multaddu_c_shift_reg'HIGH-1 loop
					multaddu_c_shift_reg_next(i + 1) <= multaddu_c_shift_reg(i);
				end loop;
				multaddu_c_shift_reg_next(0) <= multaddu_in_tdata(127 downto 64);
			end if;
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
		A => mul_in_tdata(31 downto 0),
		B => mul_in_tdata(63 downto 32),
		CE => mul_ce,
		P => mul_out_tdata
	  );
	div_i : div_gen_0
	  PORT MAP (
		aclk => clock,
		aresetn => resetn,
		s_axis_divisor_tvalid => div_in_tvalid,
		s_axis_divisor_tready => div_in_tready,
		s_axis_divisor_tdata => div_in_tdata(31 downto 0),
		s_axis_dividend_tvalid => div_in_tvalid,
		--s_axis_dividend_tready => s_axis_dividend_tready,
		s_axis_dividend_tuser => div_in_tuser,
		s_axis_dividend_tdata => div_in_tdata(63 downto 32),
		m_axis_dout_tvalid => div_out_tvalid,
		m_axis_dout_tready => div_out_tready,
		m_axis_dout_tuser => div_out_tuser,
		m_axis_dout_tdata => div_out_tdata
	  );
	mult_i2 : mult_gen_1
	  PORT MAP (
		CLK => clock,
		A => multu_in_tdata(31 downto 0),
		B => multu_in_tdata(63 downto 32),
		CE => multu_ce,
		P => multu_result
	  );
	div_i2 : div_gen_1
	  PORT MAP (
		aclk => clock,
		aresetn => resetn,
		s_axis_divisor_tvalid => divu_in_tvalid,
		s_axis_divisor_tready => divu_in_tready,
		s_axis_divisor_tdata => divu_in_tdata(31 downto 0),
		s_axis_dividend_tvalid => divu_in_tvalid,
		--s_axis_dividend_tready => s_axis_dividend_tready,
		s_axis_dividend_tuser => divu_in_tuser,
		s_axis_dividend_tdata => divu_in_tdata(63 downto 32),
		m_axis_dout_tvalid => divu_out_tvalid,
		m_axis_dout_tready => divu_out_tready,
		m_axis_dout_tuser => divu_out_tuser,
		m_axis_dout_tdata => divu_out_tdata
	  );
	
	multadd_i : xbip_multadd_0
	  PORT MAP (
		CLK => clock,
		CE => multadd_ce,
		SCLR => '0',
		A => multadd_in_tdata(31 downto 0),
		B => multadd_in_tdata(63 downto 32),
		C => multadd_c_shift_reg(multadd_c_shift_reg'HIGH-1),
		SUBTRACT => multadd_in_tdata(128),
		P => multadd_out_tdata
		--PCOUT => PCOUT
	  );
	multadd_i2 : xbip_multadd_1
	  PORT MAP (
		CLK => clock,
		CE => multaddu_ce,
		SCLR => '0',
		A => multaddu_in_tdata(31 downto 0),
		B => multaddu_in_tdata(63 downto 32),
		C => multaddu_c_shift_reg(multaddu_c_shift_reg'HIGH-1),
		SUBTRACT => multaddu_in_tdata(128),
		P => multaddu_out_tdata
		--PCOUT => PCOUT
	  );
end mips_alu_behavioral;
