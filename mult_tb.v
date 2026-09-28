`timescale 1ns / 1ps

module test ();
    reg [7:0] a_bi;
    reg [7:0] b_bi;
    
    reg clk_i;
    reg rst_i;
    reg start_i;
    
    wire busy;
    wire [15:0] out;
    
    mult uut(
        .clk(clk_i), 
        .reset(rst_i), 
        .start(start_i),
        .a(a_bi),
        .b(b_bi), 
        .busy(busy),
        .product(out)
    );

    always #5 clk_i = ~clk_i;

    reg [31:0] test_vectors [0:3];
    integer i, error_count;
    
    initial begin
        $dumpfile("mult_tb.vcd");
        $dumpvars(0, test);

        test_vectors[0] = {8'd8,   8'd8,   16'd64};     // 8 x 8 = 64
        test_vectors[1] = {8'd5,   8'd3,   16'd15};     // 5 x 3 = 15
        test_vectors[2] = {8'd255, 8'd255, 16'd65025};  // 255 x 255 = 65025
        test_vectors[3] = {8'd0,   8'd100, 16'd0};      // 0 x 100 = 0
        
        clk_i = 1'b0; 
        rst_i = 1'b1; 
        error_count = 0;
        #20;
        
        for (i = 0; i < 4; i = i + 1) begin
            rst_i = 1'b1;
            #10;
            rst_i = 1'b0;
            #10;

            a_bi = test_vectors[i][31:24];
			b_bi = test_vectors[i][23:16];
            start_i = 1'b1;
            
            #10;
            start_i = 1'b0;
            
            wait(busy == 1'b0);
            #10;
            
            if (out === test_vectors[i][15:0]) begin
                $display("TEST %0d PASS: %d x %d = %d", 
                         i+1, a_bi, b_bi, out);
            end else begin
                $display("TEST %0d FAIL: %d x %d = %d (expected %d)", 
                         i+1, a_bi, b_bi, out, test_vectors[i][15:0]);
                error_count = error_count + 1;
            end
        end
        
        $display("----------------------------------------");
        if (error_count == 0) begin
            $display("ALL TESTS PASSED!");
        end else begin
            $display("FAILED: %0d of %0d tests failed", error_count, 4);
        end
        
        $finish;
    end
endmodule