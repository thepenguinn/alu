# make file

default: alu run

run: alu
	vvp alu

alu: alu.v testbench.v
	iverilog -o alu -g2012 testbench.v alu.v

.PHONY: default run
