#!/bin/sh
cd sail-core/verilog

VERILOG_FILES=`ls -l *.v | awk '{ print "-l "$9 }'`

iverilog -s top -D SIMULATION_MODE=1 $VERILOG_FILES ../../toplevel.v
vvp a.out -fst

if ! pgrep gtkwave >/dev/null; then
	gtkwave processor.fst
fi
