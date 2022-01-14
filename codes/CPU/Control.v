
module Control(
    Op_i,
    NoOp_i,
    RegWrite_o,
    MemtoReg_o,
    MemRead_o,
    MemWrite_o,
    ALUOp_o,
    ALUSrc_o,
    Branch_o);

input [6:0] Op_i; // 7-bit opcode in instruction
input NoOp_i; // to Stall
output reg [1:0] ALUOp_o; // 2-bit // load or store: 00; branch: 01; R-type: 10; others I'll use 11
output reg ALUSrc_o; // 1-bit, select = 1 -> output immed(B), otherwise output regB(A)
output reg RegWrite_o; //1-bit, 有rd(dest reg) = 1
output reg MemtoReg_o; //1-bit, lw
output reg MemRead_o; //1-bit, lw
output reg MemWrite_o; //1-bit, sw
output reg Branch_o; //1-bit, isBranch or not
// pipeline 的registers都要記得initialize

initial begin
    ALUOp_o=0;
    ALUSrc_o=0;
    RegWrite_o=0;
    MemtoReg_o=0;
    MemRead_o=0;
    MemWrite_o= 0;
    Branch_o = 0;
end

always @(*) begin
    case (Op_i)
        7'b0110011:begin
            // R-type instruction
            ALUSrc_o = 1'b0;
            ALUOp_o = 2'b10;
            RegWrite_o = 1'b1;
            MemtoReg_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
        end
        7'b0010011:begin
            // I-type
            ALUSrc_o = 1'b1;
            ALUOp_o = 2'b11;
            RegWrite_o = 1'b1;
            MemtoReg_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
        end
        // * Lab1 update: *
        // lw
        7'b0000011: begin
            ALUSrc_o = 1'b1; //select immed
            ALUOp_o = 2'b00;
            RegWrite_o = 1'b1;
            MemtoReg_o = 1'b1;
            MemRead_o = 1'b1;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
        end
        7'b0100011:begin
            // sw
            ALUSrc_o = 1'b1; // select immed
            ALUOp_o = 2'b00;
            RegWrite_o = 1'b0;
            MemtoReg_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b1;
            Branch_o = 1'b0;
            //$display("enter sw zone");
            //$display("Op = %b |ALUOp = %b | ALUSrc = %b", Op_i, ALUOp_o, ALUSrc_o);
        end
        7'b1100011:begin
            // beq: we'll deal with the equality NOT at ALU(EX stage),
            // but in ID stage
            ALUSrc_o = 1'bx; // x as don't care
            ALUOp_o = 2'b01;
            RegWrite_o = 1'b0;
            MemtoReg_o = 1'bx;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b1;
        end
        default:begin
            // default no op
            ALUSrc_o = 1'b0;
            ALUOp_o = 2'b10;
            RegWrite_o = 1'b0;
            MemtoReg_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
            end
    endcase
    if (NoOp_i == 1)//set all control signals to 0
    // 處理Stall
    begin
        ALUSrc_o = 1'b0;
        ALUOp_o = 2'b00;
        RegWrite_o = 1'b0;
        MemtoReg_o = 1'b0;
        MemRead_o = 1'b0;
        MemWrite_o = 1'b0;
        Branch_o = 1'b0;
    end
end
endmodule
/*
// test bench
module Control_tb;
    reg [6:0] Op;
    reg NoOp;
    // output signal
    wire RegWrite;
    wire MemtoReg;
    wire MemRead;
    wire MemWrite;
    wire [1:0] ALUOp;
    wire ALUSrc;
    wire Branch;

Control uut(Op, NoOp, RegWrite, MemtoReg, MemRead, MemWrite, ALUOp, ALUSrc, Branch); //by-order passing arguments
initial
	begin
		$dumpfile("Control_tb.vcd"); //fsdb較大 vcd較快
		$dumpvars(0, Control_tb);

		#50 Op =7'b0110011; NoOp = 1'b0; // R-type
        $monitor("Op = %b |ALUOp = %b | ALUSrc = %b", Op, ALUOp, ALUSrc);
        #50 Op =7'b0110011; NoOp = 1'b0; // R-type
        $monitor("Op = %b |ALUOp = %b | ALUSrc = %b", Op, ALUOp, ALUSrc);
        #50 Op =7'b0100011; NoOp = 1'b0; // sw
        $monitor("Op = %b |ALUOp = %b | ALUSrc = %b", Op, ALUOp, ALUSrc);
        #50 Op =7'b0000011; NoOp = 1'b0; // lw
        $monitor("Op = %b |ALUOp = %b | ALUSrc = %b", Op, ALUOp, ALUSrc);
        #50 Op =7'b0110011; NoOp = 1'b1; // all set to 0
        $monitor("Op = %b |ALUOp = %b | ALUSrc = %b", Op, ALUOp, ALUSrc);
        #50 Op =7'b1100011; NoOp = 1'b0; // beq, 有don't care values
        $monitor("Op = %b |ALUOp = %b | ALUSrc = %b", Op, ALUOp, ALUSrc);
		#50 $finish;
	end
endmodule
*/