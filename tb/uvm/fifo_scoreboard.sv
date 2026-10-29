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