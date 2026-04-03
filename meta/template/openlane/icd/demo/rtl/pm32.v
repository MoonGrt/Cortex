// A signed 32x32 Multiplier utilizing SPM
// 
// Copyright 2016, mshalan@aucegypt.edu

`timescale		    1ns/1ps
`default_nettype    none

module pm32 (
    input wire          clk,
    input wire          rst,
    input wire          start,
    input wire  [31:0]  mc,
    input wire  [31:0]  mp,
    output reg  [63:0]  p,
    output wire         done
);
    wire        pw;
    reg [31:0]  Y;
    reg [7:0]   cnt, ncnt;
    reg [1:0]   state, nstate;

    localparam  IDLE=0, RUNNING=1, DONE=2;

    always @(posedge clk or posedge rst)
        if(rst)
            state  <= IDLE;
        else 
            state <= nstate;
    
    always @*
        case(state)
            IDLE    :   if(start) nstate = RUNNING; else nstate = IDLE;
            RUNNING :   if(cnt == 64) nstate = DONE; else nstate = RUNNING; 
            DONE    :   if(start) nstate = RUNNING; else nstate = DONE;
            default :   nstate = IDLE;
        endcase
    
    always @(posedge clk)
        cnt <= ncnt;

    always @*
        case(state)
            IDLE    :   ncnt = 0;
            RUNNING :   ncnt = cnt + 1;
            DONE    :   ncnt = 0;
            default :   ncnt = 0;
        endcase

    always @(posedge clk or posedge rst)
        if(rst)
            Y <= 32'b0;
        else if((start == 1'b1))
            Y <= mp;
        else if(state==RUNNING) 
            Y <= $signed(Y) >>> 1;

    always @(posedge clk or posedge rst)
        if(rst)
            p <= 64'b0;
        else if(start)
            p <= 64'b0;
        else if(state==RUNNING)
            p <= {pw, p[63:1]};

    wire y = (state==RUNNING) ? Y[0] : 1'b0;

    spm #(.SIZE(32)) spm32(
        .clk(clk),
        .rst(rst),
        .x(mc),
        .y(y),
        .p(pw)
    );

    assign done = (state == DONE);

endmodule


/*
    A Serial-Parallel Multiplier (SPM)
    Modeled after the design outlined by ATML for their 
    AT6000 FPGA in application notes DOC0716 and DOC0529:
        - https://ww1.microchip.com/downloads/en/AppNotes/DOC0529.PDF
        - https://ww1.microchip.com/downloads/en/AppNotes/DOC0716.PDF
    
    Implemented by mshalan@aucegypt.edu, 2016
*/

`timescale		    1ns/1ps
`default_nettype    none

module spm #(parameter SIZE = 32)(
    input wire              clk, 
    input wire              rst,
    input wire              y,
    input wire [SIZE-1:0]   x,
    output wire             p
);
    wire [SIZE-1:1]     pp;
    wire [SIZE-1:0]     xy;

    genvar i;

    CSADD csa0 (.clk(clk), .rst(rst), .x(x[0]&y), .y(pp[1]), .sum(p));
    
    generate 
        for(i=1; i<SIZE-1; i=i+1) begin
            CSADD csa (.clk(clk), .rst(rst), .x(x[i]&y), .y(pp[i+1]), .sum(pp[i]));
        end 
    endgenerate
    
    TCMP tcmp (.clk(clk), .rst(rst), .a(x[SIZE-1]&y), .s(pp[SIZE-1]));

endmodule


// Carry Save Adder
module CSADD(
    input wire  clk, 
    input wire  rst,
    input wire  x, 
    input wire  y,
    output reg  sum
);

    reg sc;

    // Half Adders logic
    wire hsum1, hco1;
    assign hsum1 = y ^ sc;
    assign hco1 = y & sc;

    wire hsum2, hco2;
    assign hsum2 = x ^ hsum1;
    assign hco2 = x & hsum1;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 1'b0;
            sc <= 1'b0;
        end
        else begin
            sum <= hsum2;
            sc <= hco1 ^ hco2;
        end
    end
endmodule

// 2's Complement
module TCMP (
    input wire  clk, 
    input wire  rst,
    input wire  a, 
    output reg  s
);
  
    reg z;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            s <= 1'b0;
            z <= 1'b0;
        end
        else begin
            z <= a | z;
            s <= a ^ z;
        end
    end

endmodule
