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

package mips_utils is

	type register_array_t is array(natural range 31 downto 0) of std_logic_vector(31 downto 0);
	
	type memory_port_t is record
		enable : STD_LOGIC;
		write_enable : STD_LOGIC_VECTOR(3 DOWNTO 0);
		address : STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_in : STD_LOGIC_VECTOR(31 DOWNTO 0);
		data_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
	end record;
	
	-- coprocessor 0 register numbers
	constant COP0_REGISTER_INDEX : NATURAL := 0;	-- Index into the TLB array
	constant COP0_REGISTER_INDEX_SEL : NATURAL := 0;
	constant COP0_REGISTER_RANDOM : NATURAL := 1;	-- Randomly generated index into the TLB array
	constant COP0_REGISTER_RANDOM_SEL : NATURAL := 0;
	constant COP0_REGISTER_ENTRYLO0 : NATURAL := 2;	-- Low-order portion of the TLB entry for even-numbered virtual pages
	constant COP0_REGISTER_ENTRYLO0_SEL : NATURAL := 0;
	constant COP0_REGISTER_ENTRYLO1 : NATURAL := 3;	-- Low-order portion of the TLB entry for odd-numbered virtual pages 
	constant COP0_REGISTER_ENTRYLO1_SEL : NATURAL := 0;
	constant COP0_REGISTER_CONTEXT : NATURAL := 4;	-- Pointer to page table entry in memory
	constant COP0_REGISTER_CONTEXT_SEL : NATURAL := 0;
	constant COP0_REGISTER_PAGEMASK : NATURAL := 5;	-- Control for variable page size in TLB entries
	constant COP0_REGISTER_PAGEMASK_SEL : NATURAL := 0;
	constant COP0_REGISTER_WIRED : NATURAL := 6;	-- Controls the number of fixed (“wired”) TLB entries
	constant COP0_REGISTER_WIRED_SEL : NATURAL := 0;
	constant COP0_REGISTER_7 : NATURAL := 7;		-- Reserved for future extensions
	constant COP0_REGISTER_7_SEL : NATURAL := 0;
	constant COP0_REGISTER_BADVADDR : NATURAL := 8;	-- Reports the address for the most recent address-related exception
	constant COP0_REGISTER_BADVADDR_SEL : NATURAL := 0;
	constant COP0_REGISTER_COUNT : NATURAL := 9;	-- Processor cycle count
	constant COP0_REGISTER_COUNT_SEL : NATURAL := 0;
	constant COP0_REGISTER_ENTRYHI : NATURAL := 10;	-- High-order portion of the TLB entry
	constant COP0_REGISTER_ENTRYHI_SEL : NATURAL := 0;
	constant COP0_REGISTER_COMPARE : NATURAL := 11;	-- Timer interrupt control 
	constant COP0_REGISTER_COMPARE_SEL : NATURAL := 0;
	constant COP0_REGISTER_STATUS : NATURAL := 12;	-- Processor status and control
	constant COP0_REGISTER_STATUS_SEL : NATURAL := 0;
	constant COP0_REGISTER_CAUSE : NATURAL := 13;	-- Cause of last general exception 
	constant COP0_REGISTER_CAUSE_SEL : NATURAL := 0;
	constant COP0_REGISTER_EPC : NATURAL := 14;		-- Program counter at last exception
	constant COP0_REGISTER_EPC_SEL : NATURAL := 0;
	constant COP0_REGISTER_PRID : NATURAL := 15;	-- Processor identification and revision
	constant COP0_REGISTER_PRID_SEL : NATURAL := 0;
	constant COP0_REGISTER_CONFIG : NATURAL := 16;	-- Configuration register
	constant COP0_REGISTER_CONFIG_SEL : NATURAL := 0;
	constant COP0_REGISTER_CONFIG1 : NATURAL := 16;	-- Configuration register 1 
	constant COP0_REGISTER_CONFIG1_SEL : NATURAL := 1;
	constant COP0_REGISTER_CONFIG2 : NATURAL := 16;	-- Configuration register 2
	constant COP0_REGISTER_CONFIG2_SEL : NATURAL := 2;
	constant COP0_REGISTER_CONFIG3 : NATURAL := 16;	-- Configuration register 3
	constant COP0_REGISTER_CONFIG3_SEL : NATURAL := 3;
	constant COP0_REGISTER_LLADDR : NATURAL := 17;	-- Load linked address
	constant COP0_REGISTER_LLADDR_SEL : NATURAL := 0;
	constant COP0_REGISTER_WATCHLO : NATURAL := 18;	-- Watchpoint address
	constant COP0_REGISTER_WATCHLO_SEL : NATURAL := 0;
	constant COP0_REGISTER_WATCHHI : NATURAL := 19;	-- Watchpoint control
	constant COP0_REGISTER_WATCHHI_SEL : NATURAL := 0;
	constant COP0_REGISTER_20 : NATURAL := 20;		-- XContext in 64-bit implementations
	constant COP0_REGISTER_20_SEL : NATURAL := 0;
	constant COP0_REGISTER_21 : NATURAL := 21;		-- Reserved for future extensions
	constant COP0_REGISTER_21_SEL : NATURAL := 0;
	constant COP0_REGISTER_22 : NATURAL := 22;		-- Available for implementation dependent use
	constant COP0_REGISTER_22_SEL : NATURAL := 0;
	constant COP0_REGISTER_DEBUG : NATURAL := 23;	-- EJTAG Debug register
	constant COP0_REGISTER_DEBUG_SEL : NATURAL := 0;
	constant COP0_REGISTER_DEPC : NATURAL := 24;	-- Program counter at last EJTAG debug exception 
	constant COP0_REGISTER_DEPC_SEL : NATURAL := 0;
	constant COP0_REGISTER_PERFCNT : NATURAL := 25;	-- Performance counter interface
	constant COP0_REGISTER_PERFCNT_SEL : NATURAL := 0;
	constant COP0_REGISTER_ERRCTL : NATURAL := 26;	-- Parity/ECC error control and status
	constant COP0_REGISTER_ERRCTL_SEL : NATURAL := 0;
	constant COP0_REGISTER_CACHERR : NATURAL := 27;	-- Cache parity error control and status 
	constant COP0_REGISTER_CACHERR_SEL : NATURAL := 0;
	constant COP0_REGISTER_TAGLO : NATURAL := 28;	-- Low-order portion of cache tag interface
	constant COP0_REGISTER_TAGLO_SEL : NATURAL := 0;
	constant COP0_REGISTER_DATALO : NATURAL := 28;	-- Low-order portion of cache data interface
	constant COP0_REGISTER_DATALO_SEL : NATURAL := 1;
	constant COP0_REGISTER_TAGHI : NATURAL := 29;	-- High-order portion of cache tag interface
	constant COP0_REGISTER_TAGHI_SEL : NATURAL := 0;
	constant COP0_REGISTER_DATAHI : NATURAL := 29;	-- High-order portion of cache data interface
	constant COP0_REGISTER_DATAHI_SEL : NATURAL := 1;
	constant COP0_REGISTER_ERROREPC : NATURAL := 30;-- Program counter at last error 
	constant COP0_REGISTER_ERROREPC_SEL : NATURAL := 0;
	constant COP0_REGISTER_DESAVE : NATURAL := 31;	-- EJTAG debug exception save register 
	constant COP0_REGISTER_DESAVE_SEL : NATURAL := 0;
	
	constant COP0_EXCCODE_INT : std_logic_vector(4 downto 0) := '0' & x"0";			-- Interrupt
	constant COP0_EXCCODE_MOD : std_logic_vector(4 downto 0) := '0' & x"1";			-- TLB modification exception
	constant COP0_EXCCODE_TLBL : std_logic_vector(4 downto 0) := '0' & x"2";		-- TLB exception (load or instruction fetch)
	constant COP0_EXCCODE_TLBS : std_logic_vector(4 downto 0) := '0' & x"3";		-- TLB exception (store)
	constant COP0_EXCCODE_ADEL : std_logic_vector(4 downto 0) := '0' & x"4";		-- Address error exception (load or instruction fetch)
	constant COP0_EXCCODE_ADES : std_logic_vector(4 downto 0) := '0' & x"5";		-- Address error exception (store)
	constant COP0_EXCCODE_IBE : std_logic_vector(4 downto 0) := '0' & x"6";			-- Bus error exception (instruction fetch)
	constant COP0_EXCCODE_DBE : std_logic_vector(4 downto 0) := '0' & x"7";			-- Bus error exception (data reference: load or store)
	constant COP0_EXCCODE_SYS : std_logic_vector(4 downto 0) := '0' & x"8";			-- Syscall exception
	constant COP0_EXCCODE_BP : std_logic_vector(4 downto 0) := '0' & x"9";			-- Breakpoint exception
	constant COP0_EXCCODE_RI : std_logic_vector(4 downto 0) := '0' & x"A";			-- Reserved instruction exception
	constant COP0_EXCCODE_CPU : std_logic_vector(4 downto 0) := '0' & x"B";			-- Coprocessor Unusable exception
	constant COP0_EXCCODE_OV : std_logic_vector(4 downto 0) := '0' & x"C";			-- Arithmetic Overflow exception
	constant COP0_EXCCODE_TR : std_logic_vector(4 downto 0) := '0' & x"D";			-- Trap exception
	constant COP0_EXCCODE_FPE : std_logic_vector(4 downto 0) := '0' & x"F";			-- Floating point exception
	constant COP0_EXCCODE_C2E : std_logic_vector(4 downto 0) := '1' & x"2";			-- Reserved for precise Coprocessor 2 exceptions
	constant COP0_EXCCODE_MDMX : std_logic_vector(4 downto 0) := '1' & x"6";		-- Reserved for MDMX Unusable Exception in MIPS64 implementations
	constant COP0_EXCCODE_WATCH : std_logic_vector(4 downto 0) := '1' & x"7";		-- Reference to WatchHi/WatchLo address
	constant COP0_EXCCODE_MCHECK : std_logic_vector(4 downto 0) := '1' & x"8";		-- Machine check
	constant COP0_EXCCODE_CACHEERR : std_logic_vector(4 downto 0) := '1' & x"E";	-- Cache error
end package;