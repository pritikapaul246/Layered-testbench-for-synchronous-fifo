class monitor;
    virtual fifo_if vif;
    mailbox mon2ref;

    function new(virtual fifo_if vif, mailbox m);
        this.vif = vif;
        this.mon2ref = m;
    endfunction

    task run();
        mon_pkt_t pkt;
        forever begin
            @(posedge vif.clk);
            #1; 

            pkt.wr    = vif.wr_en;    
			pkt.rd    = vif.rd_en;     
            pkt.din   = vif.wdata;
            pkt.dout  = vif.rdata;
            pkt.full  = vif.full;
            pkt.empty = vif.empty;

            if (pkt.wr || pkt.rd) begin
                mon2ref.put(pkt);
            end
        end
    endtask
endclass