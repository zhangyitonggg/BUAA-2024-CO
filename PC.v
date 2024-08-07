`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module PC(
    input wire clk,
    input wire reset,
    input wire block,
    input wire [31:0]nextPC,
    input wire Req,           //from CP0
    input wire [31:0] EPC,
    input wire D_eret,
    
    output reg [31:0]nowPC 
    );
    initial begin
        nowPC = `INITPC;
    end
    //get nowPC
    always @(posedge clk) begin
        if (reset == `TRUE) begin
            nowPC <= `INITPC;
        end
        else if (Req === `TRUE) begin
            nowPC <= `EXCPC;
        end
        else if (block == `TRUE) begin
            nowPC <= nowPC;
        end
        else if (D_eret === `TRUE) begin
            nowPC <= EPC;
        end
        else begin
            nowPC <= nextPC;
        end
    end
endmodule
