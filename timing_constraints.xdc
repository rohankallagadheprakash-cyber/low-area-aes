# Define a clock constraint for the 'clk' input port
# Period: 10.000 ns corresponds to 100 MHz
create_clock -name sys_clk_i -period 10.000 [get_ports clk]

# Change IOSTANDARD to LVCMOS18 (or LVCMOS25 if 1.8V doesn't work)
set_property IOSTANDARD LVCMOS18 [get_ports clk]

