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

module d_latch(input logic clk, data,
    output logic q, qbar);

    wire set, reset;
    wire notdata, notclk;

    sr_latch srl (
        .set(set),
        .reset(reset),
        .q(q),
        .qbar(qbar)
    );

    nor #3 (notdata, data, data);
    nor #3 (notclk, clk, clk);
    nor #3 (set, notclk, notdata);
    nor #3 (reset, notclk, data);

endmodule

module ms_flipflop(input logic eclk, ieclk, data,
    output logic q, qbar);

    wire mout;

    d_latch master (
        .clk(eclk),
        .data(data),
        .q(mout)
    );

    d_latch slave (
        .clk(ieclk),
        .data(mout),
        .q(q),
        .qbar(qbar)
    );

endmodule

module counter(input logic clk, reset,
    output logic [3:0] count);



endmodule


module testbench;

    initial begin

        $finish;
    end

endmodule
