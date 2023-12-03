module testbench();

    reg rst;
    wire reclk, feclk;
    wire [3:0] count;
    wire notout;
    reg en;
    wire out;

    ring_oscillator ro (
        .en(en),
        .out(out)
    );

    nor #3 (notout, out, out);

    edge_detector ed0 (
        .clk(out),
        .reclk(reclk)
    );

    edge_detector ed1 (
        .clk(notout),
        .reclk(feclk)
    );

    counter cc (
        .reclk(reclk),
        .feclk(feclk),
        .rst(rst),
        .count(count)
    );

    initial begin

        en = 1'b0;
        #1000
        en = 1'b1;


        rst = 1'b1;

        #3000;
        rst = 1'b0;

    end

    integer j = 0;

    always @(negedge out) begin
        if (j >= 26)
            $finish;


        #100;
        $display("%b, %b %t", out, count, $time);

        j++;
    end


endmodule
