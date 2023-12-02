module testbench();

    reg in;
    reg [3:0] sl;

    wire [15:0] out;

    demux16 billie (
        .in(in),
        .sl(sl),
        .out(out)
    );

    integer i;

    initial begin

        in = 1'b1;

        #100 $display ("%b", in);

        for (i = 0; i < 16; i++) begin
            sl = i;

            #100;

            $display ("%b", out);
        end

    end


endmodule
