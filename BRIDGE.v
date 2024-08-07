`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module BRIDGE (
    input wire [3:0]  byteen_from_cpu,
    input wire [31:0] addr_from_cpu,
    input wire [31:0] WD_from_cpu,
    output reg [31:0] RD_to_cpu,
    
    input wire [31:0] RD_from_tb,
    output reg [3:0] byteen_to_tb,
    output reg [31:0] addr_to_tb,
    output reg [31:0] WD_to_tb,

    input wire [31:0] RD_from_tc0,
    output reg WE_to_tc0,
    output reg [31:0] addr_to_tc0,
    output reg [31:0] WD_to_tc0,

    input wire [31:0] RD_from_tc1,
    output reg WE_to_tc1,
    output reg [31:0] addr_to_tc1,
    output reg [31:0] WD_to_tc1
    );
    //read
    always @(*) begin
        if ((addr_from_cpu <= `RDMA)&&(addr_from_cpu >= `LDMA)) begin
            RD_to_cpu = RD_from_tb;
        end
        else if ((addr_from_cpu <= `RTC0A)&&(addr_from_cpu >= `LTC0A)) begin
            RD_to_cpu = RD_from_tc0;
        end
        else if ((addr_from_cpu <= `RTC1A)&&(addr_from_cpu >= `LTC1A)) begin
            RD_to_cpu = RD_from_tc1;
        end
        //interrupt generator always sb $0, 0x7f20($0),so no read
        else RD_to_cpu = 32'h0011_4514;
    end    
    //write
    always @(*) begin
        if ((addr_from_cpu <= `RDMA)&&(addr_from_cpu >= `LDMA)) begin
            WE_to_tc0 = 1'b0;
            WE_to_tc1 = 1'b0;

            byteen_to_tb = byteen_from_cpu;
            addr_to_tb = addr_from_cpu;
            WD_to_tb = WD_from_cpu;
        end
        else if ((addr_from_cpu <= `RTC0A)&&(addr_from_cpu >= `LTC0A)) begin
            byteen_to_tb = 4'b0000;
            WE_to_tc1 = 1'b0;

            WE_to_tc0 = |byteen_from_cpu;
            addr_to_tc0 = addr_from_cpu;
            WD_to_tc0 = WD_from_cpu;
        end
        else if ((addr_from_cpu <= `RTC1A)&&(addr_from_cpu >= `LTC1A)) begin
            byteen_to_tb = 4'b0000;
            WE_to_tc0 = 1'b0;

            WE_to_tc1 = |byteen_from_cpu;
            addr_to_tc1 = addr_from_cpu;
            WD_to_tc1 = WD_from_cpu;
        end
        //interrupt generator always sb $0, 0x7f20($0)
        else if ((addr_from_cpu <= `RINTA)&&(addr_from_cpu >= `LINTA)) begin  
            WE_to_tc0 = 1'b0;
            WE_to_tc1 = 1'b1;

            byteen_to_tb = byteen_from_cpu;
            addr_to_tb = addr_from_cpu;
            WD_to_tb = WD_from_cpu;
        end
        else begin
            byteen_to_tb = 4'b0000;  
            WE_to_tc0 = 1'b0;
            WE_to_tc1 = 1'b0;
        end
    end
endmodule
