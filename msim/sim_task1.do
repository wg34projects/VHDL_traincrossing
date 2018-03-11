vsim -t ns -novopt -lib work work.tb_train_crossing
view *
do wave_task1.do
run 45 sec
