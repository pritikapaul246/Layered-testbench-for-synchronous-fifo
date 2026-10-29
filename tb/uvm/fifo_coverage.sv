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