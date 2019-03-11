# ModelSim simulations script

vlib work

#################
#### Compile ####
#################

vlog ../rtl/aes_core.v
vlog ../rtl/aes_decipher_block.v
vlog ../rtl/aes_encipher_block.v
vlog ../rtl/aes_inv_sbox.v
vlog ../rtl/aes_key_mem.v
vlog ../rtl/aes_sbox.v
vlog ../rtl/aes.v
vlog ../tb/tb_aes_core.v

##########################
#### Start simulation ####
##########################

vsim tb_aes_core

###################
#### Add waves ####
###################

add wave -position end -radix hex -label "clk" sim:/tb_aes_core/tb_clk
add wave -position end -radix hex -label "reset" sim:/tb_aes_core/tb_reset_n
add wave -position end -radix hex -label "encdec" sim:/tb_aes_core/tb_encdec
add wave -position end -radix hex -label "init" sim:/tb_aes_core/tb_init
add wave -position end -radix hex -label "next" sim:/tb_aes_core/tb_next
add wave -position end -radix hex -label "ready" sim:/tb_aes_core/tb_ready
add wave -position end -radix hex -label "key" sim:/tb_aes_core/tb_key
add wave -position end -radix hex -label "256bit_key" sim:/tb_aes_core/tb_keylen
add wave -position end -radix hex -label "plaintext" sim:/tb_aes_core/tb_block
add wave -position end -radix hex -label "cipher" sim:/tb_aes_core/tb_result
add wave -position end -radix hex -label "cipher_valid" sim:/tb_aes_core/tb_ready


#######################
#### Force signals ####
#######################

# challenge and control to others => '1'
#force -deposit sim:/cro_puf_top/challenge 16#FFFFFF

##############
#### Run! ####
##############

run 10 us