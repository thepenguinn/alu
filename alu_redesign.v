module full_adder(input logic a, b, cin,
    output logic sum, cout);

    wire anorb;
    wire xnor1, xnor2;
    wire xnor1nor1, xnor1nor2, xnor2nor1, xnor2nor2;
    wire xnor1norcin;

    // sum
    nor #3 (anorb, a, b);
    nor #3 (xnor1nor1, a, anorb);
    nor #3 (xnor1nor2, b, anorb);
    nor #3 (xnor1, xnor1nor1, xnor1nor2);

    nor #3 (xnor1norcin, xnor1, cin);
    nor #3 (xnor2nor1, xnor1, xnor1norcin);
    nor #3 (xnor2nor2, cin, xnor1norcin);
    nor #3 (sum, xnor2nor1, xnor2nor2);

    // cout
    nor #3 (cout, xnor1norcin, anorb);

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

module nor_gate(input logic a, b,
    output logic y);

    nor #3 (y, a, b);

endmodule

module nand_gate(input logic a, b,
    output logic y);

    wire nota, notb;
    wire andab;

    nor #3 (nota, a, a);
    nor #3 (notb, b, b);
    nor #3 (andab, nota, notb);
    nor #3 (y, andab, andab);

endmodule

module ring_oscillator(input logic en,
    output logic out);

    wire s4, s2, s3;
    wire noten, nots3;

    nor (noten, en, en);
    nor (nots3, s3, s3);
    nor (s4, noten, nots3);

    nor #300 (s2, out, out);
    nor #300 (s3, s2, s2);
    nor #300 (out, s4, s4);

endmodule

module edge_detector(input logic clk,
    output logic eclk);

    wire notclk;

    nor #30 (notclk, clk, clk);
    and #3 (eclk, notclk, clk);

endmodule

module sr_latch(input logic set, reset,
    output logic q, qbar);

    nor #3 (q, qbar, reset);
    nor #3 (qbar, q, set);

endmodule

module d_latch(input logic data, clk,
    output logic q, qbar);

    /*
     * With active low clk
     * */

    wire notdata;
    wire set, reset;

    sr_latch srl (
        .set(set),
        .reset(reset),
        .q(q),
        .qbar(qbar)
    );

    nor #3 (notdata, data, data);

    nor #3 (reset, data, clk);
    nor #3 (set, notdata, clk);

endmodule

module d_latch_sr(input logic data, rst, clk,
    output logic q, qbar);

    /*
     * With active low clk and active low data
     * */

    wire acdata;

    d_latch dl (
        .data(acdata),
        .clk(clk),
        .q(q),
        .qbar(qbar)
    );

    nor #3 (acdata, data, rst);

endmodule

module ms_flipflop(input logic data, rst, eclk, ieclk,
    output logic q, qbar);

    /*
     * With synchronous reset, active low clk, active low data
     * */

    wire sdata;

    d_latch_sr master (
        .data(data),
        .clk(eclk),
        .q(sdata),
        .rst(rst)
    );

    d_latch slave (
        .data(sdata),
        .clk(ieclk),
        .q(q),
        .qbar(qbar)
    );

endmodule

module couter(input logic clk, rst,
    output logic [3:0] count);



endmodule

module nor5input(input logic in0, in1, in2, in3, in4,
    output logic out);

    wire nor01, nor23;
    wire or01, or23;
    wire nor0123;
    wire or0123;

    nor #3 (nor01, in0, in1);
    nor #3 (or01, nor01, nor01);

    nor #3 (nor23, in2, in3);
    nor #3 (or23, nor23, nor23);

    nor #3 (nor0123, or01, or23);
    nor #3 (or0123, nor0123, nor0123);

    nor #3 (out, or0123, in4);

endmodule

module nor4input(input logic in0, in1, in2, in3,
    output logic out);

    wire nor01, nor23;
    wire or01, or23;

    nor #3 (nor01, in0, in1);
    nor #3 (or01, nor01, nor01);

    nor #3 (nor23, in2, in3);
    nor #3 (or23, nor23, nor23);

    nor #3 (out, or01, or23);

endmodule

module mux16(input logic [15:0] in, input logic [3:0] sl,
    output logic out);

    wire sl00, sl01, sl02, sl03; // original select lines
    wire sl10, sl11, sl12, sl13; // inverted select lines

    assign sl00 = sl[0];
    assign sl01 = sl[1];
    assign sl02 = sl[2];
    assign sl03 = sl[3];

    nor #3 (sl10, sl00, sl00);
    nor #3 (sl11, sl01, sl01);
    nor #3 (sl12, sl02, sl02);
    nor #3 (sl13, sl03, sl03);

    wire nor00, nor01, nor02, nor03, nor04, nor05, nor06, nor07,
        nor08, nor09, nor10, nor11, nor12, nor13, nor14, nor15;

    nor5input nor500 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl00), .in4(in[00]), .out(nor00));
    nor5input nor501 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl10), .in4(in[01]), .out(nor01));
    nor5input nor502 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl00), .in4(in[02]), .out(nor02));
    nor5input nor503 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl10), .in4(in[03]), .out(nor03));
    nor5input nor504 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl00), .in4(in[04]), .out(nor04));
    nor5input nor505 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl10), .in4(in[05]), .out(nor05));
    nor5input nor506 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl00), .in4(in[06]), .out(nor06));
    nor5input nor507 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl10), .in4(in[07]), .out(nor07));
    nor5input nor508 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl00), .in4(in[08]), .out(nor08));
    nor5input nor509 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl10), .in4(in[09]), .out(nor09));
    nor5input nor510 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl00), .in4(in[10]), .out(nor10));
    nor5input nor511 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl10), .in4(in[11]), .out(nor11));
    nor5input nor512 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl00), .in4(in[12]), .out(nor12));
    nor5input nor513 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl10), .in4(in[13]), .out(nor13));
    nor5input nor514 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl00), .in4(in[14]), .out(nor14));
    nor5input nor515 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl10), .in4(in[15]), .out(nor15));

    wire fnor0, fnor1, fnor2, fnor3;
    wire for0, for1, for2, for3;

    nor #3 (for0, fnor0, fnor0);
    nor #3 (for1, fnor1, fnor1);
    nor #3 (for2, fnor2, fnor2);
    nor #3 (for3, fnor3, fnor3);

    nor4input nor400 (.in0(nor00), .in1(nor01), .in2(nor02), .in3(nor03), .out(fnor0));
    nor4input nor401 (.in0(nor04), .in1(nor05), .in2(nor06), .in3(nor07), .out(fnor1));
    nor4input nor402 (.in0(nor08), .in1(nor09), .in2(nor10), .in3(nor11), .out(fnor2));
    nor4input nor403 (.in0(nor12), .in1(nor13), .in2(nor14), .in3(nor15), .out(fnor3));

    nor4input nor404 (.in0(for0), .in1(for1), .in2(for2), .in3(for3), .out(out));

endmodule

module demux16(input logic in, input logic [3:0] sl,
    output logic [15:0] out);

    wire sl00, sl01, sl02, sl03; // original select lines
    wire sl10, sl11, sl12, sl13; // inverted select lines

    assign sl00 = sl[0];
    assign sl01 = sl[1];
    assign sl02 = sl[2];
    assign sl03 = sl[3];

    nor #3 (sl10, sl00, sl00);
    nor #3 (sl11, sl01, sl01);
    nor #3 (sl12, sl02, sl02);
    nor #3 (sl13, sl03, sl03);

    wire notin;

    nor #3 (notin, in, in);

    wire nor00, nor01, nor02, nor03, nor04, nor05, nor06, nor07,
        nor08, nor09, nor10, nor11, nor12, nor13, nor14, nor15;

    nor5input nor500 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl00), .in4(notin), .out(out[00]));
    nor5input nor501 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl10), .in4(notin), .out(out[01]));
    nor5input nor502 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl00), .in4(notin), .out(out[02]));
    nor5input nor503 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl10), .in4(notin), .out(out[03]));
    nor5input nor504 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl00), .in4(notin), .out(out[04]));
    nor5input nor505 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl10), .in4(notin), .out(out[05]));
    nor5input nor506 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl00), .in4(notin), .out(out[06]));
    nor5input nor507 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl10), .in4(notin), .out(out[07]));
    nor5input nor508 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl00), .in4(notin), .out(out[08]));
    nor5input nor509 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl10), .in4(notin), .out(out[09]));
    nor5input nor510 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl00), .in4(notin), .out(out[10]));
    nor5input nor511 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl10), .in4(notin), .out(out[11]));
    nor5input nor512 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl00), .in4(notin), .out(out[12]));
    nor5input nor513 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl10), .in4(notin), .out(out[13]));
    nor5input nor514 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl00), .in4(notin), .out(out[14]));
    nor5input nor515 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl10), .in4(notin), .out(out[15]));

endmodule
