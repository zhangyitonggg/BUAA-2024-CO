`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
//adddress of three register
`define ASR     5'd12
`define ACAUSE  5'd13
`define AEPC    5'd14
//SR
//signal can block external interrupts
`define IM      SR[15:10]
//set true when exception occurs, prohibit interrupts.
`define EXL     SR[1]
//global interrupt enable
`define IE      SR[0]
//Cause
//is branch delay
`define BD      Cause[31]
//show 6 external interrupts.when not 0,no external interrupt
`define IP      Cause[15:10]
//exceptional code
`define ExcCode Cause[6:2]    
////////////////////////////////////////////////////////////////////
module CP0 (
    input wire clk,         
    input wire reset,
    
    input wire [4:0] addr,          //Register address
    input wire WE,                  //Write Enable
    input wire [31:0] WD,           //Write data
    
    input wire [31:0] pc,           //Victim PC
    input wire isBD,                //Is it a delay slot instruction
    input wire [4:0] ExcCode,       //exception type
    input wire [5:0] HWInt,         //Interrupt signal
    input wire EXLClr,              //Used to reset EXL,equals with eret

    output wire [31:0] RD,          //Read data
    output wire Req,                //Enter the processing program request
    output wire [31:0] EPCOUT       //EPC's value
    );
    //define register
    //The initial values are 0,the unimplemented bits always remain 0
    reg [31:0] SR;        //$12
    reg [31:0] Cause;     //$13
    reg [31:0] EPC;       //$14
    //Req
    wire [5:0] HWIM = HWInt & `IM;
    assign Req = (`EXL == 1'b0)&&((|ExcCode)||(`IE&&(|HWIM)));
    //RD
    assign RD = (addr === `ASR)    ? SR    : 
                (addr === `ACAUSE) ? Cause :
                (addr === `AEPC)   ? EPC   :
                32'h0011_4515;
    assign EPCOUT = EPC;
    //always
    always @(posedge clk) begin
        if (reset) begin        //reset
            SR <= `NINSTR;
            Cause <= `NINSTR;
            EPC <= `NINSTR;
        end
        else begin
            `IP <= HWInt;
            if (Req) begin     //interrupt 
                `EXL <= 1'b1;
                `ExcCode <= (`IE&&(|HWIM)) ? 5'd0 : ExcCode;
                `BD <= isBD;
                EPC <= (isBD) ?  (pc- 32'd4) : (pc);
            end
            else if (EXLClr) begin  //eret
                `EXL <= 1'b0;
            end
            else if (WE) begin      //mtc0 
                case (addr)  //Cause will not be written
                    `ASR: begin
                        `IM  <= WD[15:10];
                        `EXL <= WD[1];
                        `IE  <= WD[0];
                    end
                    `AEPC: begin
                        EPC <= WD;
                    end
                    default: Cause <= 32'h0011_4516;
                endcase
            end      
        end
    end
endmodule
