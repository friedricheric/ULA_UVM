//  Module: alu_core
//
`timescale 1ns / 1ps

module alu_core
  #(
    parameter DATA_WIDTH  = 8,
    parameter SEL_WIDTH   = 3
  )(
    input       [(DATA_WIDTH-1):0 ]     data_ip_1,
    input       [(DATA_WIDTH-1):0 ]     data_ip_2,
    input       [(SEL_WIDTH-1):0  ]     sel_ip,
    output wire [((DATA_WIDTH*2)-1):0]  data_op
  );

  assign data_op  = (sel_ip == 3'b000) ? data_ip_1 + data_ip_2 :                                    // ALU_ADD
                    (sel_ip == 3'b001) ? data_ip_1 - data_ip_2 :                                    // ALU_SUB
                    (sel_ip == 3'b010) ? data_ip_1 * data_ip_2 :                                    // ALU_MULT
                    (sel_ip == 3'b011) ? (data_ip_2 > DATA_WIDTH ? 'd0 : data_ip_1 << data_ip_2) :  // ALU_LSH
                    (sel_ip == 3'b100) ? (data_ip_2 > DATA_WIDTH ? 'd0 : data_ip_1 >> data_ip_2) :  // ALU_RSH
                    (sel_ip == 3'b101) ? data_ip_1 + 'd1 :                                          // ALU_INCR
                    (sel_ip == 3'b110) ? data_ip_1 - 'd1 :                                          // ALU_DECR
                    'd0;
endmodule: alu_core
