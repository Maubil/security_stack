#---------------------------------------------------------------------
# Project name         : counter
# Description          : this is the test for the two modules converting 
# an array of bus into a single bus.
# each cycle the next value in the bus array is taken.
#
# File name            : counter.do
#
# Design Engineer      : maurice billmann
# Quality Engineer     : maurice billmann
# Version              : 1.0
# Last modification    : 2018-12-30
#
# ModelSim simulations script
#---------------------------------------------------------------------

transcript off
# ------------------------------------------------------------------- #
# Directories location
# ------------------------------------------------------------------- #

set source_dir rtl
set tb_dir     bench
set work_dir   sim/modelsim_lib

# ------------------------------------------------------------------- #
# Maping destination directory for core of model
# ------------------------------------------------------------------- #

vlib $work_dir
vmap SHA_LIB $work_dir
transcript on


# ------------------------------------------------------------------- #
# Compiling components of core
# ------------------------------------------------------------------- #

transcript off
vlog -work SHA_LIB +incdir+$source_dir $source_dir/counter.v


# ------------------------------------------------------------------- #
# Compiling Test Bench
# ------------------------------------------------------------------- #

vlog  -work SHA_LIB $tb_dir/test_counter.v

transcript on


# ------------------------------------------------------------------- #
# Loading the Test Bench
# ------------------------------------------------------------------- #

transcript off
vsim +nowarnTFMPC +nowarnTSCALE -t ns -lib SHA_LIB test_counter

transcript on


transcript on

# ------------------------------------------------------------------- #
# Add waves
# ------------------------------------------------------------------- #

add wave -position end -radix hex -label "clk" sim:/test_counter/clk
add wave -position end -radix hex -label "reset" sim:/test_counter/rst
add wave -position end -radix hex -label "data_block" sim:/test_counter/data_block_i
add wave -position end -radix hex -label "trigger" sim:/test_counter/trigger_i
add wave -position end -radix hex -label "counter" sim:/test_counter/counter_val_o
add wave -position end -radix hex -label "done" sim:/test_counter/done_o
add wave -position end -radix hex -label "cyclic_out" sim:/test_counter/cyclic_out

# ------------------------------------------------------------------- #
# Force signals
# ------------------------------------------------------------------- #


# ------------------------------------------------------------------- #
# Run!
# ------------------------------------------------------------------- #
run 1ms
