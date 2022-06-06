#!/bin/sh

if [ $# -gt 0 ]; then
	RANGE=$1
else
	RANGE="abe72ec~..HEAD"
fi

process_yosys() { # $1: filename, $2: hash, $3: comment
	lc="$(sed -n 's/.*ICESTORM_LC:[[:space:]]*\([[:digit:]]\+\).*/\1/p' $1)"
	wirelen="$(sed -n 's/.*wirelen *=[[:space:]]*\([[:digit:]]\+\).*/\1/p' $1)"
	path_delay="$(sed -n 's/.*Total path delay:[[:space:]]*\([.[:digit:]]\+ \w\+\).*/\1/p' $1)"
	echo "$2,$lc,$wirelen,$path_delay,$3"
}

mkdir -p outputs
mkdir -p results

commits="$(git log --oneline $RANGE)"
top_hash="$(echo "$commits" | head -n1 | cut -f1 -d' ')"

echo "hash,LC,Wire Length,Timing Cost,Comment" > results.csv

cd processor

i=0
IFS="
"
for commit in $commits; do
	padded_idx="$(echo "$i" | sed 's/^.$/0&/')"

	hash="$(echo $commit | cut -f1 -d' ')"
	msg="$(echo $commit | cut -f2- -d' ')"
	file_sanitised_msg="$(echo "$msg" | sed 's/[^[:alnum:]._]/_/g')"
	csv_sanitised_msg="$(echo "$msg" | tr -d ',')"

	echo "[ $hash ] $msg"

	git checkout $hash >/dev/null 2>&1 || exit 1
	git show $top_hash:processor/Makefile > Makefile
	git show $top_hash:processor/process_yosys.sh > process_yosys.sh
	make remote-scripted --silent
	git reset --hard HEAD

	cp compilation_output.txt ../outputs/${padded_idx}_${hash}_$file_sanitised_msg.txt
	cp results.txt ../results/${padded_idx}_${hash}_$file_sanitised_msg.txt
	process_yosys results.txt $hash $csv_sanitised_msg >> ../results.csv

	i=$(($i+1))
done

cd - >/dev/null
