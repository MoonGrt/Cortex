#------------------------------------------#
# Design Constraints
#------------------------------------------#

# Clock network
set clk_input clk
create_clock [get_ports $clk_input] -name clk -period 25
puts "\[INFO\]: Creating clock {clk} for port $clk_input with period: 25"

# Clock non-idealities
set_propagated_clock [get_clocks {clk}]
set_clock_uncertainty 0.12 [get_clocks {clk}]
puts "\[INFO\]: Setting clock uncertainty to: 0.12"

# Maximum transition time for the design nets
set_max_transition 0.75 [current_design]
puts "\[INFO\]: Setting maximum transition to: 0.75"

# Maximum fanout
set_max_fanout 16 [current_design]
puts "\[INFO\]: Setting maximum fanout to: 16"

# Timing paths delays derate
set_timing_derate -early [expr {1-0.07}]
set_timing_derate -late [expr {1+0.07}]
puts "\[INFO\]: Setting timing derate to: [expr {0.07 * 100}] %"

#------------------------------------------#
# Retrieved Constraints then modified
#------------------------------------------#


