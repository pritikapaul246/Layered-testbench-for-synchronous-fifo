class scoreboard;
    mailbox ref2sb;

    int unsigned total_checks = 0;
    int unsigned total_pass   = 0;
    int unsigned total_fail   = 0;

    function new(mailbox m);
        ref2sb = m;
    endfunction

    task run();
        sb_pkt_t pkt;
        forever begin
            ref2sb.get(pkt);
            total_checks++;
            if (pkt.exp !== pkt.act) begin
                total_fail++;
                $error("[SCOREBOARD] FAIL: Expected=%0h Actual=%0h", pkt.exp, pkt.act);
            end else begin
                total_pass++;
                $display("[SCOREBOARD] PASS: %0h", pkt.act);
            end
        end
    endtask
endclass