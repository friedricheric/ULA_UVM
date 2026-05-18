//  Class: alu_agent
//
class alu_agent extends uvm_agent;
  `uvm_component_utils(alu_agent)

  //  Group: Components
  alu_sequencer   m_seqr;
  alu_driver      m_drv;
  alu_monitor     m_mon;

  //  Group: Variables
  uvm_active_passive_enum is_active;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s",
              get_full_name()), UVM_NONE)

    if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
      `uvm_fatal("AGT_BUILD", $sformatf("Error to get is_active for %s", get_full_name))

    if (is_active == UVM_ACTIVE) begin
      m_seqr  = alu_sequencer::type_id::create("m_seqr", this);
    end

    m_drv   = alu_driver::type_id::create("m_drv" , this);
    m_mon     = alu_monitor::type_id::create("m_mon", this);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s",
              get_full_name()), UVM_NONE)
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting connect_phase for %s",
              get_full_name()), UVM_NONE)

    if (is_active == UVM_ACTIVE)
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);

    `uvm_info("END_PHASE", $sformatf("Finishing connect_phase for %s",
              get_full_name()), UVM_NONE)
  endfunction: connect_phase

  //  Constructor: new
  function new(string name = "alu_agent", uvm_component parent);
    super.new(name, parent);
  endfunction: new

endclass: alu_agent
