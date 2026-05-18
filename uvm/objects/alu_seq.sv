//  Class: alu_seq
//
class alu_seq extends uvm_sequence;

  `uvm_object_utils(alu_seq)

  //  Group: Variables
  string report_id;

  int num_samples = 10;

  //  Group: Functions
  task body();
    alu_tx m_item;

    string report_id = $sformatf("%s.body", this.report_id);

    `uvm_info(report_id, $sformatf("Started sequence %s", this.get_full_name()), UVM_MEDIUM)

    //repeat(10) begin
    m_item = alu_tx::type_id::create("m_item");

    start_item(m_item);

    if (!m_item.randomize())
      `uvm_fatal("SEQ_RAND", $sformatf("Unable to randomize for %s",
                get_full_name()))

    m_item.timestamp = $realtime();

    `uvm_info(report_id, $sformatf("Randomized m_item for '%s'.", this.get_full_name()), UVM_MEDIUM)
    `uvm_info(report_id, $sformatf("Randomized item: \n %s", m_item.sprint()), UVM_FULL)

    finish_item(m_item);

    `uvm_info(report_id, $sformatf("Finished sequence '%s'.", this.get_full_name()), UVM_MEDIUM)
  endtask : body

  //  Constructor: new
  function new(string name = "alu_seq");
    super.new(name);

    report_id = name;
  endfunction: new

endclass: alu_seq
