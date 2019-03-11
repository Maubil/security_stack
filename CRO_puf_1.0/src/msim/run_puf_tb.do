# ModelSim simulations script

vlib work

#################
#### Compile ####
#################

vcom ../hdl/cdiv.vhd
# we will use a fake RO for the purpose of the simulation as real ROs cannot be simulated
vcom ../hdl/config_RO_sim.vhd
vcom ../hdl/counter32bit.vhd
vcom ../hdl/CRO_PUF.vhd
vcom ../hdl/inverter.vhd
vcom ../hdl/mux16to1.vhd
vcom ../hdl/cro_puf_top_.vhd

##########################
#### Start simulation ####
##########################

# set generic value
vsim cro_puf_top -GOUT_WIDTH=3

###################
#### Add waves ####
###################

add wave -divider "Top Layer"
add wave -position end -radix hex -label "enable" sim:/cro_puf_top/enable
add wave -position end -radix hex -label "rst" sim:/cro_puf_top/rst
add wave -position end -radix hex -label "challenge" sim:/cro_puf_top/challenge
add wave -position end -radix hex -label "control" sim:/cro_puf_top/control
add wave -position end -radix bin -label "response" sim:/cro_puf_top/response

add wave -divider "PUF bit 0"
add wave -position end -radix hex -label "CRO-output(0)" sim:/cro_puf_top/GEN_CRO_PUF1(0)/CRO_PUF1/CRO_output
add wave -position end -radix hex -label "top_count(0)" sim:/cro_puf_top/GEN_CRO_PUF1(0)/CRO_PUF1/top_count
add wave -position end -radix hex -label "bot_count(0)" sim:/cro_puf_top/GEN_CRO_PUF1(0)/CRO_PUF1/bot_count

add wave -divider "PUF bit 1"
add wave -position end -radix hex -label "CRO_output(1)" sim:/cro_puf_top/GEN_CRO_PUF1(1)/CRO_PUF1/CRO_output
add wave -position end -radix hex -label "top_count(1)" sim:/cro_puf_top/GEN_CRO_PUF1(1)/CRO_PUF1/top_count
add wave -position end -radix hex -label "bot_count(1)" sim:/cro_puf_top/GEN_CRO_PUF1(1)/CRO_PUF1/bot_count

add wave -divider "PUF bit 2"
add wave -position end -radix hex -label "CRO_output(2)" sim:/cro_puf_top/GEN_CRO_PUF1(2)/CRO_PUF1/CRO_output
add wave -position end -radix hex -label "top_count(2)" sim:/cro_puf_top/GEN_CRO_PUF1(2)/CRO_PUF1/top_count
add wave -position end -radix hex -label "bot_count(2)" sim:/cro_puf_top/GEN_CRO_PUF1(2)/CRO_PUF1/bot_count

#######################
#### Force signals ####
#######################

# challenge and control to others => '1'
force -deposit sim:/cro_puf_top/challenge 16#FFFFFF
force -deposit sim:/cro_puf_top/control 16#FFF
# reset after 10 ns and again after 680 ns
force -deposit sim:/cro_puf_top/rst 1 0 ns, 0 10 ns, 1 770 ns, 0 780 ns

# enable is only needed for the RO, which is faked in the simulation -> just set the signal to 0 and leave it as is
force -deposit sim:/cro_puf_top/enable 0

# set counter values to overflow in 16 cycles
# reload values after 800 ns (20 ns after reset) and begin again
force -deposit sim:/cro_puf_top/GEN_CRO_PUF1(0)/CRO_PUF1/top_counter/count 16#FFFFFFF0 15 ns, 16#FFFFFFF0 800 ns
force -deposit sim:/cro_puf_top/GEN_CRO_PUF1(1)/CRO_PUF1/top_counter/count 16#FFFFFFF0 15 ns, 16#FFFFFFF0 800 ns
force -deposit sim:/cro_puf_top/GEN_CRO_PUF1(2)/CRO_PUF1/top_counter/count 16#FFFFFFF0 15 ns, 16#FFFFFFF0 800 ns

force -deposit sim:/cro_puf_top/GEN_CRO_PUF1(0)/CRO_PUF1/bot_counter/count 16#FFFFFFF0 15 ns, 16#FFFFFFF0 800 ns
force -deposit sim:/cro_puf_top/GEN_CRO_PUF1(1)/CRO_PUF1/bot_counter/count 16#FFFFFFF0 15 ns, 16#FFFFFFF0 800 ns
force -deposit sim:/cro_puf_top/GEN_CRO_PUF1(2)/CRO_PUF1/bot_counter/count 16#FFFFFFF0 15 ns, 16#FFFFFFF0 800 ns

# LSB and MSB of RO decide who wins
# with this simulation pattern of the RO we whould get a response of 0b101
force -freeze sim:/cro_puf_top/GEN_CRO_PUF1(0)/CRO_PUF1/CRO_output 16#0001 0ns, 16#0000 20ns, 16#0001 40ns, 16#0000 60ns -r 80 ns
force -freeze sim:/cro_puf_top/GEN_CRO_PUF1(1)/CRO_PUF1/CRO_output 16#8000 0ns, 16#0000 20ns, 16#8000 40ns, 16#0000 60ns -r 80 ns
force -freeze sim:/cro_puf_top/GEN_CRO_PUF1(2)/CRO_PUF1/CRO_output 16#0001 0ns, 16#0000 20ns, 16#0001 40ns, 16#0000 60ns -r 80 ns

##############
#### Run! ####
##############

run 2 us