module enc_round #(parameter ROUND = 1, ROUNDS = 10) (
  input [127:0] in,
  input [127:0] key,
  output [127:0] out
);

wire [127:0] post_subs;
wire [127:0] post_shift;
wire [127:0] post_mix;

generate
  if(ROUND == ROUNDS) begin

    subs_bytes sub (.in(in), .out(post_subs));
      
    shift_row shift (.in(post_subs), .out(post_shift));

    add_rk #(.WIDTH(128)) add (.in1(post_shift), .in2(key), .out(out));

  end
  else begin

    subs_bytes sub (.in(in), .out(post_subs));
      
    shift_row shift (.in(post_subs), .out(post_shift));

    mix_128 mix (.in(post_shift), .out(post_mix));

    add_rk #(.WIDTH(128)) add (.in1(post_mix), .in2(key), .out(out));

  end
endgenerate





endmodule