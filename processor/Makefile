DESIGN	= sail

sail-nextpnr:
	cp programs/data.hex verilog/
	cp programs/program.hex verilog/
	yosys $(DESIGN).ys
	nextpnr-ice40 --up5k --package uwg30 --json $(DESIGN).json --pcf pcf/$(DESIGN).pcf --asc $(DESIGN).asc
	icetime -p pcf/sail.pcf -P uwg30 -d up5k -t sail.asc
	icepack $(DESIGN).asc $(DESIGN).bin

# you need (locally) to put the gb3 server in ~/.ssh/config, something like:
#
# Host gb3
# 	User <crsid>
# 	HostName cpu0.f-of-e.org
#
# you also need to put make.sh at ~/make.sh on the server,
# and the gb3 repo at ~/gb3

remote:
	git checkout -b remote-push
	git commit -am "Make" || true
	git push -f gb3:gb3
	((git log --oneline -1 | grep -q "Make") && git reset HEAD~) || true
	git checkout -
	git branch -D remote-push
	ssh gb3 sh make.sh > compilation_output 2>&1
	./process_yosys.sh compilation_output
	scp gb3:gb3/processor/sail.bin .

clean:
	rm -f *.json *.blif *.asc *.bin

install:
	iceprog -S sail.bin

remote-pdf:
	ssh gb3 'cd gb3/processor/ && \
	yosys -p "read_verilog verilog/alu.v; proc; opt; fsm; opt; show -format pdf -prefix alu -colors 33 -width -stretch"'
	scp gb3:gb3/processor/alu.pdf .
	ssh gb3 rm gb3/processor/alu.pdf
