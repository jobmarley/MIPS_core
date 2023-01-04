-- 
--  Copyright (C) 2022 jobmarley
-- 
--  This file is part of MIPS_core.
-- 
--  This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
-- 
--  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
--  You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.
--  

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.axi_helper.all;
use work.mips_utils.all;
library xpm;
use xpm.vcomponents.all;

entity cache_memory is
	--generic(
	--	BRAM_data_width : POSITIVE := 512;
	--	BRAM_address_width : POSITIVE := 8
	--);
	port (
	resetn : in std_logic;
	clock : in std_logic;
	
	-- port A
	porta_address : in std_logic_vector(31 downto 0);
	porta_address_ready : out std_logic;
	porta_address_valid : in std_logic;
	porta_read_data : out std_logic_vector(31 downto 0);
	porta_read_data_ready : in std_logic;
	porta_read_data_valid : out std_logic;
	
	
	-- AXI4 RAM 
	M_AXI_araddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_arburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_arcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_arlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_arlock : out STD_LOGIC;
    M_AXI_arprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_arready : in STD_LOGIC;
    M_AXI_arsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_arvalid : out STD_LOGIC;
    M_AXI_awaddr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_awburst : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_awcache : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_awlen : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M_AXI_awlock : out STD_LOGIC;
    M_AXI_awprot : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_awready : in STD_LOGIC;
    M_AXI_awsize : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_awvalid : out STD_LOGIC;
    M_AXI_bready : out STD_LOGIC;
    M_AXI_bresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_bvalid : in STD_LOGIC;
    M_AXI_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_rlast : in STD_LOGIC;
    M_AXI_rready : out STD_LOGIC;
    M_AXI_rresp : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_rvalid : in STD_LOGIC;
    M_AXI_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_wlast : out STD_LOGIC;
    M_AXI_wready : in STD_LOGIC;
    M_AXI_wstrb : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_wvalid : out STD_LOGIC
	);
end cache_memory;

architecture cache_memory_behavioral of cache_memory is
		
	-- see https://docs.xilinx.com/r/en-US/ug953-vivado-7series-libraries/XPM_MEMORY_SPRAM
	component xpm_memory_spram is
	generic (
	   ADDR_WIDTH_A : INTEGER;
	   AUTO_SLEEP_TIME : INTEGER;
	   BYTE_WRITE_WIDTH_A : INTEGER;
	   CASCADE_HEIGHT : INTEGER;
	   ECC_MODE : STRING;
	   MEMORY_INIT_FILE : STRING;
	   MEMORY_INIT_PARAM : STRING;
	   MEMORY_OPTIMIZATION : STRING;
	   MEMORY_PRIMITIVE : STRING;
	   MEMORY_SIZE : INTEGER;
	   MESSAGE_CONTROL : INTEGER;
	   READ_DATA_WIDTH_A : INTEGER;
	   READ_LATENCY_A : INTEGER;
	   READ_RESET_VALUE_A : STRING;
	   RST_MODE_A : STRING;
	   SIM_ASSERT_CHK : INTEGER;
	   USE_MEM_INIT : INTEGER;
	   USE_MEM_INIT_MMI : INTEGER;
	   WAKEUP_TIME : STRING;
	   WRITE_DATA_WIDTH_A : INTEGER;
	   WRITE_MODE_A : STRING;
	   WRITE_PROTECT : INTEGER
	);
	port (
	   dbiterra : out std_logic;
	   douta : out std_logic_vector(READ_DATA_WIDTH_A-1 downto 0);
	   sbiterra : out std_logic;
	   addra : in std_logic_vector(ADDR_WIDTH_A-1 downto 0);
	   clka : in std_logic;
	   dina : in std_logic_vector(WRITE_DATA_WIDTH_A-1 downto 0);
	   ena : in std_logic;
	   injectdbiterra : in std_logic;
	   injectsbiterra : in std_logic;
	   regcea : in std_logic;
	   rsta : in std_logic;
	   sleep : in std_logic;
	   wea : in std_logic_vector(WRITE_DATA_WIDTH_A/BYTE_WRITE_WIDTH_A-1 downto 0)

	);
	end component;
	
	function log2(v : NATURAL) return NATURAL is
		variable tmp : NATURAL := 0;
		variable result : NATURAL := 0;
	begin
		tmp := v;
		while tmp /= 1 loop
			tmp := tmp / 2;
			result := result + 1;
		end loop;
		return result;
	end function;
	
	
	constant DATA_WIDTH_BITS : NATURAL := 32;							-- size of data out
	constant DATA_WIDTH_BYTE : NATURAL := DATA_WIDTH_BITS / 8;
	constant RAM_DATA_WIDTH_BITS : NATURAL := 32;						-- size of ram/bram data
	constant RAM_DATA_WIDTH_BYTE : NATURAL := RAM_DATA_WIDTH_BITS / 8;
	
	constant LINE_LENGTH : NATURAL := 8;
	constant LINE_LENGTH_BITS : NATURAL := LINE_LENGTH * DATA_WIDTH_BITS;
	constant LINE_LENGTH_BYTE : NATURAL := LINE_LENGTH_BITS / 8;
	constant SET_COUNT : NATURAL := 16;																-- number of entries in a set
	constant WAY_COUNT : NATURAL := 2;
	
	constant BRAM_MEMORY_SIZE_BYTE : NATURAL := LINE_LENGTH_BYTE*SET_COUNT*WAY_COUNT;
	constant BRAM_ADDRESS_WIDTH : NATURAL := log2(BRAM_MEMORY_SIZE_BYTE / RAM_DATA_WIDTH_BYTE);			-- addressable by blocks of RAM_DATA_WIDTH_BYTE
	
	constant TAG_WIDTH_BITS : NATURAL := 32 - log2(LINE_LENGTH_BYTE*SET_COUNT);
	constant SET_INDEX_WIDTH_BITS : NATURAL := log2(SET_COUNT);
	constant OFFSET_WIDTH_BITS : NATURAL := log2(LINE_LENGTH_BYTE);
	
	subtype cache_tag_t is std_logic_vector(TAG_WIDTH_BITS-1 downto 0);
	subtype cache_set_index_t is UNSIGNED(log2(SET_COUNT)-1 downto 0);
	subtype cache_way_index_t is UNSIGNED(log2(WAY_COUNT)-1 downto 0);
	subtype cache_offset_t is std_logic_vector(log2(LINE_LENGTH_BYTE)-1 downto 0);
	
	type cache_line_info_t is record
		tag : cache_tag_t;
		way_index : cache_way_index_t;							-- ways are reordered so we need that
		dirty : std_logic;										-- '1' if that cache line has been written to
		updating : std_logic;
		valid : std_logic;										-- '0' if not initialized
	end record;
		
	type cache_set_info_t is array (WAY_COUNT-1 downto 0) of cache_line_info_t;
	type cache_set_info_array_t is array (SET_COUNT-1 downto 0) of cache_set_info_t;
	
	
	signal cache_infos : cache_set_info_array_t;
	signal cache_infos_next : cache_set_info_array_t;
			
	type state_t is (
		state_idle,
		state_update_read_address,
		state_update_read_data,
		state_update_send_data
	);
	
	signal state : state_t;
	signal state_next : state_t;
		
	type address_t is record
		tag : cache_tag_t;
		set_index : cache_set_index_t;
	end record;
	
	type bram_address_t is record
		set_index : cache_set_index_t;
		way_index : cache_way_index_t;
		offset : cache_offset_t;
	end record;
	
	procedure indexes_from_address(addr : std_logic_vector; variable tag : out cache_tag_t; variable set_index : out cache_set_index_t) is
		variable result : address_t;
	begin
		tag := addr(31 downto 32-TAG_WIDTH_BITS);
		set_index := unsigned(addr(SET_INDEX_WIDTH_BITS+OFFSET_WIDTH_BITS-1 downto OFFSET_WIDTH_BITS));
	end procedure;
		
	signal hit_cache_address : bram_address_t;
	signal hit_cache_address_next : bram_address_t;
	signal hit : std_logic;
	signal hit_next : std_logic;
	signal address : std_logic_vector(31 downto 0);
	signal address_next : std_logic_vector(31 downto 0);
	
	signal bram_address : bram_address_t;
	signal bram_address_next : bram_address_t;
		
	signal reorder_valid : std_logic;
	signal reorder_valid_next : std_logic;
	signal reorder_set_index : cache_set_index_t;
	signal reorder_set_index_next : cache_set_index_t;
	signal reorder_last_used_way_index : cache_way_index_t;
	signal reorder_last_used_way_index_next : cache_way_index_t;
	signal reorder_tag : cache_tag_t;
	signal reorder_tag_next : cache_tag_t;
	
	
	-- block ram
	signal mem_clka : STD_LOGIC;
	signal mem_ena : STD_LOGIC;
	signal mem_wea : STD_LOGIC_VECTOR(RAM_DATA_WIDTH_BYTE-1 DOWNTO 0);
	signal mem_addra : STD_LOGIC_VECTOR(BRAM_ADDRESS_WIDTH-1 downto 0);
	signal mem_dina : STD_LOGIC_VECTOR(RAM_DATA_WIDTH_BITS-1 DOWNTO 0);
	signal mem_douta : STD_LOGIC_VECTOR(RAM_DATA_WIDTH_BITS-1 DOWNTO 0);
	
	signal data_out_reg : slv32_t;
	signal data_out_reg_next : slv32_t;
		
	-- return an slv address for the bram (increments of RAM_DATA_WIDTH_BYTE)
	function BRAM_address_to_slv(address : bram_address_t) return std_logic_vector is
		variable result : std_logic_vector(BRAM_ADDRESS_WIDTH-1 downto 0);
	begin
		result := std_logic_vector(address.set_index) & std_logic_vector(address.way_index) & address.offset(address.offset'HIGH downto log2(RAM_DATA_WIDTH_BYTE));
		return result;
	end function;
	
	signal stall : std_logic;
	signal stall_next : std_logic;
begin
	mem_ena <= '1';
	mem_clka <= clock;
		
	process (clock) is
	begin
		if rising_edge(clock) then
			state <= state_next;
			
			hit <= hit_next;
			hit_cache_address <= hit_cache_address_next;
						
			address <= address_next;
			
			reorder_valid <= reorder_valid_next;
			reorder_set_index <= reorder_set_index_next;
			reorder_last_used_way_index <= reorder_last_used_way_index_next;
			reorder_tag <= reorder_tag_next;
			
			bram_address <= bram_address_next;
			
			cache_infos <= cache_infos_next;
			
			data_out_reg <= data_out_reg_next;
			
			stall <= stall_next;
		end if;
	end process;

	process(
		resetn,
		state,
		porta_address,
		porta_address_valid,
		porta_read_data_ready,
		address,
		cache_infos,
		
		M_AXI_arready,
		M_AXI_awready,
		M_AXI_bresp,
		M_AXI_bvalid,
		M_AXI_rdata,
		M_AXI_rlast,
		M_AXI_rresp,
		M_AXI_rvalid,
		M_AXI_wready,
		
		hit,
		hit_cache_address,
		
		bram_address,
		
		reorder_set_index,
		reorder_last_used_way_index,
		reorder_tag,
		
		mem_douta,
		data_out_reg,
		
		stall
		)
		variable vtag : cache_tag_t;
		variable vset_index : cache_set_index_t;
		variable vcache_line : cache_line_info_t;
		variable vhit : std_logic;
		variable vhit_cache_address : bram_address_t;
	begin
		porta_address_ready <= '0';
	
		state_next <= state;
		
		hit_next <= hit;
		hit_cache_address_next <= hit_cache_address;
		
		address_next <= address;
		
		M_AXI_araddr <= (others => '0');
		M_AXI_arburst <= (others => '0');
		M_AXI_arcache <= (others => '0');
		M_AXI_arlen <= (others => '0');
		M_AXI_arlock <= '0';
		M_AXI_arprot <= (others => '0');
		M_AXI_arsize <= (others => '0');
		M_AXI_arvalid <= '0';
		M_AXI_awaddr <= (others => '0');
		M_AXI_awburst <= (others => '0');
		M_AXI_awcache <= (others => '0');
		M_AXI_awlen <= (others => '0');
		M_AXI_awlock <= '0';
		M_AXI_awprot <= (others => '0');
		M_AXI_awsize <= (others => '0');
		M_AXI_awvalid <= '0';
		M_AXI_bready <= '0';
		M_AXI_rready <= '0';
		M_AXI_wdata <= (others => '0');
		M_AXI_wlast <= '0';
		M_AXI_wstrb <= (others => '0');
		M_AXI_wvalid <= '0';
		
		mem_wea <= (others => '0');
		mem_addra <= BRAM_address_to_slv(hit_cache_address);
		mem_dina <= (others => '0');
		
		reorder_valid_next <= '0';
		reorder_set_index_next <= reorder_set_index;
		reorder_last_used_way_index_next <= reorder_last_used_way_index;
		reorder_tag_next <= reorder_tag;
		
		bram_address_next <= bram_address;
				
		if resetn = '0' then
			hit_cache_address_next <= (offset => (others => '0'), set_index => (others => '0'), way_index => (others => '0'));
			bram_address_next <= (offset => (others => '0'), set_index => (others => '0'), way_index => (others => '0'));
			address_next <= (others => '0');
			reorder_set_index_next <= (others => '0');
			reorder_tag_next <= (others => '0');
			reorder_last_used_way_index_next <= (others => '0');
			hit_next <= '0';
			state_next <= state_idle;
		else
			case state is
				when state_idle =>
					if stall = '0' then
						porta_address_ready <= '1';
						address_next <= porta_address;
					
						indexes_from_address(porta_address, vtag, vset_index);
				
						vhit := '0';
					
						reorder_set_index_next <= vset_index;
						reorder_tag_next <= vtag;
					
						hit_next <= '0';
					
						for i in WAY_COUNT-1 downto 0 loop
							vcache_line := cache_infos(TO_INTEGER(vset_index))(i);
							if vtag = vcache_line.tag and vcache_line.valid = '1' then
								vhit_cache_address.set_index := vset_index;
								vhit_cache_address.way_index := vcache_line.way_index;
								vhit_cache_address.offset := porta_address(hit_cache_address.offset'LENGTH-1 downto 0);
								hit_cache_address_next <= vhit_cache_address;	
							
								hit_next <= porta_address_valid;
							
								-- reorder
								reorder_valid_next <= porta_address_valid;
								reorder_last_used_way_index_next <= TO_UNSIGNED(i, reorder_last_used_way_index'LENGTH);
												
								-- read data
								mem_wea <= (others => '0');
								mem_addra <= BRAM_address_to_slv(vhit_cache_address);
								mem_dina <= (others => '0');
							
								vhit := porta_address_valid;
							end if;
						end loop;
					
						if vhit = '0' and porta_address_valid = '1' then
							state_next <= state_update_read_address;
						end if;
					end if;
				
				when state_update_read_address =>
					vcache_line := cache_infos(TO_INTEGER(reorder_set_index))(WAY_COUNT-1);		
					reorder_last_used_way_index_next <= TO_UNSIGNED(WAY_COUNT-1, reorder_last_used_way_index'LENGTH);
					
					bram_address_next.set_index <= reorder_set_index;
					bram_address_next.way_index <= vcache_line.way_index;
					bram_address_next.offset <= (others => '0');
						
					M_AXI_araddr <= (others => '0');
					M_AXI_araddr(31 downto OFFSET_WIDTH_BITS) <= address(31 downto OFFSET_WIDTH_BITS);
					M_AXI_arvalid <= '1';
					M_AXI_arburst <= AXI4_BURST_INCR;
					M_AXI_arlen <= std_logic_vector(TO_UNSIGNED(LINE_LENGTH_BYTE / RAM_DATA_WIDTH_BYTE - 1, 8));
					M_AXI_arsize <= AXI4_BURST_SIZE_64;
					if M_AXI_arready = '1' then
						reorder_valid_next <= '1';
						state_next <= state_update_read_data;
					end if;
				when state_update_read_data =>
					M_AXI_rready <= '1';
					if M_AXI_rvalid = '1' then
						mem_wea <= (others => '1');
						mem_addra <= BRAM_address_to_slv(bram_address);
						mem_dina <= M_AXI_rdata;
						bram_address_next.offset <= std_logic_vector(UNSIGNED(bram_address.offset) + RAM_DATA_WIDTH_BYTE);
						if M_AXI_rlast = '1' then
							state_next <= state_update_send_data;
						end if;
					end if;
				when state_update_send_data =>
					-- could remove that step by intercepting the correct offset in update
					hit_next <= '1';
							
					vhit_cache_address.set_index := bram_address.set_index;
					vhit_cache_address.way_index := bram_address.way_index;
					vhit_cache_address.offset := address(hit_cache_address.offset'LENGTH-1 downto 0);
					hit_cache_address_next <= vhit_cache_address;	
							
					-- read data
					mem_wea <= (others => '0');
					mem_addra <= BRAM_address_to_slv(vhit_cache_address);
					mem_dina <= (others => '0');
					
					state_next <= state_idle;
				when others =>
			end case;
		end if;
	end process;
		
	process(
		resetn,
		hit,
		porta_read_data_ready,
		data_out_reg,
		mem_douta,
		stall
		)
	begin
		stall_next <= '0';
		
		data_out_reg_next <= data_out_reg;
		
		porta_read_data_valid <= '0';
		porta_read_data <= (others => '0');
		
		if resetn = '0' then
			data_out_reg_next <= (others => '0');
		else
			-- handle output
			if stall = '1' then
				stall_next <= not porta_read_data_ready;
				porta_read_data_valid <= '1';
				porta_read_data <= data_out_reg;
			elsif hit = '1' then
				stall_next <= not porta_read_data_ready;
				data_out_reg_next <= mem_douta;
				porta_read_data_valid <= '1';
				porta_read_data <= mem_douta;
			end if;
		end if;
	end process;
	
	-- update the order of ways infos (0 is most recently used)
	process(
		resetn,
		reorder_valid,
		reorder_set_index,
		reorder_tag,
		reorder_last_used_way_index,
		cache_infos
		)
		variable iset : NATURAL;
		variable ilast_used_way : NATURAL;
	begin
		iset := TO_INTEGER(reorder_set_index);
		ilast_used_way := TO_INTEGER(reorder_last_used_way_index);
		
		cache_infos_next <= cache_infos;
		
		if resetn = '0' then
			for iset in SET_COUNT-1 downto 0 loop
				for iway in WAY_COUNT-1 downto 0 loop
					cache_infos_next(iset)(iway).tag <= (others => '0');
					cache_infos_next(iset)(iway).way_index <= TO_UNSIGNED(iway, cache_way_index_t'LENGTH);
					cache_infos_next(iset)(iway).dirty <= '0';
					cache_infos_next(iset)(iway).updating <= '0';
					cache_infos_next(iset)(iway).valid <= '0';
				end loop;
			end loop;
		else
			if reorder_valid = '1' then
				for i in WAY_COUNT-1 downto 1 loop
					if i <= ilast_used_way then
						cache_infos_next(iset)(i) <= cache_infos(iset)(i - 1);
					end if;
				end loop;
				cache_infos_next(iset)(0) <= cache_infos(iset)(ilast_used_way);
				cache_infos_next(iset)(0).tag <= reorder_tag;
				cache_infos_next(iset)(0).valid <= '1';
			end if;
		end if;
	end process;
	
	
	-- instantiate a block ram
	-- this should be changed if used with a non xilinx device
	
	xpm_memory_spram_inst : xpm_memory_spram
	generic map (
	   ADDR_WIDTH_A => BRAM_ADDRESS_WIDTH,
	   AUTO_SLEEP_TIME => 0,
	   BYTE_WRITE_WIDTH_A => 8,
	   CASCADE_HEIGHT => 0,
	   ECC_MODE => "no_ecc",
	   MEMORY_INIT_FILE => "none",
	   MEMORY_INIT_PARAM => "0",
	   MEMORY_OPTIMIZATION => "true",
	   MEMORY_PRIMITIVE => "auto",
	   MEMORY_SIZE => BRAM_MEMORY_SIZE_BYTE*8,
	   MESSAGE_CONTROL => 0,
	   READ_DATA_WIDTH_A => 32,
	   READ_LATENCY_A => 1,
	   READ_RESET_VALUE_A => "0",
	   RST_MODE_A => "SYNC",
	   SIM_ASSERT_CHK => 0,
	   USE_MEM_INIT => 0,
	   USE_MEM_INIT_MMI => 0,
	   WAKEUP_TIME => "disable_sleep",
	   WRITE_DATA_WIDTH_A => 32,
	   WRITE_MODE_A => "write_first",
	   WRITE_PROTECT => 1
	)
	port map (
		douta => mem_douta,
		addra => mem_addra,
		clka => clock,
		dina => mem_dina,
		ena => mem_ena,
		rsta => '0',
		wea => mem_wea,
		injectdbiterra => '0',
		injectsbiterra => '0',
		regcea => '1',
		sleep => '0'

	);

end cache_memory_behavioral;
