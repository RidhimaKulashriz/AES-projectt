module aes_dec #(parameter KEY_SIZE = 128) (
  input                       clk,
  input                       start,
  input                       rst,
  input       [127:0]         ct,
  input       [KEY_SIZE-1:0]  key,
  output reg  [127:0]         pt,
  output reg                  done
);

parameter ROUNDS = (KEY_SIZE == 128) ? 10 : (KEY_SIZE == 192) ? 12 : 14;

wire [(ROUNDS+1)*128-1:0] w;
wire [127:0] r_in[0:ROUNDS-1];
(* KEEP = "TRUE" *)  reg  [127:0] ct_reg;
wire [127:0] pt_comb;

always @(posedge clk or negedge rst) begin
  if(!rst) begin
    ct_reg <= 'b0;
    pt <= 'b0;
    done <= 1'b0;
  end
  else if(start) begin
    ct_reg <= ct;
    done <= 1'b1;
  end
  else if(done) begin
    pt <= pt_comb;
    done <= 1'b0;
  end
  else begin
    ct_reg <= ct_reg;
    pt <= pt;
  end
end



key_gen #(.KEY_SIZE(KEY_SIZE), .ROUNDS(ROUNDS)) k (.key(key), .w(w));
add_rk #(.WIDTH(128)) add0 (.in1(ct), .in2(w[127:0]), .out(r_in[0]));


genvar i;
generate
  for(i=0; i<ROUNDS; i=i+1) begin
    if(i+1 == ROUNDS) begin // last round
      dec_round #(.ROUND(i+1), .ROUNDS(ROUNDS)) lr(

      .in(r_in[i]),
      .key(w[127 + 128*(i+1) : 128*(i+1)]),
      .out(pt_comb)

      ); 
    end
    else begin
      dec_round #(.ROUND(i+1), .ROUNDS(ROUNDS)) r(

      .in(r_in[i]),
      .key(w[127 + 128*(i+1) : 128*(i+1)]),
      .out(r_in[i+1])

      );
    end
  end
endgenerate



  
endmodule