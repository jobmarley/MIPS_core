#set_property DIFF_TERM false [get_ports SYSCLK_P]

set_property IOSTANDARD LVCMOS25 [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property LOC G25 [get_ports sys_rst_n]
set_false_path -from [get_ports sys_rst_n]