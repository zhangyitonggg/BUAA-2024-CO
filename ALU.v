`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module ALU(
    input wire [4:0] op,             
    input wire [31:0] in1,
    input wire [31:0] in2,
    input wire [4:0] in3,         
    input wire [2:0] alu_find,

    output reg [31:0] ans,       
    output wire equalZero,    
    output wire E_Ov,
    output wire E_AdEL,
    output wire E_AdES
    );
    reg [32:0]temp_ans;
    wire overflow = (temp_ans[32] != temp_ans[31]);
    assign E_Ov = (alu_find === 3'd1) ? overflow : 1'd0;
    assign E_AdEL = (alu_find === 3'd2) ? overflow : 1'd0;
    assign E_AdES = (alu_find === 3'd3) ? overflow : 1'd0;
    always @(*) begin
        case (op)
            `ALUADD: begin
                ans = in1 + in2;
                temp_ans = {{in1[31]},{in1}} + {{in2[31]},{in2}};
            end   
            `ALUSUB: begin
                ans = in1 - in2;
                temp_ans = {{in1[31]},{in1}} - {{in2[31]},{in2}};
            end
            `ALUAND:   ans = in1 & in2;
            `ALUOR:    ans = in1 | in2;
            `ALUSLL:   ans = in2 << in3;
            `ALUSLT: begin
                if ($signed(in1) < $signed(in2)) ans = 32'd1;
                else ans = 32'd0;
            end
            `ALUSLTU: begin
                if (in1 < in2) ans = 32'd1;
                else ans = 32'd0;
            end
            default:   ans = 32'h0011_4514;  //add; 
        endcase
    end
    // equalZero
    assign equalZero = (ans == 32'h0000_0000) ? 1'b1 : 1'b0;
endmodule
/*
    function signed [1:0] ADD;
        input A,B,CIN;
        
        reg S,COUT;

        begin
            S = A ^ B ^CIN;
            COUT = (A&B) | (A&CIN) | (B&CIN);
            ADD = {COUT,S};
        end
    endfunction 

    assign S0 = ADD (A[0], B[0], CIN);
    */