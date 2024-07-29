/*
 * Copyright (c) 2024 Konrad Beckmann
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // Audio signals
  wire audio_out;
  wire [15:0] audio_sample;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Audio PMOD
  assign uio_out = {audio_out, 7'b0000000};
  assign uio_oe = 8'b10000000;

  // Suppress unused signals warning
  // wire _unused_ok = &{ena, ui_in, uio_in};
  wire _unused_ok = &{ena, ui_in, uio_in, pix_x, pix_y};

  reg [9:0] frame;
  // reg [16:0] counter;
  reg [6:0] counter;

// Audio start
  pdm pdm_gen(
    .clk(clk),
    .rst_n(rst_n),
    .pdm_in(audio_sample),
    .pdm_out(audio_out)
  );

  // wire [15:0] triangle = counter[16] ? -counter : counter;
  // assign audio_sample = triangle;

  // Just to test, let's add a small memory and output it as audio samples

  // ROM
  wire [3:0] rom_adr;
  wire [7:0] rom_data;
  always @(*) begin
      case (rom_adr)
          4'h0: rom_data = 8'h12;
          4'h1: rom_data = 8'h34;
          4'h2: rom_data = 8'h56;
          4'h3: rom_data = 8'h78;
          4'h4: rom_data = 8'h9A;
          4'h5: rom_data = 8'hBC;
          4'h6: rom_data = 8'hDE;
          4'h7: rom_data = 8'hF0;
          4'h8: rom_data = 8'h11;
          4'h9: rom_data = 8'h22;
          4'hA: rom_data = 8'h33;
          4'hB: rom_data = 8'h44;
          4'hC: rom_data = 8'h55;
          4'hD: rom_data = 8'h66;
          4'hE: rom_data = 8'h77;
          4'hF: rom_data = 8'h88;
          default: rom_data = 8'h00;
      endcase
  end

  assign rom_adr = counter[6:3];
  assign audio_sample = rom_data;

// Audio end


  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  assign R = video_active ? {frame[8], frame[9]} : 2'b00;
  assign G = video_active ? {frame[4], frame[5]} : 2'b00;
  assign B = video_active ? {frame[6], frame[7]} : 2'b00;
  
  always @(posedge clk) begin
    if (~rst_n) begin
      frame <= 0;
      counter <= 0;
    end else begin
      if (vsync) begin
        frame <= frame + 1;
      end else begin
        frame <= frame;
      end

      counter <= counter + 1;
    end
  end
  
endmodule