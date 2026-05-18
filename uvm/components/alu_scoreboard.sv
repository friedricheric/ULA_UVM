//  Class: alu_scoreboard
//
class alu_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(alu_scoreboard)

  //  Group: Components
  // uvm_analysis_imp_active #(alu_tx, alu_scoreboard) active_analysis_port;
  // uvm_analysis_imp_passive #(alu_tx, alu_scoreboard) passive_analysis_port;

  //  Group: Variables
  // string report_id;
  // alu_tx received_items[$];
  // alu_tx expected_items[$];

  alu_tx expected_items_q[$];
  alu_tx received_items_q[$];

  `uvm_analysis_imp_decl(_active)
  `uvm_analysis_imp_decl(_passive)

  uvm_analysis_imp_active #(alu_tx, alu_scoreboard) imp_active;
  uvm_analysis_imp_passive  #(alu_tx, alu_scoreboard) imp_passive;

  //  Group: Functions
  function void build_phase(uvm_phase phase);
    imp_active = new("imp_active", this);
    imp_passive = new("imp_passive", this);
  endfunction : build_phase

  function void write_active(alu_tx m_item);
    `uvm_info("ACTIVE_SCBD", $sformatf("Received item in write_active."), UVM_LOW)
    `uvm_info("ACTIVE_SCBD", $sformatf("%s", m_item.sprint()), UVM_FULL)

    m_item.data_op = ref_model(m_item);

    `uvm_info("ACTIVE_SCBD", $sformatf("Predicted item in write_active."), UVM_LOW)
    `uvm_info("ACTIVE_SCBD", $sformatf("%s", m_item.sprint()), UVM_FULL)

    expected_items_q.push_back(m_item);
    // // Description: processes the input data to the RTL, which comes from the active
    // //              monitor after checking the interface written by the active driver
    // string report_id;
    // alu_tx tmp_expected_item;
    // report_id = $sformatf("%s.write_active", this.report_id);
    // `uvm_info(report_id, $sformatf("Item received."), UVM_NONE)
    // `uvm_info(report_id, $sformatf("%s", item.sprint), UVM_MEDIUM)
  endfunction: write_active

  function void write_passive(alu_tx m_item);
    `uvm_info("PASSIVE_SCBD", $sformatf("Received item in write_passive."), UVM_LOW)
    `uvm_info("PASSIVE_SCBD", $sformatf("%s", m_item.sprint()), UVM_FULL)

    received_items_q.push_back(m_item);

    // // Description: processes the RTL's output data, which comes from the passive monitor
    // string report_id;

    // report_id = $sformatf("%s.write_passive", this.report_id);
    // `uvm_info(report_id, $sformatf("Item received."), UVM_NONE)
    // `uvm_info(report_id, $sformatf("%s", item.sprint), UVM_MEDIUM)
  endfunction: write_passive

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    `uvm_info("CHECK_SCBD", $sformatf("END!!!!"), UVM_NONE)

    foreach (expected_items_q[i]) begin
      if (expected_items_q[i].data_op != received_items_q[i].data_op) begin
        `uvm_error("ERROR_ALU", $sformatf("Error Alu - expected out: %0d != %0d :received out", expected_items_q[i].data_op, received_items_q[i].data_op))
        `uvm_error("Expected item", $sformatf("%s", expected_items_q[i].sprint()))
        `uvm_error("Received item", $sformatf("%s", received_items_q[i].sprint()))
      end else begin
        `uvm_info("SUCCESS_ALU", $sformatf("Success!"), UVM_NONE)
      end
    end

    // string report_id;
    // super.check_phase(phase);
    // report_id = $sformatf("%s.check_phase", this.report_id);
    // if (expected_items.size() != received_items.size()) begin
    //   `uvm_error(report_id,
    //              $sformatf({"Mismatch in the number of expected and received items.",
    //             "expected_items.size = %0d, received_items.size = %0d"},
    //             expected_items.size(), received_items.size()))
    // end
  endfunction: check_phase

  function bit [(`DATA_WIDTH*2 - 1):0] ref_model(alu_tx item);
    case (item.sel_ip)
      ALU_ADD  : ref_model = item.data_ip_1 + item.data_ip_2;
      ALU_SUB  : ref_model = item.data_ip_1 - item.data_ip_2;
      ALU_MULT : ref_model = item.data_ip_1 * item.data_ip_2;
      ALU_LSH  : ref_model = (item.data_ip_2 > `DATA_WIDTH) ? '0 : item.data_ip_1 << item.data_ip_2;
      ALU_RSH  : ref_model = (item.data_ip_2 > `DATA_WIDTH) ? '0 : item.data_ip_1 >> item.data_ip_2;
      ALU_INCR : ref_model = item.data_ip_1 + 1;
      ALU_DECR : ref_model = item.data_ip_1 - 1;
      default  : ref_model = '0;
    endcase
  endfunction: ref_model

  // function bit [(`CLASS_SIZE - 1):0] accel_output (accel_item m_item);
  //   //bit [(`CLASS_SIZE - 1):0] temp;

  //   `uvm_info("BIT", $sformatf("Feature: %h", m_item.features_i), UVM_LOW)

  //   ref_model(m_item.features_i, accel_output);

  //   `uvm_info("CLASS_O", $sformatf("Classe: %b", accel_output), UVM_LOW)

  //   //accel_output = temp;
  // endfunction : accel_output

  //  Constructor: new
  function new(string name = "alu_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction: new

endclass: alu_scoreboard
