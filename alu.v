module full_adder(input logic a, b, cin,
    output logic sum, cout);

    wire anorb, anorcin, bnorcin;
    wire xnor1, xnor2;
    wire xor1;
    wire bxor1nor1, bxor1nor2, bxor2nor1, bxor2nor2;
    wire xor1norcin;

    wire coutnor1, coutor1;

    // sum
    nor #3 (anorb, a, b);
    nor #3 (bxor1nor1, a, anorb);
    nor #3 (bxor1nor2, b, anorb);
    nor #3 (xnor1, bxor1nor1, bxor1nor2);
    nor #3 (xor1, xnor1, xnor1);
    nor #3 (xor1norcin, xor1, cin);
    nor #3 (bxor2nor1, xor1, xor1norcin);
    nor #3 (bxor2nor2, cin, xor1norcin);
    nor #3 (xnor2, bxor2nor1, bxor2nor2);
    nor #3 (sum, xnor2, xnor2);

    // cout
    nor #3 (anorcin, a, cin);
    nor #3 (bnorcin, b, cin);
    nor #3 (coutnor1, anorb, anorcin);
    nor #3 (coutor1, coutnor1, coutnor1);
    nor #3 (cout, coutor1, bnorcin);

endmodule

module xor_gate(input logic a, b,
    output logic y);

    wire anorb, nor1, nor2, xnor1;

    nor #3 (anorb, a, b);
    nor #3 (nor1, anorb, a);
    nor #3 (nor2, anorb, b);
    nor #3 (xnor1, nor1, nor2);
    nor #3 (y, xnor1, xnor1);

endmodule

module and_gate(input logic a, b,
    output logic y);

    wire anot, bnot;

    nor #3 (anot, a, a);
    nor #3 (bnot, b, b);
    nor #3 (y, anot, bnot);

endmodule

module or_gate(input logic a, b,
    output logic y);

    wire anorb;

    nor #3 (anorb, a, b);
    nor #3 (y, anorb, anorb);

endmodule

module not_gate(input logic a,
    output logic y);

    nor #3 (y, a, a);

endmodule

module ring_oscillator(input logic en,
    output logic s1, s2, s3);

    wire s4;
    wire noten, nots3;

    nor (noten, en, en);
    nor (nots3, s3, s3);
    nor (s4, noten, nots3);

    nor #30 (s2, s1, s1);
    nor #30 (s3, s2, s2);
    nor #30 (s1, s4, s4);

endmodule

module edge_detector(input logic clk,
    output logic edgclk);

    wire notclk;
    wire nct, nnct;

    nor #30 (notclk, clk, clk);
    nor     (nct, clk, clk);
    nor     (nnct, notclk, notclk);
    nor     (edgclk, nct, nnct);

endmodule

module sr_latch(input logic set, reset,
    output logic q, qbar);

    nor #3 (q, reset, qbar);
    nor #3 (qbar, set, q);

endmodule

module d_latch(input logic clk, rst, data,
    output logic q, qbar);

    wire set, reset;
    wire notclk, bfreset;
    wire acdata, notacdata, notdata;
    wire norreset;

    sr_latch srl (
        .set(set),
        .reset(reset),
        .q(q),
        .qbar(qbar)
    );

    /*
     * if data, clk and rst are high at the same time
     * the set and reset of the sr latch could get a
     * high at the same time. So we are anding data and
     * notrst
     * */
    nor #3 (notdata, data, data);
    nor #3 (acdata, notdata, rst);

    nor #3 (notacdata, acdata, acdata);
    nor #3 (notclk, clk, clk);
    nor #3 (set, notclk, notacdata);
    nor #3 (bfreset, notclk, acdata);

    /*
     * asynchronosly resetting the sr latch
     * */
    nor #3 (norreset, bfreset, rst);
    nor #3 (reset, norreset, norreset);

endmodule

module ms_flipflop(input logic eclk, ieclk, rst, data,
    output logic q, qbar);

    wire mout;

    d_latch master (
        .clk(eclk),
        .rst(rst),
        .data(data),
        .q(mout)
    );

    d_latch slave (
        .clk(ieclk),
        .rst(rst),
        .data(mout),
        .q(q),
        .qbar(qbar)
    );

endmodule

module counter(input logic eclk, ieclk, rst,
    output logic [3:0] count);

    wire q0, q1, q2, q3;
    wire qb0, qb1, qb2, qb3;
    wire d0, d1, d2, d3;
    wire eclk1, eclk2, eclk3;
    wire ieclk1, ieclk2, ieclk3;

    ms_flipflop msff0 (
        .eclk(eclk),
        .ieclk(ieclk),
        .rst(rst),
        .data(qb0),
        .q(count[0]),
        .qbar(qb0)
    );

    edge_detector ed1 (
        .clk(count[0]),
        .edgclk(eclk1)
    );

    edge_detector ied1 (
        .clk(qb0),
        .edgclk(ieclk1)
    );

    ms_flipflop msff1 (
        .eclk(eclk1),
        .ieclk(ieclk1),
        .rst(rst),
        .data(qb1),
        .q(count[1]),
        .qbar(qb1)
    );

    edge_detector ed2 (
        .clk(count[1]),
        .edgclk(eclk2)
    );

    edge_detector ied2 (
        .clk(qb1),
        .edgclk(ieclk2)
    );

    ms_flipflop msff2 (
        .eclk(eclk2),
        .ieclk(ieclk2),
        .rst(rst),
        .data(qb2),
        .q(count[2]),
        .qbar(qb2)
    );

    edge_detector ed3 (
        .clk(count[2]),
        .edgclk(eclk3)
    );

    edge_detector ied3 (
        .clk(qb2),
        .edgclk(ieclk3)
    );

    ms_flipflop msff3 (
        .eclk(eclk3),
        .ieclk(ieclk3),
        .rst(rst),
        .data(qb3),
        .q(count[3]),
        .qbar(qb3)
    );

endmodule

module testbench;

    reg eclk, ieclk, reset;
    wire [3:0] out;
    integer i = 0;

    counter cc (
        .eclk(eclk),
        .ieclk(ieclk),
        .rst(reset),
        .count(out)
    );

    initial begin

        $display("%4b", out);

        reset = 1'b1;
        #30;
        reset = 1'b0;

        for (i = 0; i < 16; i++) begin
            eclk = 1'b1;
            ieclk = 1'b0;
            #30;
            eclk = 1'b0;
            #60;
            ieclk = 1'b1;
            #30;
            ieclk = 1'b0;
            #60;
            $display("%4b", out);
        end

        // #60 $display("%4b", out);

        $finish;
    end

endmodule
