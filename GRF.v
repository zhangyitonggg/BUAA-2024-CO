`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
//D && W !!!
//internal forward !!!
module GRF(
    input wire clk,
    input wire reset,
    input wire [31:0] pc,
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire[4:0] A3,
    input wire WE,
    input wire [31:0] WD,

    output reg [31:0] RD1,
    output reg [31:0] RD2
    );
    //define
    reg [31:0] grf [0:31]; //registers
    integer i = 0;
    //init
    initial begin
        for (i = 0;i < 32;i = i + 1) begin
            grf[i] = 32'd0;
        end
    end
    //read
    always @(*) begin
        if (WE == `TRUE && A1 == A3 && A1 != 5'd0) begin
            RD1 = WD;
        end
        else begin
            RD1 = grf[A1];
        end
        if (WE == `TRUE && A2 == A3 && A2 != 5'd0) begin
            RD2 = WD;
        end
        else begin
            RD2 = grf[A2];
        end
    end
    //write
    always @(posedge clk) begin
        if (reset == `TRUE) begin
            for (i = 0;i < 32;i = i + 1) begin
                grf[i] <= 32'd0;
            end
        end
        else begin
            if (WE == `TRUE && A3 != 5'b0) begin
                grf[A3] <= WD;
            end
            else begin
                grf[A3] <= grf[A3];
            end
        end
    end
endmodule
