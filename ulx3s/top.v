`default_nettype none
module top
(
  // Clock
  input         clk_25mhz,
  // Needed in order to turn off the wifi module
  output        wifi_en,
  // HDMI
  output [3:0]  gpdi_dp,
  output [3:0]  gpdi_dn,
  // Audio
  output [3:0]  audio_l,
  output [3:0]  audio_r,
  // Leds
  output [7:0]  led
);

  // Keep wifi off
  assign wifi_en = 1'b0;

  // ===============================================================
  // Clock generation
  // ===============================================================
  wire [3:0] clocks;
  ecp5pll
  #(
      .in_hz( 25*1000000),
    .out0_hz(125*1000000),
    .out1_hz( 25*1000000),
  )
  ecp5pll_inst
  (
    .clk_i(clk_25mhz),
    .clk_o(clocks)
  );

  wire clk_25x1 = clocks[1];
  wire clk_25x5 = clocks[0];

  // ===============================================================
  // Reset generation
  // ===============================================================
  reg [5:0] reset_cnt;
  wire rst_n = &reset_cnt;
  
  always @(posedge clk_25mhz) begin
    reset_cnt <= reset_cnt + !rst_n;
  end

  // ===============================================================
  // TinyTapeout design instance
  // ===============================================================
  wire ena = 1'b1;
  wire [7:0] ui_in = 8'b0;
  wire [7:0] uio_in = 8'b0;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  // assign uio_out = {audio_pdm, video_active, 6'b000000};

  // ULX3S has a 4 bit resistor DAC, but the TT design has a 1 bit PDM output.
  assign audio_l = {4{uio_out[7]}};
  assign audio_r = {4{uio_out[7]}};

  wire [7:0] vga_r = {uo_out[0], uo_out[4], 6'b000000};
  wire [7:0] vga_g = {uo_out[1], uo_out[5], 6'b000000};
  wire [7:0] vga_b = {uo_out[2], uo_out[6], 6'b000000};
  wire vga_hsync = uo_out[7];
  wire vga_vsync = uo_out[3];
  wire vga_blank = ~uio_out[6];

  assign led = uo_out;

  tt_um_top tt_um_top_instance (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk_25x1), // clock
      .rst_n  (rst_n)     // not reset
  );

  // ===============================================================
  // Convert VGA to HDMI
  // ===============================================================
  HDMI_out vga2dvid (
    .pixclk(clk_25x1),
    .pixclk_x5(clk_25x5),
    .red(vga_r),
    .green(vga_g),
    .blue(vga_b),
    .vde(~vga_blank),
    .hSync(vga_hsync),
    .vSync(vga_vsync),
    .gpdi_dp(gpdi_dp),
    .gpdi_dn(gpdi_dn)
  );

endmodule
