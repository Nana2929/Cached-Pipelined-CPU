/*
module Equal(data1_i, data2_i, isequal_o);
input [31:0] data1_i, data2_i;
output isequal_o;
assign isequal_o = (data1_i == data2_i) ? 1'b1:1'b0;
endmodule

module ANDer(sig1_i, sig2_i, ANDresult_o);
input sig1_i, sig2_i;
output ANDresult_o;
assign ANDresult_o = sig1_i & sig2_i;
endmodule
*/
module Shifter(data_i, data_o);
input [31:0] data_i;
output [31:0] data_o;
assign data_o = data_i << 1'b1;
endmodule