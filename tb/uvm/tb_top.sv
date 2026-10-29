`include "uvm_macros.svh"
import uvm_pkg::*;
import fifo_pkg::*;

module tb_top;
  bit clk = 0;
  always #5 clk = ~clk;

  fifo_uvm_if vif (clk);

  fifo_dut #(.WIDTH(8), .DEPTH(16)) dut (
    .clk(clk), .rst(vif.rst),
    .wr_en(vif.wr_en), .rd_en(vif.rd_en), .wdata(vif.wdata),
    .rdata(vif.rdata), .full(vif.full), .empty(vif.empty)
  );

  initial begin
    vif.rst = 0; vif.wr_en = 0; vif.rd_en = 0; vif.wdata = 0;
    #1 vif.rst = 1;                  // clean posedge for async reset
    repeat (3) @(posedge clk);
    #1 vif.rst = 0;
  end

  initial begin
    uvm_config_db#(virtual fifo_uvm_if)::set(null, "*", "vif", vif);
    run_test("fifo_base_test");
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_top);
  end
endmodule