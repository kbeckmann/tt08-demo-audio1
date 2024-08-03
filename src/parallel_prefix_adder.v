module parallel_prefix_adder #(parameter WIDTH = 4) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire cin,
    output wire [WIDTH-1:0] sum,
    output wire cout
);
    wire [WIDTH-1:0] g;  // Generate signals
    wire [WIDTH-1:0] p;  // Propagate signals
    wire [WIDTH-1:0] c;  // Carry signals

    // Generate and propagate signals
    generate_propagate #(WIDTH) gp (
        .a(a),
        .b(b),
        .g(g),
        .p(p)
    );

    // Carry lookahead logic
    carry_lookahead #(WIDTH) cla (
        .g(g),
        .p(p),
        .cin(cin),
        .c(c)
    );

    // Sum and carry-out computation
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: sum_gen
            full_adder fa (
                .a(a[i]),
                .b(b[i]),
                .cin(c[i]),
                .sum(sum[i]),
                .cout()  // Unused
            );
        end
    endgenerate

    assign cout = c[WIDTH]; // Final carry-out
endmodule
