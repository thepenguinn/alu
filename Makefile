# make file
#
#

redesign: alu_redesign
	vvp alu_redesign

run: alu
	vvp alu

runtest: alutester
	./alutester alu.v

alutester: testbench/alutester.o testbench/sim.o testbench/draw.o
	gcc -o alutester -lncurses testbench/sim.o testbench/alutester.o testbench/draw.o

testbench/alutester.o: testbench/alutester.c testbench/alutester.h
	gcc -o testbench/alutester.o -c testbench/alutester.c

testbench/sim.o: testbench/sim.c testbench/sim.h
	gcc -o testbench/sim.o -c testbench/sim.c

testbench/draw.o: testbench/draw.c testbench/draw.h
	gcc -o testbench/draw.o -c testbench/draw.c

alu_redesign: alu_redesign.v testbench_redesign.v
	iverilog -o alu_redesign -g2012 testbench_redesign.v alu_redesign.v

alu: alu.v testbench.v
	iverilog -o alu -g2012 testbench.v alu.v

clean:
	rm -rf testbench/*.o

.PHONY: run runtest clean
