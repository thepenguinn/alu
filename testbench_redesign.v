module testbench();

    reg clk, muxlast, on;
    wire reclk, feclk, rstsig;

    init billie (
        .clk(clk),
        .muxlast(muxlast),
        .on(on),
        .reclk(reclk),
        .feclk(feclk),
        .rstsig(rstsig)
    );

    initial begin

        clk = 1'b0;
        muxlast = 1'b1;
        on = 1'b0;

        #50;
        on = 1'b1;
        #50;
        on = 1'b0;

        #300;
        $display("%b", rstsig);

    end

endmodule
