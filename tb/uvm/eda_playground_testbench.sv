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

package fifo_pkg;
import uvm_pkg::*;
`include "uvm_macros.svh"
class fifo_item extends uvm_sequence_item;
  rand bit       wr_en, rd_en;
  rand bit [7:0] wdata;
  bit      [7:0] rdata;
  bit            full, empty, rst;

  constraint c_act { soft (wr_en || rd_en); }

  `uvm_object_utils_begin(fifo_item)
    `uvm_field_int(wr_en, UVM_ALL_ON)
    `uvm_field_int(rd_en, UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="fifo_item"); super.new(name); endfunction
endclass
class fifo_base_seq extends uvm_sequence #(fifo_item);
  `uvm_object_utils(fifo_base_seq)
  function new(string name="fifo_base_seq"); super.new(name); endfunction
endclass

// write only
class fifo_write_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_write_seq)
  int unsigned n = 20;
  function new(string name="fifo_write_seq"); super.new(name); endfunction
  task body();
    repeat (n) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {wr_en==1; rd_en==0;}) `uvm_error("SEQ","randomize failed")
      finish_item(req);
    end
  endtask
endclass

// read only
class fifo_read_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_read_seq)
  int unsigned n = 20;
  function new(string name="fifo_read_seq"); super.new(name); endfunction
  task body();
    repeat (n) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {wr_en==0; rd_en==1;}) `uvm_error("SEQ","randomize failed")
      finish_item(req);
    end
  endtask
endclass

// simultaneous write + read
class fifo_wrrd_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_wrrd_seq)
  int unsigned n = 20;
  function new(string name="fifo_wrrd_seq"); super.new(name); endfunction
  task body();
    repeat (n) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      if (!req.randomize() with {wr_en==1; rd_en==1;}) `uvm_error("SEQ","randomize failed")
      finish_item(req);
    end
  endtask
endclass

// fully random
class fifo_rand_seq extends fifo_base_seq;
  `uvm_object_utils(fifo_rand_seq)
  int unsigned n = 500;
  function new(string name="fifo_rand_seq"); super.new(name); endfunction
  task body();
    repeat (n) begin
      req = fifo_item::type_id::create("req");
      start_item(req);
      if (!req.randomize()) `uvm_error("SEQ","randomize failed")
      finish_item(req);
    end
  endtask
endclass
class fifo_driver extends uvm_driver #(fifo_item);
  `uvm_component_utils(fifo_driver)
  virtual fifo_uvm_if vif;

  function new(string n, uvm_component p); super.new(n,p); endfunction

  function void build_phase(uvm_phase phase);
    if (!uvm_config_db#(virtual fifo_uvm_if)::get(this,"","vif",vif))
      `uvm_fatal("DRV","vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    wait (vif.rst === 1'b1);   // reset asserted
    wait (vif.rst === 1'b0);   // reset released
    forever begin
      @(vif.drv_cb);
      seq_item_port.try_next_item(req);
      if (req == null) begin             // idle when no item
        vif.drv_cb.wr_en <= 0;
        vif.drv_cb.rd_en <= 0;
      end else begin
        vif.drv_cb.wr_en <= req.wr_en;
        vif.drv_cb.rd_en <= req.rd_en;
        vif.drv_cb.wdata <= req.wdata;
        seq_item_port.item_done();
      end
    end
  endtask
endclass
class fifo_monitor extends uvm_monitor;
  `uvm_component_utils(fifo_monitor)
  virtual fifo_uvm_if vif;
  uvm_analysis_port #(fifo_item) ap;

  function new(string n, uvm_component p); super.new(n,p); endfunction

  function void build_phase(uvm_phase phase);
    ap = new("ap", this);
    if (!uvm_config_db#(virtual fifo_uvm_if)::get(this,"","vif",vif))
      `uvm_fatal("MON","vif not set")
  endfunction

  task run_phase(uvm_phase phase);
    fifo_item t;
    forever begin
      @(vif.mon_cb);
      t = fifo_item::type_id::create("t");
      t.rst   = vif.mon_cb.rst;
      t.wr_en = vif.mon_cb.wr_en;
      t.rd_en = vif.mon_cb.rd_en;
      t.wdata = vif.mon_cb.wdata;
      t.rdata = vif.mon_cb.rdata;
      t.full  = vif.mon_cb.full;
      t.empty = vif.mon_cb.empty;
      ap.write(t);
    end
  endtask
endclass
class fifo_agent extends uvm_agent;
  `uvm_component_utils(fifo_agent)

  fifo_driver                drv;
  fifo_monitor               mon;
  uvm_sequencer #(fifo_item) sqr;

  function new(string n, uvm_component p); super.new(n,p); endfunction

  function void build_phase(uvm_phase phase);
    mon = fifo_monitor::type_id::create("mon", this);
    if (get_is_active() == UVM_ACTIVE) begin
      drv = fifo_driver::type_id::create("drv", this);
      sqr = uvm_sequencer#(fifo_item)::type_id::create("sqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
class fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(fifo_scoreboard)
  uvm_analysis_imp #(fifo_item, fifo_scoreboard) imp;

  bit [7:0]    q[$];
  bit [7:0]    exp_data;
  bit          exp_valid;
  int unsigned DEPTH = 16;          // match fifo_dut DEPTH
  int          checks, errors;

  function new(string n, uvm_component p); super.new(n,p); endfunction

  function void build_phase(uvm_phase phase);
    imp = new("imp", this);
  endfunction

  function void write(fifo_item t);
    bit do_wr, do_rd;

    if (t.rst) begin                 // flush model during reset
      q.delete(); exp_valid = 0;
      return;
    end

   
    if (exp_valid) begin
      checks++;
      if (t.rdata !== exp_data) begin
        errors++;
        `uvm_error("SB", $sformatf("rdata mismatch: exp=%0h got=%0h", exp_data, t.rdata))
      end
      exp_valid = 0;
    end

  
    if (t.full !== (q.size() == DEPTH))
      `uvm_error("SB", $sformatf("full flag wrong: dut=%0b model_size=%0d", t.full, q.size()))
    if (t.empty !== (q.size() == 0))
      `uvm_error("SB", $sformatf("empty flag wrong: dut=%0b model_size=%0d", t.empty, q.size()))

  
    do_wr = t.wr_en && !t.full;
    do_rd = t.rd_en && !t.empty;
    if (do_rd) begin
      if (q.size() > 0) begin exp_data = q.pop_front(); exp_valid = 1; end
      else `uvm_error("SB", "read accepted but model queue empty")
    end
    if (do_wr) q.push_back(t.wdata);
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SB", $sformatf("read-data checks=%0d, mismatches=%0d", checks, errors), UVM_LOW)
  endfunction
endclass
class fifo_coverage extends uvm_subscriber #(fifo_item);
  `uvm_component_utils(fifo_coverage)

  fifo_item tr;

  covergroup cg;
    option.per_instance = 1;
    cp_wr    : coverpoint tr.wr_en;
    cp_rd    : coverpoint tr.rd_en;
    cp_full  : coverpoint tr.full;
    cp_empty : coverpoint tr.empty;
    x_wr_rd    : cross cp_wr, cp_rd;       // includes simultaneous wr+rd
    x_wr_full  : cross cp_wr, cp_full;     // write attempted while full
    x_rd_empty : cross cp_rd, cp_empty;    // read attempted while empty
  endgroup

  function new(string n, uvm_component p);
    super.new(n,p);
    cg = new();
  endfunction

  function void write(fifo_item t);
    if (!t.rst) begin
      tr = t;
      cg.sample();
    end
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("COV", $sformatf("functional coverage = %0.2f%%", cg.get_inst_coverage()), UVM_LOW)
  endfunction
endclass
class fifo_env extends uvm_env;
  `uvm_component_utils(fifo_env)

  fifo_agent      agent;
  fifo_scoreboard sb;
  fifo_coverage   cov;

  function new(string n, uvm_component p); super.new(n,p); endfunction

  function void build_phase(uvm_phase phase);
    agent = fifo_agent::type_id::create("agent", this);
    sb    = fifo_scoreboard::type_id::create("sb", this);
    cov   = fifo_coverage::type_id::create("cov", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.mon.ap.connect(sb.imp);
    agent.mon.ap.connect(cov.analysis_export);
  endfunction
endclass
class fifo_base_test extends uvm_test;
  `uvm_component_utils(fifo_base_test)

  fifo_env env;

  function new(string n, uvm_component p); super.new(n,p); endfunction

  function void build_phase(uvm_phase phase);
    env = fifo_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    fifo_write_seq wr = fifo_write_seq::type_id::create("wr");
    fifo_read_seq  rd = fifo_read_seq::type_id::create("rd");
    fifo_wrrd_seq  wrrd = fifo_wrrd_seq::type_id::create("wrrd");
    fifo_rand_seq  rn = fifo_rand_seq::type_id::create("rn");

    phase.raise_objection(this);

    wr.n = 20;   wr.start(env.agent.sqr);     // fill to full (16) + 4 overflow writes
    rd.n = 20;   rd.start(env.agent.sqr);     // drain to empty + 4 underflow reads
    wr.n = 8;    wr.start(env.agent.sqr);     // half fill
    wrrd.n = 20; wrrd.start(env.agent.sqr);   // simultaneous wr+rd
    rn.n = 500;  rn.start(env.agent.sqr);     // random mix

    #100;                                      // let last samples reach scoreboard
    phase.drop_objection(this);
  endtask
endclass
endpackage

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
