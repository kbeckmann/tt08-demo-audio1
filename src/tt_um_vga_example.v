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
  wire [6:0] rom_addr;
  reg  [6:0] rom_addr_r;
  reg  [7:0] rom_data;
  reg  [7:0] rom_data_r;

  always @(*) begin
    case (rom_addr_r)
      7'h00: rom_data = 8'h22;
      7'h01: rom_data = 8'h42;
      7'h02: rom_data = 8'h5E;
      7'h03: rom_data = 8'h5A;
      7'h04: rom_data = 8'h4B;
      7'h05: rom_data = 8'h2B;
      7'h06: rom_data = 8'h64;
      7'h07: rom_data = 8'h2A;
      7'h08: rom_data = 8'h15;
      7'h09: rom_data = 8'h58;
      7'h0A: rom_data = 8'h4F;
      7'h0B: rom_data = 8'h80;
      7'h0C: rom_data = 8'hB6;
      7'h0D: rom_data = 8'hBA;
      7'h0E: rom_data = 8'hFE;
      7'h0F: rom_data = 8'h2A;
      7'h10: rom_data = 8'hB3;
      7'h11: rom_data = 8'hCA;
      7'h12: rom_data = 8'h0C;
      7'h13: rom_data = 8'hAA;
      7'h14: rom_data = 8'h0D;
      7'h15: rom_data = 8'hA2;
      7'h16: rom_data = 8'hC6;
      7'h17: rom_data = 8'hB5;
      7'h18: rom_data = 8'h91;
      7'h19: rom_data = 8'h37;
      7'h1A: rom_data = 8'h97;
      7'h1B: rom_data = 8'hF7;
      7'h1C: rom_data = 8'h9D;
      7'h1D: rom_data = 8'h01;
      7'h1E: rom_data = 8'hC5;
      7'h1F: rom_data = 8'hBA;
      7'h20: rom_data = 8'h54;
      7'h21: rom_data = 8'hB8;
      7'h22: rom_data = 8'hD7;
      7'h23: rom_data = 8'h47;
      7'h24: rom_data = 8'hD4;
      7'h25: rom_data = 8'h41;
      7'h26: rom_data = 8'h3C;
      7'h27: rom_data = 8'h51;
      7'h28: rom_data = 8'hBF;
      7'h29: rom_data = 8'hF0;
      7'h2A: rom_data = 8'h19;
      7'h2B: rom_data = 8'hF9;
      7'h2C: rom_data = 8'hB2;
      7'h2D: rom_data = 8'h81;
      7'h2E: rom_data = 8'hEE;
      7'h2F: rom_data = 8'hBA;
      7'h30: rom_data = 8'h96;
      7'h31: rom_data = 8'h94;
      7'h32: rom_data = 8'hF8;
      7'h33: rom_data = 8'h3C;
      7'h34: rom_data = 8'h02;
      7'h35: rom_data = 8'h2E;
      7'h36: rom_data = 8'hB1;
      7'h37: rom_data = 8'hE2;
      7'h38: rom_data = 8'h79;
      7'h39: rom_data = 8'h65;
      7'h3A: rom_data = 8'h36;
      7'h3B: rom_data = 8'h4D;
      7'h3C: rom_data = 8'hF1;
      7'h3D: rom_data = 8'hE8;
      7'h3E: rom_data = 8'hA3;
      7'h3F: rom_data = 8'h3E;
      7'h40: rom_data = 8'hF9;
      7'h41: rom_data = 8'h41;
      7'h42: rom_data = 8'hFE;
      7'h43: rom_data = 8'h29;
      7'h44: rom_data = 8'hB4;
      7'h45: rom_data = 8'hBF;
      7'h46: rom_data = 8'hA6;
      7'h47: rom_data = 8'hF2;
      7'h48: rom_data = 8'hEF;
      7'h49: rom_data = 8'h78;
      7'h4A: rom_data = 8'hB5;
      7'h4B: rom_data = 8'hED;
      7'h4C: rom_data = 8'hFD;
      7'h4D: rom_data = 8'hCC;
      7'h4E: rom_data = 8'h1E;
      7'h4F: rom_data = 8'hE5;
      7'h50: rom_data = 8'hFB;
      7'h51: rom_data = 8'hCB;
      7'h52: rom_data = 8'h98;
      7'h53: rom_data = 8'h67;
      7'h54: rom_data = 8'h73;
      7'h55: rom_data = 8'h00;
      7'h56: rom_data = 8'hDD;
      7'h57: rom_data = 8'hCD;
      7'h58: rom_data = 8'hE7;
      7'h59: rom_data = 8'h2D;
      7'h5A: rom_data = 8'hD3;
      7'h5B: rom_data = 8'h05;
      7'h5C: rom_data = 8'hCF;
      7'h5D: rom_data = 8'hAB;
      7'h5E: rom_data = 8'hB0;
      7'h5F: rom_data = 8'h29;
      7'h60: rom_data = 8'hCA;
      7'h61: rom_data = 8'h29;
      7'h62: rom_data = 8'h6F;
      7'h63: rom_data = 8'hC6;
      7'h64: rom_data = 8'h26;
      7'h65: rom_data = 8'h64;
      7'h66: rom_data = 8'hC3;
      7'h67: rom_data = 8'h78;
      7'h68: rom_data = 8'h47;
      7'h69: rom_data = 8'h65;
      7'h6A: rom_data = 8'hF3;
      7'h6B: rom_data = 8'hDE;
      7'h6C: rom_data = 8'hA6;
      7'h6D: rom_data = 8'hE2;
      7'h6E: rom_data = 8'h29;
      7'h6F: rom_data = 8'hBA;
      7'h70: rom_data = 8'h75;
      7'h71: rom_data = 8'hE7;
      7'h72: rom_data = 8'h06;
      7'h73: rom_data = 8'h6A;
      7'h74: rom_data = 8'hCF;
      7'h75: rom_data = 8'h5B;
      7'h76: rom_data = 8'h67;
      7'h77: rom_data = 8'hC2;
      7'h78: rom_data = 8'hD0;
      7'h79: rom_data = 8'hEB;
      7'h7A: rom_data = 8'hFF;
      7'h7B: rom_data = 8'h98;
      7'h7C: rom_data = 8'h05;
      7'h7D: rom_data = 8'h6F;
      7'h7E: rom_data = 8'h0C;
      7'h7F: rom_data = 8'hE0;

      default: rom_data = 8'h00;
    endcase
  end

  always @(posedge clk) begin
    if (~rst_n) begin
      rom_addr_r <= 0;
      rom_data_r <= 0;
    end else begin
      rom_addr_r <= rom_addr;
      rom_data_r <= rom_data;
    end
  end

  assign rom_addr = counter[10:4];
  assign audio_sample = {8'h00, rom_data_r};

// Audio end

  always @(posedge clk) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end
  
endmodule
