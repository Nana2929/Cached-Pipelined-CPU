// PC adder; PC = PC +4 (if branching, calc otherwise)
// Before simulating with Adder_tb, change the bit length to 5 and 10.
module Adder(data1_i, data2_i, data_o);
input [31:0] data1_i, data2_i;
output [31:0] data_o;

reg [31:0] data_o_reg;
always@(*)
begin
    data_o_reg = data1_i + data2_i;
end
assign data_o = data_o_reg;

endmodule
