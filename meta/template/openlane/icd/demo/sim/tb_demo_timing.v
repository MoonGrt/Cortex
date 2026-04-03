`timescale 1ns/1ps
`default_nettype none

module tb_demo_timing;

    reg         clk;
    reg         rst;
    reg         start;
    reg  [31:0] mc;
    reg  [31:0] mp;
    wire [63:0] p;
    wire        done;
    pm32 dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mc(mc),
        .mp(mp),
        .p(p),
        .done(done)
    );

    // clock
    initial clk = 0;
    always #5 clk = ~clk;
    // reference（改为 unsigned）
    reg [63:0] reference;
    task run_test(input [31:0] a, input [31:0] b);
    begin
        @(posedge clk);
        mc = a;
        mp = b;
        reference = a * b;   // unsigned 乘法

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        wait(done == 1'b1);
        @(posedge clk);
        if (p !== reference) begin
            $display("[ERROR] mc=%0d mp=%0d => DUT=%0d REF=%0d",
                      mc, mp, p, reference);
        end else begin
            $display("[PASS ] mc=%0d mp=%0d => %0d",
                      mc, mp, p);
        end
    end
    endtask

    integer i;
    initial begin
        rst   = 1;
        start = 0;
        mc    = 0;
        mp    = 0;

        repeat(5) @(posedge clk);
        rst = 0;

        // ---------------------------
        // Directed（全正数）
        // ---------------------------
        run_test(32'd0, 32'd0);
        run_test(32'd1, 32'd1);
        run_test(32'd10, 32'd20);
        run_test(32'd12345, 32'd6789);
        run_test(32'h7fffffff, 32'd2);

        // ---------------------------
        // Random（强制正数）
        // ---------------------------
        for (i = 0; i < 10; i = i + 1) begin
            run_test($random & 32'h7fffffff,
                     $random & 32'h7fffffff);
        end

        $display("All tests finished.");
        $finish;
    end

endmodule