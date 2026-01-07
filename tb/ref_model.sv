class ref_model;
    mailbox mon2ref;
    mailbox ref2sb;
    bit [7:0] fifo_q[$];

    function new(mailbox a, mailbox b);
        mon2ref = a;
        ref2sb  = b;
    endfunction

    task run();
        mon_pkt_t m;
        forever begin
            mon2ref.get(m);

            if (m.rd) begin
                if (!m.empty && fifo_q.size() > 0) begin
                    sb_pkt_t sb;
                    sb.exp = fifo_q.pop_front();
                    sb.act = m.dout;
                    ref2sb.put(sb);
                end
            end

            if (m.wr && !m.full) begin
                fifo_q.push_back(m.din);
            end
        end
    endtask
endclass
