module tb;
    logic clk = 0;
    logic rst = 1;
    always #5 clk = ~clk;

    fifo_if #(.WIDTH(8)) intf (.clk(clk), .rst(rst));

    fifo_dut dut (
        .clk(clk),
        .rst(rst),
        .wr_en(intf.wr_en),
        .rd_en(intf.rd_en),
        .wdata(intf.wdata),
        .rdata(intf.rdata),
        .full(intf.full),
        .empty(intf.empty)
    );

    mailbox gen2drv = new();
    mailbox mon2ref = new();
    mailbox ref2sb  = new();

    generator   gen;
    driver      drv;
    monitor     mon;
    ref_model   refm;
    scoreboard  sb;

    covergroup ops_cg @(posedge clk);
        cp_wr: coverpoint intf.wr_en;
        cp_rd: coverpoint intf.rd_en;
        cp_cross: cross cp_wr, cp_rd;
    endgroup
    ops_cg cg = new();

    initial begin
        rst = 1;
        #20 rst = 0;

        intf.wr_en = 0;
        intf.rd_en = 0;
        intf.wdata = 0;

        gen  = new(gen2drv);
        drv  = new(intf, gen2drv);
        mon  = new(intf, mon2ref);
        refm = new(mon2ref, ref2sb);
        sb   = new(ref2sb);

        fork
            gen.run(200);
            drv.run();
            mon.run();
            refm.run();
            sb.run();
        join_none

        #3000;

        $display("=== SCOREBOARD SUMMARY ===");
        $display("Total checks = %0d", sb.total_checks);
        $display("Total pass   = %0d", sb.total_pass);
        $display("Total fail   = %0d", sb.total_fail);

        $finish;
    end
endmodule