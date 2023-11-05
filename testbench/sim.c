#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#include "sim.h"

static char TB_above[] =

    "`include \"" FILE_NAME_ALU "\"\n"

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

    "    always @(clkout) begin\n"
    "        if (aluon == 1'b0) begin\n"
    "            if (i < " TOSTR(TOTAL_EDGE_CYCLES) ") begin\n"
    "                i++;\n"
    "                #20 $write(\"%b%b\", clkout, aluout);\n"
    "            end else begin\n"
    "                $finish;\n"
    "            end\n"
    "        end\n"
    "    end\n"

    "endmodule\n"
;

static int run_alu(char *out, int outsize);

static int compile_alu() {

    int pid;

    char *cmd[] = {
        "iverilog",
        "-o",
        FILE_NAME_VVP,
        "-g2012",
        FILE_NAME_TB,
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

        _exit(0);
    } else {
        // parent
        wait(NULL);
    }

    return 0;

}

static int run_alu(char *out, int outsize) {

    int pid;
    int pipe_out[2];

    pipe(pipe_out);

    char *cmd[] = {
        "vvp",
        FILE_NAME_VVP,
        NULL
    };

    pid = fork();

    if (pid == -1) {
        fprintf(stderr, "Forking failed.\n");
        exit(EXIT_FAILURE);
    }

    if (pid == 0) {
        // child

        dup2(pipe_out[1], STDOUT_FILENO);

        execvp(cmd[0], cmd);
    }

    // parent

    read(pipe_out[0], out, outsize - 1);

    wait(NULL);

    return 0;
}

int sim_run_alu(struct CycleEvent *cycle, int outsize) {

    FILE *tb_file;

    tb_file = fopen(FILE_NAME_TB, "w");

    // - 1 because we don't need the last NULL terminator
    fwrite(TB_above, sizeof(char), (sizeof(TB_above) / sizeof(char)) - 1, tb_file);

    fprintf(tb_file, "        aluop = 16'b%s;\n", cycle->op);
    fprintf(tb_file, "        aluina = 16'b%s;\n", cycle->ina);
    fprintf(tb_file, "        aluinb = 16'b%s;\n", cycle->inb);

    fwrite(TB_below, sizeof(char), (sizeof(TB_below) / sizeof(char)) - 1, tb_file);

    fclose(tb_file);

    compile_alu();

    run_alu((char *)(cycle->out), outsize);

    return 0;
}
