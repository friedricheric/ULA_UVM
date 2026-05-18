//  Class: alu_monitor
//
class alu_monitor extends uvm_monitor;

  `uvm_component_utils(alu_monitor)

  //  Group: Components
  virtual alu_if vif;

  //  Group: Variables
  uvm_analysis_port #(alu_tx) mon_analysis_port;
  uvm_active_passive_enum is_active;

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s", get_full_name()), UVM_NONE)

    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON_IF", $sformatf("Error to get vif for %s", 												 get_full_name))

    if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
      `uvm_fatal("MON_BUILD", $sformatf("Error to get is_active for %s", get_full_name))

    mon_analysis_port = new("mon_analysis_port", this);

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s",
              get_full_name()), UVM_NONE)
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    //if (m_cfg.master_slave == VIP_MASTER)
    if (is_active == UVM_ACTIVE)
      active_mon();
    else
      passive_mon();
  endtask: run_phase

  task active_mon();
    alu_tx m_item;
    `uvm_info("MON_ACTIVE", "Starting monitor ACTIVE", UVM_NONE)

    forever begin
      @(posedge vif.clk);

      if(vif.valid_ip == 1'b1 && vif.ready_op == 1'b1 && vif.rst == 1'b0) begin
        m_item = alu_tx::type_id::create("input_item");

        m_item.data_ip_1 = vif.data_ip_1;
        m_item.data_ip_2 = vif.data_ip_2;
        $cast(m_item.sel_ip, vif.sel_ip);
        m_item.timestamp  = $realtime();

        `uvm_info("MON_ACTIVE", "Monitor captured INPUT item.", UVM_MEDIUM)
        `uvm_info("MON_ACTIVE", $sformatf("%s", m_item.sprint()), UVM_FULL)

        mon_analysis_port.write(m_item);
        @(posedge vif.clk);
      end
    end
  endtask : active_mon

  task passive_mon();
    alu_tx m_item;
    `uvm_info("MON_PASSIVE", "Starting monitor PASSIVE", UVM_NONE)

    forever begin
      @(posedge vif.clk);

      if(vif.valid_op == 1'b1 && vif.rst == 1'b0) begin
        m_item = alu_tx::type_id::create("output_item");

        m_item.data_op = vif.data_op;

        `uvm_info("MON_PASSIVE", "Monitor captured OUTPUT item.", UVM_MEDIUM)
        `uvm_info("MON_PASSIVE", $sformatf("%s", m_item.sprint()), UVM_FULL)

        mon_analysis_port.write(m_item);
        @(posedge vif.clk);
      end
    end
  endtask : passive_mon

  //  Constructor: new
  function new(string name = "alu_monitor", uvm_component parent);
    super.new(name, parent);
  endfunction: new

endclass: alu_monitor




