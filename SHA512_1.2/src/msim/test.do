# ModelSim simulations script

vlib work

#################
#### Compile ####
#################

vlog ../rtl/sha512_core.v
vlog ../rtl/sha512_h_constants.v
vlog ../rtl/sha512_k_constants.v
vlog ../rtl/sha512_w_mem.v
vlog ../rtl/sha512.v

vlog ../tb/tb_sha512_core.v

##########################
#### Start simulation ####
##########################

vsim tb_sha512_core

###################
#### Add waves ####
###################

add wave -position end -radix hex -label "clk" sim:/tb_sha512_core/dut/clk
add wave -position end -radix hex -label "reset" sim:/tb_sha512_core/dut/reset_n
add wave -position end -radix hex -label "init" sim:/tb_sha512_core/dut/init
add wave -position end -radix hex -label "next" sim:/tb_sha512_core/dut/next
add wave -position end -radix hex -label "mode" sim:/tb_sha512_core/dut/mode

add wave -position end -radix hex -label "work_factor" sim:/tb_sha512_core/dut/work_factor
add wave -position end -radix hex -label "work_factor_num" sim:/tb_sha512_core/dut/work_factor_num

add wave -position end -radix hex -label "block" sim:/tb_sha512_core/dut/block
add wave -position end -radix hex -label "ready" sim:/tb_sha512_core/dut/ready
add wave -position end -radix hex -label "digest" sim:/tb_sha512_core/dut/digest
add wave -position end -radix hex -label "digest_valid" sim:/tb_sha512_core/dut/digest_valid


#######################
#### Force signals ####
#######################

# challenge and control to others => '1'
#force -deposit sim:/cro_puf_top/challenge 16#FFFFFF

##############
#### Run! ####
##############

run 10 us