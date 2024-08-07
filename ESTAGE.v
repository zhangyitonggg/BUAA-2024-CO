`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module ESTAGE (
    //from mips
    input wire clk,
    input wire reset,
    //from DE_REG
    input wire [31:0] E_inStr_in,
    input wire [31:0] E_pc_in,
    input wire [31:0] E_GRF_RD1,
    input wire [31:0] E_GRF_RD2,
    input wire [31:0] E_EXT_ans,
    input wire E_jump_in,
    //from HCU
    input wire [2:0] E_ALU_in1_FWD, 
    input wire [2:0] E_ALU_in2_FWD, 
    //from forwardfing
    input wire [31:0] E_ALU_in1_M,
    input wire [31:0] E_ALU_in1_W,
    input wire [31:0] E_ALU_in2_M,
    input wire [31:0] E_ALU_in2_W,
    //p7 
    input wire [4:0] E_ExcCode_in,
    input wire M_Req,

    //to HCU
    output wire [1:0] E_tnew,     
    output wire E_GRF_WE,         
    output wire [4:0] E_GRF_A1,   
    output wire [4:0] E_GRF_A2,   
    output wire [4:0] E_GRF_A3, 
    output wire [3:0] E_MD_busy,
    output wire E_MD_start,
    output wire E_CP0_WE,
    //to before
    output wire [31:0] E_give,
    //to EM_REG
    output wire [31:0] E_inStr_out,
    output wire [31:0] E_pc_out,
    output wire [31:0] E_ALU_ans,
    output wire [31:0] E_MD_date,
    output wire [31:0] E_GRF_MUX_RD2,  // !!!    
    output wire E_jump_out,
    //p7
    output wire [4:0] E_ExcCode_out
    );
    //EXC
    wire E_Ov;
    wire E_AdEL;
    wire E_AdES;
    assign E_ExcCode_out = (E_ExcCode_in) ? E_ExcCode_in : 
                           (E_Ov)         ? `EXCOV       :
                           (E_AdEL)       ? `EXCADEL     :
                           (E_AdES)       ? `EXCADES     : //!!!
                           E_ExcCode_in;
    //DECODER
    wire alu_in2_sel;
    wire [4:0] alu_op;
    wire [3:0] md_cop;
    wire [3:0] md_wop;
    wire  md_rop;
    wire grf_write;
    wire [1:0] grf_A3_sel;
    wire [2:0] E_give_sel;
    wire [2:0] alu_find;
    DECODER E_cu (
        //input
        .op(E_inStr_in[31:26]),
        .fc(E_inStr_in[5:0]),   
        .inStr(E_inStr_in),
        //output
        .alu_in2_sel(alu_in2_sel),
        .alu_op(alu_op),
        .md_cop(md_cop),
        .md_start(E_MD_start),
        .md_wop(md_wop),
        .md_rop(md_rop),
        .grf_write(E_GRF_WE),
        .grf_A3_sel(grf_A3_sel),
        .E_tnew(E_tnew),
        .E_give_sel(E_give_sel),
        .alu_find(alu_find),
        .CP0_WE(E_CP0_WE)
    );
    //give back
    wire [31:0] pc_add8 = E_pc_in + 32'd8;
    MUX_32_8 E_mux_give (
        //input
        .op(E_give_sel),
        .in0(E_EXT_ans),
        .in1(pc_add8),
        //output
        .out(E_give)
    );
    //ALU
    wire [31:0] E_GRF_MUX_RD1;
    wire [31:0] E_ALU_in1;
    wire [31:0] E_ALU_in2;
    //extended for sll
    assign E_ALU_in1 = E_GRF_MUX_RD1;
    assign E_ALU_in2 = (alu_in2_sel == `TRUE) ? E_EXT_ans : 
                       E_GRF_MUX_RD2;
    MUX_32_8 E_mux_fwd_in1 (
        //input
        .op(E_ALU_in1_FWD),
        .in0(E_GRF_RD1),
        .in1(E_ALU_in1_M),
        .in2(E_ALU_in1_W),
        //output
        .out(E_GRF_MUX_RD1)
    );
    MUX_32_8 E_mux_fwd_in2 (
        //input
        .op(E_ALU_in2_FWD),
        .in0(E_GRF_RD2),
        .in1(E_ALU_in2_M),
        .in2(E_ALU_in2_W),
        //output
        .out(E_GRF_MUX_RD2)            //!!!
    );
    ALU E_alu (
        //input
        .op(alu_op),
        .in1(E_ALU_in1),
        .in2(E_ALU_in2),
        .in3(E_inStr_in[10:6]),
        .alu_find(alu_find),
        //output
        .ans(E_ALU_ans),
        .E_Ov(E_Ov),
        .E_AdEL(E_AdEL),
        .E_AdES(E_AdES)
    );
    //MD
    MD E_md (
        //input 
        .clk(clk),
        .reset(reset),
        .cop(md_cop),
        .start(E_MD_start),
        .wop(md_wop),
        .rop(md_rop),
        .in1(E_ALU_in1),
        .in2(E_ALU_in2),
        .Req(M_Req),
        //outout
        .date(E_MD_date),
        .busy(E_MD_busy)
    );
    //else output
    assign E_inStr_out = E_inStr_in;
    assign E_pc_out = E_pc_in;
    assign E_jump_out = E_jump_in;
    CGA E_cga (
        //input
        .inStr(E_inStr_in),
        .op(grf_A3_sel),
        .jump(E_jump_in),
        //output
        .A1(E_GRF_A1),
        .A2(E_GRF_A2),
        .A3(E_GRF_A3)
    ); 
endmodule
