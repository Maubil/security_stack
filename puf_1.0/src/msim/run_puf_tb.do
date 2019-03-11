# ModelSim simulations script

vlib work

#################
#### Compile ####
#################

vcom ../hdl/comparator.vhd
vcom ../hdl/counter.vhd
vcom ../hdl/mux.vhd
vcom ../hdl/puf.vhd
vcom ../hdl/ring_oscillator_sim.vhd

##########################
#### Start simulation ####
##########################

# simulating only with 12 input bits and counter only 4 bits
vsim puf -GINPUT_WIDTH=12 -GCOUNTER_SIZE=8 -GCNTR_OVERFLOW=15

###################
#### Add waves ####
###################

add wave -divider "Top Layer"
add wave -position end -radix hex -label "rstn" sim:/puf/rstn
add wave -position end -radix hex -label "ena" sim:/puf/ena
add wave -position end -radix hex -label "done" sim:/puf/done
add wave -position end -radix hex -label "challenge_input" sim:/puf/challenge_input
add wave -position end -radix bin -label "response_output" sim:/puf/response_output


add wave -position end  sim:/puf/U1_GEN_COUNTER(0)/U1_COUNTER/*


#######################
#### Force signals ####
#######################

# le premier bit doit basculer plus rapidement que le second bit

force -deposit sim:/puf/clk 1 0 ns, 0 10 ns -r 20 ns
force -deposit sim:/puf/challenge_input 16#FFF
force -deposit sim:/puf/rstn 0 0, 1 20 ns
force -deposit sim:/puf/ena 0 0 ns, 1 100 ns, 0 200 ns

force -freeze sim:/puf/osc_output 16#001 0 ns, 16#000 20 ns, 16#001 40 ns, 16#000 60 ns -r 80 ns

##############
#### Run! ####
##############

run 5 us
