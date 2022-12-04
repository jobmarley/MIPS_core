set_part "xc7k325tffg900-2"
set_property TARGET_LANGUAGE VHDL [current_project]
set_property BOARD_PART "xilinx.com:kc705:part0:1.6" [current_project]
set_property DEFAULT_LIB work [current_project]


add_files {./core_test.vhd
	../mips_core_internal.vhd
	../mips_decode.vhd
	../mips_fetch.vhd
	../mips_readmem.vhd
	../mips_readreg.vhd
	../mips_registers.vhd
	../mips_writeback.vhd
	../mips_utils.vhd}

source core_test_design.tcl