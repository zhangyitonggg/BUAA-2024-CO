`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module DE_REG(
    input wire clk,
    input wire reset,
    input wire block,
    input wire [31:0] D_inStr,
    input wire [31:0] D_pc,
    input wire [31:0] D_GRF_RD1,
    input wire [31:0] D_GRF_RD2,
    input wire [31:0] D_EXT_ans,
    input wire D_jump,
    input wire [4:0] D_ExcCode,
    input wire Req,
    input wire D_isBD,

    output reg [31:0] E_inStr,
    output reg [31:0] E_pc,
    output reg [31:0] E_GRF_RD1,
    output reg [31:0] E_GRF_RD2,
    output reg [31:0] E_EXT_ans,
    output reg E_jump,
    output reg [4:0] E_ExcCode,
    output reg E_isBD
    );
    always @(posedge clk) begin
        if (reset || Req ||block) begin
            E_inStr <= 32'h0000_0000;
            E_pc <= (reset) ? 32'b0 :
                    (Req)   ? `EXCPC  :
                    (block) ? D_pc    :
                    32'h0011_4514;
            E_isBD <= (block) ? D_isBD : 1'b0;
            E_GRF_RD1 <= 32'h0000_0000;
            E_GRF_RD2 <= 32'h0000_0000;
            E_EXT_ans <= 32'h0000_0000;
            E_jump <= 1'b0;
            E_ExcCode <= `EXCNO;
        end
        else begin
            E_inStr <= D_inStr;
            E_pc <= D_pc;
            E_isBD <= D_isBD;
            E_GRF_RD1 <= D_GRF_RD1;
            E_GRF_RD2 <= D_GRF_RD2;
            E_EXT_ans <= D_EXT_ans;
            E_jump <= D_jump; 
            E_ExcCode <= D_ExcCode;
        end
    end
    
endmodule
