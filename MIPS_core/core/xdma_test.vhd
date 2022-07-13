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
	
		PCIE_PERST_LS : in std_logic;
	
		PCIE_CLK_QO_P : in std_logic;
		PCIE_CLK_QO_N : in std_logic;
	
		SYSCLK_P : in std_logic;
		SYSCLK_N : in std_logic;
	
		CPU_RESET : in std_logic;
			
		DDR3_D0 : inout std_logic;
		DDR3_D1 : inout std_logic;
		DDR3_D2 : inout std_logic;
		DDR3_D3 : inout std_logic;
		DDR3_D4 : inout std_logic;
		DDR3_D5 : inout std_logic;
		DDR3_D6 : inout std_logic;
		DDR3_D7 : inout std_logic;
		DDR3_D8 : inout std_logic;
		DDR3_D9 : inout std_logic;
		DDR3_D10 : inout std_logic;
		DDR3_D11 : inout std_logic;
		DDR3_D12 : inout std_logic;
		DDR3_D13 : inout std_logic;
		DDR3_D14 : inout std_logic;
		DDR3_D15 : inout std_logic;
		DDR3_D16 : inout std_logic;
		DDR3_D17 : inout std_logic;
		DDR3_D18 : inout std_logic;
		DDR3_D19 : inout std_logic;
		DDR3_D20 : inout std_logic;
		DDR3_D21 : inout std_logic;
		DDR3_D22 : inout std_logic;
		DDR3_D23 : inout std_logic;
		DDR3_D24 : inout std_logic;
		DDR3_D25 : inout std_logic;
		DDR3_D26 : inout std_logic;
		DDR3_D27 : inout std_logic;
		DDR3_D28 : inout std_logic;
		DDR3_D29 : inout std_logic;
		DDR3_D30 : inout std_logic;
		DDR3_D31 : inout std_logic;
		DDR3_D32 : inout std_logic;
		DDR3_D33 : inout std_logic;
		DDR3_D34 : inout std_logic;
		DDR3_D35 : inout std_logic;
		DDR3_D36 : inout std_logic;
		DDR3_D37 : inout std_logic;
		DDR3_D38 : inout std_logic;
		DDR3_D39 : inout std_logic;
		DDR3_D40 : inout std_logic;
		DDR3_D41 : inout std_logic;
		DDR3_D42 : inout std_logic;
		DDR3_D43 : inout std_logic;
		DDR3_D44 : inout std_logic;
		DDR3_D45 : inout std_logic;
		DDR3_D46 : inout std_logic;
		DDR3_D47 : inout std_logic;
		DDR3_D48 : inout std_logic;
		DDR3_D49 : inout std_logic;
		DDR3_D50 : inout std_logic;
		DDR3_D51 : inout std_logic;
		DDR3_D52 : inout std_logic;
		DDR3_D53 : inout std_logic;
		DDR3_D54 : inout std_logic;
		DDR3_D55 : inout std_logic;
		DDR3_D56 : inout std_logic;
		DDR3_D57 : inout std_logic;
		DDR3_D58 : inout std_logic;
		DDR3_D59 : inout std_logic;
		DDR3_D60 : inout std_logic;
		DDR3_D61 : inout std_logic;
		DDR3_D62 : inout std_logic;
		DDR3_D63 : inout std_logic;
	
		DDR3_A0 : out std_logic;
		DDR3_A1 : out std_logic;
		DDR3_A2 : out std_logic;
		DDR3_A3 : out std_logic;
		DDR3_A4 : out std_logic;
		DDR3_A5 : out std_logic;
		DDR3_A6 : out std_logic;
		DDR3_A7 : out std_logic;
		DDR3_A8 : out std_logic;
		DDR3_A9 : out std_logic;
		DDR3_A10 : out std_logic;
		DDR3_A11 : out std_logic;
		DDR3_A12 : out std_logic;
		DDR3_A13 : out std_logic;
	
		DDR3_DM0 : out std_logic;
		DDR3_DM1 : out std_logic;
		DDR3_DM2 : out std_logic;
		DDR3_DM3 : out std_logic;
		DDR3_DM4 : out std_logic;
		DDR3_DM5 : out std_logic;
		DDR3_DM6 : out std_logic;
		DDR3_DM7 : out std_logic;
	
		DDR3_DQS0_P : inout std_logic;
		DDR3_DQS1_P : inout std_logic;
		DDR3_DQS2_P : inout std_logic;
		DDR3_DQS3_P : inout std_logic;
		DDR3_DQS4_P : inout std_logic;
		DDR3_DQS5_P : inout std_logic;
		DDR3_DQS6_P : inout std_logic;
		DDR3_DQS7_P : inout std_logic;
	
		DDR3_DQS0_N : inout std_logic;
		DDR3_DQS1_N : inout std_logic;
		DDR3_DQS2_N : inout std_logic;
		DDR3_DQS3_N : inout std_logic;
		DDR3_DQS4_N : inout std_logic;
		DDR3_DQS5_N : inout std_logic;
		DDR3_DQS6_N : inout std_logic;
		DDR3_DQS7_N : inout std_logic;
	
		DDR3_BA0 : out std_logic;
		DDR3_BA1 : out std_logic;
		DDR3_BA2 : out std_logic;
	
		DDR3_RAS_B : out std_logic;
		DDR3_CAS_B : out std_logic;
	
		DDR3_WE_B : out std_logic;
	
		DDR3_RESET_B : out std_logic;
	
		DDR3_CLK0_P : out std_logic;
		DDR3_CLK0_N : out std_logic;
	
		DDR3_CKE0 : out std_logic;
	
		DDR3_S0_B : out std_logic;
	
		DDR3_ODT0 : out std_logic;
	
		GPIO_LED_0_LS : out std_logic;
		GPIO_LED_1_LS : out std_logic;
		GPIO_LED_2_LS : out std_logic;
		GPIO_LED_3_LS : out std_logic;
		GPIO_LED_4_LS : out std_logic;
		GPIO_LED_5_LS : out std_logic;
		GPIO_LED_6_LS : out std_logic;
		GPIO_LED_7_LS : out std_logic
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
	
	GPIO_LED_0_LS <= LEDS(0);
	GPIO_LED_1_LS <= LEDS(1);
	GPIO_LED_2_LS <= LEDS(2);
	GPIO_LED_3_LS <= LEDS(3);
	GPIO_LED_4_LS <= LEDS(4);
	GPIO_LED_5_LS <= LEDS(5);
	GPIO_LED_6_LS <= LEDS(6);
	GPIO_LED_7_LS <= LEDS(7);
	--LEDS(7 downto 3) <= "11111";
	
design_1_i: component design_1
	 port map (
	  LEDS => LEDS,
	  PCIE_PERST_LS => PCIE_PERST_LS,
	  PCIE_REFCLK_clk_n => PCIE_CLK_QO_N,
	  PCIE_REFCLK_clk_p => PCIE_CLK_QO_P,
	  pcie_mgt_0_rxn => PCIE_RX0_N,
	  pcie_mgt_0_rxp => PCIE_RX0_P,
	  pcie_mgt_0_txn => PCIE_TX0_N,
	  pcie_mgt_0_txp => PCIE_TX0_P,
	
		DDR3_0_dq(0) => DDR3_D0,
		DDR3_0_dq(1) => DDR3_D1,
		DDR3_0_dq(2) => DDR3_D2,
		DDR3_0_dq(3) => DDR3_D3,
		DDR3_0_dq(4) => DDR3_D4,
		DDR3_0_dq(5) => DDR3_D5,
		DDR3_0_dq(6) => DDR3_D6,
		DDR3_0_dq(7) => DDR3_D7,
		DDR3_0_dq(8) => DDR3_D8,
		DDR3_0_dq(9) => DDR3_D9,
		DDR3_0_dq(10) => DDR3_D10,
		DDR3_0_dq(11) => DDR3_D11,
		DDR3_0_dq(12) => DDR3_D12,
		DDR3_0_dq(13) => DDR3_D13,
		DDR3_0_dq(14) => DDR3_D14,
		DDR3_0_dq(15) => DDR3_D15,
		DDR3_0_dq(16) => DDR3_D16,
		DDR3_0_dq(17) => DDR3_D17,
		DDR3_0_dq(18) => DDR3_D18,
		DDR3_0_dq(19) => DDR3_D19,
		DDR3_0_dq(20) => DDR3_D20,
		DDR3_0_dq(21) => DDR3_D21,
		DDR3_0_dq(22) => DDR3_D22,
		DDR3_0_dq(23) => DDR3_D23,
		DDR3_0_dq(24) => DDR3_D24,
		DDR3_0_dq(25) => DDR3_D25,
		DDR3_0_dq(26) => DDR3_D26,
		DDR3_0_dq(27) => DDR3_D27,
		DDR3_0_dq(28) => DDR3_D28,
		DDR3_0_dq(29) => DDR3_D29,
		DDR3_0_dq(30) => DDR3_D30,
		DDR3_0_dq(31) => DDR3_D31,
		DDR3_0_dq(32) => DDR3_D32,
		DDR3_0_dq(33) => DDR3_D33,
		DDR3_0_dq(34) => DDR3_D34,
		DDR3_0_dq(35) => DDR3_D35,
		DDR3_0_dq(36) => DDR3_D36,
		DDR3_0_dq(37) => DDR3_D37,
		DDR3_0_dq(38) => DDR3_D38,
		DDR3_0_dq(39) => DDR3_D39,
		DDR3_0_dq(40) => DDR3_D40,
		DDR3_0_dq(41) => DDR3_D41,
		DDR3_0_dq(42) => DDR3_D42,
		DDR3_0_dq(43) => DDR3_D43,
		DDR3_0_dq(44) => DDR3_D44,
		DDR3_0_dq(45) => DDR3_D45,
		DDR3_0_dq(46) => DDR3_D46,
		DDR3_0_dq(47) => DDR3_D47,
		DDR3_0_dq(48) => DDR3_D48,
		DDR3_0_dq(49) => DDR3_D49,
		DDR3_0_dq(50) => DDR3_D50,
		DDR3_0_dq(51) => DDR3_D51,
		DDR3_0_dq(52) => DDR3_D52,
		DDR3_0_dq(53) => DDR3_D53,
		DDR3_0_dq(54) => DDR3_D54,
		DDR3_0_dq(55) => DDR3_D55,
		DDR3_0_dq(56) => DDR3_D56,
		DDR3_0_dq(57) => DDR3_D57,
		DDR3_0_dq(58) => DDR3_D58,
		DDR3_0_dq(59) => DDR3_D59,
		DDR3_0_dq(60) => DDR3_D60,
		DDR3_0_dq(61) => DDR3_D61,
		DDR3_0_dq(62) => DDR3_D62,
		DDR3_0_dq(63) => DDR3_D63,
		DDR3_0_dqs_p(0) => DDR3_DQS0_P,
		DDR3_0_dqs_p(1) => DDR3_DQS1_P,
		DDR3_0_dqs_p(2) => DDR3_DQS2_P,
		DDR3_0_dqs_p(3) => DDR3_DQS3_P,
		DDR3_0_dqs_p(4) => DDR3_DQS4_P,
		DDR3_0_dqs_p(5) => DDR3_DQS5_P,
		DDR3_0_dqs_p(6) => DDR3_DQS6_P,
		DDR3_0_dqs_p(7) => DDR3_DQS7_P,
		DDR3_0_dqs_n(0) => DDR3_DQS0_N,
		DDR3_0_dqs_n(1) => DDR3_DQS1_N,
		DDR3_0_dqs_n(2) => DDR3_DQS2_N,
		DDR3_0_dqs_n(3) => DDR3_DQS3_N,
		DDR3_0_dqs_n(4) => DDR3_DQS4_N,
		DDR3_0_dqs_n(5) => DDR3_DQS5_N,
		DDR3_0_dqs_n(6) => DDR3_DQS6_N,
		DDR3_0_dqs_n(7) => DDR3_DQS7_N,
		DDR3_0_addr(0) => DDR3_A0,
		DDR3_0_addr(1) => DDR3_A1,
		DDR3_0_addr(2) => DDR3_A2,
		DDR3_0_addr(3) => DDR3_A3,
		DDR3_0_addr(4) => DDR3_A4,
		DDR3_0_addr(5) => DDR3_A5,
		DDR3_0_addr(6) => DDR3_A6,
		DDR3_0_addr(7) => DDR3_A7,
		DDR3_0_addr(8) => DDR3_A8,
		DDR3_0_addr(9) => DDR3_A9,
		DDR3_0_addr(10) => DDR3_A10,
		DDR3_0_addr(11) => DDR3_A11,
		DDR3_0_addr(12) => DDR3_A12,
		DDR3_0_addr(13) => DDR3_A13,
		DDR3_0_ba(0) => DDR3_BA0,
		DDR3_0_ba(1) => DDR3_BA1,
		DDR3_0_ba(2) => DDR3_BA2,
		DDR3_0_ras_n => DDR3_RAS_B,
		DDR3_0_cas_n => DDR3_CAS_B,
		DDR3_0_we_n => DDR3_WE_B,
		DDR3_0_reset_n => DDR3_RESET_B,
		DDR3_0_ck_p(0) => DDR3_CLK0_P,
		DDR3_0_ck_n(0) => DDR3_CLK0_N,
		DDR3_0_cke(0) => DDR3_CKE0,
		DDR3_0_cs_n(0) => DDR3_S0_B,
		DDR3_0_dm(0) => DDR3_DM0,
		DDR3_0_dm(1) => DDR3_DM1,
		DDR3_0_dm(2) => DDR3_DM2,
		DDR3_0_dm(3) => DDR3_DM3,
		DDR3_0_dm(4) => DDR3_DM4,
		DDR3_0_dm(5) => DDR3_DM5,
		DDR3_0_dm(6) => DDR3_DM6,
		DDR3_0_dm(7) => DDR3_DM7,
		DDR3_0_odt(0) => DDR3_ODT0,
	  SYS_CLK_clk_n => SYSCLK_N,
	  SYS_CLK_clk_p => SYSCLK_P--,
	--debug(0) => LEDS(0),
	--debug_2(0) => LEDS(1),
	--debug_3 => LEDS(2)
	);
end xdma_test_behavioral;
