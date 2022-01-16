module MEMWB(
    clk_i, memStall_i,
    memRegWrite, memMemtoReg, memALUResult, memDMdata, memRd,
    wbRegWrite,wbMemtoReg,wbALUResult, wbRd, wbDMdata
);
input clk_i;
input memRegWrite, memMemtoReg, memStall_i;
input [31:0] memALUResult, memDMdata;
input [4:0] memRd;
output reg wbRegWrite, wbMemtoReg;
output reg [31:0] wbALUResult, wbDMdata;
output reg [4:0] wbRd;
always @(posedge clk_i)begin
    if (~memStall_i) begin
        wbRegWrite <= memRegWrite;
        wbMemtoReg <= memMemtoReg;
        wbALUResult <= memALUResult;
        wbDMdata <= memDMdata;
        wbRd <= memRd;
    end
end
endmodule
