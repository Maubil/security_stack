vlib work
vlog ../rtl/*.v
vlog *.v
vsim -novopt test_bench
add wave -format Literal -radix hexadecimal sim:/test_bench/*
run 3us
wave zoomfull