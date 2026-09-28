`timescale 1ns / 1ps
`include "cbrt.v"
`include "sqrt.v"

module func_calc (
    input         clk,
    input         reset,
    input         start,
    input  [7:0]  a,
    input  [7:0]  b,
    output        busy,
    output reg [4:0] y
);

    localparam IDLE      = 3'd0;
    localparam WAIT_CBRT = 3'd1;
    localparam DO_ADD    = 3'd2;
    localparam WAIT_SQRT = 3'd3;
    localparam DONE      = 3'd4;

    reg [2:0] state;
    reg [7:0] a_reg, b_reg;
    reg       cbrt_armed, sqrt_armed;

    reg        cbrt_start;
    wire       cbrt_busy;
    wire [3:0] cbrt_root;
    cbrt u_cbrt (.clk(clk), .reset(reset), .start(cbrt_start), .a(b_reg), .busy(cbrt_busy), .root(cbrt_root));

    wire [9:0] add_sum;
    addr #(.WIDTH(10)) u_add (.a({2'b0, a_reg}), .b({6'b0, cbrt_root}), .sum(add_sum));

    reg         sqrt_start;
    wire        sqrt_busy;
    wire [5:0]  sqrt_root;
    sqrt #(.N(10)) u_sqrt (.clk(clk), .reset(reset), .start(sqrt_start), .a(add_sum), .busy(sqrt_busy), .root(sqrt_root));

    assign busy = (state != IDLE);

    always @(posedge clk) begin
        if (reset) begin
            state       <= IDLE;
            y           <= 5'd0;
            a_reg       <= 8'd0;
            b_reg       <= 8'd0;
            cbrt_start  <= 1'b0;
            sqrt_start  <= 1'b0;
            cbrt_armed  <= 1'b0;
            sqrt_armed  <= 1'b0;
        end else begin
            cbrt_start <= 1'b0;
            sqrt_start <= 1'b0;

            case (state)
                IDLE: begin
                    cbrt_armed <= 1'b0;
                    sqrt_armed <= 1'b0;
                    if (start) begin
                        a_reg      <= a;
                        b_reg      <= b;
                        cbrt_start <= 1'b1;
                        state      <= WAIT_CBRT;
                    end
                end

                WAIT_CBRT: begin
                    if (cbrt_busy)
                        cbrt_armed <= 1'b1;
                    if (cbrt_armed && !cbrt_busy) begin
                        sqrt_start <= 1'b1;
                        sqrt_armed <= 1'b0;
                        state      <= WAIT_SQRT;
                    end
                end

                WAIT_SQRT: begin
                    if (sqrt_busy)
                        sqrt_armed <= 1'b1;
                    if (sqrt_armed && !sqrt_busy) begin
                        y     <= sqrt_root[4:0];
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
