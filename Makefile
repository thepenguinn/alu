# make file
#

run: alu
	vvp alu

runtest: alutester
	./alutester alu.v

alutester: testbench/alutester.o testbench/sim.o
	gcc -o alutester testbench/sim.o testbench/alutester.o

testbench/alutester.o: testbench/alutester.c
	gcc -o testbench/alutester.o -c testbench/alutester.c

testbench/sim.o: testbench/sim.c testbench/sim.h
	gcc -o testbench/sim.o -c testbench/sim.c

alu: alu.v testbench.v
	iverilog -o alu -g2012 testbench.v alu.v

.PHONY: run runtest
