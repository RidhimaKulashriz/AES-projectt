module inv_subs_bytes (
  input   [127:0] in,
  output  [127:0] out
);


genvar i;
generate
  for (i=0; i<16; i=i+1) begin
    inv_sbox s0 (.in(in[8*i+7 : 8*i]), .out(out[8*i+7 : 8*i]) );
  end
endgenerate



  
endmodule