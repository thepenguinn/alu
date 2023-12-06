module testbench();

    reg ain, bin, rst, reclk, feclk;
    reg [2:0] op;
    wire aluout, regout;

    alu billie (
        .ain(ain),
        .bin(bin),
        .op(op),
        .rst(rst),
        .reclk(reclk),
        .feclk(feclk),
        .aluout(aluout),
        .regout(regout)
    );

    initial begin

        reclk = 1'b0;
        feclk = 1'b0;
        rst = 1'b0;

        op = 3'b011;
        ain = 1'b1;
        bin = 1'b1;

        #30;
        rst = 1'b1;
        reclk = 1'b1;
        #100;
        reclk = 1'b0;
        #100;

        feclk = 1'b1;
        #100;
        feclk = 1'b0;
        #100;
        rst = 1'b0;

        #100;
        reclk = 1'b1;
        #100;
        reclk = 1'b0;
        #100;

        feclk = 1'b1;
        #100;
        feclk = 1'b0;
        #100;

        #1000 $display ("%b %b", aluout, regout);

    end

endmodule
