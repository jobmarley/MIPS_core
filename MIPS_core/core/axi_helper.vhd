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

package axi_helper is
	type axi_lite_port_out_t is record
		awaddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
		awvalid : STD_LOGIC;
		awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
		wdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
		wstrb : STD_LOGIC_VECTOR(3 DOWNTO 0);
		wvalid : STD_LOGIC;
		bready : STD_LOGIC;
		araddr : STD_LOGIC_VECTOR(31 DOWNTO 0);
		arvalid : STD_LOGIC;
		arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
		rready : STD_LOGIC;
	end record;
	type axi_lite_port_in_t is record
		awready : STD_LOGIC;
		wready : STD_LOGIC;
		bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
		bvalid : STD_LOGIC;
		arready : STD_LOGIC;
		rdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
		rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
		rvalid : STD_LOGIC;
	end record;
		
	type axi4_port_out_t is record
		awid :  STD_LOGIC_VECTOR ( 3 downto 0 );
		awaddr :  STD_LOGIC_VECTOR ( 31 downto 0 );
		awregion :  STD_LOGIC_VECTOR ( 3 downto 0 );
		awlen :  STD_LOGIC_VECTOR ( 7 downto 0 );
		awsize :  STD_LOGIC_VECTOR ( 2 downto 0 );
		awburst :  STD_LOGIC_VECTOR ( 1 downto 0 );
		awvalid :  STD_LOGIC;
		wdata :  STD_LOGIC_VECTOR ( 31 downto 0 );
		wstrb :  STD_LOGIC_VECTOR ( 3 downto 0 );
		wlast :  STD_LOGIC;
		wvalid :  STD_LOGIC;
		bready :  STD_LOGIC;
		arid :  STD_LOGIC_VECTOR ( 3 downto 0 );
		araddr :  STD_LOGIC_VECTOR ( 31 downto 0 );
		arregion :  STD_LOGIC_VECTOR ( 3 downto 0 );
		arlen :  STD_LOGIC_VECTOR ( 7 downto 0 );
		arsize :  STD_LOGIC_VECTOR ( 2 downto 0 );
		arburst :  STD_LOGIC_VECTOR ( 1 downto 0 );
		arvalid :  STD_LOGIC;
		rready :  STD_LOGIC;
		arcache : STD_LOGIC_VECTOR ( 3 downto 0 );
		arlock : STD_LOGIC;
		arprot : STD_LOGIC_VECTOR ( 2 downto 0 );
		awcache : STD_LOGIC_VECTOR ( 3 downto 0 );
		awlock : STD_LOGIC;
		awprot : STD_LOGIC_VECTOR ( 2 downto 0 );
	end record;
	type axi4_port_in_t is record
		awready :  STD_LOGIC;
		wready :  STD_LOGIC;
		bid :  STD_LOGIC_VECTOR ( 3 downto 0 );
		bresp :  STD_LOGIC_VECTOR ( 1 downto 0 );
		bvalid :  STD_LOGIC;
		arready :  STD_LOGIC;
		rid :  STD_LOGIC_VECTOR ( 3 downto 0 );
		rdata :  STD_LOGIC_VECTOR ( 31 downto 0 );
		rresp :  STD_LOGIC_VECTOR ( 1 downto 0 );
		rlast :  STD_LOGIC;
		rvalid :  STD_LOGIC;
	end record;
	
	constant AXI_RESP_OKAY : std_logic_vector(1 downto 0) := "00";
	constant AXI_RESP_EXOKAY : std_logic_vector(1 downto 0) := "01";
	constant AXI_RESP_SLVERR : std_logic_vector(1 downto 0) := "10";
	constant AXI_RESP_DECERR : std_logic_vector(1 downto 0) := "11";
	
	function AXI_resp_to_string(r : std_logic_vector) return STRING;
	
	type AXI_write_result_t is (AXI_write_result_pending, AXI_write_result_OK, AXI_write_result_ERR);
	
	-- AXI LITE
	procedure AXI_LITE_idle(signal pm : out axi_lite_port_out_t);
	procedure AXI_LITE_write_addr(
		signal pm : out axi_lite_port_out_t;
		signal ps : in axi_lite_port_in_t;
		addr : std_logic_vector;
		variable handshake : out BOOLEAN);
	procedure AXI_LITE_write_data(
		signal pm : out axi_lite_port_out_t;
		signal ps : in axi_lite_port_in_t;
		data : std_logic_vector;
		strb : std_logic_vector;
		variable handshake : out BOOLEAN);
	procedure AXI_LITE_write_errcheck(
		signal pm : out axi_lite_port_out_t;
		signal ps : in axi_lite_port_in_t;
		variable result : out AXI_write_result_t);
	procedure AXI_LITE_read_addr(
		signal po : out axi_lite_port_out_t;
		signal pi : in axi_lite_port_in_t;
		addr : std_logic_vector;
		variable handshake : out BOOLEAN);
	procedure AXI_LITE_read_data(
		signal po : out axi_lite_port_out_t;
		signal pi : in axi_lite_port_in_t;
		signal data : out std_logic_vector;
		signal resp : out std_logic_vector;
		variable handshake : out BOOLEAN);
	
	-- AXI4
	procedure AXI4_idle(signal p : out axi4_port_out_t);
	procedure AXI4_write_addr(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		addr : std_logic_vector;
		burst_type : std_logic_vector;
		burst_size : std_logic_vector;
		burst_len : natural;
		variable result : out BOOLEAN);
	procedure AXI4_write_data(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		data : std_logic_vector;
		strb : std_logic_vector;
		last : std_logic;
		variable result : out BOOLEAN);
	procedure AXI4_read_addr(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		addr : std_logic_vector;
		burst_type : std_logic_vector;
		burst_size : std_logic_vector;
		burst_len : NATURAL;
		variable handshake : out BOOLEAN);
	procedure AXI4_read_data(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		signal data : out std_logic_vector;
		signal resp : out std_logic_vector;
		variable handshake : out BOOLEAN);
	procedure AXI4_write_errcheck(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		variable result : out AXI_write_result_t);
	procedure AXI4_test_read(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		addr : std_logic_vector;
		burst_type : std_logic_vector;
		burst_size : std_logic_vector;
		burst_len : NATURAL;
		timeout : TIME;
		variable result : out std_logic_vector;
		variable resp : out std_logic_vector);

	constant AXI4_BURST_FIXED : std_logic_vector(1 downto 0) := "00";
	constant AXI4_BURST_INCR : std_logic_vector(1 downto 0) := "01";
	constant AXI4_BURST_WRAP : std_logic_vector(1 downto 0) := "10";
	
	constant AXI4_BURST_SIZE_1 : std_logic_vector(2 downto 0) := "000";
	constant AXI4_BURST_SIZE_2 : std_logic_vector(2 downto 0) := "001";
	constant AXI4_BURST_SIZE_4 : std_logic_vector(2 downto 0) := "010";
	constant AXI4_BURST_SIZE_8 : std_logic_vector(2 downto 0) := "011";
	constant AXI4_BURST_SIZE_16 : std_logic_vector(2 downto 0) := "100";
	constant AXI4_BURST_SIZE_32 : std_logic_vector(2 downto 0) := "101";
	constant AXI4_BURST_SIZE_64 : std_logic_vector(2 downto 0) := "110";
	constant AXI4_BURST_SIZE_128 : std_logic_vector(2 downto 0) := "111";
	
	function AXI4_burst_size_decode(size : std_logic_vector) return NATURAL;
end axi_helper;

package body axi_helper is

	procedure AXI_LITE_idle(signal pm : out axi_lite_port_out_t) is
	begin
		pm.awaddr <= (others => '0');
		pm.awvalid <= '0';
		pm.wdata <= (others => '0');
		pm.wstrb <= (others => '0');
		pm.wvalid <= '0';
		pm.awprot <= (others => '0');
		pm.bready <= '0';
		pm.araddr <= (others => '0');
		pm.arvalid <= '0';
		pm.arprot <= (others => '0');
		pm.rready <= '0';
	end procedure;
	procedure AXI_LITE_write_addr(
		signal pm : out axi_lite_port_out_t;
		signal ps : in axi_lite_port_in_t;
		addr : std_logic_vector;
		variable handshake : out BOOLEAN) is
	begin
		pm.awaddr <= addr;
		pm.awvalid <= '1';
		if ps.awready = '1' then
			handshake := TRUE;
		else
			handshake := FALSE;
		end if;
	end procedure;
	
	procedure AXI_LITE_write_data(
		signal pm : out axi_lite_port_out_t;
		signal ps : in axi_lite_port_in_t;
		data : std_logic_vector;
		strb : std_logic_vector;
		variable handshake : out BOOLEAN) is
	begin
		pm.wdata <= data;
		pm.wstrb <= strb;
		pm.wvalid <= '1';
		if ps.wready = '1' then
			handshake := TRUE;
		else
			handshake := FALSE;
		end if;
	end procedure;
	procedure AXI_LITE_write_errcheck(
		signal pm : out axi_lite_port_out_t;
		signal ps : in axi_lite_port_in_t;
		variable result : out AXI_write_result_t) is
	begin
		pm.bready <= '1';
		if ps.bvalid = '1' then
			case (ps.bresp) is
				when AXI_RESP_OKAY =>
					result := AXI_write_result_OK;
				when AXI_RESP_EXOKAY =>
					result := AXI_write_result_OK;
				when AXI_RESP_SLVERR =>
					result := AXI_write_result_ERR;
				when AXI_RESP_DECERR =>
					result := AXI_write_result_ERR;
				when others =>
					result := AXI_write_result_ERR;
			end case;
		else
			result := AXI_write_result_pending;
		end if;
	end procedure;
	
	procedure AXI_LITE_read_addr(
		signal po : out axi_lite_port_out_t;
		signal pi : in axi_lite_port_in_t;
		addr : std_logic_vector;
		variable handshake : out BOOLEAN) is
	begin
		po.araddr <= addr;
		po.arvalid <= '1';
		if pi.arready = '1' then
			handshake := TRUE;
		else
			handshake := FALSE;
		end if;
	end procedure;
	
	procedure AXI_LITE_read_data(
		signal po : out axi_lite_port_out_t;
		signal pi : in axi_lite_port_in_t;
		signal data : out std_logic_vector;
		signal resp : out std_logic_vector;
		variable handshake : out BOOLEAN) is
	begin
		data <= pi.rdata;
		resp <= pi.rresp;
		po.rready <= '1';
		if pi.rvalid = '1' then
			handshake := TRUE;
		else
			handshake := FALSE;
		end if;
	end procedure;
	
	procedure AXI4_idle(signal p : out axi4_port_out_t) is
	begin
		p.awid <= (others => '0');
		p.awaddr <= (others => '0');
		p.awregion <= (others => '0');
		p.awlen <= (others => '0');
		p.awsize <= (others => '0');
		p.awburst <= (others => '0');
		p.awvalid <= '0';
		p.wdata <= (others => '0');
		p.wstrb <= (others => '0');
		p.wlast <= '0';
		p.wvalid <= '0';
		p.bready <= '0';
		p.arid <= (others => '0');
		p.araddr <= (others => '0');
		p.arregion <= (others => '0');
		p.arlen <= (others => '0');
		p.arsize <= (others => '0');
		p.arburst <= (others => '0');
		p.arvalid <= '0';
		p.rready <= '0';
		p.arcache <= (others => '0');
		p.arlock <= '0';
		p.arprot <= (others => '0');
		p.awcache <= (others => '0');
		p.awlock <= '0';
		p.awprot <= (others => '0');
	end procedure;
	procedure AXI4_write_addr( 
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		addr : std_logic_vector;
		burst_type : std_logic_vector;
		burst_size : std_logic_vector;
		burst_len : natural;
		variable result : out BOOLEAN) is
	begin
		pm.awburst <= burst_type;
		pm.awsize <= burst_size;
		pm.awlen <= std_logic_vector(to_unsigned(burst_len, 8) - 1);
		pm.awaddr <= addr;
		pm.awvalid <= '1';
		if ps.awready = '1' then
			result := TRUE;
		else
			result := FALSE;
		end if;
	end procedure;
	
	procedure AXI4_write_data(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		data : std_logic_vector;
		strb : std_logic_vector;
		last : std_logic;
		variable result : out BOOLEAN) is
	begin
		pm.wdata <= data;
		pm.wstrb <= strb;
		pm.wlast <= last;
		pm.wvalid <= '1';
		if ps.wready = '1' then
			result := TRUE;
		else
			result := FALSE;
		end if;
	end procedure;
	
	procedure AXI4_read_addr(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		addr : std_logic_vector;
		burst_type : std_logic_vector;
		burst_size : std_logic_vector;
		burst_len : NATURAL;
		variable handshake : out BOOLEAN) is
	begin
		pm.arburst <= burst_type;
		pm.arsize <= burst_size;
		pm.arlen <= std_logic_vector(to_unsigned(burst_len, 8) - 1);
		pm.araddr <= addr;
		pm.arvalid <= '1';
		if ps.arready = '1' then
			handshake := TRUE;
		else
			handshake := FALSE;
		end if;
	end procedure;
	
	procedure AXI4_read_data(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		signal data : out std_logic_vector;
		signal resp : out std_logic_vector;
		variable handshake : out BOOLEAN) is
	begin
		data <= ps.rdata;
		resp <= ps.rresp;
		pm.rready <= '1';
		if ps.rvalid = '1' then
			handshake := TRUE;
		else
			handshake := FALSE;
		end if;
	end procedure;
		
	procedure AXI4_write_errcheck(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		variable result : out AXI_write_result_t) is
	begin
		pm.bready <= '1';
		if ps.bvalid = '1' then
			case (ps.bresp) is
				when AXI_RESP_OKAY =>
					result := AXI_write_result_OK;
				when AXI_RESP_EXOKAY =>
					result := AXI_write_result_OK;
				when AXI_RESP_SLVERR =>
					result := AXI_write_result_ERR;
				when AXI_RESP_DECERR =>
					result := AXI_write_result_ERR;
				when others => 
					result := AXI_write_result_ERR;
			end case;
		else
			result := AXI_write_result_pending;
		end if;
	end procedure;
	
	function AXI4_burst_size_decode(size : std_logic_vector) return NATURAL is
	begin
		return 2 ** TO_INTEGER(UNSIGNED(size));
	end function;
	
	procedure AXI4_test_read(
		signal pm : out axi4_port_out_t;
		signal ps : in axi4_port_in_t;
		addr : std_logic_vector;
		burst_type : std_logic_vector;
		burst_size : std_logic_vector;
		burst_len : NATURAL;
		timeout : TIME;
		variable result : out std_logic_vector;
		variable resp : out std_logic_vector) is
		
		alias data : std_logic_vector(result'LENGTH-1 downto 0) is result;
		constant data_width : NATURAL := ps.rdata'LENGTH;
		variable ofs : NATURAL := 0;
	begin
		assert AXI4_burst_size_decode(burst_size) <= ps.rdata'LENGTH report "burst size cannot be bigger then bus width" severity FAILURE;
		assert AXI4_burst_size_decode(burst_size) = ps.rdata'LENGTH report "burst size /= bus width is not supported" severity FAILURE;
		assert burst_type = AXI4_BURST_INCR report "only increment burst type supported" severity FAILURE;
		
		pm.araddr <= addr;
		pm.arvalid <= '1';
		pm.rready <= '0';
		pm.arburst <= burst_type;
		pm.arlen <= std_logic_vector(TO_UNSIGNED(burst_len-1, 8));
		pm.arsize <= burst_size;
		pm.arcache <= (others => '0');
		pm.arid <= (others => '0');
		pm.arlock <= '0';
		pm.arprot <= (others => '0');
		pm.arregion <= (others => '0');
		
		wait until ps.arready = '1' for timeout;
		pm.arvalid <= '0';
		assert ps.arready = '1' report "AXI4_test_read arready timed out" severity ERROR;
	
		pm.rready <= '1';
		
		for i in 0 to burst_len-1 loop
			wait until ps.rvalid = '1' for timeout;
			assert ps.rvalid = '1' report "AXI4_test_read rvalid timed out" severity ERROR;
			data(ofs+data_width-1 downto ofs) := ps.rdata;
			ofs := ofs + data_width;
			if i = burst_len-1 then
				assert ps.rlast = '1' report "AXI4_test_read rlast was not set properly" severity ERROR;
				resp := ps.rresp;
			end if;
		end loop;
		
		pm.rready <= '0';
	end procedure;
	
	function AXI_resp_to_string(r : std_logic_vector) return STRING is
		alias rr : std_logic_vector(1 downto 0) is r;
	begin
		case rr is
			when AXI_RESP_OKAY =>
				return "AXI_RESP_OKAY";
			when AXI_RESP_EXOKAY =>
				return "AXI_RESP_EXOKAY";
			when AXI_RESP_DECERR =>
				return "AXI_RESP_DECERR";
			when AXI_RESP_SLVERR =>
				return "AXI_RESP_SLVERR";
			when others =>
				report "AXI_resp_to_string unknown value" severity FAILURE;
		end case;
	end function;
end axi_helper;
