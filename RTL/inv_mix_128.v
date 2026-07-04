module inv_mix_128 (
  input [127:0] in,
  output [127:0] out
);

inv_mix_32 m0(.in_col(in[127:96]), .out_col(out[127:96]));
inv_mix_32 m1(.in_col(in[95:64]), .out_col(out[95:64]));
inv_mix_32 m2(.in_col(in[63:32]), .out_col(out[63:32]));
inv_mix_32 m3(.in_col(in[31:0]), .out_col(out[31:0]));


endmodule