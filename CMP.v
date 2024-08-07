`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module CMP(
    input wire [2:0] op,
    input wire [31:0] in0,
    input wire [31:0] in1,

    output reg jump //if jump == 1,jump;else,not
    );
    always @(*) begin
        case (op) 
            `CMPBEQ: begin
                if (in0 == in1) jump = `TRUE;
                else jump = `FALSE;
            end
            `CMPBNE: begin
                if (in0 != in1) jump = `TRUE;
                else jump = `FALSE;
            end
            default: jump = `FALSE;
        endcase
    end
endmodule
