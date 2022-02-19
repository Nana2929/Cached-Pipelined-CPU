
module ALU_Control(funct_i, ALUOp_i, ALUCtrl_o);

input [9:0] funct_i; // {func7, func3} (concatenate)
input [1:0] ALUOp_i; // load or store: 00; branch: 01; R-type: 10; others I'll use 11
output reg [2:0] ALUCtrl_o;    // output control signal as ALU's input

// parameter list for ALUctrl signal assignment
parameter AND = 3'b000;
parameter XOR = 3'b001;
parameter SLL = 3'b010;
parameter ADD = 3'b011;
parameter SUB = 3'b100;
parameter MUL = 3'b101;
parameter SRAI = 3'b111;
// to calculate addition (base + offset);
// LoadStore shares the same ALUCtrl signal with ADD
parameter LS = 3'b011;
parameter NoOp = 3'b110;

always @(*)
begin
    if (ALUOp_i == 2'b10) //R-type
        case (funct_i)
        10'b0000000111: ALUCtrl_o = AND;
        10'b0000000100: ALUCtrl_o = XOR;
        10'b0000000001: ALUCtrl_o = SLL;
        10'b0000000000: ALUCtrl_o = ADD;
        10'b0100000000: ALUCtrl_o = SUB;
        10'b0000001000: ALUCtrl_o = MUL;
        default: ALUCtrl_o = ADD;
        endcase
    // LoadStore
    else if (ALUOp_i == 2'b00) ALUCtrl_o = LS; //10'b???????010
    else if (ALUOp_i == 2'b01) ALUCtrl_o = NoOp; // branch is dealt in ID stage , no op at ALU
    else if (ALUOp_i == 2'b11) // I-type
        case(funct_i)
            10'b0100000101: ALUCtrl_o = SRAI;
            default: ALUCtrl_o = ADD; //func7 does not exist/immd field replaces
        endcase
    else ALUCtrl_o = ADD;
end //end always block
endmodule

// test bench
/*
module ALUControl_tb;
reg [9:0] A; // {func7, func3} (concatenate)
reg [1:0] Aop; // load or store: 00; branch: 01; R-type: 10; others I'll use 11
wire [2:0] ALUCtrl;    // output control signal as ALU's input
ALU_Control uut(A, Aop, ALUCtrl); //by-order passing arguments
initial
	begin
		$dumpfile("ALUControl_tb.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, ALUControl_tb);
		#50 A =10'b0000000111; Aop = 2'b10; // AND
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);
		#50 A =10'b0000000100; Aop = 2'b10; // XOR
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);
        #50 A =10'b0000000001; Aop = 2'b10; // SLL
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);
        #50 A =10'b0000000000; Aop = 2'b10; // ADD
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);
        #50 A =10'b0100000000; Aop = 2'b10; // SUB
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);
        #50 A =10'b0000001000; Aop = 2'b10; // MUL
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);


        #50 A =10'b0100000101; Aop = 2'b11; // SRAI 111
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);

        #50 A =10'b0110001101; Aop = 2'b11; // ADD 011
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);
        #50 A =10'b0110011101; Aop = 2'b11; // ADD 011
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);

        #50 A =10'b0110011010; Aop = 2'b00; // LoadStore 011
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);

        #50 A =10'b0110011010; Aop = 2'b01; // NoOp 110
        $monitor("A = %b, Aop = %b | ALUCtrl = %b", A, Aop, ALUCtrl);
		#50 $finish;
	end
endmodule
*/
