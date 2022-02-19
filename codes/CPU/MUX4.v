module MUX4(exdata_i, wbWriteData_i, memALUResult_i,
             select_i, data_o);
// 00: data00_i forward from ID/EX stage (2nd pipeline register)
// 10: data10_i forward from EX/MEM stage (3rd pipeline register)
// 01: data01_i: forward from MEM/WB stage (4th pipeline register)
input [31:0] exdata_i, wbWriteData_i, memALUResult_i;
input [1:0] select_i; //2-bit
output reg [31:0] data_o;
always @(*) begin
case (select_i)
    2'b00: data_o = exdata_i;
    2'b01: data_o = wbWriteData_i;
    2'b10: data_o = memALUResult_i;
    default: data_o = exdata_i;
endcase
end
endmodule
/*
// testbench
module MUX4_tb;
reg [31:0] exdata_i, wbWriteData_i, memALUresult_i;
reg [1:0] select;
wire [31:0] data;
MUX4 uut(exdata_i, wbWriteData_i, memALUresult_i,
             select, data);
initial
	begin
		$dumpfile("MUX4_tb.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, MUX4_tb);
		#50 exdata_i =32'b01; wbWriteData_i=32'b11; memALUresult_i = 32'b00; select = 2'b00;
        $monitor("Out: %d", data); // 01
        #50 exdata_i =32'b01; wbWriteData_i=32'b11; memALUresult_i = 32'b00; select = 2'b01;
        $monitor("Out: %d", data); // 11
        #50 exdata_i =32'b01; wbWriteData_i=32'b11; memALUresult_i = 32'b00; select = 2'b10;
        $monitor("Out: %d", data); // 00
		#50 $finish;
	end
endmodule
*/
