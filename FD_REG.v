`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module FD_REG(
    input wire clk,
    input wire reset,
    input wire block,
    input wire [31:0] F_inStr,
    input wire [31:0] F_pc,
    input wire [4:0] F_ExcCode,
    input wire Req,
    input wire F_isBD,
    input wire D_eret,

    output reg [31:0] D_inStr,
    output reg [31:0] D_pc,
    output reg [4:0] D_ExcCode,
    output reg D_isBD
    );
    always @(posedge clk) begin
        if (reset || Req || (!block && D_eret)) begin
            D_inStr <= 32'h0000_0000;
            D_pc <= (Req) ? `EXCPC : 32'b0;
            D_ExcCode <= `EXCNO;
            D_isBD <= 1'b0;
        end
        else begin
            if (block == `TRUE) begin
                D_inStr <= D_inStr;
                D_pc <= D_pc;
                D_ExcCode <= D_ExcCode;
                D_isBD <= D_isBD;
            end
            else begin
                D_inStr <= F_inStr;
                D_pc <= F_pc;
                D_ExcCode <= F_ExcCode;
                D_isBD <= F_isBD;
            end
        end
    end
endmodule
