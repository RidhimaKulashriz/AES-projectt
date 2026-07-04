module inv_mix_32 (
  input [31:0] in_col,
  output [31:0] out_col
);

wire [7:0] a0,a1,a2,a3;
wire [7:0] b0,b1,b2,b3;
wire [7:0] b [0:15];

assign a0 = in_col[31:24];
assign a1 = in_col[23:16];
assign a2 = in_col[15:8];
assign a3 = in_col[7:0];


// Using M_General Blocks
M_General mul00(.op1(8'd14), .op2(a0), .result(b[0]));
M_General mul01(.op1(8'd11), .op2(a1), .result(b[1]));
M_General mul02(.op1(8'd13), .op2(a2), .result(b[2]));
M_General mul03(.op1(8'd9), .op2(a3), .result(b[3]));
M_General mul13(.op1(8'd9), .op2(a0), .result(b[4]));
M_General mul10(.op1(8'd14), .op2(a1), .result(b[5]));
M_General mul11(.op1(8'd11), .op2(a2), .result(b[6]));
M_General mul12(.op1(8'd13), .op2(a3), .result(b[7]));
M_General mul22(.op1(8'd13), .op2(a0), .result(b[8]));
M_General mul23(.op1(8'd9), .op2(a1), .result(b[9]));
M_General mul20(.op1(8'd14), .op2(a2), .result(b[10]));
M_General mul21(.op1(8'd11), .op2(a3), .result(b[11]));
M_General mul31(.op1(8'd11), .op2(a0), .result(b[12]));
M_General mul32(.op1(8'd13), .op2(a1), .result(b[13]));
M_General mul33(.op1(8'd9), .op2(a2), .result(b[14]));
M_General mul30(.op1(8'd14), .op2(a3), .result(b[15]));


assign b0 = b[0] ^ b[1] ^ b[2] ^ b[3];
assign b1 = b[4] ^ b[5] ^ b[6] ^ b[7];
assign b2 = b[8] ^ b[9] ^ b[10] ^ b[11];
assign b3 = b[12] ^ b[13] ^ b[14] ^ b[15];


assign out_col = {b0,b1,b2,b3};





endmodule
