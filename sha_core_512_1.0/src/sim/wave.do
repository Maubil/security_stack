add wave -divider "Top Layer"
add wave -position end -radix hex -label "clk" sim:/test_sha/clk
add wave -position end -radix hex -label "rst" sim:/test_sha/rst
add wave -position end -radix hex -label "text_i" sim:/test_sha/text_i
add wave -position end -radix hex -label "text_o" sim:/test_sha/text_o
add wave -position end -radix bin -label "cmd_i" sim:/test_sha/cmd_i
add wave -position end -radix bin -label "cmd_w_i" sim:/test_sha/cmd_w_i
add wave -position end -radix bin -label "cmd_o" sim:/test_sha/cmd_o
