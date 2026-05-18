//  Class: alu_cov_agent
//
class alu_cov_agent extends uvm_component;

  `uvm_component_utils(alu_cov_agent)

  //  Group: Analysis Ports
  `uvm_analysis_imp_decl(_active)
  `uvm_analysis_imp_decl(_passive)

  uvm_analysis_imp_active #(alu_tx, alu_cov_agent) imp_active;
  uvm_analysis_imp_passive #(alu_tx, alu_cov_agent) imp_passive;

  //  Group: Components

  //  Group: Variables
  alu_tx received_items_q[$];

  uvm_event evt_anything;

  //  Group: Covergroups
  //  Covergroup: cg_sel
  //  Verifica se todas as operacoes da ULA foram executadas e quantas vezes.
  covergroup cg_sel with function sample(alu_tx item);
    option.per_instance = 1;
    option.goal         = 100;

    //  Coverpoint: cp_sel_ip
    //  Um bin por operacao; ignore_bins descarta os codigos 3'b111 (invalido).
    cp_sel_ip: coverpoint item.sel_ip {
      bins add  = {ALU_ADD };
      bins sub  = {ALU_SUB };
      bins mult = {ALU_MULT};
      bins lsh  = {ALU_LSH };
      bins rsh  = {ALU_RSH };
      bins incr = {ALU_INCR};
      bins decr = {ALU_DECR};
      ignore_bins invalid = {3'b111};
    }
  endgroup: cg_sel

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    imp_active = new("imp_active", this);
    imp_passive = new("imp_passive", this);
  endfunction: build_phase

  function void write_active(alu_tx item);
    `uvm_info("COV_AGT",
              $sformatf("Item %0d received in cov_agent ACTIVE.", item.get_inst_id()),
              UVM_LOW)

    // sel_ip é capturado pelo monitor ativo; amostrar aqui garante a cobertura
    cg_sel.sample(item);

    evt_anything.trigger(item);
  endfunction: write_active

  function void write_passive(alu_tx item);
    `uvm_info("COV_AGT",
              $sformatf("Item %0d received in cov_agent PASSIVE.", item.get_inst_id()),
              UVM_LOW)
  endfunction: write_passive

  //  Constructor: new
  function new(string name = "alu_cov_agent", uvm_component parent);
    super.new(name, parent);

    cg_sel = new();

    evt_anything = uvm_event_pool::get_global("evt_anything");
  endfunction: new

endclass: alu_cov_agent
