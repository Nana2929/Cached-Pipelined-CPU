module MUX32 (data1_i, data2_i, select_i, data_o);
// 0=> regB; 1=>immed
// A, data1_i: regB
// B, data2_i: immed
// all declarations are defaulted to "wire"
input [31:0] data1_i, data2_i;
input select_i; //default: 1-bit
output [31:0] data_o;
assign data_o = select_i ? data2_i: data1_i;
// ALUSrc = 1-> output immed(B), otherwise output regB(A)
// MemtoReg = 1-> output Data Memory's data(B), otherwise output ALU result
endmodule


/*
module MUX32_tb;
	reg [31:0] A, B;
    reg signal;
	wire [31:0] O;
MUX32 uut(A, B, signal, O); //by-order passing arguments
initial
	begin
		$dumpfile("MUX32.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, MUX32_tb);
		#50 A =5'b00010; B = 5'b01111; signal = 1'b0; // A
        $monitor("A = %b, B = %b, O = %b| select = %b", A, B, O, signal);
		#50 A =5'b00010; B = 5'b01111; signal = 1'b1; // B
        $monitor("A = %b, B = %b, O = %b| select = %b", A, B,  O, signal);
        #50 A =5'b01110; B = 5'b01111; signal = 1'b0; // A
        $monitor("A = %b, B = %b, O = %b| select = %b", A, B, O, signal);
        #50 A =5'b11110; B = 5'b01111; signal = 1'b1; // B
        $monitor("A = %b, B = %b, O = %b| select = %b", A, B, O, signal);
		#50 $finish;
	end
endmodule
*/