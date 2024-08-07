`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module EM_REG(
    input wire clk,
    input wire reset,
    input wire [31:0] E_inStr,
    input wire [31:0] E_pc,
    input wire [31:0] E_ALU_ans,
    input wire [31:0] E_MD_date,
    input wire [31:0] E_GRF_RD2,
    input wire [1:0] E_tnew,
    input wire E_jump,
    input wire [4:0] E_ExcCode,
    input wire Req,
    input wire E_isBD,
 
    output reg [31:0] M_inStr,
    output reg [31:0] M_pc,
    output reg [31:0] M_ALU_ans,
    output reg [31:0] M_MD_date,
    output reg [31:0] M_GRF_RD2,
    output reg [1:0] M_tnew,
    output reg M_jump,
    output reg [4:0] M_ExcCode,
    output reg M_isBD
    );
    always @(posedge clk) begin
        if (reset || Req) begin
            M_inStr <= 32'h0000_0000;
            M_pc <= (Req)?`EXCPC:32'b0;
            M_ALU_ans <= 32'h0000_0000;
            M_MD_date <= 32'h0000_0000;
            M_GRF_RD2 <= 32'h0000_0000;
            M_tnew <= 2'd0;
            M_jump <= 1'b0;
            M_ExcCode <= `EXCNO;
            M_isBD <= 1'b0;
        end
        else begin
            M_inStr <= E_inStr;
            M_pc <= E_pc;
            M_ALU_ans <= E_ALU_ans;
            M_MD_date <= E_MD_date;
            M_GRF_RD2 <= E_GRF_RD2;
            M_jump <= E_jump;
            M_ExcCode <= E_ExcCode;
            M_isBD <= E_isBD;
            if (E_tnew == 2'd0) begin
                M_tnew <= E_tnew;
            end
            else begin
                M_tnew <= E_tnew - 2'd1;
            end
        end
    end
endmodule
