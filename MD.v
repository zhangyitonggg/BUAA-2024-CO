`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module MD (
    //input 
    input wire clk,
    input wire reset,
    input wire [3:0]cop,   //cal
    input wire start,      
    input wire [3:0]wop,   //write
    input wire rop,        //read
    input wire [31:0]in1,
    input wire [31:0]in2,
    input wire Req,
    //output 
    output wire [31:0] date,
    output reg [3:0] busy 
    );
    //define HI & LO 
    reg [31:0] HI;
    reg [31:0] LO;
    
    reg [31:0] tHI;
    reg [31:0] tLO;
    integer cnt;
    //read
    assign date = (rop == 1'b0) ? HI : LO;
    
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            busy <= 4'd0;
            HI <= 32'd0;
            LO <= 32'd0;
            tHI <= 32'd0;
            tLO <= 32'd0;
            cnt <= 0;
        end
        else begin
            //write
            if (wop == `MDTHI && !Req) begin
                HI <= in1;
            end
            else if (wop == `MDTLO && !Req) begin
                LO <= in1;
            end
            else begin
                HI <= HI;
                LO <= LO;
            end
            //cal
            if (start == 1'b1 && !Req) begin
                //get busy
                busy <= 1'b1;
                //get cnt
                if (cop == `MDCM) cnt <= 5;
                else if (cop == `MDCMU) cnt <= 5;
                else if (cop == `MDCD) cnt <= 10;
                else if (cop == `MDCDU) cnt <= 10;
                else cnt <= 777;
                //precal
                if (cop == `MDCM) {tHI,tLO} <= $signed(in1) * $signed(in2); 
                else if (cop == `MDCMU) {tHI,tLO} <= in1 * in2;
                else if (cop == `MDCD) begin
                    tHI <= $signed(in1) % $signed(in2);  //yushu
                    tLO <= $signed(in1) / $signed(in2);  //shang
                end
                else if (cop == `MDCDU) begin
                    tHI <= in1 % in2;  //yushu
                    tLO <= in1 / in2;  //shang
                end
                else cnt <= -1;
            end
            else if (cnt >= 2) begin
                cnt <= cnt - 1;
            end
            else if (cnt == 1) begin
                HI <= tHI;
                LO <= tLO;
                cnt <= 0;
                busy <= 1'b0;
            end
            else cnt <= 0;
        end
    end
endmodule
