# set_property DUMPFILE wave.vcd [current_simulation]
# log_saif [get_objects -r *]


# ---- Export ----
open_run impl_1
file mkdir work/sim
write_verilog -force -mode timesim work/sim/uart_timesim.v
write_sdf     -force               work/sim/uart_timesim.sdf

