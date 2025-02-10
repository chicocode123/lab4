# Create Project
cd [file dirname [file normalize [info script]]]
create_project lab4 ./ -part xc7z020clg400-1 -force
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]

# Add files
add_files [ glob ./src/design/* ]
add_files -fileset sim_1 [ glob ./src/sim/* ]
add_files -fileset constrs_1 ./src/lab4.xdc

# Add clk_wiz
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list \
	CONFIG.CLK_IN1_BOARD_INTERFACE {sys_clock} \
	CONFIG.CLKOUT2_USED {true} \
	CONFIG.CLKOUT3_USED {true} \
	CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {30.000} \
	CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {150.000} \
	CONFIG.PRIM_IN_FREQ {125.000} \
	CONFIG.CLKIN1_JITTER_PS {80.0} \
	CONFIG.MMCM_DIVCLK_DIVIDE {5} \
	CONFIG.MMCM_CLKFBOUT_MULT_F {42.000} \
	CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
	CONFIG.MMCM_CLKOUT0_DIVIDE_F {10.500} \
	CONFIG.MMCM_CLKOUT1_DIVIDE {35} \
	CONFIG.MMCM_CLKOUT2_DIVIDE {7} \
	CONFIG.NUM_OUT_CLKS {3} \
	CONFIG.CLKOUT1_JITTER {205.508} \
	CONFIG.CLKOUT1_PHASE_ERROR {233.292} \
	CONFIG.CLKOUT2_JITTER {253.016} \
	CONFIG.CLKOUT2_PHASE_ERROR {233.292} \
	CONFIG.CLKOUT3_JITTER {193.443} \
	CONFIG.CLKOUT3_PHASE_ERROR {233.292} \
] [get_ips clk_wiz_0]
