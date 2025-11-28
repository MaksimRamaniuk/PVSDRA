create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { clk }];
#create_clock -add -name sys_clk_pin_2 -period 20.00 -waveform {0 4} [get_ports { clk }];