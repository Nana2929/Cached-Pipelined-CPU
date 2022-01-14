module EXMEM(clk_i, memStall_i,
    exRegWrite, exMemtoReg, exMemRead, exMemWrite,
    exALUresult, expreALUd2, exRd,
    memRegWrite, memMemtoReg, memMemRead, memMemWrite,
    memALUresult, mempreALUd2, memRd
);
input clk_i;
input exRegWrite, exMemtoReg, exMemRead, exMemWrite, memStall_i;
input [31:0] exALUresult, expreALUd2;
input [4:0] exRd;
output reg memRegWrite, memMemtoReg, memMemRead, memMemWrite;
output reg [31:0] memALUresult;
output reg [31:0] mempreALUd2;
output reg [4:0] memRd;

// initialization in testbench
/*
initial begin
    memRegWrite = 1'b0;
    memMemtoReg = 1'b0;
    memMemRead = 1'b0;
    memMemWrite = 1'b0;
    memALUresult = 32'b0;
    mempreALUd2 = 32'b0;
    memRd = 5'b0;
end
*/
always @(posedge clk_i)begin
    if (~memStall_i) begin
        memRegWrite <= exRegWrite;
        memMemtoReg <= exMemtoReg;
        memMemRead <= exMemRead;
        memMemWrite <= exMemWrite;
        memALUresult <= exALUresult;
        mempreALUd2 <= expreALUd2;
        memRd <= exRd;
    end
end
endmodule
