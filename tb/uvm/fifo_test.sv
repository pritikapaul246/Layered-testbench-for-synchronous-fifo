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