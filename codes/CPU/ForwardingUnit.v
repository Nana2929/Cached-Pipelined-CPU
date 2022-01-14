module FWUnit(memRegWrite_i,
    memRd_i,
    wbRegWrite_i,
    wbRd_i,
    exRs1_i,
    exRs2_i,
    ForwardA_o,
    ForwardB_o);
input memRegWrite_i, wbRegWrite_i;
input [4:0] memRd_i, wbRd_i;
input [4:0] exRs1_i, exRs2_i;
output reg [1:0] ForwardA_o, ForwardB_o;

always @(*)begin
    // ForwardA: first ALU operand (Rs1)
    // 00; comes from the Register File (no forwarding)
    // 10: ~ is forwarded from the prior ALU result
    // 01: ~ is forwarded from data memory or prior-prior ALU result
    // EX hazard
    ForwardA_o = 2'b00;
    ForwardB_o = 2'b00;
    if (memRegWrite_i == 1'b1 && memRd_i != 0 && memRd_i == exRs1_i) begin
    ForwardA_o = 2'b10;
    end
    // MEM hazard
    // 好奇這樣是不是就不用寫 !(memRegWrite_i== 1'b1 && (memRd_i != 0) && (memRd_i == exRs1_i))
    // 因為not內這些condition成立的話會先進上面那個if statement
    else if ((wbRegWrite_i) && (wbRd_i != 0) &&
    !(memRegWrite_i== 1'b1 && (memRd_i != 0) && (memRd_i == exRs1_i))
    && (wbRd_i == exRs1_i)) ForwardA_o = 2'b01;

    // ForwardB: second ALU operand (Rs2)
    if ((memRegWrite_i) && (memRd_i!=0) && (memRd_i==exRs2_i))ForwardB_o = 2'b10;
    else if (wbRegWrite_i== 1'b1 && wbRd_i != 0 && !(memRegWrite_i==1'b1 && memRd_i != 0 && (memRd_i == exRs2_i))
    && (wbRd_i==exRs2_i))ForwardB_o = 2'b01;
end
endmodule


/*
// test bench
module FWUnit_tb;
reg memRegWrite;
reg wbRegWrite;
reg [4:0] memRd;
reg [4:0] wbRd;
reg [4:0] exRs1;
reg [4:0] exRs2;
wire [1:0] ForwardA;
wire [1:0] ForwardB;
FWUnit uut(memRegWrite, memRd, wbRegWrite, wbRd, exRs1, exRs2, ForwardA, ForwardB); //by-order passing arguments
initial
	begin
		$dumpfile("FWUnit_tb.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, FWUnit_tb);
        // ForwardA = 10, ForwardB = 11
		#50 memRegWrite = 1'b1; memRd = 5'b00001; wbRegWrite = 1'b0;  wbRd = 5'b00111; exRs1 =  5'b00001; exRs2 =  5'b00011;
        $monitor("ForwardA = %b |ForwardB = %b", ForwardA, ForwardB);

        // ForwardA = 11, ForwardB = 10
        #50 memRegWrite = 1'b1; memRd = 5'b00001; wbRegWrite = 1'b0;  wbRd = 5'b00111; exRs1 =  5'b00000; exRs2 =  5'b00001;
        $monitor("ForwardA = %b |ForwardB = %b", ForwardA, ForwardB);

        // ForwardA = 01, ForwardB = 11
        #50 memRegWrite = 1'b0; memRd = 5'b00001; wbRegWrite = 1'b1;  wbRd = 5'b00111; exRs1 =  5'b00111; exRs2 =  5'b00001;
        $monitor("ForwardA = %b |ForwardB = %b", ForwardA, ForwardB);

        // MEM hazard但不能MEM forwarded的情況
        // 可用EX hazard
        // ForwardA = 10, ForwardB = 10
        #50 memRegWrite = 1'b0; memRd = 5'b00001; wbRegWrite = 1'b1;  wbRd = 5'b00001; exRs1 =  5'b00001; exRs2 =  5'b00001;
        $monitor("ForwardA = %b |ForwardB = %b", ForwardA, ForwardB);

        // ForwardA = 01, ForwardB = 01
        #50 memRegWrite = 1'b0; memRd = 5'b00001; wbRegWrite = 1'b1;  wbRd = 5'b00111; exRs1 =  5'b00111; exRs2 =  5'b00111;
        $monitor("ForwardA = %b |ForwardB = %b", ForwardA, ForwardB);
		#50 $finish;
	end
endmodule
*/
