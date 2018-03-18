vsim -t ns -novopt -lib work work.tb_train_crossing
view *
do wave_task2.do
run 130 sec
