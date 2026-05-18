//  Class: alu_driver
//
class alu_driver extends uvm_driver #(alu_tx);
  `uvm_component_utils(alu_driver)

  //  Group: Components
  virtual alu_if vif;

  //  Group: Variables
  uvm_active_passive_enum is_active;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting build_phase for %s",
              get_full_name()), UVM_NONE)

    if (!uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active))
      `uvm_fatal("DRV_BUILD", $sformatf("Error to get is_active for %s", get_full_name))

    if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV_BUILD", $sformatf("Error to get vif for %s", get_full_name))

    `uvm_info("END_PHASE", $sformatf("Finishing build_phase for %s",
              get_full_name()), UVM_NONE)
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("START_PHASE", $sformatf("Starting run_phase for %s",
              get_full_name()), UVM_NONE)

    if (is_active == UVM_ACTIVE) begin
      initial_rst();

      forever begin
      	seq_item_port.get_next_item(req);

        drive_item_active(req);

      	seq_item_port.item_done();
      end
    end else begin
      forever
      	drive_item_passive();
    end

    `uvm_info("END_PHASE", $sformatf("Finishing run_phase for %s",
              get_full_name()), UVM_NONE)
  endtask: run_phase

  task initial_rst();
    vif.rst <= 1'b1;
    vif.data_ip_1 <= 'b0;
    vif.data_ip_2 <= 'b0;
    vif.sel_ip <= 'b0;
    vif.valid_ip <= 'b0;

    repeat (5)
      @(posedge vif.clk);

    vif.rst <= 1'b0;
  endtask : initial_rst

  task drive_item_active(alu_tx req);
    @(posedge vif.clk);
    vif.data_ip_1 <= req.data_ip_1;
    vif.data_ip_2 <= req.data_ip_2;
    vif.sel_ip 	  <= req.sel_ip;
    vif.valid_ip <= 1'b1;

    `uvm_info("DRV_RUN_ITEM", $sformatf("Sending item from drive"), UVM_NONE)

    while(vif.ready_op == 1'b0)
      @(posedge vif.clk);

    vif.valid_ip <= 1'b0;
  endtask : drive_item_active

  task drive_item_passive();
    @(negedge vif.clk);
    vif.ready_ip <= 1'b0;

    while(vif.valid_op == 0)
      @(posedge vif.clk);

    vif.ready_ip <= 1'b1;
  endtask : drive_item_passive

  //  Constructor: new
  function new(string name = "alu_driver", uvm_component parent);
    super.new(name, parent);
  endfunction: new

endclass: alu_driver
