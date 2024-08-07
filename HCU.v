`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module HCU(
// input
    // D
    input wire [1:0] D_tuse_rs,     //D's inStr's tuse_rs
    input wire [1:0] D_tuse_rt,     //D's inStr's tuse_rt
    input wire D_GRF_WE,         //D's grf's write enable
    input wire [4:0] D_GRF_A1,   //D's grf's A1
    input wire [4:0] D_GRF_A2,   //D's grf's A2
    input wire [4:0] D_GRF_A3,   //D's grf's A3
    input wire D_md_flag,
    input wire D_eret,
    // E
    input wire [1:0] E_tnew,     //E's inStr's tnew 
    input wire E_GRF_WE,         //E's grf's write enable
    input wire [4:0] E_GRF_A1,   //E's grf's A1
    input wire [4:0] E_GRF_A2,   //E's grf's A2
    input wire [4:0] E_GRF_A3,   //E's grf's A3
    input wire [3:0] E_MD_busy,  //E's MD's busy
    input wire E_MD_start,
    input wire E_CP0_WE,
    // M
    input wire [1:0] M_tnew,     //M's inStr's tnew 
    input wire M_GRF_WE,         //M's grf's write enable
    input wire [4:0] M_GRF_A2,   //M's grf's A2
    input wire [4:0] M_GRF_A3,   //M's grf's A3
    input wire M_CP0_WE,
    // W
    input wire [1:0] W_tnew,
    input wire W_GRF_WE,         //W's grf's write enable
    input wire [4:0] W_GRF_A3,   //W's grf's A3
//output    
    output wire block,               //block signal
    output wire [2:0] D_GRF_RD1_FWD, //D_GRF_RD1's forward signal
    output wire [2:0] D_GRF_RD2_FWD, //D_GRF_RD2's forward signal
    output wire [2:0] E_ALU_in1_FWD,  //E_ALU_in1's forward signal
    output wire [2:0] E_ALU_in2_FWD,  //E_ALU_in2's forward signal
    output wire [2:0] M_DM_WD_FWD    //M_DM_WD's forward signal
    );
//determine whether to block(compare tuse with tnew)
    wire block_eret = (D_eret) && ((E_CP0_WE && (E_GRF_A3 === 5'd14))||(M_CP0_WE && (M_GRF_A3 === 5'd14)));
    wire block_E_rs = (E_GRF_WE) && (D_GRF_A1 == E_GRF_A3) && (D_GRF_A1 != 5'd0) && (D_tuse_rs < E_tnew);
    wire block_E_rt = (E_GRF_WE) && (D_GRF_A2 == E_GRF_A3) && (D_GRF_A2 != 5'd0) && (D_tuse_rt < E_tnew);
    wire block_E = block_E_rs || block_E_rt;
    wire block_M_rs = (M_GRF_WE) && (D_GRF_A1 == M_GRF_A3) && (D_GRF_A1 != 5'd0) && (D_tuse_rs < M_tnew);
    wire block_M_rt = (M_GRF_WE) && (D_GRF_A2 == M_GRF_A3) && (D_GRF_A2 != 5'd0) && (D_tuse_rt < M_tnew);
    wire block_M = block_M_rs || block_M_rt;
    wire block_MD = D_md_flag && (E_MD_busy || E_MD_start);
    assign block = block_eret || block_E || block_M || block_MD;
//determine how to forward
    assign D_GRF_RD1_FWD = ((E_GRF_WE) && (D_GRF_A1 == E_GRF_A3) && (D_GRF_A1 != 5'd0) && (E_tnew == 2'd0)) ? `DG1E :
                           ((M_GRF_WE) && (D_GRF_A1 == M_GRF_A3) && (D_GRF_A1 != 5'd0) && (M_tnew == 2'd0)) ? `DG1M :
                           `DG1COM;
    assign D_GRF_RD2_FWD = ((E_GRF_WE) && (D_GRF_A2 == E_GRF_A3) && (D_GRF_A2 != 5'd0) && (E_tnew == 2'd0)) ? `DG2E :
                           ((M_GRF_WE) && (D_GRF_A2 == M_GRF_A3) && (D_GRF_A2 != 5'd0) && (M_tnew == 2'd0)) ? `DG2M :
                           `DG2COM;
    assign E_ALU_in1_FWD  = ((M_GRF_WE) && (E_GRF_A1 == M_GRF_A3) && (E_GRF_A1 != 5'd0) && (M_tnew == 2'd0)) ? `EA1M :
                            ((W_GRF_WE) && (E_GRF_A1 == W_GRF_A3) && (E_GRF_A1 != 5'd0) && (W_tnew == 2'd0)) ? `EA1W :
                            `EA1COM;
    assign E_ALU_in2_FWD  = ((M_GRF_WE) && (E_GRF_A2 == M_GRF_A3) && (E_GRF_A2 != 5'd0) && (M_tnew == 2'd0)) ? `EA2M :
                            ((W_GRF_WE) && (E_GRF_A2 == W_GRF_A3) && (E_GRF_A2 != 5'd0) && (W_tnew == 2'd0)) ? `EA2W :
                            `EA2COM; 
    assign M_DM_WD_FWD   = ((W_GRF_WE) && (M_GRF_A2 == W_GRF_A3) && (M_GRF_A2 != 5'd0) && (W_tnew == 2'd0)) ? `MDWW :
                           `MDWCOM;
                                             
endmodule
