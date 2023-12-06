module testbench();

    reg sin, rst, reclk, feclk;
    wire [15:0] pout;

    shiftreg billie (
        .sin(sin),
        .rst(rst),
        .reclk(reclk),
        .feclk(feclk),
        .pout(pout)
    );

    integer i;

    initial begin

        for (i = 0; i < 18; i++) begin

            reclk = 1'b1;
            #100;
            reclk = 1'b0;
            #100;

            feclk = 1'b1;
            #100;
            feclk = 1'b0;
            #100;

        end

    end

    initial begin

        sin = 1'b1;

        $display("%b", pout);

        rst = 1'b1;
        #400;
        rst = 1'b0;

        $display("%b", pout);

        #400;
        $display("%b", pout);

        #400;
        $display("%b", pout);


    end





endmodule
