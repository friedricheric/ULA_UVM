//  Package: alu_pkg
//
`timescale 1ns / 1ps

package alu_pkg;

  // Group UVM
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Group: Defines/Macros
  `define DATA_WIDTH 8
  `define SEL_WIDTH 3

  //  Group: Typedefs

  //  Group: Includes
  `include "alu_if.sv"

  // Objects
  `include "alu_tx.sv"
  `include "alu_seq.sv"

  // Components
  `include "alu_sequencer.sv"
  `include "alu_driver.sv"
  `include "alu_monitor.sv"
  `include "alu_agent.sv"
  // `include "alu_cov_agent.sv"
  `include "alu_env.sv"
  `include "alu_scoreboard.sv"
  `include "alu_test.sv"

endpackage: alu_pkg
