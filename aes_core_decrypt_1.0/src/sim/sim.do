# ModelSim simulations script

vlib work

#################
#### Compile ####
#################

vlog ../rtl/verilog/aes_cipher_top.v
vlog ../rtl/verilog/aes_inv_cipher_top.v
vlog ../rtl/verilog/aes_inv_sbox.v
vlog ../rtl/verilog/aes_key_expand_128.v
vlog ../rtl/verilog/aes_rcon.v
vlog ../rtl/verilog/aes_sbox.v
vlog ../bench/verilog/test_bench_top.v

##########################
#### Start simulation ####
##########################

# simulating only with 12 input bits and counter only 4 bits
vsim test

###################
#### Add waves ####
###################

add wave -position end -radix hex -label "clk" sim:/test/clk
add wave -position end -radix hex -label "rst" sim:/test/rst
add wave -position end -radix hex -label "key" sim:/test/key

# kld, ld, done and done2 are a little bit mixed up in the testbench
# following will show the righful signals at the right place

add wave -divider "Encryption"

# key loading
add wave -position end -radix hex -label "ld" sim:/test/kld
# encryption done
add wave -position end -radix hex -label "done" sim:/test/done
add wave -position end -radix hex -label "text_in" sim:/test/text_in
add wave -position end -radix hex -label "text_out" sim:/test/text_out

add wave -divider "Decryption"

# key loading
add wave -position end -radix hex -label "kld" sim:/test/kld
# load when encryption finished
add wave -position end -radix hex -label "ld" sim:/test/done
# decryption done signal
add wave -position end -radix hex -label "done" sim:/test/done2
# decryption input is encryption output
add wave -position end -radix hex -label "text_in" sim:/test/text_out
# decryption outpout should be encryption input
add wave -position end -radix hex -label "text_out" sim:/test/text_out2

#######################
#### Force signals ####
#######################





##############
#### Run! ####
##############

run 80 us
