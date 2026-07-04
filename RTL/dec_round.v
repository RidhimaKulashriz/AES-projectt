module dec_round #(parameter ROUND = 1, ROUNDS = 10) (
  input [127:0] in,
  input [127:0] key,
  output [127:0] out
);

wire [127:0] post_subs;
wire [127:0] post_shift;
wire [127:0] post_rk;

generate
  if(ROUND == ROUNDS) begin

    inv_shift_row ishift (.in(in), .out(post_shift));
      
    inv_subs_bytes isub (.in(post_shift), .out(post_subs));

    add_rk #(.WIDTH(128)) add (.in1(post_subs), .in2(key), .out(out));
  
  end
  else begin

    inv_shift_row ishift (.in(in), .out(post_shift));

    inv_subs_bytes isub (.in(post_shift), .out(post_subs));

    add_rk #(.WIDTH(128)) add (.in1(post_subs), .in2(key), .out(post_rk));

    inv_mix_128 imix (.in(post_rk), .out(out));
  
  end
endgenerate





endmodule