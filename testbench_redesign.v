module testbench();

    reg rst;
    wire reclk, feclk;
    wire [3:0] count;
    wire notout;
    reg en;
    wire out;

    reg data;

    wire [15:0] muout;

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

    memoryunit mu (
        .reclk(reclk),
        .sl(count),
        .rst(rst),
        .out(muout),
        .data(data)
    );

    initial begin

        en = 1'b0;
        #1000
        en = 1'b1;


        rst = 1'b1;

        #2999;
        rst = 1'b0;

        data = 1'b0;

    end

    integer j = 0;

    always @(negedge out) begin
        if (j >= 36)
            $finish;

        $display("%b %b %b %t", out, count, muout, $time);

        j++;
    end


endmodule
