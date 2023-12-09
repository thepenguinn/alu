#include <stdio.h>

#define FILE_NAME_TB  "alutester_tb_file.v"
#define FILE_NAME_ALU "alu_redesign.v"
#define FILE_NAME_VVP "alutester_vvp_file"

#define XTOSTR(x)         #x
#define TOSTR(x)   XTOSTR(x)
#define TOTAL_EDGE_CYCLES 36

#define BITWIDTH_CLK       1
#define BITWIDTH_ALUOUT   17
#define BITWIDTH_INA      16
#define BITWIDTH_INB      16
#define BITWIDTH_OP        3

struct CycleOutput;
struct CycleEvent;

struct CycleOutput {

    char clk[BITWIDTH_CLK];
    char aluout[BITWIDTH_ALUOUT];

};

struct CycleEvent {

    char *op;
    char *ina;
    char *inb;
    int clkcycle;
    struct CycleOutput *out;

};

int sim_run_alu(struct CycleEvent *cycle, int outsize);
