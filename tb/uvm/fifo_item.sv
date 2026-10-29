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