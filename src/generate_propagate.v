module generate_propagate #(parameter WIDTH = 4) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] g,  // Generate signals
    output wire [WIDTH-1:0] p   // Propagate signals
);
    assign g = a & b;           // Generate signal: G_i = A_i & B_i
    assign p = a ^ b;           // Propagate signal: P_i = A_i ^ B_i
endmodule
