set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN DIV-1 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.SPI_OPCODE 8'h6B [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 2.5 [current_design]

set_false_path -from [get_pins {design_1_i/mips_core_0/U0/mips_debugger_i/status_reg_reg[1]/C}] -to [get_pins design_1_i/mips_core_0/U0/mips_debugger_i/interrupt_reg1_reg/D]

set_false_path -from [get_pins {design_1_i/proc_sys_reset_0/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins design_1_i/mips_core_0/U0/mips_debugger_i/interrupt_reg1_reg/R]
set_false_path -from [get_pins {design_1_i/proc_sys_reset_0/U0/ACTIVE_LOW_PR_OUT_DFF[0].FDRE_PER_N/C}] -to [get_pins design_1_i/mips_core_0/U0/mips_debugger_i/interrupt_reg2_reg/D]
