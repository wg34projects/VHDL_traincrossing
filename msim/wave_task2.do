onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -divider -height 30 "CLK, RESET"
add wave -noupdate -height 30 -format Logic /tb_train_crossing/clk_i
add wave -noupdate -height 30 -format Logic /tb_train_crossing/reset_i

add wave -divider -height 30 "ENTITY RTL"
add wave -noupdate -height 30 -format Logic /tb_train_crossing/train_in_i
add wave -noupdate -height 30 -format Logic /tb_train_crossing/train_out_i
add wave -noupdate -height 30 -format Logic /tb_train_crossing/engine_open_o
add wave -noupdate -height 30 -format Logic /tb_train_crossing/engine_close_o
add wave -noupdate -height 30 -format Logic /tb_train_crossing/light_o
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_train_crossing/presentstate_s
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_train_crossing/nextstate_s

add wave -divider -height 30 "ENTITY SIM"
# add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/gate_open_i
# add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/gate_close_i
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/gate_state_s
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/gate_state_o
add wave -noupdate -height 30 -format Logic /tb_train_crossing/track_blocked_o
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/timer_run_s
# add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/timer_measure_s

add wave -divider -height 30 "TIMESTAMPS"
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/p_gate_check/timer_start_1_v
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/p_gate_check/timer_start_2_v
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/p_gate_check/timer_break_1_v
add wave -noupdate -height 30 -format Logic /tb_train_crossing/i_gate_simulation/p_gate_check/timer_break_2_v

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {0 ps}
WaveRestoreZoom {0 ps} {1 ns}
configure wave -namecolwidth 250
configure wave -valuecolwidth 10
configure wave -signalnamewidth 0
configure wave -justifyvalue left

