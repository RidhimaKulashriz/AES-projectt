module aes_enc #(parameter KEY_SIZE = 128) (
  input                       clk,
  input                       start,
  input                       rst,
  input       [127:0]         pt,
  input       [KEY_SIZE-1:0]  key,
  output reg  [127:0]         ct,
  output reg                  done
);

parameter ROUNDS = (KEY_SIZE == 128) ? 10 : (KEY_SIZE == 192) ? 12 : 14;

wire [(ROUNDS+1)*128-1:0] w;
wire [127:0] r_in[0:ROUNDS-1];
(* KEEP = "TRUE" *)  reg  [127:0] pt_reg;
wire [127:0] ct_comb;

always @(posedge clk or negedge rst) begin
  if(!rst) begin
    pt_reg <= 'b0;
    ct <= 'b0;
    done <= 1'b0;
  end
  else if(start) begin
    pt_reg <= pt;
    done <= 1'b1;
  end
  else if(done) begin
    ct <= ct_comb;
    done <= 1'b0;
  end
  else begin
    pt_reg <= pt_reg;
    ct <= ct;
  end
end

key_gen #(.KEY_SIZE(KEY_SIZE), .ROUNDS(ROUNDS)) k (.key(key), .w(w));
add_rk #(.WIDTH(128)) add0 (.in1(pt_reg), .in2(w[(ROUNDS+1)*128-1 : ROUNDS*128]), .out(r_in[0]));


genvar i;
generate
  for(i=0; i<ROUNDS; i=i+1) begin
    if(i+1 == ROUNDS) begin // last round
      enc_round #(.ROUND(i+1), .ROUNDS(ROUNDS)) lr (

      .in(r_in[i]),
      .key(w[(ROUNDS*128)-1 - 128*i : (ROUNDS*128)-128 - 128*i]),
      .out(ct_comb)

      );
    end
    else begin
      enc_round #(.ROUND(i+1), .ROUNDS(ROUNDS)) r (

      .in(r_in[i]),
      .key(w[(ROUNDS*128)-1 - 128*i : (ROUNDS*128)-128 - 128*i]),
      .out(r_in[i+1])

      );
    end
  end
endgenerate

  
endmodule