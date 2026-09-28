`timescale 1ns / 1ps
`include "addr.v"

module sqrt #(parameter N = 10)(
    input              clk,
    input              reset,
    input              start,
    input  [N-1:0]     a,
    output             busy,
    output reg [N/2:0] root
);

    reg  [N:0] add_a, add_b;
    wire [N:0] add_sum;
    addr #(.WIDTH(N+1)) u_add (.a(add_a), .b(add_b), .sum(add_sum));

    localparam IDLE     = 3'd0;
    localparam CHECK    = 3'd1;
    localparam BODY     = 3'd2;
    localparam WAIT_SUB = 3'd3;
    localparam SHIFT_M  = 3'd4;

    reg [2:0]   state;
    reg [N-1:0] x;
    reg [N-1:0] y;
    reg [N-1:0] y_shifted;
    reg [N-1:0] m;
    wire [N-1:0] b;

    assign busy = (state != IDLE);
    assign b    = y | m;

    always @(posedge clk) begin
        if (reset) begin
            state     <= IDLE;
            root      <= 0;
            x         <= 0;
            y         <= 0;
            y_shifted <= 0;
            m         <= 0;
            add_a     <= 0;
            add_b     <= 0;
        end else begin
            case (state)

                IDLE: begin
                    if (start) begin
                        x     <= a;
                        y     <= {N{1'b0}};
                        m     <= {{(N-1){1'b0}}, 1'b1} << (N-2);
                        root  <= 0;
                        state <= CHECK;
                    end
                end

                CHECK: begin
                    if (m == {N{1'b0}}) begin
                        root  <= y[N/2:0];
                        state <= IDLE;
                    end else begin
                        state <= BODY;
                    end
                end

                BODY: begin
                    y_shifted <= y >> 1;
                    if (x >= b) begin
                        add_a <= {1'b0, x};
                        add_b <= ~{1'b0, b} + {{N{1'b0}}, 1'b1};
                        state <= WAIT_SUB;
                    end else begin
                        y     <= y >> 1;
                        state <= SHIFT_M;
                    end
                end

                WAIT_SUB: begin
                    x     <= add_sum[N-1:0];
                    y     <= y_shifted | m;
                    state <= SHIFT_M;
                end

                SHIFT_M: begin
                    m     <= m >> 2;
                    state <= CHECK;
                end

            endcase
        end
    end
endmodule
