`timescale 1ns / 1ps

module test ();
    reg         clk_i, rst_i, start_i;
    reg  [7:0]  a_bi, b_bi;
    wire        busy;
    wire [4:0]  y_bo;

    func_calc uut (
        .clk(clk_i),
        .reset(rst_i),
        .start(start_i),
        .a(a_bi),
        .b(b_bi),
        .busy(busy),
        .y(y_bo)
    );

    always #5 clk_i = ~clk_i;

    reg [20:0] test_vectors [0:11];
    integer i, error_count, ai, bi, expected;

    initial begin
        $dumpfile("func_calc_tb.vcd");
        $dumpvars(0, test);

        test_vectors[0]  = {8'd0,   8'd0,   5'd0};
        test_vectors[1]  = {8'd0,   8'd1,   5'd1};
        test_vectors[2]  = {8'd1,   8'd0,   5'd1};
        test_vectors[3]  = {8'd3,   8'd8,   5'd2}; 
        test_vectors[4]  = {8'd7,   8'd27,  5'd3};
        test_vectors[5]  = {8'd12,  8'd64,  5'd4};
        test_vectors[6]  = {8'd0,   8'd255, 5'd2};
        test_vectors[7]  = {8'd255, 8'd0,   5'd15}; 
        test_vectors[8]  = {8'd250, 8'd215, 5'd15};
        test_vectors[9]  = {8'd255, 8'd1,   5'd16};
        test_vectors[10] = {8'd255, 8'd8,   5'd16}; 
        test_vectors[11] = {8'd255, 8'd255, 5'd16};

        clk_i = 1'b0;
        rst_i = 1'b1;
        start_i = 1'b0;
        a_bi = 8'd0;
        b_bi = 8'd0;
        error_count = 0;
        #20;
        rst_i = 1'b0;
        #10;

        for (i = 0; i < 12; i = i + 1) begin
            rst_i = 1'b1;
            #10;
            rst_i = 1'b0;
            #10;

            a_bi = test_vectors[i][20:13];
            b_bi = test_vectors[i][12:5];
            expected = test_vectors[i][4:0];

            start_i = 1'b1;
            #10;
            start_i = 1'b0;

            wait (busy == 1'b0);
            #10;

            if (y_bo === expected[4:0]) begin
                $display("TEST %0d PASS: y=sqrt(%0d+cbrt(%0d)) = %0d",
                         i+1, a_bi, b_bi, y_bo);
            end else begin
                $display("TEST %0d FAIL: y=sqrt(%0d+cbrt(%0d)) = %0d (expected %0d)",
                         i+1, a_bi, b_bi, y_bo, expected);
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
