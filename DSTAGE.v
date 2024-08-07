`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module DSTAGE(
    //from mips.v
    input wire clk,
    input wire reset,
    input wire [31:0] F_pc_out,
    //from FD_REG
    input wire [31:0] D_pc_in,
    input wire [31:0] D_inStr_in,
    //from W stage !!!!!!! 
    input wire [31:0] W_pc_in,
    input wire [4:0] W_GRF_A3,
    input wire W_GRF_WE,
    input wire [31:0] W_GRF_WD,
    //from HCU
    input wire [2:0] D_GRF_RD1_FWD,
    input wire [2:0] D_GRF_RD2_FWD,
    //from forwarding
    input wire [31:0] D_GRF_RD1_E,
    input wire [31:0] D_GRF_RD1_M,
    input wire [31:0] D_GRF_RD2_E,
    input wire [31:0] D_GRF_RD2_M,
    //p7
    input wire [4:0] D_ExcCode_in,

    //to HCU
    output wire [1:0] D_tuse_rs,     
    output wire [1:0] D_tuse_rt,    
    output wire D_GRF_WE,         
    output wire [4:0] D_GRF_A1,   
    output wire [4:0] D_GRF_A2,  
    output wire [4:0] D_GRF_A3,
    output wire D_md_flag,
    //to DE_REG
    output wire [31:0] D_inStr_out,
    output wire [31:0] D_pc_out,
    output wire [31:0] D_GRF_RD1,
    output wire [31:0] D_GRF_RD2,
    output wire [31:0] D_EXT_ans,
    output wire D_jump,
    //to PC
    output wire [31:0] D_nextpc, 
    //EXC
    output wire [4:0] D_ExcCode_out,
    output wire F_isBD,
    output wire D_eret
    );

    //EXC
    wire isLegal;
    wire D_RI;
    wire D_syscall;
    assign D_ExcCode_out = (D_ExcCode_in) ? D_ExcCode_in :
                           (D_syscall) ? `EXCSYS :
                           (D_RI) ? `EXCRI :
                           D_ExcCode_in;
    //DECODER
    wire [2:0] ext_op;
    wire [2:0] npc_op;
    wire [2:0] cmp_op;
    wire [1:0] grf_A3_sel;
    DECODER D_cu (
        //input
        .op(D_inStr_in[31:26]),
        .fc(D_inStr_in[5:0]),
        .inStr(D_inStr_in),
        //output
        .grf_write(D_GRF_WE),
        .grf_A3_sel(grf_A3_sel),
        .ext_op(ext_op),
        .npc_op(npc_op),
        .cmp_op(cmp_op),
        .tuse_rs(D_tuse_rs),
        .tuse_rt(D_tuse_rt),
        .md_flag(D_md_flag),
        .isLegal(isLegal),
        .isSyscall(D_syscall),
        .haveBD(F_isBD),
        .eret(D_eret)
    );
    assign D_RI = (isLegal === `FALSE);
    //GRF !!! also is reg
    wire [31:0] grf_rd1;
    wire [31:0] grf_rd2;
    GRF D_grf(
        //input
        .clk(clk),
        .reset(reset),
        .pc(W_pc_in),
        .A1(D_GRF_A1),
        .A2(D_GRF_A2),
        .A3(W_GRF_A3),
        .WE(W_GRF_WE),
        .WD(W_GRF_WD),
        //output
        .RD1(grf_rd1),
        .RD2(grf_rd2)
    );
    MUX_32_8 D_mux_fwd_rd1 (
        //input
        .op(D_GRF_RD1_FWD),
        .in0(grf_rd1),
        .in1(D_GRF_RD1_E),
        .in2(D_GRF_RD1_M),
        //output
        .out(D_GRF_RD1)
    );
    MUX_32_8 D_mux_fwd_rd2 (
        //input
        .op(D_GRF_RD2_FWD),
        .in0(grf_rd2),
        .in1(D_GRF_RD2_E),
        .in2(D_GRF_RD2_M),
        //output
        .out(D_GRF_RD2)
    );
    //CMP
    wire jump;
    CMP D_cmp (
        //input 
        .op(cmp_op),
        .in0(D_GRF_RD1),
        .in1(D_GRF_RD2),
        //output 
        .jump(jump)
    );
    assign D_jump = jump;
    //NPC
    NPC D_npc (
        //input 
        .op(npc_op),
        .jump(jump),
        .F_pc(F_pc_out),
        .nowPC(D_pc_in),
        .immNum16(D_inStr_in[15:0]),
        .immNum26(D_inStr_in[25:0]),
        .regDate(D_GRF_RD1),
        //output
        .nextPC(D_nextpc)
    );


    //EXT
    EXT D_ext (
        //input
        .op(ext_op),
        .in(D_inStr_in[15:0]),
        //output
        .ans(D_EXT_ans)
    );
    //else output 
    assign D_inStr_out = D_inStr_in;
    assign D_pc_out = D_pc_in;
    CGA D_cga (
        //input
        .inStr(D_inStr_in),
        .op(grf_A3_sel),
        .jump(D_jump),
        //output
        .A1(D_GRF_A1),
        .A2(D_GRF_A2),
        .A3(D_GRF_A3)
    ); 
endmodule

