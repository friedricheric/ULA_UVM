`ifndef alu_if__sv
`define alu_if__sv

`timescale 1ns / 1ps

// Interface: alu_if
interface alu_if  #(
    parameter DATA_WIDTH  = 8,
    parameter SEL_WIDTH   = 3
  )(
    input clk
  );

  logic 						            rst;
  logic                         valid_ip, ready_ip;
  logic [(DATA_WIDTH - 1): 0]	  data_ip_1;
  logic [(DATA_WIDTH - 1): 0]	  data_ip_2;
  logic [(SEL_WIDTH - 1): 0]	  sel_ip;
  logic [((DATA_WIDTH*2)-1):0]  data_op;
  logic                         valid_op, ready_op;

endinterface : alu_if

`endif
