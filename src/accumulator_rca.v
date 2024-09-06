`default_nettype none

module accumulator_rca #(
    parameter ACC_WIDTH = 8,  // Parameter to define the bit width of the accumulator
    parameter ADD_WIDTH = 8   // Parameter to define the bit width of the value to be added
)(
    input wire clk,                        // Clock input
    input wire rst_n,                      // Active low reset
    input wire [ADD_WIDTH-1:0] add_value,  // Input value to be added to the accumulator
    output wire [ACC_WIDTH-1:0] data       // Output data (accumulator register)
);

    // Internal accumulator register
    reg [ACC_WIDTH-1:0] acc;
    wire [ACC_WIDTH-1:0] acc_new;
    wire cout;
    wire _unused_ok = cout;

    wire [ACC_WIDTH-1:0] extended_add_value;
    assign extended_add_value = { {ACC_WIDTH-ADD_WIDTH{1'b0}}, add_value };

    ripple_carry_adder #(
        .WIDTH(ACC_WIDTH)
    ) rca (
        .a(acc),
        .b(extended_add_value),
        .cin(1'b0),
        .sum(acc_new),
        .cout(cout)
    );

    // Always block triggered on the rising edge of the clock or the falling edge of the reset
    always @(posedge clk) begin
        if (!rst_n) begin
            // Asynchronous reset: when rst_n is low, reset the accumulator to 0
            acc <= {ACC_WIDTH{1'b0}};
        end else begin
            // On the rising edge of the clock, add the input value to the accumulator
            acc <= acc_new;
        end
    end

    // Assign the accumulator value to the output
    assign data = acc;

endmodule
