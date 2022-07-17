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

entity xdma_test is
	port (
		PCIE_RX0_P : in std_logic;
		PCIE_RX0_N : in std_logic;
		
		PCIE_TX0_P : out std_logic;
		PCIE_TX0_N : out std_logic;
	
		sys_rst_n : in std_logic;
	
		PCIE_CLK_QO_P : in std_logic;
		PCIE_CLK_QO_N : in std_logic;
	
		sys_clk_p : in std_logic;
		sys_clk_n : in std_logic;
	
		CPU_RESET : in std_logic;
			
		-- ddr3
		ddr3_dq : inout std_logic_vector(63 downto 0);
		ddr3_addr : out std_logic_vector(13 downto 0);
		ddr3_dm : out std_logic_vector(7 downto 0);
		ddr3_dqs_p : inout std_logic_vector(7 downto 0);
		ddr3_dqs_n : inout std_logic_vector(7 downto 0);
		ddr3_ba : out std_logic_vector(2 downto 0);
		ddr3_ras_n : out std_logic;
		ddr3_cas_n : out std_logic;
		ddr3_we_n : out std_logic;
		ddr3_reset_n : out std_logic;
		ddr3_ck_p : out std_logic_vector(0 downto 0);
		ddr3_ck_n : out std_logic_vector(0 downto 0);
		ddr3_cke : out std_logic_vector(0 downto 0);
		ddr3_cs_n : out std_logic_vector(0 downto 0);
		ddr3_odt : out std_logic_vector(0 downto 0);
	
		led : out std_logic_vector(7 downto 0)
	);
end xdma_test;

architecture xdma_test_behavioral of xdma_test is

component design_1 is
  port (
	PCIE_PERST_LS : in STD_LOGIC;
	LEDS : out STD_LOGIC_VECTOR ( 7 downto 0 );
	PCIE_REFCLK_clk_p : in STD_LOGIC;
	PCIE_REFCLK_clk_n : in STD_LOGIC;
	pcie_mgt_0_rxn : in STD_LOGIC;
	pcie_mgt_0_rxp : in STD_LOGIC;
	pcie_mgt_0_txn : out STD_LOGIC;
	pcie_mgt_0_txp : out STD_LOGIC;
	DDR3_0_dq : inout STD_LOGIC_VECTOR ( 63 downto 0 );
	DDR3_0_dqs_p : inout STD_LOGIC_VECTOR ( 7 downto 0 );
	DDR3_0_dqs_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
	DDR3_0_addr : out STD_LOGIC_VECTOR ( 13 downto 0 );
	DDR3_0_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
	DDR3_0_ras_n : out STD_LOGIC;
	DDR3_0_cas_n : out STD_LOGIC;
	DDR3_0_we_n : out STD_LOGIC;
	DDR3_0_reset_n : out STD_LOGIC;
	DDR3_0_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
	DDR3_0_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
	DDR3_0_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
	DDR3_0_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
	DDR3_0_dm : out STD_LOGIC_VECTOR ( 7 downto 0 );
	DDR3_0_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
    SYS_CLK_clk_p : in STD_LOGIC;
    SYS_CLK_clk_n : in STD_LOGIC;
    debug : out STD_LOGIC_VECTOR ( 0 to 0 );
    debug_2 : out STD_LOGIC_VECTOR ( 0 to 0 );
	debug_3 : out std_logic
  );
  end component design_1;
	
	signal LEDS : std_logic_vector(7 downto 0);
	
begin
	
	led <= LEDS;
	--LEDS(7 downto 3) <= "11111";
	
design_1_i: component design_1
	 port map (
	  LEDS => LEDS,
	  PCIE_PERST_LS => sys_rst_n,
	  PCIE_REFCLK_clk_n => PCIE_CLK_QO_N,
	  PCIE_REFCLK_clk_p => PCIE_CLK_QO_P,
	  pcie_mgt_0_rxn => PCIE_RX0_N,
	  pcie_mgt_0_rxp => PCIE_RX0_P,
	  pcie_mgt_0_txn => PCIE_TX0_N,
	  pcie_mgt_0_txp => PCIE_TX0_P,
	
		DDR3_0_dq => ddr3_dq,
		DDR3_0_dqs_p => ddr3_dqs_p,
		DDR3_0_dqs_n => ddr3_dqs_n,
		DDR3_0_addr => ddr3_addr,
		DDR3_0_ba => ddr3_ba,
		DDR3_0_ras_n => ddr3_ras_n,
		DDR3_0_cas_n => ddr3_cas_n,
		DDR3_0_we_n => ddr3_we_n,
		DDR3_0_reset_n => ddr3_reset_n,
		DDR3_0_ck_p => ddr3_ck_p,
		DDR3_0_ck_n => ddr3_ck_n,
		DDR3_0_cke => ddr3_cke,
		DDR3_0_cs_n => ddr3_cs_n,
		DDR3_0_dm => ddr3_dm,
		DDR3_0_odt => ddr3_odt,
	  SYS_CLK_clk_n => sys_clk_n,
	  SYS_CLK_clk_p => sys_clk_p--,
	--debug(0) => LEDS(0),
	--debug_2(0) => LEDS(1),
	--debug_3 => LEDS(2)
	);
end xdma_test_behavioral;
