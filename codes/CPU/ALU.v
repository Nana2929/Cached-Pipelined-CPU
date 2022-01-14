// 3-bit alucontrol signal for 8 ops
// self-defined; not follwing risc-v format
`define AND 3'b000
`define XOR 3'b001
`define SLL 3'b010
`define ADD 3'b011 // Addi
`define SUB 3'b100
`define MUL 3'b101
`define NoOp 3'b110 // Branch
`define SRAI 3'b111
// Lab 1 updates

module ALU(data1_i, data2_i, ALUCtrl_i, data_o);
input signed [31:0] data1_i, data2_i;// 32-bit // remember the sign
input [2:0] ALUCtrl_i; // 3-bit
// put the output into a register
output reg signed [31:0] data_o; //32-bit
// Use the op
// code part of your instruction word to select which multiplexer input to use for the addition.
// reg: value can only be changed inside always block

always @(*)
begin
    case (ALUCtrl_i)
        `AND: data_o = data1_i & data2_i;
        `XOR: data_o = data1_i ^ data2_i; // XOR: exclusive OR
        `SLL: data_o = data1_i << data2_i; //pad 0 at final {data2_i} pos
        `ADD: data_o = data1_i + data2_i; // LS, ADDI: // immediate operand source dealt with at ALUSrc MUX
        `SUB: data_o = data1_i - data2_i;
        `MUL: data_o = data1_i * data2_i;
        `SRAI: data_o = data1_i >>> data2_i; // arithmetic shift right (immed)
        `NoOp: data_o = 32'b0;
        default: data_o = data1_i + data2_i;
    endcase
    // Zero_o is True (1) of data_o is zero
    // assign signal A = (contition) ? (True Signal) : (False Signal)
end
endmodule

// testbench
/*
module ALU_tb;
reg [9:0] A, B;
reg [2:0] select; //ALU control signal
wire [9:0] O;
wire isZero;
ALU uut(A, B, select, O); //by-order passing arguments
initial
	begin
		$dumpfile("ALU.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, ALU_tb);
        // will cause warning; Verilog pads zero to higher bits

		#50 A = 10'b0001000000; B = 10'b0000001111; select = 3'b100; // SUB
        $monitor("A = %d, B = %d, select = %b | O = %d ",A, B, select, O);
        #50 A = 10'b1111000000; B = 10'b1000001111; select= 3'b011; // ADD
        $monitor("A = %d, B = %d, select = %b | O = %d ",A, B, select, O);
        #50 A = 10'b000000100; B = 10'b1111111110; select = 3'b101; //MUL
        $monitor("A = %d, B = %d, select = %b | O = %d ",A, B, select, O);
        #50 A = 10'b1111111000; B = 10'b0000000100; select = 3'b010; // SLL
        $monitor("A = %d, B = %d, select = %b | O = %d ",A, B, select, O);
        #50 A = 10'b1111100010; B = 10'b0000000010; select = 3'b111; //SRAI 2
        $monitor("A = %d, B = %d, select = %b | O = %d ",A, B, select, O);
        #50 A = 10'b1111100010; B = 10'b0000000110; select = 3'b111; //SRAI 6
        $monitor("A = %d, B = %d, select = %b | O = %d", A, B, select, O);

        #50 A = 10'b100010010; B = 10'b0000000111; select = 3'b110;
        $monitor("A = %d, B = %d, select = %b | O = %d", A, B, select, O);


        #50 A = 10'b0000111111; B = 10'b0000000010; select = 3'b111; //SRAI 2
        $monitor("A = %d, B = %d, select = %b | O = %d", A, B, select, O);

        // bitwise operations
        #50 A = 10'b1000100010; B = 10'b000000011; select = 3'b000; //AND
        $monitor("A = %d, B = %d, select = %b | O = %d ",A, B, select, O);
        #50 A = 10'b1000100010; B = 10'b000000011; select = 3'b001; //XOR
        $monitor("A = %d, B = %d, select = %b | O = %d ",A, B, select, O);
        #50 $finish;
	end
endmodule
*/
