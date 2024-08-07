`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module MSTAGE (
    //from mips_tb
    input wire clk,
    input wire reset,
    input wire [31:0] m_data_rdata,
    //from EM_REG
    input wire [31:0] M_inStr_in,
    input wire [31:0] M_pc_in,
    input wire [31:0] M_ALU_ans_in,
    input wire [31:0] M_MD_date_in,
    input wire [31:0] M_GRF_RD2,
    input wire [1:0] M_tnew_in,
    input wire M_jump_in,
    //from HCU
    input wire [2:0] M_DM_WD_FWD,
    //from forwarding
    input wire [31:0] M_DM_WD_W,
    //p7 
    input wire [4:0] M_ExcCode_in,
    input wire M_isBD,
    input wire [5:0] HWInt,

    //to HCU
    output wire [1:0] M_tnew_out,      
    output wire M_GRF_WE,         
    output wire [4:0] M_GRF_A2,   
    output wire [4:0] M_GRF_A3,  
    output wire M_CP0_WE, 
    //to before
    output wire [31:0] M_give,
    //to MW_REG
    output wire [31:0] M_inStr_out,
    output wire [31:0] M_pc_out, 
    output wire [31:0] M_ALU_ans_out,
    output wire [31:0] M_MD_date_out,
    output reg [31:0] M_DM_RD,
    output wire [31:0] M_CP0_RD,
    output wire M_jump_out,
    //to mips_tb
    output reg [31:0] M_DM_WD,
    output reg [3:0] M_DM_byteen,
    //EXC 
    output wire Req,
    output wire [31:0] EPC 
    );
    //p7
    wire [4:0] M_ExcCode_out;  //real ExcCode
    reg M_AdEL;//AdEL except Ov
    reg M_AdES;//AdES except Ov
    wire EXLClr;
    assign M_ExcCode_out = (M_ExcCode_in) ? M_ExcCode_in :
                           (M_AdEL)       ? `EXCADEL     :
                           (M_AdES)       ? `EXCADES     :
                           M_ExcCode_in;

    //DECODER
    wire dm_write;
    wire [2:0] dm_op;
    wire [2:0] M_give_sel;
    wire [1:0] grf_A3_sel;
    wire load;
    wire store;
    DECODER M_cu (
        //input
        .op(M_inStr_in[31:26]),
        .fc(M_inStr_in[5:0]),
        .inStr(M_inStr_in),
        //output
        .dm_op(dm_op),
        .grf_write(M_GRF_WE),
        .M_give_sel(M_give_sel),
        .grf_A3_sel(grf_A3_sel),
        .load(load),
        .store(store),
        .CP0_WE(M_CP0_WE),
        .eret(EXLClr)
    );
    //DM
    wire [31:0] temp_wd;
    MUX_32_8 M_mux_fwd_WD (
        //input
        .op(M_DM_WD_FWD),
        .in0(M_GRF_RD2),
        .in1(M_DM_WD_W),
        //output
        .out(temp_wd)
    );
    always @(*) begin
        if (Req) begin
            M_DM_RD = 32'h0;
            M_DM_WD = 32'h0;
            M_DM_byteen = 4'b0000;
        end
        else begin
            case (dm_op)
            `DMSW:begin
                M_DM_RD = m_data_rdata;
                M_DM_WD = temp_wd;
                M_DM_byteen = 4'b1111;   
            end 
            `DMSH:begin
                M_DM_RD = m_data_rdata;
                if (M_ALU_ans_in[1] == 1'b0)begin
                    M_DM_WD = {{16'b0},temp_wd[15:0]};
                    M_DM_byteen = 4'b0011;
                end
                else begin
                    M_DM_WD = {temp_wd[15:0],{16'b0}};
                    M_DM_byteen = 4'b1100;
                end
            end
            `DMSB:begin
                M_DM_RD = m_data_rdata;
                if (M_ALU_ans_in[1:0] == 2'b00) begin
                    M_DM_WD = {{24'b0},temp_wd[7:0]};
                    M_DM_byteen = 4'b0001;
                end
                else if (M_ALU_ans_in[1:0] == 2'b01) begin
                    M_DM_WD = {{16'b0},temp_wd[7:0],{8'b0}};
                    M_DM_byteen = 4'b0010;
                end
                else if (M_ALU_ans_in[1:0] == 2'b10) begin
                    M_DM_WD = {{8'b0},temp_wd[7:0],{16'b0}};
                    M_DM_byteen = 4'b0100;
                end
                else begin
                    M_DM_WD = {temp_wd[7:0],{24'b0}};
                    M_DM_byteen = 4'b1000;
                end
            end
            `DMLW:begin
                M_DM_RD = m_data_rdata;
                M_DM_WD = 32'b0;
                M_DM_byteen = 4'b0000;
            end 
            `DMLH:begin
                if (M_ALU_ans_in[1] == 1'b0) begin
                    M_DM_RD = {{16{m_data_rdata[15]}},m_data_rdata[15:0]};
                end
                else begin
                    M_DM_RD = {{16{m_data_rdata[31]}},m_data_rdata[31:16]};
                end
                M_DM_WD = 32'b0;
                M_DM_byteen = 4'b0000;
            end
            `DMLB:begin
                if (M_ALU_ans_in[1:0] == 2'b00) begin
                    M_DM_RD = {{24{m_data_rdata[7]}},m_data_rdata[7:0]}; 
                end
                else if (M_ALU_ans_in[1:0] == 2'b01) begin
                    M_DM_RD = {{24{m_data_rdata[15]}},m_data_rdata[15:8]}; 
                end
                else if (M_ALU_ans_in[1:0] == 2'b10) begin
                    M_DM_RD = {{24{m_data_rdata[23]}},m_data_rdata[23:16]}; 
                end
                else begin
                    M_DM_RD = {{24{m_data_rdata[31]}},m_data_rdata[31:24]}; 
                end
                M_DM_WD = 32'b0;
                M_DM_byteen = 4'b0000;
            end
            default: begin
                M_DM_RD = 32'h00114514;
                M_DM_byteen = 4'b000;
                M_DM_WD = 32'b0;
            end
            endcase     
        end
    end
    wire beyond = ((M_ALU_ans_in >= `LDMA && M_ALU_ans_in <= `RDMA)  ||
                   (M_ALU_ans_in >= `LINTA && M_ALU_ans_in <= `RINTA)||
                   (M_ALU_ans_in >= `LTC0A && M_ALU_ans_in <= `RTC0A)||
                   (M_ALU_ans_in >= `LTC1A && M_ALU_ans_in <= `RTC1A)) 
                  ? 1'b0 : 1'b1;
    always @(*) begin   //AdEL except Ov
        if((dm_op === `DMLW)||(dm_op === `DMLH)||(dm_op === `DMLB)) begin
            if (((dm_op == `DMLW)&&(|M_ALU_ans_in[1:0]))||((dm_op == `DMLH)&&(M_ALU_ans_in[0]))) M_AdEL = 1'b1;
            else if (((dm_op == `DMLH)||(dm_op == `DMLB))&&(M_ALU_ans_in >= `LTC0A)&&(M_ALU_ans_in <= `RTC1A)) M_AdEL = 1'b1;
            else if (beyond) M_AdEL = 1'b1;
            else M_AdEL = 1'b0;
        end
        else M_AdEL = 1'b0;
    end
    always @(*) begin   //AdES except Ov
        if((dm_op === `DMSW)||(dm_op === `DMSH)||(dm_op === `DMSB)) begin
            if (((dm_op == `DMSW)&&(|M_ALU_ans_in[1:0]))||((dm_op == `DMSH)&&(M_ALU_ans_in[0]))) M_AdES = 1'b1;
            else if (((dm_op == `DMSH)||(dm_op == `DMSB))&&(M_ALU_ans_in >= `LTC0A)&&(M_ALU_ans_in <= `RTC1A)) M_AdES = 1'b1;
            else if (((M_ALU_ans_in >= `LTC0A+32'h8)&&(M_ALU_ans_in <= `RTC0A))||((M_ALU_ans_in >= `LTC1A+32'h8)&&(M_ALU_ans_in <= `RTC1A))) M_AdES = 1'b1;
            else if (beyond) M_AdES = 1'b1;
            else M_AdES = 1'b0;
        end
        else M_AdES = 1'b0;
    end
    //give back
    wire [31:0] pc_add8 = M_pc_in + 32'd8;
    MUX_32_8 M_mux_give (
        //input
        .op(M_give_sel),
        .in0(M_ALU_ans_in),
        .in1(pc_add8),
        .in2(M_MD_date_in),
        //output
        .out(M_give)
    );
    //CP0
    CP0 cp0 (
        //input
        .clk(clk),
        .reset(reset),
        .addr(M_inStr_in[15:11]),
        .WE(M_CP0_WE),
        .WD(temp_wd),
        .pc(M_pc_in),
        .isBD(M_isBD),
        .ExcCode(M_ExcCode_out),
        .HWInt(HWInt),
        .EXLClr(EXLClr),
        //output
        .RD(M_CP0_RD),
        .Req(Req),
        .EPCOUT(EPC)
    );
    //else output
    assign M_tnew_out = M_tnew_in;
    assign M_inStr_out = M_inStr_in;
    assign M_pc_out = M_pc_in;
    assign M_ALU_ans_out = M_ALU_ans_in;
    assign M_MD_date_out = M_MD_date_in;
    assign M_jump_out = M_jump_in;
    CGA M_cga (
        //input
        .inStr(M_inStr_in),
        .op(grf_A3_sel),
        .jump(M_jump_in),
        //output
        .A2(M_GRF_A2),
        .A3(M_GRF_A3)
    ); 
endmodule
