class generator;
    mailbox gen2drv;

    function new(mailbox m);
        gen2drv = m;
    endfunction
    task run(int unsigned N = 300);
        packet p;
        for (int i = 0; i < N; i++) begin
            p = new();
            p.randomize(); 
            #1;
        end

        forever begin
            p = new();
            p.wr_en = 0; p.rd_en = 0; p.data = 0;
            gen2drv.put(p);
            #1;
        end
    endtask
endclass
