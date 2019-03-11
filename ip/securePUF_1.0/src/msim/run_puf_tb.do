# ModelSim simulations script

vlib work
vmap unisim C:/tmp/zybo_test1/zybo_test1.cache/compile_simlib/modelsim/unisim

#################
#### Compile ####
#################

vlog ../hdl/mapping.v
vlog ../hdl/pdl_based_switch.v
vlog ../hdl/pdl_block.v
vlog ../hdl/PDL_PUF.v
vlog ../hdl/puf_intercon_network.v
vlog ../hdl/pufInputNetwork.v
vlog ../hdl/pufOutputNetwork.v
vcom ../hdl/FDC.vhd
vcom ../hdl/LUT1.vhd
vcom ../hdl/LUT6.vhd

##########################
#### Start simulation ####
##########################

vsim mapping

###################
#### Add waves ####
###################

add wave -divider "Top Layer"
add wave -position end -radix hex -label "trigger" sim:/mapping/trigger
add wave -position end -radix hex -label "reset" sim:/mapping/reset
add wave -position end -radix hex -label "challenge" sim:/mapping/challenge
add wave -position end -radix hex -label "pdl_config" sim:/mapping/pdl_config
add wave -position end -radix hex -label "done" sim:/mapping/done
add wave -position end -radix bin -label "raw_response" sim:/mapping/raw_response
add wave -position end -radix bin -label "xor_response" sim:/mapping/xor_response

#######################
#### Force signals ####
#######################

# challenge and control to others => '1'
force -deposit sim:/mapping/challenge 16#ABCDEF00
force -deposit sim:/mapping/pdl_config 16#FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF

# reset after 10 ns and again after 680 ns
force -deposit sim:/mapping/reset 1 0 ns, 0 10 ns, 1 770 ns, 0 780 ns

# trigger signal
force -deposit sim:/mapping/trigger 0 0, 1 40 ns

##############
#### Run! ####
##############

run 2 us