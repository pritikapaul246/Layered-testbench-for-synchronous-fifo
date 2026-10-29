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