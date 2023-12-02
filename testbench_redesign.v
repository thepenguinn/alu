module testbench();

    reg eclk, ieclk, rst, data;
    wire q, qbar;

    ms_flipflop billie (
        .eclk(eclk),
        .ieclk(ieclk),
        .data(data),
        .rst(rst),
        .q(q),
        .qbar(qbar)
    );


    initial begin

        eclk = 1'b1;
        ieclk = 1'b1;
        data = 1'b0;
        rst = 1'b1;

        #100;
        eclk = 1'b0;
        #100;
        eclk = 1'b1;

        // #100;
        // ieclk = 1'b1;
        // #100;
        // ieclk = 1'b0;


        $display("%b %b", q, qbar);

    end



endmodule
