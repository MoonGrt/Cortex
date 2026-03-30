import "DPI-C" function void ebreak(input byte code);
module EBreak (
  input trap,
  input [7:0] code
);
  always @* if (trap) ebreak(code);
endmodule

import "DPI-C" function int  pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input byte wmask, input int wdata);
module PMem(
  input valid,
  input [31:0] raddr,
  input [31:0] waddr,
  input [31:0] wdata,
  input [7:0] wmask,
  input wen,
  output reg [31:0] rdata
);
  always @(*) begin
    if (valid) begin
      rdata = pmem_read(raddr);
      if (wen) pmem_write(waddr, wdata, wmask);
    end else rdata = 0;
  end
endmodule

module ROM_DPI(
  input  wire [31:0] addr,
  output reg  [31:0] data
);
  always @(*) data = pmem_read(addr);
endmodule

module RAM_DPI(
  input  wire        we,
  input  wire [31:0] addr,
  input  wire [ 7:0] mask,
  input  wire [31:0] wdata,
  output reg  [31:0] rdata
);
  always @(*) begin
    rdata = pmem_read(addr);
    if (we) pmem_write(addr, mask, wdata);
  end
endmodule
