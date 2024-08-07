`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module NPC(
    input wire [2:0] op,
    input wire jump,
    input wire [31:0] F_pc,
    input wire [31:0] nowPC,
    input wire [15:0] immNum16,
    input wire [25:0] immNum26,
    input wire [31:0] regDate,
    
    output reg [31:0] nextPC
    );
    always @(*) begin
        case (op)
            `NPCCOM: nextPC = F_pc + 32'd4;
            `NPCBR: begin
                if (jump == `TRUE) nextPC = nowPC + 32'd4 + {{14{immNum16[15]}},immNum16,{2'b00}};
                else nextPC = F_pc + 32'd4;
            end 
            `NPCJAL:  nextPC = {{nowPC[31:28]},{immNum26},{2'b00}};
            `NPCJR: nextPC = regDate;
            default: nextPC = nowPC;
        endcase
    end
endmodule
