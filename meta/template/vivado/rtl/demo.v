module demo (
    input  wire       clk,
    input  wire       rstn,
    // input
    input  wire [7:0] din,
    input  wire       din_valid,
    output wire       din_ready,
    // output
    output reg  [7:0] dout = 'b0,
    output reg        dout_valid = 'b0,
    input  wire       dout_ready
);

    // pipeline registers
    reg [7:0] stage1_data = 'b0;
    reg       stage1_valid = 'b0;
    reg [7:0] stage2_data = 'b0;
    reg       stage2_valid = 'b0;

    // ready logic
    assign din_ready = !stage1_valid || (stage2_valid && dout_ready);

    // stage1
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            stage1_valid <= 0;
        end else if (din_ready) begin
            stage1_valid <= din_valid;
            if (din_valid)
                stage1_data <= din;
        end
    end

    // stage2（计算 + 截断到8bit）
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            stage2_valid <= 0;
        end else begin
            stage2_valid <= stage1_valid;
            if (stage1_valid)
                stage2_data <= (stage1_data * 3 + 1) & 8'hFF;
        end
    end

    // output
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout_valid <= 0;
        end else if (dout_ready) begin
            dout_valid <= stage2_valid;
            if (stage2_valid)
                dout <= stage2_data;
        end
    end

endmodule