//  Class: alu_env
//
class alu_env extends uvm_env;

  `uvm_component_utils(alu_env)

  //  Group: Components
  alu_agent 	  m_agt_active;
  alu_agent 	  m_agt_passive;

  alu_cov_agent m_cov_agent;

  //  Group: Variables

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s",
              get_full_name()), UVM_NONE)

    m_agt_active  = alu_agent::type_id::create("m_agt_active", this);
    m_agt_passive = alu_agent::type_id::create("m_agt_passive", this);

    m_cov_agent = alu_cov_agent::type_id::create("m_cov_agent", this);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s",
              get_full_name()), UVM_NONE)
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting connect_phase for %s",
              get_full_name()), UVM_NONE)

    // Monitor ativo captura sel_ip + data_ip_* → alimenta cobertura
    m_agt_active.m_mon.mon_analysis_port.connect(m_cov_agent.imp_active);

    // Monitor passivo captura data_op → alimenta cobertura (sem sel_ip)
    m_agt_passive.m_mon.mon_analysis_port.connect(m_cov_agent.imp_passive);

    `uvm_info("END_PHASE", $sformatf("Finishing connect_phase for %s",
              get_full_name()), UVM_NONE)
  endfunction: connect_phase

  //  Constructor: new
  function new(string name = "alu_env", uvm_component parent);
    super.new(name, parent);
  endfunction: new

endclass: alu_env
