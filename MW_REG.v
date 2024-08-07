`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module MW_REG(
    input wire clk,
    input wire reset,
    input wire [31:0] M_inStr,
    input wire [31:0] M_pc, 
    input wire [31:0] M_ALU_ans,
    input wire [31:0] M_MD_date,
    input wire [31:0] M_DM_RD,
    input wire [31:0] M_CP0_RD,
    input wire [1:0] M_tnew,
    input wire M_jump,
    input wire Req,

    output reg [31:0] W_inStr,
    output reg [31:0] W_pc,
    output reg [31:0] W_ALU_ans,
    output reg [31:0] W_MD_date,
    output reg [31:0] W_DM_RD,
    output reg [31:0] W_CP0_RD,
    output reg [1:0] W_tnew,
    output reg W_jump
    );
    always @(posedge clk) begin
        if (reset || Req) begin
            W_inStr <= 32'h0000_0000;
            W_pc <= (Req)? `EXCPC:32'b0;
            W_ALU_ans <= 32'h0000_0000;
            W_MD_date <= 32'h0000_0000;
            W_DM_RD <= 32'h0000_0000;
            W_CP0_RD <= 32'h0000_0000;
            W_tnew <= 2'd0;
            W_jump <= 1'b0;
        end
        else begin
            W_inStr <= M_inStr;
            W_pc <= M_pc;
            W_ALU_ans <= M_ALU_ans;
            W_MD_date <= M_MD_date;
            W_DM_RD <= M_DM_RD;
            W_CP0_RD <= M_CP0_RD;
            W_jump <= M_jump;
            if (M_tnew == 2'd0) begin
                W_tnew <= M_tnew;
            end
            else begin
                W_tnew <= M_tnew - 2'd1;
            end
        end
    end
endmodule
