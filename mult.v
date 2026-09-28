`timescale 1ns / 1ps

module mult (
    input		 clk,
    input        reset,
    input        start,
    input  [7:0] a,
    input  [7:0] b,
	output		 busy,
    output reg [15:0] product
);

    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;

    reg  [2:0]  ctr;          
    wire [2:0]  end_step;  
    wire [7:0] part_sum;      
    wire [15:0] shifted_part_sum;
    reg  [7:0]  A, B;     
    reg  [15:0] part_res;
    reg  		state;

    assign end_step = (ctr == 3'h7);
    assign part_sum = A & {8{B[ctr]}};
    assign shifted_part_sum = part_sum << ctr;
    assign busy = state;

    always @(posedge clk)
            if (reset) begin
                product <= 0;
                ctr <= 0;
                part_res <= 0;
                state <= IDLE;
            end else begin
                case (state)
                    IDLE :
                        if (start) begin
                            state <= WORK;
                            A <= a;
                            B <= b;
                            ctr <= 0;
                            part_res <= 0;
                        end
                    WORK:
                        begin
                            if (end_step) begin
                                state <= IDLE;
                                product <= part_res + shifted_part_sum;
                            end
                            part_res <= part_res + shifted_part_sum;
                            ctr <= ctr + 1;
                        end
                endcase
            end
endmodule