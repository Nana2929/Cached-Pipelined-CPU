
module HzDetectionUnit(EXMemRead_i,EXRd_i,IDRs1_i,IDRs2_i,
    NoOp_o,Stall_o,PCWrite_o);
/*
we have to implement a
“hazard detection unit” to detect whether to stall the pipeline or
to flush when a control hazard happens. The hazard detection unit
detects whether the rd in EX stage is the same as rs1 or rs2 in ID stage.
If so, adding a nop (no operation) to the pipeline to resolve data hazard.
*/
input EXMemRead_i;
input [4:0] IDRs1_i, IDRs2_i, EXRd_i;
output PCWrite_o, NoOp_o, Stall_o;
reg flag;
initial begin
    flag = 0;
end
always@(*)begin
    flag = 1'b0;
    // if load
    if (EXMemRead_i == 1'b1) begin
        // if use immediately after (use rs1)
        if (IDRs1_i == EXRd_i) begin
            flag = 1'b1;
        end
        // ~(use rs2)
        if (IDRs2_i == EXRd_i) begin
            flag = 1'b1;
        end
    end
end
assign PCWrite_o = (flag == 1'b1)?  1'b0:1'b1;
assign NoOp_o = (flag == 1'b1)?  1'b1:1'b0;
assign Stall_o= (flag == 1'b1)?  1'b1:1'b0;
endmodule
/*
// test bench
module HzDetectionUnit_tb;
reg EXMemRead;
reg [4:0] EXRd, IDRs1, IDRs2;
wire NoOp, Stall, PCWrite;    // output control signal as ALU's input
HzDetectionUnit uut(
    .EXMemRead_i(EXMemRead),
    .EXRd_i(EXRd),
    .IDRs1_i(IDRs1),
    .IDRs2_i(IDRs2),
    .PCWrite_o(PCWrite),
    .NoOp_o(NoOp),
    .Stall_o(Stall)
    ); //by-order passing arguments
initial
	begin
		$dumpfile("HzDetectionUnit_tb.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, HzDetectionUnit_tb);
		#50 EXMemRead = 1'b0; EXRd = 5'b00000; IDRs1 = 5'b00000; IDRs2 = 5'b00000;
        $monitor("NoOp = %b", NoOp); // 0
        #50 EXMemRead = 1'b1; EXRd = 5'b00000; IDRs1 = 5'b00000; IDRs2 = 5'b00001;
        $monitor("NoOp = %b", NoOp); // 1
        #50 EXMemRead = 1'b1; EXRd = 5'b11110; IDRs1 = 5'b00000; IDRs2 = 5'b00000;
        $monitor("NoOp = %b", NoOp); // 0
        #50 EXMemRead = 1'b1; EXRd = 5'b11111; IDRs1 = 5'b00001; IDRs2 = 5'b11111;
        $monitor("NoOp = %b", NoOp); // 1
		#50 $finish;
	end
endmodule
*/
