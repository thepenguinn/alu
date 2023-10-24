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
    wire nct, nnct;

    nor #200 (notclk, clk, clk);
    nor      (nct, clk, clk);
    nor      (nnct, notclk, notclk);
    nor      (eclk, nct, nnct);

endmodule

module edge_detector_long(input logic clk,
    output logic eclk);

    wire notclk;
    wire nct, nnct;

    nor #1500 (notclk, clk, clk);
    nor       (nct, clk, clk);
    nor       (nnct, notclk, notclk);
    nor       (eclk, nct, nnct);

endmodule

module edge_detector_half(input logic clk,
    output logic eclk);

    wire notclk;
    wire nct, nnct;

    nor #500 (notclk, clk, clk);
    nor     (nct, clk, clk);
    nor     (nnct, notclk, notclk);
    nor     (eclk, nct, nnct);

endmodule

module edge_detector_short(input logic clk,
    output logic eclk);

    wire notclk;
    wire nct, nnct;

    nor #30 (notclk, clk, clk);
    nor     (nct, clk, clk);
    nor     (nnct, notclk, notclk);
    nor     (eclk, nct, nnct);

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
        .eclk(eclk1)
    );

    edge_detector ied1 (
        .clk(qb0),
        .eclk(ieclk1)
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
        .eclk(eclk2)
    );

    edge_detector ied2 (
        .clk(qb1),
        .eclk(ieclk2)
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
        .eclk(eclk3)
    );

    edge_detector ied3 (
        .clk(qb2),
        .eclk(ieclk3)
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

module and5in(input logic in0, in1, in2, in3, in4,
    output logic out, f4high);

    /*
     * in[0-4] takes the inverted values for input signals
     * ie, for 00101 give 11010, because we are using nor gates.
     * */

    wire nor0, nor1, nor2;
    wire notnor0, notnor1, notnor2;

    nor #3 (nor0, in0, in1);
    nor #3 (notnor0, nor0, nor0);

    nor #3 (nor1, notnor0, in2);
    nor #3 (notnor1, nor1, nor1);

    nor #3 (nor2, notnor1, in3);
    nor #3 (notnor2, nor2, nor2);

    nor #3 (out, notnor2, in4);

    assign f4high = nor2;

endmodule

module demux16(input logic in, input logic [3:0] sl,
    output logic [15:0] out);

    /*
     * propagation delay -> 25 units
     * */
    reg sl00, sl01, sl02, sl03;
    wire sl10, sl11, sl12, sl13;
    wire notin;

    assign sl00 = sl[0];
    assign sl01 = sl[1];
    assign sl02 = sl[2];
    assign sl03 = sl[3];

    nor #3 (sl10, sl00, sl00);
    nor #3 (sl11, sl01, sl01);
    nor #3 (sl12, sl02, sl02);
    nor #3 (sl13, sl03, sl03);

    nor #3 (notin, in, in);

    /*
     * I know this is a mess, but why not ? :)
     * */
    and5in and00 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl00), .in4(notin), .out(out[0]));
    and5in and01 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl10), .in4(notin), .out(out[1]));
    and5in and02 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl00), .in4(notin), .out(out[2]));
    and5in and03 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl10), .in4(notin), .out(out[3]));
    and5in and04 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl00), .in4(notin), .out(out[4]));
    and5in and05 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl10), .in4(notin), .out(out[5]));
    and5in and06 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl00), .in4(notin), .out(out[6]));
    and5in and07 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl10), .in4(notin), .out(out[7]));
    and5in and08 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl00), .in4(notin), .out(out[8]));
    and5in and09 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl10), .in4(notin), .out(out[9]));
    and5in and10 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl00), .in4(notin), .out(out[10]));
    and5in and11 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl10), .in4(notin), .out(out[11]));
    and5in and12 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl00), .in4(notin), .out(out[12]));
    and5in and13 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl10), .in4(notin), .out(out[13]));
    and5in and14 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl00), .in4(notin), .out(out[14]));
    and5in and15 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl10), .in4(notin), .out(out[15]));


endmodule

module mux16(input logic [15:0] in, input logic [3:0] sl,
    output logic out, last);

    /*
     * propagation delay -> 112 units
     * */
    reg sl00, sl01, sl02, sl03; // the actual sl values
    wire sl10, sl11, sl12, sl13; // the inverted sl values
    wire notin00, notin01, notin02, notin03, notin04, notin05, notin06,
        notin07, notin08, notin09, notin10, notin11, notin12, notin13,
        notin14, notin15;
    wire out00, out01, out02, out03, out04, out05, out06, out07,
        out08, out09, out10, out11, out12, out13, out14, out15;

    assign sl00 = sl[0];
    assign sl01 = sl[1];
    assign sl02 = sl[2];
    assign sl03 = sl[3];

    nor #3 (sl10, sl00, sl00);
    nor #3 (sl11, sl01, sl01);
    nor #3 (sl12, sl02, sl02);
    nor #3 (sl13, sl03, sl03);

    nor #3 (notin00, in[0], in[0]);
    nor #3 (notin01, in[1], in[1]);
    nor #3 (notin02, in[2], in[2]);
    nor #3 (notin03, in[3], in[3]);
    nor #3 (notin04, in[4], in[4]);
    nor #3 (notin05, in[5], in[5]);
    nor #3 (notin06, in[6], in[6]);
    nor #3 (notin07, in[7], in[7]);
    nor #3 (notin08, in[8], in[8]);
    nor #3 (notin09, in[9], in[9]);
    nor #3 (notin10, in[10], in[10]);
    nor #3 (notin11, in[11], in[11]);
    nor #3 (notin12, in[12], in[12]);
    nor #3 (notin13, in[13], in[13]);
    nor #3 (notin14, in[14], in[14]);
    nor #3 (notin15, in[15], in[15]);

    /*
     * I know this is a mess, but why not ? :)
     * */
    and5in and00 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl00), .in4(notin00), .out(out00));
    and5in and01 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl10), .in4(notin01), .out(out01));
    and5in and02 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl00), .in4(notin02), .out(out02));
    and5in and03 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl10), .in4(notin03), .out(out03));
    and5in and04 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl00), .in4(notin04), .out(out04));
    and5in and05 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl10), .in4(notin05), .out(out05));
    and5in and06 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl00), .in4(notin06), .out(out06));
    and5in and07 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl10), .in4(notin07), .out(out07));
    and5in and08 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl00), .in4(notin08), .out(out08));
    and5in and09 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl10), .in4(notin09), .out(out09));
    and5in and10 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl00), .in4(notin10), .out(out10));
    and5in and11 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl10), .in4(notin11), .out(out11));
    and5in and12 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl00), .in4(notin12), .out(out12));
    and5in and13 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl10), .in4(notin13), .out(out13));
    and5in and14 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl00), .in4(notin14), .out(out14));
    and5in and15 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl10), .in4(notin15), .out(out15), .f4high(last));

    wire nor00, nor01, nor02, nor03, nor04, nor05, nor06, nor07,
        nor08, nor09, nor10, nor11, nor12, nor13, nor14;

    wire or00, or01, or02, or03, or04, or05, or06, or07,
        or08, or09, or10, or11, or12, or13;

        nor #3 (or00, nor00, nor00);
        nor #3 (or01, nor01, nor01);
        nor #3 (or02, nor02, nor02);
        nor #3 (or03, nor03, nor03);
        nor #3 (or04, nor04, nor04);
        nor #3 (or05, nor05, nor05);
        nor #3 (or06, nor06, nor06);
        nor #3 (or07, nor07, nor07);
        nor #3 (or08, nor08, nor08);
        nor #3 (or09, nor09, nor09);
        nor #3 (or10, nor10, nor10);
        nor #3 (or11, nor11, nor11);
        nor #3 (or12, nor12, nor12);
        nor #3 (or13, nor13, nor13);

        nor #3 (out, nor14, nor14);

        nor #3 (nor00, out00, out01);
        nor #3 (nor01, out02, or00);
        nor #3 (nor02, out03, or01);
        nor #3 (nor03, out04, or02);
        nor #3 (nor04, out05, or03);
        nor #3 (nor05, out06, or04);
        nor #3 (nor06, out07, or05);
        nor #3 (nor07, out08, or06);
        nor #3 (nor08, out09, or07);
        nor #3 (nor09, out10, or08);
        nor #3 (nor10, out11, or09);
        nor #3 (nor11, out12, or10);
        nor #3 (nor12, out13, or11);
        nor #3 (nor13, out14, or12);
        nor #3 (nor14, out15, or13);

endmodule

module and4in(input logic in0, in1, in2, in3,
    output logic out);

    /*
     * in[0-3] takes the inverted values for input signals
     * ie, for 0010 give 1101, because we are using nor gates.
     * */

    wire nor0, nor1;
    wire notnor0, notnor1;

    nor #3 (nor0, in0, in1);
    nor #3 (notnor0, nor0, nor0);

    nor #3 (nor1, notnor0, in2);
    nor #3 (notnor1, nor1, nor1);

    nor #3 (out, notnor1, in3);

endmodule

module alu(input logic eclk, ieclk, ina, inb, rst,
    input logic [2:0] op,
    output logic out, regout);

    wire op00, op01, op02;
    wire op10, op11, op12;

    wire opout02, opout03, opout04, opout05, opout06, opout07;
    wire out02, out03, out04, out05, out06, out07;
    wire out00and01;

    assign op00 = op[0];
    assign op01 = op[1];
    assign op02 = op[2];

    nor #3 (op10, op00, op00);
    nor #3 (op11, op01, op01);
    nor #3 (op12, op02, op02);

    wire op1and2, notop1and2;
    wire cout, notcout;
    wire sum, notsum;
    wire dwrst, notdwrst;
    wire notrst;
    wire andrstd0, andrstd1;
    wire data, notdata;

    nor #3 (op1and2, op01, op02);
    nor #3 (notop1and2, op1and2, op1and2);

    nor #3 (notsum, sum, sum);
    nor #3 (out00and01, notsum, notop1and2);

    nor #3 (dwrst, notop1and2, op10);
    nor #3 (notdwrst, dwrst, dwrst);

    nor #3 (notrst, rst, rst);
    nor #3 (notcout, cout, cout);
    nor #3 (andrstd0, notrst, notdwrst);
    nor #3 (andrstd1, notcout, rst);

    nor #3 (notdata, andrstd0, andrstd1);
    nor #3 (data, notdata, notdata);

    // inverting inb for SUB

    wire fxor, sxor0, sxor1, lxnor, inbforfa;

    nor #3 (fxor, dwrst, inb);
    nor #3 (sxor0, dwrst, fxor);
    nor #3 (sxor1, fxor, inb);
    nor #3 (lxnor, sxor0, sxor1);
    nor #3 (inbforfa, lxnor, lxnor);

    ms_flipflop coutreg (
        .eclk(eclk),
        .ieclk(ieclk),
        .data(data),
        .rst(notop1and2),
        .q(regout)
    );

    full_adder fadder (
        .a(ina),
        .b(inbforfa),
        .cin(regout),
        .sum(sum),
        .cout(cout)
    );

    xor_gate gxor   ( .a(ina), .b(inb), .y(opout02));
    and_gate gand   ( .a(ina), .b(inb), .y(opout03));
    not_gate gnot   ( .a(ina),          .y(opout04));
    or_gate  gor    ( .a(ina), .b(inb), .y(opout05));
    nor_gate gnor   ( .a(ina), .b(inb), .y(opout06));
    nand_gate gnand ( .a(ina), .b(inb), .y(opout07));

    wire notopout02, notopout03, notopout04, notopout05, notopout06, notopout07;

    nor #3 (notopout02, opout02, opout02);
    nor #3 (notopout03, opout03, opout03);
    nor #3 (notopout04, opout04, opout04);
    nor #3 (notopout05, opout05, opout05);
    nor #3 (notopout06, opout06, opout06);
    nor #3 (notopout07, opout07, opout07);

    and4in and2 (.in0(op02), .in1(op11), .in2(op00), .in3(notopout02), .out(out02));
    and4in and3 (.in0(op02), .in1(op11), .in2(op10), .in3(notopout03), .out(out03));
    and4in and4 (.in0(op12), .in1(op01), .in2(op00), .in3(notopout04), .out(out04));
    and4in and5 (.in0(op12), .in1(op01), .in2(op10), .in3(notopout05), .out(out05));
    and4in and6 (.in0(op12), .in1(op11), .in2(op00), .in3(notopout06), .out(out06));
    and4in and7 (.in0(op12), .in1(op11), .in2(op10), .in3(notopout07), .out(out07));

    wire nor00, nor01, nor02, nor03, nor04, nor05;
    wire or00, or01, or02, or03, or04;

    nor #3 (or00, nor00, nor00);
    nor #3 (or01, nor01, nor01);
    nor #3 (or02, nor02, nor02);
    nor #3 (or03, nor03, nor03);
    nor #3 (or04, nor04, nor04);

    nor #3 (out, nor05, nor05);

    nor #3 (nor00, out00and01, out02);
    nor #3 (nor01, out03, or00);
    nor #3 (nor02, out04, or01);
    nor #3 (nor03, out05, or02);
    nor #3 (nor04, out06, or03);
    nor #3 (nor05, out07, or04);

endmodule

module alu16(input logic clk, on,
    input logic [15:0] ina, inb,
    input logic [2:0] op,
    output logic [16:0] out,
    output logic [3:0] count);

    wire eclk, ieclk, notclk;

    nor #3 (notclk, clk, clk);

    edge_detector ed00 (
        .clk(clk),
        .eclk(eclk)
    );

    edge_detector ed01 (
        .clk(notclk),
        .eclk(ieclk)
    );

    wire noton, longon, notlongon;
    wire shorteclk, notshorteclk;
    wire dldata, dlout;
    wire rstsig;
    wire longonlq, notlongonlq;

    nor #3 (noton, on, on);

    edge_detector_short edshort (
        .clk(clk),
        .eclk(shorteclk)
    );

    nor #3 (notshorteclk, shorteclk, shorteclk);
    nor #3 (dldata, notshorteclk, on);

    wire srlq;

    sr_latch srl ( // ahhhhh, race conditionsss!!!!
        .reset(on),
        .set(dldata),
        .q(srlq)
    );

    edge_detector_half edhalf (
        .clk(srlq),
        .eclk(rstsig)
    );

    wire noteclk, lastcount;

    nor #3 (noteclk, eclk, eclk);
    nor #3 (eclkcounter, noteclk, lastcount);

    wire [15:0] dmout;
    wire muxaout, muxbout;
    wire aluout;

    counter counter (
        .eclk(eclkcounter),
        .ieclk(ieclk),
        .rst(rstsig),
        .count(count)
    );

    mux16 muxa (
        .in(ina),
        .sl(count),
        .out(muxaout),
        .last(lastcount)
    );

    mux16 muxb (
        .in(inb),
        .sl(count),
        .out(muxbout)
    );

    alu alu (
        .eclk(eclk),
        .ieclk(ieclk),
        .ina(muxaout),
        .inb(muxbout),
        .rst(rstsig),
        .op(op),
        .out(aluout),
        .regout(out[16])
    );

    demux16 demux(
        .in(eclkcounter), // some clock
        .sl(count),
        .out(dmout)
    );

    ms_flipflop msff00 (.eclk(dmout[00]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[00]));
    ms_flipflop msff01 (.eclk(dmout[01]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[01]));
    ms_flipflop msff02 (.eclk(dmout[02]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[02]));
    ms_flipflop msff03 (.eclk(dmout[03]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[03]));
    ms_flipflop msff04 (.eclk(dmout[04]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[04]));
    ms_flipflop msff05 (.eclk(dmout[05]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[05]));
    ms_flipflop msff06 (.eclk(dmout[06]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[06]));
    ms_flipflop msff07 (.eclk(dmout[07]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[07]));
    ms_flipflop msff08 (.eclk(dmout[08]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[08]));
    ms_flipflop msff09 (.eclk(dmout[09]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[09]));
    ms_flipflop msff10 (.eclk(dmout[10]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[10]));
    ms_flipflop msff11 (.eclk(dmout[11]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[11]));
    ms_flipflop msff12 (.eclk(dmout[12]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[12]));
    ms_flipflop msff13 (.eclk(dmout[13]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[13]));
    ms_flipflop msff14 (.eclk(dmout[14]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[14]));
    ms_flipflop msff15 (.eclk(dmout[15]), .ieclk(ieclk), .rst(rstsig), .data(aluout), .q(out[15]));

endmodule
