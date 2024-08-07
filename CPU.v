`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module CPU(
    input wire clk,                      
    input wire reset,
    
    input wire [5:0] HWInt,              //Interrupt signal
    
    input wire [31:0] i_inst_rdata,      //F_inStr
    output wire [31:0] i_inst_addr,      //F_pc

    input wire [31:0] m_data_rdata,      //M_DM_RD
    output wire [31:0] m_data_addr,      //M_ALU_ans_in
    output wire [31:0] m_data_wdata,     //M_DM_WD
    output wire [3:0] m_data_byteen,     //M_DM_byteen
    output wire [31:0] m_inst_addr,      //M_pc_in,also is macroscopic_pc

    output wire w_grf_we,                //D_GRF_WE
    output wire [4:0] w_grf_addr,        //W_GRF_A3
    output wire [31:0] w_grf_wdata,      //W_GRF_WD
    output wire [31:0] w_inst_addr       //W_pc_in
    );
//p7 new
    //F
    wire F_AdEL;
    wire [4:0] F_ExcCode_out;
    wire F_isBD;
    //D
    wire D_eret;
    wire [4:0] D_ExcCode_in;
    wire [4:0] D_ExcCode_out;
    wire D_isBD;
    //E
    wire [4:0] E_ExcCode_in;
    wire [4:0] E_ExcCode_out;
    wire E_isBD;
    wire E_CP0_WE;
    //M
    wire M_Req;
    wire [31:0] M_EPC;
    wire [4:0] M_ExcCode_in;
    wire M_isBD;
    wire M_CP0_WE;
//HCU
  //define
    //input
    // D
    wire [1:0] D_tuse_rs;     //D's inStr's tuse_rs
    wire [1:0] D_tuse_rt;     //D's inStr's tuse_rt
    wire D_GRF_WE;         //D's grf's write enable
    wire [4:0] D_GRF_A1;   //D's grf's A1
    wire [4:0] D_GRF_A2;   //D's grf's A2
    wire [4:0] D_GRF_A3;   //D's grf's A3
    wire D_md_flag;           
    // E
    wire [1:0] E_tnew;     //E's inStr's tnew 
    wire E_GRF_WE;         //E's grf's write enable
    wire [4:0] E_GRF_A1;   //E's grf's A1
    wire [4:0] E_GRF_A2;   //E's grf's A2
    wire [4:0] E_GRF_A3;   //E's grf's A3
    wire [3:0] E_MD_busy;   //E's MD's busy
    wire E_MD_start;        //E's MD's start
    // M
    wire [1:0] M_tnew_out;     //M's inStr's tnew 
    wire M_GRF_WE;         //M's grf's write enable
    wire [4:0] M_GRF_A2;   //M's grf's A2
    wire [4:0] M_GRF_A3;   //M's grf's A3
    // W
    wire [1:0] W_tnew_out;
    wire W_GRF_WE;         //W's grf's write enable
    wire [4:0] W_GRF_A3;   //W's grf's A3
   //output    
    wire block;               //block signal
    wire [2:0] D_GRF_RD1_FWD; //D_GRF_RD1's forward signal
    wire [2:0] D_GRF_RD2_FWD; //D_GRF_RD2's forward signal
    wire [2:0] E_ALU_in1_FWD;  //E_ALU_in1's forward signal
    wire [2:0] E_ALU_in2_FWD;  //E_ALU_in2's forward signal
    wire [2:0] M_DM_WD_FWD;    //M_DM_WD's forward signal
  //iuu
    HCU hcu(
    //input
        //D
        .D_tuse_rs(D_tuse_rs),
        .D_tuse_rt(D_tuse_rt),
        .D_GRF_WE(D_GRF_WE),
        .D_GRF_A1(D_GRF_A1),
        .D_GRF_A2(D_GRF_A2),
        .D_GRF_A3(D_GRF_A3),
        .D_md_flag(D_md_flag),
        .D_eret(D_eret),
        //E
        .E_tnew(E_tnew),
        .E_GRF_WE(E_GRF_WE),
        .E_GRF_A1(E_GRF_A1),
        .E_GRF_A2(E_GRF_A2),
        .E_GRF_A3(E_GRF_A3),
        .E_MD_busy(E_MD_busy),
        .E_MD_start(E_MD_start),
        .E_CP0_WE(E_CP0_WE),
        //M
        .M_tnew(M_tnew_out),
        .M_GRF_WE(M_GRF_WE),
        .M_GRF_A2(M_GRF_A2),
        .M_GRF_A3(M_GRF_A3),
        .M_CP0_WE(M_CP0_WE),
        //W
        .W_tnew(W_tnew_out),
        .W_GRF_WE(W_GRF_WE),
        .W_GRF_A3(W_GRF_A3),
    //output
        .block(block),
        .D_GRF_RD1_FWD(D_GRF_RD1_FWD),
        .D_GRF_RD2_FWD(D_GRF_RD2_FWD),
        .E_ALU_in1_FWD(E_ALU_in1_FWD),
        .E_ALU_in2_FWD(E_ALU_in2_FWD),
        .M_DM_WD_FWD(M_DM_WD_FWD)    
    );
//datepath
  //define
    //F
    wire [31:0] F_pc_in;
    wire [31:0] F_pc_out; 
    wire [31:0] F_inStr_out;
    //D
    wire [31:0] D_pc_in;
    wire [31:0] D_pc_out;
    wire D_jump;
    wire [31:0] D_inStr_in;
    wire [31:0] D_inStr_out;
    wire [31:0] D_GRF_RD1;
    wire [31:0] D_GRF_RD2;
    wire [31:0] D_EXT_ans;
    wire [31:0] D_nextpc;
    //E
    wire [31:0] E_pc_in;
    wire [31:0] E_pc_out;
    wire [31:0] E_inStr_in;
    wire [31:0] E_inStr_out;
    wire E_jump_in;
    wire E_jump_out;
    wire [31:0] E_GRF_RD1;
    wire [31:0] E_GRF_RD2;
    wire [31:0] E_EXT_ans;
    wire [31:0] E_ALU_ans;
    wire [31:0] E_MD_date;
    wire [31:0] E_GRF_MUX_RD2;
    wire [31:0] E_give;
    //M
    wire [31:0] M_pc_in;
    wire [31:0] M_pc_out;
    wire M_jump_in;
    wire M_jump_out;
    wire [31:0] M_inStr_in;
    wire [31:0] M_inStr_out;
    wire [31:0] M_ALU_ans_in;
    wire [31:0] M_MD_date_in;
    wire [31:0] M_GRF_RD2;
    wire [1:0] M_tnew_in;
    wire [31:0] M_ALU_ans_out;
    wire [31:0] M_MD_date_out;
    wire [31:0] M_DM_RD;
    wire [31:0] M_CP0_RD;
    wire [31:0] M_give;
    //W
    wire [31:0] W_pc_in;
    wire [31:0] W_pc_out;
    wire [31:0] W_inStr_in;
    wire W_jump_in;
    wire [31:0] W_ALU_ans;
    wire [31:0] W_MD_date;
    wire [31:0] W_DM_RD;
    wire [31:0] W_CP0_RD;
    wire [1:0] W_tnew_in;
    wire [31:0] W_GRF_WD;
    wire [31:0] W_give;

  //iuu
    /* F */
    //PC
    PC pc(
        //input    
        .clk(clk),
        .reset(reset),
        .block(block),
        .nextPC(D_nextpc),
        .Req(M_Req),        //from CP0
        .EPC(M_EPC),
        .D_eret(D_eret),
        //output
        .nowPC(F_pc_in)
    );

    //FSTAGE
    assign F_AdEL = (D_eret == `FALSE) && ((F_pc_in < 32'h0000_3000) || (F_pc_in > 32'h0000_6ffc) || (F_pc_in[1:0] !== 2'b00));
    assign F_ExcCode_out = (F_AdEL) ? `EXCADEL : `EXCNO;
    assign i_inst_addr = F_pc_in;
    assign F_inStr_out = (F_AdEL === `TRUE)? `NINSTR : i_inst_rdata;
    assign F_pc_out = F_pc_in;
    /* D */
    //FD_REG
    FD_REG fd_reg(
        //input
        .clk(clk),
        .reset(reset),
        .block(block),
        .F_inStr(F_inStr_out),
        .F_pc(F_pc_out),
        .F_ExcCode(F_ExcCode_out),
        .Req(M_Req),
        .F_isBD(F_isBD),
        .D_eret(D_eret),
        //output
        .D_inStr(D_inStr_in),
        .D_pc(D_pc_in),
        .D_ExcCode(D_ExcCode_in),
        .D_isBD(D_isBD)
    );
    //DSTAGE 
    DSTAGE dstage(
        //input 
        .clk(clk),                      //from mips.v
        .reset(reset),
        .F_pc_out(F_pc_out),
        .D_pc_in(D_pc_in),              //from FD_REG
        .D_inStr_in(D_inStr_in),
        .W_pc_in(W_pc_in),              //from W stage
        .W_GRF_A3(W_GRF_A3),
        .W_GRF_WE(W_GRF_WE),
        .W_GRF_WD(W_GRF_WD),
        .D_GRF_RD1_FWD(D_GRF_RD1_FWD), //from HCU
        .D_GRF_RD2_FWD(D_GRF_RD2_FWD),  
        .D_GRF_RD1_E(E_give),          //from forwarding
        .D_GRF_RD1_M(M_give),        
        .D_GRF_RD2_E(E_give),  
        .D_GRF_RD2_M(M_give),       
        .D_ExcCode_in(D_ExcCode_in), 
        //output
        .D_tuse_rs(D_tuse_rs),        //to HCU
        .D_tuse_rt(D_tuse_rt),
        .D_GRF_WE(D_GRF_WE),
        .D_GRF_A1(D_GRF_A1),
        .D_GRF_A2(D_GRF_A2),
        .D_GRF_A3(D_GRF_A3),
        .D_md_flag(D_md_flag),
        .D_inStr_out(D_inStr_out),   //to DE_REG
        .D_pc_out(D_pc_out),
        .D_GRF_RD1(D_GRF_RD1),
        .D_GRF_RD2(D_GRF_RD2),
        .D_EXT_ans(D_EXT_ans),
        .D_jump(D_jump),
        .D_nextpc(D_nextpc),        //to PC !!!
        .D_ExcCode_out(D_ExcCode_out),
        .F_isBD(F_isBD),
        .D_eret(D_eret)
    );
    assign w_grf_we = W_GRF_WE;
    assign w_grf_addr = W_GRF_A3;
    assign w_grf_wdata = W_GRF_WD;
    assign w_inst_addr = W_pc_out;
    /* E */
    //DE_REG
    DE_REG de_reg(
        //input
        .clk(clk),
        .reset(reset),
        .block(block),
        .D_inStr(D_inStr_out),
        .D_pc(D_pc_out),
        .D_GRF_RD1(D_GRF_RD1),
        .D_GRF_RD2(D_GRF_RD2),
        .D_EXT_ans(D_EXT_ans),
        .D_jump(D_jump),
        .D_ExcCode(D_ExcCode_out),
        .Req(M_Req),
        .D_isBD(D_isBD),
        //output
        .E_inStr(E_inStr_in),
        .E_pc(E_pc_in),
        .E_GRF_RD1(E_GRF_RD1),
        .E_GRF_RD2(E_GRF_RD2),
        .E_EXT_ans(E_EXT_ans),
        .E_jump(E_jump_in),
        .E_ExcCode(E_ExcCode_in),
        .E_isBD(E_isBD)
    );
    //ESTAGE
    ESTAGE estage(
        //input
        .clk(clk),
        .reset(reset),
        .E_inStr_in(E_inStr_in),          //from DE_REG
        .E_pc_in(E_pc_in),
        .E_GRF_RD1(E_GRF_RD1),
        .E_GRF_RD2(E_GRF_RD2),
        .E_EXT_ans(E_EXT_ans),
        .E_ALU_in1_FWD(E_ALU_in1_FWD), //from HCU
        .E_ALU_in2_FWD(E_ALU_in2_FWD), 
        .E_ALU_in1_M(M_give),          //from forwarding
        .E_ALU_in1_W(W_give),
        .E_ALU_in2_M(M_give),
        .E_ALU_in2_W(W_give),
        .E_jump_in(E_jump_in),
        .E_ExcCode_in(E_ExcCode_in),
        .M_Req(M_Req),
        //output
        .E_tnew(E_tnew),               //to HCU
        .E_GRF_WE(E_GRF_WE),
        .E_GRF_A1(E_GRF_A1),
        .E_GRF_A2(E_GRF_A2),
        .E_GRF_A3(E_GRF_A3),
        .E_MD_busy(E_MD_busy),
        .E_MD_start(E_MD_start),
        .E_CP0_WE(E_CP0_WE),
        .E_give(E_give),               //to before
        .E_inStr_out(E_inStr_out),      //to EM_REG
        .E_pc_out(E_pc_out),            
        .E_ALU_ans(E_ALU_ans),
        .E_MD_date(E_MD_date),
        .E_GRF_MUX_RD2(E_GRF_MUX_RD2),
        .E_jump_out(E_jump_out),
        .E_ExcCode_out(E_ExcCode_out)
    );
    /* M */
    //EM_REG
    EM_REG em_reg(
        //input
        .clk(clk),
        .reset(reset),
        .E_inStr(E_inStr_out),
        .E_pc(E_pc_out),
        .E_ALU_ans(E_ALU_ans),
        .E_MD_date(E_MD_date),
        .E_GRF_RD2(E_GRF_MUX_RD2),
        .E_tnew(E_tnew),
        .E_jump(E_jump_out),
        .E_ExcCode(E_ExcCode_out),
        .E_isBD(E_isBD),
        .Req(M_Req),
        //output
        .M_inStr(M_inStr_in),
        .M_pc(M_pc_in),
        .M_ALU_ans(M_ALU_ans_in),
        .M_MD_date(M_MD_date_in),
        .M_GRF_RD2(M_GRF_RD2),
        .M_tnew(M_tnew_in),
        .M_jump(M_jump_in),
        .M_ExcCode(M_ExcCode_in),
        .M_isBD(M_isBD)
    );
    //MSTAGE
    MSTAGE mstage(
        //input
        .clk(clk),
        .reset(reset),
        .m_data_rdata(m_data_rdata),
        .M_inStr_in(M_inStr_in),    //from EM_REG
        .M_pc_in(M_pc_in),
        .M_ALU_ans_in(M_ALU_ans_in),
        .M_MD_date_in(M_MD_date_in),
        .M_GRF_RD2(M_GRF_RD2),
        .M_tnew_in(M_tnew_in),
        .M_jump_in(M_jump_in),
        .M_DM_WD_FWD(M_DM_WD_FWD),  //from HCU
        .M_DM_WD_W(W_give),      //from forwarding
        .M_ExcCode_in(M_ExcCode_in),
        .M_isBD(M_isBD),
        .HWInt(HWInt),
        //output
        .M_tnew_out(M_tnew_out),    //to HCU
        .M_GRF_WE(M_GRF_WE),
        .M_GRF_A2(M_GRF_A2),
        .M_GRF_A3(M_GRF_A3),
        .M_CP0_WE(M_CP0_WE),
        .M_give(M_give),            //to before
        .M_inStr_out(M_inStr_out),  //to MW_REG
        .M_pc_out(M_pc_out),
        .M_ALU_ans_out(M_ALU_ans_out),
        .M_MD_date_out(M_MD_date_out),
        .M_jump_out(M_jump_out),
        .M_DM_RD(M_DM_RD),
        .M_CP0_RD(M_CP0_RD),
        .M_DM_WD(m_data_wdata),
        .M_DM_byteen(m_data_byteen),
        .Req(M_Req),
        .EPC(M_EPC)
    );
    assign m_data_addr = M_ALU_ans_in;
    assign m_inst_addr = M_pc_in;  
    /* W */
    //MW_REG
    MW_REG mw_reg(
        //input
        .clk(clk),
        .reset(reset),
        .M_inStr(M_inStr_out),
        .M_pc(M_pc_out),
        .M_ALU_ans(M_ALU_ans_out),
        .M_MD_date(M_MD_date_out),
        .M_DM_RD(M_DM_RD),
        .M_CP0_RD(M_CP0_RD),
        .M_tnew(M_tnew_out),
        .M_jump(M_jump_out),
        .Req(M_Req),
        //output
        .W_inStr(W_inStr_in),
        .W_pc(W_pc_in),
        .W_ALU_ans(W_ALU_ans),
        .W_MD_date(W_MD_date),
        .W_DM_RD(W_DM_RD),
        .W_CP0_RD(W_CP0_RD),
        .W_tnew(W_tnew_in),
        .W_jump(W_jump_in)
    );
    //WSTAGE
    WSTAGE wstage(
        //input
        .W_inStr_in(W_inStr_in),         //from MW_REG 
        .W_pc_in(W_pc_in),
        .W_ALU_ans(W_ALU_ans),
        .W_MD_date(W_MD_date),
        .W_DM_RD(W_DM_RD),
        .W_tnew_in(W_tnew_in),
        .W_jump_in(W_jump_in),
        .W_CP0_RD(W_CP0_RD),
        //output
        .W_tnew_out(W_tnew_out),         //to HCU
        .W_GRF_WE(W_GRF_WE),
        .W_GRF_A3(W_GRF_A3),
        .W_pc_out(W_pc_out),             //write back
        .W_GRF_WD(W_GRF_WD),
        .W_give(W_give)                  //to before
    );

endmodule
