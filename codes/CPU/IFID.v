module IFID(clk_i, Flush_i, Stall_i, memStall_i,
            instr_i, nowPC_i, instr_o, PCval_o);
input clk_i, Flush_i, Stall_i, memStall_i;
input [31:0] instr_i, nowPC_i;
output reg [31:0] instr_o, PCval_o;
wire [31:0] harmless_op;
// sll r0, r0, 0
assign harmless_op = 32'b00000000000000000001000000110011;
/*
initial begin
    PCval_o = 32'b0;
    instr_o = 32'b0;
end
*/
// Logic: toFlush: wrong branch prediction
// Logic: Stall: load-use hazard detected by HzDetectionUnit
/*
Stall和NoOp會同時為1，因此control unit那裡會全部改0，
相當於洗掉後面的pipeline成noop。而flush則是洗掉ifid reg成為noop。
（請打開spec裡的圖）
*/
always @(posedge clk_i) begin
    // Flush的話要完全洗掉PC值成為sll r0 r0 0
    if (Flush_i) begin
        instr_o <= harmless_op;
        PCval_o <= nowPC_i;
    end
    //Stall的話會用同一個instruction兩次，所以PC不更新值，而NoOp（洗掉）會在Control Unit處理
    else if (~Stall_i && ~memStall_i) begin
        instr_o <= instr_i;
        PCval_o <= nowPC_i;
    end

end
endmodule



