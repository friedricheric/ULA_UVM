//  Module: top_tb
`timescale 1ns / 1ps

`include "uvm_macros.svh"
`include "alu_if.sv"

module top_tb;
  /*  package imports  */
  import uvm_pkg::*;
  import alu_pkg::*;

  logic clk;

  alu_if #(.DATA_WIDTH (`DATA_WIDTH), .SEL_WIDTH (`SEL_WIDTH))
     dut_if (.clk (clk));

  alu_top #(
    .DATA_WIDTH (`DATA_WIDTH),
    .SEL_WIDTH  (`SEL_WIDTH)
  ) dut (
    // Control Signals
    .clk        (dut_if.clk),
    .rst        (dut_if.rst),
    // Input Signals
    .valid_ip   (dut_if.valid_ip),
    .ready_ip   (dut_if.ready_ip),
    .data_ip_1  (dut_if.data_ip_1),
    .data_ip_2  (dut_if.data_ip_2),
    .sel_ip     (dut_if.sel_ip),
    // Output Signals
    .valid_op   (dut_if.valid_op),
    .ready_op   (dut_if.ready_op),
    .data_op    (dut_if.data_op)
  );

  initial begin
    clk = 1'b0;
    forever #2 clk = ~clk;
  end

  initial begin
    uvm_config_db#(virtual alu_if)::set(null, "uvm_test_top", "vif", dut_if);
    run_test("alu_test");
  end
endmodule: top_tb

