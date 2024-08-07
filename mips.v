`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module mips (
    input wire clk,                      
    input wire reset,
    
    input wire interrupt,                //External interrupt signal 
    output wire [31:0] macroscopic_pc,   //macroscopic_pc
    output wire [31:0] m_int_addr,       //中断发生器待写入地址
    output wire [3:0] m_int_byteen,      //中断发生器字节使能信号
    
    input wire [31:0] i_inst_rdata,      //F_inStr
    output wire [31:0] i_inst_addr,      //F_pc

    input wire [31:0] m_data_rdata,      //M_DM_RD
    output wire [31:0] m_data_addr,      
    output wire [31:0] m_data_wdata,     //M_DM_WD
    output wire [3:0] m_data_byteen,     //M_DM_byteen
    output wire [31:0] m_inst_addr,      //M_pc_in

    output wire w_grf_we,                //D_GRF_WE
    output wire [4:0] w_grf_addr,        //W_GRF_A3
    output wire [31:0] w_grf_wdata,      //W_GRF_WD
    output wire [31:0] w_inst_addr       //W_pc_in
    );
    //define bridge
    wire [3:0]  byteen_from_cpu;
    wire [31:0] addr_from_cpu;
    wire [31:0] WD_from_cpu;
    wire [31:0] RD_to_cpu;

    wire [31:0] RD_from_tc0;
    wire WE_to_tc0;
    wire [31:0] addr_to_tc0;
    wire [31:0] WD_to_tc0;

    wire [31:0] RD_from_tc1;
    wire WE_to_tc1;
    wire [31:0] addr_to_tc1;
    wire [31:0] WD_to_tc1;
    //define IRQ
    wire IRQ_tc0;
    wire IRQ_tc1;
    //define & get HWInt
    wire [5:0] HWInt = {{3'b000},{interrupt},{IRQ_tc1},{IRQ_tc0}};
    //else
    assign m_int_addr = m_data_addr;
    assign m_int_byteen = m_data_byteen;
    assign m_inst_addr = macroscopic_pc;
    CPU cpu (
        .clk(clk),
        .reset(reset),
        
        .HWInt(HWInt),
        
        .i_inst_rdata(i_inst_rdata),
        .i_inst_addr(i_inst_addr),
        
        .m_data_rdata(RD_to_cpu),
        .m_data_addr(addr_from_cpu),
        .m_data_wdata(WD_from_cpu),
        .m_data_byteen(byteen_from_cpu),
        .m_inst_addr(macroscopic_pc),

        .w_grf_we(w_grf_we),
        .w_grf_addr(w_grf_addr),
        .w_grf_wdata(w_grf_wdata),
        .w_inst_addr(w_inst_addr)
    );
    
    TC tc0 (
        .clk(clk),
        .reset(reset),
        .Addr(addr_to_tc0[31:2]),
        .WE(WE_to_tc0),
        .Din(WD_to_tc0),

        .Dout(RD_from_tc0),
        .IRQ(IRQ_tc0)
    );

    TC tc1 (
        .clk(clk),
        .reset(reset),
        .Addr(addr_to_tc1[31:2]),
        .WE(WE_to_tc1),
        .Din(WD_to_tc1),

        .Dout(RD_from_tc1),
        .IRQ(IRQ_tc1)
    );

    BRIDGE bridge (
        .byteen_from_cpu(byteen_from_cpu),
        .addr_from_cpu(addr_from_cpu),
        .WD_from_cpu(WD_from_cpu),
        .RD_to_cpu(RD_to_cpu),

        .RD_from_tb(m_data_rdata),
        .byteen_to_tb(m_data_byteen),
        .addr_to_tb(m_data_addr),
        .WD_to_tb(m_data_wdata),
        
        .RD_from_tc0(RD_from_tc0),
        .WE_to_tc0(WE_to_tc0),
        .addr_to_tc0(addr_to_tc0),
        .WD_to_tc0(WD_to_tc0),

        .RD_from_tc1(RD_from_tc1),
        .WE_to_tc1(WE_to_tc1),
        .addr_to_tc1(addr_to_tc1),
        .WD_to_tc1(WD_to_tc1)
    );
endmodule
