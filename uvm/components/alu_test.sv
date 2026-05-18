//  Class: alu_test
//
class alu_test extends uvm_test;

  `uvm_component_utils(alu_test)

  //  Group: Components
  alu_env         m_env;
  alu_scoreboard  m_scbd;

  //  Group: Variables
  virtual alu_if vif;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s",
              get_full_name()), UVM_NONE)

    uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.m_agt_active*", "is_active", UVM_ACTIVE);
    uvm_config_db#(uvm_active_passive_enum)::set(this, "m_env.m_agt_passive*", "is_active", UVM_PASSIVE);

    m_env = alu_env::type_id::create("m_env", this);
    m_scbd = alu_scoreboard::type_id::create("m_scbd", this);

    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("TEST_IF", $sformatf("Unable to get vif for %s", get_full_name()))

    uvm_config_db#(virtual alu_if)::set(this, "m_env.m_agt*", "vif", vif);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s",
              get_full_name()), UVM_NONE)
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting connect_phase for %s", get_full_name()), UVM_NONE)

    m_env.m_agt_active.m_mon.mon_analysis_port.connect(m_scbd.imp_active);
    m_env.m_agt_passive.m_mon.mon_analysis_port.connect(m_scbd.imp_passive);

    `uvm_info("END_PHASE", $sformatf("Finishing connect_phase for %s", get_full_name()), UVM_NONE)
  endfunction: connect_phase

  task run_phase(uvm_phase phase);
    alu_seq seq;
    `uvm_info("START_PHASE", $sformatf("Starting run_phase for %s",
              get_full_name()), UVM_NONE)

    phase.raise_objection(this);
    `uvm_info(get_name(), "<run_phase> started, objection raised.", UVM_NONE)

    repeat(100) begin
      seq = alu_seq::type_id::create("seq");

      if (!seq.randomize())
        `uvm_fatal("TEST_RUN", $sformatf("Unable to randomize seq for %s", get_full_name()))

      seq.start(m_env.m_agt_active.m_seqr);
    end

    #50;

    // if (!seq.randomize()) begin
    //   `uvm_fatal("TEST_SEQ", $sformatf("Unable to randomize seq for %s", get_full_name()))
    //   seq.start(m_env.alu_agt_inputs.m_seqr);
    // end

    // #10ns;

    phase.drop_objection(this);
    `uvm_info(get_name(), "<run_phase> finished, objection dropped.", UVM_NONE)

    `uvm_info("END_PHASE", $sformatf("Finishing run_phase for %s",
              get_full_name()), UVM_NONE)
  endtask: run_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction: end_of_elaboration_phase

  //  Constructor: new
  function new(string name = "alu_test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

endclass: alu_test




