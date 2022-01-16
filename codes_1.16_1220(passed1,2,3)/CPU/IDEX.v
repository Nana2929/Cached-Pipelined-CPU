
module IDEX(clk_i,
    idRegWrite_i, idMemtoReg_i, idMemRead_i, idMemWrite_i,
    idALUOp_i, idALUSrc_i, iddata1_i, iddata2_i, idImm_i,
    idfunc10_i, idrs1_i, idrs2_i, idRd_i, memStall_i,
    exRegWrite_o,exMemtoReg_o,exMemRead_o,exMemWrite_o,
    exALUOp_o,
    exALUSrc_o,
    exdata1_o, exdata2_o,
    exImm_o, exfunc10_o,
    exrs1_o, exrs2_o,
    exRd_o,
);
// input
input clk_i;
input idRegWrite_i, idMemtoReg_i, idMemRead_i, idMemWrite_i, idALUSrc_i, memStall_i;
input [1:0] idALUOp_i;
input [31:0] iddata1_i, iddata2_i, idImm_i;
input [9:0] idfunc10_i;
input [4:0] idrs1_i, idrs2_i, idRd_i;
// output
output reg exRegWrite_o,exMemtoReg_o,exMemRead_o,exMemWrite_o;
output reg [1:0] exALUOp_o;
output reg exALUSrc_o;
output reg [31:0] exdata1_o, exdata2_o,exImm_o;
output reg [9:0] exfunc10_o;
output reg [4:0] exrs1_o, exrs2_o, exRd_o;
// Initialize in testbench
/*
initial begin
    exRegWrite_o = 1'b0;
    exMemtoReg_o = 1'b0;
    exMemRead_o = 1'b0;
    exMemWrite_o = 1'b0;
    exALUOp_o = 2'b0;
    exALUSrc_o = 1'b0;
    exdata1_o = 32'b0;
    exdata2_o = 32'b0;
    exImm_o = 32'b0;
    exfunc10_o = 10'b0;
    exrs1_o = 5'b0;
    exrs2_o = 5'b0;
    exRd_o = 5'b0;
end
*/
// Logic
always @(posedge clk_i) begin
    if (~memStall_i) begin
        exRegWrite_o <= idRegWrite_i;
        exMemtoReg_o <= idMemtoReg_i;
        exMemRead_o <= idMemRead_i;
        exMemWrite_o <= idMemWrite_i;
        exALUOp_o <= idALUOp_i;
        exALUSrc_o <= idALUSrc_i;
        exdata1_o <= iddata1_i;
        exdata2_o <= iddata2_i;
        exImm_o <= idImm_i;
        exfunc10_o <= idfunc10_i;
        exrs1_o <= idrs1_i;
        exrs2_o <= idrs2_i;
        exRd_o <= idRd_i;
    end
end
endmodule

/*
// out wires to hold ID/EX register
wire exRegWrite; // 1
wire exMemtoReg; // 1
wire exMemRead; // 1
wire exMemWrite; //1
wire [1:0] exALUOp;   //2
wire exALUSrc; //1
wire [31:0] exdata1, exdata2; //32
wire [31:0] exImm; // 32
wire [9:0] exfunct10; //10
wire [4:0] exrs1, exrs2;
wire [4:0] exRd; // 5
wire [31:0] exALUresult;
reg [127:0] ID_EXreg; // 128 in total
always @(posedge clk_i) begin
    ID_EXreg[0] <= RegWrite;
    ID_EXreg[1] <= MemtoReg;
    ID_EXreg[2] <= MemRead;
    ID_EXreg[3] <= MemWrite;
    ID_EXreg[5:4] <= ALUOp;
    ID_EXreg[6] <= ALUSrc;
    ID_EXreg[38:7] <= data1;
    ID_EXreg[70:39] <= data2;
    ID_EXreg[102:71] <= ext_immed;
    ID_EXreg[112:103] <= {instr_2[31:25], instr_2[14:12]};
    ID_EXreg[117:113] <= instr_2[19:15];
    ID_EXreg[122:118] <= instr_2[24:20];
    ID_EXreg[127:123] <= instr_2[11:7];
end
assign exRegWrite = ID_EXreg[0];
assign exMemtoReg = ID_EXreg[1];
assign exMemRead = ID_EXreg[2];
assign exMemWrite = ID_EXreg[3];
assign exALUOp = ID_EXreg[5:4];
assign exALUSrc = ID_EXreg[6];
assign exdata1 = ID_EXreg[38:7];
assign exdata2 = ID_EXreg[70:39];
assign exImm = ID_EXreg[102:71];
assign exfunct10 = ID_EXreg[112:103];

assign exrs1 =ID_EXreg[117:113];
assign exrs2 = ID_EXreg[122:118];

assign exRd = ID_EXreg[127:123];
*/