// Modules provided by TA
// [!] comment out in submission
`include "./Modules/Registers.v"
`include "./Modules/PC.v"
`include "./Modules/Instruction_Memory.v"
// hw3
`include "./CPU/Adder.v"
`include "./CPU/Sign_Extend.v"
`include "./CPU/MUX32.v"
`include "./CPU/ALU_Control.v"
`include "./CPU/Control.v"
`include "./CPU/ALU.v"
// Newly added Units
`include "./CPU/ForwardingUnit.v"
`include "./CPU/HzDetectionUnit.v"
`include "./CPU/MUX4.v"
`include "./CPU/Utils.v"
// Pipeline Registers
`include "./CPU/IFID.v"
`include "./CPU/IDEX.v"
`include "./CPU/EXMEM.v"
`include "./CPU/MEMWB.v"

// Lab2
`include "./Dcache/dcache_controller.v"

// top-level module
module CPU(clk_i, rst_i, start_i,
    mem_data_i, mem_ack_i,
    mem_data_o, mem_addr_o, mem_enable_o, mem_write_o);

// CPU Ports: control signals
input               clk_i;
input               rst_i;
input              start_i;
wire [31:0] update_addr;  //input of PC
wire [31:0] addr;         // output of PC

// CPU Ports: connecting to off-chip data memory
input [255:0] mem_data_i;
input mem_ack_i;
output [255:0] mem_data_o;
output [31:0] mem_addr_o;
output mem_enable_o;
output mem_write_o;


wire [255:0] mem_to_dcache_data;
wire mem_to_dcache_ack;
// for write-back policy
wire [255:0] dcache_to_mem_data;
wire [31:0] dcache_to_mem_addr;
wire dcache_to_mem_enable;
wire dcache_to_mem_write;

assign mem_addr_o = dcache_to_mem_addr;
assign mem_enable_o = dcache_to_mem_enable;
assign mem_write_o = dcache_to_mem_write;
assign mem_data_o = dcache_to_mem_data;

assign mem_to_dcache_data = mem_data_i;
assign mem_to_dcache_ack = mem_ack_i;

// Control signals
wire [31:0] instr;
wire [1:0] ALUOp;
wire ALUSrc;
wire RegWrite;
wire MemtoReg;
wire MemRead;
wire MemWrite;
wire isBranch;

wire signed [31:0] data1;
wire signed [31:0] data2;

wire [31:0] ext_immed;
wire [31:0] Sext_immed;
wire toFlush;

wire NoOp, Stall, PCWrite;
wire [31:0] instr_2;
wire [31:0] IFpcvalue;
wire [31:0] BranchTarget;
wire [31:0] PCMUXvalue;

wire signed [31:0] ALUoperand1;
wire signed [31:0] ALUoperand2;
// IDEX
wire exRegWrite; // 1
wire exMemtoReg; // 1
wire exMemRead; // 1
wire exMemWrite; //1
wire [1:0] exALUOp;   //2
wire exALUSrc; //1
wire signed [31:0] exdata1, exdata2;
wire signed [31:0] exImm; // 32
wire [9:0] exfunc10; //10
wire [4:0] exrs1, exrs2;
wire [4:0] exRd, wbRd; // 5
wire signed [31:0] exALUResult;
wire signed [31:0] expreALUd2;
wire [2:0] ALUCtrlSig; // 3

wire memRegWrite, memMemtoReg, memMemRead, memMemWrite;
wire signed [31:0] mempreALUd2; //32
wire signed [31:0] memALUResult;
wire [4:0] memRd;
wire signed [31:0] memDCdata;
wire memStall;
wire wbRegWrite, wbMemtoReg;
wire signed [31:0] wbWriteData, wbALUResult, wbDMdata;
wire [1:0] ForwardA, ForwardB;
wire [31:0] const4;
assign const4 = 32'b100;

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .memStall_i (memStall),
    .stall_i (Stall),
    .PCWrite_i  (PCWrite),
    .pc_i       (PCMUXvalue),
    .pc_o       (addr)
);

// update PC value
Adder Add_PC(
    .data1_i    (addr),
    .data2_i    (const4),
    .data_o     (update_addr)  //update prev_addr; to be replaced in PC at clk posedge/reset negedge
);

assign toFlush = ((data1 == data2) && (isBranch));
MUX32 PCMUX(
    .data1_i (update_addr),
    .data2_i (BranchTarget),
    .select_i (toFlush),
    .data_o (PCMUXvalue));

Instruction_Memory Instruction_Memory(
    .addr_i     (addr),
    .instr_o    (instr)
);
//// IF/ID register
IFID IFID(
    .clk_i(clk_i),
    .Flush_i(toFlush),
    .Stall_i(Stall),
    .instr_i(instr),
    .nowPC_i(addr),
    .instr_o(instr_2),
    .PCval_o(IFpcvalue),
    //
    .memStall_i(memStall)
);
////
Control Control(
    .Op_i       (instr_2[6:0]),
    .NoOp_i     (NoOp),
    .ALUOp_o    (ALUOp),
    .ALUSrc_o   (ALUSrc),
    .RegWrite_o (RegWrite),
    .MemtoReg_o (MemtoReg),
    .MemRead_o (MemRead),
    .MemWrite_o (MemWrite),
    .Branch_o (isBranch)
);
Registers Registers(
    .clk_i      (clk_i),
    .RS1addr_i   (instr_2[19:15]),
    .RS2addr_i   (instr_2[24:20]),
    .RDaddr_i   (wbRd),
    .RDdata_i   (wbWriteData),      // will be written if RegWriteSig is on and data is available
    .RegWrite_i (wbRegWrite),       // Brought from MEM/WB stage
    .RS1data_o   (data1),
    .RS2data_o   (data2)
);
// !!!! check immediate fields (every instruction format's differs)!!!!
Sign_Extend Sign_Extend(
    .data_i     (instr_2),
    .data_o     (ext_immed)
);
HzDetectionUnit HzDetectionUnit(
    .EXMemRead_i (exMemRead),
    .EXRd_i (exRd),
    .IDRs1_i (instr_2[19:15]),
    .IDRs2_i (instr_2[24:20]),
    .NoOp_o (NoOp),  // 要接到Control
    .Stall_o (Stall), // 要接到IF/ID
    .PCWrite_o(PCWrite)
);

Shifter Shifter(
    .data_i(ext_immed),
    .data_o(Sext_immed)
);

Adder Bh_Adder(
    .data1_i (IFpcvalue),
    .data2_i (Sext_immed),
    .data_o (BranchTarget));

//// ID/EX register
IDEX IDEX(
    .clk_i(clk_i),
    .idRegWrite_i(RegWrite),
    .idMemtoReg_i(MemtoReg),
    .idMemRead_i(MemRead),
    .idMemWrite_i(MemWrite),
    .idALUOp_i(ALUOp),
    .idALUSrc_i(ALUSrc),
    .iddata1_i(data1),
    .iddata2_i(data2),
    .idImm_i(ext_immed),
    .idfunc10_i({instr_2[31:25], instr_2[14:12]}),
    .idrs1_i(instr_2[19:15]),
    .idrs2_i(instr_2[24:20]),
    .idRd_i(instr_2[11:7]),
    .exRegWrite_o(exRegWrite), // declare wires to 接住
    .exMemtoReg_o(exMemtoreg), // ...
    .exMemRead_o(exMemRead),
    .exMemWrite_o(exMemWrite),
    .exALUOp_o(exALUOp),
    .exALUSrc_o(exALUSrc),
    .exdata1_o(exdata1),
    .exdata2_o(exdata2),
    .exImm_o(exImm),
    .exfunc10_o(exfunc10),
    .exrs1_o(exrs1),
    .exrs2_o(exrs2),
    .exRd_o(exRd),
    //
    .memStall_i(memStall)
);
////
// decide whether the op is immediate or not
// A, data1_i: regB
// B, data2_i: immed
// 1.3 the two MUX4

MUX4 MUX_ALU1(
    .exdata_i  (exdata1),    // 00
    .wbWriteData_i (wbWriteData),// 01
    .memALUResult_i (memALUResult), // 10
    .select_i    (ForwardA),   //ForwardA
    .data_o      (ALUoperand1)
);
MUX4 MUX_ALU2(
    .exdata_i  (exdata2),
    .wbWriteData_i (wbWriteData),
    .memALUResult_i (memALUResult),
    .select_i    (ForwardB),   //ForwardB
    .data_o      (expreALUd2)
);
////
MUX32 MUX_ALUSrc(
    .data1_i    (expreALUd2),
    .data2_i    (exImm),
    .select_i   (exALUSrc),
    .data_o     (ALUoperand2)
);

ALU_Control ALU_Control(
    .funct_i    (exfunc10),
    .ALUOp_i    (exALUOp),
    .ALUCtrl_o  (ALUCtrlSig)
);

// wire isZero;
// isZero is removed because branch-instruction-or-not determination
// is now moved to Instruction Decoding stage
ALU ALU(
    .data1_i    (ALUoperand1),
    .data2_i    (ALUoperand2),
    .ALUCtrl_i  (ALUCtrlSig),
    .data_o     (exALUResult) // pass into EX/MEM pipeline reg
);

//// EX/MEM stage
EXMEM EXMEM(
    .clk_i(clk_i),
    .exRegWrite(exRegWrite),
    .exMemtoReg(exMemtoreg),
    .exMemRead(exMemRead),
    .exMemWrite(exMemWrite),
    .exALUresult(exALUResult),
    .expreALUd2(expreALUd2),
    .exRd(exRd),
    .memRegWrite(memRegWrite),
    .memMemtoReg(memMemtoReg),
    .memMemRead(memMemRead),
    .memMemWrite(memMemWrite),
    .memALUresult(memALUResult),
    .mempreALUd2(mempreALUd2),
    .memRd(memRd),
    //
    .memStall_i(memStall)
);
////

dcache_controller dcache
(
    .clk_i (clk_i),
    .rst_i (rst_i),

    // to Data Memory interface
    .mem_data_i (mem_to_dcache_data),
    .mem_ack_i (mem_to_dcache_ack),
    .mem_data_o (dcache_to_mem_data),
    .mem_addr_o (dcache_to_mem_addr),
    .mem_enable_o (dcache_to_mem_enable),
    .mem_write_o (dcache_to_mem_write),

    // to CPU interface
    .cpu_data_i (mempreALUd2),
    .cpu_addr_i (memALUResult),
    .cpu_MemRead_i (memMemRead),
    .cpu_MemWrite_i (memMemWrite),
    .cpu_data_o (memDCdata),
    .cpu_stall_o (memStall)
);

//// MEM/WB stage
MEMWB MEMWB(
    .clk_i(clk_i),
    .memRegWrite(memRegWrite),
    .memMemtoReg(memMemtoReg),
    .memALUResult(memALUResult),
    .memDMdata(memDCdata),
    .memRd(memRd),
    .wbRegWrite(wbRegWrite),
    .wbMemtoReg(wbMemtoReg),
    .wbALUResult(wbALUResult),
    .wbDMdata(wbDMdata),
    .wbRd(wbRd),
    // stall
    .memStall_i(memStall)
);

////
MUX32 MUX_MemtoReg(
    .data1_i    (wbALUResult),  // ALU result
    .data2_i    (wbDMdata),     // Data Memory's data_o
    .select_i   (wbMemtoReg),   // MemtoReg signal
    .data_o     (wbWriteData)   // if MemtoReg =1 , let data2_i passes
);

// 1.3 Forwarding Unit
FWUnit FW(
    .memRegWrite_i (memRegWrite),
    .memRd_i       (memRd),
    .wbRegWrite_i  (wbRegWrite),
    .wbRd_i        (wbRd),
    .exRs1_i       (exrs1),
    .exRs2_i       (exrs2),
    .ForwardA_o    (ForwardA),
    .ForwardB_o    (ForwardB)
);
endmodule