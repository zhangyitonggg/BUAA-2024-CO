`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module EXT(
    input wire [2:0] op,
    input wire [15:0] in,
    
    output reg [31:0] ans
    );
    always @(*) begin
        case (op)
            //3'b000
            `EXTZERO: ans = {{16'h0000},in};
            //3'b001
            `EXTSIGN: ans = {{16{in[15]}},in};
            //3'b010
            `EXTLUI:  ans = {in,{16'h0000}};
            default: ans = 32'h0011_4514;
        endcase
    end
endmodule
