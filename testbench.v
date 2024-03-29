module testbench;

    reg en;
    wire clkout;

    reg [15:0] aluina, aluinb;
    reg [2:0] aluop;
    reg aluon;
    wire [3:0] alucount;
    wire [16:0] aluout;

    integer i, j;


    ring_oscillator rosci (
        .en(en),
        .out(clkout)
    );

    alu16 alu (
        .clk(clkout),
        .on(aluon),
        .ina(aluina),
        .inb(aluinb),
        .op(aluop),
        .out(aluout),
        .count(alucount)
    );

    initial begin

        en = 1'b0;
        #900;
        en = 1'b1;

        aluina = 16'b0000_0000_1100_0111;
        aluinb = 16'b0000_0000_0010_0001;

        aluop = 3'b000;

        aluon = 1'b0;
        #100;
        aluon = 1'b1;
        #100;
        aluon = 1'b0;

        j = 0;
        i = 0;

    end

    initial begin
        $display("Clk  Count            Aluout         Time");
    end

    always @(posedge clkout) begin
        if (aluon == 1'b0) begin
            if (i < 32) begin
                i++;
                #20 $display("%3d %b %b %b %12t", i, clkout, alucount, aluout, $time);
            end else begin
                $finish;
            end
        end
    end

endmodule
