`include "./CPU.v"
`define CYCLE_TIME 50

module TestBench;

reg                Clk;
reg                Start;
reg                Reset;
integer            i, outfile, counter;
integer            stall, flush;
parameter          num_cycles = 64;

always #(`CYCLE_TIME/2) Clk = ~Clk;

CPU CPU(
    .clk_i  (Clk),
    .start_i(Start),
    .rst_i  (Reset)
);

initial begin
    $dumpfile("CPU.vcd");
    $dumpvars;
    counter = 0;
    stall = 0;
    flush = 0;

    // initialize instruction memory
    for(i=0; i<256; i=i+1) begin
        CPU.Instruction_Memory.memory[i] = 32'b0;
    end

    // initialize data memory
    for(i=0; i<32; i=i+1) begin
        CPU.Data_Memory.memory[i] = 32'b0;
    end
    CPU.Data_Memory.memory[0] = 5;
    // [D-MemoryInitialization] DO NOT REMOVE THIS FLAG !!!
    // 為什麼這裡要自己寫QQ
    CPU.Data_Memory.memory[1] = 6;
    CPU.Data_Memory.memory[2] = 10;
    CPU.Data_Memory.memory[3] = 18;
    CPU.Data_Memory.memory[4] = 29;

    // initialize Register File
    for(i=0; i<32; i=i+1) begin
        CPU.Registers.register[i] = 32'b0;
    end
    // [RegisterInitialization] DO NOT REMOVE THIS FLAG !!!
    CPU.Registers.register[24] = -24;
    CPU.Registers.register[25] = -25;
    CPU.Registers.register[26] = -26;
    CPU.Registers.register[27] = -27;
    CPU.Registers.register[28] = 56;
    CPU.Registers.register[29] = 58;
    CPU.Registers.register[30] = 60;
    CPU.Registers.register[31] = 62;

    // TODO: initialize your pipeline registers
    // initialization
    // IFID
    CPU.IFID.PCval_o = 32'b0;
    CPU.IFID.instr_o = 32'b0;
    // IDEX
    CPU.IDEX.exRegWrite_o = 1'b0;
    CPU.IDEX.exMemtoReg_o = 1'b0;
    CPU.IDEX.exMemRead_o = 1'b0;
    CPU.IDEX.exMemWrite_o = 1'b0;
    CPU.IDEX.exALUOp_o = 2'b0;
    CPU.IDEX.exALUSrc_o = 1'b0;
    CPU.IDEX.exdata1_o = 32'b0;
    CPU.IDEX.exdata2_o = 32'b0;
    CPU.IDEX.exImm_o = 32'b0;
    CPU.IDEX.exfunc10_o = 10'b0;
    CPU.IDEX.exrs1_o = 5'b0;
    CPU.IDEX.exrs2_o = 5'b0;
    CPU.IDEX.exRd_o = 5'b0;
    // EXMEM
    CPU.EXMEM.memRegWrite = 1'b0;
    CPU.EXMEM.memMemtoReg = 1'b0;
    CPU.EXMEM.memMemRead = 1'b0;
    CPU.EXMEM.memMemWrite = 1'b0;
    CPU.EXMEM.memALUresult = 32'b0;
    CPU.EXMEM.mempreALUd2 = 32'b0;
    CPU.EXMEM.memRd = 5'b0;
    // MEMWB
    CPU.MEMWB.wbRegWrite = 0;
    CPU.MEMWB.wbMemtoReg = 0;
    CPU.MEMWB.wbALUResult = 32'b0;
    CPU.MEMWB.wbDMdata = 32'b0;
    CPU.MEMWB.wbRd = 5'b0;

    // Load instructions into instruction memory

    // Make sure you change back to "instruction.txt" before submission
    $readmemb("testdata/instruction1.txt", CPU.Instruction_Memory.memory);
    // $readmemb("testdata/instruction_3.txt", CPU.Instruction_Memory.memory);

    // Open output file
    // Make sure you change back to "output.txt" before submission
    outfile = $fopen("myoutput_1.txt") | 1;

    Clk = 1;
    Reset = 1;
    Start = 0;

    #(`CYCLE_TIME/4)
    Reset = 0;
    Start = 1;


end

always@(posedge Clk) begin
    if(counter == num_cycles)    // stop after num_cycles cycles
        $finish;

    // put in your own signal to count stall and flush
    if(CPU.HzDetectionUnit.Stall_o == 1 && CPU.Control.Branch_o == 0)stall = stall + 1;
    if(CPU.toFlush == 1)flush = flush + 1;

    // print PC
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "cycle = %d, Start = %0d, Stall = %0d, Flush = %0d\nPC = %d", counter, Start, stall, flush, CPU.PC.pc_o);

    // print Registers
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "Registers");
    $fdisplay(outfile, "x0 = %d, x8  = %d, x16 = %d, x24 = %d", CPU.Registers.register[0], CPU.Registers.register[8] , CPU.Registers.register[16], CPU.Registers.register[24]);
    $fdisplay(outfile, "x1 = %d, x9  = %d, x17 = %d, x25 = %d", CPU.Registers.register[1], CPU.Registers.register[9] , CPU.Registers.register[17], CPU.Registers.register[25]);
    $fdisplay(outfile, "x2 = %d, x10 = %d, x18 = %d, x26 = %d", CPU.Registers.register[2], CPU.Registers.register[10], CPU.Registers.register[18], CPU.Registers.register[26]);
    $fdisplay(outfile, "x3 = %d, x11 = %d, x19 = %d, x27 = %d", CPU.Registers.register[3], CPU.Registers.register[11], CPU.Registers.register[19], CPU.Registers.register[27]);
    $fdisplay(outfile, "x4 = %d, x12 = %d, x20 = %d, x28 = %d", CPU.Registers.register[4], CPU.Registers.register[12], CPU.Registers.register[20], CPU.Registers.register[28]);
    $fdisplay(outfile, "x5 = %d, x13 = %d, x21 = %d, x29 = %d", CPU.Registers.register[5], CPU.Registers.register[13], CPU.Registers.register[21], CPU.Registers.register[29]);
    $fdisplay(outfile, "x6 = %d, x14 = %d, x22 = %d, x30 = %d", CPU.Registers.register[6], CPU.Registers.register[14], CPU.Registers.register[22], CPU.Registers.register[30]);
    $fdisplay(outfile, "x7 = %d, x15 = %d, x23 = %d, x31 = %d", CPU.Registers.register[7], CPU.Registers.register[15], CPU.Registers.register[23], CPU.Registers.register[31]);

    // print Data Memory
    // DO NOT CHANGE THE OUTPUT FORMAT
    $fdisplay(outfile, "Data Memory: 0x00 = %10d", CPU.Data_Memory.memory[0]);
    $fdisplay(outfile, "Data Memory: 0x04 = %10d", CPU.Data_Memory.memory[1]);
    $fdisplay(outfile, "Data Memory: 0x08 = %10d", CPU.Data_Memory.memory[2]);
    $fdisplay(outfile, "Data Memory: 0x0C = %10d", CPU.Data_Memory.memory[3]);
    $fdisplay(outfile, "Data Memory: 0x10 = %10d", CPU.Data_Memory.memory[4]);
    $fdisplay(outfile, "Data Memory: 0x14 = %10d", CPU.Data_Memory.memory[5]);
    $fdisplay(outfile, "Data Memory: 0x18 = %10d", CPU.Data_Memory.memory[6]);
    $fdisplay(outfile, "Data Memory: 0x1C = %10d", CPU.Data_Memory.memory[7]);

    $fdisplay(outfile, "\n");

    counter = counter + 1;


end
endmodule