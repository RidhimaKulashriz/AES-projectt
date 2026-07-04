`timescale 1ns / 1ps

module tb_aes_top();
    reg clk, rst_n;
    reg [7:0] data_in;
    reg select, load, cmd, start;
    wire done, busy;
    wire [127:0] data_out;

    // Instantiate the Top Module
    aes_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .select(select),
        .load(load),
        .cmd(cmd),
        .start(start),
        .done(done),
        .busy(busy),
        .data_out(data_out)
    );

    // Clock Generation (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        data_in = 0;
        select = 0;
        load = 0;
        cmd = 0;      // 0 = Encrypt
        start = 0;

        // Release Reset
        #20;
        rst_n = 1;
        #10;

        // =============================================
        // STEP 1: User types the KEY (128-bit)
        // select = 0 for Key mode
        // Key = 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
        // =============================================
        select = 0;
        
        data_in = 8'h00; load = 1; #10; load = 0; #10;
        data_in = 8'h01; load = 1; #10; load = 0; #10;
        data_in = 8'h02; load = 1; #10; load = 0; #10;
        data_in = 8'h03; load = 1; #10; load = 0; #10;
        data_in = 8'h04; load = 1; #10; load = 0; #10;
        data_in = 8'h05; load = 1; #10; load = 0; #10;
        data_in = 8'h06; load = 1; #10; load = 0; #10;
        data_in = 8'h07; load = 1; #10; load = 0; #10;
        data_in = 8'h08; load = 1; #10; load = 0; #10;
        data_in = 8'h09; load = 1; #10; load = 0; #10;
        data_in = 8'h0A; load = 1; #10; load = 0; #10;
        data_in = 8'h0B; load = 1; #10; load = 0; #10;
        data_in = 8'h0C; load = 1; #10; load = 0; #10;
        data_in = 8'h0D; load = 1; #10; load = 0; #10;
        data_in = 8'h0E; load = 1; #10; load = 0; #10;
        data_in = 8'h0F; load = 1; #10; load = 0; #10;

        // =============================================
        // STEP 2: User types the TEXT (128-bit)
        // select = 1 for Text mode
        // Text = 00 11 22 33 44 55 66 77 88 99 AA BB CC DD EE FF
        // =============================================
        select = 1;
        
        data_in = 8'h00; load = 1; #10; load = 0; #10;
        data_in = 8'h11; load = 1; #10; load = 0; #10;
        data_in = 8'h22; load = 1; #10; load = 0; #10;
        data_in = 8'h33; load = 1; #10; load = 0; #10;
        data_in = 8'h44; load = 1; #10; load = 0; #10;
        data_in = 8'h55; load = 1; #10; load = 0; #10;
        data_in = 8'h66; load = 1; #10; load = 0; #10;
        data_in = 8'h77; load = 1; #10; load = 0; #10;
        data_in = 8'h88; load = 1; #10; load = 0; #10;
        data_in = 8'h99; load = 1; #10; load = 0; #10;
        data_in = 8'hAA; load = 1; #10; load = 0; #10;
        data_in = 8'hBB; load = 1; #10; load = 0; #10;
        data_in = 8'hCC; load = 1; #10; load = 0; #10;
        data_in = 8'hDD; load = 1; #10; load = 0; #10;
        data_in = 8'hEE; load = 1; #10; load = 0; #10;
        data_in = 8'hFF; load = 1; #10; load = 0; #10;

        // =============================================
        // STEP 3: Press START to begin Encryption
        // =============================================
        #20;
        start = 1;      // Press GO button
        #10;
        start = 0;      // Release GO button

        // =============================================
        // STEP 4: Wait for Done and Print Result
        // =============================================
        #1000; // Wait for processing to finish (AES takes a few hundred ns)
        
        // Wait for done signal to go high
        @(posedge done);
        #20;
        
        // Print the final encrypted result
        $display("==========================================");
        $display("Encryption Complete!");
        $display("Output Cipher Text: %h", data_out);
        $display("==========================================");
        
        #100;
        $finish;
    end
endmodule