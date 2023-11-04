#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#include "sim.h"

#define TB_FILE_NAME "alutest_tb_tmp.v"
#define ALU_FILE_NAME "alu.v"

static char TB_above[] =

    "`include \"" ALU_FILE_NAME "\"\n"

    "module testbench;\n"

    "    reg en;\n"
    "    wire clkout;\n"

    "    reg [15:0] aluina, aluinb;\n"
    "    reg [2:0] aluop;\n"
    "    reg aluon;\n"
    "    wire [3:0] alucount;\n"
    "    wire [16:0] aluout;\n"

    "    integer i = 0;\n"


    "    ring_oscillator rosci (\n"
    "        .en(en),\n"
    "        .out(clkout)\n"
    "    );\n"

    "    alu16 alu (\n"
    "        .clk(clkout),\n"
    "        .on(aluon),\n"
    "        .ina(aluina),\n"
    "        .inb(aluinb),\n"
    "        .op(aluop),\n"
    "        .out(aluout),\n"
    "        .count(alucount)\n"
    "    );\n"

    "    initial begin\n"

    "        en = 1'b0;\n"
    "        #900;\n"
    "        en = 1'b1;\n"
;

static char TB_below[] =

    // "        aluina = 16'b0111_0000_0000_0010;\n"
    // "        aluinb = 16'b1000_0000_0000_0011;\n"

    // "        aluop = 3'b000;\n"

    "        aluon = 1'b0;\n"
    "        #100;\n"
    "        aluon = 1'b1;\n"
    "        #100;\n"
    "        aluon = 1'b0;\n"

    "    end\n"

    "    always @(posedge clkout) begin\n"
    "        if (aluon == 1'b0) begin\n"
    "            if (i < 18) begin\n"
    "                i++;\n"
    "                #20 $display(\"%b\", aluout);\n"
    "            end else begin\n"
    "                $finish;\n"
    "            end\n"
    "        end\n"
    "    end\n"

    "endmodule\n"
;

static int compile_alu() {

    int pid;

    char *cmd[] = {
        "iverilog",
        "-o",
        "alu_test_build",
        "-g2012",
        TB_FILE_NAME,
        NULL
    };

    pid = fork();

    if (pid == -1) {
        fprintf(stderr, "Forking failed.\n");
        exit(EXIT_FAILURE);
    }

    if (pid == 0) {
        // child
        execvp(cmd[0], cmd);

        int i = 0;

        while (cmd[i]) {
            printf("%s\n", cmd[i]);
            i++;
        }

        printf("haha, its the child\n");
        // _exit(0);
    } else {
        // parent
        wait(NULL);
        printf("child finished\n");
    }

    return 0;

}

int sim_run_alu(char *op, char *ina, char *inb, char *out) {

    FILE *tb_file;

    tb_file = fopen(TB_FILE_NAME, "w");

    // - 1 because we don't need the last NULL terminator
    fwrite(TB_above, sizeof(char), (sizeof(TB_above) / sizeof(char)) - 1, tb_file);

    fprintf(tb_file, "        aluop = 16'b%s;\n", op);
    fprintf(tb_file, "        aluina = 16'b%s;\n", ina);
    fprintf(tb_file, "        aluinb = 16'b%s;\n", inb);

    fwrite(TB_below, sizeof(char), (sizeof(TB_below) / sizeof(char)) - 1, tb_file);

    fclose(tb_file);

    compile_alu();

    return 0;
}

int testing() {

}
