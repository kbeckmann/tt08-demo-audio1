`default_nettype none

module voice(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,          // enable signal, when high, calculation is done.
    input  wire [15:0] frequency,   // frequency, but it's not Hz...
    input  wire [11:0] pulsewidth,  // pulse width %. 0 = 0%, 1<<11 = 50%, (1<<12)-1 = 100%
    output wire        voice        // waveform data out.
);

parameter                 ACC_WIDTH = 24;
parameter                 ADD_WIDTH = 16;
reg      [ACC_WIDTH-1:0] accumulator;
wire      [ADD_WIDTH-1:0] add_value;
reg                       pulse       = 0;

assign voice = pulse;
assign add_value = en ? frequency : 0;

// // Instantiate the accumulator module
// accumulator_rca #(
//     .ACC_WIDTH(ACC_WIDTH),
//     .ADD_WIDTH(ADD_WIDTH)
// ) acc (
//     .clk(clk),
//     .rst_n(rst_n),
//     .add_value(add_value),
//     .data(accumulator)
// );

always @(posedge clk)
begin
    if (~rst_n)
    begin
        pulse <= 0;
    end
    else begin
        if (en) begin
            accumulator <= accumulator + add_value;
            if (accumulator[23:12] >= pulsewidth[11:0])
                pulse <= 1;
            else
                pulse <= 0;
        end
    end
end

endmodule
