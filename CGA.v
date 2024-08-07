`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
//calcuale GRF's A1,A2,A3
module CGA(
    //input
    input wire [31:0] inStr,
    input wire [1:0] op,
    input wire jump,
    //output 
    output wire [4:0] A1,
    output wire [4:0] A2,
    output wire [4:0] A3
    );
    //A1
    assign A1 = inStr[25:21];
    //A2
    assign A2 = inStr[20:16];
    //A3
    assign A3 = (op == 2'b00) ? inStr[20:16] : //rt
                (op == 2'b01) ? inStr[15:11] : //rd
                (op == 2'b10) ? 5'd31 :        //ra
                5'd00;                                        
endmodule
