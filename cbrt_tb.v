`timescale 1ns / 1ps

module test ();
    reg [7:0] a_bi;
    reg clk_i, rst_i, start_i;
    wire busy;
    wire [3:0] out;
    
    cbrt uut(.clk(clk_i), .reset(rst_i), .start(start_i), 
             .a(a_bi), .busy(busy), .root(out));

    always #5 clk_i = ~clk_i;

    reg [11:0] test_vectors [0:7];
    integer i, error_count;
    
    initial begin
        $dumpfile("cbrt_tb.vcd");
        $dumpvars(0, test);

        test_vectors[0] = {8'd8,   4'd2};   // 8 = 2
        test_vectors[1] = {8'd28,  4'd3};   // 28 = 3
        test_vectors[2] = {8'd64,  4'd4};   // 64 = 4
        test_vectors[3] = {8'd125, 4'd5};   // 125 = 5
        test_vectors[4] = {8'd215, 4'd5};   // 215 = 5
        test_vectors[5] = {8'd1,   4'd1};   // 1 = 1
        test_vectors[6] = {8'd0,   4'd0};   // 0 = 0
        test_vectors[7] = {8'd255, 4'd6};   // 255 ≈ 6 (
        
        clk_i = 1'b0; 
        rst_i = 1'b1; 
        error_count = 0;
        #20;
        
        for (i = 0; i < 8; i = i + 1) begin
            rst_i = 1'b1;
            #10;
            rst_i = 1'b0;
            #10;
            
            a_bi = test_vectors[i][11:4];  
            start_i = 1'b1;
            #10;
            start_i = 1'b0;
            
            wait(busy == 1'b0);
            #10;
            
            if (out === test_vectors[i][3:0]) begin
                $display("TEST %0d PASS: %d^(1/3) = %d", i+1, a_bi, out);
            end else begin
                $display("TEST %0d FAIL: %d^(1/3) = %d (expected %d)", 
                         i+1, a_bi, out, test_vectors[i][3:0]);
                error_count = error_count + 1;
            end
        end
        
        $display("----------------------------------------");
        if (error_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("FAILED: %0d of %0d tests failed", error_count, 8);
        end
        
        $finish;
    end
endmodule