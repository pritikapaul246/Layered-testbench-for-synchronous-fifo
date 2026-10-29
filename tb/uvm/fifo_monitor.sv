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