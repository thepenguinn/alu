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

module and5in(input logic in0, in1, in2, in3, in4,
    output logic out);

    /*
     * in[0-3] takes the inverted values for select signals
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

endmodule

module mux16(input logic [15:0] in, input logic [3:0] sl,
    output logic out);

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
    and5in and15 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl10), .in4(notin15), .out(out15));

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

module testbench;

    reg [15:0] in;
    reg [3:0] sl;
    wire out;
    integer i;

    mux16 m16 (
        .in(in),
        .sl(sl),
        .out(out)
    );

    initial begin

        in = 16'b0000_0000_0000_0000;
        $display("%b", in);

        for (i = 0; i < 16; i++) begin
            sl = i;
            #112;
            $display("%b -> %b", sl, out);

        end

    end

endmodule
