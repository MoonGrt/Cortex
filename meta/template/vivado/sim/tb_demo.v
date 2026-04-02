`timescale 1ns/1ps

module tb_demo;

    reg clk = 'b0;
    reg rstn = 'b0;

    // DUT IO
    reg  [7:0] din = 'b0;
    reg        din_valid = 'b0;
    wire       din_ready;

    wire [7:0] dout;
    wire       dout_valid;
    reg        dout_ready = 'b0;

    integer fin, fout;
    integer ret;
    integer input_data;

    // clock
    always #5 clk = ~clk;

    // DUT
    demo uut (
        .clk        (clk),
        .rstn       (rstn),
        .din        (din),
        .din_valid  (din_valid),
        .din_ready  (din_ready),
        .dout       (dout),
        .dout_valid (dout_valid),
        .dout_ready (dout_ready)
    );

    initial begin
        clk = 0;
        rstn = 0;
        din = 0;
        din_valid = 0;
        dout_ready = 1;

        fin = 0;
        fout = 0;
        ret = 0;
        input_data = 0;

        // reset
        repeat(5) @(posedge clk);
        rstn = 1;

        // --------------------------
        // 读取输入（只读一次）
        // --------------------------
        fin = $fopen("/home/moon/pqc/chain/work/sim/input.txt", "r");
        if (fin == 0) begin
            $display("INPUT FILE ERROR");
            $finish;
        end
        ret = $fscanf(fin, "%d\n", input_data);
        $fclose(fin);

        if (ret != 1) begin
            $display("READ ERROR");
            $finish;
        end

        din = input_data & 8'hFF;

        $display("INPUT  = %0d", din);

        // --------------------------
        // 发送数据
        // --------------------------
        @(posedge clk);
        din_valid <= 1;

        wait(din_ready);

        @(posedge clk);
        din_valid <= 0;

        // --------------------------
        // 等待输出
        // --------------------------
        wait(dout_valid);

        $display("OUTPUT = %0d", dout);

        // --------------------------
        // 1️⃣ 覆盖写回 input 文件（链式）
        // --------------------------
        fin = $fopen("/home/moon/pqc/chain/work/sim/input.txt", "w");
        if (fin == 0) begin
            $display("WRITE INPUT FILE ERROR");
            $finish;
        end
        $fwrite(fin, "%0d\n", dout);
        $fclose(fin);

        // --------------------------
        // 2️⃣ 追加写入 output 文件（日志）
        // --------------------------
        fout = $fopen("/home/moon/pqc/chain/work/sim/output.txt", "a");
        if (fout == 0) begin
            $display("OUTPUT FILE ERROR");
            $finish;
        end
        $fwrite(fout, "%0d\n", dout);
        $fclose(fout);

        repeat(5) @(posedge clk);
        $finish;
    end

endmodule
