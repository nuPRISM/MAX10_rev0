#
# Copyright (c) 2016 Intel Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider C2C
add wave -noupdate /sim_top/tb/test_sys_inst/conduit_remap_0_input_conduit_input
add wave -noupdate /sim_top/tb/test_sys_inst/conduit_remap_0_output_conduit_output
add wave -noupdate -divider C2I
add wave -noupdate /sim_top/tb/test_sys_inst/conduit_to_interrupt_0_input_conduit_input
add wave -noupdate /sim_top/tb/test_sys_inst/conduit_to_interrupt_0_output_interrupt_irq
add wave -noupdate -divider C2R
add wave -noupdate /sim_top/tb/test_sys_inst/conduit_to_reset_0_input_conduit_input
add wave -noupdate /sim_top/tb/test_sys_inst/conduit_to_reset_0_output_reset_reset
add wave -noupdate -divider I2C
add wave -noupdate /sim_top/tb/test_sys_inst/interrupt_to_conduit_0_input_interrupt_irq
add wave -noupdate /sim_top/tb/test_sys_inst/interrupt_to_conduit_0_output_conduit_output
add wave -noupdate -divider R2C
add wave -noupdate /sim_top/tb/test_sys_inst/reset_to_conduit_0_input_reset_reset
add wave -noupdate /sim_top/tb/test_sys_inst/reset_to_conduit_0_output_conduit_output
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 350
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {4441500 ps}
