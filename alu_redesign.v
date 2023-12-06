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
    output logic reclk);

    wire notclk;

    nor #30 (notclk, clk, clk);
    and #3 (reclk, notclk, clk);

endmodule

module sr_latch(input logic set, reset,
    output logic q, qbar);

    nor #3 (q, qbar, reset);
    nor #3 (qbar, q, set);

endmodule

module sr_flipflop(input logic set, reset, clk,
    output logic q, qbar);

    /*
     * With active low clk
     * */

    wire srlset, srlreset;

    sr_latch srl (
        .set(srlset),
        .reset(srlreset),
        .q(q),
        .qbar(qbar)
    );

    nor #3 (srlreset, set, clk);
    nor #3 (srlset, reset, clk);

endmodule

module d_flipflop(input logic data, clk,
    output logic q, qbar);

    /*
     * With active low clk
     * */

    wire notdata;

    sr_flipflop srff (
        .set(data),
        .reset(notdata),
        .clk(clk),
        .q(q),
        .qbar(qbar)
    );

    nor #3 (notdata, data, data);

endmodule

module d_flipflop_ar(input logic data, clk, rst,
    output logic q, qbar);

    /*
     * With active high clk, async rst,
     * make sure to never let data and clk high
     * when rst is high
     * */

    wire notdata;
    wire set, reset;
    wire acreset, notacreset;
    wire acclk;

    sr_latch srl (
        .set(set),
        .reset(acreset),
        .q(q),
        .qbar(qbar)
    );

    nor #3 (acclk, clk, clk);
    nor #3 (notdata, data, data);

    nor #3 (reset, data, acclk);
    nor #3 (set, notdata, acclk);

    nor #3 (notacreset, reset, rst);
    nor #3 (acreset, notacreset, notacreset);

endmodule

module d_flipflop_sr(input logic data, rst, clk,
    output logic q, qbar);

    /*
     * With active low clk and active low data
     * */

    wire acdata;

    d_flipflop dl (
        .data(acdata),
        .clk(clk),
        .q(q),
        .qbar(qbar)
    );

    nor #3 (acdata, data, rst);

endmodule

module ms_flipflop(input logic data, rst, reclk, feclk,
    output logic q, qbar);

    /*
     * With synchronous reset, active low data,
     * active high reclk, and feclk
     * */

    wire sdata, notsdata;

    wire ireclk, ifeclk;

    nor #3 (ireclk, reclk, reclk);
    nor #3 (ifeclk, feclk, feclk);

    d_flipflop_sr master (
        .data(data),
        .clk(ireclk),
        .q(sdata),
        .qbar(notsdata),
        .rst(rst)
    );

    sr_flipflop slave (
        .set(sdata),
        .reset(notsdata),
        .clk(ifeclk),
        .q(q),
        .qbar(qbar)
    );

endmodule

module counter(input logic reclk, feclk, rst,
    output logic [3:0] count);

    wire feclk1, feclk2, feclk3;

    wire acfeclk1, acfeclk2, acfeclk3;
    wire mux11, mux12, mux21, mux22, mux31, mux32;
    wire notrst;
    wire qbar1, qbar2, qbar3;

    nor #3 (notrst, rst, rst);

    ms_flipflop msff00 (
        .data(count[0]),
        .rst(rst),
        .reclk(reclk),
        .feclk(feclk),
        .q(count[0]),
        .qbar(qbar1)
    );

    edge_detector ed01 (
        .clk(qbar1),
        .reclk(feclk1)
    );

    nor #3 (mux11, rst, feclk1);
    nor #3 (mux12, notrst, feclk);
    nor #3 (acfeclk1, mux11, mux12);

    ms_flipflop msff01 (
        .data(count[1]),
        .rst(rst),
        .reclk(reclk),
        .feclk(acfeclk1),
        .q(count[1]),
        .qbar(qbar2)
    );

    edge_detector ed02 (
        .clk(qbar2),
        .reclk(feclk2)
    );

    nor #3 (mux21, rst, feclk2);
    nor #3 (mux22, notrst, feclk);
    nor #3 (acfeclk2, mux21, mux22);

    ms_flipflop msff02 (
        .data(count[2]),
        .rst(rst),
        .reclk(reclk),
        .feclk(acfeclk2),
        .q(count[2]),
        .qbar(qbar3)
    );

    edge_detector ed03 (
        .clk(qbar3),
        .reclk(feclk3)
    );

    nor #3 (mux31, rst, feclk3);
    nor #3 (mux32, notrst, feclk);
    nor #3 (acfeclk3, mux31, mux32);

    ms_flipflop msff03 (
        .data(count[3]),
        .rst(rst),
        .reclk(reclk),
        .feclk(acfeclk3),
        .q(count[3])
    );


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

    /*
     * Active low in
     * */

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

    nor5input nor500 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl00), .in4(in), .out(out[00]));
    nor5input nor501 (.in0(sl03), .in1(sl02), .in2(sl01), .in3(sl10), .in4(in), .out(out[01]));
    nor5input nor502 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl00), .in4(in), .out(out[02]));
    nor5input nor503 (.in0(sl03), .in1(sl02), .in2(sl11), .in3(sl10), .in4(in), .out(out[03]));
    nor5input nor504 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl00), .in4(in), .out(out[04]));
    nor5input nor505 (.in0(sl03), .in1(sl12), .in2(sl01), .in3(sl10), .in4(in), .out(out[05]));
    nor5input nor506 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl00), .in4(in), .out(out[06]));
    nor5input nor507 (.in0(sl03), .in1(sl12), .in2(sl11), .in3(sl10), .in4(in), .out(out[07]));
    nor5input nor508 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl00), .in4(in), .out(out[08]));
    nor5input nor509 (.in0(sl13), .in1(sl02), .in2(sl01), .in3(sl10), .in4(in), .out(out[09]));
    nor5input nor510 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl00), .in4(in), .out(out[10]));
    nor5input nor511 (.in0(sl13), .in1(sl02), .in2(sl11), .in3(sl10), .in4(in), .out(out[11]));
    nor5input nor512 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl00), .in4(in), .out(out[12]));
    nor5input nor513 (.in0(sl13), .in1(sl12), .in2(sl01), .in3(sl10), .in4(in), .out(out[13]));
    nor5input nor514 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl00), .in4(in), .out(out[14]));
    nor5input nor515 (.in0(sl13), .in1(sl12), .in2(sl11), .in3(sl10), .in4(in), .out(out[15]));

endmodule

module memoryunit_mux(input logic data, reclk, rst, input logic [3:0] sl,
    output logic [15:0] out);

    wire [15:0] dmout;
    wire notdata;

    demux16 demux(
        .in(reclk),
        .sl(sl),
        .out(dmout)
    );

    nor #3 (notdata, data, data);

    d_flipflop_ar dlsr00 (.data(notdata), .rst(rst), .clk(dmout[00]), .q(out[00]));
    d_flipflop_ar dlsr01 (.data(notdata), .rst(rst), .clk(dmout[01]), .q(out[01]));
    d_flipflop_ar dlsr02 (.data(notdata), .rst(rst), .clk(dmout[02]), .q(out[02]));
    d_flipflop_ar dlsr03 (.data(notdata), .rst(rst), .clk(dmout[03]), .q(out[03]));
    d_flipflop_ar dlsr04 (.data(notdata), .rst(rst), .clk(dmout[04]), .q(out[04]));
    d_flipflop_ar dlsr05 (.data(notdata), .rst(rst), .clk(dmout[05]), .q(out[05]));
    d_flipflop_ar dlsr06 (.data(notdata), .rst(rst), .clk(dmout[06]), .q(out[06]));
    d_flipflop_ar dlsr07 (.data(notdata), .rst(rst), .clk(dmout[07]), .q(out[07]));
    d_flipflop_ar dlsr08 (.data(notdata), .rst(rst), .clk(dmout[08]), .q(out[08]));
    d_flipflop_ar dlsr09 (.data(notdata), .rst(rst), .clk(dmout[09]), .q(out[09]));
    d_flipflop_ar dlsr10 (.data(notdata), .rst(rst), .clk(dmout[10]), .q(out[10]));
    d_flipflop_ar dlsr11 (.data(notdata), .rst(rst), .clk(dmout[11]), .q(out[11]));
    d_flipflop_ar dlsr12 (.data(notdata), .rst(rst), .clk(dmout[12]), .q(out[12]));
    d_flipflop_ar dlsr13 (.data(notdata), .rst(rst), .clk(dmout[13]), .q(out[13]));
    d_flipflop_ar dlsr14 (.data(notdata), .rst(rst), .clk(dmout[14]), .q(out[14]));
    d_flipflop_ar dlsr15 (.data(notdata), .rst(rst), .clk(dmout[15]), .q(out[15]));

endmodule

module alu_init(input logic bin, cin, rst, op,
    output logic bout, cout);

    wire bxnorfl, bxnorslt, bxnorslb, bxnortl;

    // inveting bin for subtraction
    nor #3 (bxnorfl, bin, op);

    nor #3 (bxnorslt, bin, bxnorfl);
    nor #3 (bxnorslb, op, bxnorfl);

    nor #3 (bxnortl, bxnorslt, bxnorslb);

    nor #3 (bout, bxnortl, bxnortl);

    wire notrst;
    wire muxfl1, muxfl2, muxsl;

    // resetting msff
    nor #3 (notrst, rst, rst);

    nor #3 (muxfl1, rst, cin);
    nor #3 (muxfl2, notrst, op);

    nor #3 (muxsl, muxfl1, muxfl2);

    nor #3 (cout, muxsl, muxsl);

endmodule

module mux7(input logic [6:0] in, input logic [2:0] sl,
    output logic slf00, out);

    wire sl00, sl01, sl02; // original select lines
    wire sl10, sl11, sl12; // inverted select lines

    assign sl00 = sl[0];
    assign sl01 = sl[1];
    assign sl02 = sl[2];

    nor #3 (sl10, sl00, sl00);
    nor #3 (sl11, sl01, sl01);
    nor #3 (sl12, sl02, sl02);

    wire [6:0] muxfl;
    wire norfl, orfl;

    nor #3 (norfl, sl02, sl01);
    nor #3 (orfl, norfl, norfl);
    nor #3 (muxfl[0], orfl, in[0]);

    // for rst to msff inside alu
    assign slf00 = orfl;

    nor4input nor402 ( .in0(sl02), .in1(sl11), .in2(sl00), .in3(in[1]), .out(muxfl[1]) );
    nor4input nor403 ( .in0(sl02), .in1(sl11), .in2(sl10), .in3(in[2]), .out(muxfl[2]) );
    nor4input nor404 ( .in0(sl12), .in1(sl01), .in2(sl00), .in3(in[3]), .out(muxfl[3]) );
    nor4input nor405 ( .in0(sl12), .in1(sl01), .in2(sl10), .in3(in[4]), .out(muxfl[4]) );
    nor4input nor406 ( .in0(sl12), .in1(sl11), .in2(sl00), .in3(in[5]), .out(muxfl[5]) );
    nor4input nor407 ( .in0(sl12), .in1(sl11), .in2(sl10), .in3(in[6]), .out(muxfl[6]) );

    wire mlnor01, mlor01, mlnor012, mlor012;
    wire mlnor3456, mlor3456;

    nor #3 (mlnor01, muxfl[0], muxfl[1]);
    nor #3 (mlor01, mlnor01, mlnor01);

    nor #3 (mlnor012, mlor01, muxfl[2]);
    nor #3 (mlor012, mlnor012, mlnor012);

    nor4input nor4last  (
        .in0(muxfl[3]), .in1(muxfl[4]),
        .in2(muxfl[5]), .in3(muxfl[6]),
        .out(mlnor3456)
    );

    nor #3 (mlor3456, mlnor3456, mlnor3456);

    nor #3 (out, mlor012, mlor3456);


endmodule

module alu( input logic [2:0] op,
    input logic ain, bin, rst, reclk, feclk,
    output logic aluout, regout);

    wire [6:0] muxin;
    wire bout;
    wire cout;
    wire regin;
    wire slf00;

    full_adder flad (
        .a(ain),
        .b(bout),
        .cin(regout),
        .sum(muxin[0]),
        .cout(cout)
    );

    alu_init ainit (
        .bin(bin),
        .cin(cout),
        .rst(rst),
        .op(op[0]),
        .bout(bout),
        .cout(regin)
    );

    ms_flipflop msff (
        .data(regin),
        .rst(slf00),
        .reclk(reclk),
        .feclk(feclk),
        .q(regout)
    );

    mux7 mux (
        .sl(op),
        .in(muxin),
        .out(aluout),
        .slf00(slf00)
    );

    xor_gate  gxor   ( .a(ain), .b(bin), .y(muxin[1]) );
    and_gate  gand   ( .a(ain), .b(bin), .y(muxin[2]) );
    not_gate  gnot   ( .a(ain),          .y(muxin[3]) );
    or_gate   gor    ( .a(ain), .b(bin), .y(muxin[4]) );
    nor_gate  gnor   ( .a(ain), .b(bin), .y(muxin[5]) );
    nand_gate gnand  ( .a(ain), .b(bin), .y(muxin[6]) );

endmodule
