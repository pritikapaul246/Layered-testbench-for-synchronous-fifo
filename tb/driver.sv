class driver;
    virtual fifo_if vif;
    mailbox gen2drv;

    function new(virtual fifo_if vif, mailbox m);
        this.vif = vif;
        this.gen2drv = m;
    endfunction

    task run();
        packet p;
        bit allow_wr;
        bit allow_rd;
        forever begin
            gen2drv.get(p);

            @(negedge vif.clk);

            allow_wr = p.wr_en && !vif.full;
            allow_rd = p.rd_en && !vif.empty;

            vif.wdata = p.data;

            vif.wr_en = allow_wr;
            vif.rd_en = allow_rd;

            @(posedge vif.clk);

            @(posedge vif.clk);
            vif.wr_en = 0;
            vif.rd_en = 0;

            #1;
        end
    endtask
endclass