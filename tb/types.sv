typedef struct packed {
    bit wr;
    bit rd;
    bit [7:0] din;
    bit [7:0] dout;
    bit full;
    bit empty;
} mon_pkt_t;

typedef struct packed {
    bit [7:0] exp;
    bit [7:0] act;
} sb_pkt_t;