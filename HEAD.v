`timescale 1ns/1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
//zelse
    `define TRUE   1'b1
    `define FALSE  1'b0
    `define NINSTR 32'h0000_0000
    `define INITPC 32'h0000_3000
    `define EXCPC  32'h0000_4180
    `define LDMA   32'h0000_0000
    `define RDMA   32'h0000_2fff
    `define LTC0A  32'h0000_7f00
    `define RTC0A  32'h0000_7f0b 
    `define LTC1A  32'h0000_7f10 
    `define RTC1A  32'h0000_7f1b 
    `define LINTA  32'h0000_7f20 
    `define RINTA  32'h0000_7f23
    //ExcCode
    `define EXCNO   32'd0
    `define EXCINT  32'd0
    `define EXCADEL 32'd4
    `define EXCADES 32'd5
    `define EXCSYS  32'd8
    `define EXCRI   32'd10 
    `define EXCOV   32'd12
// zopCode & zfunc 
    //zR-type
    `define R     6'b000000
    `define ADD   6'b100000
    `define SUB   6'b100010
    `define JR    6'b001000    //!!!
    `define SLL   6'b000000    //extended
    `define AND   6'b100100
    `define OR    6'b100101 
    `define SLT   6'b101010 
    `define SLTU  6'b101011
    `define MULT  6'b011000 
    `define MULTU 6'b011001 
    `define DIV   6'b011010 
    `define DIVU  6'b011011 
    `define MFHI  6'b010000 
    `define MFLO  6'b010010 
    `define MTHI  6'b010001 
    `define MTLO  6'b010011 
    //zI-type
    `define ORI   6'b001101
    `define LUI   6'b001111
    `define BEQ   6'b000100
    `define BNE   6'b000101 
    `define LW    6'b100011
    `define LH    6'b100001 
    `define LB    6'b100000 
    `define SW    6'b101011
    `define SH    6'b101001 
    `define SB    6'b101000
    `define ADDI  6'b001000
    `define ANDI  6'b001100 
    //zJ-type
    `define JAL   6'b000011
    `define J     6'b000010
    //EXC
    `define SYSCALL 6'b001100
    `define COP0  6'b010000   //!!!
    `define ERET  6'b011000
    `define MFC0  5'b00000
    `define MTC0  5'b00100
// zext_op
    `define EXTZERO 3'b000
    `define EXTSIGN 3'b001 
    `define EXTLUI  3'b010
// zcmp _op
    `define CMPBEQ  3'b000
    `define CMPBNE  3'b001
// znpc _op
    `define NPCCOM 3'b000
    `define NPCBR  3'b001
    `define NPCJAL 3'b010
    `define NPCJR  3'b011 
// zalu_op
    `define ALUADD  5'b00000
    `define ALUSUB  5'b00001
    `define ALUAND  5'b00010
    `define ALUOR   5'b00011
    `define ALUSLL  5'b00100
    `define ALUSLT  5'b00101 
    `define ALUSLTU 5'b00110 
// zMD_wop
    `define MDTNO 4'b0000
    `define MDTHI 4'b0001 
    `define MDTLO 4'b0010 
// zMD_cop
    `define MDCM  4'b0000
    `define MDCMU 4'b0001 
    `define MDCD  4'b0010 
    `define MDCDU 4'b0011 
// zdm_op
    `define DMSW 3'b000
    `define DMSH 3'b001
    `define DMSB 3'b010
    `define DMLW 3'b011
    `define DMLH 3'b100
    `define DMLB 3'b101
    `define DMNO 3'b111
// zgrf_A3_sel
    `define GA3RT 2'b00
    `define GA3RD 2'b01
    `define GA3RA 2'b10
// zgrf_WD_sel
    `define GWDALU 3'b000
    `define GWDDM  3'b001
    `define GWDPC  3'b010
    `define GWDMD  3'b011 
    `define GWDCP0 3'b100
// zD_GRF_RD1_FWD
    `define DG1COM 3'b000
    `define DG1E   3'b001
    `define DG1M   3'b010
// zD_GRF_RD2_FWD
    `define DG2COM 3'b000
    `define DG2E   3'b001
    `define DG2M   3'b010
// zE_ALU_in1_FWD
    `define EA1COM 3'b000
    `define EA1M   3'b001
    `define EA1W   3'b010
// zE_ALU_in2_FWD
    `define EA2COM 3'b000
    `define EA2M   3'b001
    `define EA2W   3'b010
// zM_DM_WD_FWD
    `define MDWCOM 3'b000
    `define MDWW   3'b001
// zE_give_sel
    `define EGIEXT 3'b000
    `define EGIPC  3'b001
// zM_give_sel
    `define MGIALU 3'b000
    `define MGIPC  3'b001
    `define MGIMD  3'b010
