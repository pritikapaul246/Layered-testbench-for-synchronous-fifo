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