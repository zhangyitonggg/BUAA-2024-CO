`include "HEAD.v"
`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////
module DECODER (
    input wire [5:0] op,             //opCode
    input wire [5:0] fc,             //func
    input wire [31:0] inStr,

    output wire alu_in2_sel,            //if(alu_in2_sel==1'b1)ALU's A2 is imm, else is regDate
    output wire [4:0] alu_op,         //alu_op:add,sub,or,compare
    output wire [2:0] ext_op,         //ext_op:zeroExt,signedExt,luiExt
    output wire [2:0] npc_op,         //npc_op£ºcomNpc,beqNpc,jalNpc,jrNpc
    output wire [2:0] dm_op,          //one op,one inStr
    output wire [1:0] grf_A3_sel,      //grf_A3_sel£º2'b00:rt, 2'b01:rd, 2'b10:ra
    output wire grf_write,            //grf_write:GRF's write enable
    output wire [2:0] grf_wd_sel,      //grf_wd_sel: 2'b00:from ALU, 2'b01:from DM, 2'b10:from PC+4 
    output wire [1:0] tuse_rs,       
    output wire [1:0] tuse_rt,
    output wire md_flag,
    output wire md_start,
    output wire [3:0] md_cop,
    output wire [3:0] md_wop,
    output wire md_rop,
    output wire [1:0] E_tnew,        //Tnew in E
    output wire [2:0] cmp_op,
    output wire [2:0] E_give_sel,
    output wire [2:0] M_give_sel,
    //p7
    output wire load,
    output wire store,
    output wire isSyscall,
    output wire isLegal,            //inStr-type if TRUE
    output wire [2:0] alu_find,     //Determine the type of Exc in ALU,3'd0:find nothing;3'd1:find ALUOv;3'd2:find loadOv;3'd3:find storeOv           
    output wire haveBD,
    output wire CP0_WE,
    output wire eret
    );
    /* ADN LOGIC */
    //R-type
    wire add = (op === `R)&&(fc === `ADD);
    wire sub = (op === `R)&&(fc === `SUB); 
    wire jr = (op === `R)&&(fc === `JR);
    wire sll = (op === `R)&&(fc === `SLL);
    wire and_ = (op === `R)&&(fc === `AND);
    wire or_ = (op === `R)&&(fc === `OR);
    wire slt = (op === `R)&&(fc === `SLT);
    wire sltu = (op === `R)&&(fc === `SLTU);
    wire mult = (op === `R)&&(fc === `MULT);
    wire multu = (op === `R)&&(fc === `MULTU);
    wire div = (op === `R)&&(fc === `DIV);
    wire divu = (op === `R)&&(fc === `DIVU);
    wire mfhi = (op === `R)&&(fc === `MFHI);
    wire mflo = (op === `R)&&(fc === `MFLO);
    wire mthi = (op === `R)&&(fc === `MTHI);
    wire mtlo = (op === `R)&&(fc === `MTLO);
    //I-type
    wire ori = (op === `ORI);
    wire lui = (op === `LUI);
    wire beq = (op === `BEQ);  
    wire bne = (op === `BNE);  
    wire lw = (op === `LW);
    wire lh = (op === `LH);
    wire lb = (op === `LB);
    wire sw = (op === `SW);
    wire sh = (op === `SH);
    wire sb = (op === `SB);
    wire addi = (op === `ADDI);
    wire andi = (op === `ANDI);
    //J-type
    wire jal = (op === `JAL);
    wire j = (op === `J);
    //EXC
    wire syscall = (op === `R)&&(fc === `SYSCALL);
    assign eret = (op === `COP0)&&(fc === `ERET);
    wire mfc0 = (op === `COP0)&&(inStr[25:21] === `MFC0);
    wire mtc0 = (op === `COP0)&&(inStr[25:21] === `MTC0);
    ////////////////////////////////////////////
    wire cal_rr = add || sub || and_ || or_ || sll || slt || sltu;
    wire cal_ri = addi || andi || ori;
    assign load = lw || lh || lb;
    assign store = sw || sh || sb;
    wire branch = beq || bne;
    wire md_cal = mult || multu || div || divu;
    wire md_read = mfhi || mflo;
    wire md_write = mthi || mtlo;
    assign md_flag = md_cal || md_read || md_write;
    //lui
    //jal
    //jr
    /* OR LOGIC */
    //p7
    assign CP0_WE = mtc0;
    assign haveBD = (beq | bne | jal | jr | j);
    assign isSyscall = (syscall === `TRUE);
    assign isLegal = add | sub | jr | sll | and_ | or_ | slt | sltu |
                     mult | multu | div | divu | mfhi | mflo | mthi | mtlo |
                     ori | lui | beq | bne | lw | lh | lb | sw | sh | sb | addi | andi |
                     jal | j | syscall | eret | mfc0 | mtc0;                   
    assign alu_find = (add | sub | addi) ? 3'd1 :
                      (load) ? 3'd2 :
                      (store) ? 3'd3 :
                      3'd0;
    //other
    assign alu_in2_sel = cal_ri || load || store || lui;
    assign alu_op = (add || addi) ? `ALUADD : 
                    (sub) ? `ALUSUB :
                    (and_ || andi) ? `ALUAND :
                    (or_ || ori) ? `ALUOR :
                    (sll) ? `ALUSLL :
                    (slt) ? `ALUSLT :
                    (sltu) ? `ALUSLTU :
                    `ALUADD;
    assign ext_op = (load || store || addi) ? `EXTSIGN :
                    (lui) ? `EXTLUI :
                    `EXTZERO;
    assign npc_op =  (beq || bne) ? `NPCBR : 
                     (jal || j) ? `NPCJAL :
                     (jr) ?  `NPCJR  :
                     `NPCCOM;
    assign dm_op = (sw) ? `DMSW : 
                   (sh) ? `DMSH :
                   (sb) ? `DMSB :
                   (lw) ? `DMLW :
                   (lh) ? `DMLH :
                   (lb) ? `DMLB :
                   `DMNO;
                        //write mtc0 to give rd_addr !!! 
    assign grf_A3_sel = (mtc0 || cal_rr || md_read) ? `GA3RD :
                        (jal)   ? `GA3RA :
                        `GA3RT;
    assign grf_write = (mfc0 || cal_rr || cal_ri || load || md_read || lui || jal) ? `TRUE : `FALSE;
    assign grf_wd_sel = (load) ? `GWDDM :
                        (jal)  ? `GWDPC :
                        (md_read) ? `GWDMD :
                        (mfc0) ? `GWDCP0:
                        `GWDALU;
    assign tuse_rs = (branch || jr) ? 2'd0 :
                     ((cal_rr && !sll) || cal_ri || load || store || md_write || md_cal) ? 2'd1 :
                     2'd3;
    assign tuse_rt = (branch) ? 2'd0 :
                     (cal_rr || md_cal) ? 2'd1 :
                     (mtc0 || store) ? 2'd2 :
                     2'd3;
    assign md_start = md_cal;
    assign md_cop = (mult)  ? `MDCM  :
                    (multu) ? `MDCMU :
                    (div)   ? `MDCD  :
                    (divu)  ? `MDCDU :
                    4'b1111;
    assign md_wop = (mthi) ? `MDTHI :
                    (mtlo) ? `MDTLO :
                    4'b1111;
    assign md_rop = (mfhi) ? 1'b0 : 1'b1;
    assign E_tnew = (cal_rr || cal_ri || md_read) ? 2'd1 :
                    (mfc0 || load) ? 2'd2 :
                    2'd0;  
    assign cmp_op = (beq) ? `CMPBEQ :
                    (bne) ? `CMPBNE :
                    3'b111;
    assign E_give_sel = (`TRUE == jal) ? `EGIPC :
                        `EGIEXT;
    assign M_give_sel = (jal) ? `MGIPC :
                        (md_read) ? `MGIMD :
                        `MGIALU;
endmodule
