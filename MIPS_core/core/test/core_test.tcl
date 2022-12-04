# simulation requires a project so we cannot use non-project mode
create_project -force -part xc7k325tffg900-2 core_test_proj ./project

#set_part "xc7k325tffg900-2"
set_property TARGET_LANGUAGE VHDL [current_project]
set_property BOARD_PART "xilinx.com:kc705:part0:1.6" [current_project]
set_property DEFAULT_LIB work [current_project]

set_property source_mgmt_mode All [current_project]


read_vhdl ../axi_helper.vhd
read_vhdl ../mips_utils.vhd
read_vhdl ../mips_decode.vhd
read_vhdl ../mips_fetch.vhd
read_vhdl ../mips_readmem.vhd
read_vhdl ../mips_readreg.vhd
read_vhdl ../mips_registers.vhd
read_vhdl ../mips_writeback.vhd
read_vhdl ../../alu/mips_alu.vhd
read_vhdl ../mips_core_internal.vhd
read_vhdl ./core_test.vhd
	
# this makes the block design generation fail. I think because you cannot use VHDL2008 modules directly from a block design
set_property file_type {VHDL 2008} [get_files mips_alu.vhd]

source core_test_design.tcl
read_bd ./project/core_test_proj.srcs/sources_1/bd/core_test_design/core_test_design.bd
open_bd_design ./project/core_test_proj.srcs/sources_1/bd/core_test_design/core_test_design.bd
make_wrapper -files [get_files ./project/core_test_proj.srcs/sources_1/bd/core_test_design/core_test_design.bd] -top
read_vhdl ./project/core_test_proj.gen/sources_1/bd/core_test_design/hdl/core_test_design_wrapper.vhd

set_property top core_test_design_wrapper [get_fileset sim_1]

launch_simulation
run -all