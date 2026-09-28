`timescale 1ns / 1ps
`include "mult.v"

module cbrt(
	input 		clk,
    input 		reset,
    input [7:0] a,
    input 		start,
	output 		busy,
    output reg [3:0] root
);

    reg  [7:0] 	a_mul, b_mul;
    wire [15:0] y_mul;
    reg 		mult_start;
    wire 		mult_busy;
        
    mult mul(
        .clk(clk),
        .reset(reset),
        .start(mult_start),
        .a(a_mul),
        .b(b_mul),
        .busy(mult_busy),
        .product(y_mul)
    );

    localparam  IDLE 		   = 3'd0;
    localparam  EXIT_CONDITION = 3'd1;
    localparam  MUL1_START     = 3'd2;
    localparam  MUL2_START	   = 3'd3;
    localparam  WAIT_MUL	   = 3'd4;
    localparam  UPDATE_XY 	   = 3'd5;

    reg [7:0]  s;
    wire 	   end_step;
    reg [7:0]  x;

    reg [31:0] y, tmp, sum; 
    reg [4:0]  state;
    wire [31:0] b;

    assign end_step = (s == -8'd3);
    assign busy = (state != IDLE);
    assign b = sum << s;

    always@(posedge clk) begin
        if(reset) begin
            root <= 0;
            state <= IDLE;
        end
        else begin
            case (state)
            IDLE:
                begin
                    if(start) begin
                        mult_start <= 0;
                        x <= a;
                        s <= 30;
                        y <= 0;
                        state <= EXIT_CONDITION;
                    end
                end

            EXIT_CONDITION:
                begin
                    if(end_step) begin
                        state <= IDLE;
                        root <= y;
                    end else begin
                        y <= y << 1;
                        state <= MUL1_START;
                    end
                end

            MUL1_START:
                begin
                    state <= MUL2_START;
                    a_mul <= (y << 1) + y;
                    b_mul <= y + 1;
                    mult_start <= 1;
                end

            MUL2_START:
                begin
                    mult_start <= 0;
                    state <= WAIT_MUL;
                end

            WAIT_MUL:
                begin
                    if(~mult_busy) begin
                        state <= UPDATE_XY;
                        sum <= y_mul + 1;
                    end
                end

            UPDATE_XY:
                    begin                 
                        if (x >= b) begin        
                            x <= x - b;          
                            y <= y + 1;                   
                        end
                        s <= s - 3;                       
                        state <= EXIT_CONDITION;
                    end
            endcase
        end
    end
endmodule