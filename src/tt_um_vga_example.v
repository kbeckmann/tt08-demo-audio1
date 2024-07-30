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

  // Audio signals
  wire audio_out;
  wire [15:0] audio_sample;

  // TinyVGA PMOD
  // assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  assign uo_out = 8'b00000000;

  // Audio PMOD
  assign uio_out = {audio_out, 7'b0000000};
  assign uio_oe = 8'b10000000;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [10:0] counter;

// Audio start
  pdm #(.N(16)) pdm_gen(
    .clk(clk),
    .rst_n(rst_n),
    .pdm_in(audio_sample),
    .pdm_out(audio_out)
  );

  // ROM
  wire [7:0] rom_addr;
  reg  [7:0] rom_addr_r;
  reg  [3:0] rom_data_h;
  reg  [3:0] rom_data_l;
  reg  [3:0] rom_data_h_r;
  reg  [3:0] rom_data_l_r;

  always @(*) begin
    case (rom_addr_r)
      8'h00: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0C;  end
      8'h01: begin  rom_data_h = 4'h03;  rom_data_l = 4'h0B;  end
      8'h02: begin  rom_data_h = 4'h02;  rom_data_l = 4'h07;  end
      8'h03: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h0E;  end
      8'h04: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h02;  end
      8'h05: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h0A;  end
      8'h06: begin  rom_data_h = 4'h08;  rom_data_l = 4'h0D;  end
      8'h07: begin  rom_data_h = 4'h02;  rom_data_l = 4'h01;  end
      8'h08: begin  rom_data_h = 4'h04;  rom_data_l = 4'h07;  end
      8'h09: begin  rom_data_h = 4'h05;  rom_data_l = 4'h05;  end
      8'h0A: begin  rom_data_h = 4'h04;  rom_data_l = 4'h09;  end
      8'h0B: begin  rom_data_h = 4'h00;  rom_data_l = 4'h09;  end
      8'h0C: begin  rom_data_h = 4'h04;  rom_data_l = 4'h0D;  end
      8'h0D: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h02;  end
      8'h0E: begin  rom_data_h = 4'h08;  rom_data_l = 4'h01;  end
      8'h0F: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h0B;  end
      8'h10: begin  rom_data_h = 4'h06;  rom_data_l = 4'h03;  end
      8'h11: begin  rom_data_h = 4'h07;  rom_data_l = 4'h01;  end
      8'h12: begin  rom_data_h = 4'h06;  rom_data_l = 4'h0C;  end
      8'h13: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h03;  end
      8'h14: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h05;  end
      8'h15: begin  rom_data_h = 4'h05;  rom_data_l = 4'h0E;  end
      8'h16: begin  rom_data_h = 4'h03;  rom_data_l = 4'h07;  end
      8'h17: begin  rom_data_h = 4'h04;  rom_data_l = 4'h0A;  end
      8'h18: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0B;  end
      8'h19: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h05;  end
      8'h1A: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h0D;  end
      8'h1B: begin  rom_data_h = 4'h06;  rom_data_l = 4'h03;  end
      8'h1C: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0D;  end
      8'h1D: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h0B;  end
      8'h1E: begin  rom_data_h = 4'h06;  rom_data_l = 4'h0A;  end
      8'h1F: begin  rom_data_h = 4'h00;  rom_data_l = 4'h07;  end
      8'h20: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0D;  end
      8'h21: begin  rom_data_h = 4'h01;  rom_data_l = 4'h00;  end
      8'h22: begin  rom_data_h = 4'h08;  rom_data_l = 4'h08;  end
      8'h23: begin  rom_data_h = 4'h00;  rom_data_l = 4'h01;  end
      8'h24: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h08;  end
      8'h25: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0D;  end
      8'h26: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h0B;  end
      8'h27: begin  rom_data_h = 4'h03;  rom_data_l = 4'h0F;  end
      8'h28: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0C;  end
      8'h29: begin  rom_data_h = 4'h07;  rom_data_l = 4'h05;  end
      8'h2A: begin  rom_data_h = 4'h09;  rom_data_l = 4'h0D;  end
      8'h2B: begin  rom_data_h = 4'h07;  rom_data_l = 4'h04;  end
      8'h2C: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h0A;  end
      8'h2D: begin  rom_data_h = 4'h06;  rom_data_l = 4'h0C;  end
      8'h2E: begin  rom_data_h = 4'h05;  rom_data_l = 4'h04;  end
      8'h2F: begin  rom_data_h = 4'h08;  rom_data_l = 4'h05;  end
      8'h30: begin  rom_data_h = 4'h03;  rom_data_l = 4'h08;  end
      8'h31: begin  rom_data_h = 4'h08;  rom_data_l = 4'h08;  end
      8'h32: begin  rom_data_h = 4'h09;  rom_data_l = 4'h01;  end
      8'h33: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0E;  end
      8'h34: begin  rom_data_h = 4'h09;  rom_data_l = 4'h0A;  end
      8'h35: begin  rom_data_h = 4'h03;  rom_data_l = 4'h0D;  end
      8'h36: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h0F;  end
      8'h37: begin  rom_data_h = 4'h00;  rom_data_l = 4'h06;  end
      8'h38: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h0F;  end
      8'h39: begin  rom_data_h = 4'h02;  rom_data_l = 4'h06;  end
      8'h3A: begin  rom_data_h = 4'h02;  rom_data_l = 4'h03;  end
      8'h3B: begin  rom_data_h = 4'h01;  rom_data_l = 4'h01;  end
      8'h3C: begin  rom_data_h = 4'h01;  rom_data_l = 4'h03;  end
      8'h3D: begin  rom_data_h = 4'h06;  rom_data_l = 4'h06;  end
      8'h3E: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h07;  end
      8'h3F: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h03;  end
      8'h40: begin  rom_data_h = 4'h05;  rom_data_l = 4'h07;  end
      8'h41: begin  rom_data_h = 4'h02;  rom_data_l = 4'h0B;  end
      8'h42: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h02;  end
      8'h43: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0B;  end
      8'h44: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h0A;  end
      8'h45: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h06;  end
      8'h46: begin  rom_data_h = 4'h04;  rom_data_l = 4'h03;  end
      8'h47: begin  rom_data_h = 4'h02;  rom_data_l = 4'h04;  end
      8'h48: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h08;  end
      8'h49: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0A;  end
      8'h4A: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0D;  end
      8'h4B: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0F;  end
      8'h4C: begin  rom_data_h = 4'h05;  rom_data_l = 4'h01;  end
      8'h4D: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h01;  end
      8'h4E: begin  rom_data_h = 4'h08;  rom_data_l = 4'h08;  end
      8'h4F: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h09;  end
      8'h50: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h0C;  end
      8'h51: begin  rom_data_h = 4'h00;  rom_data_l = 4'h05;  end
      8'h52: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h04;  end
      8'h53: begin  rom_data_h = 4'h01;  rom_data_l = 4'h09;  end
      8'h54: begin  rom_data_h = 4'h03;  rom_data_l = 4'h05;  end
      8'h55: begin  rom_data_h = 4'h02;  rom_data_l = 4'h0D;  end
      8'h56: begin  rom_data_h = 4'h08;  rom_data_l = 4'h04;  end
      8'h57: begin  rom_data_h = 4'h09;  rom_data_l = 4'h01;  end
      8'h58: begin  rom_data_h = 4'h07;  rom_data_l = 4'h05;  end
      8'h59: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0F;  end
      8'h5A: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h08;  end
      8'h5B: begin  rom_data_h = 4'h07;  rom_data_l = 4'h01;  end
      8'h5C: begin  rom_data_h = 4'h07;  rom_data_l = 4'h0A;  end
      8'h5D: begin  rom_data_h = 4'h07;  rom_data_l = 4'h07;  end
      8'h5E: begin  rom_data_h = 4'h01;  rom_data_l = 4'h01;  end
      8'h5F: begin  rom_data_h = 4'h01;  rom_data_l = 4'h08;  end
      8'h60: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h03;  end
      8'h61: begin  rom_data_h = 4'h05;  rom_data_l = 4'h05;  end
      8'h62: begin  rom_data_h = 4'h07;  rom_data_l = 4'h0F;  end
      8'h63: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h09;  end
      8'h64: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h0D;  end
      8'h65: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h07;  end
      8'h66: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h02;  end
      8'h67: begin  rom_data_h = 4'h02;  rom_data_l = 4'h0A;  end
      8'h68: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h06;  end
      8'h69: begin  rom_data_h = 4'h04;  rom_data_l = 4'h0C;  end
      8'h6A: begin  rom_data_h = 4'h00;  rom_data_l = 4'h04;  end
      8'h6B: begin  rom_data_h = 4'h04;  rom_data_l = 4'h01;  end
      8'h6C: begin  rom_data_h = 4'h08;  rom_data_l = 4'h08;  end
      8'h6D: begin  rom_data_h = 4'h04;  rom_data_l = 4'h09;  end
      8'h6E: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h07;  end
      8'h6F: begin  rom_data_h = 4'h03;  rom_data_l = 4'h09;  end
      8'h70: begin  rom_data_h = 4'h03;  rom_data_l = 4'h01;  end
      8'h71: begin  rom_data_h = 4'h03;  rom_data_l = 4'h07;  end
      8'h72: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h06;  end
      8'h73: begin  rom_data_h = 4'h04;  rom_data_l = 4'h0B;  end
      8'h74: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0C;  end
      8'h75: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0E;  end
      8'h76: begin  rom_data_h = 4'h04;  rom_data_l = 4'h0E;  end
      8'h77: begin  rom_data_h = 4'h09;  rom_data_l = 4'h07;  end
      8'h78: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h07;  end
      8'h79: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0C;  end
      8'h7A: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0A;  end
      8'h7B: begin  rom_data_h = 4'h08;  rom_data_l = 4'h00;  end
      8'h7C: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0A;  end
      8'h7D: begin  rom_data_h = 4'h08;  rom_data_l = 4'h07;  end
      8'h7E: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h0F;  end
      8'h7F: begin  rom_data_h = 4'h05;  rom_data_l = 4'h04;  end
      8'h80: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h08;  end
      8'h81: begin  rom_data_h = 4'h04;  rom_data_l = 4'h0D;  end
      8'h82: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0C;  end
      8'h83: begin  rom_data_h = 4'h02;  rom_data_l = 4'h00;  end
      8'h84: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h06;  end
      8'h85: begin  rom_data_h = 4'h09;  rom_data_l = 4'h07;  end
      8'h86: begin  rom_data_h = 4'h09;  rom_data_l = 4'h0A;  end
      8'h87: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h03;  end
      8'h88: begin  rom_data_h = 4'h06;  rom_data_l = 4'h07;  end
      8'h89: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h03;  end
      8'h8A: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h0A;  end
      8'h8B: begin  rom_data_h = 4'h07;  rom_data_l = 4'h05;  end
      8'h8C: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0B;  end
      8'h8D: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0D;  end
      8'h8E: begin  rom_data_h = 4'h08;  rom_data_l = 4'h04;  end
      8'h8F: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0A;  end
      8'h90: begin  rom_data_h = 4'h05;  rom_data_l = 4'h04;  end
      8'h91: begin  rom_data_h = 4'h06;  rom_data_l = 4'h0E;  end
      8'h92: begin  rom_data_h = 4'h06;  rom_data_l = 4'h0F;  end
      8'h93: begin  rom_data_h = 4'h02;  rom_data_l = 4'h03;  end
      8'h94: begin  rom_data_h = 4'h03;  rom_data_l = 4'h0D;  end
      8'h95: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h09;  end
      8'h96: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h00;  end
      8'h97: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h02;  end
      8'h98: begin  rom_data_h = 4'h08;  rom_data_l = 4'h0E;  end
      8'h99: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0E;  end
      8'h9A: begin  rom_data_h = 4'h00;  rom_data_l = 4'h00;  end
      8'h9B: begin  rom_data_h = 4'h06;  rom_data_l = 4'h08;  end
      8'h9C: begin  rom_data_h = 4'h04;  rom_data_l = 4'h06;  end
      8'h9D: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h03;  end
      8'h9E: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0F;  end
      8'h9F: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0C;  end
      8'hA0: begin  rom_data_h = 4'h01;  rom_data_l = 4'h03;  end
      8'hA1: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h0A;  end
      8'hA2: begin  rom_data_h = 4'h07;  rom_data_l = 4'h04;  end
      8'hA3: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h04;  end
      8'hA4: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h02;  end
      8'hA5: begin  rom_data_h = 4'h01;  rom_data_l = 4'h06;  end
      8'hA6: begin  rom_data_h = 4'h04;  rom_data_l = 4'h04;  end
      8'hA7: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0B;  end
      8'hA8: begin  rom_data_h = 4'h09;  rom_data_l = 4'h09;  end
      8'hA9: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0E;  end
      8'hAA: begin  rom_data_h = 4'h09;  rom_data_l = 4'h01;  end
      8'hAB: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0A;  end
      8'hAC: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h01;  end
      8'hAD: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0A;  end
      8'hAE: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0A;  end
      8'hAF: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0E;  end
      8'hB0: begin  rom_data_h = 4'h07;  rom_data_l = 4'h07;  end
      8'hB1: begin  rom_data_h = 4'h02;  rom_data_l = 4'h06;  end
      8'hB2: begin  rom_data_h = 4'h02;  rom_data_l = 4'h0A;  end
      8'hB3: begin  rom_data_h = 4'h09;  rom_data_l = 4'h04;  end
      8'hB4: begin  rom_data_h = 4'h07;  rom_data_l = 4'h02;  end
      8'hB5: begin  rom_data_h = 4'h08;  rom_data_l = 4'h0C;  end
      8'hB6: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h05;  end
      8'hB7: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h02;  end
      8'hB8: begin  rom_data_h = 4'h08;  rom_data_l = 4'h09;  end
      8'hB9: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h02;  end
      8'hBA: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h0B;  end
      8'hBB: begin  rom_data_h = 4'h08;  rom_data_l = 4'h06;  end
      8'hBC: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h00;  end
      8'hBD: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h02;  end
      8'hBE: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0C;  end
      8'hBF: begin  rom_data_h = 4'h02;  rom_data_l = 4'h0E;  end
      8'hC0: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0D;  end
      8'hC1: begin  rom_data_h = 4'h04;  rom_data_l = 4'h05;  end
      8'hC2: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h0A;  end
      8'hC3: begin  rom_data_h = 4'h08;  rom_data_l = 4'h0E;  end
      8'hC4: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h08;  end
      8'hC5: begin  rom_data_h = 4'h05;  rom_data_l = 4'h0E;  end
      8'hC6: begin  rom_data_h = 4'h08;  rom_data_l = 4'h03;  end
      8'hC7: begin  rom_data_h = 4'h02;  rom_data_l = 4'h00;  end
      8'hC8: begin  rom_data_h = 4'h02;  rom_data_l = 4'h03;  end
      8'hC9: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h06;  end
      8'hCA: begin  rom_data_h = 4'h09;  rom_data_l = 4'h09;  end
      8'hCB: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h0B;  end
      8'hCC: begin  rom_data_h = 4'h00;  rom_data_l = 4'h09;  end
      8'hCD: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h03;  end
      8'hCE: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0C;  end
      8'hCF: begin  rom_data_h = 4'h00;  rom_data_l = 4'h01;  end
      8'hD0: begin  rom_data_h = 4'h05;  rom_data_l = 4'h01;  end
      8'hD1: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0C;  end
      8'hD2: begin  rom_data_h = 4'h00;  rom_data_l = 4'h00;  end
      8'hD3: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h0E;  end
      8'hD4: begin  rom_data_h = 4'h05;  rom_data_l = 4'h0A;  end
      8'hD5: begin  rom_data_h = 4'h05;  rom_data_l = 4'h0A;  end
      8'hD6: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h07;  end
      8'hD7: begin  rom_data_h = 4'h0B;  rom_data_l = 4'h0C;  end
      8'hD8: begin  rom_data_h = 4'h07;  rom_data_l = 4'h0E;  end
      8'hD9: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0C;  end
      8'hDA: begin  rom_data_h = 4'h00;  rom_data_l = 4'h00;  end
      8'hDB: begin  rom_data_h = 4'h01;  rom_data_l = 4'h01;  end
      8'hDC: begin  rom_data_h = 4'h09;  rom_data_l = 4'h0D;  end
      8'hDD: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h00;  end
      8'hDE: begin  rom_data_h = 4'h03;  rom_data_l = 4'h0A;  end
      8'hDF: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h0C;  end
      8'hE0: begin  rom_data_h = 4'h09;  rom_data_l = 4'h05;  end
      8'hE1: begin  rom_data_h = 4'h01;  rom_data_l = 4'h0F;  end
      8'hE2: begin  rom_data_h = 4'h02;  rom_data_l = 4'h02;  end
      8'hE3: begin  rom_data_h = 4'h08;  rom_data_l = 4'h09;  end
      8'hE4: begin  rom_data_h = 4'h06;  rom_data_l = 4'h0C;  end
      8'hE5: begin  rom_data_h = 4'h00;  rom_data_l = 4'h0B;  end
      8'hE6: begin  rom_data_h = 4'h07;  rom_data_l = 4'h04;  end
      8'hE7: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h02;  end
      8'hE8: begin  rom_data_h = 4'h04;  rom_data_l = 4'h06;  end
      8'hE9: begin  rom_data_h = 4'h04;  rom_data_l = 4'h0A;  end
      8'hEA: begin  rom_data_h = 4'h09;  rom_data_l = 4'h05;  end
      8'hEB: begin  rom_data_h = 4'h07;  rom_data_l = 4'h01;  end
      8'hEC: begin  rom_data_h = 4'h07;  rom_data_l = 4'h03;  end
      8'hED: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h03;  end
      8'hEE: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h0B;  end
      8'hEF: begin  rom_data_h = 4'h0E;  rom_data_l = 4'h01;  end
      8'hF0: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h09;  end
      8'hF1: begin  rom_data_h = 4'h06;  rom_data_l = 4'h08;  end
      8'hF2: begin  rom_data_h = 4'h0C;  rom_data_l = 4'h05;  end
      8'hF3: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h03;  end
      8'hF4: begin  rom_data_h = 4'h08;  rom_data_l = 4'h0C;  end
      8'hF5: begin  rom_data_h = 4'h09;  rom_data_l = 4'h0D;  end
      8'hF6: begin  rom_data_h = 4'h01;  rom_data_l = 4'h06;  end
      8'hF7: begin  rom_data_h = 4'h09;  rom_data_l = 4'h0D;  end
      8'hF8: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h01;  end
      8'hF9: begin  rom_data_h = 4'h0D;  rom_data_l = 4'h0F;  end
      8'hFA: begin  rom_data_h = 4'h0A;  rom_data_l = 4'h09;  end
      8'hFB: begin  rom_data_h = 4'h06;  rom_data_l = 4'h06;  end
      8'hFC: begin  rom_data_h = 4'h08;  rom_data_l = 4'h02;  end
      8'hFD: begin  rom_data_h = 4'h09;  rom_data_l = 4'h02;  end
      8'hFE: begin  rom_data_h = 4'h09;  rom_data_l = 4'h02;  end
      8'hFF: begin  rom_data_h = 4'h0F;  rom_data_l = 4'h05;  end

      default:
        begin
          rom_data_h = 4'h00;
          rom_data_l = 4'h00;
        end
    endcase
  end

  always @(posedge clk) begin
    if (~rst_n) begin
      rom_addr_r <= 0;
      rom_data_h_r <= 0;
      rom_data_l_r <= 0;
    end else begin
      rom_addr_r <= rom_addr;
      rom_data_h_r <= rom_data_h;
      rom_data_l_r <= rom_data_l;
    end
  end

  assign rom_addr = counter[10:3];
  assign audio_sample = {8'h00, rom_data_h_r, rom_data_l_r};

// Audio end

  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
endmodule
