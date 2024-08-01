/*
* Copyright (c) 2024 Konrad Beckmann
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_top(
`ifdef VERILATOR
  // Extra signals for web simulator
  output wire        audio_en , // Audio Enabled. Set to false to enable video rendering
  output wire [15:0] audio_out, // Audio sample output
  output wire [31:0] clk_hz,    // clk frequency in Hz. Output consumed by simulator to adjust sampling rate (when to consume audio_out)
`endif

  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

// ------------------------------
// Audio signals
wire audio_pdm;
wire [12:0] audio_sample;

`ifdef VERILATOR
  // assign clk_hz = 48000 * 21; // Close enough to 1MHz, but integer factor of 48kHz
  // assign audio_en = 1'b1;
  assign audio_en = 1'b0;
  assign audio_out = {4'b0, audio_sample} <<  4;
  assign clk_hz = 1000000;
`endif

// ------------------------------
// VGA signals
wire hsync;
wire vsync;
wire [1:0] R;
wire [1:0] G;
wire [1:0] B;
wire video_active;
wire [9:0] pix_x;
wire [9:0] pix_y;

// TinyVGA PMOD
assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

// Audio PMOD
assign uio_out = {audio_pdm, 7'b0000000};
assign uio_oe = 8'b10000000;

// Suppress unused signals warning
wire _unused_ok = &{ena, ui_in, uio_in};

// ------------------------------
// Audio start
pdm #(.N(12)) pdm_gen(
  .clk(clk),
  .rst_n(rst_n),
  .pdm_in(audio_sample),
  .pdm_out(audio_pdm)
);

reg [24:0] counter;
always @(posedge clk) begin
  if (~rst_n) begin
    counter <= 0;
  end else begin
    counter <= counter + 1;
  end
end

wire [ 3:0] note_in;
wire [15:0] freq_out;

assign note_in = counter[19:17] & counter[23:20];

scale_rom scale_rom_instance(
  .note_in(note_in),
  .freq_out(freq_out)
);

wire [11:0] voice1;

wire gate1 = counter[17:0] < (1 << 16);
reg [ 7:0] control1 = {7'b0001000, gate1};

wire msb;

voice #() Voice1(
  .clk_1MHz(clk),
  .reset(~rst_n),
  .frequency(freq_out >> 3),
  .pulsewidth(1<<11),
  .control(control1),
  .Att_dec(8'h29),
  .Sus_Rel(8'h79),
  .PA_MSB_in(),
  .PA_MSB_out(msb),
  .voice(voice1)
);
assign audio_sample = voice1;

// Audio end

// ------------------------------
// VGA start
  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

reg [9:0] vsync_r;
reg [9:0] counter_vsync;
wire [9:0] moving_x = pix_x + counter_vsync;

assign R = video_active ? {moving_x[5], pix_y[2]} : 2'b00;
assign G = video_active ? {moving_x[6], pix_y[2]} : 2'b00;
assign B = video_active ? {moving_x[7], pix_y[5]} : 2'b00;

always @(posedge clk) begin
  if (~rst_n) begin
    vsync_r <= 0;
    counter_vsync <= 0;
  end else begin
    vsync_r <= vsync;
    if (~vsync_r & vsync) begin
      counter_vsync <= counter_vsync + 1;
    end else begin
      counter_vsync <= counter_vsync;
    end
  end
end

// VGA end

endmodule

