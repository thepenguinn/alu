# make file

run: alu
	vvp alu

alu: alu.v testbench.v
	iverilog -o alu -g2012 testbench.v alu.v

.PHONY: run
