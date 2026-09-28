`timescale 1ns / 1ps

module test();

    reg  [15:0] a;
    reg  [15:0] b;
    wire [15:0] sum;

    addr #(.WIDTH(16)) adder(
		 .a(a), 
		 .b(b), 
		 .sum(sum)
	);

    initial begin
        $dumpfile("addr_tb.vcd");
        $dumpvars(0, test);

        // === ТЕСТ 1: 0 + 0 = 0 ===
        a = 16'd0;
        b = 16'd0;
        #10;
        $display("TEST 1: %d + %d = %d", a, b, sum);

   	    // === ТЕСТ 2: 7 + 1 = 8 ===
        a = 16'd7;
        b = 16'd1;
        #10;
        $display("TEST 2: %d + %d = %d", a, b, sum);

        // === ТЕСТ 3: 50000 + 10000 = 60000 ===
        a = 16'd50000;
        b = 16'd10000;
        #10;
        $display("TEST 3: %d + %d = %d", a, b, sum);

        // === ТЕСТ 4: 65535 + 1 = 0 (переполнение) ===
        a = 16'd65535;
        b = 16'd1;
        #10;
        $display("TEST 4: %d + %d = %d", a, b, sum);

        #10;
        $finish;
    end

endmodule