`timescale 1ns / 1ps

module test ();
    reg  [9:0] a_bi;
    reg        clk_i, rst_i, start_i;
    wire       busy;
    wire [5:0] out;

    sqrt #(.N(10)) uut (
        .clk(clk_i),
        .reset(rst_i),
        .start(start_i),
        .a(a_bi),
        .busy(busy),
        .root(out)
    );

    always #5 clk_i = ~clk_i;

    reg [15:0] test_vectors [0:11];
    integer i, error_count, exp_root, xin;

    initial begin
        $dumpfile("sqrt_tb.vcd");
        $dumpvars(0, test);

        test_vectors[0]  = {10'd0,   6'd0};   
        test_vectors[1]  = {10'd1,   6'd1};   
        test_vectors[2]  = {10'd2,   6'd1};   
        test_vectors[3]  = {10'd3,   6'd1};   
        test_vectors[4]  = {10'd4,   6'd2};   
        test_vectors[5]  = {10'd8,   6'd2};   
        test_vectors[6]  = {10'd9,   6'd3};   
        test_vectors[7]  = {10'd15,  6'd3};   
        test_vectors[8]  = {10'd16,  6'd4};   
        test_vectors[9]  = {10'd255, 6'd15};  
        test_vectors[10] = {10'd256, 6'd16};  
        test_vectors[11] = {10'd261, 6'd16};

        clk_i = 1'b0;
        rst_i = 1'b1;
        start_i = 1'b0;
        a_bi = 10'd0;
        error_count = 0;
        #20;

        for (i = 0; i < 12; i = i + 1) begin
            rst_i = 1'b1;
            #10;
            rst_i = 1'b0;
            #10;

            a_bi    = test_vectors[i][15:6];
            exp_root = test_vectors[i][5:0];
            start_i = 1'b1;
            #10;
            start_i = 1'b0;

            wait (busy == 1'b0);
            #10;

            if (out === exp_root[5:0]) begin
                $display("TEST %0d PASS: sqrt(%0d) = %0d", i+1, a_bi, out);
            end else begin
                $display("TEST %0d FAIL: sqrt(%0d) = %0d (expected %0d)",
                         i+1, a_bi, out, exp_root);
                error_count = error_count + 1;
            end
        end

        $display("----------------------------------------");
        if (error_count == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("FAILED: %0d error(s)", error_count);

        $finish;
    end
endmodule
