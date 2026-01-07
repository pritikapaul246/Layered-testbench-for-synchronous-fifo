class packet;
    rand bit wr_en;
    rand bit rd_en;
    rand bit [7:0] data;

    constraint no_both { !(wr_en && rd_en); }
endclass