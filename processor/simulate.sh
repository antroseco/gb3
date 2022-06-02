#!/bin/sh
cd sail-core/verilog

VERILOG_FILES=`ls -l *.v | awk '{ print "-l "$9 }'`

iverilog -s top -D SIMULATION_MODE=1 -W all $VERILOG_FILES ../../toplevel.v
vvp a.out -fst
rm a.out

if ! pgrep gtkwave >/dev/null; then
	gtkwave dump.fst &
fi
