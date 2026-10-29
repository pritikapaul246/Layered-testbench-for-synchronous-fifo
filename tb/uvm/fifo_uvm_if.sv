interface fifo_uvm_if (input logic clk);
  logic       rst;
  logic       wr_en, rd_en;
  logic [7:0] wdata, rdata;
  logic       full, empty;

  clocking drv_cb @(posedge clk);
    default input #1step output #1;
    output wr_en, rd_en, wdata;
    input  rdata, full, empty;
  endclocking

  clocking mon_cb @(posedge clk);
    default input #1step;
    input rst, wr_en, rd_en, wdata, rdata, full, empty;
  endclocking
endinterface
