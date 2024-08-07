`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
//grf is also reg!!!
module WSTAGE (
    //from MW_REG
    input wire [31:0] W_inStr_in,
    input wire [31:0] W_pc_in,
    input wire [31:0] W_ALU_ans,
    input wire [31:0] W_MD_date,
    input wire [31:0] W_DM_RD,
    input wire [31:0] W_CP0_RD,
    input wire [1:0] W_tnew_in,  //always zero
    input wire W_jump_in,
    
    //to HCU
    output wire [1:0]W_tnew_out,
    output wire W_GRF_WE, 
    output wire [4:0] W_GRF_A3, 
    //write back
    output wire [31:0] W_pc_out,
    output wire [31:0]W_GRF_WD,
    //to before
    output wire [31:0] W_give //always equals with W_GRF_WD
    );
    //DECODER
    wire [1:0] grf_A3_sel;
    wire [2:0] grf_wd_sel;
    DECODER W_cu (
        //input
        .op(W_inStr_in[31:26]),
        .fc(W_inStr_in[5:0]),
        .inStr(W_inStr_in),
        //output
        .grf_write(W_GRF_WE),
        .grf_A3_sel(grf_A3_sel),
        .grf_wd_sel(grf_wd_sel)
    );
    //write back
    assign W_pc_out = W_pc_in;
    CGA W_cga (
        //input
        .inStr(W_inStr_in),
        .op(grf_A3_sel),
        .jump(W_jump_in),
        //output
        .A3(W_GRF_A3)
    ); 
    wire [31:0] pc_add8 = W_pc_in + 32'd8;
    assign W_GRF_WD = (grf_wd_sel == `GWDALU) ? W_ALU_ans : 
                      (grf_wd_sel == `GWDDM)  ? W_DM_RD   :
                      (grf_wd_sel == `GWDPC)  ? pc_add8   :
                      (grf_wd_sel == `GWDMD)  ? W_MD_date :
                      (grf_wd_sel == `GWDCP0) ? W_CP0_RD  :
                      32'h00114514; 
    //else output
    assign W_tnew_out = W_tnew_in;
    assign W_give = W_GRF_WD;
endmodule
