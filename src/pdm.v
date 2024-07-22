/*
 * Copyright (c) 2024 Konrad Beckmann
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module pdm(clk, rst_n, pdm_in, pdm_out);
    parameter N = 16;

    input clk;
    input rst_n;
    input [(N-1):0] pdm_in;
    output pdm_out;

    reg [N:0] accumulator_r;

    wire [N:0] accumulator_next = accumulator_r[(N-1):0] + pdm_in;

    always @(posedge clk) begin
        if (~rst_n) begin
            accumulator_r <= 0;
        end else begin
            accumulator_r <= accumulator_next;
        end
    end

    assign pdm_out = accumulator_r[N];

endmodule
