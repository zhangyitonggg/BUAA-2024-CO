`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module MUX_32_2(
    input wire op,
    input wire [31:0] in0,
    input wire [31:0] in1,
    output wire [31:0] out
    );
    assign out = (op == 1'b0) ? in0 : in1;
endmodule

module MUX_5_4(
    input wire [1:0] op,
    input wire [4:0] in0,
    input wire [4:0] in1,
    input wire [4:0] in2,
    input wire [4:0] in3,
    output wire [4:0] out
    );
    assign out = (op == 2'b00) ? in0 :
                 (op == 2'b01) ? in1 :
                 (op == 2'b10) ? in2 :
                 in3;
endmodule

module MUX_32_4(
    input wire [1:0] op,
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [31:0] in3,
   
    output wire [31:0] out
    );
    assign out = (op == 2'b00) ? in0 :
                 (op == 2'b01) ? in1 :
                 (op == 2'b10) ? in2 :
                 in3;
endmodule

module MUX_32_8(
    input wire [2:0] op,
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [31:0] in3,
    input wire [31:0] in4,
    input wire [31:0] in5,
    input wire [31:0] in6,
    input wire [31:0] in7,
    output wire [31:0] out
    );
    assign out = (op == 3'b000) ? in0 :
                 (op == 3'b001) ? in1 :
                 (op == 3'b010) ? in2 :
                 (op == 3'b011) ? in3 :
                 (op == 3'b100) ? in4 :
                 (op == 3'b101) ? in5 :
                 (op == 3'b110) ? in6 :
                 in7;
endmodule

module MUX_32_16(
    input wire [3:0] op,
    input wire [31:0] in0,
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [31:0] in3,
    input wire [31:0] in4,
    input wire [31:0] in5,
    input wire [31:0] in6,
    input wire [31:0] in7,
    input wire [31:0] in8,
    input wire [31:0] in9,
    input wire [31:0] in10,
    input wire [31:0] in11,
    input wire [31:0] in12,
    input wire [31:0] in13,
    input wire [31:0] in14,
    input wire [31:0] in15,
    output wire [31:0] out
    );
    assign out = (op == 4'd0) ? in0 :
                 (op == 4'd1) ? in1 :
                 (op == 4'd2) ? in2 :
                 (op == 4'd3) ? in3 :
                 (op == 4'd4) ? in4 :
                 (op == 4'd5) ? in5 :
                 (op == 4'd6) ? in6 :
                 (op == 4'd7) ? in7 :
                 (op == 4'd8) ? in8 :
                 (op == 4'd9) ? in9 :
                 (op == 4'd10) ? in10 :
                 (op == 4'd11) ? in11 :
                 (op == 4'd12) ? in12 :
                 (op == 4'd13) ? in13 :
                 (op == 4'd14) ? in14 :
                 in15;
endmodule