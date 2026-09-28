`timescale 1ns / 1ps

module sqrt (
    input             clk_i,
    input             rst_i,
    input      [8:0]  x_bi,
    input             start_i,
    output            busy_o,
    output reg [7:0]  y_bo
);

    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;

    reg         state;
    reg  [9:0]  x;      
    reg  [9:0]  y;      
    reg  [9:0]  m;
    wire [9:0]  y_shifted;   
    wire [9:0]  b_tmp;    
    wire        end_step;

    assign y_shifted = y >> 1;   
    assign b_tmp     = y | m;    
    assign end_step  = (m == 10'd0);
    assign busy_o = state;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state <= IDLE;
            x     <= 10'd0;
            y     <= 10'd0;
            m     <= 10'd0;
            y_bo  <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_i) begin
                        state <= WORK;
                        x     <= {1'b0, x_bi};
                        y     <= 10'd0;
                        m     <= 10'b01_0000_0000;
                        y_bo  <= 8'd0;
                    end
                end
                WORK: begin
                    if (end_step) begin
                        state <= IDLE;
                        y_bo  <= y[7:0];
                    end else begin
                        if (x >= b_tmp) begin
                            x <= x - b_tmp;
                            y <= y_shifted | m;
                        end else begin
                            y <= y_shifted;
                        end
                        m <= m >> 2;
                    end
                end
            endcase
        end
    end

endmodule