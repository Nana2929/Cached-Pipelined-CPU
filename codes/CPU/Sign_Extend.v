module Sign_Extend(data_i, data_o);
// reference: https://stackoverflow.com/questions/4176556/how-to-sign-extend-a-number-in-verilog
// 要在Sign-Extend裡判斷哪一塊才是imm field（看前七碼opcode+func3）
input [31:0] data_i;
output [31:0] data_o;
wire [9:0] opfunc3;
reg signed [11:0] imm;
assign opfunc3 = {data_i[6:0], data_i[14:12]};
always @(*) begin
case (opfunc3)
	// addi
	10'b0010011000: imm = data_i[31:20];
	// srai
	10'b0010011101: imm = data_i[24:20];
	// lw
	10'b0000011010: imm = data_i[31:20];
	// sw
	10'b0100011010: imm = {data_i[31:25], data_i[11:7]};
	// beq
	// 是13-bit!
	10'b1100011000:
	begin
		// 在外面要自己補上LSB as 0 //left shifter (ls 1)
		imm = {data_i[31], data_i[7], data_i[30:25], data_i[11:8]};
	end
	default: imm = data_i[31:20];
	endcase
end
assign data_o = {{20{imm[11]}}, imm};
endmodule
/*
// testbench, instead of writing a Sign_Extend_tb.v
// keep it in a file
module Sign_Ex_tb;
	reg [31:0] A;
	wire [31:0] O;
Sign_Extend uut(A, O);
initial
	begin
		$dumpfile("Sign_Extend.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, Sign_Ex_tb);
		#50 A = 32'b00000000000000000000000000010011; //addi r0, r0, 0
        $monitor("A = %b | O = %b", A, O);
		#50 A = 32'b01000000111100000101000000010011; // srai r0, r0,01111
        $monitor("A = %b | O = %b", A, O);
		#50 A = 32'b00000000001100000010000000000011; // lw r0, 3(r0)                                     //lw
        $monitor("A = %b | O = %b", A, O);
		#50 A = 32'b00000010000000000010000010100011; // sw 000000100001 32+1=33
        $monitor("A = %b | O = %b", A, O);
		#50 A = 32'b10000010000000000000100011100011;  //beq 110000011000(0) -> 是負的
		$monitor("A = %b | O = %b", A, O);
		#50 $finish;
	end
endmodule
*/