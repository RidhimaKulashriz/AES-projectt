module aes_top (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input select,
    input load,
    input cmd,        // Command (0=Encrypt, 1=Decrypt) - Currently only Encrypt works
    input start,
    output reg done,
    output reg busy,
    output [127:0] data_out
);

    // ----------------------------------------------
    // Internal Registers for User Data
    // ----------------------------------------------
    reg [127:0] key_reg;
    reg [127:0] text_reg;
    reg [3:0] byte_cnt;
    reg core_start;
    wire core_done;
    wire [127:0] core_out;

    // ----------------------------------------------
    // AES Encryption Core (Positional Mapping)
    // Order: clk, rst, start, plain_text, key, cipher_text, done
    // ----------------------------------------------
    aes_enc u_enc (clk, rst_n, core_start, text_reg, key_reg, core_out, core_done);

    assign data_out = core_out;

    // ----------------------------------------------
    // Finite State Machine (FSM)
    // ----------------------------------------------
    reg [2:0] state;
    localparam IDLE      = 3'b000,
               STORE     = 3'b001,
               RUN       = 3'b010,
               WAIT_CORE = 3'b011,
               DONE_ST   = 3'b100;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            key_reg <= 128'd0;
            text_reg <= 128'd0;
            byte_cnt <= 4'd0;
            core_start <= 1'b0;
            done <= 1'b0;
            busy <= 1'b0;
        end else begin
            core_start <= 1'b0; // Default: only pulse for 1 cycle

            case (state)
                IDLE: begin
                    done <= 1'b0;
                    busy <= 1'b0;
                    byte_cnt <= 4'd0;
                    if (start && (byte_cnt == 4'd15)) 
                        state <= RUN;
                    else 
                        state <= STORE;
                end

                STORE: begin
                    if (load) begin
                        if (select == 1'b0) // 0 = KEY mode
                            key_reg[ (byte_cnt*8) +: 8 ] <= data_in;
                        else                // 1 = TEXT mode
                            text_reg[ (byte_cnt*8) +: 8 ] <= data_in;
                            
                        if (byte_cnt < 4'd15)
                            byte_cnt <= byte_cnt + 1'b1;
                    end
                    
                    if (start && (byte_cnt == 4'd15))
                        state <= RUN;
                    else
                        state <= STORE;
                end

                RUN: begin
                    busy <= 1'b1;
                    core_start <= 1'b1; // Pulse start to AES core
                    state <= WAIT_CORE;
                end

                WAIT_CORE: begin
                    busy <= 1'b1;
                    if (core_done) 
                        state <= DONE_ST;
                end

                DONE_ST: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    if (!start) 
                        state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule