module carry_lookahead #(parameter WIDTH = 4) (
    input wire [WIDTH-1:0] g,  // Generate signals
    input wire [WIDTH-1:0] p,  // Propagate signals
    input wire cin,
    output wire [WIDTH-1:0] c  // Carry signals
);
    wire [WIDTH:0] carry;

    assign carry[0] = cin;
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: carry_gen
            assign carry[i+1] = g[i] | (p[i] & carry[i]);
        end
    endgenerate

    assign c = carry[WIDTH-1:0];
endmodule
