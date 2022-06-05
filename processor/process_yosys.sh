#!/bin/bash
rm -f results.txt
grep -A16 'Info: Device utilisation:' $1 | tee -a results.txt

grep -A999 'Info: Running simulated annealing placer for refinement.' $1 \
	| grep 'Info:   at iteration' | tail -n1 | tee -a results.txt

grep 'Total path delay:' $1 | tee -a results.txt
