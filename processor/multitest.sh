LC_AVG=0
LC_MIN=999999999
WIRELEN_AVG=0
WIRELEN_MIN=99999999
N=5

for i in 1 2 3 4 5; do
	make remote
	LC="$(sed -n 's/.*ICESTORM_LC:[[:space:]]*\([[:digit:]]*\).*/\1/p' results.txt)"
	if [ $LC -lt $LC_MIN ]; then
		LC_MIN=$LC
	fi
	LC_AVG=$(($LC_AVG + $LC))

	WIRELEN="$(sed -n 's/.*wirelen = \([[:digit:]]*\).*/\1/p' results.txt)"
	if [ $WIRELEN -lt $WIRELEN_MIN ]; then
		WIRELEN_MIN=$WIRELEN
	fi
	WIRELEN_AVG=$((WIRELEN_AVG + $WIRELEN))
done

LC_AVG=$((LC_AVG / $N))
WIRELEN_AVG=$((WIRELEN_AVG / $N))

echo "Minimum LCs: $LC_MIN"
echo "Average LCs: $LC_AVG"
echo "Minimum wirelen: $WIRELEN_MIN"
echo "Average wirelen: $WIRELEN_AVG"
