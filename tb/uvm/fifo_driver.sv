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